#!/usr/bin/env python3
"""
upload_resources.py - Script chay truoc khi deploy: pack + copy + sinh
bundle_resource_config.json cho tung bundle.

Luong:
1. Voii tung bundle trong raw_assets/:
   a. Pack SVG  (raw_assets/<b>/svg/*        -> assets/<b>/packs/<b>.<hash>.svg)
   b. Pack WebP (raw_assets/<b>/packs/*       -> assets/<b>/packs/<b>_<sub>.<hash>.webp + .json)
   c. Copy images/   (hash noi dung) -> assets/<b>/images/<rel>.<hash>.<ext>
   d. Copy cac folder khac (hash noi dung) -> assets/<b>/others/<rel>.<hash>.<ext>
      (bo qua: svg, packs, images)
   e. Sinh config: assets/<b>/bundle_resource_config.json
      {
        "name":   "<b>",
        "svg":    "<b>.<hash>.svg" | null,
        "atlases": ["<b>_<sub>.<hash>", ...],
        "images":  ["images/rel.<hash>.ext", ...],
        "others": ["others/rel.<hash>.ext", ...]
      }

Cach dung:
  python3 tools/upload_resources.py
  python3 tools/upload_resources.py --raw-assets proj_resources/raw_assets --assets assets
  python3 tools/upload_resources.py --bundle diamond
  python3 tools/upload_resources.py --skip-pack   (chi copy + sinh config, khong pack lai)
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import time
from datetime import datetime
import shutil
import subprocess
import sys
from pathlib import Path

# .env local (keyfile/pass mỗi dev) — không cần pip dotenv.
sys.path.insert(0, str(Path(__file__).parent))
from dotenv_local import load_dotenv  # noqa: E402
load_dotenv()

def _ensure_dep(module_name: str, pip_name: str) -> None:
    """Import module, thiếu thì pip install rồi import lại.

    Sau khi cài, tự thêm user site-packages vào sys.path: pip có thể rơi về
    --user install (site-packages hệ thống read-only, vd Python của Xcode trên
    macOS); nếu thư mục user site VỪA được tạo mới bởi lệnh cài thì process
    đang chạy chưa có nó trong sys.path (module `site` chỉ thêm lúc khởi động
    interpreter) → không thêm tay sẽ phải chạy script lần 2 mới ăn.
    """
    try:
        __import__(module_name)
    except ImportError:
        print(f'[INFO] Thiếu thư viện {pip_name}, đang tự động cài đặt...')
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', pip_name])
        import importlib
        import site
        site.addsitedir(site.getusersitepackages())
        importlib.invalidate_caches()
        __import__(module_name)


_ensure_dep('paramiko', 'paramiko')
# Pillow: pack_svg_sprite.py / pack_webp.py (import phía dưới) cần `PIL`.
_ensure_dep('PIL', 'Pillow')

import paramiko  # noqa: E402


# ANSI color codes
_RED = "\033[91m"
_RESET = "\033[0m"


def check_duplicate_filenames(raw_assets: Path) -> None:
    """
    Duyet toan bo file trong raw_assets (tat ca bundle, tat ca subfolder),
    tim nhung file co cung ten (chi stem, khong tinh duoi mo rong), in loi
    do va thoat. VD: a.png va a.webp duoc coi la trung ten.
    """
    seen: dict[str, list[Path]] = {}
    for f in raw_assets.rglob("*"):
        if not f.is_file():
            continue
        if f.name in (".DS_Store",):
            continue
        key = f.stem  # chi lay ten file, bo qua duoi (.png, .webp, ...)
        seen.setdefault(key, []).append(f)

    duplicates = {k: v for k, v in seen.items() if len(v) > 1}
    if duplicates:
        print(f"\n{_RED}{'=' * 60}{_RESET}")
        print(f"{_RED}❌  PHAT HIEN FILE TRUNG TEN TRONG raw_assets!{_RESET}")
        print(f"{_RED}{'=' * 60}{_RESET}")
        for name, paths in sorted(duplicates.items()):
            print(f"\n{_RED}  • {name} (cac file: {', '.join(p.suffix for p in paths)}){_RESET}")
            for p in paths:
                print(f"    {p.relative_to(raw_assets.parent)}")
        print(f"\n{_RED}{'=' * 60}{_RESET}")
        print(f"{_RED}⚠  Vui long sua lai ten file de khong trung nhau, sau do chay lai.{_RESET}")
        print(f"{_RED}{'=' * 60}{_RESET}")
        sys.exit(1)


DEFAULT_DEPLOY_ENV = 'staging'

# SSH key/pass: CLI (--key-file/--key-pass) > ENV (.env) > '' (rỗng).
# KHÔNG có giá trị mặc định trong code — mỗi dev tự đặt SSH_KEY_FILE /
# SSH_KEY_PASS trong .env của mình (xem .env.example). Thiếu key -> lỗi rõ.

DEPLOY_PRESETS = {
    'staging': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/staging/commons/',
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
    'prod': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/prod/commons/',
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
    'pre': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/prod/commons/pre',
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
}


# Import cac ham pack tu tool ban ngan
sys.path.insert(0, str(Path(__file__).parent))
from pack_svg_sprite import pack_bundle as pack_svg_bundle  # noqa: E402
from pack_webp import pack_bundle as pack_webp_bundle  # noqa: E402

# Folder duoc bo qua khi copy "others"
SKIP_FOLDERS = {"svg", "packs", "images"}


def hash_file_content(filepath: str | Path) -> str:
    """MD5 hash noi dung file (chi data, khong meta nhu mtime)."""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def clean_dir(folder: Path) -> None:
    if folder.exists():
        shutil.rmtree(folder, ignore_errors=True)
    folder.mkdir(parents=True, exist_ok=True)


def coalesce_str(cli_value: str | None, default_value: str) -> str:
    if cli_value is not None and str(cli_value).strip():
        return str(cli_value).strip()
    return str(default_value).strip()


def resolve_ssh_key(cli_file: str | None, cli_pass: str | None, preset: dict) -> tuple[str, str]:
    """CLI > ENV (.env) > preset. Thiếu key file -> lỗi rõ, không dùng chùa."""
    import os
    key = (cli_file or '').strip() or os.getenv('SSH_KEY_FILE', '').strip() \
        or str(preset.get('ssh_key_file', '')).strip()
    if cli_pass is not None and str(cli_pass).strip():
        pwd = str(cli_pass)
    elif 'SSH_KEY_PASS' in os.environ:
        pwd = os.environ['SSH_KEY_PASS']
    else:
        pwd = str(preset.get('ssh_key_pass', ''))
    if not key:
        raise RuntimeError(
            'Thiếu SSH key file. Đặt SSH_KEY_FILE trong .env '
            '(xem .env.example) hoặc truyền --key-file.')
    return key, pwd


def get_deploy_preset(env_name: str) -> dict:
    preset = DEPLOY_PRESETS.get(env_name)
    if preset is None:
        raise RuntimeError(f"Preset môi trường không hợp lệ: {env_name}")
    return preset


def resolve_staging_dev(cli_dev: int | None, env_name: str) -> str | None:
    """Trả về `devN` khi `--env staging`, ngược lại None (prod/pre giữ nguyên).

    - `--dev N` (1..10) được dùng luôn.
    - Không truyền `--dev`: hỏi interactive; **Enter = staging GỐC — không có
      sub-env** → trả None, KHÔNG nối devN vào server_path. Môi trường không
      tương tác (CI, stdin không phải tty) cũng vậy. Giá trị ngoài 1..10:
      cảnh báo rồi coi như Enter.
    """
    if env_name != 'staging':
        return None
    if cli_dev is not None:
        return f'dev{int(cli_dev)}'
    try:
        if sys.stdin.isatty():
            print('\n----- STAGING: chọn dev path (1-10, Enter = staging gốc, không devN) -----')
            raw = input('dev [1-10, Enter=staging gốc]: ').strip()
            if not raw:
                return None
            n = int(raw) if raw.isdigit() else None
            if n is not None and 1 <= n <= 10:
                return f'dev{n}'
            print(f'  ⚠ Giá trị "{raw}" không hợp lệ (1-10) → staging gốc (không devN).')
            return None
    except (EOFError, KeyboardInterrupt):
        pass
    return None


def apply_staging_dev_path(base_path: str, dev: str | None) -> str:
    """Nối `devN` vào server_path staging (idempotent, tránh gấp đôi)."""
    base = base_path.rstrip('/')
    if not dev:
        return base
    if base.endswith(f'/{dev}'):
        return base
    return f'{base}/{dev}'


def copy_with_content_hash(src_file: Path, out_dir: Path) -> str:
    """
    Copy file, hash noi dung, luu thanh <ten_cu>.<hash>.<ext> trong out_dir.
    Tra ve ten file moi (ten file, khong ke duong dan).
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    ext = src_file.suffix
    short_hash = hash_file_content(src_file)[:8]
    new_name = f"{src_file.stem}.{short_hash}{ext}"
    dest = out_dir / new_name
    shutil.copy2(src_file, dest)
    return new_name


def copy_tree_with_hash(src_root: Path, out_root: Path, bundle_assets: Path) -> list[str]:
    """
    Copy toan bo file trong src_root sang out_root, hash noi dung, giu nguyen
    cau truc thu muc con. Tra ve danh sach duong dan tuong doi (rel so voi
    bundle_assets) cua cac file moi, dung de ghi vao config.
    """
    out_root.mkdir(parents=True, exist_ok=True)
    results: list[str] = []
    for src_file in sorted(src_root.rglob("*")):
        if not src_file.is_file():
            continue
        if src_file.name in (".DS_Store",):
            continue
        rel = src_file.relative_to(src_root)
        out_file_dir = out_root / rel.parent
        new_name = copy_with_content_hash(src_file, out_file_dir)
        # Duong dan tuong doi so voi bundle_assets (vi _fileUrl them tien to folder)
        rel_in_bundle = (out_root / rel.parent / new_name).relative_to(bundle_assets)
        results.append(str(rel_in_bundle).replace("\\", "/"))
    return results


def copy_others_flat(bundle_raw: Path, out_dir: Path, bundle_assets: Path, skip: set[str]) -> list[str]:
    """
    Copy TAT CA file (recursive) trong cac folder cua bundle (tru skip) sang
    out_dir MOT CACH PHANG (flat): bo qua cau truc subfolder, chi lay ten file
    goc + hash. Tra ve danh sach duong dan tuong doi (rel so voi bundle_assets)
    cua cac file moi, dung de ghi vao config.
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    results: list[str] = []
    used_names: set[str] = set()

    for sub in sorted([p for p in bundle_raw.iterdir() if p.is_dir() and not p.name.startswith(".")]):
        if sub.name in skip:
            continue
        for src_file in sorted(sub.rglob("*")):
            if not src_file.is_file():
                continue
            if src_file.name in (".DS_Store",):
                continue
            ext = src_file.suffix
            short_hash = hash_file_content(src_file)[:8]
            # Ten moi phang: <ten_cu>.<hash>.<ext>
            new_name = f"{src_file.stem}.{short_hash}{ext}"
            # Tranh trung ten: neu trung, them ten folder goc vao truoc
            if new_name in used_names:
                new_name = f"{sub.name}_{src_file.stem}.{short_hash}{ext}"
            used_names.add(new_name)
            dest = out_dir / new_name
            shutil.copy2(src_file, dest)
            rel_in_bundle = (out_dir / new_name).relative_to(bundle_assets)
            results.append(str(rel_in_bundle).replace("\\", "/"))
    return results


def scan_packs(bundle_assets: Path) -> tuple[str | None, list[str]]:
    """
    Quet assets/<b>/packs/ de thu thap:
      - svg  : ten file .svg sprite (1 cai) hoac None
      - atlas: ten '<b>_<sub>.<hash>' (GIU hash, bo duoi .webp/.json) cua cac
        cap .webp/.json.

    GIU hash trong ten atlas la BAT BUOC: BundleManager._atlasBaseUrl ghep
    'packs/<atlas>' roi noi '.json'/'.webp' -> phai co hash moi ra dung URL
    (vd main_avatars.e7260c94.json). Cap .json/.webp cua 1 atlas dung CHUNG
    hash nen 1 stem la du. Phia doc atlas tu strip hash (_extractFilename) de
    lam cache key on dinh nen van thong nhat.
    """
    packs_dir = bundle_assets / "packs"
    svg_name: str | None = None
    atlases: list[str] = []

    if packs_dir.is_dir():
        for f in sorted(packs_dir.iterdir()):
            if not f.is_file():
                continue
            if f.suffix.lower() == ".svg":
                svg_name = f.name
            elif f.suffix.lower() == ".webp":
                stem = f.stem  # vd 'main_avatars.e7260c94' (da bo .webp)
                if stem not in atlases:
                    atlases.append(stem)
    return svg_name, atlases


def process_bundle(bundle_raw: Path, bundle_name: str, assets_dir: Path, skip_pack: bool) -> str:
    bundle_assets = assets_dir / bundle_name

    print(f"\n{'=' * 60}\n📦 Bundle: {bundle_name}\n{'=' * 60}")

    # THU TU BAT BUOC: Pack SVG TRUOC, Pack WebP SAU.
    # Pack SVG co the tach cac SVG that ra la anh raster (base64 <image>) thanh
    # WebP them vao raw_assets/<bundle>/packs/ (va xoa .svg loi). Pack WebP chay
    # ngay sau se gom cac anh moi nay vao atlas <bundle>.
    if not skip_pack:
        # 1. Pack SVG (co the sinh them WebP vao images/)
        print("\n• Pack SVG sprite")
        pack_svg_bundle(bundle_raw, bundle_name, assets_dir)

        # 2. Pack WebP atlas
        print("\n• Pack WebP atlas")
        pack_webp_bundle(bundle_raw, bundle_name, assets_dir)

    # 3. Copy images/ (hash noi dung) - chi tao folder neu thuc su co file
    print("\n• Copy images")
    images_dir = bundle_raw / "images"
    images_out = bundle_assets / "images"
    if images_dir.is_dir() and any(f.is_file() for f in images_dir.rglob("*")):
        clean_dir(images_out)
        copy_tree_with_hash(images_dir, images_out, bundle_assets)

    # 4. Copy cac folder khac -> others/ (hash noi dung, phang) - chi tao neu co file
    print("\n• Copy others")
    others_out = bundle_assets / "others"
    others_src = [
        sub for sub in bundle_raw.iterdir()
        if sub.is_dir() and not sub.name.startswith(".")
        and sub.name not in SKIP_FOLDERS
    ]
    if any(f.is_file() for sub in others_src for f in sub.rglob("*")):
        clean_dir(others_out)
        copy_others_flat(bundle_raw, others_out, bundle_assets, SKIP_FOLDERS)

    # 5. Sinh config
    svg_name, atlases = scan_packs(bundle_assets)

    images_list: list[str] = []
    images_scan = bundle_assets / "images"
    if images_scan.is_dir():
        images_prefix = "images/"
        for f in sorted(images_scan.rglob("*")):
            if f.is_file() and f.name != ".DS_Store":
                rel = str(f.relative_to(bundle_assets)).replace("\\", "/")
                # Strip "images/" prefix giu subpath (vd games/abc.webp)
                if rel.startswith(images_prefix):
                    rel = rel[len(images_prefix):]
                images_list.append(rel)

    others_list: list[str] = []
    others_scan = bundle_assets / "others"
    if others_scan.is_dir():
        others_prefix = "others/"
        for f in sorted(others_scan.rglob("*")):
            if f.is_file() and f.name != ".DS_Store":
                rel = str(f.relative_to(bundle_assets)).replace("\\", "/")
                # Strip "others/" prefix giu subpath (vd sounds/xyz.mp3)
                if rel.startswith(others_prefix):
                    rel = rel[len(others_prefix):]
                others_list.append(rel)

    config = {
        "name": bundle_name,
        "svg": svg_name,
        "atlases": atlases,
        "images": images_list,
        "others": others_list,
    }

    config_path = bundle_assets / "bundle_resource_config.json"
    bundle_assets.mkdir(parents=True, exist_ok=True)
    # Xoa MOI config cu cua bundle (unhashed + da hash) truoc khi ghi ban moi.
    # Nho vay thu muc chi con dung 1 config -> build_global_config khong the
    # chon nham hash cu (chinh la nguyen nhan bug "images/images").
    for old_cfg in bundle_assets.glob("bundle_resource_config*.json"):
        old_cfg.unlink(missing_ok=True)
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    # Hash noi dung config -> 8 ky tu -> them truong "version" + "created_at" -> doi ten
    # thanh bundle_resource_config.<8hash>.json
    short_hash = hash_file_content(config_path)[:8]
    config["version"] = short_hash
    config["created_at"] = datetime.now().strftime("%Y-%m-%d %H:%M")
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    hashed_config = bundle_assets / f"bundle_resource_config.{short_hash}.json"
    if hashed_config.exists():
        hashed_config.unlink(missing_ok=True)
    config_path.rename(hashed_config)

    print(f"\n✅ Config: {hashed_config.relative_to(assets_dir.parent)}")
    print(f"   version : {short_hash}")
    print(f"   svg     : {svg_name or '(khong co)'}")
    print(f"   atlases : {len(atlases)} file")
    print(f"   images  : {len(images_list)} file")
    print(f"   others  : {len(others_list)} file")

    # Tra ve hash vua tao de main() gom lai va truyen thang cho
    # build_global_config -> khong con phai doan hash bang cach quet thu muc.
    return short_hash


def _scan_bundle_hash(bundle_dir: Path) -> str:
    """
    Fallback lay hash config cua 1 bundle KHONG nam trong lan chay hien tai
    (vd chay `--bundle X` thi cac bundle khac lay hash tu day). Doc file config
    da hash MOI NHAT theo mtime — KHONG dung sort ten (hash la content-hash,
    thu tu chu cai vo nghia -> tung chon nham ban cu, gay bug "images/images").
    """
    stale = bundle_dir / "bundle_resource_config.json"
    if stale.exists():
        stale.unlink(missing_ok=True)
    matches = list(bundle_dir.glob("bundle_resource_config.*.json"))
    if not matches:
        return ""
    newest = max(matches, key=lambda p: p.stat().st_mtime)
    stem = newest.stem  # bundle_resource_config.<hash>
    return stem.rsplit(".", 1)[-1] if "." in stem else ""


def build_global_config(
    assets_dir: Path,
    proj_resources_dir: Path,
    known_hashes: dict[str, str],
) -> None:
    """
    Tong hop tat ca bundle thanh bundle_config.json tai goc assets/:
      { "<bundle>": "<8hash>", ... }
    sau do hash noi dung file -> doi ten thanh bundle_config.<8hash>.json.
    Dong thoi sinh version_resource_config.json tai proj_resources/ (URL tinh,
    khong hash ten) de app native match version, web luon dung default.

    [known_hashes]: map {bundle_name: hash} do process_bundle vua tao trong lan
    chay nay -> dung TRUC TIEP (chinh xac tuyet doi). Bundle khong co trong day
    (vd chay --bundle X) moi fallback quet thu muc qua [_scan_bundle_hash].
    """
    # Xoa cac file bundle_config cu (ke ca da hash) de chi giu lai ban moi nhat
    for old in assets_dir.glob("bundle_config*.json"):
        old.unlink(missing_ok=True)

    mapping: dict[str, str] = {}
    dynamic_hash: str | None = None
    for bundle_dir in sorted(
        p for p in assets_dir.iterdir() if p.is_dir() and not p.name.startswith(".")
    ):
        # Uu tien hash vua tao trong lan chay; khong co thi fallback quet thu muc.
        h = known_hashes.get(bundle_dir.name) or _scan_bundle_hash(bundle_dir)
        # Skip "dynamic" bundle in global config (will be stored separately)
        if bundle_dir.name == "dynamic":
            # Still collect its hash for version_resource_config
            if h:
                dynamic_hash = h
            continue
        if h:
            mapping[bundle_dir.name] = h

    if not mapping:
        print("\n⚠  Khong co bundle nao de tong hop bundle_config.")
        return

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
    global_path = assets_dir / "bundle_config.json"
    # Ghi file KHONG co created_at -> hash noi dung -> them created_at -> ghi lai -> rename
    with open(global_path, "w", encoding="utf-8") as f:
        json.dump(mapping, f, indent=2, ensure_ascii=False)

    short_hash = hash_file_content(global_path)[:8]
    mapping["created_at"] = now_str
    with open(global_path, "w", encoding="utf-8") as f:
        json.dump(mapping, f, indent=2, ensure_ascii=False)
    hashed_global = assets_dir / f"bundle_config.{short_hash}.json"
    if hashed_global.exists():
        hashed_global.unlink(missing_ok=True)
    global_path.rename(hashed_global)
    print(f"\n✅ Global bundle_config: {hashed_global.relative_to(assets_dir.parent)}  ({len(mapping)} bundle)")

    # Sinh version_resource_config.json tai proj_resources/ (URL tinh, khong hash)
    # Doc file cu neu co de giu nguyen app_versions mapping
    version_config_path = proj_resources_dir / "version_resource_config.json"
    existing_versions: dict[str, str] = {}
    if version_config_path.exists():
        try:
            with open(version_config_path, "r", encoding="utf-8") as f:
                existing_data = json.load(f)
            existing_versions = existing_data.get("app_versions", {})
        except (json.JSONDecodeError, KeyError):
            pass

    version_config: dict[str, object] = {
        "app_versions": existing_versions,
        "default": short_hash,
    }
    if dynamic_hash is not None:
        version_config["dynamic"] = dynamic_hash
    proj_resources_dir.mkdir(parents=True, exist_ok=True)
    with open(version_config_path, "w", encoding="utf-8") as f:
        json.dump(version_config, f, indent=2, ensure_ascii=False)
    print(f"\n✅ Version resource config: {version_config_path}  (default={short_hash})")


def create_ssh_client(host: str, port: int, user: str, key_file: str | None, pass_key: str | None) -> paramiko.SSHClient:
    """Tao va ket noi SSH client (giong upload_web.py)."""
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    connect_kwargs: dict = {
        "hostname": host,
        "port": port,
        "username": user,
        "timeout": 20,
        "allow_agent": True,
        "look_for_keys": False,
    }
    if key_file:
        connect_kwargs["key_filename"] = key_file
    if pass_key:
        connect_kwargs["passphrase"] = pass_key

    try:
        client.connect(**connect_kwargs)
    except Exception as e:
        raise RuntimeError(f"Khong the ket noi SSH toi {user}@{host}:{port}: {e}")
    return client


def ensure_remote_dirs_sftp(sftp: paramiko.SFTPClient, remote_dir: str) -> None:
    """Tao folder tren server neu chua co (recursive)."""
    if not remote_dir or remote_dir == "/":
        return
    current = "" if remote_dir.startswith("/") else "."
    for part in remote_dir.strip("/").split("/"):
        current = f"{current}/{part}" if current not in ("", ".") else (f"/{part}" if remote_dir.startswith("/") else part)
        try:
            sftp.stat(current)
        except FileNotFoundError:
            try:
                sftp.mkdir(current)
            except IOError:
                pass


def remote_listdir_recursive(sftp: paramiko.SFTPClient, remote_dir: str, root_prefix: str | None = None) -> set[str]:
    """
    Quet de quy tren server, tra ve set cac duong dan file tuong doi
    (rel so voi remote_dir goc). Neu remote_dir khong ton tai -> set rong.

    root_prefix: giu nguyen trong qua trinh de quy de tinh rel chinh xac
    so voi thu muc goc ban dau. Buoc dau tien tu dong set = remote_dir.
    """
    if root_prefix is None:
        root_prefix = remote_dir  # Lan dau: dung chinh remote_dir lam goc
    root_prefix = root_prefix.rstrip("/")

    results: set[str] = set()
    try:
        entries = sftp.listdir_attr(remote_dir)
    except FileNotFoundError:
        return results
    except IOError:
        return results

    base = remote_dir.rstrip("/")
    for entry in entries:
        name = entry.filename
        if name in (".", ".."):
            continue
        full = f"{base}/{name}"
        mode = entry.st_mode
        is_dir = False
        if mode is not None:
            is_dir = stat.S_ISDIR(mode)
        else:
            # Mot so server SFTP khong tra ve st_mode -> phai thử stat để biết có phải folder không
            try:
                is_dir = stat.S_ISDIR(sftp.stat(full).st_mode)
            except IOError:
                is_dir = False
        if is_dir:
            results |= remote_listdir_recursive(sftp, full, root_prefix)
        else:
            # QUAN TRONG: rel phai tinh so voi root_prefix (thu muc goc),
            # KHONG phai so voi base (thu muc hien tai).
            # Bug cu: dung base lam cho file o subfolder chi tra ve ten file,
            # khong co duong dan day du -> so sanh voi local sai -> upload lai.
            rel = full[len(root_prefix) + 1:]
            results.add(rel)
    return results


def upload_single_file(sftp: paramiko.SFTPClient, local_file: Path, remote_path: str) -> None:
    """Upload 1 file len server (khong kiem tra trung)."""
    ensure_remote_dirs_sftp(sftp, str(Path(remote_path).parent))
    t0 = time.time()
    sftp.put(str(local_file), remote_path)
    elapsed = time.time() - t0
    print(f"  📤 Upload: {Path(remote_path).name}  ({elapsed:.2f}s)")


def upload_new_files(sftp: paramiko.SFTPClient, local_root: Path, remote_root: str) -> tuple[int, int]:
    """
    Duyet de quy local_root, upload chi cac file CHUA co tren server
    (so sanh theo ten file tuong doi, vi file da duoc hash noi dung nen
    ten giong = noi dung giong = bo qua).
    Tra ve (so_file_upload, so_file_bo_qua).
    """
    remote_root = remote_root.rstrip("/")
    ensure_remote_dirs_sftp(sftp, remote_root)
    remote_files = remote_listdir_recursive(sftp, remote_root)

    uploaded = 0
    skipped = 0
    for local_file in sorted(local_root.rglob("*")):
        if not local_file.is_file():
            continue
        if local_file.name in (".DS_Store",):
            continue
        rel = str(local_file.relative_to(local_root)).replace("\\", "/")
        if rel in remote_files:
            skipped += 1
            continue
        remote_path = f"{remote_root}/{rel}"
        ensure_remote_dirs_sftp(sftp, str(Path(remote_path).parent))
        t0 = time.time()
        sftp.put(str(local_file), remote_path)
        elapsed = time.time() - t0
        print(f"  📤 Upload: {rel}  ({elapsed:.2f}s)")
        uploaded += 1
    return uploaded, skipped


def upload_resources_to_server(assets_dir: Path, proj_resources_dir: Path, server_ip: str,
                               server_port: int, server_user: str, server_path: str,
                               key_file: str | None, key_pass: str | None) -> None:
    """
    Upload len server:
      1. version_resource_config.json -> <server_path>/version_resource_config.json
      2. Toan bo proj_resources/assets/ -> <server_path>/assets/ (chi file moi)
    """
    print(f"\n{'=' * 60}\n🚀 Upload resources len server: {server_user}@{server_ip}:{server_port}\n{'=' * 60}")
    print(f"   Server path: {server_path}")

    client = create_ssh_client(server_ip, server_port, server_user, key_file, key_pass)
    try:
        sftp = client.open_sftp()
        try:
            # 1. Upload version_resource_config.json
            version_config_local = proj_resources_dir / "version_resource_config.json"
            if version_config_local.is_file():
                remote_version = f"{server_path.rstrip('/')}/version_resource_config.json"
                print(f"\n• Upload version_resource_config.json -> {remote_version}")
                upload_single_file(sftp, version_config_local, remote_version)
                print("  ✅ version_resource_config.json")
            else:
                print("\n⚠  Khong tim thay version_resource_config.json de upload.")

            # 2. Upload assets/ (chi file moi)
            print(f"\n• Upload assets/ -> {server_path.rstrip('/')}/assets/ (bo qua file trung ten)")
            uploaded, skipped = upload_new_files(sftp, assets_dir, f"{server_path.rstrip('/')}/assets")
            print(f"  ✅ Upload: {uploaded} file moi | Bo qua: {skipped} file da co")
        finally:
            sftp.close()
    finally:
        client.close()

    print(f"\n✅ Hoan tat upload resources len server.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Pack + copy + sinh bundle_resource_config.json + upload len server")
    parser.add_argument("--raw-assets", default="proj_resources/raw_assets", help="Thu muc raw_assets")
    parser.add_argument("--assets", default="proj_resources/assets", help="Thu muc assets output")
    parser.add_argument("--bundle", default=None, help="Chi xu ly 1 bundle cu the")
    parser.add_argument("--skip-pack", action="store_true", help="Bo qua buoc pack (chi copy + config)")
    parser.add_argument("--skip-upload", action="store_true", help="Bo qua buoc upload len server")
    parser.add_argument("--ip", default=None, help="IP hoac hostname server")
    parser.add_argument("--port", type=int, default=None, help="Port SSH")
    parser.add_argument("--user", default=None, help="User SSH")
    parser.add_argument("--server-path", default=None, help="Thu muc goc tren server")
    parser.add_argument("--key-file", default=None, help="Duong dan private key SSH")
    parser.add_argument("--key-pass", default=None, help="Passphrase private key SSH")
    parser.add_argument("--env", default=DEFAULT_DEPLOY_ENV, choices=['staging', 'prod', 'pre'], help=f"Preset server/deploy (mac dinh: {DEFAULT_DEPLOY_ENV})")
    parser.add_argument("--dev", type=int, default=None, choices=list(range(1, 11)),
                        help="Staging sub-env dev1..dev10 (CHI dung khi --env staging). "
                             "Khong truyen thi script hoi interactive "
                             "(Enter = staging GOC, KHONG devN — khong +/devN vao cuoi "
                             "server_path).")
    args = parser.parse_args()

    dev = resolve_staging_dev(args.dev, args.env)

    raw_assets = Path(args.raw_assets)
    assets_dir = Path(args.assets)

    if not raw_assets.is_dir():
        sys.exit(f"Khong tim thay thu muc raw_assets: {raw_assets}")

    if args.bundle:
        bundles = [raw_assets / args.bundle]
    else:
        bundles = sorted([p for p in raw_assets.iterdir() if p.is_dir() and not p.name.startswith(".")])

    # BUOC 0: Kiem tra file trung ten trong raw_assets (truoc khi lam bat cu viec gi khac)
    print(f"\n{'=' * 60}\n🔍 Kiem tra file trung ten trong raw_assets...\n{'=' * 60}")
    check_duplicate_filenames(raw_assets)
    print("   ✅ Khong co file trung ten.")

    preset = get_deploy_preset(args.env)

    # BUOC DAU TIEN: xoa toan bo folder assets cu de dam bao build sach
    # (tranh xu ly phan du, config hash cu, anh cu bi giu lai gay bug).
    print(f"\n{'=' * 60}\n🧹 Xoa folder assets cu: {assets_dir}\n{'=' * 60}")
    clean_dir(assets_dir)

    # Gom hash config vua tao cua tung bundle de truyen thang cho
    # build_global_config (khong doan hash bang cach quet thu muc).
    known_hashes: dict[str, str] = {}
    for bundle_raw in bundles:
        h = process_bundle(bundle_raw, bundle_raw.name, assets_dir, args.skip_pack)
        if h:
            known_hashes[bundle_raw.name] = h

    # Tong hop tat ca bundle thanh bundle_config.<hash>.json o goc assets/
    # va version_resource_config.json tai proj_resources/
    proj_resources_dir = Path(args.raw_assets).parent  # proj_resources/
    build_global_config(assets_dir, proj_resources_dir, known_hashes)

    # Upload len server (tru khi --skip-upload)
    if not args.skip_upload:
        ip = coalesce_str(args.ip, preset['server_ip'])
        port = args.port if args.port is not None else int(preset['server_port'])
        user = coalesce_str(args.user, preset['server_user'])
        # Staging: server_path + devN (vd /home/msservice/staging/commons/ + dev3).
        # Prod/pre: giữ nguyên preset.
        server_path = apply_staging_dev_path(
            coalesce_str(args.server_path, preset['server_path']), dev)
        key_file, key_pass = resolve_ssh_key(args.key_file, args.key_pass, preset)

        key_file_resolved = str(Path(key_file).expanduser().resolve()) if key_file else None
        if key_file_resolved and not Path(key_file_resolved).exists():
            sys.exit(f"Khong tim thay key file: {key_file_resolved}")

        print(f"\n===== DEPLOY PRESET: {args.env}" + (f" ({dev})" if dev else "") + " =====")
        print(f"Server: {user}@{ip}:{port}")
        print(f"Server path: {server_path}")
        print(f"SSH key: {key_file_resolved}")
        if dev:
            print(f"Resource URL base: rs_domain/{dev}/...")

        upload_resources_to_server(
            assets_dir=assets_dir,
            proj_resources_dir=proj_resources_dir,
            server_ip=ip,
            server_port=port,
            server_user=user,
            server_path=server_path,
            key_file=key_file_resolved,
            key_pass=key_pass,
        )

    print("\n✅ Hoan tat upload resources cho tat ca bundle.")


if __name__ == "__main__":
    main()
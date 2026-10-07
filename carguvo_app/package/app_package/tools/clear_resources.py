#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/clear_resources.py - Dọn file tài nguyên CŨ trên server (pre/prod).
====================================================================
Mục đích: folder `assets/` trên server tích luỹ mãi file của mọi lần release
(mỗi release sinh hash mới cho từng bundle) -> phình rất nhanh. Tool này xoá
hết file không còn bản nào cần dùng.

CÁCH XÁC ĐỊNH FILE CẦN GIỮ (keep set):
  1. Git tags: lấy N tag `v<ver>-res.<hash>` gần nhất (mặc định 5, --keep-tags).
     Mỗi tag = 1 resource version prod đã phát hành.
  2. version_resource_config.json TRÊN SERVER:
       - "default"       -> resource version app không khớp version nào dùng
       - "dynamic"       -> bundle dynamic (không nằm trong bundle_config gốc)
       - "app_versions"  -> hash của từng app version cũ vẫn đang chạy ngoài
                            thị trường (KHÔNG xoá, tránh app cũ vỡ ảnh)
  3. Từ mỗi hash giữ lại, dò ngược:
       assets/bundle_config.<hash>.json          -> {bundle: bundle_hash}
       assets/<bundle>/bundle_resource_config.<bundle_hash>.json
         -> svg / atlases / images / others
       => ra danh sách CHÍNH XÁC từng file (packs/, images/, others/) cần giữ.
  4. Duyệt toàn bộ assets/ trên server, file nào KHÔNG có trong keep set thì xoá.

AN TOÀN:
  - MẶC ĐỊNH CHẠY DRY-RUN (chỉ in ra sẽ xoá gì). Muốn xoá thật phải thêm --apply.
  - Chỉ đụng trong <server_path>/assets/ — không touch file nào khác.
  - Không xoá version_resource_config.json.

DÙNG:
  python3 tools/clear_resources.py --env pre                 # xem trước
  python3 tools/clear_resources.py --env pre --apply -y      # xoá thật
  python3 tools/clear_resources.py --env prod --keep-tags 10 --apply -y
  python3 tools/clear_resources.py --env prod --no-keep-app-versions --apply -y
  python3 tools/clear_resources.py --env pre --log > log.txt # in HẾT file giữ/xoá
YÊU CẦU: .env có SSH_KEY_FILE (xem .env.example).
"""
from __future__ import annotations
import argparse, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dotenv_local import load_dotenv  # noqa: E402

load_dotenv()

from upload_resources import DEPLOY_PRESETS, create_ssh_client  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parent.parent
# Tag prod: v<ver>-res.<hash>[-dyn.<dyn_hash>] —dyn là hash bundle dynamic.
TAGVER_RE = re.compile(r"^v(\d+)\.(\d+)\.(\d+)\+(\d+)-res\.([0-9a-f]+)(?:-dyn\.([0-9a-f]+))?$")


def run_git(*args: str) -> str:
    import subprocess
    p = subprocess.run(["git", *args], cwd=str(REPO_ROOT),
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.stdout.strip() if p.returncode == 0 else ""


def fetch_tags() -> None:
    """Đồng bộ tag từ origin — NON-INTERACTIVE, tối đa 20s.

    Giữ credential.helper (osxkeychain) — keychain đã có login hợp lệ thì
    fetch không hỏi gì. GIT_TERMINAL_PROMPT=0 + GCM_INTERACTIVE=never: nếu
    KHÔNG có credential thì git FAIL NGAY thay vì hỏi tay/treo dialog.
    (Trước đây có `-c credential.helper=` — tắt keychain, gây hỏi pass/treo
    — đã bỏ.) Lỗi chỉ cảnh báo, không chặn tool.
    """
    import subprocess, os as _os
    env = {**_os.environ, "GIT_TERMINAL_PROMPT": "0", "GCM_INTERACTIVE": "never"}
    try:
        p = subprocess.run(
            ["git", "fetch", "--tags", "--prune", "origin"],
            cwd=str(REPO_ROOT), env=env, timeout=20,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if p.returncode != 0:
            print("   ⚠️ `git fetch --tags` thất bại (mạng/auth) — dùng tag local hiện có.")
        else:
            print("   ✅ Đã kết nối GitHub — tags đã đồng bộ.")
    except subprocess.TimeoutExpired:
        print("   ⚠️ `git fetch --tags` quá 20s (mạng?) — dùng tag local hiện có.")
    except Exception as e:
        print(f"   ⚠️ Không fetch được tags ({e}) — dùng tag local hiện có.")


def tag_keep_hashes(n: int) -> list[tuple[str, str]]:
    """[(tên nguồn, hash)] của N tag prod gần nhất, mới -> cũ.
    Mỗi tag cho 2 nguồn: res hash + (nếu có) dyn hash bundle dynamic."""
    found: list[tuple[tuple[int, int, int, int], str, str, str]] = []
    for t in run_git("tag", "--list", "v*").splitlines():
        m = TAGVER_RE.match(t.strip())
        if m:
            ver_key = tuple(int(m.group(i)) for i in range(1, 5))
            found.append((ver_key, t.strip(), m.group(5), m.group(6) or ""))
    found.sort(key=lambda x: x[0], reverse=True)
    out: list[tuple[str, str]] = []
    for _k, t, h, d in found[:n]:
        out.append((t, h))
        if d:
            out.append((f"{t} (dyn)", d))
    return out


def read_remote_json(sftp, remote_path: str) -> dict | None:
    """Đọc JSON trên server. None nếu không có / không parse được."""
    try:
        with sftp.open(remote_path, "r") as f:
            return json.loads(f.read().decode("utf-8"))
    except Exception:
        return None


def remote_walk(sftp, root: str) -> list[tuple[str, int]]:
    """[(remote_path, size)] của mọi FILE dưới root (đệ quy). [] nếu root không có."""
    import stat as st
    out: list[tuple[str, int]] = []
    stack = [root.rstrip("/")]
    while stack:
        cur = stack.pop()
        try:
            entries = sftp.listdir_attr(cur)
        except IOError:
            continue
        except OSError:
            continue
        for e in entries:
            p = f"{cur}/{e.filename}"
            if st.S_ISDIR(e.st_mode):
                stack.append(p)
            else:
                out.append((p, e.st_size or 0))
    return out


def keep_bundle_files(sftp, root: str, bundle: str, bh: str) -> set[str]:
    """File cần giữ của 1 bundle: config + svg + atlases + images + others."""
    keep: set[str] = set()
    bdir = f"{root}/{bundle}"
    cfg_path = f"{bdir}/bundle_resource_config.{bh}.json"
    cfg = read_remote_json(sftp, cfg_path)
    if cfg is None:
        print(f"    ⚠️ Thiếu {cfg_path} — KHÔNG xoá gì trong {bundle}/ (an toàn).")
        for p, _s in remote_walk(sftp, bdir):
            keep.add(p)
        return keep
    keep.add(cfg_path)

    svg = cfg.get("svg")
    if isinstance(svg, str) and svg:
        keep.add(f"{bdir}/packs/{svg}")
    for atlas in cfg.get("atlases", []):
        # 1 stem atlas dùng chung cho cặp .webp + .json
        keep.add(f"{bdir}/packs/{atlas}.webp")
        keep.add(f"{bdir}/packs/{atlas}.json")
    for rel in cfg.get("images", []):
        keep.add(f"{bdir}/images/{rel}")
    for rel in cfg.get("others", []):
        keep.add(f"{bdir}/others/{rel}")
    return keep


def keep_files_for_hash(sftp, assets_root: str, h: str) -> tuple[set[str], str, list[str]]:
    """Dò 1 resource hash -> (files cần giữ, mô tả nguồn, cảnh báo)."""
    root = assets_root.rstrip("/")
    warns: list[str] = []

    gpath = f"{root}/bundle_config.{h}.json"
    gdata = read_remote_json(sftp, gpath)
    if gdata is not None:
        keep = {gpath}
        n = 0
        for bundle, bh in gdata.items():
            if bundle == "created_at" or not isinstance(bh, str):
                continue
            keep |= keep_bundle_files(sftp, root, bundle, bh)
            n += 1
        return keep, f"{h}: bundle_config ({n} bundle)", warns

    dcfg = f"{root}/dynamic/bundle_resource_config.{h}.json"
    if read_remote_json(sftp, dcfg) is not None:
        keep = keep_bundle_files(sftp, root, "dynamic", h)
        return keep, f"{h}: dynamic bundle", warns

    warns.append(f"hash {h} không tìm thấy config trên server (tag cũ? chưa deploy?)")
    return set(), f"{h}: BỎ QUA", warns

def collect_keep_files(sftp, assets_root: str, tags: list[tuple[str, str]],
                       srv_hashes: list[tuple[str, str]],
                       remote_files: list[tuple[str, int]],
                       log_all: bool = False) -> set[str]:
    """Gom file cần giữ từ (tag, hash) + (hash, nguồn trên server).

    Với hash KHÔNG dò được config: giữ mọi file có tên chứa hash đó (lưới an
    toàn — thà giữ thừa còn hơn xoá nhầm file của bản app cũ đang chạy).
    """
    print("\n--- 3) Dò ngược hash -> file cần giữ ---")
    all_h: list[tuple[str, str]] = [(h, f"tag {t}") for t, h in tags] + srv_hashes
    keep: set[str] = set()
    seen: set[str] = set()
    for h, src in all_h:
        if h in seen:
            continue
        seen.add(h)
        files, desc, warns = keep_files_for_hash(sftp, assets_root, h)
        if not files:
            hits = {p for p, _s in remote_files if h in p}
            if hits:
                files = hits
                desc = f"{h}: KHÔNG có config — giữ {len(hits)} file theo tên chứa hash"
        keep |= files
        print(f"   [{src}] {desc}  ({len(files)} file)")
        if log_all:
            prefix = assets_root.rstrip("/") + "/"
            for p in sorted(files):
                print(f"      GIỮ {p.replace(prefix, 'assets/')}")
        for w in warns:
            print(f"      ⚠️ {w}")
    print(f"\n   Tổng file cần giữ: {len(keep)}")
    return keep


def scan_and_delete(sftp, server_path: str, assets_root: str, keep: set[str],
                    remote_files: list[tuple[str, int]],
                    apply: bool, assume_yes: bool,
                    log_all: bool = False) -> tuple[int, int]:
    """Quét assets/ trên server, xoá file không nằm trong keep set.
    Trả (số file đã xoá, tổng byte giải phóng)."""
    print("\n--- 4) Quét assets/ trên server ---")
    print(f"   Tổng file trên server: {len(remote_files)}")
    to_delete = sorted((p, s) for p, s in remote_files if p not in keep)
    total = sum(s for _p, s in to_delete)
    print(f"   File cần xoá: {len(to_delete)}  (~{total / 1_048_576:.1f} MB)")

    if not to_delete:
        print("\n✅ Không có gì để xoá — server đã sạch.")
        return 0, 0

    if log_all or len(to_delete) <= 40:
        show = to_delete
    else:
        show = to_delete[:25] + [("...", -1)] + to_delete[-15:]
    for p, s in show:
        if s < 0:
            print("      ...")
            continue
        print(f"      - {p.replace(server_path + '/', '')}  ({s / 1024:.0f} KB)")

    if not apply:
        print("\n DRY-RUN — chưa xoá gì. Thêm --apply để xoá thật.")
        return 0, 0

    if not assume_yes:
        ans = input(f"\nXoá {len(to_delete)} file? [y/N]: ").strip().lower()
        if ans != "y":
            sys.exit("Đã hủy — không xoá gì.")

    print("\n--- Xoá ---")
    done = 0
    freed = 0
    for i, (p, s) in enumerate(to_delete, 1):
        try:
            sftp.remove(p)
            done += 1
            freed += s
        except (IOError, OSError) as e:
            print(f"      ⚠️ Không xoá được {p}: {e}")
        if i % 50 == 0:
            print(f"      ... {i}/{len(to_delete)}")
    print(f"\n✅ Đã xoá {done}/{len(to_delete)} file (~{freed / 1_048_576:.1f} MB)")
    return done, freed


def main() -> None:
    ap = argparse.ArgumentParser(description="Dọn resource cũ trên server (pre/prod)")
    ap.add_argument("--env", required=True, choices=["staging", "pre", "prod"],
                    help="Preset server (pre = <prod>/commons/pre)")
    ap.add_argument("--keep-tags", type=int, default=5,
                    help="Số tag v<ver>-res.<hash> gần nhất cần giữ (mặc định 5)")
    ap.add_argument("--no-keep-app-versions", action="store_true",
                    help="KHÔNG giữ hash trong app_versions (mặc định giữ — app cũ còn chạy)")
    ap.add_argument("--apply", action="store_true",
                    help="Xoá THẬT. Không có cờ này = chỉ in ra sẽ xoá gì (dry-run)")
    ap.add_argument("--log", action="store_true",
                    help="In RA HẾT từng file cần giữ / cần xoá (mặc định chỉ tóm tắt)")
    ap.add_argument("--no-fetch", action="store_true",
                    help="Không gọi git fetch --tags (dùng tag local; tránh chờ mạng/auth)")
    ap.add_argument("--ip", default=None)
    ap.add_argument("--port", type=int, default=None)
    ap.add_argument("--user", default=None)
    ap.add_argument("--server-path", default=None)
    ap.add_argument("--key-file", default=None)
    ap.add_argument("--key-pass", default=None)
    ap.add_argument("-y", "--yes", action="store_true")
    a = ap.parse_args()

    from setup_github_key import ensure_git_auth  # noqa: E402
    ensure_git_auth("clear_resources.py")  # chưa auth GitHub -> setup + exit 2

    preset = DEPLOY_PRESETS.get(a.env)
    if preset is None:
        sys.exit(f"[LỖI] Không có preset cho env={a.env}")
    ip = (a.ip or preset["server_ip"]).strip()
    port = a.port if a.port is not None else int(preset["server_port"])
    user = (a.user or preset["server_user"]).strip()
    server_path = (a.server_path or preset["server_path"]).rstrip("/")
    import os
    key_file = (a.key_file or os.getenv("SSH_KEY_FILE", "") or preset.get("ssh_key_file", "")).strip()
    key_pass = a.key_pass if a.key_pass is not None else os.getenv("SSH_KEY_PASS", preset.get("ssh_key_pass", ""))
    if not key_file:
        sys.exit("[LỖI] Thiếu SSH key. Đặt SSH_KEY_FILE trong .env (xem .env.example).")
    key_file = str(Path(key_file).expanduser().resolve())
    if not Path(key_file).exists():
        sys.exit(f"[LỖI] SSH key không tồn tại: {key_file}")

    print("=" * 64)
    print(f" DỌN RESOURCE — env={a.env}  ({'XOÁ THẬT' if a.apply else 'DRY-RUN'})")
    print(f"   Server : {user}@{ip}:{port}")
    print(f"   Assets : {server_path}/assets/")
    print(f"   Key    : {key_file}")
    print("=" * 64)

    # ── 1. Hash cần giữ: từ git tags ──
    print(f"\n--- 1) Git tags (giữ {a.keep_tags} tag gần nhất dạng v<ver>-res.<hash>) ---")
    tags = tag_keep_hashes(a.keep_tags)
    if len(tags) < a.keep_tags and not a.no_fetch:
        # Chỉ khi thiếu tag mới chạm mạng (fetch có thể chậm/treo vì auth).
        print(f"   Local chỉ có {len(tags)}/{a.keep_tags} tag — thử fetch từ origin...")
        fetch_tags()
        tags = tag_keep_hashes(a.keep_tags)
    if not tags:
        print("   ⚠️ Không có tag nào dạng v<ver>-res.<hash> — chỉ giữ theo server config.")
    for t, h in tags:
        print(f"   {t}  ->  {h}")

    client = create_ssh_client(ip, port, user, key_file, key_pass or None)
    print("\n✅ Kết nối SSH OK.")
    freed = 0
    deleted = 0
    try:
        sftp = client.open_sftp()
        try:
            assets_root = f"{server_path}/assets"
            vcfg_path = f"{server_path}/version_resource_config.json"
            vcfg = read_remote_json(sftp, vcfg_path)
            print(f"\n--- 2) {vcfg_path} ---")
            srv_hashes: list[tuple[str, str]] = []
            if not vcfg:
                print("   ⚠️ Không đọc được — bỏ qua phần này.")
            else:
                d = str(vcfg.get("default", "")).strip()
                dy = str(vcfg.get("dynamic", "")).strip()
                if d:
                    srv_hashes.append((d, "default (app không khớp version)"))
                    print(f"   default       -> {d}")
                if dy:
                    srv_hashes.append((dy, "dynamic bundle"))
                    print(f"   dynamic       -> {dy}")
                apps = vcfg.get("app_versions", {}) or {}
                if apps and a.no_keep_app_versions:
                    print(f"   app_versions  -> BỎ QUA ({len(apps)} bản, theo --no-keep-app-versions)")
                for ver, h in apps.items():
                    if a.no_keep_app_versions:
                        continue
                    if isinstance(h, str) and h.strip():
                        srv_hashes.append((h.strip(), f"app_versions[{ver}]"))
                        print(f"   app_versions[{ver}] -> {h}")
            # Quét 1 lần duy nhất toàn bộ assets/ (dùng cho cả bước 3 và 4).
            remote_files = remote_walk(sftp, assets_root)
            keep = collect_keep_files(sftp, assets_root, tags, srv_hashes, remote_files, a.log)
            removed = scan_and_delete(sftp, server_path, assets_root, keep,
                                      remote_files, a.apply, a.yes, a.log)
            deleted, freed = removed
        finally:
            sftp.close()
    finally:
        client.close()

    print("\n" + "=" * 64)
    if a.apply:
        print(f"XONG: xoá {deleted} file, giải phóng ~{freed / 1_048_576:.1f} MB ({a.env})")
    else:
        print(f"DRY-RUN xong ({a.env}). Thêm --apply để xoá thật.")
    print("=" * 64)
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[!] Ctrl-C — dừng.")
        sys.exit(130)
    except Exception as e:
        print(f"\n[LỖI] {e}", file=sys.stderr)
        sys.exit(1)

#!/usr/bin/env python3
"""
Shorebird preflight cho carguvo — kiểm tra TRƯỚC khi `shorebird release` /
`shorebird patch` để không bao giờ lọt plugin native hay cấu hình debug.

Vì sao cần: Shorebird patch chỉ thay được Dart. Plugin native (Kotlin/Swift/.so)
phải nằm sẵn trong binary release. Thiếu → MissingPluginException /
`channel-error` lúc runtime (đã dính: rive_native, url_launcher_android).

Lệnh:
  fix           TỰ cấu hình native trước release/patch: ghim exact mọi plugin native
                (thêm plugin thiếu như game_engine/sqflite), sửa cờ debug, quyền/queries
                Android, LSApplicationQueriesSchemes/CFBundleURLTypes iOS → pub get → check.
                - Version CHƯA release → chế độ RELEASE: ghim theo pubspec.lock.
                - Version ĐÃ release (có manifest) → chế độ PATCH: ghim theo đúng binary;
                  có plugin native mới → dừng, báo phải release mới.
  check         Trước `shorebird release`. Chạy trên cây ĐẦY ĐỦ (có app_package
                trong pubspec) để script biết app_package cần những gì.
  snapshot      Ngay SAU khi `shorebird release` thành công. Chạy trên đúng cây
                đã dùng để release. Ghi release_manifests/<version>.json = danh
                sách plugin native + version thực sự nằm trong binary.
  verify-patch  Trước `shorebird patch`. So cây hiện tại với manifest của release
                → báo plugin native mới / đổi version / sửa code native.

Ví dụ:
  python3 scripts/shorebird_preflight.py fix --dry-run            # xem sẽ sửa gì
  python3 scripts/shorebird_preflight.py fix                      # sửa + pub get + check
  python3 scripts/shorebird_preflight.py check                      # android + ios
  python3 scripts/shorebird_preflight.py check --platform ios
  python3 scripts/shorebird_preflight.py check --patch-packages app_package --strict
  python3 scripts/shorebird_preflight.py snapshot --platform android --flags="--no-tree-shake-icons"
  python3 scripts/shorebird_preflight.py verify-patch --flags="--no-tree-shake-icons"

Lưu ý: giá trị --flags bắt đầu bằng `--` nên phải viết dạng `--flags="..."` (có dấu =).

Exit code: 0 = OK, 1 = có FAIL (hoặc có WARN khi dùng --strict), 2 = lỗi script.
Chỉ dùng thư viện chuẩn của Python 3.8+.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from collections import deque
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parent.parent
MANIFEST_DIR = ROOT / "release_manifests"

# Package chỉ được đưa vào qua PATCH (không có mặt khi build release).
# Mọi plugin native mà các package này cần phải có sẵn trong release.
DEFAULT_PATCH_PACKAGES = ["app_package"]

PLATFORMS = ["android", "ios"]

# Plugin path phải lấy từ nơi khác thay vì bản copy trong repo.
# `fix` sẽ: trỏ dependency tới path này + tự thêm dependency_overrides cho nó và cho
# mọi path-dependency của nó bị trùng tên với package đang có trong cây (vd. app_env).
PATH_OVERRIDES = {
    "game_engine": "/Users/admin/Documents/projects/app_package/packages/game_engine",
}

# ---------------------------------------------------------------------------
# Luật riêng của project: (file, regex, level, message[, auto-fix replacement]).
# Có phần tử thứ 5 → lệnh `fix` tự thay regex bằng chuỗi đó.
# Thêm dòng mới ở đây khi có cờ debug / cấu hình phải đổi trước release.
# ---------------------------------------------------------------------------
SOURCE_RULES = [
    (
        "package/app_package/lib/features/home/domain/ncc_sportbook.dart",
        r"kNccLogFullUrl\s*=\s*true",
        "FAIL",
        "kNccLogFullUrl = true → in nguyên URL kèm token ra logcat. Đổi thành false.",
        "kNccLogFullUrl = false",
    ),
    (
        "package/app_package/packages/app_env/lib/app_env.dart",
        r"_raw\s*=\s*'(?!prod')[^']*'",
        "FAIL",
        "AppEnv._raw không phải 'prod'.",
        "_raw = 'prod'",
    ),
    (
        "package/unlock_shorebird_kit/lib/flow/unlock_flow_config.dart",
        r"_staging\.json",
        "WARN",
        "UnlockFlowConfig.apiDomainConfigUrl đang trỏ STAGING (s88_staging.json).",
    ),
]

# Đánh dấu tự do: comment `// RELEASE_BLOCKER: ...` ở bất kỳ file .dart/.kt/.swift
# nào → chặn release cho tới khi xoá.
BLOCKER_MARKER = "RELEASE_BLOCKER"
BLOCKER_SCAN_DIRS = ["lib", "package", "android/app/src", "ios/Runner"]
BLOCKER_EXTS = {".dart", ".kt", ".java", ".swift", ".m", ".yaml", ".plist"}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
_USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
_COLORS = {"OK": "32", "WARN": "33", "FAIL": "31", "INFO": "36"}


def _c(level: str, text: str) -> str:
    if not _USE_COLOR:
        return text
    return f"\033[{_COLORS.get(level, '0')}m{text}\033[0m"


class Report:
    def __init__(self) -> None:
        self.counts = {"OK": 0, "WARN": 0, "FAIL": 0}

    def section(self, title: str) -> None:
        print(f"\n== {title}")

    def add(self, level: str, msg: str, detail: list[str] | None = None) -> None:
        if level in self.counts:
            self.counts[level] += 1
        print(f"  {_c(level, f'[{level}]'):<6} {msg}")
        for line in detail or []:
            print(f"         {line}")

    def finish(self, strict: bool) -> int:
        ok, warn, fail = self.counts["OK"], self.counts["WARN"], self.counts["FAIL"]
        print(f"\n== Tổng: {ok} OK, {warn} WARN, {fail} FAIL")
        if fail or (strict and warn):
            print(_c("FAIL", "✗ CHƯA được release/patch. Sửa các mục FAIL ở trên trước."))
            return 1
        if warn:
            print(_c("WARN", "✓ Không có FAIL. Đọc kỹ các WARN trước khi chạy tiếp."))
        else:
            print(_c("OK", "✓ Sẵn sàng."))
        return 0


# ---------------------------------------------------------------------------
# Mini YAML (đủ cho pubspec.yaml / pubspec.lock — không cần PyYAML)
# ---------------------------------------------------------------------------
def _strip_comment(line: str) -> str:
    out, quote = [], None
    for i, ch in enumerate(line):
        if quote:
            if ch == quote:
                quote = None
        elif ch in ("'", '"'):
            quote = ch
        elif ch == "#" and (i == 0 or line[i - 1] in " \t"):
            break
        out.append(ch)
    return "".join(out).rstrip()


def _unquote(v: str) -> str:
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "'\"":
        return v[1:-1]
    return v


def _indent(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def _top_level_block(text: str, key: str) -> list[str]:
    """Các dòng con (đã bỏ comment) của khoá top-level `key:`."""
    lines, inside = [], False
    for raw in text.splitlines():
        line = _strip_comment(raw)
        if not line.strip():
            continue
        if _indent(line) == 0:
            inside = line.split(":", 1)[0].strip() == key
            continue
        if inside:
            lines.append(line)
    return lines


def parse_dep_block(text: str, key: str = "dependencies") -> dict[str, dict]:
    """name -> {'raw': str|None, 'path':..., 'sdk':..., 'version':..., 'git':bool}"""
    block = _top_level_block(text, key)
    if not block:
        return {}
    base = min(_indent(l) for l in block)
    deps: dict[str, dict] = {}
    cur = None
    for line in block:
        ind = _indent(line)
        body = line.strip()
        if ind == base:
            name, _, val = body.partition(":")
            cur = name.strip()
            val = _unquote(val)
            deps[cur] = {"raw": val or None}
        elif cur and ":" in body:
            k, _, v = body.partition(":")
            k = k.strip()
            if k in ("path", "sdk", "version"):
                deps[cur][k] = _unquote(v)
            elif k == "git":
                deps[cur]["git"] = True
    return deps


def parse_flutter_assets(text: str) -> list[str]:
    """Trả về các khoá assets/fonts có khai báo trong section `flutter:`."""
    found = []
    block = _top_level_block(text, "flutter")
    if not block:
        return found
    base = min(_indent(l) for l in block)
    for line in block:
        if _indent(line) == base:
            k = line.strip().split(":", 1)[0]
            if k in ("assets", "fonts"):
                found.append(k)
    return found


def parse_version(text: str) -> str | None:
    m = re.search(r"^version:\s*(\S+)", text, re.M)
    return _unquote(m.group(1)) if m else None


def parse_lock(path: Path) -> dict[str, dict]:
    pkgs: dict[str, dict] = {}
    cur = None
    in_packages = False
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = _strip_comment(raw)
        if not line.strip():
            continue
        ind = _indent(line)
        body = line.strip()
        if ind == 0:
            in_packages = body.startswith("packages:")
            continue
        if not in_packages:
            continue
        if ind == 2 and body.endswith(":"):
            cur = body[:-1].strip()
            pkgs[cur] = {}
        elif cur and ind == 4 and ":" in body:
            k, _, v = body.partition(":")
            if k.strip() in ("dependency", "source", "version"):
                pkgs[cur][k.strip()] = _unquote(v)
        elif cur and ind == 6 and body.startswith("path:"):
            pkgs[cur]["path"] = _unquote(body.split(":", 1)[1])
    return pkgs


# ---------------------------------------------------------------------------
# Project model
# ---------------------------------------------------------------------------
class Project:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.pubspec_path = root / "pubspec.yaml"
        self.lock_path = root / "pubspec.lock"
        self.plugins_path = root / ".flutter-plugins-dependencies"
        self.pkgcfg_path = root / ".dart_tool" / "package_config.json"
        for p in (self.pubspec_path, self.lock_path, self.plugins_path, self.pkgcfg_path):
            if not p.exists():
                raise SystemExit(
                    f"Thiếu {p.relative_to(root)} — chạy `flutter pub get` ở thư mục gốc trước."
                )
        self.pubspec_text = self.pubspec_path.read_text(encoding="utf-8")
        self.name = re.search(r"^name:\s*(\S+)", self.pubspec_text, re.M).group(1)
        self.version = parse_version(self.pubspec_text)
        self.root_deps = parse_dep_block(self.pubspec_text, "dependencies")
        self.lock = parse_lock(self.lock_path)
        self.package_dirs = self._load_package_dirs()
        self.plugins = self._load_plugins()
        self._graph: dict[str, list[str]] | None = None
        self.graph_notes: list[str] = []

    # -- packages / plugins --------------------------------------------------
    def _load_package_dirs(self) -> dict[str, Path]:
        cfg = json.loads(self.pkgcfg_path.read_text(encoding="utf-8"))
        base = self.pkgcfg_path.parent
        dirs = {}
        for p in cfg.get("packages", []):
            uri = p["rootUri"]
            if uri.startswith("file:"):
                d = Path(unquote(urlparse(uri).path))
            else:
                d = (base / uri).resolve()
            dirs[p["name"]] = d
        return dirs

    def _load_plugins(self) -> dict[str, dict[str, dict]]:
        data = json.loads(self.plugins_path.read_text(encoding="utf-8"))
        out: dict[str, dict[str, dict]] = {}
        for plat in PLATFORMS:
            out[plat] = {}
            for p in data.get("plugins", {}).get(plat, []):
                if p.get("dev_dependency"):
                    continue
                if p.get("native_build") is False:
                    continue  # plugin Dart-only trên nền tảng này (vd. FFI-less shim)
                out[plat][p["name"]] = p
        return out

    def version_of(self, pkg: str) -> str:
        info = self.lock.get(pkg, {})
        if info.get("source") == "path":
            return f"path:{info.get('path', '?')}"
        return info.get("version", "?")

    def is_path_pkg(self, pkg: str) -> bool:
        return self.lock.get(pkg, {}).get("source") == "path"

    # -- dependency graph ------------------------------------------------------
    def graph(self) -> dict[str, list[str]]:
        if self._graph is None:
            self._graph = self._graph_from_pubspecs()
            if self._graph is None:
                self._graph = self._graph_from_pub_deps()
        return self._graph

    def _graph_from_pubspecs(self) -> dict[str, list[str]] | None:
        g: dict[str, list[str]] = {}
        missing = []
        for name, d in self.package_dirs.items():
            if name == self.name:
                g[name] = list(self.root_deps.keys())
                continue
            ps = d / "pubspec.yaml"
            if not ps.exists():
                missing.append(name)
                continue
            g[name] = list(parse_dep_block(ps.read_text(encoding="utf-8")).keys())
        if missing and os.environ.get("PREFLIGHT_ALLOW_PARTIAL_GRAPH") == "1":
            self.graph_notes.append(f"[test] {len(missing)} pubspec không đọc được → coi là lá.")
            for name in missing:
                g[name] = []
            return g
        if missing:
            self.graph_notes.append(
                f"Không đọc được pubspec của {len(missing)} package (vd. {missing[:3]}) → dùng `pub deps`."
            )
            return None
        return g

    def _graph_from_pub_deps(self) -> dict[str, list[str]]:
        cmd = _flutter_cmd(self.root) + ["pub", "deps", "--json"]
        try:
            res = subprocess.run(cmd, cwd=self.root, capture_output=True, text=True, timeout=300)
        except (OSError, subprocess.TimeoutExpired) as e:
            raise SystemExit(f"Không chạy được {' '.join(cmd)}: {e}")
        out = res.stdout
        start = out.find("{")
        if res.returncode != 0 or start < 0:
            raise SystemExit(f"`{' '.join(cmd)}` lỗi:\n{res.stderr or out}")
        data = json.loads(out[start:])
        g = {}
        for p in data.get("packages", []):
            if p.get("kind") == "root":
                g[p["name"]] = list(p.get("directDependencies") or self.root_deps.keys())
            else:
                g[p["name"]] = list(p.get("dependencies", []))
        self.graph_notes.append("Đồ thị dependency lấy từ `pub deps --json`.")
        return g

    def closure(self, starts, exclude=frozenset()) -> set[str]:
        g = self.graph()
        seen, q = set(), deque(s for s in starts if s not in exclude)
        while q:
            n = q.popleft()
            if n in seen or n in exclude:
                continue
            seen.add(n)
            q.extend(d for d in g.get(n, []) if d not in seen and d not in exclude)
        return seen


def _flutter_cmd(root: Path) -> list[str]:
    if shutil.which("fvm") and ((root / ".fvmrc").exists() or (root / ".fvm").exists()):
        return ["fvm", "flutter"]
    return ["flutter"]


_NATIVE_SUBDIRS = {"android": ("android",), "ios": ("ios", "darwin")}


def _hash_native_dir(pkg_dir: Path, plat: str) -> str | None:
    """Hash source native của 1 plugin path cho 1 nền tảng."""
    skip = {"build", ".gradle", ".cxx", ".idea", "Pods", ".dart_tool"}
    h = hashlib.sha256()
    found = False
    for sub in _NATIVE_SUBDIRS[plat]:
        d = pkg_dir / sub
        if not d.is_dir():
            continue
        for p in sorted(d.rglob("*")):
            if not p.is_file() or any(part in skip for part in p.relative_to(pkg_dir).parts):
                continue
            found = True
            h.update(str(p.relative_to(pkg_dir)).encode())
            h.update(p.read_bytes())
    return h.hexdigest()[:16] if found else None


def _rel(p: Path) -> str:
    try:
        return os.path.relpath(p, ROOT)
    except ValueError:
        return str(p)


def _suggest_line(proj: Project, pkg: str) -> str:
    if proj.is_path_pkg(pkg):
        return f"  {pkg}:\n    path: {PATH_OVERRIDES.get(pkg) or _rel(proj.package_dirs.get(pkg, Path('?')))}"
    return f"  {pkg}: {proj.version_of(pkg)}"


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------
def freshness_issues(proj: Project) -> list[str]:
    """So NỘI DUNG pubspec.yaml ↔ pubspec.lock ↔ .flutter-plugins-dependencies ↔ package_config.

    Không so mtime: Flutter/pub chỉ ghi lại file khi nội dung đổi, nên mtime lệch là bình thường.
    """
    issues = []
    for n, d in proj.root_deps.items():
        if d.get("sdk"):
            continue
        if n not in proj.lock:
            issues.append(f"`{n}` có trong pubspec.yaml nhưng chưa có trong pubspec.lock")
            continue
        want = _unquote(d.get("raw") or d.get("version") or "")
        if re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][\w.+-]*)?", want or ""):
            got = proj.lock[n].get("version")
            if got and got != want:
                issues.append(f"`{n}` ghim {want} nhưng lock đang {got}")
    for n, d in parse_dep_block(proj.pubspec_text, "dev_dependencies").items():
        if not d.get("sdk") and n not in proj.lock:
            issues.append(f"dev `{n}` chưa có trong pubspec.lock")
    for plat in PLATFORMS:
        for n, info in proj.plugins[plat].items():
            if n not in proj.lock:
                issues.append(f"plugin `{n}` ({plat}) không còn trong pubspec.lock")
                continue
            m = re.search(rf"/{re.escape(n)}-([^/]+)/?$", info.get("path", "").rstrip("/") + "/")
            locked = proj.lock[n].get("version")
            if m and proj.lock[n].get("source") == "hosted" and m.group(1) != locked:
                issues.append(f"plugin `{n}`: .flutter-plugins-dependencies {m.group(1)} ≠ lock {locked}")
    missing_cfg = [n for n in proj.lock if n not in proj.package_dirs]
    if missing_cfg:
        issues.append(f".dart_tool/package_config.json thiếu {len(missing_cfg)} package (vd. {missing_cfg[:3]})")
    return issues


def load_fresh_project(auto_pub_get: bool = True, offline: bool = False) -> tuple[Project, list[str]]:
    """Nạp Project; nếu kết quả pub get lệch / thiếu → tự chạy `flutter pub get` rồi nạp lại."""
    notes: list[str] = []
    try:
        proj = Project(ROOT)
        issues = freshness_issues(proj)
    except SystemExit as e:  # thiếu pubspec.lock / package_config / plugins file
        proj, issues = None, [str(e.code)]
    if not issues:
        return proj, notes
    if not auto_pub_get:
        if proj is None:
            raise SystemExit(issues[0])
        proj.stale_issues = issues
        return proj, notes
    print(_c("INFO", "Kết quả pub get chưa khớp pubspec.yaml → tự chạy `flutter pub get`:"))
    for i in issues[:8]:
        print(f"         - {i}")
    ok, out = _pub_get(ROOT, offline=offline)
    if not ok:
        print(_c("FAIL", "  `flutter pub get` lỗi:"))
        print("  " + out.strip().replace("\n", "\n  "))
        if _NETWORK_ERR.search(out):
            print("  → Lỗi MẠNG: kiểm tra VPN/proxy/Wi-Fi, hoặc chạy lại với --offline.")
        raise SystemExit("Dừng: pub get không thành công.")
    print(_c("OK", "  pub get OK."))
    notes.append("Đã tự chạy `flutter pub get` trước khi kiểm.")
    proj = Project(ROOT)
    proj.stale_issues = freshness_issues(proj)
    return proj, notes


def check_freshness(proj: Project, rep: Report, notes: list[str] | None = None) -> None:
    rep.section("1. Trạng thái pub get")
    for n in notes or []:
        rep.add("INFO", n)
    issues = getattr(proj, "stale_issues", None)
    if issues is None:
        issues = freshness_issues(proj)
    if issues:
        rep.add("FAIL", "pubspec.yaml / pubspec.lock / plugin list chưa khớp:", issues[:10]
                + ["→ chạy `flutter pub get` (hoặc bỏ --no-pub-get để script tự chạy)."])
    else:
        rep.add("OK", "pubspec.yaml / pubspec.lock / .flutter-plugins-dependencies / package_config khớp nhau.")


def check_version(proj: Project, rep: Report) -> None:
    rep.section("2. Version")
    m = MANIFEST_DIR / f"{proj.version}.json"
    if m.exists():
        rep.add("FAIL", f"Version {proj.version} đã release (có {_rel(m)}).",
                ["→ Bump `version:` trong pubspec.yaml. Shorebird không cho release trùng version."])
    else:
        rep.add("OK", f"Version {proj.version} chưa có manifest release.")
    if "shorebird.yaml" not in proj.pubspec_text:
        rep.add("FAIL", "pubspec.yaml không khai `shorebird.yaml` trong flutter.assets.")
    else:
        rep.add("OK", "shorebird.yaml có trong flutter.assets.")


def check_native_coverage(proj: Project, rep: Report, patch_pkgs: list[str], platforms=PLATFORMS) -> None:
    rep.section("3. Plugin native mà package chỉ-có-qua-patch cần")
    if not patch_pkgs:
        rep.add("INFO", "Không khai --patch-packages → bỏ qua (release build có đủ mọi package).")
        return
    absent = [p for p in patch_pkgs if p not in proj.package_dirs]
    if absent:
        rep.add("FAIL", f"Không thấy {absent} trong cây dependency hiện tại.",
                ["→ Chạy `check` trên cây ĐẦY ĐỦ (có app_package trong pubspec.yaml),",
                 "  trước khi bỏ nó ra để build release."])
        return
    patch_closure = proj.closure(patch_pkgs)
    release_closure = proj.closure([proj.name], exclude=frozenset(patch_pkgs))
    for note in proj.graph_notes:
        rep.add("INFO", note)

    any_missing = False
    for plat in platforms:
        needed = {n for n in proj.plugins[plat] if n in patch_closure}
        missing = sorted(needed - release_closure)
        if missing:
            any_missing = True
            rep.add("FAIL",
                    f"[{plat}] {len(missing)} plugin native {patch_pkgs} cần nhưng release KHÔNG có: {', '.join(missing)}",
                    ["→ Thêm vào block PRE-BUNDLE của pubspec.yaml gốc:"]
                    + [l for m_ in missing for l in _suggest_line(proj, m_).splitlines()])
        else:
            rep.add("OK", f"[{plat}] Release đã có đủ {len(needed)} plugin native mà {patch_pkgs} cần.")
    if any_missing:
        rep.add("INFO", "Plugin federated (vd. url_launcher_android) có thể thêm bằng package mặt tiền (url_launcher).")


def check_pins(proj: Project, rep: Report, patch_pkgs: list[str], platforms=PLATFORMS) -> None:
    rep.section("4. Ghim version plugin native")
    if not patch_pkgs or any(p not in proj.package_dirs for p in patch_pkgs):
        rep.add("INFO", "Bỏ qua (không có package chỉ-qua-patch trong cây).")
        return
    patch_closure = proj.closure(patch_pkgs)
    loose = []
    for plat in platforms:
        for n in proj.plugins[plat]:
            if n not in patch_closure or proj.is_path_pkg(n):
                continue
            dep = proj.root_deps.get(n)
            locked = proj.version_of(n)
            constraint = (dep or {}).get("raw") or (dep or {}).get("version")
            if dep is None:
                loose.append(f"{n} {locked}  (transitive — release resolve lại có thể ra version khác)")
            elif constraint != locked:
                loose.append(f"{n}: {constraint}  → lock đang {locked}")
    loose = sorted(set(loose))
    if loose:
        rep.add("WARN",
                f"{len(loose)} plugin native chưa ghim exact. Bỏ {patch_pkgs} ra khi release thì pub resolve lại; "
                "patch sau lại resolve theo app_package → Dart lệch native.",
                loose + ["→ Ghim exact (vd. `url_launcher_android: 6.3.33`) trong pubspec.yaml gốc,",
                         "  hoặc dựa vào `verify-patch` để bắt lệch trước khi patch."])
    else:
        rep.add("OK", "Mọi plugin native app_package dùng đều đã ghim exact ở pubspec gốc.")


def check_patch_assets(proj: Project, rep: Report, patch_pkgs: list[str]) -> None:
    rep.section("5. Asset / font trong package chỉ-qua-patch")
    if not patch_pkgs or any(p not in proj.package_dirs for p in patch_pkgs):
        rep.add("INFO", "Bỏ qua.")
        return
    hits = []
    for n in sorted(proj.closure(patch_pkgs)):
        if not proj.is_path_pkg(n):
            continue
        ps = proj.package_dirs[n] / "pubspec.yaml"
        if ps.exists():
            kinds = parse_flutter_assets(ps.read_text(encoding="utf-8"))
            if kinds:
                hits.append(f"{n}: {', '.join(kinds)}")
    if hits:
        rep.add("WARN", "Package chỉ-qua-patch có khai asset/font — không trông vào patch để mang asset lên:",
                hits + ["→ Đưa asset vào binary release, hoặc tải qua mạng."])
    else:
        rep.add("OK", "Không package chỉ-qua-patch nào khai asset/font.")


def check_source_rules(proj: Project, rep: Report) -> None:
    rep.section("6. Cờ debug / cấu hình phải đổi trước release")
    for rel, pattern, level, msg, *_ in SOURCE_RULES:
        f = proj.root / rel
        if not f.exists():
            rep.add("WARN", f"Không thấy {rel} (luật '{msg[:40]}…' cần cập nhật?).")
            continue
        text = f.read_text(encoding="utf-8", errors="replace")
        m = re.search(pattern, text)
        if m:
            line_no = text.count("\n", 0, m.start()) + 1
            rep.add(level, f"{rel}:{line_no} — {msg}")
        else:
            rep.add("OK", f"{rel} — ổn.")

    blockers = []
    for d in BLOCKER_SCAN_DIRS:
        base = proj.root / d
        if not base.exists():
            continue
        for p in base.rglob("*"):
            if p.suffix not in BLOCKER_EXTS or not p.is_file():
                continue
            if any(part in ("build", ".dart_tool", "Pods", ".gradle") for part in p.parts):
                continue
            try:
                for i, line in enumerate(p.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
                    if BLOCKER_MARKER in line:
                        blockers.append(f"{_rel(p)}:{i}: {line.strip()[:100]}")
            except OSError:
                pass
    if blockers:
        rep.add("FAIL", f"Còn {len(blockers)} dấu `{BLOCKER_MARKER}`:", blockers[:20])
    else:
        rep.add("OK", f"Không còn dấu `{BLOCKER_MARKER}`.")


def _check_registrant(proj: Project, rep: Report, plat: str) -> None:
    f = proj.root / (
        "android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
        if plat == "android" else "ios/Runner/GeneratedPluginRegistrant.m")
    if not f.exists():
        rep.add("WARN", f"Chưa có {_rel(f)} (sẽ sinh khi build).")
        return
    text = f.read_text(encoding="utf-8", errors="replace")
    if plat == "android":
        missing = [n for n in proj.plugins[plat] if f"Error registering plugin {n}," not in text]
    else:
        missing = [n for n in proj.plugins[plat] if f"<{n}/" not in text and f"@import {n};" not in text]
    if missing:
        rep.add("FAIL", f"GeneratedPluginRegistrant thiếu: {', '.join(sorted(missing))}",
                ["→ `flutter clean && flutter pub get` rồi build lại (registrant đang cũ)."])
    else:
        rep.add("OK", f"GeneratedPluginRegistrant đăng ký đủ {len(proj.plugins[plat])} plugin.")


_IGNORED_SCHEMES = {"http", "https", "ws", "wss", "file", "data", "package", "asset", "dart",
                    "content", "blob", "about", "javascript", "intent", "market"}


def _custom_url_schemes(proj: Project) -> dict[str, str]:
    """Scheme dạng `xxx://` xuất hiện trong code Dart của app + package path → {scheme: file:line}."""
    found: dict[str, str] = {}
    pat = re.compile(r"""['"]([a-z][a-z0-9+.\-]{1,24})://""")
    dirs = [proj.root / "lib"] + [d / "lib" for n, d in proj.package_dirs.items()
                                  if proj.is_path_pkg(n) and n != proj.name]
    for base in dirs:
        if not base.is_dir():
            continue
        for p in base.rglob("*.dart"):
            if p.name.endswith((".g.dart", ".freezed.dart")):
                continue
            try:
                text = p.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            for m in pat.finditer(text):
                s = m.group(1)
                if s not in _IGNORED_SCHEMES and s not in found:
                    found[s] = f"{_rel(p)}:{text.count(chr(10), 0, m.start()) + 1}"
    return found


def _plugin_dir(proj: Project, name: str) -> Path | None:
    d = proj.package_dirs.get(name)
    return d if d and d.is_dir() else None


def _ver_tuple(v: str) -> tuple:
    return tuple(int(x) for x in re.findall(r"\d+", v)[:3]) or (0,)


# ---------------------------------------------------------------------------
# Android
# ---------------------------------------------------------------------------
def check_android(proj: Project, rep: Report) -> None:
    rep.section("A. Android")
    gradle = next((proj.root / "android/app" / n for n in ("build.gradle.kts", "build.gradle")
                   if (proj.root / "android/app" / n).exists()), None)
    manifest_p = proj.root / "android/app/src/main/AndroidManifest.xml"
    if gradle is None or not manifest_p.exists():
        rep.add("FAIL", "Không thấy android/app/build.gradle(.kts) hoặc AndroidManifest.xml.")
        return
    g = gradle.read_text(encoding="utf-8", errors="replace")
    manifest = manifest_p.read_text(encoding="utf-8", errors="replace")

    # A1. applicationId / namespace
    app_id = (re.search(r'applicationId\s*=?\s*"([^"]+)"', g) or [None, None])[1]
    namespace = (re.search(r'namespace\s*=?\s*"([^"]+)"', g) or [None, None])[1]
    if not app_id:
        rep.add("FAIL", f"Không đọc được applicationId trong {_rel(gradle)}.")
    elif app_id.startswith("com.example"):
        rep.add("FAIL", f"applicationId vẫn là mặc định: {app_id}")
    else:
        rep.add("OK", f"applicationId = {app_id}")

    # A2. MainActivity đúng package (sai → ClassNotFoundException ngay khi mở app)
    act = re.search(r'<activity[^>]*android:name="([^"]+)"', manifest, re.S)
    if act and namespace:
        expected = act.group(1)
        if expected.startswith("."):
            expected = namespace + expected
        found = None
        for d in ("kotlin", "java"):
            for p in (proj.root / "android/app/src/main" / d).rglob("MainActivity.*") \
                    if (proj.root / "android/app/src/main" / d).is_dir() else []:
                pkg = re.search(r"^\s*package\s+([\w.]+)", p.read_text(encoding="utf-8", errors="replace"), re.M)
                if pkg:
                    found = (f"{pkg.group(1)}.MainActivity", p)
        if not found:
            rep.add("FAIL", f"Không thấy MainActivity cho {expected}.")
        elif found[0] != expected:
            rep.add("FAIL", f"Manifest trỏ {expected} nhưng {_rel(found[1])} khai {found[0]} → crash khi mở app.")
        else:
            rep.add("OK", f"MainActivity khớp manifest ({expected}).")

    # A3. version lấy từ pubspec (Shorebird so version theo pubspec)
    for key in ("versionCode", "versionName"):
        if re.search(rf"{key}\s*=?\s*flutter\.{key}", g):
            rep.add("OK", f"{key} = flutter.{key} (lấy từ pubspec {proj.version}).")
        else:
            rep.add("FAIL", f"{key} bị hard-code trong {_rel(gradle)} → lệch version Shorebird/pubspec.")

    # A4. Signing release
    rel_block = re.search(r"buildTypes\s*\{.*?release\s*\{(.*?)\}", g, re.S)
    signing = rel_block.group(1) if rel_block else ""
    if re.search(r'signingConfigs\.getByName\("debug"\)|signingConfig\s+signingConfigs\.debug', signing):
        rep.add("FAIL", "buildTypes.release đang ký bằng DEBUG key → không upload/cập nhật được trên store.")
    elif "signingConfig" not in signing:
        rep.add("FAIL", "buildTypes.release không có signingConfig.")
    else:
        rep.add("OK", "buildTypes.release dùng signingConfig release.")
    kp = proj.root / "android/key.properties"
    if "key.properties" in g:
        if not kp.exists():
            rep.add("FAIL", "Thiếu android/key.properties → build release không ký được.")
        else:
            props = dict(l.split("=", 1) for l in kp.read_text(encoding="utf-8", errors="replace").splitlines()
                         if "=" in l and not l.lstrip().startswith("#"))
            props = {k.strip(): v.strip() for k, v in props.items()}
            empty = [k for k in ("storeFile", "storePassword", "keyAlias", "keyPassword") if not props.get(k)]
            store = props.get("storeFile")
            if empty:
                rep.add("FAIL", f"key.properties thiếu: {', '.join(empty)}")
            elif not ((proj.root / "android/app" / store).exists() or Path(store).expanduser().exists()):
                rep.add("FAIL", f"key.properties trỏ storeFile={store} nhưng file không tồn tại (tính từ android/app/).")
            else:
                rep.add("OK", f"key.properties đủ 4 khoá, keystore {store} tồn tại.")

    # A5. minSdk ≥ minSdk của mọi plugin native
    m = re.search(r"minSdk(?:Version)?\s*=?\s*(\d+)", g)
    if not m:
        rep.add("WARN", "minSdk = flutter.minSdkVersion (không ghim) — không so được với plugin.")
    else:
        app_min, too_low, unread = int(m.group(1)), [], []
        for n in proj.plugins["android"]:
            d = _plugin_dir(proj, n)
            pg = next((d / "android" / f for f in ("build.gradle", "build.gradle.kts")
                       if d and (d / "android" / f).exists()), None) if d else None
            if not pg:
                unread.append(n)
                continue
            pm = re.search(r"minSdk(?:Version)?\s*(?:=|\s)\s*(\d+)", pg.read_text(encoding="utf-8", errors="replace"))
            if pm and int(pm.group(1)) > app_min:
                too_low.append(f"{n} cần minSdk {pm.group(1)}")
        if too_low:
            rep.add("FAIL", f"minSdk app = {app_min} thấp hơn yêu cầu plugin:", too_low)
        else:
            rep.add("OK", f"minSdk = {app_min} ≥ yêu cầu của các plugin đọc được.")
        if unread:
            rep.add("INFO", f"Không đọc được build.gradle của {len(unread)} plugin (pub-cache) — chạy trên Mac để kiểm đủ.")

    # A6. Manifest
    if "android.permission.INTERNET" in manifest:
        rep.add("OK", "Có quyền INTERNET (Shorebird updater cần để tải patch).")
    else:
        rep.add("FAIL", "Thiếu android.permission.INTERNET trong main manifest → Shorebird không tải được patch, "
                        "và bản release không có mạng (debug tự thêm nên dễ không thấy).")
    if any(n.startswith("url_launcher") for n in proj.plugins["android"]):
        declared = set(re.findall(r'android:scheme="([^"]+)"', manifest))
        need = {"https"} | set(_custom_url_schemes(proj))
        miss = sorted(need - declared)
        if miss:
            rep.add("WARN", f"<queries> thiếu scheme: {', '.join(miss)} → Android 11+ canLaunchUrl/launchUrl trả false.")
        else:
            rep.add("OK", f"<queries> khai đủ scheme url_launcher dùng ({', '.join(sorted(need))}).")

    # A7. Registrant
    _check_registrant(proj, rep, "android")


# ---------------------------------------------------------------------------
# iOS
# ---------------------------------------------------------------------------
def check_ios(proj: Project, rep: Report) -> None:
    import plistlib
    rep.section("I. iOS")
    plist_p = proj.root / "ios/Runner/Info.plist"
    pbx_p = proj.root / "ios/Runner.xcodeproj/project.pbxproj"
    if not plist_p.exists() or not pbx_p.exists():
        rep.add("FAIL", "Không thấy ios/Runner/Info.plist hoặc ios/Runner.xcodeproj/project.pbxproj.")
        return
    try:
        plist = plistlib.loads(plist_p.read_bytes())
    except Exception as e:  # noqa: BLE001
        rep.add("FAIL", f"Info.plist không parse được: {e}")
        return
    pbx = pbx_p.read_text(encoding="utf-8", errors="replace")

    # I1. Bundle id
    ids = {v.strip('";') for v in re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", pbx)}
    app_ids = sorted(i for i in ids if not i.endswith("RunnerTests"))
    if not app_ids:
        rep.add("FAIL", "Không đọc được PRODUCT_BUNDLE_IDENTIFIER.")
    elif len(app_ids) > 1:
        rep.add("FAIL", f"Bundle id khác nhau giữa Debug/Release/Profile: {app_ids}")
    elif app_ids[0].startswith("com.example"):
        rep.add("FAIL", f"Bundle id vẫn là mặc định: {app_ids[0]}")
    else:
        rep.add("OK", f"Bundle id = {app_ids[0]}")

    # I2. Version lấy từ Flutter
    for key, want in (("CFBundleShortVersionString", "$(FLUTTER_BUILD_NAME)"),
                      ("CFBundleVersion", "$(FLUTTER_BUILD_NUMBER)")):
        if plist.get(key) == want:
            rep.add("OK", f"{key} = {want}")
        else:
            rep.add("FAIL", f"{key} = {plist.get(key)!r} (phải là {want}) → lệch version Shorebird/pubspec.")

    # I3. Signing
    teams = set(re.findall(r"DEVELOPMENT_TEAM = ([^;]+);", pbx))
    if teams:
        rep.add("OK", f"DEVELOPMENT_TEAM = {', '.join(sorted(teams))}")
    else:
        rep.add("WARN", "Chưa set DEVELOPMENT_TEAM → `shorebird release ios` (archive) sẽ fail ký. "
                        "Chọn Team trong Xcode > Runner > Signing & Capabilities.")

    # I4. Deployment target ≥ plugin + khớp Podfile
    targets = sorted({v for v in re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);", pbx)}, key=_ver_tuple)
    if not targets:
        rep.add("WARN", "Không đọc được IPHONEOS_DEPLOYMENT_TARGET.")
        app_min = None
    else:
        app_min = targets[0]
        if len(targets) > 1:
            rep.add("WARN", f"IPHONEOS_DEPLOYMENT_TARGET không đồng nhất: {targets}")
        else:
            rep.add("OK", f"IPHONEOS_DEPLOYMENT_TARGET = {app_min}")
    podfile = proj.root / "ios/Podfile"
    if podfile.exists():
        pm = re.search(r"^\s*platform\s*:ios\s*,\s*'([\d.]+)'", podfile.read_text(encoding="utf-8", errors="replace"), re.M)
        if pm and app_min and _ver_tuple(pm.group(1)) != _ver_tuple(app_min):
            rep.add("WARN", f"Podfile platform :ios '{pm.group(1)}' khác IPHONEOS_DEPLOYMENT_TARGET {app_min}.")
        elif not pm:
            rep.add("INFO", "Podfile chưa ghim `platform :ios` (CocoaPods tự đoán).")
    if app_min:
        too_low, unread, no_spm = [], [], []
        for n in proj.plugins["ios"]:
            d = _plugin_dir(proj, n)
            srcs = [d / s for s in ("ios", "darwin")] if d else []
            files = [p for s in srcs if s.is_dir() for p in list(s.glob("*.podspec")) + list(s.rglob("Package.swift"))]
            if not files:
                unread.append(n)
                continue
            mins = []
            for p in files:
                t = p.read_text(encoding="utf-8", errors="replace")
                mins += re.findall(r"ios\.deployment_target\s*=\s*['\"]([\d.]+)", t)
                mins += re.findall(r"platform\s*=\s*:ios\s*,\s*['\"]([\d.]+)", t)
                mins += re.findall(r"\.iOS\(\s*\"([\d.]+)\"", t)
                mins += [a.replace("_", ".") for a in re.findall(r"\.iOS\(\s*\.v(\d+(?:_\d+)?)", t)]
            if not any(p.name == "Package.swift" for p in files):
                no_spm.append(n)
            if mins:
                need = max(mins, key=_ver_tuple)
                if _ver_tuple(need) > _ver_tuple(app_min):
                    too_low.append(f"{n} cần iOS {need}")
        if too_low:
            rep.add("FAIL", f"Deployment target {app_min} thấp hơn yêu cầu plugin:", too_low)
        else:
            rep.add("OK", f"Deployment target {app_min} ≥ yêu cầu của các plugin đọc được.")
        if unread:
            rep.add("INFO", f"Không đọc được podspec của {len(unread)} plugin (pub-cache) — chạy trên Mac để kiểm đủ.")
        if no_spm and not podfile.exists():
            rep.add("FAIL", f"Thiếu ios/Podfile nhưng {len(no_spm)} plugin chưa hỗ trợ SwiftPM: {', '.join(no_spm)}")

    # I5. URL scheme để terminate_restart mở lại app
    url_types = plist.get("CFBundleURLTypes") or []
    schemes = {s for t in url_types for s in t.get("CFBundleURLSchemes", [])}
    if "$(PRODUCT_BUNDLE_IDENTIFIER)" in schemes or (app_ids and app_ids[0] in schemes):
        rep.add("OK", "CFBundleURLTypes có scheme = bundle id (terminate_restart mở lại app sau restart patch).")
    elif "terminate_restart" in proj.plugins["ios"]:
        rep.add("WARN", "CFBundleURLTypes thiếu scheme $(PRODUCT_BUNDLE_IDENTIFIER) → restart patch xong app tắt hẳn.")

    # I6. LSApplicationQueriesSchemes cho canLaunchUrl
    if any(n.startswith("url_launcher") for n in proj.plugins["ios"]):
        declared = set(plist.get("LSApplicationQueriesSchemes") or [])
        used = _custom_url_schemes(proj)
        miss = sorted(s for s in used if s not in declared)
        if miss:
            rep.add("WARN", f"LSApplicationQueriesSchemes thiếu: {', '.join(miss)} → canLaunchUrl trả false trên iOS.",
                    [f"{s}: {used[s]}" for s in miss[:10]])
        else:
            rep.add("OK", "LSApplicationQueriesSchemes khai đủ scheme tuỳ biến mà code dùng.")

    # I7. Quyền riêng tư theo plugin (thiếu → App Store từ chối / crash khi xin quyền)
    privacy = {
        "camera_avfoundation": ["NSCameraUsageDescription", "NSMicrophoneUsageDescription"],
        "image_picker_ios": ["NSPhotoLibraryUsageDescription", "NSCameraUsageDescription"],
        "geolocator_apple": ["NSLocationWhenInUseUsageDescription"],
        "location": ["NSLocationWhenInUseUsageDescription"],
        "mobile_scanner": ["NSCameraUsageDescription"],
        "local_auth_darwin": ["NSFaceIDUsageDescription"],
        "record_ios": ["NSMicrophoneUsageDescription"],
        "contacts_service": ["NSContactsUsageDescription"],
        "permission_handler_apple": [],
    }
    missing_priv = [f"{n}: {k}" for n, keys in privacy.items() if n in proj.plugins["ios"]
                    for k in keys if k not in plist]
    if missing_priv:
        rep.add("FAIL", "Info.plist thiếu mô tả quyền mà plugin cần:", missing_priv)
    else:
        rep.add("OK", "Không thiếu mô tả quyền (NS*UsageDescription) cho plugin đã biết.")

    # I8. Registrant
    _check_registrant(proj, rep, "ios")


def run_check(args) -> int:
    proj, notes = load_fresh_project(not getattr(args, "no_pub_get", False), getattr(args, "offline", False))
    rep = Report()
    print(f"Shorebird preflight — {proj.name} {proj.version}   platform: {', '.join(args.platform)}   "
          f"(patch-only: {args.patch_packages or 'none'})")
    check_freshness(proj, rep, notes)
    check_version(proj, rep)
    check_native_coverage(proj, rep, args.patch_packages, args.platform)
    check_pins(proj, rep, args.patch_packages, args.platform)
    check_patch_assets(proj, rep, args.patch_packages)
    check_source_rules(proj, rep)
    if "android" in args.platform:
        check_android(proj, rep)
    if "ios" in args.platform:
        check_ios(proj, rep)
    return rep.finish(args.strict)


# ---------------------------------------------------------------------------
# fix — tự cấu hình native trước release/patch
# ---------------------------------------------------------------------------
MANAGED_BEGIN = "  # >>> shorebird_preflight: native plugins (tự sinh — đừng sửa tay, chạy `fix` để cập nhật)"
MANAGED_END = "  # <<< shorebird_preflight"
OV_BEGIN = "  # >>> shorebird_preflight: path overrides (tự sinh từ PATH_OVERRIDES — chạy `fix` để cập nhật)"
OV_END = "  # <<< shorebird_preflight overrides"


def _local_path(p: str) -> Path:
    """Đổi path trên Mac sang path đọc được ở máy đang chạy (PREFLIGHT_PATH_MAP="src=dst;...")."""
    for pair in filter(None, os.environ.get("PREFLIGHT_PATH_MAP", "").split(";")):
        src, _, dst = pair.partition("=")
        if src and p.startswith(src):
            return Path(dst + p[len(src):])
    return Path(p)


def compute_path_overrides(proj: Project) -> tuple[dict[str, str], list[str]]:
    """{tên: path tuyệt đối} cần đưa vào dependency_overrides, kèm cảnh báo."""
    result: dict[str, str] = {}
    warns: list[str] = []
    queue = list(PATH_OVERRIDES.items())
    while queue:
        name, path = queue.pop(0)
        path = os.path.normpath(path)
        if name in result:
            continue
        result[name] = path
        ps = _local_path(path) / "pubspec.yaml"
        if not ps.exists():
            warns.append(f"{name}: không đọc được {path}/pubspec.yaml")
            continue
        for dep, spec in parse_dep_block(ps.read_text(encoding="utf-8")).items():
            if "path" not in spec:
                continue
            dep_abs = os.path.normpath(os.path.join(path, spec["path"]))
            cur = proj.package_dirs.get(dep)
            if cur is not None and os.path.normpath(str(cur)) != dep_abs and dep not in result:
                queue.append((dep, dep_abs))
    return result, warns


def plan_overrides_block(text: str, overrides: dict[str, str]) -> str:
    lines = text.splitlines()
    # bỏ block cũ
    b = next((i for i, l in enumerate(lines) if l.rstrip() == OV_BEGIN), None)
    if b is not None:
        e = next(i for i in range(b, len(lines)) if lines[i].rstrip() == OV_END)
        del lines[b:e + 1]
        if b > 0 and not lines[b - 1].strip() and (b >= len(lines) or not lines[b].strip()):
            del lines[b - 1]
    # bỏ section dependency_overrides rỗng do mình để lại
    for i, l in enumerate(lines):
        if l.rstrip() == "dependency_overrides:":
            nxt = next((j for j in range(i + 1, len(lines)) if lines[j].strip()), None)
            if nxt is None or not lines[nxt].startswith((" ", "\t")):
                del lines[i]
                if i < len(lines) and not lines[i].strip() and i > 0 and not lines[i - 1].strip():
                    del lines[i]
            break
    if overrides:
        block = [OV_BEGIN]
        for n in sorted(overrides):
            block += [f"  {n}:", f"    path: {overrides[n]}"]
        block.append(OV_END)
        idx = next((i for i, l in enumerate(lines) if l.rstrip() == "dependency_overrides:"), None)
        if idx is not None:
            lines[idx + 1:idx + 1] = block
        else:
            rng = _deps_block_range(lines)
            end = rng[1] if rng else len(lines)
            lines[end:end] = ["", "dependency_overrides:"] + block
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")
PIN_NOTE = "# pinned by shorebird_preflight"


def _deps_block_range(lines: list[str]) -> tuple[int, int] | None:
    """[start, end) của các dòng con thuộc `dependencies:` top-level."""
    start = None
    for i, raw in enumerate(lines):
        if raw.startswith("dependencies:"):
            start = i + 1
            continue
        if start is not None and raw.strip() and not raw.startswith((" ", "\t", "#")):
            end = i
            while end > start and not lines[end - 1].strip():
                end -= 1
            return start, end
    return (start, len(lines)) if start is not None else None


def plan_pubspec_pins(proj: Project, platforms, pin_to: dict[str, str] | None = None) -> tuple[str, list[str]]:
    """Trả về (pubspec mới, danh sách thay đổi). Ghim exact MỌI plugin native trong cây.

    pin_to: version ép theo binary đã release (chế độ patch). Không có → theo pubspec.lock.
    """
    pin_to = pin_to or {}
    # pubspec.yaml dùng chung cho mọi nền tảng → LUÔN ghim plugin của cả android lẫn ios,
    # bất kể --platform (nếu không, chạy `fix --platform android` sẽ xoá ghim plugin iOS).
    names = sorted({n for plat in PLATFORMS for n in proj.plugins[plat]})

    def want(n: str) -> str | None:
        return pin_to.get(n) or proj.lock.get(n, {}).get("version")
    lines = proj.pubspec_text.splitlines()
    rng = _deps_block_range(lines)
    if rng is None:
        raise SystemExit("pubspec.yaml không có block `dependencies:`.")
    start, end = rng

    # Bỏ managed block cũ (sẽ sinh lại)
    old_managed: set[str] = set()
    b = next((i for i in range(start, end) if lines[i].rstrip() == MANAGED_BEGIN), None)
    if b is not None:
        e = next((i for i in range(b, len(lines)) if lines[i].rstrip() == MANAGED_END), None)
        if e is None:
            raise SystemExit("Thấy marker mở nhưng không thấy marker đóng của managed block trong pubspec.yaml.")
        for l in lines[b + 1:e]:
            mm = re.match(r"\s+([A-Za-z0-9_]+):", _strip_comment(l))
            if mm and not _strip_comment(l).strip().startswith("path:"):
                old_managed.add(mm.group(1))
        del lines[b:e + 1]
        while b < len(lines) and b > 0 and not lines[b - 1].strip() and not lines[b].strip():
            del lines[b - 1]
            b -= 1
        start, end = _deps_block_range(lines)

    # Map tên → dòng khai báo trực tiếp (ngoài managed block)
    entry_line: dict[str, int] = {}
    base = None
    for i in range(start, end):
        s = _strip_comment(lines[i])
        if not s.strip():
            continue
        ind = _indent(s)
        base = ind if base is None else min(base, ind)
    for i in range(start, end):
        s = _strip_comment(lines[i])
        if s.strip() and _indent(s) == base and ":" in s:
            entry_line[s.strip().split(":", 1)[0].strip()] = i

    changes, to_add = [], []
    for n in names:
        is_path = proj.is_path_pkg(n)
        locked = want(n)
        if n in entry_line:
            i = entry_line[n]
            s = _strip_comment(lines[i])
            val = s.split(":", 1)[1].strip()
            if is_path or not locked:
                continue
            if val == "":  # khai dạng nhiều dòng (hosted:/version:)
                j = i + 1
                while j < len(lines) and (not lines[j].strip() or _indent(lines[j]) > base):
                    if re.match(r"\s+version:", lines[j]):
                        old = _unquote(lines[j].split(":", 1)[1].split("#")[0])
                        if old != locked:
                            ind = " " * _indent(lines[j])
                            lines[j] = f"{ind}version: {locked}  {PIN_NOTE}"
                            changes.append(f"{n}: {old} → {locked}")
                        break
                    j += 1
                continue
            if _unquote(val) != locked:
                lines[i] = f"{' ' * base}{n}: {locked}  {PIN_NOTE} (trước: {_unquote(val)})"
                changes.append(f"{n}: {_unquote(val)} → {locked}")
        else:
            to_add.append(n)

    if to_add:
        ind = " " * (base or 2)
        block = ["", MANAGED_BEGIN,
                 f"{ind}# Plugin native có trong cây (thường đến từ app_package) nhưng pubspec gốc",
                 f"{ind}# chưa khai trực tiếp. Ghim đúng version trong pubspec.lock để binary release",
                 f"{ind}# luôn chứa đủ native, kể cả khi build release không kèm app_package."]
        for n in to_add:
            if proj.is_path_pkg(n):
                pth = PATH_OVERRIDES.get(n) or _rel(proj.package_dirs[n])
                block += [f"{ind}{n}:", f"{ind}  path: {pth}"]
                desc = f"+ {n} (path: {pth})"
            else:
                block.append(f"{ind}{n}: {want(n)}")
                desc = f"+ {n}: {want(n)}"
            if n not in old_managed:
                changes.append(desc)
        block.append(MANAGED_END)
        _, end = _deps_block_range(lines)
        lines[end:end] = block

    # path override đổi → coi là thay đổi
    for n in to_add:
        if n in PATH_OVERRIDES and n in old_managed and PATH_OVERRIDES[n] not in proj.pubspec_text:
            changes.append(f"{n}: path → {PATH_OVERRIDES[n]}")
    for n in sorted(old_managed - set(to_add)):
        changes.append(f"- {n} (bỏ khỏi managed block)")
    new = "\n".join(lines) + ("\n" if proj.pubspec_text.endswith("\n") else "")
    overrides, ov_warns = compute_path_overrides(proj)
    for w in ov_warns:
        print(_c("WARN", f"  PATH_OVERRIDES: {w}"))
    new2 = plan_overrides_block(new, overrides)
    if new2 != new:
        for n in sorted(overrides):
            if f"path: {overrides[n]}" not in proj.pubspec_text:
                changes.append(f"dependency_overrides: {n} → {overrides[n]}")
        new = new2
    if new == proj.pubspec_text:
        return new, []
    if not changes:
        changes.append("cập nhật managed block (version trong lock đổi)")
    return new, changes


def plan_source_fixes(proj: Project) -> dict[Path, tuple[str, list[str]]]:
    out: dict[Path, tuple[str, list[str]]] = {}
    for rule in SOURCE_RULES:
        if len(rule) < 5 or not rule[4]:
            continue
        rel, pattern, _level, msg, repl = rule
        f = proj.root / rel
        if not f.exists():
            continue
        text = out[f][0] if f in out else f.read_text(encoding="utf-8")
        new, n = re.subn(pattern, repl, text)
        if n:
            prev = out.get(f, ("", []))[1]
            out[f] = (new, prev + [f"{rel}: {msg.split('.')[0]} → `{repl}`"])
    return out


def plan_android_fixes(proj: Project) -> dict[Path, tuple[str, list[str]]]:
    f = proj.root / "android/app/src/main/AndroidManifest.xml"
    if not f.exists():
        return {}
    text, notes = f.read_text(encoding="utf-8"), []
    if "android.permission.INTERNET" not in text:
        text = re.sub(r"(<manifest\b[^>]*>)",
                      r'\1\n    <uses-permission android:name="android.permission.INTERNET" />', text, count=1)
        notes.append("AndroidManifest: + quyền INTERNET")
    if any(n.startswith("url_launcher") for n in proj.plugins["android"]):
        declared = set(re.findall(r'android:scheme="([^"]+)"', text))
        miss = sorted(({"https"} | set(_custom_url_schemes(proj))) - declared)
        if miss:
            intents = "".join(
                f'        <intent>\n            <action android:name="android.intent.action.VIEW" />\n'
                f'            <data android:scheme="{s}" />\n        </intent>\n' for s in miss)
            if "</queries>" in text:
                text = text.replace("    </queries>", intents + "    </queries>", 1) \
                    if "    </queries>" in text else text.replace("</queries>", intents + "</queries>", 1)
            else:
                text = text.replace("</manifest>", f"    <queries>\n{intents}    </queries>\n</manifest>", 1)
            notes.append(f"AndroidManifest <queries>: + {', '.join(miss)}")
    return {f: (text, notes)} if notes else {}


def plan_ios_fixes(proj: Project) -> dict[Path, tuple[str, list[str]]]:
    import plistlib
    f = proj.root / "ios/Runner/Info.plist"
    if not f.exists():
        return {}
    text, notes = f.read_text(encoding="utf-8"), []
    try:
        plist = plistlib.loads(text.encode())
    except Exception:  # noqa: BLE001
        return {}

    def insert_before_root_end(t: str, snippet: str) -> str:
        idx = t.rfind("</dict>")
        return t[:idx] + snippet + t[idx:]

    if any(n.startswith("url_launcher") for n in proj.plugins["ios"]):
        declared = set(plist.get("LSApplicationQueriesSchemes") or [])
        miss = sorted(s for s in _custom_url_schemes(proj) if s not in declared)
        if miss:
            items = "".join(f"\t\t<string>{s}</string>\n" for s in miss)
            m = re.search(r"(<key>LSApplicationQueriesSchemes</key>\s*<array>\s*\n)", text)
            if m:
                text = text[:m.end()] + items + text[m.end():]
            else:
                text = insert_before_root_end(
                    text, f"\t<key>LSApplicationQueriesSchemes</key>\n\t<array>\n{items}\t</array>\n")
            notes.append(f"Info.plist LSApplicationQueriesSchemes: + {', '.join(miss)}")
    schemes = {s for t in (plist.get("CFBundleURLTypes") or []) for s in t.get("CFBundleURLSchemes", [])}
    if "terminate_restart" in proj.plugins["ios"] and "$(PRODUCT_BUNDLE_IDENTIFIER)" not in schemes \
            and "CFBundleURLTypes" not in plist:
        text = insert_before_root_end(text, (
            "\t<!-- terminate_restart: iOS chỉ mở lại app sau exit() qua URL scheme này. -->\n"
            "\t<key>CFBundleURLTypes</key>\n\t<array>\n\t\t<dict>\n"
            "\t\t\t<key>CFBundleTypeRole</key>\n\t\t\t<string>Editor</string>\n"
            "\t\t\t<key>CFBundleURLName</key>\n\t\t\t<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>\n"
            "\t\t\t<key>CFBundleURLSchemes</key>\n\t\t\t<array>\n"
            "\t\t\t\t<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>\n\t\t\t</array>\n"
            "\t\t</dict>\n\t</array>\n"))
        notes.append("Info.plist: + CFBundleURLTypes = $(PRODUCT_BUNDLE_IDENTIFIER)")
    if notes:
        try:
            plistlib.loads(text.encode())
        except Exception as e:  # noqa: BLE001
            print(_c("WARN", f"Bỏ qua sửa Info.plist: kết quả không hợp lệ ({e})."))
            return {}
    return {f: (text, notes)} if notes else {}


_NETWORK_ERR = re.compile(r"SocketException|Connection refused|Failed host lookup|ClientException|"
                          r"Network is unreachable|timed out|HandshakeException", re.I)


def _pub_get(root: Path, offline: bool = False) -> tuple[bool, str]:
    def run(extra: list[str]) -> tuple[bool, str]:
        cmd = _flutter_cmd(root) + ["pub", "get"] + extra
        try:
            res = subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=600)
        except (OSError, subprocess.TimeoutExpired) as e:
            return False, f"{' '.join(cmd)}: {e}"
        return res.returncode == 0, (res.stdout + res.stderr)[-3000:]

    if offline:
        return run(["--offline"])
    ok, out = run([])
    if not ok and _NETWORK_ERR.search(out):
        print(_c("WARN", "  Không kết nối được pub.dev → thử lại `pub get --offline` (version ghim = lock, đã có trong pub-cache)."))
        ok2, out2 = run(["--offline"])
        if ok2:
            return True, out2
        return False, out + "\n--- offline ---\n" + out2
    return ok, out


def run_unpin(proj: Project) -> int:
    lines = proj.pubspec_text.splitlines()
    out, skip, n_restore, n_drop = [], False, 0, 0
    for l in lines:
        if l.rstrip() == MANAGED_BEGIN:
            skip = True
            if out and not out[-1].strip():
                out.pop()
            continue
        if skip:
            if l.rstrip() == MANAGED_END:
                skip = False
            elif re.match(r"\s+[A-Za-z0-9_]+:", l) and not l.strip().startswith(("#", "path:")):
                n_drop += 1
            continue
        m = re.match(rf"^(\s+)([A-Za-z0-9_]+):\s*\S+\s+{re.escape(PIN_NOTE)} \(trước: (.+)\)\s*$", l)
        if m:
            l = f"{m.group(1)}{m.group(2)}: {m.group(3)}"
            n_restore += 1
        out.append(l)
    new = "\n".join(out) + ("\n" if proj.pubspec_text.endswith("\n") else "")
    if new == proj.pubspec_text:
        print("Không có gì để bỏ ghim.")
        return 0
    shutil.copy2(proj.pubspec_path, proj.pubspec_path.with_name("pubspec.yaml.preflight.bak"))
    proj.pubspec_path.write_text(new, encoding="utf-8")
    print(f"Đã bỏ ghim: trả {n_restore} dòng về constraint cũ, bỏ {n_drop} plugin khỏi managed block.")
    print("→ `flutter pub upgrade` / `flutter pub get`, rồi chạy `fix` để ghim lại theo lock mới "
          "(nhớ: đổi version plugin native = phải RELEASE mới, không patch được).")
    return 0


def run_fix(args) -> int:
    proj, _ = load_fresh_project(not args.no_pub_get and not args.unpin, args.offline)
    if args.unpin:
        return run_unpin(proj)
    absent = [p for p in args.patch_packages if p not in proj.package_dirs]
    if absent:
        print(_c("FAIL", f"Không thấy {absent} trong cây. Chạy `fix` trên cây ĐẦY ĐỦ (có app_package) "
                         "để script biết native nào cần ghim."))
        return 1
    print(f"Shorebird preflight FIX — {proj.name} {proj.version}   platform: {', '.join(args.platform)}")

    # Version này đã release (có manifest) → chế độ PATCH: ghim theo đúng binary,
    # không theo pubspec.lock (lock có thể đã trôi sau khi app_package đổi).
    pin_to: dict[str, str] = {}
    mf = MANIFEST_DIR / f"{proj.version}.json"
    if mf.exists() and not args.release_mode:
        m = json.loads(mf.read_text(encoding="utf-8"))
        print(_c("INFO", f"Chế độ PATCH: {proj.version} đã release → ghim plugin theo {_rel(mf)}."))
        new_plugins = []
        for plat, binary in m.get("plugins", {}).items():
            for n in proj.plugins.get(plat, {}):
                v = binary.get(n)
                if v is None:
                    if plat in args.platform:
                        new_plugins.append(f"[{plat}] {n}")
                elif not v.startswith("path:"):
                    pin_to[n] = v
        if new_plugins:
            print(_c("FAIL", "  Plugin native MỚI so với binary — fix không cứu được, phải bump version + release mới:"))
            for x in new_plugins:
                print(f"         {x}")
            print("  → Bump `version:` trong pubspec.yaml rồi chạy lại `fix` (khi đó là chế độ RELEASE).")
            return 1

    plan: dict[Path, tuple[str, list[str]]] = {}
    new_pubspec, pin_changes = plan_pubspec_pins(proj, args.platform, pin_to)
    if pin_changes:
        plan[proj.pubspec_path] = (new_pubspec, [f"pubspec.yaml {c}" for c in pin_changes])
    for part in (plan_source_fixes(proj),
                 plan_android_fixes(proj) if "android" in args.platform else {},
                 plan_ios_fixes(proj) if "ios" in args.platform else {}):
        plan.update(part)

    print("\n== Thay đổi" + (" (dry-run, CHƯA ghi)" if args.dry_run else ""))
    if not plan:
        print("  Không có gì cần sửa.")
    for f, (_, notes) in plan.items():
        for n in notes:
            print(f"  {_c('INFO', '[FIX]')}  {n}")
    if args.dry_run or not plan:
        if args.dry_run:
            return 0
    else:
        backups = {}
        for f, (text, _) in plan.items():
            bak = f.with_name(f.name + ".preflight.bak")
            shutil.copy2(f, bak)
            backups[f] = bak
            f.write_text(text, encoding="utf-8")
        print(f"\n  Đã ghi {len(plan)} file. Bản cũ: *.preflight.bak cạnh từng file.")

        if proj.pubspec_path in plan and not args.no_pub_get:
            print("\n== flutter pub get")
            ok, out = _pub_get(ROOT, offline=args.offline)
            if not ok:
                shutil.copy2(backups[proj.pubspec_path], proj.pubspec_path)
                print(_c("FAIL", "  pub get lỗi → đã KHÔI PHỤC pubspec.yaml. Log:"))
                if _NETWORK_ERR.search(out):
                    print("  → Lỗi MẠNG (không tới được pub.dev): kiểm tra VPN/proxy/Wi-Fi rồi chạy lại.")
                    print("    Hoặc `fix --offline` nếu chắc mọi package đã có trong pub-cache.")
                elif pin_to:
                    print("  (Chế độ PATCH: app_package hiện cần version plugin khác với binary → phải release mới.)")
                print("  " + out.replace("\n", "\n  "))
                return 1
            print(_c("OK", "  pub get OK."))
        elif proj.pubspec_path in plan:
            print(_c("WARN", "\n  Bỏ qua pub get (--no-pub-get). Chạy `flutter pub get` trước khi check/release."))
            return 0

    print("\n== Kiểm lại sau khi sửa")
    args.strict = getattr(args, "strict", False)
    return run_check(args)


# ---------------------------------------------------------------------------
# Snapshot / verify-patch
# ---------------------------------------------------------------------------
_APP_NATIVE = {
    "android": ("android/app/src/main", {".kt", ".java", ".xml"}),
    "ios": ("ios/Runner", {".swift", ".m", ".h", ".plist", ".entitlements"}),
}


def _current_native_state(proj: Project) -> dict:
    plugins, hashes = {}, {}
    for plat in PLATFORMS:
        plugins[plat] = {n: proj.version_of(n) for n in sorted(proj.plugins[plat])}
        hashes[plat] = {}
        for n in proj.plugins[plat]:
            if proj.is_path_pkg(n) and n in proj.package_dirs:
                h = _hash_native_dir(proj.package_dirs[n], plat)
                if h:
                    hashes[plat][n] = h
        # Code native của chính app (MainActivity, AndroidManifest, AppDelegate, Info.plist…)
        base, exts = _APP_NATIVE[plat]
        app = hashlib.sha256()
        root = proj.root / base
        if root.is_dir():
            for p in sorted(root.rglob("*")):
                if p.is_file() and p.suffix in exts and "GeneratedPluginRegistrant" not in p.name \
                        and "/res/" not in str(p):
                    app.update(_rel(p).encode())
                    app.update(p.read_bytes())
        hashes[plat]["<app native code>"] = app.hexdigest()[:16]
    return {"plugins": plugins, "native_hashes": hashes}


def _flutter_version(root: Path) -> str | None:
    try:
        res = subprocess.run(_flutter_cmd(root) + ["--version", "--machine"], cwd=root,
                             capture_output=True, text=True, timeout=120)
        start = res.stdout.find("{")
        if start >= 0:
            return json.loads(res.stdout[start:]).get("frameworkVersion")
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
        pass
    return None


def run_snapshot(args) -> int:
    proj, _ = load_fresh_project(not args.no_pub_get, args.offline)
    MANIFEST_DIR.mkdir(exist_ok=True)
    out = MANIFEST_DIR / f"{proj.version}.json"
    manifest = json.loads(out.read_text(encoding="utf-8")) if out.exists() else {}
    clash = [p for p in args.platform if p in manifest.get("plugins", {})]
    if clash and not args.force:
        print(f"{_rel(out)} đã có snapshot cho {clash}. Dùng --force nếu chắc chắn muốn ghi đè.")
        return 1
    state = _current_native_state(proj)
    manifest.setdefault("version", proj.version)
    manifest.setdefault("plugins", {})
    manifest.setdefault("native_hashes", {})
    manifest.setdefault("releases", {})
    for plat in args.platform:
        manifest["plugins"][plat] = state["plugins"][plat]
        manifest["native_hashes"][plat] = state["native_hashes"][plat]
        manifest["releases"][plat] = {
            "created_at": _dt.datetime.now().isoformat(timespec="seconds"),
            "flutter": _flutter_version(ROOT),
            "flags": args.flags,
            "packages_in_release": sorted(n for n in proj.root_deps if n != "flutter"),
        }
    out.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Đã ghi {_rel(out)}: " + ", ".join(f"{p}={len(manifest['plugins'][p])} plugin" for p in args.platform))
    print("→ Commit file này cùng code release. `verify-patch` sẽ so với nó.")
    return 0


def run_verify_patch(args) -> int:
    proj, notes = load_fresh_project(not args.no_pub_get, args.offline)
    rep = Report()
    version = args.release or proj.version
    mf = MANIFEST_DIR / f"{version}.json"
    print(f"Verify patch — cây hiện tại vs release {version}")
    rep.section("Manifest release")
    if not mf.exists():
        rep.add("FAIL", f"Không có {_rel(mf)}.",
                ["→ Release này chưa chạy `snapshot`. Không có cách nào biết binary chứa gì;",
                 "  cài binary release thuần lên máy và so log trước khi patch."])
        return rep.finish(args.strict)
    m = json.loads(mf.read_text(encoding="utf-8"))
    for plat, r in m.get("releases", {}).items():
        rep.add("OK", f"[{plat}] release tạo {r.get('created_at')}, flutter {r.get('flutter')}, cờ: {r.get('flags') or '(trống)'}")
    if args.release and args.release != proj.version:
        rep.add("WARN", f"pubspec đang {proj.version}, patch nhắm {args.release} → nhớ truyền --release-version.")

    check_freshness(proj, rep, notes)
    cur = _current_native_state(proj)

    rep.section("Plugin native so với binary")
    plats = [p for p in m.get("plugins", {}) if not args.platform or p in args.platform]
    for plat in plats:
        old, new = m["plugins"][plat], cur["plugins"].get(plat, {})
        added = sorted(set(new) - set(old))
        removed = sorted(set(old) - set(new))
        changed = sorted(n for n in set(old) & set(new) if old[n] != new[n])
        if added:
            rep.add("FAIL", f"[{plat}] Plugin native MỚI, binary không có: {', '.join(added)}",
                    ["→ Patch sẽ ném MissingPluginException/channel-error. Phải release binary mới."])
        if changed:
            rep.add("FAIL", f"[{plat}] Plugin native đổi version so với binary:",
                    [f"{n}: binary {old[n]} → hiện tại {new[n]}" for n in changed]
                    + ["→ Ghim lại đúng version của binary trong pubspec.yaml, hoặc release mới."])
        if removed:
            rep.add("WARN", f"[{plat}] Plugin có trong binary nhưng cây hiện tại không dùng: {', '.join(removed)}")
        if not (added or changed):
            rep.add("OK", f"[{plat}] {len(new)} plugin native khớp binary.")

    rep.section("Code native (plugin path + app)")
    for plat in plats:
        old_h = m.get("native_hashes", {}).get(plat, {})
        new_h = cur["native_hashes"].get(plat, {})
        for n, h in old_h.items():
            now = new_h.get(n)
            if now is None:
                rep.add("WARN", f"[{plat}] {n}: không còn trong cây hiện tại.")
            elif now != h:
                rep.add("FAIL", f"[{plat}] {n}: code native đã sửa so với lúc release (patch không mang được).")
            else:
                rep.add("OK", f"[{plat}] {n}: native không đổi.")
        for n in sorted(set(new_h) - set(old_h)):
            rep.add("FAIL", f"[{plat}] {n}: plugin native path MỚI, binary không có.")

    rep.section("Cờ build / Flutter")
    fv = _flutter_version(ROOT)
    for plat in plats:
        r = m.get("releases", {}).get(plat, {})
        if args.flags is None:
            rep.add("WARN", f"[{plat}] Không truyền --flags. Release đã build với: {r.get('flags') or '(trống)'}")
        elif args.flags.split() != (r.get("flags") or "").split():
            rep.add("FAIL", f"[{plat}] Cờ patch khác cờ lúc release:",
                    [f"release: {r.get('flags') or '(trống)'}", f"patch  : {args.flags or '(trống)'}"])
        else:
            rep.add("OK", f"[{plat}] Cờ build trùng với lúc release.")
        if fv and r.get("flutter") and fv != r["flutter"]:
            rep.add("WARN", f"[{plat}] Flutter hiện tại {fv} khác lúc release {r['flutter']}.")

    check_source_rules(proj, rep)
    return rep.finish(args.strict)


# ---------------------------------------------------------------------------
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    c = sub.add_parser("check", help="trước shorebird release")
    c.add_argument("--patch-packages", nargs="*", default=DEFAULT_PATCH_PACKAGES,
                   help="package chỉ đưa vào qua patch (mặc định: app_package). Truyền rỗng nếu release có đủ.")
    c.add_argument("--platform", nargs="+", default=PLATFORMS, choices=PLATFORMS,
                   help="nền tảng cần kiểm (mặc định: android ios)")
    c.add_argument("--strict", action="store_true", help="WARN cũng tính là chặn")
    c.add_argument("--no-pub-get", action="store_true", help="không tự chạy flutter pub get khi lệch")
    c.add_argument("--offline", action="store_true", help="pub get --offline")
    c.set_defaults(fn=run_check)

    fx = sub.add_parser("fix", help="tự cấu hình native (ghim plugin, manifest, Info.plist) rồi check lại")
    fx.add_argument("--platform", nargs="+", default=PLATFORMS, choices=PLATFORMS)
    fx.add_argument("--patch-packages", nargs="*", default=DEFAULT_PATCH_PACKAGES)
    fx.add_argument("--dry-run", action="store_true", help="chỉ in thay đổi, không ghi")
    fx.add_argument("--no-pub-get", action="store_true", help="không tự chạy flutter pub get")
    fx.add_argument("--offline", action="store_true", help="chạy `pub get --offline` (không cần mạng)")
    fx.add_argument("--unpin", action="store_true",
                    help="bỏ ghim (trả constraint cũ, xoá managed block) để nâng version plugin")
    fx.add_argument("--release-mode", action="store_true",
                    help="ép ghim theo pubspec.lock kể cả khi version đã có manifest (chỉ dùng khi chắc chắn)")
    fx.add_argument("--strict", action="store_true")
    fx.set_defaults(fn=run_fix)

    s = sub.add_parser("snapshot", help="ngay sau shorebird release")
    s.add_argument("--platform", nargs="+", default=PLATFORMS, choices=PLATFORMS,
                   help="nền tảng vừa release (mặc định: android ios)")
    s.add_argument("--flags", default="", help='cờ đã truyền sau `--` cho shorebird release, viết --flags="..."')
    s.add_argument("--force", action="store_true")
    s.add_argument("--no-pub-get", action="store_true")
    s.add_argument("--offline", action="store_true")
    s.set_defaults(fn=run_snapshot)

    v = sub.add_parser("verify-patch", help="trước shorebird patch")
    v.add_argument("--release", help="version release đích (mặc định: version trong pubspec)")
    v.add_argument("--flags", default=None, help='cờ sẽ truyền cho shorebird patch, viết --flags="..."')
    v.add_argument("--platform", nargs="+", default=None, choices=PLATFORMS,
                   help="chỉ so nền tảng này (mặc định: mọi nền tảng có trong manifest)")
    v.add_argument("--strict", action="store_true")
    v.add_argument("--no-pub-get", action="store_true")
    v.add_argument("--offline", action="store_true")
    v.set_defaults(fn=run_verify_patch)

    args = ap.parse_args()
    try:
        return args.fn(args)
    except SystemExit as e:
        if isinstance(e.code, str):
            print(_c("FAIL", e.code))
            return 2
        raise


if __name__ == "__main__":
    sys.exit(main())

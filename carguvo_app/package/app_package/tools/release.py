#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/release.py - Tool release pre/prod/hotfix cho s88-flutter.
====================================================================
1. UP PRE (bản test cho QC)
   - Đang đứng ở NHÁNH NÀO CŨNG ĐƯỢC (tool tự checkout staging_v2 mới nhất).
   - KHÔNG cần commit trước: tree bẩn (ngoài tools/) thì tool FAIL, chạy lại
     với --stash để tool tự stash (có nhánh backup), xong tự pop về.
   - Bẩn trong tools/ (keyfile/pass mỗi dev) thì tự bỏ qua.
   - Mỗi lần pre là 1 version mới tăng đều (+8, +9, +10...) để tra changelog
     từng bản. QC fail -> dev tiếp -> chạy lại là có số mới, không đè bản cũ.
   VD:
     python3 tools/release.py --env pre -y
     python3 tools/release.py --env pre --version 1.0.2+8 --stash -y
   - Xong: nhánh release/<ver> đã push (CHƯA tag). QC pass bản nào thì prod
     đúng bản đó.

2. UP PROD (bản chính thức)
   - Đang đứng ở NHÁNH NÀO CŨNG ĐƯỢC (tool tự lấy release/<ver> mới nhất).
   - Không truyền --version = lấy ver lớn nhất. Muốn chốt bản cũ hơn thì
     truyền explicit: --version 1.0.1+9.
   VD:
     python3 tools/release.py --env prod -y
     python3 tools/release.py --env prod --version 1.0.1+10 -y
   - Tag tạo SAU khi upload, kèm hash resource (`default`) + hash dynamic
     (`dynamic`) trong proj_resources/version_resource_config.json do
     upload_resources.py sinh:
       v1.0.1+10-res.ca972611-dyn.a4ff8d66
     -> tra ngược được bản prod đó dùng bundle tài nguyên + dynamic nào.
   - Ver prod không cần đều nhau (+8, +10, +13...).

3. HOTFIX (lỗi prod, cần lên thẳng prod)
   - B1 (tay): checkout từ TAG prod mới nhất, vd:
       git checkout -b fix/nap-tien-loi v1.0.1+10
   - B2 (tay): sửa code trong IDE. KHÔNG CẦN commit trước, KHÔNG CẦN đụng
     pubspec.yaml — tool tự commit code fix + tự bump version.
     (Muốn chốt số thì sửa pubspec tay hoặc truyền --version.)
   - B3 (tool): đang đứng YÊN trên nhánh fix đó, chạy:
       python3 tools/release.py --env hotfix -y
   - Tool tự: CI bắt buộc (cấm --skip-ci) -> commit fix -> bump -> push nhánh
     -> upload --env prod -> tag v<ver>-res.<hash>-dyn.<dyn> -> cherry-pick
     fix về staging_v2 + push.
   - Cherry-pick conflict -> tool GIỮ NGUYÊN hiện trường ở staging_v2 cho bạn
     merge tay (không abort), prod thì đã lên xong, không ảnh hưởng.

CỜ CHUNG:
  --bump build|patch|minor|major (mặc định build: chỉ +build)
  --stash        cho phép auto-stash khi tree bẩn (mặc định FAIL)
  --skip-ci      bỏ CI local (pre/prod; hotfix CẤM skip)
  --full-ci      chạy cả make test-* như GitHub Actions
  --skip-upload  chỉ làm git, không đụng server
  -y             bỏ qua hỏi xác nhận
YÊU CẦU: file .env ở root repo phải có SSH_KEY_FILE trỏ tới key thật
  (xem .env.example). Git auth = SSH keyfile (xem .env.example — mục
  Git auth). Tắt `make serve/preview` (cổng 8091/8092/8093) trước.
"""
from __future__ import annotations
import argparse, datetime, os, re, socket, subprocess, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dotenv_local import load_dotenv  # noqa: E402
load_dotenv()

REPO_ROOT = Path(__file__).resolve().parent.parent
PUBSPEC = REPO_ROOT / "pubspec.yaml"
RES_CONFIG = REPO_ROOT / "proj_resources" / "version_resource_config.json"
PORTS = [8091, 8092, 8093]
# Bẩn trong các thư mục này thì BỎ QUA khi check tree (keyfile/preset SSH
# mỗi dev một khác, không bao giờ commit — vd tools/upload_jaspr.py,
# tools/upload_resources.py chứa ssh_key_file/pass nội bộ).
IGNORE_DIRTY_PREFIXES = ("tools/",)
VER_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)\+(\d+)$")
BR_RE = re.compile(r"release/(\d+\.\d+\.\d+\+\d+)")
# Tag prod: v<ver>[-res.<hash>][-dyn.<dyn_hash>]. 2 hash lấy từ `default` +
# `dynamic` trong proj_resources/version_resource_config.json — CHỈ biết được
# SAU khi upload_resources.py chạy (script này sinh lại file config đó).
TAGVER_RE = re.compile(r"^v(\d+\.\d+\.\d+\+\d+)(?:-res\.([0-9a-f]+))?(?:-dyn\.([0-9a-f]+))?$")

def run(cmd, cwd=None, check=True):
    # GIT_TERMINAL_PROMPT=0: nếu remote đòi credential (HTTPS không token) thì
    # git FAIL NGAY thay vì hi username/password rồi treo terminal.
    env = {**os.environ, "GIT_TERMINAL_PROMPT": "0", "GCM_INTERACTIVE": "never"}
    p = subprocess.run(cmd, cwd=str(cwd or REPO_ROOT), env=env,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    if check and p.returncode != 0:
        print(p.stdout, file=sys.stderr)
        sys.exit(f"[LỖI] lệnh thất bại: {' '.join(cmd)}")
    return p.stdout.strip()

def git(*a, check=True):
    return run(["git", *a], check=check)

def check_ports():
    busy = []
    for port in PORTS:
        s = socket.socket(); s.settimeout(0.3)
        try:
            if s.connect_ex(("127.0.0.1", port)) == 0:
                busy.append(port)
        finally:
            s.close()
    if busy:
        sys.exit(f"[LỖI] cổng {busy} đang bận (make serve/preview?). "
                 f"Tắt serve trước. KT: lsof -i :{', '.join(map(str, busy))}")
    print("  ✅ Cổng 8091/8092/8093 trống.")

def check_ssh_key():
    """Fail-fast trước khi làm git/upload: .env phải có SSH_KEY_FILE + file tồn tại."""
    key = os.getenv('SSH_KEY_FILE', '').strip()
    if not key:
        sys.exit("[LỖI] Thiếu SSH_KEY_FILE trong .env (xem .env.example) — "
                 "mỗi dev tự đặt key của mình, không commit key lên git.")
    kp = Path(key).expanduser()
    if not kp.exists():
        sys.exit(f"[LỖI] SSH key không tồn tại: {key} — kiểm tra SSH_KEY_FILE trong .env.")
    print(f"  ✅ SSH key: {key}")

def dirty_files() -> list[str]:
    """Danh sách file bẩn NGOÀI vùng bỏ qua (tools/)."""
    out = []
    for line in git("status", "--porcelain").splitlines():
        # 'XY <path>' — path bắt đầu từ cột 3; rename 'R  old -> new' lấy new.
        path = line[3:].strip()
        if " -> " in path:
            path = path.split(" -> ", 1)[1].strip()
        if any(path.startswith(p) for p in IGNORE_DIRTY_PREFIXES):
            continue
        out.append(line.strip())
    return out

def builder() -> str:
    """git user.name (+ email) của người đang chạy tool — gắn vào tag/message."""
    name = git("config", "user.name", check=False).strip() or "unknown"
    email = git("config", "user.email", check=False).strip()
    return f"{name} <{email}>" if email else name

def ensure_clean(allow_stash):
    real = dirty_files()
    if not real:
        ignored = git("status", "--porcelain").strip()
        if ignored:
            print("  ✅ OK (chỉ bẩn trong tools/ — bỏ qua theo quy ước keyfile mỗi dev).")
        else:
            print("  ✅ Working tree sạch.")
        return None
    print("  ⚠️ Tree bẩn (ngoài tools/):\n    " + "\n    ".join(real[:20]))
    if not allow_stash:
        sys.exit("[LỖI] Có file chưa commit (ngoài tools/). Commit trước hoặc chạy lại với --stash.")
    ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    bk = f"backup/release-tool-{ts}"
    cur = git("rev-parse", "--abbrev-ref", "HEAD")
    git("branch", bk)
    print(f"  📦 Đã tạo nhánh backup: {bk}")
    msg = f"release-tool auto-stash {ts} from {cur}"
    git("stash", "push", "-u", "-m", msg)
    print(f"  📦 Đã stash (-u): {msg}")
    return msg

def pop_stash(msg, orig):
    if not msg: return
    if msg not in git("stash", "list"):
        print("  ⚠️ Không thấy stash (đã pop tay?). Bỏ qua."); return
    print(f"  📤 Pop stash về {orig} ...")
    git("checkout", orig, check=False)
    p = subprocess.run(["git", "stash", "pop"], cwd=str(REPO_ROOT),
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print(p.stdout.strip())
    if p.returncode != 0:
        sys.exit("[LỖI] stash pop conflict. Stash VẪN GIỮ — tự resolve rồi pop tay.")
    print("  ✅ Đã pop stash.")

def read_ver():
    for ln in PUBSPEC.read_text(encoding="utf-8").splitlines():
        if ln.startswith("version:"):
            return ln.split(":", 1)[1].strip()
    sys.exit("[LỖI] Không đọc được version: trong pubspec.yaml")

def bump(ver, kind):
    m = VER_RE.match(ver)
    if not m: sys.exit(f"[LỖI] version '{ver}' sai dạng X.Y.Z+B")
    a, b, c, d = map(int, m.groups())
    if kind == "build": d += 1
    elif kind == "patch": c += 1; d += 1
    elif kind == "minor": b += 1; c = 0; d += 1
    elif kind == "major": a += 1; b = 0; c = 0; d += 1
    return f"{a}.{b}.{c}+{d}"

def write_ver(ver):
    t = PUBSPEC.read_text(encoding="utf-8")
    n, cnt = re.subn(r"^version:\s*.+$", f"version: {ver}", t, count=1, flags=re.M)
    if cnt != 1: sys.exit("[LỖI] Không bump được pubspec.yaml")
    PUBSPEC.write_text(n, encoding="utf-8")
    print(f"  ✅ pubspec -> {ver}")
def ver_key(v: str) -> tuple[int, int, int, int]:
    m = VER_RE.match(v)
    return tuple(map(int, m.groups())) if m else (0, 0, 0, 0)

def ver_to_str(t: tuple[int, int, int, int]) -> str:
    return f"{t[0]}.{t[1]}.{t[2]}+{t[3]}"

def latest_release_ver() -> str | None:
    """Version lớn nhất trong origin/release/* (local + remote). None nếu chưa có."""
    vers: set[str] = set(BR_RE.findall(git("branch", "--list", "release/*")))
    vers |= set(BR_RE.findall(git("branch", "-r", "--list", "origin/release/*")))
    return ver_to_str(max(ver_key(v) for v in vers)) if vers else None

def latest_release():
    v = latest_release_ver()
    if not v: sys.exit("[LỖI] Chưa có origin/release/* — chạy --env pre trước.")
    return f"release/{v}"

def next_pre_ver(base: str, bump_kind: str) -> str:
    """Mỗi lần pre là 1 version mới: max(staging, release mới nhất) + bump.
    QC fail -> dev tiếp -> pre lại -> +9, +10... đều đặn để tra changelog từng bản.
    --version explicit luôn thắng (dùng khi muốn chốt số)."""
    rel = latest_release_ver()
    start = base
    if rel and ver_key(rel) >= ver_key(base):
        start = rel
        print(f"  Pre trước đã tới {rel} — bump tiếp từ đó.")
    return bump(start, bump_kind)

def ci_check(full):
    print("\n--- CI local (timeout mỗi bước 10 phút, output stream trực tiếp) ---")
    t0 = __import__("time").time()

    def step(name, cmd, t=600):
        print(f"  ▶ {name}: {' '.join(cmd)}")
        import subprocess as sp, threading
        out_lines: list[str] = []
        p = sp.Popen(cmd, cwd=str(REPO_ROOT), stdout=sp.PIPE,
                     stderr=sp.STDOUT, text=True)
        assert p.stdout is not None
        def pump():
            for ln in p.stdout:
                print(f"    {ln}", end="", flush=True)
                out_lines.append(ln)
        th = threading.Thread(target=pump, daemon=True)
        th.start()
        try:
            rc = p.wait(timeout=t)
        except sp.TimeoutExpired:
            p.kill()
            th.join(timeout=5)
            sys.exit(f"[LỖI] CI treo quá {t//60} phút ở bước '{name}' — đã kill. "
                     f"Chạy tay để xem: {' '.join(cmd)}")
        th.join(timeout=10)
        dt = __import__("time").time() - t0
        if rc != 0:
            print("".join(out_lines[-30:]), file=sys.stderr)
            sys.exit(f"[LỖI] CI fail ở bước '{name}' (mất {dt:.0f}s). Fix rồi chạy lại tool.")
        print(f"  ✅ {name} ({dt:.0f}s)")

    step("layer guard", ["bash", "tools/check_package_layers.sh"], t=120)
    step("flutter analyze lib",
         ["flutter", "analyze", "lib", "--no-fatal-warnings", "--no-fatal-infos"], t=600)
    step("jaspr analyze lib",
         ["bash", "-c", "cd jaspr_web && dart pub get >/dev/null && dart analyze lib --no-fatal-warnings"], t=600)
    if full:
        step("make test-shared", ["make", "test-shared"], t=600)
        step("make test-shared-flutter", ["make", "test-shared-flutter"], t=600)
    else:
        print("  ⏭ Bỏ qua test (thêm --full-ci để chạy đủ)")
    print("--- CI XANH ✅ ---\n")

def latest_prod_tag() -> str | None:
    """Tag prod mới nhất dạng vX.Y.Z+B (bỏ qua hậu tố -res.<hash> nếu có)."""
    vers = []
    for t in git("tag", "--list", "v*").splitlines():
        m = TAGVER_RE.match(t.strip())
        if m:
            vers.append(m.group(1))
    return ver_to_str(max(ver_key(v) for v in vers)) if vers else None

def read_resource_ver(key: str = "default") -> str:
    """`default` (hash bundle tài nguyên) hoặc `dynamic` (hash bundle dynamic)
    trong proj_resources/version_resource_config.json. '' nếu file thiếu/sai
    (không chặn release)."""
    if not RES_CONFIG.is_file():
        return ""
    try:
        import json
        data = json.loads(RES_CONFIG.read_text(encoding="utf-8"))
        return str(data.get(key, "")).strip()
    except Exception:
        return ""

def latest_prod_res() -> tuple[str, str]:
    """(res, dyn) của tag prod mới nhất ('' với hash tag cũ chưa có hậu tố)."""
    for t in sorted(git("tag", "--list", "v*").splitlines(),
                    key=lambda x: ver_key(TAGVER_RE.match(x.strip()).group(1))  # type: ignore
                    if TAGVER_RE.match(x.strip()) else (0, 0, 0, 0), reverse=True):
        m = TAGVER_RE.match(t.strip())
        if m and (m.group(2) or m.group(3)):
            return (m.group(2) or "", m.group(3) or "")
    return ("", "")

def main():
    ap = argparse.ArgumentParser(description="Tool release pre/prod/hotfix")
    ap.add_argument("--env", required=True, choices=["pre", "prod", "hotfix"],
                    help="pre: staging->release mới; prod: tag+upload bản release; "
                         "hotfix: đang đứng trên nhánh fix từ tag prod, bump+tag+upload prod luôn")
    ap.add_argument("--version", default=None, help="X.Y.Z+B explicit")
    ap.add_argument("--bump", default="build", choices=["build", "patch", "minor", "major"])
    ap.add_argument("--stash", action="store_true")
    ap.add_argument("--skip-ci", action="store_true")
    ap.add_argument("--full-ci", action="store_true")
    ap.add_argument("--skip-upload", action="store_true")
    ap.add_argument("-y", "--yes", action="store_true")
    a = ap.parse_args()
    from setup_github_key import ensure_git_auth  # noqa: E402
    ensure_git_auth("release.py")  # chưa auth GitHub -> setup + exit 2
    orig = git("rev-parse", "--abbrev-ref", "HEAD")
    msg = None
    who = builder()
    try:
        print(f"===== RELEASE --env {a.env} (nhánh hiện tại: {orig}, by {who}) =====")
        msg = ensure_clean(a.stash)
        print("  🌐 git fetch --prune origin ...")
        try:
            git("fetch", "--prune", "origin")
            print("  ✅ Đã kết nối GitHub — origin đã đồng bộ.")
        except SystemExit:
            sys.exit("[LỖI] git fetch THẤT BẠI — không kết nối được GitHub. "
                     "Kiểm tra auth (make setup-github-key) hoặc mạng rồi chạy lại.")
        if a.env == "hotfix":
            # Bạn đã: checkout từ tag prod (vd v1.0.1+10) -> sửa code xong.
            # Tool KHÔNG checkout đi đâu cả, ở yên nhánh hiện tại của bạn.
            # Version = max(pubspec hiện tại, tag prod mới nhất) + bump.
            cur = read_ver()
            pt = latest_prod_tag()
            start = cur
            if pt and ver_key(pt) >= ver_key(cur):
                start = pt
                print(f"  Tag prod mới nhất: v{pt} — bump tiếp từ đó.")
            nv = a.version or bump(start, a.bump)
            if not VER_RE.match(nv):
                sys.exit("[LỖI] --version phải dạng X.Y.Z+B")
            print(f"  Hotfix trên nhánh {orig}: {cur} -> {nv} (upload thẳng prod)")
            cur_res, cur_dyn = latest_prod_res()
            if cur_res or cur_dyn:
                print(f"  Prod hiện tại: res={cur_res or 'n/a'} dyn={cur_dyn or 'n/a'}")
            br = f"release/{nv}"
        elif a.env == "pre":
            git("checkout", "staging_v2")
            git("pull", "--ff-only", "origin", "staging_v2")
            print("  ✅ Đã pull staging_v2 mới nhất.")
            base = read_ver()
            nv = a.version or next_pre_ver(base, a.bump)
            if a.version and not VER_RE.match(a.version):
                sys.exit("[LỖI] --version phải dạng X.Y.Z+B")
            if not a.version and nv in git("branch", "--list", f"release/{nv}"):
                # Hy hữu: nhánh đã có mà version tính ra trùng (vd base bị sửa tay).
                # Thay vì tái sử dụng (dễ nhầm bản), bump thêm 1 build cho ra số mới.
                nv = bump(nv, "build")
                print(f"  Nhánh release/{nv} đã tồn tại — bump thêm thành {nv}.")
            print(f"  Ver: {base} -> {nv}")
        else:
            rel = latest_release() if not a.version else f"release/{a.version}"
            print(f"  Nhánh release: {rel}")
            git("checkout", rel)
            git("pull", "--ff-only", "origin", rel)
            print(f"  ✅ Đã pull {rel} mới nhất.")
            m = BR_RE.search(rel)
            nv = a.version or (m.group(1) if m else read_ver())
            print(f"  Ver prod: {nv}")
        print("\n--- Check SSH key + cổng ---")
        check_ssh_key()
        check_ports()
        if not a.skip_ci:
            ci_check(full=(a.full_ci or a.env in ("pre", "hotfix")))
        else:
            if a.env == "hotfix":
                sys.exit("[LỖI] hotfix KHÔNG được --skip-ci — bản lên thẳng prod, phải check tối thiểu.")
            print("  ⏭ Bỏ qua CI (--skip-ci)")
        if not a.yes:
            if input(f"\nTiếp tục {a.env} {nv}? [y/N]: ").strip().lower() != "y":
                sys.exit("Đã hủy.")
        br = f"release/{nv}"
        if a.env == "hotfix":
            # Commit fix của bạn (nếu chưa commit) + commit bump version.
            if dirty_files():
                git("add", "-A")
                git("commit", "-m", f"fix(hotfix): {nv} by {who}")
                print(f"  ✅ Đã commit code fix của bạn.")
            if read_ver() != nv:
                write_ver(nv)
                git("add", "pubspec.yaml")
                git("commit", "-m", f"chore(hotfix): bump {nv} by {who}")
            git("push", "-u", "origin", f"HEAD:{br}")
            print(f"  ✅ Đã push nhánh {br} (tag tạo sau khi upload — cần hash resource)")
        elif a.env == "pre":
            # Mỗi lần pre là 1 nhánh mới (QC fail -> pre lại -> +9, +10...).
            # Break giữa chừng rồi chạy lại: fail ở bước upload nhưng cùng version
            # và nhánh local đã có mà REMOTE CHƯA CÓ -> tái sử dụng để upload tiếp.
            # Đã push remote rồi mà chạy lại cùng version -> DỪNG, không đè.
            local_has = br in git("branch", "--list", br)
            remote_has = f"origin/{br}" in git("branch", "-r", "--list", f"origin/{br}")
            if local_has and not remote_has:
                print(f"  ♻️ Nhánh {br} mới có local (lần trước break trước khi push) — tái sử dụng để upload tiếp.")
                git("checkout", br)
            else:
                if remote_has:
                    sys.exit(f"[LỖI] origin/{br} đã tồn tại (bản pre này đã lên server). "
                             f"Muốn pre bản mới thì chạy lại để tool tự bump lên số tiếp theo, "
                             f"không đè lên bản đã phát hành.")
                git("checkout", "-b", br)
                write_ver(nv)
                git("add", "pubspec.yaml")
                git("commit", "-m", f"chore(release): bump {nv} for pre by {who}")
            print(f"  ✅ {br} tại commit {git('rev-parse', '--short', 'HEAD')} (CHƯA push/tag)")
        else:
            git("push", "origin", f"{br}:{br}")
            print(f"  ✅ Đã push nhánh {br} (tag tạo sau khi upload — cần hash resource)")
        upload_env = "prod" if a.env in ("prod", "hotfix") else a.env
        if not a.skip_upload:
            print(f"\n--- Upload resource --env {upload_env} ---")
            run([sys.executable, "tools/upload_resources.py", "--env", upload_env])
            print(f"\n--- Upload jaspr --env {upload_env} ---")
            run([sys.executable, "tools/upload_jaspr.py", "--env", upload_env, "-y"])
        else:
            print("  ⏭ Bỏ qua upload (--skip-upload)")
        # Tag SAU upload: tag kèm hash resource (`default`) + hash dynamic
        # (`dynamic`) trong version_resource_config.json mà upload_resources.py
        # vừa sinh lại. VD tag: v1.0.1+8-res.ca972611-dyn.a4ff8d66
        if a.env in ("prod", "hotfix"):
            res = read_resource_ver()
            dyn = read_resource_ver("dynamic")
            tag = f"v{nv}" + (f"-res.{res}" if res else "") + (f"-dyn.{dyn}" if dyn else "")
            if tag in git("tag", "--list", tag):
                print(f"  ♻️ Tag {tag} đã có — tái sử dụng.")
            else:
                kind = "Hotfix" if a.env == "hotfix" else "Release"
                extra = f" from {orig}" if a.env == "hotfix" else ""
                msg = f"{kind} {nv} (prod) res={res or 'n/a'} dyn={dyn or 'n/a'} by {who}{extra}"
                git("tag", "-a", tag, "-m", msg)
                git("push", "origin", tag)
                print(f"  ✅ Đã tạo+push tag {tag} (by {who})")
            if not res:
                print("  ⚠️ Không đọc được resource hash — tag thiếu hậu tố -res.<hash>.")
            if not dyn:
                print("  ⚠️ Không đọc được dynamic hash — tag thiếu hậu tố -dyn.<hash>.")
        # Push nhánh CHỈ SAU KHI UPLOAD XONG (pre) — thứ tự cũ push trước
        # upload nên break giữa chừng là remote đã có nhánh "chết" (có nhánh
        # mà không có bản trên server). Push muộn thì remote luôn = đã có bản.
        if a.env == "pre":
            git("push", "-u", "origin", br)
            print(f"  ✅ Đã push {br} (CHƯA tag — tag khi prod, by {who})")
        print(f"\n🎉 XONG {a.env} {nv}")
        if a.env == "pre":
            res = read_resource_ver()
            dyn = read_resource_ver("dynamic")
            if res:
                print(f"  Resource hash bản pre này: {res}")
            if dyn:
                print(f"  Dynamic bundle hash: {dyn}")
            print(f"  QC ok thì chạy: python3 tools/release.py --env prod -y")
        elif a.env == "hotfix":
            # Tự cherry-pick commit FIX (không lấy commit bump) về staging_v2.
            # Tool đã ở commit bump (HEAD), commit fix là HEAD~1 (nếu tool vừa
            # commit cả 2) hoặc HEAD (nếu pubspec bạn bump tay từ trước).
            log = git("log", "--format=%H %s", "-2")
            lines = log.splitlines()
            fix_full = None
            for ln in lines:
                if ln.split(" ", 1)[1].startswith("fix(hotfix):"):
                    fix_full = ln.split(" ", 1)[0]
                    break
            if fix_full is None and lines:
                # Không tìm thấy commit fix riêng (bạn gộp fix+pubspec chung 1
                # commit) -> cherry-pick HEAD nhưng trừ pubspec ra sau.
                fix_full = lines[0].split(" ", 1)[0]
                print(f"  ⚠️ Không tách được commit fix riêng — cherry-pick {fix_full[:7]} rồi bỏ pubspec.")
            fix_short = fix_full[:7]
            print(f"\n--- Cherry-pick fix {fix_short} về staging_v2 ---")
            git("checkout", "staging_v2")
            git("pull", "--ff-only", "origin", "staging_v2")
            print("  ✅ Đã pull staging_v2 mới nhất.")
            p = subprocess.run(["git", "cherry-pick", fix_full], cwd=str(REPO_ROOT),
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            print(p.stdout.strip())
            if p.returncode != 0:
                # GIỮ NGUYÊN trạng thái conflict cho bạn merge tay — KHÔNG abort.
                # Tool dừng ở đây (staging_v2 đang dở cherry-pick), prod thì đã
                # xong từ trước nên không ảnh hưởng. Bạn resolve xong thì:
                #   git add <file> && git cherry-pick --continue && git push
                print(f"  ⚠️ Cherry-pick CONFLICT — GIỮ NGUYÊN để bạn merge tay.")
                print(f"     Đang ở staging_v2, file conflict có marker <<<<<<<.")
                print(f"     Xong thì: git add <file> && git cherry-pick --continue && git push")
                print(f"     Bỏ thì: git cherry-pick --abort")
                sys.exit(2)
            else:
                # Commit bump đi kèm? -> trả pubspec về version của staging.
                if read_ver() != git("show", "origin/staging_v2:pubspec.yaml").split("version:")[1].split()[0].strip():
                    pass  # version trên staging cứ giữ nguyên theo quy ước
                if "pubspec.yaml" in git("show", "--name-only", "--format=", fix_full):
                    git("checkout", "origin/staging_v2", "--", "pubspec.yaml")
                    git("commit", "--amend", "--no-edit")
                    print(f"  ✅ Đã loại pubspec.yaml khỏi commit cherry-pick (staging giữ version gốc).")
                git("push", "origin", "staging_v2")
                print(f"  ✅ Đã cherry-pick {fix_short} về staging_v2 + push.")
    finally:
        # Nếu đang dở cherry-pick conflict (hotfix giữ lại cho bạn merge tay)
        # thì KHÔNG pop stash / KHÔNG checkout đi đâu — để nguyên hiện trường.
        mid = REPO_ROOT / ".git" / "CHERRY_PICK_HEAD"
        if mid.exists():
            print("  ⏸ Đang dở cherry-pick — giữ nguyên nhánh + stash để bạn resolve.")
            return
        try: pop_stash(msg, orig)
        except SystemExit as e: print(e)

if __name__ == "__main__":
    main()


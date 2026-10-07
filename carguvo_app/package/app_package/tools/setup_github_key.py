#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
setup_github_key.py — Setup SSH keyfile cho git GitHub, 1 lệnh cho dev mới.

Tool tự làm hết:
  1. Sinh key ed25519 ~/.ssh/github_s88 (KHÔNG passphrase) nếu chưa có —
     có rồi thì dùng lại, pub thiếu thì sinh lại từ private.
  2. ~/.ssh/config: đã có block `Host github.com` -> SỬA IdentityFile/
     IdentitiesOnly cho chuẩn; chưa có -> TỰ THÊM block. Luôn backup
     config ra config.bak.<thời-gian> trước khi ghi.
  3. In PUBLIC KEY ra màn hình + hướng dẫn từng bước add lên GitHub.
  4. Test `ssh -T git@github.com` — auth được là báo account.
  5. Auth OK mà origin đang HTTPS -> tự đổi remote sang SSH + chạy
     `git fetch --tags` xác nhận.

Chạy:
  python3 tools/setup_github_key.py      # hoặc: make setup-github-key
Exit code: 0 = auth OK, sẵn sàng; 2 = đã setup máy, CHỜ bạn add key lên
GitHub rồi chạy lại (bước 3-5 trong hướng dẫn in ra).
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

SSH_DIR = Path.home() / ".ssh"
KEY_PATH = SSH_DIR / "github_s88"
PUB_PATH = Path(str(KEY_PATH) + ".pub")
KEY_COMMENT = "s88-git"
CONFIG = SSH_DIR / "config"
GITHUB_HOST = "github.com"
IDENT = f"~/.ssh/{KEY_PATH.name}"
REPO_GH = "G1-production/s88-flutter"


def run(cmd: list[str], timeout: int = 30) -> tuple[int, str]:
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, f"quá {timeout}s"


def ensure_key() -> str:
    """Sinh key nếu chưa có; trả về PUBLIC KEY (text 1 dòng)."""
    if KEY_PATH.exists() and PUB_PATH.exists():
        print(f"1) ✅ Key đã có, dùng lại: {KEY_PATH}")
        return PUB_PATH.read_text().strip()
    SSH_DIR.mkdir(mode=0o700, exist_ok=True)
    if KEY_PATH.exists() and not PUB_PATH.exists():
        # Private có, pub mất -> sinh lại pub từ private
        rc, out = run(["ssh-keygen", "-y", "-f", str(KEY_PATH)])
        if rc != 0:
            sys.exit(f"[LỖI] Không sinh lại pub từ private:\n{out.strip()}")
        PUB_PATH.write_text(out.strip() + f" {KEY_COMMENT}\n")
        os.chmod(PUB_PATH, 0o644)
        print(f"1) ✅ Pub key thiếu — đã sinh lại từ private: {PUB_PATH}")
        return PUB_PATH.read_text().strip()
    rc, out = run(["ssh-keygen", "-t", "ed25519", "-N", "",
                   "-C", KEY_COMMENT, "-f", str(KEY_PATH)])
    if rc != 0:
        sys.exit(f"[LỖI] ssh-keygen thất bại:\n{out.strip()}")
    os.chmod(KEY_PATH, 0o600)
    os.chmod(PUB_PATH, 0o644)
    print(f"1) 🔑 Đã sinh key mới (không passphrase): {KEY_PATH}")
    return PUB_PATH.read_text().strip()


def _backup_config() -> None:
    """Backup ~/.ssh/config kề bên trước khi sửa."""
    if CONFIG.exists():
        bak = CONFIG.with_name("config.bak." + datetime.now().strftime("%Y%m%d-%H%M%S"))
        shutil.copy2(CONFIG, bak)
        print(f"   💾 Backup config -> {bak.name}")


def ensure_config() -> None:
    """Có block Host github.com -> sửa cho chuẩn; chưa có -> tự thêm."""
    SSH_DIR.mkdir(mode=0o700, exist_ok=True)
    lines = CONFIG.read_text().splitlines() if CONFIG.exists() else []
    idxs = [i for i, l in enumerate(lines)
            if re.match(r"^\s*Host\b", l, re.I) and GITHUB_HOST in l.split()]
    if not idxs:
        block = ["", f"Host {GITHUB_HOST}", f"    HostName {GITHUB_HOST}",
                 "    User git", f"    IdentityFile {IDENT}",
                 "    IdentitiesOnly yes"] if lines else [
                 f"Host {GITHUB_HOST}", f"    HostName {GITHUB_HOST}",
                 "    User git", f"    IdentityFile {IDENT}",
                 "    IdentitiesOnly yes"]
        _backup_config()
        CONFIG.write_text("\n".join(lines + block) + "\n")
        os.chmod(CONFIG, 0o600)
        print(f"2) ✅ {CONFIG}: đã THÊM block Host github.com.")
        return
    i = idxs[0]
    j = next((k for k in range(i + 1, len(lines))
              if re.match(r"^\s*Host\b", lines[k], re.I)), len(lines))
    block = lines[i:j]
    changed: list[str] = []

    def set_opt(name: str, value: str) -> None:
        for bi, bl in enumerate(block):
            if re.match(rf"^\s*{name}\b", bl, re.I):
                val = bl.split(None, 1)[1].strip() if len(bl.split(None, 1)) > 1 else ""
                if val != value:
                    indent = bl[: len(bl) - len(bl.lstrip())]
                    block[bi] = f"{indent}{name} {value}"
                    changed.append(name)
                return
        block.append(f"    {name} {value}")
        changed.append(name)

    set_opt("IdentityFile", IDENT)
    set_opt("IdentitiesOnly", "yes")
    if not changed:
        print(f"2) ✅ {CONFIG}: block Host github.com đã chuẩn, không đổi.")
        return
    _backup_config()
    lines[i:j] = block
    CONFIG.write_text("\n".join(lines) + "\n")
    os.chmod(CONFIG, 0o600)
    print(f"2) ✅ {CONFIG}: đã SỬA block Host github.com ({', '.join(changed)}).")


def print_pub_and_guide(pub: str) -> None:
    line = "=" * 74
    print(f"\n{line}")
    print("3) 📋 PUBLIC KEY — copy NGUYÊN dòng dưới (1 dòng duy nhất):")
    print("-" * 74)
    print(pub)
    print("-" * 74)
    print("HƯỚNG DẪN add key vào GitHub (đăng nhập git) — làm 1 lần:")
    print(f"  1. Đăng nhập github.com bằng account CÓ QUYỀN repo {REPO_GH}")
    print("     (account khác sẽ không thấy repo — đổi account trước khi add!)")
    print("  2. Mở: https://github.com/settings/ssh/new")
    print("     (hoặc: Settings > SSH and GPG keys > New SSH key)")
    print("  3. Title: `s88-git @<tên máy>`, Key type: Authentication Key")
    print("  4. Paste key vào ô Key > bấm Add SSH key")
    print("  5. Chạy lại tool này để xác nhận: python3 tools/setup_github_key.py")
    print("  Sau đó fetch/push/tag tự động bằng keyfile — không hỏi pass, không")
    print("  cần VS Code/PAT, chạy được ở mọi terminal và CI.")
    print(f"{line}\n")


def git_auth_ok() -> bool:
    """Check nhanh (BatchMode, ~vài giây): GitHub đã nhận key chưa."""
    rc, out = run(["ssh", "-T", f"git@{GITHUB_HOST}", "-o", "BatchMode=yes",
                   "-o", "ConnectTimeout=8",
                   "-o", "StrictHostKeyChecking=accept-new"], timeout=25)
    return bool(re.search(r"Hi [\w.-]+!", out))


def ensure_git_auth(tool: str = "tool") -> None:
    """Hàm dùng chung: release.py / clear_resources.py gọi ĐẦU TIÊN trong main.

    Auth OK -> return, tool chạy tiếp bình thường.
    Chưa OK -> chạy setup (sinh key nếu thiếu, sửa config, in PUBLIC KEY +
    hướng dẫn add lên GitHub) rồi EXIT 2 — dev add key xong chạy lại lệnh gốc.
    """
    if git_auth_ok():
        print("  ✅ Git auth: SSH key đã được GitHub nhận.")
        return
    print("  ⏳ Git auth CHƯA OK (GitHub chưa nhận key) — chạy setup...\n")
    pub = ensure_key()
    ensure_config()
    print_pub_and_guide(pub)
    print(f"=> Add key xong, chạy lại: python3 tools/{tool}")
    sys.exit(2)


def test_auth() -> str | None:
    """ssh -T git@github.com -> tên account nếu GitHub đã nhận key."""
    rc, out = run(["ssh", "-T", f"git@{GITHUB_HOST}", "-o", "BatchMode=yes",
                   "-o", "ConnectTimeout=8",
                   "-o", "StrictHostKeyChecking=accept-new"], timeout=25)
    m = re.search(r"Hi ([\w.-]+)!", out)
    if m:
        print(f"4) ✅ GitHub xác nhận key — đăng nhập là account '{m.group(1)}'")
        return m.group(1)
    if rc == 124:
        print("4) ⚠️ Không kết nối được github.com:22 (mạng/firewall?) — thử lại sau.")
        return None
    print("4) ⏳ GitHub CHƯA nhận key (Permission denied) — bình thường nếu bạn")
    print("   chưa add public key ở bước 3. Xong rồi CHẠY LẠI tool này.")
    return None


def fix_remote_and_fetch() -> None:
    """origin đang HTTPS của repo này -> đổi sang SSH; rồi fetch xác nhận."""
    rc, url = run(["git", "remote", "get-url", "origin"])
    url = (url or "").strip()
    if rc != 0 or not url:
        print("5) ℹ️ Không đọc được origin — bỏ qua.")
        return
    ssh_url = f"git@{GITHUB_HOST}:{REPO_GH}.git"
    if re.fullmatch(rf"https://(?:[^/@]+@)?{re.escape(GITHUB_HOST)}/{re.escape(REPO_GH)}\.git", url):
        run(["git", "remote", "set-url", "origin", ssh_url])
        print(f"5) 🔀 origin: HTTPS -> SSH ({ssh_url})")
    elif url.startswith(f"git@{GITHUB_HOST}:"):
        print(f"5) ✅ origin đã là SSH: {url}")
    else:
        print(f"5) ℹ️ origin trỏ tới {url} — tool không đụng vào.")
    rc, out = run(["git", "fetch", "--tags", "--prune", "origin"], timeout=90)
    if rc == 0:
        print("   ✅ git fetch --tags OK — sẵn sàng: fetch/push/tag tự động bằng keyfile.")
    else:
        last = out.strip().splitlines()[-1][:180] if out.strip() else "không có chi tiết"
        print(f"   ⚠️ git fetch chưa qua được (account thiếu quyền repo?): {last}")


def main() -> None:
    print("===== SETUP GITHUB SSH KEYFILE =====")
    pub = ensure_key()
    ensure_config()
    print_pub_and_guide(pub)
    if test_auth():
        fix_remote_and_fetch()
        sys.exit(0)
    print("=> Trạng thái: máy đã setup xong, chờ bạn add key lên GitHub rồi chạy lại.")
    sys.exit(2)


if __name__ == "__main__":
    main()


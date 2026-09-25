#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Hash jaspr build assets voi content hash cho cache-busting.

Flow:
1. Hash + rename cac file (main.css, styles.css, vendor/rive.js,
   vendor/rive_boot.js, main.client.dart.js) -> <name>.<hash>.<ext>
2. Luu hash noi dung + ten file da rename vao version.json
3. Cap nhat index.html: loai bo the <link>/<script> asset cu,
   chi giu lai <script defer src="index.js"></script>

Luu y: index.js la file TINH nam trong jaspr_web/web/index.js (duoc jaspr
copy sang build/jaspr/ cung cac file web khac). index.js chay tai runtime:
fetch ./version.json -> load tung asset da hash theo dung thu tu.
Script nay KHONG sinh index.js.

Usage:
    python tools/deploy_jaspr_version.py
    python tools/deploy_jaspr_version.py --dir jaspr_web/build/jaspr
"""

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path


# Cac file can hash + rename moi lan build.
# Key: ten file goc (tuong doi voi build_dir), Value: template ten moi.
FILES_TO_RENAME = {
    'main.css': 'main.{hash}.css',
    'styles.css': 'styles.{hash}.css',
    'vendor/rive.js': 'vendor/rive.{hash}.js',
    'vendor/rive_boot.js': 'vendor/rive_boot.{hash}.js',
    'main.client.dart.js': 'main.client.{hash}.dart.js',
}


def hash_file(filepath: str) -> str:
    """Hash noi dung file bang SHA256, tra ve 12 ky tu dau."""
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            sha256.update(chunk)
    return sha256.hexdigest()[:12]


def rename_file(build_dir: str, old_name: str, new_template: str) -> str:
    """
    Rename file: <old_name> -> <new_template> thay {hash} bang hash thuc te.
    Tra ve ten file moi.
    """
    old_path = os.path.join(build_dir, old_name)
    if not os.path.isfile(old_path):
        # File goc vang mat: co the build da bi hash o lan chay truoc. Dung lai
        # ban da hash thay vi tra ten goc (khong ton tai tren dia -> 404).
        reused = find_hashed_file(build_dir, old_name, new_template)
        if reused:
            print(f"  [=] {old_name} -> {reused}  (dung ban da hash tu lan truoc)")
            return reused
        print(f"  [!] Khong tim thay: {old_name}", file=sys.stderr)
        return old_name

    # Hash noi dung
    file_hash = hash_file(old_path)
    new_name = new_template.replace('{hash}', file_hash)
    new_path = os.path.join(build_dir, new_name)

    # Neu file da ton tai (cung hash) -> skip
    if os.path.isfile(new_path):
        print(f"  [-] {old_name} -> {new_name} (da ton tai)")
        # Xoa file cu neu khac ten
        if old_path != new_path:
            os.remove(old_path)
        return new_name

    # Rename
    os.rename(old_path, new_path)
    print(f"  [+] {old_name} -> {new_name}  (hash={file_hash})")
    return new_name


def extract_hash(new_name: str, old_name: str) -> str:
    """
    Trich xuat hash tu ten file da rename.
    Vi du: old='main.css', new='main.abc123def456.css' -> 'abc123def456'.
    """
    stem, dot, ext = old_name.rpartition('.')
    if not dot or not new_name.endswith('.' + ext):
        return ''
    prefix = stem + '.'
    if new_name.startswith(prefix):
        return new_name[len(prefix):-(len('.' + ext))]
    return ''

def find_hashed_file(build_dir: str, old_name: str, new_template: str) -> str:
    """
    Tim file da hash tu lan chay truoc, khop template <name>.{hash}.<ext> trong
    cung thu muc voi old_name. Tra ve duong dan tuong doi voi build_dir, hoac ''.

    Can thiet cho truong hop chay tool 2 lan tren cung build (vd deploy
    --skip-build sau --build-only): file goc da bi rename o lan truoc, khong
    duoc tra ten goc ve version.json vi file do khong con ton tai (-> 404).
    """
    if '{hash}' not in new_template:
        return ''
    directory = os.path.dirname(os.path.join(build_dir, old_name))
    base = os.path.basename(new_template)
    pattern = re.compile(
        '^' + re.escape(base).replace(re.escape('{hash}'), '[0-9a-f]{12}') + '$'
    )
    try:
        entries = sorted(os.listdir(directory))
    except OSError:
        return ''
    for entry in entries:
        if pattern.match(entry) and os.path.isfile(os.path.join(directory, entry)):
            return os.path.relpath(os.path.join(directory, entry), build_dir)
    return ''


def create_version_json(build_dir: str, renamed_files: dict) -> str:
    """
    Luu hash noi dung + ten file da rename vao version.json:
        {
          "main.css":            {"hash": "...", "file": "main.xxx.css"},
          "styles.css":          {"hash": "...", "file": "styles.xxx.css"},
          "vendor/rive.js":      {"hash": "...", "file": "vendor/rive.xxx.js"},
          "vendor/rive_boot.js": {"hash": "...", "file": "vendor/rive_boot.xxx.js"},
          "main.client.dart.js": {"hash": "...", "file": "main.client.xxx.dart.js"}
        }
    Tra ve path den file version.json.
    """
    version_info = {}
    for old_name, new_name in renamed_files.items():
        old_path = os.path.join(build_dir, old_name)
        new_path = os.path.join(build_dir, new_name)
        if old_name != new_name and os.path.isfile(new_path):
            file_hash = extract_hash(new_name, old_name) or hash_file(new_path)
        else:
            # File khong doi ten (khong co hash) -> hash noi dung truc tiep
            file_hash = hash_file(old_path) if os.path.isfile(old_path) else ''
        version_info[old_name] = {
            'hash': file_hash,
            'file': new_name,
        }

    version_json_path = os.path.join(build_dir, 'version.json')
    with open(version_json_path, 'w', encoding='utf-8') as f:
        json.dump(version_info, f, indent=2, ensure_ascii=False)

    print(f"  [*] Da tao version.json ({len(version_info)} files)")
    return version_json_path

def update_index_html(build_dir: str) -> str:
    """
    Cap nhat index.html: loai bo cac the <link>/<script> asset noi bo,
    chi giu lai <script defer src="index.js"></script> truoc </head>.
    index.js (file tinh trong web/) load cac asset da hash qua version.json.
    """
    index_html_path = os.path.join(build_dir, 'index.html')
    if not os.path.isfile(index_html_path):
        print("  [!] Khong tim thay: index.html", file=sys.stderr)
        return index_html_path

    with open(index_html_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Xoa cac the load asset noi bo (da dc index.js xu ly).
    # Giu nguyen: Google Fonts <link>, favicon, preload anh, inline <style>.
    patterns = [
        r'<link rel="stylesheet" href="main\.css">\s*\n?',
        r'<link rel="stylesheet" href="styles\.css">\s*\n?',
        r'<script defer src="/vendor/rive\.js"></script>\s*\n?',
        r'<script defer src="/vendor/rive_boot\.js"></script>\s*\n?',
        r'<script defer src="main\.client\.dart\.js"></script>\s*\n?',
    ]
    for pat in patterns:
        content = re.sub(pat, '', content)

    # Them index.js truoc </head>.
    if 'index.js' not in content:
        content = content.replace(
            '</head>',
            '    <script defer src="index.js"></script>\n    </head>'
        )

    with open(index_html_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("  [*] Da cap nhat index.html (chi load index.js)")
    return index_html_path


def main():
    parser = argparse.ArgumentParser(
        description='Hash jaspr build assets voi content hash'
    )
    parser.add_argument(
        '--dir',
        default='jaspr_web/build/jaspr',
        help='Build directory (default: jaspr_web/build/jaspr)'
    )
    args = parser.parse_args()

    build_dir = args.dir

    if not os.path.isdir(build_dir):
        print(f"Error: Directory not found: {build_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"=== Hash jaspr assets in: {build_dir} ===")

    # Step 1: Hash + rename cac file (main.css, styles.css, vendor/*, main.client)
    renamed = {}
    for old_name, new_template in FILES_TO_RENAME.items():
        new_name = rename_file(build_dir, old_name, new_template)
        renamed[old_name] = new_name

    # Step 2: Tao version.json (hash noi dung + ten file da hash)
    create_version_json(build_dir, renamed)

    # Step 3: Cap nhat index.html chi load index.js
    update_index_html(build_dir)

    print(f"\n=== Hoan thanh ===")
    hashed_count = sum(1 for o, n in renamed.items() if o != n)
    print(f"  Files da rename: {len(renamed)} ({hashed_count} co hash)")


if __name__ == '__main__':
    main()

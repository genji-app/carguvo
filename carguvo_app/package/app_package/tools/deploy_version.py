#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rename build/web/ assets with content hash for cache-busting.

Flow:
1. Hash noi dung cac file chinh (main.dart.js, main.dart.mjs, main.dart.wasm,
   flutter_service_worker.js)
2. Rename: <name>.<ext> -> <name>.<hash_prefix>.<ext>
3. Update flutter_bootstrap.js: sua path den cac file da rename
4. Hash flutter_bootstrap.js (da sua) -> rename luon
5. Xoa file cu (da co ban moi)

Usage:
    python tools/deploy_version.py
    python tools/deploy_version.py --dir path/to/build/web
"""

import argparse
import hashlib
import json
import os
import re
import sys
import shutil
from pathlib import Path


# Cac file can hash + rename moi lan build
# Key: ten file goc, Value: ten file sau khi rename (dung {hash} lam placeholder)
FILES_TO_RENAME = {
    'main.dart.js': 'main.{hash}.dart.js',
    'main.dart.mjs': 'main.{hash}.dart.mjs',
    'main.dart.wasm': 'main.{hash}.dart.wasm',
    'flutter_service_worker.js': 'flutter_service_worker.{hash}.js',
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


def update_flutter_bootstrap(build_dir: str, renamed_files: dict) -> str:
    """
    Update flutter_bootstrap.js:
    - Sua mainWasmPath, jsSupportRuntimePath, mainJsPath thanh ten file da rename
    - Xoa serviceWorkerVersion parameter

    Tra ve path den file flutter_bootstrap.js da sua.
    """
    bootstrap_path = os.path.join(build_dir, 'flutter_bootstrap.js')
    if not os.path.isfile(bootstrap_path):
        print(f"  [!] Khong tim thay: flutter_bootstrap.js", file=sys.stderr)
        return bootstrap_path

    with open(bootstrap_path, 'r') as f:
        content = f.read()

    # Update path trong buildConfig
    path_mapping = {
        'mainJsPath': 'main.dart.js',
        'mainWasmPath': 'main.dart.wasm',
        'jsSupportRuntimePath': 'main.dart.mjs',
    }

    for key, old_file in path_mapping.items():
        if old_file in renamed_files:
            new_file = renamed_files[old_file]
            # Sua "mainJsPath":"main.dart.js" -> "mainJsPath":"main.abc.dart.js"
            content = content.replace(f'"{key}":"{old_file}"', f'"{key}":"{new_file}"')

    # Update serviceWorkerSettings: serviceWorkerVersion -> ten file da rename
    # Khong xoa ma update URL de service worker moi duoc register dung ten
    if 'flutter_service_worker.js' in renamed_files:
        new_sw_file = renamed_files['flutter_service_worker.js']
        # Sua serviceWorkerVersion thanh ten file moi
        content = re.sub(
            r'"serviceWorkerVersion":"[^"]*"',
            f'"serviceWorkerUrl":"{new_sw_file}","serviceWorkerVersion":"ignored"',
            content
        )

    with open(bootstrap_path, 'w') as f:
        f.write(content)

    print(f"  [*] Da update flutter_bootstrap.js paths")
    return bootstrap_path


def hash_and_rename_bootstrap(build_dir: str) -> str:
    """
    Hash flutter_bootstrap.js (da sua) va rename.
    Tra ve ten file bootstrap moi.
    """
    old_name = 'flutter_bootstrap.js'
    old_path = os.path.join(build_dir, old_name)
    if not os.path.isfile(old_path):
        return old_name

    file_hash = hash_file(old_path)
    new_name = f'flutter_bootstrap.{file_hash}.js'
    new_path = os.path.join(build_dir, new_name)

    if os.path.isfile(new_path):
        print(f"  [-] {old_name} -> {new_name} (da ton tai)")
        if old_path != new_path:
            os.remove(old_path)
        return new_name

    os.rename(old_path, new_path)
    print(f"  [+] {old_name} -> {new_name}  (hash={file_hash})")
    return new_name


def main():
    parser = argparse.ArgumentParser(
        description='Rename build/web/ assets with content hash'
    )
    parser.add_argument(
        '--dir',
        default='build/web',
        help='Build directory (default: build/web)'
    )
    parser.add_argument(
        '--bootstrap-name',
        default=None,
        help='Output bootstrap filename (default: auto from hash)'
    )
    args = parser.parse_args()

    build_dir = args.dir

    if not os.path.isdir(build_dir):
        print(f"Error: Directory not found: {build_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"=== Rename assets in: {build_dir} ===")

    # Step 1: Rename cac file chinh (main.dart.js, .mjs, .wasm, service_worker)
    renamed = {}
    for old_name, new_template in FILES_TO_RENAME.items():
        new_name = rename_file(build_dir, old_name, new_template)
        renamed[old_name] = new_name

    # Step 2: Update flutter_bootstrap.js paths
    update_flutter_bootstrap(build_dir, renamed)

    # Step 3: Hash + rename flutter_bootstrap.js
    bootstrap_name = hash_and_rename_bootstrap(build_dir)

    # Step 4: Tao file index.asset.json de index.js biet bootstrap name
    # Va danh sach file da rename (cho service worker unregister)
    asset_info = {
        'bootstrap': bootstrap_name,
        'renamed': list(renamed.values()),
    }
    asset_info_path = os.path.join(build_dir, 'asset_info.json')
    with open(asset_info_path, 'w') as f:
        json.dump(asset_info, f)

    print(f"\n=== Hoan thanh ===")
    print(f"  Bootstrap file: {bootstrap_name}")
    print(f"  Asset info: asset_info.json")
    print(f"  Files da rename: {len(renamed)}")


if __name__ == '__main__':
    main()
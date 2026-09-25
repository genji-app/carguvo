#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script upload web build lên server qua SSH/SFTP.

Luồng:
1. Xóa folder build/web và file build/web.zip nếu có
2. Chạy: flutter build web --release --wasm --tree-shake-icons
3. Chạy: python3 tools/deploy_version.py
4. Zip folder build/web/ thành build/web.zip
5. Backup server: folder remote -> folder_yyyy_mm_dd_hh_mm
6. Upload build/web.zip lên server
7. SSH lên server: unzip -o web.zip

Ưu tiên giá trị runtime:
1) Tham số CLI.
2) Các INPUT_* define ở đầu file.
"""

from __future__ import annotations

import argparse
import datetime
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

try:
    import paramiko
except ImportError:
    print('[INFO] Thiếu thư viện paramiko, đang tự động cài đặt...')
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--user', 'paramiko'])

    # Không import thẳng được sau khi pip chạy: interpreter đã dựng sys.path VÀ
    # cache danh sách file của từng thư mục trong đó từ lúc khởi động. Gói vừa
    # rơi vào user site-packages (python3 của Xcode không cho ghi vào
    # site-packages hệ thống) nên không nằm trong cache đó -> vẫn
    # ModuleNotFoundError dù pip báo "Successfully installed".
    import importlib
    import site

    user_site = site.getusersitepackages()
    if isinstance(user_site, str):
        user_site = [user_site]
    for path in user_site:
        if path not in sys.path:
            sys.path.append(path)
    importlib.invalidate_caches()

    try:
        import paramiko
    except ImportError:
        print(
            '[LỖI] Đã cài paramiko nhưng phiên hiện tại chưa thấy. '
            'Chạy lại đúng lệnh này một lần nữa là được.',
            file=sys.stderr,
        )
        sys.exit(1)


# .env local (keyfile/pass mỗi dev) — không cần pip dotenv.
sys.path.insert(0, str(Path(__file__).parent))
from dotenv_local import load_dotenv  # noqa: E402
load_dotenv()

DEFAULT_DEPLOY_ENV = 'staging'

# SSH key/pass: CLI (--key-file/--key-pass) > ENV (.env) > '' (rỗng).
# KHÔNG có giá trị mặc định trong code — mỗi dev tự đặt SSH_KEY_FILE /
# SSH_KEY_PASS trong .env của mình (xem .env.example). Thiếu key -> lỗi rõ.

DEPLOY_PRESETS = {
    'staging': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/staging/',
        'ssh_key_file': '',
        'ssh_key_pass': '',
    },
    'prod': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/prod/',
        'ssh_key_file': '',
        'ssh_key_pass': '',
    },
}




BUILD_DIR = 'build/web'
ZIP_FILE = 'build/web.zip'


def coalesce_str(cli_value: str | None, default_value: str) -> str:
    if cli_value is not None and str(cli_value).strip():
        return str(cli_value).strip()
    return str(default_value).strip()


def resolve_ssh_key(cli_file: str | None, cli_pass: str | None, preset: dict) -> tuple[str, str]:
    """CLI > ENV (.env) > preset. Thiếu key file -> lỗi rõ, không dùng chùa."""
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
        raise RuntimeError(f'Preset môi trường không hợp lệ: {env_name}')
    return preset


def run_cmd(cmd: list[str], desc: str):
    """Chạy lệnh shell, in output real-time."""
    print(f'\n=== {desc} ===')
    print(f'>>> {" ".join(cmd)}')
    result = subprocess.run(cmd, capture_output=False)
    if result.returncode != 0:
        print(f'[LỖI] {desc} thất bại (exit code={result.returncode})', file=sys.stderr)
        sys.exit(result.returncode)
    print(f'[OK] {desc} hoàn thành.')


def remove_build_artifacts():
    """Xóa build/web/ và build/web.zip nếu có."""
    build_dir = Path(BUILD_DIR)
    zip_path = Path(ZIP_FILE)

    if build_dir.exists():
        print(f'  Xóa folder: {BUILD_DIR}')
        shutil.rmtree(build_dir)
    else:
        print(f'  Không tìm thấy: {BUILD_DIR}')

    if zip_path.exists():
        print(f'  Xóa file: {ZIP_FILE}')
        zip_path.unlink()
    else:
        print(f'  Không tìm thấy: {ZIP_FILE}')


def zip_build():
    """Zip folder build/web/ thành build/web.zip."""
    build_dir = Path(BUILD_DIR)
    zip_path = Path(ZIP_FILE)

    if not build_dir.exists():
        print(f'[LỖI] Không tìm thấy {BUILD_DIR} để zip.', file=sys.stderr)
        sys.exit(1)

    print(f'  Đang zip {BUILD_DIR} -> {ZIP_FILE} ...')
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(build_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, build_dir.parent)
                zf.write(file_path, arcname)

    print(f'  Zip hoàn thành: {zip_path} ({zip_path.stat().st_size / 1024 / 1024:.1f} MB)')


def create_ssh_client(host: str, port: int, user: str, key_file: str | None, pass_key: str | None) -> paramiko.SSHClient:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    connect_kwargs: dict = {
        'hostname': host,
        'port': port,
        'username': user,
        'timeout': 20,
        'allow_agent': True,
        'look_for_keys': False,
    }

    if key_file:
        connect_kwargs['key_filename'] = key_file
    if pass_key:
        connect_kwargs['passphrase'] = pass_key

    try:
        client.connect(**connect_kwargs)
    except Exception as e:
        raise RuntimeError(f'Không thể kết nối SSH tới {user}@{host}:{port}: {e}')

    return client


def backup_remote_folder(sftp: paramiko.SFTPClient, remote_base: str, ssh_client: paramiko.SSHClient):
    """
    Backup folder web/ trong remote_base:
    Kiểm tra <remote_base>/web, nếu tồn tại thì rename thành <remote_base>/web_yyyy_mm_dd_hh_mm.
    """
    remote_path = f'{remote_base}/web'
    try:
        sftp.stat(remote_path)
    except FileNotFoundError:
        print(f'  Không tìm thấy {remote_path} (bỏ qua backup)')
        return

    timestamp = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M')
    backup_path = f'{remote_base}/web_{timestamp}'

    print(f'  Backup: {remote_path} -> {backup_path}')
    stdin, stdout, stderr = ssh_client.exec_command(f'mv {remote_path} {backup_path}')
    exit_status = stdout.channel.recv_exit_status()
    if exit_status != 0:
        error_msg = stderr.read().decode().strip()
        if error_msg:
            print(f'  [Cảnh báo] mv có thể đã có lỗi: {error_msg}')
    print(f'  Backup hoàn thành: {backup_path}')


def ensure_remote_dirs_sftp(sftp: paramiko.SFTPClient, remote_dir: str):
    """Tạo folder trên server nếu chưa có."""
    if not remote_dir or remote_dir == '/':
        return

    current = '' if remote_dir.startswith('/') else '.'
    for part in remote_dir.strip('/').split('/'):
        current = f'{current}/{part}' if current not in ('', '.') else (f'/{part}' if remote_dir.startswith('/') else part)
        try:
            sftp.stat(current)
        except FileNotFoundError:
            sftp.mkdir(current)


def upload_and_extract(sftp: paramiko.SFTPClient, local_zip: str, remote_base_path: str, ssh_client: paramiko.SSHClient):
    """
    Upload web.zip lên server, unzip vào remote_base_path.
    """
    remote_zip = f'{remote_base_path}/web.zip'

    # Đảm bảo folder tồn tại
    ensure_remote_dirs_sftp(sftp, remote_base_path)

    # Upload
    print(f'  Upload {local_zip} -> {remote_zip} ...')
    sftp.put(local_zip, remote_zip)
    print(f'  Upload hoàn thành.')

    # Unzip
    print(f'  Unzip {remote_zip} vào {remote_base_path} ...')
    stdin, stdout, stderr = ssh_client.exec_command(
        f'cd {remote_base_path} && unzip -o {remote_zip} && rm {remote_zip}'
    )
    exit_status = stdout.channel.recv_exit_status()
    if exit_status != 0:
        error_msg = stderr.read().decode().strip()
        raise RuntimeError(f'Unzip thất bại: {error_msg}')

    print(f'  Unzip hoàn thành.')


def main():
    parser = argparse.ArgumentParser(
        description='Build + hash + zip + upload web Flutter len server'
    )
    parser.add_argument('--ip', help='IP hoac hostname cua server')
    parser.add_argument('--port', type=int, help='Port SSH')
    parser.add_argument('--user', help='User SSH')
    parser.add_argument('--key-file', help='Duong dan private key SSH')
    parser.add_argument('--key-pass', help='Passphrase cua private key SSH')
    parser.add_argument('--server-path', help='Thư mục gốc trên server chứa web')
    parser.add_argument('--env', default=DEFAULT_DEPLOY_ENV, choices=['staging', 'prod'], help=f'APP_ENV: staging hoac prod (mac dinh: {DEFAULT_DEPLOY_ENV})')
    parser.add_argument('--debug', action='store_true', help='Build web debug (JS, co source map, de debug F12). Mac dinh la release --wasm --tree-shake-icons')
    parser.add_argument('--profile', action='store_true', help='Build web profile (JS khong minify, perf gan release) — dung cho diagnostics can ten symbol that')
    parser.add_argument('-y', '--yes', action='store_true', help='Bo qua hoi xac nhan (dung cho CI)')
    args = parser.parse_args()

    preset = get_deploy_preset(args.env)

    ip = coalesce_str(args.ip, preset['server_ip'])
    server_path = coalesce_str(args.server_path, preset['server_path'])
    key_file_raw, key_pass = resolve_ssh_key(args.key_file, args.key_pass, preset)
    port = args.port if args.port is not None else int(preset['server_port'])
    user = coalesce_str(args.user, preset['server_user'])
    key_file = str(Path(key_file_raw).expanduser().resolve()) if key_file_raw else None

    if not ip:
        raise RuntimeError('Thiếu IP server. Hãy chọn preset staging/prod phù hợp hoặc truyền --ip.')
    if not server_path:
        raise RuntimeError('Thiếu đường dẫn server. Hãy chọn preset staging/prod phù hợp hoặc truyền --server-path.')
    if key_file and not Path(key_file).exists():
        raise RuntimeError(f'Không tìm thấy key file: {key_file}')

    local_zip = str(Path(ZIP_FILE).expanduser().resolve())

    print('===== BUILD + DEPLOY WEB =====')
    print(f'Env preset: {args.env}')
    print(f'Server: {user}@{ip}:{port}')
    print(f'Server path: {server_path}')
    print(f'SSH key: {key_file}')

    # Tu 2026-08-12, tools/upload_jaspr.py deploy jaspr_web vao DUNG
    # <server_path>/web nay. Hai script ghi de lan nhau: chay cai nao thi cai
    # do chiem site. Hoi truoc khi lam de khong ai lo tay thay nham.
    if not args.yes:
        print()
        print('!' * 62)
        print(f'  Lenh nay THAY noi dung {server_path}/web bang ban FLUTTER web.')
        print('  Neu dang chay jaspr_web o do thi jaspr se bi day sang backup.')
        print('!' * 62)
        try:
            answer = input("Go 'yes' de tiep tuc: ").strip().lower()
        except EOFError:
            answer = ''
        if answer != 'yes':
            print('Da huy, khong dung gi toi server.')
            sys.exit(1)

    # Step 1: Xóa build artifacts cũ
    print('\n--- Step 1: Xóa build artifacts cũ ---')
    remove_build_artifacts()

    # Step 2: Flutter build (thêm --dart-define APP_ENV)
    if args.debug:
        # Debug: JS, khong minify, co source map day du -> de debug F12
        flutter_args = [
            'flutter', 'build', 'web', '--debug',
            f'--dart-define=APP_ENV={args.env}'
        ]
        build_desc = f'Step 2: Flutter build web DEBUG (APP_ENV={args.env})'
    elif args.profile:
        # Profile: JS khong minify — runtimeType that cho diagnostics (dead-swipe hit path)
        flutter_args = [
            'flutter', 'build', 'web', '--profile',
            f'--dart-define=APP_ENV={args.env}'
        ]
        build_desc = f'Step 2: Flutter build web PROFILE (APP_ENV={args.env})'
    else:
        # Release: WASM + tree-shake-icons, toi uu cho production
        flutter_args = [
            'flutter', 'build', 'web', '--release', '--wasm', '--tree-shake-icons',
            f'--dart-define=APP_ENV={args.env}'
        ]
        build_desc = f'Step 2: Flutter build web RELEASE (APP_ENV={args.env})'
    run_cmd(
        flutter_args,
        build_desc
    )

    # Step 3: Hash + rename assets
    run_cmd(
        ['python3', 'tools/deploy_version.py'],
        'Step 3: Deploy version (hash + rename)'
    )

    # Step 4: Zip build/web/
    print('\n--- Step 4: Zip build/web/ ---')
    zip_build()

    # Step 5: SSH + Backup + Upload
    print('\n--- Step 5: SSH upload ---')
    client = create_ssh_client(ip, port, user, key_file, key_pass if key_pass else None)
    print('Kết nối SSH thành công.')

    try:
        sftp = client.open_sftp()
        try:
            # Backup folder remote
            print(f'\n--- Step 5a: Backup thư mục remote ---')
            backup_remote_folder(sftp, server_path, client)

            # Upload + unzip
            print(f'\n--- Step 5b: Upload + unzip ---')
            upload_and_extract(sftp, local_zip, server_path, client)
        finally:
            sftp.close()
    finally:
        client.close()

    # Step 6: Xóa file zip local
    print('\n--- Step 6: Dọn dẹp local ---')
    zip_path = Path(ZIP_FILE)
    if zip_path.exists():
        zip_path.unlink()
        print(f'  Xóa: {ZIP_FILE}')

    print('\n===== HOÀN THÀNH =====')
    print(f'Web đã được build + upload lên {server_path}')

    # jaspr_web deploy vao dung <server_path>/web nay, nen ban vua ghi de no.
    print('\n' + '=' * 62)
    print('SITE GIO LA BAN FLUTTER WEB.')
    print(f'   Neu truoc do dang chay jaspr_web, no da bi mv sang')
    print(f'   {server_path}/web_<timestamp>. Muon quay lai jaspr:')
    print(f'       make upload-jaspr{"-prod" if args.env == "prod" else ""}')
    print('=' * 62)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f'\n[LỖI] {e}', file=sys.stderr)
        sys.exit(1)
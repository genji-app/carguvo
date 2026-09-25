#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script build + upload `jaspr_web/` len server qua SSH/SFTP.

Song sinh cua tools/upload_web.py (ban Flutter web), khac 3 diem:

1. Build bang jaspr_cli chu khong phai flutter:
       make -C jaspr_web build APP_ENV=<env>
   Target `build` cua jaspr_web/Makefile phu thuoc `css`, nen Tailwind LUON
   duoc sinh lai truoc. Bat buoc: `jaspr_web/web/styles.css` nam trong
   .gitignore -> checkout sach KHONG co file nay -> quen `make css` la deploy
   len 1 trang mat sach style (da dinh 2026-07-22).

2. KHONG chay tools/deploy_version.py. Script do hash/rename cac artefact rieng
   cua Flutter (main.dart.js, flutter_bootstrap.js, flutter_service_worker.js) —
   jaspr khong co file nao trong so do. Cache-busting cua ban jaspr xu ly bang
   header nginx: index.html no-cache, phan con lai immutable (xem
   jaspr_web/deploy/nginx-jaspr.conf.sample).

3. Dich la `<base>/web/` — DUNG DOCROOT cua origin (quyet dinh 2026-08-12).
   jaspr chiem cho ban Flutter web o goc site.

   Vi sao lai la goc chu khong phai subpath /jaspr/: code jaspr tham chieu
   asset bang duong dan TUYET DOI (`/images/...`, `/icons/...`). O subpath thi
   chung tro ve goc origin va truot het (da dinh 2026-08-12: chu hien du, anh
   vo sach). O goc site thi tu dung, khong can vaho nginx nao.

   (Ly do thu hai hoi 2026-08-12 — route tuyet doi `/home`, `/sport` — GIO
   KHONG CON: 2026-08-19 da bo jaspr_router, URL luon dung o `/`. Nhung ly do
   asset o tren van du de giu docroot tai goc.)

⚠️⚠️ `make upload-web` VA `make upload-jaspr` GIO GHI DE LAN NHAU ⚠️⚠️
   Ca hai deu ghi vao `<base>/web`. Chay cai nao thi cai do chiem site:

       make upload-web    -> site thanh ban Flutter, jaspr bien mat
       make upload-jaspr  -> site thanh jaspr, ban Flutter bien mat

   BACKUP (16/09/2026): prod VAN backup nhu cu — upload zip xong, ban dang
   chay duoc mv sang <base>/jaspr_backups/<dir>_<timestamp> (giu 5 ban) roi
   moi unzip, nen luon rollback duoc. Staging + pre KHONG backup: unzip -o
   DE THANG len folder cu (khong mv, khong xoa folder cu; file cu khong con
   trong ban moi se con lai nguyen vi, khong anh huong) — rollback = deploy
   lai ban truoc. Ca hai script deu hoi xac nhan truoc khi lam — dung `-y`
   de bo qua khi chay trong CI.

⚠️ CORS — doc truoc lan deploy dau tien:
   Server auth dung CORS WHITELIST ORIGIN (verify 2026-07-22: preflight toi
   api.azhkthg1.net tra access-control-allow-origin cho
   https://web-s88.sandboxg1.win, KHONG tra cho origin la). `AuthConfig.proxied`
   chi vong qua dev_proxy khi host la localhost/127.0.0.1 — tren subdomain that
   thi request di THANG. Nen origin moi (vd https://jaspr-s88.sandboxg1.win)
   PHAI duoc backend them vao whitelist, neu khong toan bo chain
   regdis/get-bid/login se bi chan va app treo o buoc dang nhap.

Uu tien gia tri runtime:
1) Tham so CLI.
2) Preset DEPLOY_PRESETS ben duoi.
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

# .env local (keyfile/pass mỗi dev) — không cần pip dotenv.
sys.path.insert(0, str(Path(__file__).parent))
from dotenv_local import load_dotenv  # noqa: E402
load_dotenv()

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


DEFAULT_DEPLOY_ENV = 'staging'

# SSH key/pass: CLI (--key-file/--key-pass) > ENV (.env) > '' (rỗng).
# KHÔNG có giá trị mặc định trong code — mỗi dev tự đặt SSH_KEY_FILE /
# SSH_KEY_PASS trong .env của mình (xem .env.example). Thiếu key -> lỗi rõ.

# `server_path` = thu muc CHA tren server; script tao/ghi de <server_path>/jaspr.
# Root cua vhost nginx phai tro dung vao <server_path>/jaspr (xem file mau
# jaspr_web/deploy/nginx-jaspr.conf.sample).
#
# LUU Y: <server_path>/web LA DOCROOT dang chay — xem canh bao va cham o
# docstring dau file truoc khi doi cho nay.
DEPLOY_PRESETS = {
    'staging': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/staging/',
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
    'prod': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/prod/',
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
    # PRE-RELEASE: cung server/cay thu muc voi prod nhung ghi vao subfolder
    # `web/pre` (docroot rieng cua vhost pre-release tro vao do) — web/ cua
    # prod khong bi đụng tới. Khac prod: KHONG backup — web/pre la thu muc doc
    # lap cua pre nen ghi đè thẳng (unzip -o) là đủ; rollback = deploy lại.
    'pre': {
        'server_ip': '54.255.37.84',
        'server_port': 22000,
        'server_user': 'msservice',
        'server_path': '/home/msservice/prod/',
        'remote_dir': 'web/pre',
        'backup': False,
        'ssh_key_file': '/Users/admin/id_ed25519',
        'ssh_key_pass': '',
    },
}


# Ten thu muc dich tren server (tinh tu server_path) + ten goc ben trong zip.
# 'web' = docroot: build/jaspr/index.html se thanh <base>/web/index.html.
# Doi cai nay thi phai doi `root` cua vhost theo. Env 'pre' ghi de thanh
# 'web/pre' (xem preset ben tren) — zip cung boc goc web/pre/ de unzip tu
# <server_path> tra dung cho.
REMOTE_DIR_NAME = 'web'

# APP_ENV bake vao build jaspr = DUNG NHU --env. Env 'pre' duoc
# jaspr_web/lib/services/config/app_env.dart parse thanh preRelease (alias
# 'pre-release' cung chap nhan) — chay config giong heo prod.


def get_remote_dir_name(env_name: str) -> str:
    """Thu muc dich tren server cho env (mac dinh 'web', pre = 'web/pre').

    Staging + devN: 'web/devN' (path-based tren cung 1 domain, vd abc.com/dev1/
    <-> docroot .../staging/web/dev1/). Prod/pre giu nguyen preset.
    """
    return DEPLOY_PRESETS.get(env_name, {}).get('remote_dir', REMOTE_DIR_NAME)


def resolve_staging_dev(cli_dev: int | None, env_name: str, assume_yes: bool = False) -> str | None:
    """Tra ve `devN` khi `--env staging`, nguoc lai None (prod/pre giu nguyen).

    - `--dev N` (1..10) duoc dung luon.
    - Khong truyen `--dev`: hoi interactive; **Enter = staging GOC — khong co
      sub-env** → tra None, KHONG bake APP_ENV_SUB (rs_domain khong noi
      /devN). `-y`/moi truong khong tuong tac (CI, stdin khong phai tty) cung
      vay. Gia tri ngoai 1..10: canh bao roi coi nhu Enter.
    """
    if env_name != 'staging':
        return None
    if cli_dev is not None:
        return f'dev{int(cli_dev)}'
    try:
        if not assume_yes and sys.stdin.isatty():
            print('\n----- STAGING: chon dev path (1-10, Enter = staging goc, khong devN) -----')
            raw = input('dev [1-10, Enter=staging goc]: ').strip()
            if not raw:
                return None
            n = int(raw) if raw.isdigit() else None
            if n is not None and 1 <= n <= 10:
                return f'dev{n}'
            print(f'  ⚠ Gia tri "{raw}" khong hop le (1-10) → staging goc (khong devN).')
            return None
    except (EOFError, KeyboardInterrupt):
        pass
    return None


def get_remote_dir_name_for_dev(env_name: str, dev: str | None) -> str:
    """remote_dir theo env + devN staging (tranh gap doi khi preset da co dev)."""
    base = get_remote_dir_name(env_name)
    if env_name == 'staging' and dev:
        base_stripped = base.rstrip('/')
        if base_stripped == REMOTE_DIR_NAME or base_stripped == 'web':
            return f'web/{dev}'
        if base_stripped.endswith(f'/{dev}'):
            return base_stripped
        # --server-path/preset la tu y: noi dev vao cuoi neu chua co.
        return f'{base_stripped}/{dev}'
    return base


def backup_enabled(env_name: str) -> bool:
    """Staging + pre KHONG backup; prod mac dinh co.

    Staging (docroot lan web/devN deu vay) + pre ghi đè thẳng bằng unzip -o —
    rollback = deploy lại bản trước. Prod (docroot thật) giữ backup: mv sang
    jaspr_backups, giữ `--keep-backups` bản mới nhất.
    """
    if env_name == 'staging':
        return False
    return DEPLOY_PRESETS.get(env_name, {}).get('backup', True)

PROJECT_DIR = 'jaspr_web'
BUILD_DIR = 'jaspr_web/build/jaspr'
ZIP_FILE = 'jaspr_web/build/jaspr.zip'

# Rac cua build_runner nam lan trong build/jaspr — khong day len server.
# `.dart_tool/` va `.build.manifest` la state cua build_runner;
# `styles.tw.css` la FILE NGUON cua Tailwind (styles.css moi la ban compile).
EXCLUDE_NAMES = {'.build.manifest', '.DS_Store', 'styles.tw.css'}
EXCLUDE_DIRS = {'.dart_tool'}

# Per-env excludes, applied on top of EXCLUDE_NAMES. The staging casino preset
# lists internal staging hostnames; jaspr copies the whole `web/casino/` folder
# into the build, so without this it becomes a public URL on the prod docroot
# (audit 2026-08-31). Runtime never reads it outside staging (app_env.dart picks
# the preset by APP_ENV), so dropping it from the zip changes nothing in-app.
# Staging keeps every preset file.
ENV_EXCLUDE_NAMES = {
    'prod': {'caxilo_preset_staging.json'},
    'pre': {'caxilo_preset_staging.json'},
}


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
    """Xóa build/jaspr/ và build/jaspr.zip nếu có."""
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


def sentry_release() -> str:
    """
    `<name>@<version>` doc tu jaspr_web/pubspec.yaml — vd `jaspr_web@0.0.1`.

    Phai TUYET DOI khop chuoi ma `sentry_dart_plugin` dung khi upload source
    map (plugin cung suy ra tu 2 truong nay cua cung file do). Lech mot ky tu
    la stacktrace prod khong de-obfuscate duoc, ma khong co loi nao bao —
    dashboard chi hien ten ham da minify.

    Vi vay o day KHONG hardcode: doc lai chinh file plugin doc.
    """
    text = Path(PROJECT_DIR, 'pubspec.yaml').read_text(encoding='utf-8')
    name = version = None
    for line in text.splitlines():
        if name is None and line.startswith('name:'):
            name = line.split(':', 1)[1].strip()
        elif version is None and line.startswith('version:'):
            version = line.split(':', 1)[1].strip()
        if name and version:
            break
    if not name or not version:
        raise RuntimeError(
            f'Khong doc duoc name/version trong {PROJECT_DIR}/pubspec.yaml '
            f'(name={name!r}, version={version!r})'
        )
    return f'{name}@{version}'


def verify_build_output():
    """
    Chặn sớm 2 kiểu build hỏng mà `jaspr build` vẫn trả exit 0:
      - thiếu index.html / main.client.dart.js  -> build không ra gì
      - styles.css bé bất thường                -> Tailwind quét trượt class
        (thường do sửa `content` trong styles.tw.css, hoặc class không phải
        literal trong lib/**.dart — xem quy ước port trong repo)
    """
    build_dir = Path(BUILD_DIR)
    for required in ('index.html', 'main.client.dart.js', 'styles.css'):
        path = build_dir / required
        if not path.is_file():
            raise RuntimeError(
                f'Build thiếu {required} tại {path}. '
                f'Chạy lại `make -C {PROJECT_DIR} build` và đọc log.'
            )

    styles = build_dir / 'styles.css'
    size_kb = styles.stat().st_size / 1024
    if size_kb < 20:
        raise RuntimeError(
            f'styles.css chỉ {size_kb:.1f} KB — gần như chắc chắn Tailwind quét trượt. '
            f'Bản lành khoảng 150–210 KB. Kiểm tra `make -C {PROJECT_DIR} css`.'
        )
    print(f'  [OK] index.html + main.client.dart.js + styles.css ({size_kb:.0f} KB)')


def zip_build(remote_dir_name: str = REMOTE_DIR_NAME, env_name: str = DEFAULT_DEPLOY_ENV):
    """
    Zip build/jaspr/ thành build/jaspr.zip.

    Gốc BÊN TRONG zip là `remote_dir_name` ('web', pre: 'web/pre'), KHÔNG phải
    tên thư mục build ('jaspr') — server chỉ `cd <base> && unzip`, nên tên gốc
    trong zip quyết định luôn thư mục đích.
    """
    build_dir = Path(BUILD_DIR)
    zip_path = Path(ZIP_FILE)
    exclude_names = EXCLUDE_NAMES | ENV_EXCLUDE_NAMES.get(env_name, set())

    if not build_dir.exists():
        print(f'[LỖI] Không tìm thấy {BUILD_DIR} để zip.', file=sys.stderr)
        sys.exit(1)

    print(f'  Đang zip {BUILD_DIR} -> {ZIP_FILE} ...')
    file_count = 0
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(build_dir):
            # Prune tại chỗ để không đi vào .dart_tool/
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for file in files:
                if file in exclude_names:
                    if file in ENV_EXCLUDE_NAMES.get(env_name, set()):
                        print(f'  [env-exclude] skipped for "{env_name}": {file}')
                    continue
                file_path = os.path.join(root, file)
                # jaspr/xxx trên đĩa  ->  web/xxx trong zip
                arcname = os.path.join(remote_dir_name, os.path.relpath(file_path, build_dir))
                zf.write(file_path, arcname)
                file_count += 1

    print(f'  Zip hoàn thành: {zip_path} ({file_count} file, {zip_path.stat().st_size / 1024 / 1024:.1f} MB)')


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


def backup_remote_folder(
    sftp: paramiko.SFTPClient,
    remote_base: str,
    backup_base: str,
    ssh_client: paramiko.SSHClient,
    remote_dir_name: str = REMOTE_DIR_NAME,
) -> str | None:
    """
    <remote_base>/<dir> -> <backup_base>/<dir>_yyyy_mm_dd_hh_mm (nếu đang tồn tại).

    `backup_base` NẰM NGOÀI docroot một cách cố ý: remote_base giờ là
    `<...>/web`, tức thư mục mà nginx của bản Flutter đang phục vụ. Để backup ở
    đó thì mọi bản build cũ tải được công khai qua
    https://<site>/jaspr_2026_08_12_10_30/... — không ai muốn thế.

    Trả về đường dẫn backup để in ra cho việc rollback.
    """
    remote_path = f'{remote_base}/{remote_dir_name}'
    try:
        sftp.stat(remote_path)
    except FileNotFoundError:
        print(f'  Không tìm thấy {remote_path} (lần deploy đầu — bỏ qua backup)')
        return None

    timestamp = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M')
    backup_path = f'{backup_base}/{remote_dir_name}_{timestamp}'

    ensure_remote_dirs_sftp(sftp, backup_base)

    print(f'  Backup: {remote_path} -> {backup_path}')
    stdin, stdout, stderr = ssh_client.exec_command(f'mv {remote_path} {backup_path}')
    exit_status = stdout.channel.recv_exit_status()
    if exit_status != 0:
        error_msg = stderr.read().decode().strip()
        raise RuntimeError(
            f'Backup thất bại, DỪNG trước khi unzip để bản đang chạy không bị '
            f'ghi đè (zip đã upload nằm lại trên server): {error_msg}'
        )
    print(f'  Backup hoàn thành: {backup_path}')
    return backup_path


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


def upload_zip(
    sftp: paramiko.SFTPClient,
    local_zip: str,
    remote_base_path: str,
    remote_dir_name: str = REMOTE_DIR_NAME,
) -> str:
    """
    Upload jaspr.zip lên server (CHƯA giải nén), trả về đường dẫn zip remote.

    Tách khỏi bước unzip để đổi thứ tự deploy (2026-08-29): upload zip chạy
    TRƯỚC backup (chỉ prod) / unzip — suốt thời gian upload (có thể dài)
    docroot <remote_base>/web vẫn nguyên vẹn, site không bao giờ vắng file.

    Tên zip suy ra từ thu muc dich: 'web' -> web.zip, 'web/pre' -> web-pre.zip
    (đặt CẠNH web/ chứ không bên trong, tránh bị vhost phục vụ công khai).
    """
    zip_name = remote_dir_name.replace('/', '-') + '.zip'
    remote_zip = f'{remote_base_path}/{zip_name}'

    ensure_remote_dirs_sftp(sftp, remote_base_path)

    print(f'  Upload {local_zip} -> {remote_zip} ...')
    sftp.put(local_zip, remote_zip)
    print(f'  Upload hoàn thành.')
    return remote_zip


def extract_remote_zip(ssh_client: paramiko.SSHClient, remote_zip: str, remote_base_path: str):
    """Unzip -o `remote_zip` vào `remote_base_path` rồi xoá zip. Chạy SAU backup (chỉ prod).

    unzip -o chỉ GHI ĐÈ file trùng tên lên folder cũ — KHÔNG xoá folder cũ.
    Staging + pre không có backup: file của bản cũ không còn trong bản mới sẽ
    ở lại nguyên vị; tên file bản này đều có hash/version nên vô hại.
    """
    print(f'  Unzip {remote_zip} vào {remote_base_path} ...')
    stdin, stdout, stderr = ssh_client.exec_command(
        f'cd {remote_base_path} && unzip -o {remote_zip} && rm {remote_zip}'
    )
    exit_status = stdout.channel.recv_exit_status()
    if exit_status != 0:
        error_msg = stderr.read().decode().strip()
        raise RuntimeError(f'Unzip thất bại: {error_msg}')

    print(f'  Unzip hoàn thành.')


def prune_backups(
    ssh_client: paramiko.SSHClient,
    backup_base: str,
    keep: int,
    remote_dir_name: str = REMOTE_DIR_NAME,
):
    """Giữ `keep` bản backup gần nhất, xóa phần còn lại (đĩa server không vô hạn)."""
    if keep < 0:
        return
    cmd = (
        f'ls -1d {backup_base}/{remote_dir_name}_* 2>/dev/null | sort -r '
        f'| tail -n +{keep + 1} | xargs -r rm -rf'
    )
    stdin, stdout, stderr = ssh_client.exec_command(cmd)
    stdout.channel.recv_exit_status()
    print(f'  Giữ lại {keep} bản backup gần nhất.')


def main():
    parser = argparse.ArgumentParser(
        description='Build + zip + upload jaspr_web len server (subdomain rieng)'
    )
    parser.add_argument('--ip', help='IP hoac hostname cua server')
    parser.add_argument('--port', type=int, help='Port SSH')
    parser.add_argument('--user', help='User SSH')
    parser.add_argument('--key-file', help='Duong dan private key SSH (mac dinh lay SSH_KEY_FILE trong .env)')
    parser.add_argument('--key-pass', help='Passphrase cua private key SSH (mac dinh lay SSH_KEY_PASS trong .env)')
    parser.add_argument('--server-path', help='Thu muc CHA tren server (script ghi vao <path>/jaspr)')
    parser.add_argument('--backup-path',
                        help='Noi cat backup jaspr_<timestamp> (CHI co tac dung khi env CO '
                             'backup — prod). Mac dinh: thu muc cha cua --server-path + '
                             '/jaspr_backups (co y de NGOAI docroot).')
    parser.add_argument('--env', default=DEFAULT_DEPLOY_ENV, choices=['staging', 'prod', 'pre'],
                        help=f'Env deploy: staging | prod | pre (pre = ghi vao <prod>/web/pre; '
                             f'APP_ENV=pre → preRelease). Staging + pre KHONG backup (unzip -o '
                             f'de thang); prod CO backup nhu cu. Mac dinh: {DEFAULT_DEPLOY_ENV}')
    parser.add_argument('--dev', type=int, default=None, choices=list(range(1, 11)),
                        help='Staging sub-env dev1..dev10 (CHI dung khi --env staging). '
                             'Khong truyen thi script hoi interactive '
                             '(Enter = staging GOC, KHONG devN — khong bake APP_ENV_SUB, '
                             'rs_domain khong noi /devN). '
                             'Anh xa khi chon: abc.com/devN/ <-> <staging>/web/devN/.')
    parser.add_argument('--optimize', default='2', choices=['0', '1', '2', '3', '4'],
                        help='Muc toi uu dart2js (-O cua jaspr build). Mac dinh 2 = production an toan.')
    parser.add_argument('--source-maps', action='store_true',
                        help='Kem source map + file .dart trong output (de debug F12, nhung LO source len server)')
    parser.add_argument('--keep-backups', type=int, default=5,
                        help='So ban backup jaspr_<timestamp> giu lai tren server (mac dinh 5, '
                             '-1 = giu tat ca; CHI co tac dung khi env CO backup — prod)')
    parser.add_argument('--skip-build', action='store_true',
                        help='Bo qua buoc build, upload luon build/jaspr dang co (dung khi build lai lan 2)')
    parser.add_argument('--build-only', action='store_true',
                        help='Chi build + verify roi DUNG — khong zip, khong dung toi server. '
                             'Dung cho lane fastlane can chen buoc upload Sentry vao GIUA build va deploy '
                             '(build --source-maps -> upload map -> xoa map -> upload_jaspr.py --skip-build).')
    parser.add_argument('-y', '--yes', action='store_true',
                        help='Bo qua hoi xac nhan (dung cho CI). Mac dinh script HOI truoc khi thay docroot.')
    args = parser.parse_args()

    if args.build_only and args.skip_build:
        raise RuntimeError('--build-only va --skip-build loai tru nhau: mot cai chi build, cai kia chi upload.')

    # Luôn chạy từ root repo — mọi đường dẫn trong file này là relative tới đó.
    repo_root = Path(__file__).resolve().parent.parent
    os.chdir(repo_root)

    # --build-only khong cham toi server: bo qua toan bo phan resolve preset SSH,
    # in banner canh bao va hoi xac nhan.
    if args.build_only:
        dev_bo = resolve_staging_dev(args.dev, args.env, args.yes)
        print('===== BUILD JASPR_WEB (--build-only, KHONG upload) =====')
        print(f'Env preset: {args.env}' + (f' ({dev_bo})' if dev_bo else '') + '   (APP_ENV bake vào bundle)')
        if dev_bo:
            print(f'APP_ENV_SUB bake vào bundle: {dev_bo}')
        elif args.env == 'staging':
            print('APP_ENV_SUB: KHÔNG bake (staging gốc — rs_domain không nối /devN)')

        print('\n--- Step 1: Xóa build artifacts cũ ---')
        remove_build_artifacts()

        build_flags = []
        if args.source_maps:
            build_flags.append('--include-source-maps')
        release = sentry_release()
        build_flags.append(f'--dart-define SENTRY_RELEASE={release}')

        build_only_args = [
            'make', '-C', PROJECT_DIR, 'build',
            f'APP_ENV={args.env}',
            f'OPTIMIZE={args.optimize}',
            f'BUILD_FLAGS={" ".join(build_flags)}',
        ]
        if dev_bo:
            build_only_args.append(f'APP_ENV_SUB={dev_bo}')
        run_cmd(
            build_only_args,
            f'Step 2: Tailwind + jaspr build (APP_ENV={args.env}'
            + (f', APP_ENV_SUB={dev_bo}' if dev_bo else '') +
            f', -O{args.optimize}, release={release})',
        )

        print('\n--- Step 3: Kiểm tra output ---')
        verify_build_output()

        print('\n===== BUILD XONG =====')
        print(f'Output: {BUILD_DIR}/   (chưa upload)')
        print(f'Deploy tiếp: python3 tools/upload_jaspr.py --env {args.env}'
              + (f' --dev {dev_bo[3:]}' if dev_bo else '') + ' --skip-build -y')
        return

    preset = get_deploy_preset(args.env)
    dev = resolve_staging_dev(args.dev, args.env, args.yes)
    remote_dir_name = get_remote_dir_name_for_dev(args.env, dev)
    do_backup = backup_enabled(args.env)

    ip = coalesce_str(args.ip, preset['server_ip'])
    server_path = coalesce_str(args.server_path, preset['server_path']).rstrip('/')
    key_file_raw, key_pass = resolve_ssh_key(args.key_file, args.key_pass, preset)
    port = args.port if args.port is not None else int(preset['server_port'])
    user = coalesce_str(args.user, preset['server_user'])
    key_file = str(Path(key_file_raw).expanduser().resolve()) if key_file_raw else None

    if not ip:
        raise RuntimeError('Thiếu IP server. Chọn preset staging/prod hoặc truyền --ip.')
    if not server_path:
        raise RuntimeError('Thiếu đường dẫn server. Chọn preset staging/prod hoặc truyền --server-path.')
    if key_file and not Path(key_file).exists():
        raise RuntimeError(f'Không tìm thấy key file: {key_file}')

    # Backup ra NGOÀI docroot. Docroot là <server_path>/web, nên
    # <server_path>/jaspr_backups nằm cạnh nó chứ không nằm trong — bản build
    # cũ sẽ không tải được công khai qua https://<site>/...
    default_backup = f'{server_path}/jaspr_backups'
    backup_base = coalesce_str(args.backup_path, default_backup).rstrip('/')

    local_zip = str(Path(ZIP_FILE).expanduser().resolve())

    print('===== BUILD + DEPLOY JASPR_WEB =====')
    print(f'Env preset: {args.env}' + (f' ({dev})' if dev else '') + '   (APP_ENV bake vào bundle)')
    if dev:
        print(f'APP_ENV_SUB bake vào bundle: {dev}')
        print(f'Site path: abc.com/{dev}/  <->  Đích: {server_path}/{remote_dir_name}')
        print(f'Resource base: rs_domain/{dev}/...')
    elif args.env == 'staging':
        print('APP_ENV_SUB: KHÔNG bake (staging gốc — rs_domain không nối /devN)')
    print(f'Server: {user}@{ip}:{port}')
    print(f'Đích: {server_path}/{remote_dir_name}   <-- DOCROOT ĐANG CHẠY')
    print(f'Backup: {"TẮT (staging/pre — unzip -o đè thẳng, không xoá; rollback = deploy lại)" if not do_backup else f"{backup_base}/"}')
    print(f'SSH key: {key_file}')

    # Chặn xác nhận: đích là docroot, chạy nhầm là site đổi hẳn sang app khác.
    if not args.yes:
        print()
        print('!' * 62)
        print(f'  Lệnh này THAY nội dung {server_path}/{remote_dir_name}')
        print(f'  bằng bản jaspr_web ({args.env}).')
        print('  Bản jaspr đang chạy ở đó sẽ bị đẩy sang backup.'
              if do_backup else
              '  GHI ĐÈ THẲNG — env này KHÔNG backup (rollback = deploy lại).')
        print('!' * 62)
        try:
            answer = input("Gõ 'yes' để tiếp tục: ").strip().lower()
        except EOFError:
            answer = ''
        if answer != 'yes':
            print('Đã huỷ, không đụng gì tới server.')
            sys.exit(1)

    if not args.skip_build:
        # Step 1
        print('\n--- Step 1: Xóa build artifacts cũ ---')
        remove_build_artifacts()

        # Step 2 — `build` phụ thuộc `css`, nên Tailwind chạy trước, luôn luôn.
        build_flags = []
        if args.source_maps:
            build_flags.append('--include-source-maps')
        # Release cho Sentry runtime (SentryService._release). Bom LUON, ke ca
        # staging: chuoi nay vo hai khi Sentry tat, va co san thi bat Sentry cho
        # staging sau nay khong phai dong vao buoc build nua.
        release = sentry_release()
        build_flags.append(f'--dart-define SENTRY_RELEASE={release}')

        jaspr_args = [
            'make', '-C', PROJECT_DIR, 'build',
            f'APP_ENV={args.env}',
            f'OPTIMIZE={args.optimize}',
            f'BUILD_FLAGS={" ".join(build_flags)}',
        ]
        # Staging: app phải biết devN qua APP_ENV_SUB (rs_domain/<devN>/...).
        # Prod/pre: KHÔNG truyền (AppEnv bỏ qua hoàn toàn ngoài staging).
        if dev:
            jaspr_args.append(f'APP_ENV_SUB={dev}')
        run_cmd(
            jaspr_args,
            f'Step 2: Tailwind + jaspr build (APP_ENV={args.env}'
            + (f', APP_ENV_SUB={dev}' if dev else '') +
            f', -O{args.optimize}, release={release})',
        )
    else:
        print('\n--- Step 1+2: BỎ QUA build (--skip-build) ---')
        if Path(ZIP_FILE).exists():
            Path(ZIP_FILE).unlink()

    # Step 3
    print('\n--- Step 3: Kiểm tra output ---')
    verify_build_output()

    # Step 3.5 - hash + rename jaspr assets, sinh version.json, cap nhat index.html
    # de chay index.js. Giong tools/deploy_version.py (flutter web) nhung cho cac
    # file rieng cua jaspr (main.css, styles.css, vendor/*.js, main.client.dart.js).
    # Chay sau verify (giu ten file goc de kiem tra) va TRUOC zip de cac file da
    # hash duoc dung vao archive upload. KHONG chay o che do --build-only vi cai
    # do can ngi lieu source map raw, ten file chua bi thay doi.
    run_cmd(
        ['python3', 'tools/deploy_jaspr_version.py'],
        'Step 3.5: Hash + rename jaspr assets (version.json + index.html)',
    )

    # Step 4
    print('\n--- Step 4: Zip build/jaspr/ ---')
    zip_build(remote_dir_name, args.env)

    # Step 5 — THỨ TỰ: upload zip -> backup (CHỈ prod) -> unzip (đổi 2026-08-29;
    # trước đây là backup -> upload + unzip). Lý do: suốt thời gian upload zip
    # (có thể hàng phút) docroot <server>/web PHẢI còn nguyên — upload xong mới
    # backup (mv gần như tức thì) rồi unzip (vài giây). Staging + pre KHÔNG
    # backup (16/09/2026): unzip -o đè thẳng lên folder cũ, không mv, không xoá.
    print('\n--- Step 5: SSH upload ---')
    client = create_ssh_client(ip, port, user, key_file, key_pass if key_pass else None)
    print('Kết nối SSH thành công.')

    remote_zip = None
    backup_path = None
    try:
        sftp = client.open_sftp()
        try:
            print(f'\n--- Step 5a: Upload zip (site chưa bị đụng tới) ---')
            remote_zip = upload_zip(sftp, local_zip, server_path, remote_dir_name)

            if do_backup:
                print(f'\n--- Step 5b: Backup thư mục remote ---')
                backup_path = backup_remote_folder(
                    sftp, server_path, backup_base, client, remote_dir_name
                )
            else:
                print(f'\n--- Step 5b: Backup — BỎ QUA (env "{args.env}" không backup) ---')

            print(f'\n--- Step 5c: Unzip -o bản mới (đè thẳng, không xoá folder cũ) ---')
            extract_remote_zip(client, remote_zip, server_path)

            if do_backup:
                print(f'\n--- Step 5d: Dọn backup cũ ---')
                prune_backups(client, backup_base, args.keep_backups, remote_dir_name)
        finally:
            sftp.close()
    finally:
        client.close()

    # Step 6
    print('\n--- Step 6: Dọn dẹp local ---')
    zip_path = Path(ZIP_FILE)
    if zip_path.exists():
        zip_path.unlink()
        print(f'  Xóa: {ZIP_FILE}')

    print('\n===== HOÀN THÀNH =====')
    print(f'jaspr_web đã lên {server_path}/{remote_dir_name}')
    if backup_path:
        print(f'Rollback nếu hỏng:')
        print(f'  ssh -p {port} {user}@{ip} "rm -rf {server_path}/{remote_dir_name} && '
              f'mv {backup_path} {server_path}/{remote_dir_name}"')
    else:
        print('Không có backup tự động cho env này — rollback = deploy lại bản trước.')
    print('\nMở site và kiểm tra ngay 3 thứ (theo thứ tự):')
    print('  1. Ảnh/icon có hiện không → giờ jaspr ở gốc nên /images/, /icons/ phải trúng.')
    print('  2. Console có lỗi CORS ở regdis/get-bid/login không.')
    print('  3. Hard-reload (Cmd+Shift+R) phải ra bản MỚI — nếu vẫn thấy bản cũ thì')
    print('     header no-cache cho index.html trong vhost đang sai.')
    print()
    print('KHÔNG cần test reload /home hay /sport nữa: từ 2026-08-19 jaspr_web đã bỏ')
    print('jaspr_router, điều hướng 100% bằng state nên URL luôn đứng ở `/`. Route con')
    print('trả 404 là ĐÚNG — đừng thêm SPA fallback vào vhost vì chuyện đó.')
    if remote_dir_name == REMOTE_DIR_NAME:
        print('\n⚠️  `make upload-web` giờ GHI ĐÈ bản jaspr này (cùng đích docroot); '
              'nó CÓ backup riêng của nó — xem tools/upload_web.py.')
    else:
        print(f'\n⚠️  Đích của env "{args.env}" là subfolder riêng ({remote_dir_name}) — '
              '`make upload-web` KHÔNG đụng tới nó.')
    print('   Chạy nhầm thì rollback bằng lệnh mv ở trên.' if do_backup else '')


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f'\n[LỖI] {e}', file=sys.stderr)
        sys.exit(1)

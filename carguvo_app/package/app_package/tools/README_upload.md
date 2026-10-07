# Hướng dẫn deploy

> ⚠️ **Trước khi chạy: sửa SSH key cho đúng máy bạn.**
> Trong `upload_resources.py` và `upload_web.py`, mở `DEPLOY_PRESETS` ở đầu file và sửa:
> - `ssh_key_file`: đường dẫn key của bạn (vd `/Users/ban/.ssh/id_rsa`)
> - `ssh_key_pass`: passphrase của key (để `''` nếu không có)
>
> Hoặc truyền trực tiếp khi chạy, không cần sửa file:
> ```bash
> python3 tools/upload_web.py --key-file ~/.ssh/id_rsa --key-pass matkhau
> ```

Mặc định cả 2 tool deploy lên **staging**. Thêm `--env prod` để lên production.

## Upload tài nguyên (ảnh, svg, âm thanh...)

```bash
python3 tools/upload_resources.py
```

## Build & upload web

```bash
python3 tools/upload_web.py
```

## Dọn tài nguyên cũ trên server

`assets/` tích luỹ file của MỌI lần release (mỗi release sinh hash mới cho từng
bundle) nên phình rất nhanh. Tool `clear_resources.py` xoá file không còn bản
nào dùng.

Cách xác định file cần giữ:
1. **5 tag prod gần nhất** dạng `v<ver>-res.<hash>` (`--keep-tags N` để đổi).
2. `version_resource_config.json` **trên server**: `default`, `dynamic`, và
   toàn bộ hash trong `app_versions` (app cũ còn chạy ngoài thị trường).
3. Từ mỗi hash, dò `bundle_config.<hash>.json` → `bundle_resource_config.<hash>.json`
   của từng bundle → ra danh sách file chính xác (packs/ images/ others/).
4. Duyệt `assets/` trên server: file nào không có trong keep set → xoá.

```bash
# Xem trước (DRY-RUN — KHÔNG xoá gì, mặc định)
python3 tools/clear_resources.py --env pre
python3 tools/clear_resources.py --env prod

# Xoá thật (hỏi xác nhận, -y để bỏ qua)
python3 tools/clear_resources.py --env pre --apply -y

# Giữ 10 tag gần nhất / bỏ app_versions cũ (app cũ sẽ vỡ tài nguyên!)
python3 tools/clear_resources.py --env prod --keep-tags 10 --apply -y
python3 tools/clear_resources.py --env prod --no-keep-app-versions --apply -y
```

Qua Makefile:

```bash
make clear-resources-pre           # dry-run pre
make clear-resources-pre-apply     # xoá thật pre
make clear-resources-prod          # dry-run prod
make clear-resources-prod-apply    # xoá thật prod
```

An toàn:
- Mặc định dry-run, phải có `--apply` mới xoá.
- Chỉ đụng trong `<server_path>/assets/`.
- Hash nào không dò được config → giữ mọi file có tên chứa hash đó (thà giữ
  thừa còn hơn xoá nhầm), kèm cảnh báo trong log.

## Vài tùy chọn hay dùng

```bash
# Lên production
python3 tools/upload_resources.py --env prod
python3 tools/upload_web.py --env prod

# Chỉ xử lý 1 bundle tài nguyên
python3 tools/upload_resources.py --bundle diamond

# Build web bản debug (dễ debug F12)
python3 tools/upload_web.py --debug
```

## Lưu ý khi build app (Store / Shorebird)

Vì có thể nhiều phiên bản app chạy song song, phần này phải **chỉnh tay**:

1. **Tăng version app** trước khi update shorebird (trong `app_version.dart`) vì pubspec.yaml muốn tăng ver phải build lại app.
2. Sau khi upload tài nguyên, mở `proj_resources/version_resource_config.json` và **thêm version app vừa build** vào `app_versions`, trỏ tới hash resource muốn app đó dùng:

   ```json
   {
     "app_versions": {
       "1.0.0": "856ee4a5",
       "1.0.1": "69024124"   // 👈 thêm version mới, gán hash resource tương ứng
     },
     "default": "69024124",
     "dynamic": "2b310de8"
   }
   ```

   - `app_versions`: map từng version app → hash resource nó dùng.
   - `default`: hash resource cho app không khớp version nào ở trên.
   - Lấy hash resource từ `bundle_config.<hash>.json` sinh ra sau khi chạy `upload_resources.py`.
3. Chạy lại `upload_resources.py` (hoặc upload thủ công) để đẩy file config này lên server.

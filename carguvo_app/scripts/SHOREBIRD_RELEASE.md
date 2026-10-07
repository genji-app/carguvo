# Quy trình Shorebird release / patch (carguvo)

Script: `scripts/shorebird_preflight.py` (Python 3, không cần cài thêm gì). Chạy ở thư mục gốc repo.

## Release binary mới

```bash
# 0. Bump `version:` trong pubspec.yaml. Cây ĐẦY ĐỦ (có app_package).
# 1. Tự cấu hình native + pub get + check (1 lệnh)
python3 scripts/shorebird_preflight.py fix --dry-run      # xem trước
python3 scripts/shorebird_preflight.py fix                # ghi + pub get + check
#    → sửa nốt mục FAIL/WARN không tự sửa được (vd. DEVELOPMENT_TEAM, URL staging)

# 2. (nếu release KHÔNG kèm app_package) bỏ app_package khỏi pubspec + main.dart, rồi
flutter pub get        # plugin native đã được ghim ở managed block nên vẫn đủ

# 3. Release + snapshot ngay sau MỖI nền tảng
shorebird release android -- --no-tree-shake-icons
python3 scripts/shorebird_preflight.py snapshot --platform android --flags="--no-tree-shake-icons"
shorebird release ios -- --no-tree-shake-icons
python3 scripts/shorebird_preflight.py snapshot --platform ios --flags="--no-tree-shake-icons"
#    → commit release_manifests/<version>.json
```

## Patch

```bash
python3 scripts/shorebird_preflight.py fix                # chế độ PATCH: ghim theo binary
python3 scripts/shorebird_preflight.py verify-patch --platform android --flags="--no-tree-shake-icons"
shorebird patch android -- --no-tree-shake-icons
```

`fix` tự chọn chế độ:
- **RELEASE** (version chưa có manifest): ghim mọi plugin native theo `pubspec.lock`, thêm plugin thiếu (`game_engine`, `sqflite_*`…) vào managed block.
- **PATCH** (version đã có manifest): ghim theo đúng version trong binary. Có plugin native mới → dừng, báo bump version + release. pub get fail → khôi phục pubspec, nghĩa là app_package cần version native khác binary → phải release.

## `fix` tự sửa gì
- `pubspec.yaml`: đổi `^x.y` → exact cho plugin native đã khai; thêm plugin native còn thiếu vào block
  `# >>> shorebird_preflight … # <<<` (tự sinh, chạy lại không tạo trùng).
- Cờ debug có cách sửa an toàn (`kNccLogFullUrl = false`, `AppEnv._raw = 'prod'`).
- Android: quyền `INTERNET`, scheme còn thiếu trong `<queries>`.
- iOS: scheme còn thiếu trong `LSApplicationQueriesSchemes`, `CFBundleURLTypes` cho terminate_restart.
- Mọi file sửa đều có bản `*.preflight.bak` bên cạnh.

Nâng version plugin native (vd. app_package cần bản mới hơn → pub get báo xung đột với bản ghim):
`fix --unpin` → `flutter pub upgrade` → bump version → `fix` → **release** (không patch được).

KHÔNG tự sửa (cần người quyết): Team ký iOS, URL config staging → prod, keystore, bundle id.

## Script kiểm gì

**Chung** (`check`)
1. pub get còn mới · 2. version chưa release, `shorebird.yaml` trong assets
3. Mọi plugin native mà `app_package` cần có trong release (theo từng nền tảng) — kể cả plugin path (`game_engine`) và transitive (`sqflite`)
4. Plugin native chưa ghim exact version · 5. asset/font trong package chỉ-qua-patch
6. Cờ debug/cấu hình (`kNccLogFullUrl`, `AppEnv`, config STAGING) + dấu `// RELEASE_BLOCKER`

**A. Android** (`check --platform android`)
applicationId không phải `com.example` · `MainActivity` đúng package với manifest · versionCode/versionName lấy từ pubspec ·
release ký bằng key release, `key.properties` đủ khoá + keystore tồn tại · minSdk ≥ minSdk của plugin ·
quyền `INTERNET` (Shorebird cần để tải patch) · `<queries>` đủ scheme url_launcher dùng · `GeneratedPluginRegistrant.java` đủ plugin

**I. iOS** (`check --platform ios`)
Bundle id đồng nhất, không phải `com.example` · version = `$(FLUTTER_BUILD_NAME)`/`$(FLUTTER_BUILD_NUMBER)` ·
`DEVELOPMENT_TEAM` (archive cần ký) · deployment target đồng nhất, khớp Podfile, ≥ yêu cầu plugin · Podfile khi plugin chưa hỗ trợ SwiftPM ·
`CFBundleURLTypes` = bundle id (terminate_restart mở lại app) · `LSApplicationQueriesSchemes` đủ scheme code dùng ·
`NS*UsageDescription` cho plugin cần quyền · `GeneratedPluginRegistrant.m` đủ plugin

**verify-patch** (theo từng nền tảng)
Plugin native mới / đổi version so với binary · code native đã sửa (plugin path; `android/app/src/main` hoặc `ios/Runner`) · cờ build khác lúc release · Flutter khác version

Thêm luật mới: sửa list `SOURCE_RULES` đầu script. Chặn tạm 1 chỗ: comment `// RELEASE_BLOCKER: lý do`.
Package khác cũng chỉ-qua-patch: `check --patch-packages app_package other_pkg`.

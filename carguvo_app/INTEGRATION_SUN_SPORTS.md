# Tích hợp `sun_sports` + `unlock_shorebird_kit` vào carguvo

Cập nhật: 2026-09-19

## Kiến trúc sau khi config

```
main()
 └─ RestartScope                     lib/core/restart_scope.dart
     └─ RootGate                     lib/root_gate.dart
         ├─ AppMode.splash  → MaterialApp > SplashModeScreen (unlock_shorebird_kit)
         │                     └─ GateSplashView             lib/core/gate_splash_view.dart
         ├─ AppMode.fake    → CarguvoApp (GetMaterialApp)    lib/app.dart
         └─ AppMode.betting → ProviderScope > SunSportsApp   package/sun_sports_package
```

- `SplashModeScreen` chỉ **báo mode** qua `onModeChanged`; dựng cây là việc của
  `RootGate`. Lý do: `CarguvoApp` và `SunSportsApp` đều tự dựng `MaterialApp`
  riêng — lồng nhau sẽ ra màn hình đen sau lần điều hướng đầu
  (flutter/flutter#142585).
- `SunSports.init()` được gọi **lười**, chỉ khi thật sự vào `betting`. App vỏ
  không phải trả giá Sentry / Rive native / storage / brand config.
  Init fail → fallback về `AppMode.fake` thay vì kẹt splash.

## Đã sửa những gì

| File | Thay đổi |
|---|---|
| `pubspec.yaml` | sdk `^3.8.1` → `^3.10.0`; thêm 2 local package + `terminate_restart` + `flutter_riverpod`; **pre-bundle 17 plugin native** của sun_sports |
| `lib/main.dart` | Chỉ còn bootstrap: Hive → `TerminateRestart.initialize()` → `RestartScope(RootGate())` |
| `lib/app.dart` | **MỚI** — `CarguvoApp` tách ra khỏi `main.dart` |
| `lib/root_gate.dart` | **MỚI** — swap cây theo `AppMode` |
| `lib/core/restart_scope.dart` | **MỚI** — fade-to-black + restart process, 4 lớp chống kẹt màn đen |
| `lib/core/gate_splash_view.dart` | **MỚI** — splash của gate (không dùng GetX) |
| `android/.../AndroidManifest.xml` | `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `supportsPictureInPicture` |
| `android/app/build.gradle.kts` | `minSdk` 21 → **24** |
| `ios/Runner.xcodeproj/project.pbxproj` | bundle id `com.example.carguvo` → **`com.dulichpdlogistics.carguvo`**; deployment target 12.0 → **13.0** |
| `ios/Runner/Info.plist` | `CFBundleURLTypes` = `$(PRODUCT_BUNDLE_IDENTIFIER)` (bắt buộc để iOS mở lại app sau `terminate_restart`) |

Bản pubspec cũ giữ ở `pubspec.yaml.bak`.

## PHẢI CHẠY TAY (máy này không có Flutter SDK)

```bash
flutter pub get
flutter analyze
flutter run                       # thử debug trước
```

## Còn lại cần bạn quyết / làm

1. **`shorebird.yaml` chưa có.** Chạy `shorebird init` trong repo — lệnh này
   sinh `app_id` gắn với tài khoản Shorebird của bạn và tự thêm
   `shorebird.yaml` vào `flutter: assets:`. Không tự tay bịa `app_id`.
2. **`ios/Podfile` chưa có** — `flutter build ios` / `pod install` sẽ tự sinh.
   Nếu CocoaPods kêu pod nào cần iOS > 13.0 thì nâng
   `IPHONEOS_DEPLOYMENT_TARGET` trong Xcode cho khớp.
3. **`UnlockFlowConfig` đang trỏ STAGING.**
   `package/unlock_shorebird_kit/lib/flow/unlock_flow_config.dart`:
   `apiDomainConfigUrl` = `s88_staging.json`. Đổi sang `s88.json` khi lên prod.
   `appSubmitDate` đang là `2026-09-13` — sửa cho đúng ngày submit thật, vì
   ngày unlock = submitDate + 3 ngày (đẩy qua thứ Hai nếu rơi vào cuối tuần).
4. **GitHub PAT**: build prod nên truyền `--dart-define=GITHUB_PAT=...` thay vì
   sửa hằng số fallback trong `lib/network/github_auth.dart`.
5. **`APP_ENV`** của sun_sports: `--dart-define=APP_ENV=prod|staging|pre-release`.
6. **Bundle id iOS đã đổi** → phải tạo/chọn lại provisioning profile trong Xcode.

## Bẫy đã biết (đừng rà lại từ đầu)

- **Shorebird patch KHÔNG thêm được plugin native.** Mọi plugin mới của
  `sun_sports` phải được thêm vào block pre-bundle trong `pubspec.yaml` rồi
  **release binary mới** — patch không đủ. Triệu chứng nếu quên:
  `MissingPluginException` ném tức thì (~5ms), mọi lần, trong khi mọi thứ khác
  vẫn chạy bình thường.
- **Patch chỉ apply ở process mới.** `RestartScope` phải gọi
  `terminate: true`. Remount widget tree KHÔNG apply patch. Test patch thì luôn
  cold open (kill hẳn rồi mở lại).
- **Đừng để lỗi plugin quyết định "mất mạng".** `connectivity_plus` từng ném
  exception suốt session trong khi mạng vẫn tốt → phải xác minh bằng request
  thật (`NetworkManager.probeReachability`).
- **Mọi nhánh fail trong `RestartScope` phải đi qua `_abortFade()`** — điểm
  thoát duy nhất khỏi overlay đen. Thêm nhánh mới thì gọi nó, đừng `setState`
  trực tiếp.
- Log chẩn đoán: `adb logcat | grep NetDiag` / `idevicesyslog | grep NetDiag`.

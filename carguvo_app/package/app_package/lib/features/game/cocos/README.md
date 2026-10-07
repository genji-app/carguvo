# Cocos game download + launch (env-aware, background)

Wiring của package `game_downloader` (tải/giải nén bundle) + `game_launcher`
(bàn giao xuống native Cocos engine) vào app, tự chuyển host theo môi trường
prod/staging. **Chỉ mobile native (iOS/Android).**

## Luồng UX (design Figma 14814-195866 / 209129 / 211930)

1. Click game in-house có bundle → `GameLauncher._launchNativeCocos` gọi
   `downloadGame()` ở **background** (không modal chặn).
   Card của game hiện layer download (scrim + progress + "Đang tải...") —
   `CocosDownloadCardOverlay` trong `GameCard`.
2. User chuyển sang tab khác → progress bar mini hiện dưới tab **Casino** ở
   bottom nav — `CocosNavDownloadProgress` trong
   `SportTabletBottomNavigation` (ẩn khi đang đứng ở tab Casino).
3. Tải + giải nén xong (state `readyToPlay`) → popup **"Hoàn tất tải game"**
   (`CocosDownloadCompleteDialog`) hiện ngay tại tab user đang đứng —
   do `CocosDownloadListener` (mount trong `MainShellLayout`) đảm nhiệm.
   - **Chơi ngay** → `launchPrepared()` → bàn giao native Cocos engine.
   - **Để sau** / X / barrier → `dismiss()` (bundle giữ trên máy, lần sau
     prepare done ngay → vẫn hiện popup xác nhận).
4. Đang tải game A mà click game B → toast lỗi
   `"Bạn đang tải game A. Xin hãy chờ tải xong !"` (guard trong
   `GameLauncher._checkCocosDownloadBusy`). Bấm lại đúng game đang tải → bỏ
   qua im lặng.
5. Tải/launch lỗi → toast lỗi + `reset()` (không tự fallback WebView vì user
   có thể đang ở tab khác). Fallback WebView chỉ khi host native chưa đăng ký
   channel launcher.

## Môi trường prod/staging

Host tải game lấy từ `AppEnv.gameResourceUrl` (`lib/core/env/app_env.dart`),
switch theo `--dart-define=APP_ENV=prod|staging` như các URL khác trong app:

```
prod    → https://resources.gwin.info/s88
staging → (hiện dùng chung host prod — xem TODO trong app_env.dart)
```

> ⚠️ Chưa có host staging riêng. Nếu staging tải từ domain khác, chỉ cần sửa
> nhánh staging của `AppEnv.gameResourceUrl`, không đụng code ở đây.

## Dùng

Luồng chuẩn (background + popup xác nhận, như GameLauncher đang dùng):

```dart
final controller = ref.read(cocosGameControllerProvider.notifier);
await controller.downloadGame(game, xxteaKey: '...'); // GameBlock
// state readyToPlay → CocosDownloadListener tự show popup;
// "Chơi ngay" → controller.launchPrepared();
// nghe tiến độ: ref.watch(cocosGameControllerProvider) → CocosGameDownloadState
```

Chỉ tải, không launch:

```dart
final downloader = ref.read(gameDownloaderProvider);
await for (final p in downloader.prepareGame('fish')) { ... }
```

## Ghi chú

- `entryFileName` mặc định `data/main.js` (Cocos). Nếu bundle zip có cấu trúc
  khác, đổi `kCocosEntryFileName` trong `cocos_game_providers.dart`; đặt sai →
  `isGameReady` luôn false → tải lại mỗi lần.
- Credentials tự đọc từ `TokenManager`/`UserManager` trong `launchPrepared`.
- `nativeGameLauncherProvider` (native) khác `gameLauncherProvider` (webview,
  `lib/features/game/launcher/`). Không thay thế luồng webview hiện có.
- Performance: overlay/nav-progress đều watch bằng `select` → chỉ đúng widget
  liên quan rebuild theo tick progress, không kéo grid/nav rebuild.

## Log từng bước

Mọi bước của luồng đều log qua `cocosLog` (`cocos_log.dart`, chỉ debug build) —
filter console theo `[cocos]`:

```
[click] → [guard] → [fallback?] → [download] → [progress] (phase + mỗi 25%)
→ [ready] → [popup] → [play-now]/[later] → [launch] → [active] | [error] → [reset]
```

## Files

- `cocos_log.dart` — helper log từng bước (`🎮 [cocos][step] ...`)
- `cocos_game_providers.dart` — config env-aware + GameDownloader + GameLauncher
- `cocos_game_controller.dart` — StateNotifier: `downloadGame` →
  `launchPrepared` / `dismiss`
- `cocos_game_download_state.dart` — state (status/phase/progress/game/error)
- `cocos_game_launcher_ui.dart` — popup "Hoàn tất tải game"
  (`CocosDownloadCompleteDialog`)
- `widgets/cocos_download_card_overlay.dart` — layer download trên GameCard
- `widgets/cocos_nav_download_progress.dart` — progress mini dưới tab Casino
- `widgets/cocos_download_listener.dart` — listener toàn cục (popup + toast lỗi)

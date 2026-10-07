# Fullscreen Gate — Tài liệu kiến trúc

> **⚠️ OUTDATED — Phase 5 đã hoàn thành**
>
> Tài liệu này mô tả kiến trúc **cũ** (`system_ui/` + `AppImmersiveGate`).
> Toàn bộ hệ thống đã được thay thế bởi package `fullscreen_guard`.
>
> **Kiến trúc hiện tại:**
> - Package: `packages/fullscreen_guard/`
> - README: `packages/fullscreen_guard/README.md`
> - iOS Safari: `packages/fullscreen_guard/doc/ios_safari_minimal_ui.md`
>
> Các component cũ đã bị xóa:
> - `lib/core/services/system_ui/` — đã xóa
> - `lib/shared/widgets/immersive/app_immersive_gate.dart` — đã xóa
> - `lib/shared/widgets/immersive/app_immersive_provider.dart` — đã xóa
>
> Tài liệu này được giữ lại để tham khảo lịch sử thiết kế.

---

## Tổng quan

Hệ thống **Fullscreen Gate** cung cấp một cơ chế global để yêu cầu và thực thi chế độ toàn màn hình trên web. Bất kỳ screen nào (game, live stream, custom content...) đều có thể yêu cầu fullscreen bằng cách wrap content trong widget `FullscreenRequired`.

Trên **native** (Android/iOS): widget bypass hoàn toàn, immersive mode được xử lý bởi orientation provider + SystemChrome.

Trên **web**: widget trigger overlay gate yêu cầu user tap (browser security requirement), tự re-gate khi mất fullscreen, và block content cho đến khi satisfied.

---

## Nguyên tắc thiết kế

### Single Responsibility

| Component | Trách nhiệm duy nhất |
|-----------|---------------------|
| `SystemUiDelegate` | Gọi platform API (requestFullscreen, SystemChrome) |
| `AppSystemUiNotifier` | Track + apply System UI state |
| `AppImmersiveNotifier` | Track gate state (target, required, satisfied) |
| `AppImmersiveGate` | Render overlay UI |
| `FullscreenRequired` | Bridge widget lifecycle → provider |

### Unidirectional Data Flow

```
FullscreenRequired (mount)
  → AppImmersiveNotifier.request()
  → AppImmersiveGate observes → shows overlay
  → User taps
  → AppSystemUiNotifier.enterImmersive()
  → SystemUiDelegate.apply() → requestFullscreen()
  → Browser fires 'fullscreenchange'
  → Delegate callback → Notifier syncs state
  → AppImmersiveNotifier observes → re-gate if lost
```

---

## Kiến trúc

### Widget Tree

```
App
└─ AppImmersiveGate              ← Global overlay (web only)
    └─ AppOrientationOrchestrator
        └─ MaterialApp.router
            └─ AnyScreen
                └─ FullscreenRequired   ← Lifecycle bridge
                    └─ ScreenContent
```

### Component Diagram

```
┌──────────────────┐     mount/dispose     ┌─────────────────────┐
│ FullscreenRequired│ ──────────────────── │ AppImmersiveNotifier │
│  (widget)         │    request/clear      │  (state holder)      │
└──────────────────┘                       └──────────┬──────────┘
                                                       │ watch
┌──────────────────┐     observes state    ┌──────────▼──────────┐
│ AppImmersiveGate │ ◄──────────────────── │ appImmersiveProvider │
│  (overlay UI)     │                       └─────────────────────┘
└───────┬──────────┘
        │ user tap
        ▼
┌──────────────────┐     apply state       ┌─────────────────────┐
│AppSystemUiNotifier│ ──────────────────── │  SystemUiDelegate    │
│  (UI state mgr)   │                       │  (platform bridge)   │
└──────────────────┘                       └──────────┬──────────┘
        ▲                                              │
        │ fullscreenchange callback                    │ requestFullscreen()
        └──────────────────────────────────────────────┘
```

---

## State Model

```dart
enum AppImmersiveTarget { none, gamePlayer, custom }

class AppImmersiveState {
  final AppImmersiveTarget target;  // Ai yêu cầu
  final bool isRequired;            // Bắt buộc hay optional
  final bool isSatisfied;           // User đã tap chưa

  bool get shouldShowGate => target.isActive && !isSatisfied;
  bool get isBlocking => shouldShowGate && isRequired;
}
```

---

## Cách sử dụng

### Cơ bản — game screen yêu cầu fullscreen bắt buộc

```dart
class GamePlayerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenRequired(
      target: AppImmersiveTarget.gamePlayer,
      isRequired: true,  // Block nếu không fullscreen
      child: GameContent(),
    );
  }
}
```

### Optional fullscreen — gợi ý nhưng không block

```dart
FullscreenRequired(
  target: AppImmersiveTarget.custom,
  isRequired: false,  // Gợi ý, user có thể bỏ qua
  child: LiveStreamContent(),
)
```

### Thêm target mới

1. Thêm enum value vào `AppImmersiveTarget`:
```dart
enum AppImmersiveTarget {
  none,
  gamePlayer,
  liveStream,  // NEW
  custom;
}
```

2. Wrap content:
```dart
FullscreenRequired(
  target: AppImmersiveTarget.liveStream,
  child: StreamPlayer(),
)
```

Không cần sửa gate, delegate, hay notifier.

---

## Platform Behavior

| Platform | Fullscreen mechanism | Gate hiển thị | Re-gate |
|----------|---------------------|--------------|---------|
| Web mobile | Browser Fullscreen API | Co | Co (Esc/gesture) |
| Web desktop | Browser Fullscreen API | Co | Co (Esc/F11) |
| PWA standalone | Đã fullscreen sẵn | Không (auto-satisfy) | Không |
| Android | SystemChrome immersiveSticky | Không | Không |
| iOS | SystemChrome immersiveSticky | Không | Không |

---

## Re-gate Mechanism

Khi user thoát fullscreen (nhấn Esc, gesture, etc.):

1. Browser fires `fullscreenchange` event
2. `WebSystemUiDelegate` nhận event → gọi `onFullscreenChanged(false)`
3. `AppSystemUiNotifier` cập nhật `state.isFullscreen = false`
4. `AppImmersiveNotifier` listen thay đổi → nếu `isRequired && isSatisfied && !isFullscreen` → reset `isSatisfied = false`
5. `AppImmersiveGate` thấy `shouldShowGate = true` → re-show overlay
6. User tap lại → fullscreen lại

---

## Logging Convention

Mỗi log line: `[Tag] ACTION context_data`

```
[SystemUI]       APPLY enterImmersive → delegate.apply(immersive=true)
[SystemUI]       EVENT fullscreenchange → isFullscreen=false
[ImmersiveGate]  REQUEST target=gamePlayer, isRequired=true
[ImmersiveGate]  SATISFIED via user tap
[ImmersiveGate]  RE-GATE fullscreen lost while target=gamePlayer active
[ImmersiveGate]  CLEAR target=gamePlayer
[ImmersiveGate]  SKIP already standalone PWA, auto-satisfy
[FullscreenReq]  MOUNT target=gamePlayer, isRequired=true
[FullscreenReq]  DISPOSE clearing gate
[FullscreenReq]  SKIP not web platform
```

---

## Error Handling

| Tình huống | Xử lý | Log level |
|-----------|-------|-----------|
| requestFullscreen() bị browser reject | Giữ gate, user tap lại = retry | WARNING |
| exitFullscreen() thất bại | Log error, forceReset fallback | ERROR |
| Request khi đã có request khác | Override, log warning | WARNING |
| fullscreenchange nhưng state đã đúng | No-op | DEBUG |

---

## Files

| File | Vai trò |
|------|---------|
| `lib/shared/widgets/immersive/fullscreen_required.dart` | Widget wrapper |
| `lib/shared/widgets/immersive/app_immersive_provider.dart` | Gate state + notifier |
| `lib/shared/widgets/immersive/app_immersive_gate.dart` | Overlay UI |
| `lib/core/services/system_ui/system_ui_notifier.dart` | System UI state management |
| `lib/core/services/system_ui/system_ui_state.dart` | Immutable state model |
| `lib/core/services/system_ui/delegates/system_ui_delegate.dart` | Abstract contract |
| `lib/core/services/system_ui/delegates/system_ui_delegate_web.dart` | Web implementation |
| `lib/core/services/system_ui/delegates/system_ui_delegate_native.dart` | Native implementation |

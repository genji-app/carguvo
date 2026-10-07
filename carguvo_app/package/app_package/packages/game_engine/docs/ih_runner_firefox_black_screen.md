# Firefox: Màn hình đen khi load game (IHRunner & PLRunner)

> **Scope:** `packages/game_engine` — ảnh hưởng cả `IHRunner` (`IHInAppRunnerView`)
> và `PLRunner` (`PLInAppRunnerView`).
> Nguyên nhân gốc giống nhau: `flutter_inappwebview_web` không thể inject JS
> vào cross-origin iframe trên Firefox. Fix khác nhau do 2 runner có kiến trúc khác.

| Mục | Chi tiết |
|-----|----------|
| **Platform** | Firefox (Flutter Web — desktop & mobile) |
| **Trạng thái** | ✅ Đã khắc phục thành công (Fix E & Fix F đã được triển khai; Đã vá lỗi Sandbox & Scrollbar ở bản Flutter Web 3.27+) |
| **Runner bị ảnh hưởng** | `IHRunner` (game in-house Sunwin/Cocos) + `PLRunner` (game 3rd-party) |
| **File liên quan** | [`ih_runner/html_iframe/ih_html_iframe_runner_view.dart`](../lib/src/ih_runner/html_iframe/ih_html_iframe_runner_view.dart), [`provider_live_runner/html_iframe/pl_html_iframe_runner_view.dart`](../lib/src/provider_live_runner/html_iframe/pl_html_iframe_runner_view.dart) |
| **Phát hiện** | 2026-06-05 |

---

## Triệu chứng

Khi user mở bất kỳ game in-house nào (SC, Baccarat KT, Ông Đồ, v.v.) trên
trình duyệt Firefox, game **hiển thị màn hình đen hoàn toàn** sau khi loading
spinner biến mất. Không có thông báo lỗi. Game không tương tác được.

- Chrome, Edge, Safari: hoạt động bình thường.
- Firefox desktop & Firefox mobile: đều bị màn hình đen.

---

## Log thực tế (2026-06-05)

```
[CaxiloConfigClient] Launching: SC | Strategy: GameLaunchStrategy.iframe
[CaxiloConfigClient] Generated URL: https://fish.sunwin.qa/?token=...&iframeType=flutter-web

Feature Policy: Skipping unsupported feature name "autoplay".       ← (1)
Feature Policy: Skipping unsupported feature name "accelerometer".
Feature Policy: Skipping unsupported feature name "gyroscope".
...                                                                  ← lặp lại nhiều lần

WEBGL_debug_renderer_info is deprecated in Firefox and will be removed.   ← (2)
This page is in Quirks Mode. Page layout may be impacted.                 ← (3)

DOMException: Permission denied to get property "href" on cross-origin object       ← (4)
    prepare https://web.sun88.win/assets/.../web_support.js:53
DOMException: Permission denied to access property "console" on cross-origin object
    prepare https://web.sun88.win/assets/.../web_support.js:61
DOMException: Permission denied to access property "history" on cross-origin object
    prepare https://web.sun88.win/assets/.../web_support.js:88
DOMException: Permission denied to access property "open" on cross-origin object
    prepare https://web.sun88.win/assets/.../web_support.js:207
```

**Bằng chứng quyết định:** Log `[IHRunner] GameHost Bridge initialized` **không xuất hiện**
→ xác nhận `bridgeShim` chưa bao giờ được inject vào context của game.

---

## Root Cause Analysis — 3 tầng lỗi

### Tầng 1 — `iframeAllow` dùng sai format, Firefox bỏ qua (dấu hiệu ①)

```dart
// inapp_runner_view.dart — hiện tại
iframeAllow: 'autoplay *; fullscreen *; accelerometer *; ...'
//                    ↑ Feature Policy format (cũ)
```

Firefox dùng **Permissions Policy** (format mới, RFC 2021). Chuỗi trên dùng
**Feature Policy** (format cũ với `*` wildcard) — Firefox bỏ qua hoàn toàn.
Hậu quả: game iframe không có permission `autoplay`, `fullscreen`, v.v. khi
chạy trên Firefox.

Chrome/Safari chấp nhận cả 2 format nên không bị ảnh hưởng.

### Tầng 2 — `flutter_inappwebview_web` không thể inject JS vào cross-origin iframe (dấu hiệu ④)

`flutter_inappwebview_web` hoạt động bằng cách chạy `web_support.js` trên
parent frame (`web.sun88.win`). Script này cố truy cập `iframe.contentWindow`
để inject `window.flutter_inappwebview.callHandler` vào context của game.

Firefox enforce **Same-Origin Policy (SOP)** nghiêm ngặt theo spec W3C:

```
Parent: web.sun88.win
iframe: fish.sunwin.qa   ← cross-origin (khác host)

Firefox blocks:
  iframe.contentWindow.location.href  → DOMException ❌
  iframe.contentWindow.console        → DOMException ❌
  iframe.contentWindow.history        → DOMException ❌
  iframe.contentWindow.open           → DOMException ❌
```

Các DOMException này bị catch trong try-catch của `web_support.js` nên không
throw ra ngoài, nhưng `window.flutter_inappwebview.callHandler` **không được
setup** trong game context.

### Tầng 3 — Script injection thất bại → black screen (nguyên nhân trực tiếp)

`IHInAppRunnerCtrl` inject 3 script vào game qua `evaluateJavascript()`.
Trên Firefox, `evaluateJavascript()` cũng phụ thuộc `iframe.contentWindow` để
chạy JS trong game context → **cả 3 script fail silently, không bao giờ chạy**:

| Script | Mục đích | Hậu quả khi không chạy |
|--------|---------|------------------------|
| `earlyWebFix` | Polyfill `screen.orientation` cho Cocos | Thường an toàn — Firefox có `screen.orientation` native |
| `postLoadWebFix` | Reset `cc.view._orientationChanging`, dispatch resize | `_orientationChanging` có thể kẹt → rendering freeze |
| `bridgeShim` | Setup `window.GameHost` bridge | Game không thể gọi Flutter *\*xem ghi chú* |

> **\*Ghi chú về bridge:** Game team đã xác nhận họ dùng `window.parent.postMessage`
> trực tiếp (không qua `window.GameHost`). Firefox **không block** `postMessage`
> từ child iframe → parent. Vì vậy `bridgeShim` không phải nguyên nhân gây
> black screen trong trường hợp này.

### Sơ đồ luồng lỗi đầy đủ

```
Firefox mở game in-house
         │
         ▼
flutter_inappwebview_web tạo <iframe src="fish.sunwin.qa">
iframeAllow (Feature Policy format) → Firefox bỏ qua ①
         │
         ▼
web_support.js chạy trên web.sun88.win
  iframe.contentWindow.location.href → DOMException ④
  iframe.contentWindow.console       → DOMException ④
  iframe.contentWindow.history       → DOMException ④
  window.flutter_inappwebview.callHandler KHÔNG được inject
         │
         ▼
IHInAppRunnerCtrl.onWebViewCreated()
  evaluateJavascript(earlyWebFix)   → contentWindow blocked → fail silently
IHInAppRunnerCtrl.updateState(loaded)
  evaluateJavascript(postLoadWebFix) → fail silently
  evaluateJavascript(bridgeShim)     → fail silently
         │
         ▼
Game (Cocos) khởi tạo KHÔNG có post-load fixes
  cc.view._orientationChanging có thể kẹt → rendering freeze
         │
         ▼
    BLACK SCREEN 🖤
```

---

## Tại sao Chrome/Safari không bị?

| Browser | SOP cho `contentWindow` | Ghi chú |
|---------|------------------------|---------|
| Chrome  | ⚠️ Cho phép một phần | Dùng thêm cơ chế inject qua DevTools Protocol |
| Safari  | ⚠️ Ít strict hơn spec | Cho phép một số property access |
| Firefox | ❌ Strict theo spec W3C | Block hoàn toàn — behavior đúng nhất |

---

## Các yếu tố phụ (không gây black screen trực tiếp)

**`WEBGL_debug_renderer_info` deprecated (②):**
Extension vẫn hoạt động, chỉ là warning. Không gây crash.

**Quirks Mode (③):**
Game page `fish.sunwin.qa` thiếu `<!DOCTYPE html>`. Firefox render Quirks Mode
→ một số CSS/layout bị sai. Không trực tiếp gây black screen, nhưng ảnh hưởng
UX. Cần game team thêm DOCTYPE vào HTML.

---

## Các hướng fix

### Fix A — Show "Browser không hỗ trợ" notice (backup plan)

Detect Firefox và show notice, tương tự `isLivestreamUnsupportedBrowser`.
Nhanh, an toàn, nhưng block Firefox hoàn toàn.

### Fix B — Same-origin serving (fix triệt để, dài hạn)

Serve game tại `web.sun88.win/games/fish/` thay vì `fish.sunwin.qa`.
Same-origin → `contentWindow` access không bị block → mọi thứ hoạt động.
Cần cấu hình reverse proxy phía backend.

### Fix C — Sửa `iframeAllow` sang Permissions Policy format

```dart
// TRƯỚC (Feature Policy — Firefox bỏ qua):
iframeAllow: 'autoplay *; fullscreen *; accelerometer *; ...'

// SAU (Permissions Policy — tất cả browsers hiểu):
iframeAllow: 'autoplay; fullscreen; accelerometer; gyroscope; '
             'camera; microphone; geolocation; '
             'clipboard-read; clipboard-write; payment; midi'
```

Không fix black screen nhưng restore permissions bị mất trên Firefox.
**Nên làm kèm với bất kỳ fix nào khác.**

### Fix D — Game-side polyfills (cần game team)

Game server tự include `screen.orientation` polyfill và bỏ `<!DOCTYPE html>`.
Không phụ thuộc Flutter inject từ ngoài vào. Cần phối hợp game team.

### Fix E — Firefox-specific raw `IFrameElement` strategy ✅ Planned

Bypass `flutter_inappwebview_web` hoàn toàn trên Firefox. Dùng `HtmlElementView`
(cùng pattern với `PLRunner`) tạo raw `<iframe>` trực tiếp.

**Khả thi vì:**
- Game team dùng `window.parent.postMessage` native — Firefox không block
- `WebMessageListenerMixin` đã có sẵn, hoạt động cross-origin
- `PLRunner` đã có tiền lệ `HtmlElementView.fromTagName('iframe', ...)`

---

## Kế hoạch triển khai Fix E

### Kiến trúc mới

```
IHRunner.build()
  ├── kIsWeb && isFirefoxBrowser
  │    └── IHFirefoxRunnerView       (MỚI — raw HTMLIFrameElement)
  │          ├── HtmlElementView.fromTagName('iframe', ...)
  │          │     allow: Permissions Policy format
  │          └── WebMessageListenerMixin
  │                window.addEventListener('message', ...)
  │                → IHFirefoxRunnerCtrl.processHostMessage()
  │
  └── else (Chrome / Safari / App)
       └── IHInAppRunnerView         (hiện tại — flutter_inappwebview)
```

### Danh sách file

| File | Loại | Package path |
|------|------|-------------|
| `web/ih_firefox_runner_ctrl.dart` | **MỚI** | `lib/src/ih_runner/web/` |
| `web/ih_firefox_runner_view.dart` | **MỚI** | `lib/src/ih_runner/web/` |
| `web/ih_runner_browser_detect_web.dart` | **MỚI** | `lib/src/ih_runner/web/` |
| `web/ih_runner_browser_detect_stub.dart` | **MỚI** | `lib/src/ih_runner/web/` |
| `ih_runner.dart` | **SỬA** | `lib/src/ih_runner/` |
| `inapp/inapp_runner_view.dart` | **SỬA** | `lib/src/ih_runner/inapp/` |

### Phase 1 — Firefox browser detection (nội bộ game_engine)

Không dùng `isFirefoxWeb` từ main app vì `game_engine` phải độc lập.
Thêm UA check riêng:

```
lib/src/ih_runner/web/ih_runner_browser_detect_stub.dart
lib/src/ih_runner/web/ih_runner_browser_detect_web.dart
```

```dart
// stub — native platforms
bool get isFirefoxBrowser => false;

// web — UA check
bool get isFirefoxBrowser {
  final ua = web.window.navigator.userAgent;
  return ua.contains('Firefox/') || ua.contains('FxiOS');
}
```

Import trong `ih_runner.dart` dùng conditional import:
```dart
import 'web/ih_runner_browser_detect_stub.dart'
    if (dart.library.js_interop) 'web/ih_runner_browser_detect_web.dart';
```

### Phase 2 — Controller tối giản cho Firefox

```
lib/src/ih_runner/web/ih_firefox_runner_ctrl.dart
```

```dart
class IHFirefoxRunnerCtrl extends IHRunnerCtrl with GameBridgeMixin {
  // State machine giống IHInAppRunnerCtrl
  // KHÔNG có: evaluateJavascript, setupHostBridge, applyWebFixes

  @override
  void updateState(IHRunnerState newState, {String? url, String? message}) { ... }

  @override
  Future<dynamic> evaluateJavascript(String source) async => null; // no-op

  void processMessage(dynamic data) {
    // Nhận từ WebMessageListenerMixin → forward sang processHostMessage
    processHostMessage(data);
  }
}
```

### Phase 3 — View dùng raw HTMLIFrameElement

```
lib/src/ih_runner/web/ih_firefox_runner_view.dart
```

```dart
class IHFirefoxRunnerView extends StatefulWidget with WebMessageListenerMixin {
  ...
  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as web.HTMLIFrameElement;
        iframe.src = gameUrl;
        // Permissions Policy format — Firefox hiểu
        iframe.allow = 'autoplay; fullscreen; accelerometer; gyroscope; '
                       'camera; microphone; geolocation; '
                       'clipboard-read; clipboard-write; payment; midi';
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.background = 'transparent';

        controller.updateState(IHRunnerState.loading);
        iframe.onLoad.listen((_) => controller.updateState(IHRunnerState.loaded));
        iframe.onError.listen((_) => controller.updateState(IHRunnerState.error));
      },
    );
  }

  @override
  void onMessageReceive(dynamic data) {
    // Nhận window.parent.postMessage từ game → forward về notifier
    controller.processMessage(data);
  }
}
```

### Phase 4 — Thêm Firefox branch vào `IHRunner`

```dart
// ih_runner.dart
@override
Widget build(BuildContext context) {
  if (kIsWeb && isFirefoxBrowser) {
    return IHFirefoxRunnerView(
      gameUrl: widget.gameUrl,
      controller: _firefoxCtrl,
      logger: widget.logger,
      enableHostMessage: widget.enableHostMessage,
    );
  }
  return IHInAppRunnerView(          // unchanged — Chrome/Safari/App
    gameUrl: widget.gameUrl,
    controller: _ctrl,
    logger: widget.logger,
    enableHostMessage: widget.enableHostMessage,
  );
}
```

### Phase 5 — Fix `iframeAllow` trong `IHInAppRunnerView`

```dart
// inapp_runner_view.dart
iframeAllow: 'autoplay; fullscreen; accelerometer; gyroscope; '
             'camera; microphone; geolocation; '
             'clipboard-read; clipboard-write; payment; midi',
```

---

## Test matrix

#### App Native

| OS | IHRunner | PLRunner |
|----|----------|----------|
| iOS / Android / macOS | ✅ WebView | ✅ WebView |

#### Web — Desktop *(Windows / macOS / Linux)*

| Browser | IHRunner | PLRunner |
|---------|----------|----------|
| Chrome / Edge / Safari | ✅ WebView | ✅ WebView |
| Firefox | ⚠️ Notice | ⚠️ Notice |

#### Web — Android

| Browser | Device | IHRunner | PLRunner |
|---------|--------|----------|----------|
| Chrome / Samsung Internet | Phone | ✅ Redirect | ✅ WebView |
| Firefox | Phone | ✅ Redirect | ✅ New tab |
| Chrome / Samsung Internet | Tablet | ⚠️ Redirect* | ✅ WebView |
| Firefox | Tablet | ⚠️ Redirect* | ✅ New tab |

> `*` Android tablet bị detect nhầm là phone. Known issue — planned fix.

#### Web — iOS / iPadOS *(tất cả browser chạy WebKit)*

| Browser | Device | IHRunner | PLRunner |
|---------|--------|----------|----------|
| Safari | iPhone / iPod | ✅ Redirect | ✅ New tab |
| Chrome / Edge / Other | iPhone / iPod | ✅ Redirect | ❓ WebView |
| Firefox (FxiOS) | iPhone / iPod | ✅ Redirect | ✅ New tab |
| Safari / Chrome / Edge | iPad | ✅ WebView | ✅ WebView |
| Firefox (FxiOS) | iPad | ⚠️ Notice | ⚠️ Notice |

---

## Ghi chú về các scripts hiện tại

```dart
// ih_runner_scripts.dart

// earlyWebFix — SAFE to skip on Firefox
// Firefox có screen.orientation native → guard 'if undefined' tự skip
// earlyWebFix chưa bao giờ cần thiết trên Firefox
static const String earlyWebFix = '''...''';

// postLoadWebFix — gap còn lại sau Fix E
// Không thể inject vào cross-origin iframe dù dùng raw HtmlElementView
// Nếu cc.view._orientationChanging gây ra vấn đề → yêu cầu game team tự fix
static const String postLoadWebFix = '''...''';
```

---

---

## PLRunner — Phân tích & Fix riêng

### Điểm khác biệt với IHRunner

| | IHRunner | PLRunner |
|-|----------|----------|
| Script injection | `earlyWebFix`, `postLoadWebFix`, `bridgeShim` | `orientationPolyfill`, `landscapeViewport`, `fullscreenBlocker` |
| Bridge game → Flutter | Cần (game dùng `window.parent.postMessage`) | **Không cần** (3rd-party game tự render, không callback Flutter) |
| Raw iframe path | Chưa có → cần tạo mới (Fix E) | **Đã có sẵn** via `useInAppWebViewOnWeb = false` |

### Tại sao PLRunner bị black screen trên Firefox

`PLRunner` web mặc định dùng `useInAppWebViewOnWeb = true` → route sang
`PLInAppRunnerView` → `flutter_inappwebview_web` → `web_support.js` fail →
`initialUserScripts` không được inject → game render sai hoặc đen.

```
PLRunner (web, default)
    useInAppWebViewOnWeb = true
    └── PLInAppRunnerView (flutter_inappwebview)
          initialUserScripts:
            - orientationPolyfill  → bị block (cross-origin) ❌
            - landscapeViewport    → bị block ❌
            - fullscreenBlocker    → bị block ❌
          → Game 3rd-party render sai orientation hoặc đen 🖤
```

### Fix F — Firefox dùng raw iframe path đã có sẵn

`PLRunnerWebImpl` đã có sẵn nhánh `useInAppWebViewOnWeb = false` dùng
`HtmlElementView.fromTagName('iframe', ...)`. Chỉ cần force Firefox sang nhánh này:

```dart
// pl_runner_web.dart — _PLRunnerWebState.build()
final useInApp = widget.useInAppWebViewOnWeb && !isFirefoxBrowser;
if (useInApp) {
  return PLInAppRunnerView(...);        // Chrome / Safari / App
}
// Firefox (và khi useInAppWebViewOnWeb = false): raw iframe
return HtmlElementView.fromTagName(
  tagName: 'iframe',
  onElementCreated: (element) {
    final iframe = element as web.HTMLIFrameElement;
    iframe.src = widget.gameUrl;
    // Thêm Permissions Policy format (Fix C kèm theo)
    iframe.allow = 'autoplay; fullscreen; accelerometer; gyroscope; '
                   'camera; microphone; geolocation; '
                   'clipboard-read; clipboard-write; payment; midi';
    ...
  },
);
```

### Scripts bị mất khi dùng raw iframe (PLRunner trên Firefox)

| Script | Tác dụng | Firefox desktop có cần? |
|--------|---------|------------------------|
| `orientationPolyfill` | Fix `screen.width/height` cho iOS landscape | ❌ Không — desktop Firefox đã landscape |
| `landscapeViewport` | Force `<meta viewport>` landscape | ❌ Không quan trọng trên desktop |
| `fullscreenBlocker` | Chặn native fullscreen | ⚠️ Mất — game có thể trigger fullscreen |
| `diagnostics` | Debug log only | ❌ Không cần production |

**Kết luận:** Mất scripts không ảnh hưởng nghiêm trọng trên Firefox desktop.
`fullscreenBlocker` là rủi ro nhỏ nhất — nếu cần có thể inject riêng sau.

### Danh sách file thay đổi cho PLRunner (Fix F)

| File | Loại | Mô tả |
|------|------|-------|
| `pl_runner/web/pl_runner_web.dart` | **SỬA** | Thêm Firefox check, force raw iframe path, add `iframe.allow` |
| `web/ih_runner_browser_detect_web.dart` | **DÙNG CHUNG** | Shared với IHRunner (Fix E) |
| `web/ih_runner_browser_detect_stub.dart` | **DÙNG CHUNG** | Shared với IHRunner (Fix E) |


*Cập nhật lần cuối: 2026-06-05 (thêm PLRunner section — Fix F)*

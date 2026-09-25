# Game Player — Các vấn đề đã biết & Giải pháp

> Tài liệu này ghi lại các bug, workaround và giải pháp liên quan đến
> module **Game Player** (`lib/features/game/player/`).

---

## Mục lục

1. [Android: WebView mất kết nối khi resume từ background](#1-android-webview-mất-kết-nối-khi-resume-từ-background)
2. [Flutter Web: WebView bị unmount khi xoay màn hình](#2-flutter-web-webview-bị-unmount-khi-xoay-màn-hình)
3. [iPadOS: WebView render sai layout khi xoay màn hình](#3-ipados-webview-render-sai-layout-khi-xoay-màn-hình)
4. [iOS Safari: App crash/reset khi load game trong iframe](#4-ios-safari-app-crashreset-khi-load-game-trong-iframe)
5. [iPad: Game hiển thị Mobile layout dù đang ở Landscape](#5-ipad-game-hiển-thị-mobile-layout-dù-đang-ở-landscape)
6. [Firefox: Màn hình đen khi load game In-House (Cocos/WebGL)](#6-firefox-màn-hình-đen-khi-load-game-in-house-coswebgl)

---

## 1. Android: WebView mất kết nối khi resume từ background

| Mục | Chi tiết |
|-----|----------|
| **Ticket** | GSB-90 |
| **Platform** | Android (mobile) |
| **Trạng thái** | ✅ Đã fix |
| **File liên quan** | [`game_web_view_mobile.dart`](../web_view/game_web_view_mobile.dart) |

### Triệu chứng

Khi user mở game → đưa app vào background khoảng 30 giây đến 1 phút → mở lại
app → màn hình game hiển thị **error overlay** với thông báo lỗi:

```
code: -6
description: net::ERR_CONNECTION_ABORTED
errorType: WebResourceErrorType.connect
isForMainFrame: true
```

### Nguyên nhân gốc (Root Cause)

Android **tự động cắt kết nối mạng** của WebView khi app ở background nhằm tiết
kiệm tài nguyên và pin. Khi user quay lại app, WebView cố gắng tiếp tục load
tài nguyên nhưng tất cả các TCP connection đã bị hệ điều hành hủy →
`net::ERR_CONNECTION_ABORTED`.

Flow lỗi cũ:

```
App Background → Android kills WebView TCP connections
       ↓
App Resume → WebView reports ERR_CONNECTION_ABORTED (-6)
       ↓
_onWebResourceError() → gọi widget.onError?.call()
       ↓
GamePlayerNotifier.handleError() → set errorMessage
       ↓
_ErrorOverlay hiển thị lỗi ← User phải nhấn Retry thủ công ❌
```

### Giải pháp: Auto-Retry Transient Errors

Thêm cơ chế **auto-retry** trong `_onWebResourceError()` của
`game_web_view_mobile.dart`. Khi phát hiện lỗi thuộc nhóm **transient
connection error**, WebView sẽ tự động reload thay vì báo lỗi cho user.

#### Transient Error Codes được xử lý

| Code | Tên | Khi nào xảy ra |
|------|-----|-----------------|
| `-6` | `ERR_CONNECTION_ABORTED` | OS cắt connection khi app ở background |
| `-2` | `ERR_INTERNET_DISCONNECTED` | Mất mạng tạm thời |
| `-7` | `ERR_CONNECTION_TIMED_OUT` | Timeout sau resume |
| `-8` | `ERR_CONNECTION_RESET` | Connection bị reset bởi peer |
| `-15` | `ERR_SOCKET_NOT_CONNECTED` | Socket bị OS thu hồi |

#### Flow mới

```
App Resume → WebView reports transient error (-6, -2, -7, -8, -15)
       ↓
_onWebResourceError() kiểm tra:
  ├── retryCount < maxRetries (2)?
  │    ├── YES → log warning, chờ 500ms, gọi _controller.reload()
  │    │         Reset _hasNotifiedLoadStart/Stop cho chu kỳ load mới
  │    └── NO  → báo lỗi cho notifier (hiện Error Overlay)
  │
  └── Khi load thành công (_onPageFinished):
       → reset retryCount = 0 (sẵn sàng cho lần background tiếp theo)
```

#### Code reference

```dart
// game_web_view_mobile.dart

// Retry counter & max
int _transientRetryCount = 0;
static const _kMaxTransientRetries = 2;

// In _onWebResourceError:
const transientErrorCodes = {-6, -2, -7, -8, -15};

if (transientErrorCodes.contains(error.errorCode) &&
    _transientRetryCount < _kMaxTransientRetries) {
  _transientRetryCount++;
  Future<void>.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _controller.reload();
    }
  });
  return; // Don't report error to notifier
}

// In _onPageFinished:
_transientRetryCount = 0; // Reset for next background cycle
```

### Cách kiểm tra

1. Mở app trên thiết bị Android thật
2. Vào bất kỳ game nào (ví dụ: Sexy provider)
3. Đợi game load hoàn tất
4. Nhấn Home để đưa app vào background
5. Đợi 30 giây – 1 phút
6. Mở lại app

**Kết quả mong đợi:**
- Log hiện: `⚠️ Transient connection error (code: -6, attempt: 1/2). Auto-reloading WebView...`
- WebView tự reload thành công, **không hiện Error Overlay**
- Game tiếp tục hoạt động bình thường

**Kết quả nếu retry thất bại (sau 2 lần):**
- Log hiện error chi tiết
- Error Overlay hiển thị với nút Retry cho user

---

## 2. Flutter Web: WebView bị unmount khi xoay màn hình

| Mục | Chi tiết |
|-----|----------|
| **Platform** | Flutter Web (Chrome) |
| **Trạng thái** | ✅ Đã fix |
| **File liên quan** | [`game_player_scaffold.dart`](../widget/game_player_scaffold.dart), [`web/game_web_view_web.dart`](../web_view/src/web/game_web_view_web.dart) |

### Triệu chứng

Khi user xoay thiết bị (hoặc resize cửa sổ trên desktop), iframe WebView bị
**destroy và không thể tái tạo**. Game dừng lại hoàn toàn.

### Nguyên nhân gốc

`GamePlayerScaffold` trước đây dùng `OrientationBuilder` để switch giữa hai
layout khác nhau (Portrait: `Column`, Landscape: `Row`). Khi orientation thay
đổi, Flutter rebuild widget tree với widget type khác → `HtmlElementView`
(iframe) bị unmount → iframe bị hủy.

### Giải pháp

Thay thế `OrientationBuilder` + `Column`/`Row` bằng **`Stack` +
`AnimatedPositioned`** trong `_AdaptiveGameLayout`. Widget tree giữ nguyên
cấu trúc bất kể orientation — chỉ thay đổi vị trí (position) của các thành
phần:

- **Portrait**: Top bar (back button) + content bên dưới
- **Landscape**: Left sidebar + content + Right sidebar

Vì widget type không thay đổi → iframe không bị unmount → game tiếp tục chạy.

---

## 3. iPadOS: Nháy giao diện và Giựt màn hình khi vào/thoát game

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iPad / iPadOS (Native) |
| **Trạng thái** | ✅ Đã fix (v2.2) |
| **File liên quan** | `game_player_notifier.dart`, `game_player_screen.dart`, `orientation_guard` package |

### Triệu chứng
1. **Nháy (Flicker)**: Khi thoát game, màn hình Home hiện ra và báo lỗi "sai hướng xoay" trong tích tắc trước khi iPad kịp xoay về Portrait.
2. **Giựt (Double Rotation)**: Màn hình iPad xoay 2 lần liên tục khi đóng game.
3. **Crash**: Lỗi `Bad state` hoặc `setState() when locked` khi đóng game nhanh.

### Giải pháp: Active Lifecycle & Single Driver
Chuyển từ việc "đợi hệ thống" sang "chủ động điều phối":
- **Single Driver**: Loại bỏ việc gọi xoay màn hình từ nhiều nơi. Chỉ Notifier điều khiển lệnh xoay chính xác theo trình tự: Xoay xong mới load, và Xoay về xong mới thoát.
- **isApplying**: Thêm trạng thái xoay toàn cục. Khi đang xoay, mọi cảnh báo sai hướng sẽ bị ẩn đi (suppressed) để tránh nháy.
- **Smooth Exit**: Mọi hành động thoát gọi qua `requestExit()`. Hệ thống sẽ khóa UI, thực hiện lệnh `restore` mượt mà, rồi mới phát sự kiện `pop` cho UI.

---

## 4. iOS Safari: App crash/reset khi load game trong iframe

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iOS Safari mobile (Flutter Web) |
| **Trạng thái** | ✅ Đã fix bằng open-in-new-tab strategy |
| **Provider bị ảnh hưởng** | `amb-vn`, `lcevo`, `vivo`, `via-casino-vn` |
| **File liên quan** | [`game_block.dart`](../../../../core/services/repositories/game_repository/src/models/game_block.dart), [`game_player_screen.dart`](../game_player_screen.dart), [`web/game_web_view_web.dart`](../web_view/src/web/game_web_view_web.dart), [`index.html`](../../../../../web/index.html) |

### Root cause: WebContent Process Sharing

Khi game load trong **iframe**, Flutter CanvasKit và game **chia sẻ cùng 1 WebContent process**.
Các provider nặng dùng WebGL + live video + WebSocket → tổng RAM/GPU vượt giới hạn iOS (~1GB) → Safari kill process → app reset.

Khi game mở ở **tab mới**, mỗi tab có **process riêng** với memory/GPU riêng → không bị crash.

### Giải pháp: Open-in-new-tab (ĐÃ IMPLEMENT)

- Thêm `openInNewTabOnIOSSafariWeb: true` vào `_providerOverrides` trong `game_block.dart` cho các provider nặng
- Khi `kIsWeb && isIOSSafariWeb && game.openInNewTabOnIOSSafariWeb`, `_WebViewLayer` hiển thị `NewTabGamePlaceholder` thay vì iframe
- Game tự động mở ở tab mới bằng `url_launcher`
- UI hiện placeholder "Game đang chơi ở tab khác" + nút "Mở lại game" + "Quay lại"

> **Thiết kế của `openInNewTabOnIOSSafariWeb`:**
> Flag này **chỉ có tác dụng trên iOS Safari Web**. Tên được đặt rõ ràng để tránh nhầm lẫn
> với các tính năng "open in new tab" mang tính chất khác.
> Trên Android, Chrome, PC — game vẫn load bình thường trong iframe.

### Provider đang áp dụng flag

| Provider ID | Lý do |
|-------------|-------|
| `amb-vn` | WebGL + live FLV video + 3 WebSocket (~1GB RAM peak) |
| `lcevo` | WebGL + live video (Evolution Gaming) |
| `vivo` | Heavy game engine |
| `via-casino-vn` | + `forceLandscapeViewportOnIpad: true` (xem Issue 5) |

### Triệu chứng

Khi user mở game trên iOS Safari → game bắt đầu load → khi game gần load xong
(WebSocket connected, game initialized) → toàn bộ app bị **reset về màn hình Login**.
Safari hiện dialog hỏi có muốn report crash hay không.

### Nguyên nhân đã điều tra

#### ❌ Cause 1: Top-level navigation hijack (ĐÃ THÊM SANDBOX — chưa fix)

Iframe game không có `sandbox` attribute. JavaScript trong iframe có thể truy
cập `window.top.location` và redirect toàn bộ Flutter app đi nơi khác.

**Đã thêm `sandbox` attribute** nhưng vấn đề vẫn xảy ra → không phải nguyên nhân chính.

#### 🔴 Cause 2: `index.html` Layout Thrashing (ĐÃ FIX)

```javascript
// TRƯỚC KHI FIX:
setInterval(hideLoading, 50);  // 20 lần/giây, FOREVER
MutationObserver trên toàn bộ body  // trigger mỗi DOM change
```

→ **Layout thrashing**: 20 force-layout/giây × tất cả element = CPU cực nặng → crash.

#### 🟡 Cause 3: Safari WebContent process crash (memory/GPU)

Game live casino dùng WebGL + FLV video + 3 WebSocket → vượt giới hạn RAM iOS (~1GB) → process crash.

### Giải pháp đã áp dụng

#### Fix 1: Iframe Sandbox + Feature Policy

```dart
_iframe!.setAttribute(
  'sandbox',
  'allow-scripts allow-same-origin allow-forms allow-popups '
      'allow-presentation allow-modals allow-popups-to-escape-sandbox',
);
_iframe!.setAttribute(
  'allow',
  'autoplay; fullscreen; encrypted-media; web-share',
);
```

#### Fix 2: Gỡ bỏ Layout Thrashing trong `index.html`

```diff
-setInterval(hideLoading, 50);  // RUN FOREVER → crash
+setTimeout(hideLoading, 100);
+setTimeout(hideLoading, 500);
+setTimeout(hideLoading, 1000);
+setTimeout(hideLoading, 2000);
+setTimeout(function() { observer.disconnect(); }, 3000);
```

### Sandbox permissions giải thích

| Permission | Mục đích | Có/Không |
|------------|----------|----------|
| `allow-scripts` | Game JS execution | ✅ Có |
| `allow-same-origin` | Cookies, WebSocket, localStorage | ✅ Có |
| `allow-forms` | Form submit trong game | ✅ Có |
| `allow-popups` | Popup cho payment/support | ✅ Có |
| `allow-presentation` | Fullscreen API | ✅ Có |
| `allow-modals` | alert/confirm dialogs | ✅ Có |
| `allow-popups-to-escape-sandbox` | Popup hoạt động bình thường | ✅ Có |
| `allow-top-navigation` | **Redirect parent window** | ❌ **BỊ CHẶN** |
| `allow-top-navigation-by-user-activation` | **Redirect khi user click** | ❌ **BỊ CHẶN** |

### Cách kiểm tra

1. Mở app trên iOS Safari mobile
2. Vào game của provider được cấu hình `openInNewTabOnIOSSafariWeb: true`
3. Game phải tự mở tab mới + hiện placeholder trong Flutter app

**Kết quả mong đợi:**
- Flutter app hiện `NewTabGamePlaceholder` (không crash)
- Game load ở tab Safari mới, không bị reset

---

## 5. iPad: Game hiển thị Mobile layout dù đang ở Landscape

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iPad / iPadOS (native mobile — không phải Flutter Web) |
| **Trạng thái** | ✅ Đã fix |
| **Provider bị ảnh hưởng** | `via-casino-vn` và các provider có `forceLandscapeViewportOnIpad: true` |
| **File liên quan** | [`inapp_runner_ctrl.dart`](../../../../../packages/game_engine/lib/src/provider_live_runner/inapp/inapp_runner_ctrl.dart), [`game_block.dart`](../../../../core/services/repositories/game_repository/src/models/game_block.dart), [`game_extensions.dart`](../../game_extensions.dart) |

### Triệu chứng

Trên iPad, khi mở game live casino (ví dụ: VIA Casino), game **luôn hiển thị
layout Mobile** (giao diện thu hẹp, thiếu bảng cược full, v.v.) dù thiết bị
đang ở Landscape và app đã lock đúng `landscapeRight`.

### Nguyên nhân gốc

iOS/iPadOS có một quirk quan trọng: **`screen.width` và `screen.height` không
đổi theo chiều xoay của thiết bị** — chúng luôn trả về kích thước theo hướng
"boot orientation" (thường là portrait). Game engine lại phụ thuộc vào
`window.matchMedia('(orientation: landscape)')`, trong khi API này dựa trên
`window.innerWidth/innerHeight` (kích thước viewport thực tế).

**Vấn đề:** Trong giai đoạn khởi tạo WebView, `innerWidth` và `innerHeight` đều
là `0`. Khi đó `matchMedia('(orientation: landscape)')` → `0 > 0` → `false`
→ game engine khởi tạo layout Mobile và **không thay đổi sau đó**.

```
WebView created → innerWidth=0, innerHeight=0
       ↓
matchMedia('orientation: landscape') → 0 > 0 → FALSE
       ↓
Game engine: "Đây là portrait/mobile device"
       ↓
Game khởi tạo layout Mobile → KHÔNG tự thay đổi sau đó ❌
```

### Các giải pháp đã thử (thất bại)

| Phương pháp | Kết quả |
|-------------|---------|
| Patch `screen.width/height` | JS engine nhận đúng, nhưng `matchMedia` vẫn sai |
| Patch `screen.orientation.type` | Không đủ — game engine ưu tiên `matchMedia` |
| Delay WebView load | Tỉ lệ thành công ~85%, vẫn thất bại khoảng 1-2 lần/10 |

### Giải pháp: Patch `window.matchMedia` (ĐÃ IMPLEMENT)

**File:** `packages/game_engine/lib/src/provider_live_runner/inapp/inapp_runner_ctrl.dart`

Khi `forceLandscapeViewport = true`, inject script để intercept toàn bộ
`window.matchMedia` API. Các query về `orientation:landscape/portrait` được trả
về giá trị đúng **ngay từ đầu**, trước khi game engine khởi tạo.

```javascript
window.matchMedia = function(query) {
  const real = origMatchMedia(query);
  const isLandscapeQuery = query.includes('orientation') &&
                           query.includes('landscape');
  const isPortraitQuery  = query.includes('orientation') &&
                           query.includes('portrait');

  if (!isLandscapeQuery && !isPortraitQuery) return real; // pass-through

  const fake = Object.create(real);
  Object.defineProperty(fake, 'matches', {
    get: () => isLandscapeQuery, // landscape → true, portrait → false
  });
  // Support both modern addEventListener and legacy addListener
  fake.addEventListener = (type, listener) => {
    if (type === 'change') listener(fake); // fire immediately
  };
  fake.addListener = (listener) => listener(fake);
  return fake;
};
```

**Đặc điểm của patch:**
- **Idempotent**: kiểm tra `window.__matchMediaPatched` để không patch 2 lần
- **Targeted**: chỉ override orientation queries, các query khác (dark mode, width) pass-through
- **Zero side-effects**: dùng `Object.create(real)` để kế thừa toàn bộ properties gốc

### Kiến trúc sau khi fix

#### 1. Cấu hình trong `GameBlock`

```dart
// game_block.dart — _providerOverrides
'via-casino-vn': _ProviderOverride(
  tabletOrientation: [GameOrientation.landscapeRight],
  forceLandscapeViewportOnIpad: true,  // Kích hoạt JS polyfill trên iPad
  openInNewTabOnIOSSafariWeb: true,    // Mở tab mới trên iOS Safari Web
),
```

Trường `forceLandscapeViewportOnIpad` chỉ có tác dụng khi cả 2 điều kiện thỏa:
1. Thiết bị là **tablet** (`shortestSide >= 600`)
2. **Tất cả** `tabletOrientation` đều là landscape

#### 2. Logic kiểm tra tập trung tại `GameBlockX`

```dart
// game_extensions.dart
bool shouldForceLandscapeViewport(BuildContext context) {
  if (!forceLandscapeViewportOnIpad) return false;

  final shortestSide = MediaQuery.sizeOf(context).shortestSide;
  if (shortestSide < 600) return false; // Only for tablets

  // Only inject when ALL tablet orientations are landscape.
  return tabletOrientation.every((o) => o.isLandscape);
}
```

> **Tại sao tập trung ở đây?**
> Trước đây, logic này nằm inline trong `GamePlayerScreen` (UI layer).
> Đã move vào `GameBlockX` extension để: (1) dễ test, (2) nhất quán khi
> nhiều widget cần truy vấn giá trị này.

#### 3. Sử dụng trong UI

```dart
// game_player_screen.dart
PLRunner(
  forceLandscapeViewport: widget.game.shouldForceLandscapeViewport(context),
)
```

### Debug

Kiểm tra log `[PLRunner:DIAG]` trong Flutter console:

```json
{
  "screen_wh": "1210x834",
  "matchMedia_landscape": true,   // ← PHẢI là true khi đang landscape
  "matchMedia_portrait": false,
  ...
}
```

- `matchMedia_landscape: false` → polyfill chưa chạy hoặc bị skip
- Kiểm tra `shouldForceLandscapeViewport` có trả về `true`
- Kiểm tra log `[PLRunner] _applyAllInjections — forceLandscape=true`

### Cách kiểm tra

1. Mở app trên **iPad thật** (không phải Simulator)
2. Vào game VIA Casino (Lotto Baccarat hoặc tương tự)
3. App lock landscape → game load

**Kết quả mong đợi:**
- Game hiển thị **layout Tablet Landscape** (bảng cược full, UI rộng)
- Log: `matchMedia_landscape: true`

---

## Kiến trúc tổng quan Game Player (v2.0)

```
GamePlayerScreen (ConsumerStatefulWidget)
├── PopScope (canPop: false) → Chặn thoát đột ngột, chuyển hướng về requestExit()
└── GamePlayerBackground
    └── Stack
        ├── GamePlayerScaffold (onGoBack → requestExit)
        │   └── _AdaptiveGameLayout (Stack-based, stable iframe)
        │       └── _WebViewLayer (Hiện khi isOrientationReady = true)
        ├── _LoadingOverlay (Brand loading cho: settingUp, connecting, loadingAssets)
        ├── _ErrorOverlay (Xử lý lỗi error/maintenance)
        └── _TransitionOverlay (Hiện overlay mờ trong trạng thái exiting)

GamePlayerNotifier (Active Controller)
├── Flow: settingUp → connecting → loadingAssets → playing
├── requestExit() → stage: exiting → await restore() → emit ExitEvent
└── Safe disposal: Kiểm tra _isDisposed sau mỗi lệnh await.
```

---

---

## 6. Firefox: Hỗ trợ hạn chế khi load game

| Mục | Chi tiết |
|-----|----------|
| **Platform** | Firefox (Flutter Web — desktop & mobile) |
| **Trạng thái** | ⚠️ Đã điều tra đầy đủ — Fix E planned |
| **Game bị ảnh hưởng** | Tất cả game in-house (Sunwin/Cocos) + game 3rd-party (PLRunner) |
| **Tài liệu chi tiết** | [`packages/game_engine/docs/ih_runner_firefox_black_screen.md`](../../../../../../packages/game_engine/docs/ih_runner_firefox_black_screen.md) |
| **Phát hiện** | 2026-06-05 |

### Root cause

`flutter_inappwebview_web` không thể inject JavaScript vào cross-origin iframe trên Firefox
(Firefox enforce SOP nghiêm ngặt theo spec W3C). Scripts (`earlyWebFix`, `bridgeShim`, v.v.)
không bao giờ chạy trong game context → màn hình đen.

Chi tiết đầy đủ: [`game_engine/docs/ih_runner_firefox_black_screen.md`](../../../../../../packages/game_engine/docs/ih_runner_firefox_black_screen.md)

**Hướng fix được chọn:**
- **Fix E (IHRunner):** Bypass `flutter_inappwebview_web`, dùng raw `HtmlElementView` + `WebMessageListenerMixin`. Khả thi vì game team dùng `window.parent.postMessage` native.
- **Fix F (PLRunner):** Đơn giản hơn — PLRunner đã có sẵn path raw iframe (`useInAppWebViewOnWeb = false`), chỉ cần detect Firefox và force sang path đó.

### ⚠️ Cập nhật 2026-07-29 — mobile web có thể NHÚNG thay vì redirect

Ô "Redirect" của **In-house / phone** trong ma trận dưới đây KHÔNG còn đúng.
Mobile web (phone) nay **nhúng iframe** thay vì redirect cả tab: game chạy trong
iframe gắn ở `<body>`, nhờ đó mini game chơi song song được và Safari giấu được
thanh công cụ. Xem `lib/features/game/player/game_player_experiments.dart`
(`embedGameOnMobileWeb`).

Chế độ này cũng đổi đường render: phone web đi `htmlIframe` thay vì
`inAppWebView` (xem `IHRunner._resolvedStrategy`). Desktop, iPad và native giữ
nguyên như ma trận.

Chi tiết + lý do: vault `projects/s88-flutter/docs/mobile-web-casino-embed-shell-2026-07-28.md`.

### Matrix hành vi

#### App Native

| OS | In-house | 3rd-party |
|----|----------|-----------|
| iOS / Android / macOS | ✅ WebView | ✅ WebView |

---

#### Web — Desktop *(Windows / macOS / Linux)*

| Browser | In-house | 3rd-party |
|---------|----------|-----------|
| Chrome / Edge | ✅ WebView | ✅ WebView |
| Safari (macOS) | ✅ WebView | ✅ WebView |
| Firefox | ⚠️ Notice | ⚠️ Notice |

---

#### Web — Android

| Browser | Device | In-house | 3rd-party |
|---------|--------|----------|-----------|
| Chrome / Samsung Internet | Phone | ✅ Redirect | ✅ WebView |
| Firefox | Phone | ✅ Redirect | ✅ New tab |
| Chrome / Samsung Internet | Tablet | ⚠️ Redirect* | ✅ WebView |
| Firefox | Tablet | ⚠️ Redirect* | ✅ New tab |

> `*` Android tablet bị misclassify thành phone (`isWebAndroidBrowser = true`) → bị redirect thay vì WebView/Notice. Known issue, chưa fix.

---

#### Web — iOS / iPadOS *(tất cả browser đều chạy WebKit)*

| Browser | Device | In-house | 3rd-party |
|---------|--------|----------|-----------|
| Safari | iPhone / iPod | ✅ Redirect | ✅ New tab |
| Chrome (CriOS) / Edge / Other | iPhone / iPod | ✅ Redirect | ❓ WebView |
| Firefox (FxiOS) | iPhone / iPod | ✅ Redirect | ✅ New tab |
| Safari / Chrome / Edge | iPad | ✅ WebView | ✅ WebView |
| Firefox (FxiOS) | iPad | ⚠️ Notice | ⚠️ Notice |

> `❓` iPhone non-Safari (Chrome, Edge, Opera...) + 3rd-party: hiện dùng WebView — chưa test thực tế, tiềm ẩn vấn đề WebKit memory tương tự Safari.

---

**Chú thích hành vi:**

| Ký hiệu | Mô tả | Cơ chế trong code |
|---------|-------|-------------------|
| ✅ WebView | Game nhúng trực tiếp trong WebView | `GameRunnerView` → `IHRunner` / `PLRunner` |
| ✅ Redirect | Redirect tab hiện tại sang game URL | `redirectOnIOSSafariWeb` / `redirectOnMobileWeb` |
| ✅ New tab | Mở game trong tab trình duyệt mới | `GamePlayerNewTabPlaceholder` |
| ⚠️ Notice | Hiển thị thông báo "Trình duyệt chưa được hỗ trợ" | `GamePlayerErrorType.unsupportedBrowser()` |

### Files đã thay đổi (workaround)

| File | Thay đổi |
|------|---------|
| `game_player_notifier.dart` | Pre-flight: Firefox desktop/iPad + in-house → unsupported notice |
| `game_player_failure_view.dart` | Case `GamePlayerUnsupportedBrowserError` |
| `game_player_error.dart` | `GamePlayerUnsupportedBrowserError` (errorCode: `GP_UNSUPPORTED_BROWSER`) |
| `game_player_view.dart` | Firefox + 3rd-party → `GamePlayerNewTabPlaceholder` |

### Cách reproduce

**In-house trên Firefox desktop:** `https://web.sun88.win` → mở game Sunwin → thấy thông báo unsupported browser.

**3rd-party trên Firefox:** `https://web.sun88.win` → mở game Live (Baccarat...) → thấy màn hình "Open in new tab" → click → game mở trong tab mới.

---

*Cập nhật lần cuối: 2026-06-05*

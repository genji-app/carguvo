# iOS Safari — Minimal UI (Ẩn Toolbar)

## Vấn đề

iOS Safari **không hỗ trợ** `requestFullscreen()` — đây là ràng buộc bảo mật của Apple,
không phải lỗi của app. Khi gọi API này trên iPhone/iPad Safari, browser ném một
`TypeError: requestFullscreen is not a function`.

Điều này có nghĩa là trên iOS Safari, không thể đạt được "true fullscreen" như trên
Android Chrome hay desktop browser.

---

## Phát hiện iOS Safari (supportsFullscreen)

### Vấn đề với `document.fullscreenEnabled`

Cách phát hiện đơn giản nhất là đọc `document.fullscreenEnabled`. Tuy nhiên, trên
iOS Safari, property này trả về `null` (không phải `false`). Khi Dart cố cast `null`
thành `bool`, nó ném:

```
TypeError: null: type 'Null' is not a subtype of type 'bool'
```

### Giải pháp: `dart:js_interop_unsafe` + `getProperty`

Thay vì đọc `fullscreenEnabled`, kiểm tra xem `requestFullscreen` có tồn tại trên
`documentElement` hay không:

```dart
import 'dart:js_interop_unsafe';

bool get supportsFullscreen {
  try {
    final element = web.document.documentElement;
    if (element == null) return false;
    // getProperty trả về null nếu property không tồn tại (iOS Safari),
    // thay vì ném TypeError như khi đọc trực tiếp.
    final method = (element as JSObject)
        .getProperty<JSAny?>('requestFullscreen'.toJS);
    return method != null;
  } on Object catch (e) {
    _log('supportsFullscreen check failed: $e');
    return false;
  }
}
```

**Tại sao dùng `getProperty` thay vì đọc trực tiếp?**  
Dart's `package:web` binding cho `requestFullscreen` expect property tồn tại và có
kiểu cụ thể. Khi property là `undefined` (iOS Safari), Dart ném TypeError khi cố
đọc. `getProperty<JSAny?>` an toàn hơn vì nó trả về `null` khi property không tồn
tại, không throw.

### Hành vi khi `supportsFullscreen == false`

`FullscreenGuardController.request()` xử lý iOS Safari theo 2 chế độ, tuỳ thuộc
vào flag `requiresGestureOnIosSafari` trong `FullscreenGateRequest`:

#### Chế độ 2: Auto-satisfy (`requiresGestureOnIosSafari: false`)

Gate tự động được satisfy ngay lập tức (không hiện overlay), đồng thời vẫn gọi
`apply()` để trigger scroll trick theo lập trình:

```dart
// isPwaStandalone hoặc !supportsFullscreen + không cần gesture
_isSatisfied = true;
_platformUiController
    .apply(const PlatformUiConfig(fullscreen: true))
    .ignore();
```

UX đơn giản hơn, nhưng toolbar có thể không collapse trên một số phiên bản iOS.

#### Chế độ 1: Gate swipe-up (`requiresGestureOnIosSafari: true`) ← **Default + Khuyến nghị**

Gate overlay được hiển thị. User phải vuốt lên để tiếp tục. Scroll trick chạy
từ trong **user gesture context** → iOS Safari đáng tin cậy hơn khi collapse
toolbar:

```dart
// !supportsFullscreen + requiresGestureOnIosSafari = true
// → _isSatisfied giữ nguyên false → gate hiện lên
// → user vuốt lên → _onProceed() gọi apply() trong context gesture
```

Sử dụng trong game player:
```dart
FullscreenGuard.of(context).request(
  const FullscreenGateRequest(
    tag: 'gamePlayer',
    requiresGestureOnIosSafari: true,
  ),
);
```

---

## Giải pháp: Scroll Trick (Minimal UI)

### Cơ chế hoạt động

iOS Safari hỗ trợ "Minimal UI" — khi `window.scrollY > 0`, browser tự động collapse
thanh toolbar/address bar ở dưới cùng (hoặc trên cùng tùy cài đặt). Đây là hành vi
native của Safari, không cần API đặc biệt.

**Scroll trick** lợi dụng cơ chế này bằng cách:
1. Tạm thời cho phép document scroll (`html.overflow = 'auto'`)
2. Làm body cao hơn viewport 1px (`body.minHeight = 'calc(100% + 1px)'`)
3. Đợi browser reflow (100ms)
4. Scroll xuống 1px (`window.scrollTo(0, 1)`)
5. Giữ nguyên trạng thái → toolbar ở trạng thái collapsed

**Tại sao Flutter cần trick này?**  
Flutter web render trong `<flt-glass-pane>` với `position: fixed`, không có content
flow trong document. Mặc định `overflow: hidden` trên `<html>`. Nếu không thay đổi,
`window.scrollTo(0, 1)` không làm gì cả vì document không scrollable.

### Implementation

```dart
Future<void> _doScrollTrick() async {
  final htmlEl = web.document.documentElement as web.HTMLElement?;
  final body = web.document.body;
  if (htmlEl == null || body == null) return;

  // Bước 1: Cho phép scroll + tạo 1px overflow.
  // Flutter canvas là position:fixed nên không bị ảnh hưởng bởi scroll.
  htmlEl.style.overflow = 'auto';
  body.style.minHeight = 'calc(100% + 1px)';

  // Bước 2: Chờ browser reflow layout mới.
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // Bước 3: Scroll 1px — trigger iOS Safari Minimal UI.
  web.window.scrollTo(0.toJS, 1);

  // QUAN TRỌNG: KHÔNG reset overflow hay minHeight ở đây.
  // Xem phần "Bug: Reset overflow" bên dưới.
}
```

### Cleanup khi thoát game

Khi `restore()` được gọi (user thoát game), `_unblockScroll()` dọn dẹp:

```dart
void _unblockScroll() {
  web.document.documentElement?.removeAttribute('style'); // xóa overflow:auto
  web.document.body?.style.minHeight = '';               // xóa 1px extra
}
```

Sau đó `restore()` scroll về top: `window.scrollTo(0, 0)` → address bar hiện lại.

---

## Bugs gặp phải trong quá trình implement

### Bug 1: TypeError khi đọc `fullscreenEnabled`

**Triệu chứng:**
```
[PlatformUiControllerWeb] supportsFullscreen check failed:
TypeError: null: type 'Null' is not a subtype of type 'bool'
```

**Nguyên nhân:** `document.fullscreenEnabled` trả về `null` trên iOS Safari. Dart
binding expect `bool`, ném TypeError khi nhận `null`.

**Fix:** Dùng `getProperty<JSAny?>('requestFullscreen')` thay vì đọc
`fullscreenEnabled`. Đã giải thích ở phần trên.

---

### Bug 2: Scroll trick không hoạt động (toolbar vẫn hiện)

**Triệu chứng:** Log "requestFullscreen() failed — using scroll trick" xuất hiện,
nhưng toolbar không ẩn, hoặc ẩn ngay rồi hiện lại sau ~400ms.

**Nguyên nhân:** Code cũ reset `html.overflow = ''` và `body.minHeight = ''` sau khi
scroll. Khi `overflow` trở về `hidden`, browser **ép scrollY về 0** — Safari thấy
page ở top, hiển thị lại toolbar ngay lập tức.

```dart
// ❌ Code cũ (sai):
await Future<void>.delayed(const Duration(milliseconds: 400));
htmlEl.style.overflow = '';      // ← Browser snaps scrollY=0
body.style.minHeight = '';       // ← Toolbar hiện lại
```

**Fix:** Xóa toàn bộ đoạn reset. Giữ `overflow: auto` và `minHeight` trong suốt
thời gian ở game screen. Chỉ cleanup khi `restore()` được gọi lúc thoát game.

```dart
// ✅ Code đúng:
// (Không có đoạn reset — dọn dẹp trong _unblockScroll() khi restore())
```

---

### Bug 3: `apply()` không được gọi khi auto-satisfy

**Triệu chứng:** Log không xuất hiện, scroll trick không chạy, toolbar vẫn hiện dù
đã vào game screen.

**Nguyên nhân:** Khi `supportsFullscreen == false`, `FullscreenGuardController`
auto-satisfy gate (`_isSatisfied = true`). Gate overlay không hiện → `_onProceed()`
không được gọi → `platformUiController.apply()` không được gọi → scroll trick
không bao giờ chạy.

**Fix:** Trong `request()`, khi auto-satisfy, cũng gọi `apply()` để trigger scroll
trick:

```dart
if (!_platformUiController.supportsFullscreen || ...) {
  _isSatisfied = true;
  _platformUiController
      .apply(const PlatformUiConfig(fullscreen: true))
      .ignore(); // ← Fix: vẫn apply dù không cần gesture
}
```

---

### Bug 4: `.style` không tồn tại trên `Element?`

**Triệu chứng:**
```
The getter 'style' isn't defined for the class 'Element'.
```

**Nguyên nhân:** `web.document.documentElement` trả về `Element?`, không phải
`HTMLElement?`. `Element` không có `.style` property.

**Fix:** Cast sang `HTMLElement?`:

```dart
// ❌ Sai:
final htmlEl = web.document.documentElement;
htmlEl?.style.overflow = 'auto'; // Error: Element không có style

// ✅ Đúng:
final htmlEl = web.document.documentElement as web.HTMLElement?;
htmlEl?.style.overflow = 'auto'; // OK
```

---

## Giới hạn của scroll trick

| Tình huống | Hành vi |
|-----------|---------|
| iOS Safari — tab bar ở bottom | Toolbar collapse khi scrollY > 0 ✓ |
| iOS Safari — address bar ở top | Address bar collapse khi scrollY > 0 ✓ |
| User tự scroll lên top | Toolbar hiện lại (browser behavior không thể override) |
| Thoát game và quay lại | Scroll trick chạy lại khi `request()` được gọi |
| PWA standalone mode | Không cần scroll trick — toolbar không tồn tại |

---

## So sánh 2 chế độ trigger scroll trick

| Chế độ | `requiresGestureOnIosSafari` | UX | Độ tin cậy |
|--------|-----------------------------|----|-----------|
| Swipe-up gate | `true` **(default)** | Hiện overlay "Vuốt lên", user swipe → vào game | Cao hơn — scrollTo chạy trong call stack của user touch event |
| Auto-satisfy | `false` | Không hiện gate, vào game ngay | Thấp hơn — scrollTo chạy trong Future.delayed, không có gesture context |

---

## So sánh các cấp độ "fullscreen" trên iOS

| Cách | Toolbar ẩn | Persistent | Yêu cầu |
|------|-----------|-----------|---------|
| `requestFullscreen()` | ❌ Không khả dụng | — | — |
| Scroll trick (auto-satisfy) | ✓ Tạm thời | Chỉ khi scrollY > 0 | Không cần gesture |
| Scroll trick (swipe-up gate) | ✓ Tạm thời | Chỉ khi scrollY > 0 | User vuốt lên (khuyến nghị) |
| PWA Add to Home Screen | ✓ Vĩnh viễn | Luôn luôn | User cài đặt PWA |

**Khuyến nghị dài hạn:** Hướng dẫn user "Add to Home Screen" để có trải nghiệm
tốt nhất trên iOS. PWA standalone mode ẩn hoàn toàn toolbar và được `isPwaStandalone`
detect để auto-satisfy gate (không cần scroll trick).

---

## Files liên quan

| File | Vai trò |
|------|---------|
| `lib/src/controllers/platform_ui_controller_web.dart` | Scroll trick + supportsFullscreen |
| `lib/src/controllers/platform_ui_controller.dart` | Abstract `supportsFullscreen` |
| `lib/src/controllers/fullscreen_guard_controller.dart` | Auto-satisfy + gọi apply() |

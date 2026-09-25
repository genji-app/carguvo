# Flutter Web — Iframe Firefox Debug Report

## Tổng quan

Tài liệu này ghi lại toàn bộ quá trình debug và fix các vấn đề liên quan đến Flutter Web (JS mode) khi chạy trên Firefox, đặc biệt là vấn đề iframe game/livestream bị màn đen và không render được.

**Môi trường:**
- App: `https://web.sun88.win`
- Flutter version: `>=3.38.0`
- Renderer: CanvasKit (JS mode, không dùng WASM)
- Browser bị ảnh hưởng: Firefox 152+
- Browser hoạt động bình thường: Chrome, Safari

---

## 1. Context & Background

### 1.1 Kiến trúc app

App Flutter Web (`web.sun88.win`) load các game và livestream từ các domain bên thứ ba thông qua `<iframe>`:

| Domain | Mục đích |
|---|---|
| `lansinhphuquy.sungame.win` | Livestream |
| `spadetechplay.evo-games.com` | Evolution Gaming casino |
| `momotaro.sunwin.qa` | Game khác |
| `rs.static607zgn.com` | CDN assets (logo, hình ảnh) |

### 1.2 Lịch sử vấn đề

Trước đây app chạy được bình thường trên cả Chrome và Firefox. Sau khi **upgrade Flutter lên 3.38.0**, Firefox bắt đầu hiển thị màn đen khi load iframe game — Chrome vẫn hoạt động bình thường.

---

## 2. Các vấn đề đã gặp

### 2.1 Vấn đề COEP/WASM (Đã giải quyết bằng cách tắt WASM)

**Triệu chứng:**
```
GET https://rs.static607zgn.com/assets/images/logo_s88_home.webp
net::ERR_BLOCKED_BY_RESPONSE.NotSameOriginAfterDefaultedToSameOriginByCoep 200 (OK)
```

**Nguyên nhân:** Flutter WASM yêu cầu `SharedArrayBuffer`, cần header COEP/COOP. Khi bật COEP, tất cả cross-origin resource phải có `Cross-Origin-Resource-Policy` header — logo, game iframe, livestream đều bị block.

**Giải pháp đã áp dụng:** Tắt WASM, chạy JS mode. DevOps thêm header:
```nginx
add_header Cross-Origin-Resource-Policy "cross-origin" always;
```

---

### 2.2 Màn đen trên Firefox (Vấn đề chính)

**Triệu chứng:** Mở app trên Firefox thấy toàn màn đen. Mở thẳng URL iframe game trên tab mới thì load được bình thường.

**Quá trình debug:**

Kiểm tra Console Firefox — không có lỗi đỏ nghiêm trọng, Dart code vẫn chạy:
```
Got object store box in database deposit_qr_responses.
Got object store box in database search_recent.
Got object store box in database casino_recent_games.
```

Kiểm tra DOM qua Console:
```javascript
document.querySelector('iframe')?.getAttribute('sandbox')
// Kết quả: "allow-modals allow-scripts allow-same-origin allow-popups"
```

**Root cause xác định:** Flutter 3.27+ thay đổi rendering path của `HtmlElementView` sang **HTML slots**, đồng thời bắt đầu **tự inject `sandbox` attribute** vào iframe platform views với giá trị mặc định thiếu permissions quan trọng.

| Permission | Sandbox mặc định Flutter | Cần thiết |
|---|---|---|
| `allow-modals` | ✅ | ✅ |
| `allow-scripts` | ✅ | ✅ |
| `allow-same-origin` | ✅ | ✅ |
| `allow-popups` | ✅ | ✅ |
| `allow-popups-to-escape-sandbox` | ❌ | ✅ |
| `allow-forms` | ❌ | ✅ |
| `allow-top-navigation-by-user-activation` | ❌ | ✅ |
| `allow-downloads` | ❌ | ✅ |

Firefox strict hơn Chrome trong việc enforce sandbox — thiếu permissions này khiến WebGL context của game không khởi tạo được, dẫn đến màn đen.

---

### 2.3 Splash screen không ẩn trên Firefox

**Triệu chứng:** App render được (Dart code chạy, object stores load) nhưng vẫn thấy màn đen — là background của `#html-splash` element.

**Nguyên nhân:** `flutter-first-frame` event không fire ổn định trên Firefox → `hideHtmlSplash()` không được gọi.

**Giải pháp:** Thêm fallback poll check `flt-glass-pane` trong `index.html`:

```javascript
(function () {
  var hidden = false;

  function hideHtmlSplash() {
    if (hidden) return;
    hidden = true;
    const splash = document.getElementById("html-splash");
    if (!splash) return;
    splash.classList.add("hidden");
    setTimeout(function () {
      if (splash.parentNode) splash.parentNode.removeChild(splash);
    }, 350);
  }

  // Cách 1: Event chính xác (Chrome/Safari)
  window.addEventListener("flutter-first-frame", hideHtmlSplash);

  // Cách 2: Poll check flt-glass-pane (Firefox fallback)
  var checkInterval = setInterval(function () {
    const fltPane = document.querySelector('flt-glass-pane');
    if (fltPane) {
      clearInterval(checkInterval);
      setTimeout(hideHtmlSplash, 300);
    }
  }, 200);

  // Cách 3: Hard timeout
  setTimeout(hideHtmlSplash, 8000);

  // Dọn dẹp interval
  setTimeout(function() { clearInterval(checkInterval); }, 15000);
})();
```

---

### 2.4 Các warning không nghiêm trọng (Bỏ qua)

| Warning | Nguồn | Kết luận |
|---|---|---|
| `WEBGL_debug_renderer_info is deprecated` | Google CanvasKit | Bỏ qua — không ảnh hưởng |
| `Source map error 404` | Flutter build thiếu `.map` file | Bỏ qua — chỉ ảnh hưởng debug |
| `Cookie EVOSESSIONID will soon be rejected` | Evolution Gaming | Evolution Gaming cần fix phía họ |
| `Partitioned cookie - evo-games.com` | Firefox Total Cookie Protection | Bỏ qua — chưa block ngay |
| `ERR_BLOCKED_BY_ETP - sentry-cdn.com` | Firefox Enhanced Tracking Protection | Bỏ qua — chỉ ảnh hưởng analytics |
| `SRI hash mismatch - sentry-cdn.com` | Hệ quả của ETP block | Bỏ qua — tự hết khi ETP không block |

---

### 2.5 Geo-block từ Evolution Gaming

**Triệu chứng:**
```
Response 302 → Location: frontend/evo/errors/incorrect-currency-for-geo-location.html?lang=vi
```

**Nguyên nhân:** IP test không thuộc vùng được cấp phép của Evolution Gaming, hoặc currency config không match geo-location.

**Giải pháp:** Dùng VPN với IP từ vùng được cấp phép, hoặc nhờ team backend whitelist IP trong Evolution Gaming dashboard. **Đây không phải lỗi kỹ thuật Flutter.**

---

## 3. Fix chính: Override sandbox trong IHHtmlIframeRunnerView

### 3.1 File cần sửa

`lib/.../ih_html_iframe_runner_view.dart`

### 3.2 Code fix

```dart
onElementCreated: (element) {
  final iframe = element as web.HTMLIFrameElement;

  // ✅ Override sandbox TRƯỚC KHI set src
  // Flutter 3.27+ tự inject sandbox mặc định thiếu permissions
  // Firefox strict hơn Chrome, cần set đầy đủ
  iframe.setAttribute('sandbox',
    'allow-modals '
    'allow-scripts '
    'allow-same-origin '
    'allow-popups '
    'allow-popups-to-escape-sandbox '
    'allow-forms '
    'allow-top-navigation-by-user-activation '
    'allow-downloads');

  // Permissions Policy - format Firefox chấp nhận
  iframe.allow = 'autoplay; fullscreen; accelerometer; gyroscope; '
      'camera; microphone; geolocation; '
      'clipboard-read; clipboard-write; payment; midi';

  iframe.style.border = 'none';
  iframe.style.width = '100%';
  iframe.style.height = '100%';

  if (widget.backgroundColor != null) {
    iframe.style.background = widget.backgroundColor!.toCssRgba();
  } else {
    iframe.style.background = '#f5f4eb';
  }

  widget.controller.updateState(IHRunnerState.loading);

  iframe.onLoad.listen((_) {
    widget.logger('info', '[IHHtmlIframe] Game loaded: ${widget.gameUrl}');
    widget.controller.updateState(IHRunnerState.loaded);
  });

  iframe.onError.listen((_) {
    widget.logger('error', '[IHHtmlIframe] Failed to load: ${widget.gameUrl}');
    widget.controller.updateState(
      IHRunnerState.error,
      message: 'Failed to load game iframe',
    );
  });

  // ✅ Set src SAU CÙNG — đảm bảo sandbox được apply trước khi load URL
  iframe.src = widget.gameUrl;
},
```

### 3.3 Lý do set src sau cùng

Browser apply sandbox **tại thời điểm load URL**. Nếu set `src` trước rồi mới set `sandbox`, trình duyệt có thể đã bắt đầu load với sandbox cũ (do Flutter inject). Set `src` sau cùng đảm bảo sandbox mới được apply đúng.

---

## 4. Verify sau khi fix

Mở Firefox → vào app → navigate đến màn game → F12 Console → chạy:

```javascript
// Tìm iframe trong Shadow DOM của Flutter
document.querySelector('flt-glass-pane')
  ?.shadowRoot
  ?.querySelector('iframe')
  ?.getAttribute('sandbox')
```

**Kết quả mong đợi:**
```
"allow-modals allow-scripts allow-same-origin allow-popups 
 allow-popups-to-escape-sandbox allow-forms 
 allow-top-navigation-by-user-activation allow-downloads"
```

---

## 5. Tóm tắt nguyên nhân gốc rễ

```
Flutter <= 3.26  →  HtmlElementView KHÔNG inject sandbox
                 →  Iframe hoạt động bình thường trên Firefox

Flutter >= 3.27  →  HtmlElementView migrate sang HTML slots rendering
                 →  TỰ INJECT sandbox mặc định vào iframe platform views
                 →  Sandbox thiếu permissions (allow-forms, allow-popups-to-escape-sandbox, ...)
                 →  Firefox strict → WebGL context không khởi tạo được
                 →  Màn đen
```

Chrome ít bị ảnh hưởng hơn vì Chrome lenient hơn Firefox trong việc enforce sandbox restrictions với WebGL.

---

## 6. Checklist deploy

- [ ] Override sandbox trong `onElementCreated` trước khi set `src`
- [ ] Thêm fallback `flt-glass-pane` poll trong `index.html`
- [ ] Verify sandbox value trên Firefox sau deploy
- [ ] Test game load trên Firefox với IP/VPN được whitelist bởi Evolution Gaming
- [ ] Confirm DevOps giữ nguyên `Cross-Origin-Resource-Policy: cross-origin` header trên Nginx


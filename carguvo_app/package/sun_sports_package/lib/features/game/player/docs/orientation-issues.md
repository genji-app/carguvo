# Vấn đề xoay màn hình (Orientation) trên iPadOS 16+ với WebView

Tài liệu này ghi lại một lỗi edge-case liên quan đến xoay màn hình khi chơi game WebView trên iPadOS 16+ và các phương pháp đã thử để khắc phục nó.

## Mô tả lỗi

1. Thiết bị: iPad (vd: 8th generation), iOS 16+.
2. App đang ở trạng thái cầm dọc (Portrait).
3. Người dùng vào chơi một game yêu cầu xoay ngang (Landscape), ví dụ: game provider "VIA Casino".
4. Ở lần đầu tiên, game load bình thường nằm ngang, WebView (Sử dụng plugin `webview_flutter_wkwebview`) render giao diện phù hợp với tablet.
5. Người dùng thoát game để quay lại ứng dụng.
   - Lúc này `SystemUiService.restoreDefaultSystemUI()` cố gắng gọi `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` để trả màn hình về chiều dọc.
   - **Lỗi 101 xuất hiện** trên iPadOS 16+: `Code=101 "None of the requested orientations are supported by the view controller. Requested: portrait; Supported: landscapeRight"`.
   - Lỗi này có nghĩa là ở mức System (hệ điều hành), ứng dụng đang bị kẹt constraint vào `landscapeRight` và không cho phép trả về `portrait`.
6. Người dùng nhấn vào chơi game đó (hoặc game Landscape tương tự) **lần thứ hai**.
   - Code khởi tạo xoay ngang chạy bình thường.
   - Tuy nhiên do màn hình vật lý thực tế đang cầm dọc (người dùng đang cầm iPad dọc ở danh sách game), nhưng hệ điều hành lại nói "tao đang nằm ngang", WebView bị rớt vào một `race condition` về layout bounds.
   - Khi WebView sinh ra, nó bắt nhầm kích thước bounding box của khung hình Portrait (Width < Height).
   - Nội dung Web Game (dùng responsive CSS) đánh giá Width < Height nên quyết định load layout UI của nền tảng Mobile thay vì Tablet màn hình rộng ngang. 
   - Hậu quả: Layout game bị vỡ, khuyết UI, mất nút hiển thị không đúng chuẩn.

## Các phương pháp đã can thiệp & thử nghiệm

Chúng ta đã thử những cách sau để xử lý và đồng bộ lại constraint xoay màn hình:

### 1. Flush (xả) Orientation Mask (Đã Fix được Lỗi 101)
Trong `SystemUiService.restoreDefaultSystemUI()`, khi ra khỏi game, ta đã chèn Workaround để lách lỗi 101 của iPad:
```dart
// Workaround cho iPadOS 16+ (Lỗi 101): nhả toàn bộ mask trước khi khoá về Portrait
await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
await Future<void>.delayed(const Duration(milliseconds: 50));
await SystemChrome.setPreferredOrientations(defaultOrientations);
```
**Kết quả:** Sửa được lỗi 101 hiển thị trong console. Các lần sau không còn báo Unsupported orientation.

### 2. Delay trước khi Load Game URL
Trong `GamePlayerNotifier.initializePlayer()`, ta thêm delay (400ms đến 2000ms) để chờ hệ điều hành múa xong animation xoay màn hình (thay đổi System UI constraints hoàn tất) trước khi cho phép WebView load URL.
```dart
if (orientation != GameOrientation.portrait) {
  await Future<void>.delayed(const Duration(milliseconds: 400)); // Thậm chí tăng lên 2000ms
}
```
**Kết quả:** Delay đủ lâu, hoạt ảnh màn hình chạy xong nhưng thi thoảng WebView lần 2 vẫn render kẹt ở giao diện Mobile.

### 3. Check tỷ lệ Aspect (MediaQuery Bounds) trước khi Render WebView
Trong `_WebViewLayer` ở `game_player_screen.dart`, ta từng thử cản không cho WebView Widget được build vào Widget Tree nếu như kích thước `MediaQuery` chưa khớp với hướng xoay mong đợi (vd đợi width > height).
**Kết quả:** Sửa được lỗi trên màn hình Full thông thường. **Tuy nhiên**, đối với **Stage Manager** trên iPad, nếu người dùng đưa app vào một cửa sổ dạng dọc (dáng điện thoại, width < height), cửa sổ này bị constrain bởi OS và *vĩnh viễn* không thể tự xoay ngang chiều rộng ra được dù app có yêu cầu `setLandscapeOnly`. Điều này dẫn đến tình trạng game load liên tục (infinite black screen) vì `width > height` không bao giờ thoả mãn. Do vậy, phương pháp này đã phải bị **loại bỏ**.

## Trạng thái hiện tại
Vấn đề tỷ lệ màn hình load sai lần thứ 2 trên iPad vẫn thỉnh thoảng tái diễn chưa dứt điểm hoàn toàn. Các thay đổi work-around vẫn đang được giữ lại trong source code vì nó cải thiện phần nào lifecycle lỗi 101 và đồng bộ State.
Đặc biệt cẩn thận khi thiết kế UI liên quan đến Orientation lock cho iPad vì chế độ Stage Manager / Split-screen hoàn toàn có thể bẻ cong hoặc phớt lờ lệnh khoá xoay của Application, lúc này Bounds sẽ luôn nhỏ hơn quy chuẩn.
Cần nghiên cứu sâu hơn về WKWebView bounds lifecycle hoặc truyền Injection Script (`window.innerWidth/innerHeight`) dập vào WebView để xử lý triệt để.

## Phương pháp 4: Native Constraint Letterboxing (Tạm ngưng)

**Bối cảnh:**
Mặc dù ý tưởng sử dụng Native Layout Constraint (dùng `LayoutBuilder` bọc `AspectRatio(16/9)`) giúp ép WebView khung cảnh Landscape khi chạy Stage Manager dáng dọc rất ổn định, tuy nhiên nó đã gây ra loop reference `context.widget` rủi ro crash và UX viền đen (hắc mạc) có thể chưa phù hợp. Do đó, phương pháp này đang được **comment lại** (tạm ngưng) trong `game_player_screen.dart`.

## Phương pháp 5: Khôi phục JS Injection + Xả State WebView (Giải pháp hiện tại)

**Implementation Date:** 2026-03-XX

Để dứt điểm lỗi hiển thị Mobile Layout ở lần load thứ 2 mà không dùng Letterboxing, chúng ta sử dụng tổ hợp các kỹ thuật sau:

1. **Khôi phục Hack JS Injection (`window.innerWidth/innerHeight`)**:
   Hàm `_injectLandscapeViewport` được khôi phục trong `game_web_view_mobile.dart`. Nó chạy một vòng lặp `setInterval` 500ms để liên tục đè kích thước màn hình và dispatch sự kiện `resize` / `orientationchange`. Nó giúp lừa Game Engine rằng thiết bị đang có Width > Height (Tablet Landscape). Điều kiện kích hoạt được tính bởi `GameBlockX.shouldForceLandscapeViewport(context)` — chỉ bật khi `forceLandscapeViewportOnIpad: true` **và** thiết bị là tablet **và** tất cả tabletOrientation là landscape.

2. **Dọn dẹp WebKit bằng `about:blank`**:
   Trước khi `_controller.loadRequest(gameUrl)` ở hàm `_setupWebView`, ta gọi một lệnh `_controller.loadRequest(Uri.parse('about:blank'))`. Việc này khiến WebView xả bỏ các state/DOM của game cũ bị kẹt, đảm bảo môi trường web trong sạch khi load game thực sự.

3. **Phớt lờ Lỗi Huỷ Kết Nối Ướt (-999 và -3)**:
   Hệ quả của việc gọi `loadRequest` hoặc xoay màn hình (buộc rebuild) liên tục là WebView của Apple/Android sẽ chủ động ngắt (cancel) request cũ đang dang dở. Việc ngắt này sinh ra mã lỗi `-999` (`NSURLErrorCancelled` trên iOS/macOS) hoặc `-3` (`ERR_ABORTED` trên Android).
   Trong hàm `_onWebResourceError`, ta bắt riêng mã lỗi này và chỉ log warning chứ không gọi `widget.onError()`, ngăn chặn ứng dụng báo lỗi đỏ (Error State) nhầm lẫn.

4. **Khôi phục hoàn toàn Flush Orientation Mask (Fix Lỗi 101)**:
   Các hàm khoá xoay trong `SystemUiService` đều đã được mở lại đoạn Workaround kinh điển:
   ```dart
   await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
   await Future<void>.delayed(const Duration(milliseconds: 50));
   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // hoặc landscape
   ```
   Điều này là bắt buộc để trị dứt điểm lỗi kẹt constraint cấp hệ điều hành (Lỗi `Code=101`) của iPadOS 16+. Kèm theo đó, bổ sung `catch (e, stack)` đính kèm StackTrace gửi cho logger để dễ debug.

**Kết quả & Đánh giá**:
Với việc kết hợp dọn cache web (load blank), mở lại hack JS, ngắt báo lỗi giả (-999), và xả lock xoay màn hình, WebView trên iPad có tỷ lệ hiển thị đúng Landscape UI cao hơn rất nhiều và mượt mà đi qua khỏi cạm bẫy báo lỗi rác. Mọi xử lý dọn dẹp biến số state đều làm việc hiệu quả.

---

## Phương pháp 6: Flutter Web — Ổn định Widget Tree & Iframe Dimensions (2026-03-11)

**Nền tảng:** Flutter Web (chạy trên Chrome, Safari)  
**Bối cảnh:** Khi mở game WebView trên Flutter Web (ví dụ dùng Chrome DevTools giả lập iPad Pro), xoay thiết bị gây ra 2 lỗi:
1. **WebView HTML biến mất hoàn toàn** sau khi xoay
2. **CSS game bị vỡ** (hiển thị to hơn bình thường) nếu xoay trong lúc game đang load splash screen

### 6A. Widget Tree Stabilization — Ngăn iframe bị unmount

**File:** `game_player_scaffold.dart`

#### Nguyên nhân
`GamePlayerScaffold` sử dụng `OrientationBuilder` để chuyển đổi giữa 2 widget type khác nhau:
- Portrait → `GamePortraitLayout` (dùng `Column`)
- Landscape → `GameLandscapeLayout` (dùng `Row`)

Khi Flutter thấy **widget type thay đổi** tại cùng vị trí trong tree, nó **unmount toàn bộ subtree** (bao gồm `HtmlElementView` chứa iframe). Khi remount:
- `State.dispose()` chạy → gọi `_iframe.src = ''` + `_iframe.remove()` → **iframe bị hủy khỏi DOM**
- `initState()` mới chạy → gọi `registerViewFactory(SAME viewId)` → **bị bỏ qua** vì factory đã tồn tại
- Kết quả: HtmlElementView reference factory cũ → factory trả về iframe đã bị hủy → **WebView biến mất**

> **Note:** Trên native (iOS/Android), `InAppWebView` xử lý reparenting gracefully nên không bị lỗi này. Chỉ xảy ra trên Flutter Web do `registerViewFactory` không cho phép re-register cùng viewId.

#### Giải pháp
Thay thế 2 widget type bằng **1 `_AdaptiveGameLayout` duy nhất** dùng `Stack`:
```dart
// TRƯỚC (2 widget types — tree bị restructure khi xoay):
body: isPortrait
    ? GamePortraitLayout(child: child)   // Column
    : GameLandscapeLayout(child: child), // Row  ← KHÁC TYPE!

// SAU (1 widget type — tree ổn định):
body: _AdaptiveGameLayout(
    isPortrait: isPortrait,
    child: child,  // ← child KHÔNG BAO GIỜ bị unmount
),
```

**Cấu trúc mới:**
```
Stack
├── AnimatedPositioned(child)   ← Game WebView (STABLE, chỉ thay đổi padding)
├── Positioned (top bar)        ← Portrait navigation
└── Positioned (sidebars)       ← Landscape navigation
```

- `child` (chứa WebView) luôn là con của cùng 1 `AnimatedPositioned` → Flutter chỉ **update layout** (thay đổi padding), không **unmount/remount**
- `AnimatedPositioned` có animation 200ms tạo hiệu ứng mượt khi chuyển đổi
- Navigation overlay thay đổi vị trí dựa trên orientation nhưng không ảnh hưởng child

**Các class đã xóa:** `GamePortraitLayout`, `GameLandscapeLayout`  
**Class thay thế:** `_AdaptiveGameLayout` (private, chỉ dùng trong scaffold)

---

### 6B. Iframe Size Stabilization — Ngăn CSS bị vỡ khi xoay lúc load

**Files:** `web/game_web_view_web.dart`, `web/game_web_view_dimension_lock_mixin.dart`

#### Nguyên nhân
Game engine (JS/CSS bên trong iframe) đọc viewport dimensions **một lần** khi khởi tạo (`window.innerWidth`, `window.innerHeight`, CSS media queries). Nếu Container thay đổi kích thước trong lúc game đang khởi tạo (splash screen), game sẽ init với kích thước sai → CSS layout bị vỡ vĩnh viễn.

**Timeline lỗi:**
```
0s  — Iframe tạo (width: 100%, height: 100%)
0s  — Game bắt đầu load, đọc dimensions → 1024 x 768
3s  — User xoay thiết bị → iframe resize → 768 x 1024
3s  — Game engine đang giữa chừng init → nhận sai dimensions
5s  — Splash screen kết thúc → CSS layout đã bị init sai → VỠ
```

> **Note:** Khi game đã load xong, resize handler của game hoạt động bình thường → xoay OK. Lỗi chỉ xảy ra khi xoay **trong lúc** game đang init.

#### Giải pháp: Lock & Unlock Pattern

```
Timeline:

0ms     ─── Platform view created
150ms   ─── 🔒 LOCK: đọc getBoundingClientRect() → lock kích thước pixel
              (e.g. width: 1024px, height: 768px thay vì 100%)
150ms   ─── Set iframe.src = gameUrl (game bắt đầu load)
300ms   ─── Fallback onLoadStop (dismiss Flutter loading overlay)
  ...   ─── 🎮 Game splash screen (5-15 giây)
  ...   ─── Nếu user xoay → container resize BUT iframe vẫn 1024x768
  ...   ─── Game init ổn định với kích thước ban đầu ✅
~8s     ─── Iframe 'load' event fires
~10s    ─── 🔓 UNLOCK: load + 2s buffer → iframe chuyển về 100%/100%
  ...   ─── Game (đã init xong) tự handle resize OK ✅
```

**Unlock conditions (cái nào đến trước):**
- **Signal A:** Iframe `load` event fires + 2 giây buffer cho JS init
- **Signal B:** Safety timeout 15 giây (nếu `load` event không bao giờ fire do cross-origin)

**Code flow:**
```dart
// 1. Lock TRƯỚC khi set src
_lockIframeDimensions();       // style.width = '1024px'
_iframe?.src = widget.gameUrl; // game load vào viewport ổn định

// 2. Unlock khi load event fires + buffer
_iframe!.addEventListener('load', (event) {
  _schedulePostLoadUnlock();   // Timer(2 seconds, unlock)
});

// 3. Safety net
_maxStabilizationTimer = Timer(15 seconds, _unlockIframeDimensions);

// 4. Unlock
void _unlockIframeDimensions() {
  _iframe!.style.width = '100%';  // responsive trở lại
  _iframe!.style.height = '100%';
}
```

---

### Debug & Troubleshooting

#### Console logs (Chrome DevTools → Console)

Khi game đang chạy, các log sau sẽ xuất hiện theo thứ tự:

| Log message | Ý nghĩa |
|---|---|
| `Iframe view created` | Platform view đã tạo |
| `Iframe dimensions locked: 1024x768` | ✅ Lock thành công |
| `Setting iframe src now` | Game URL đã được set |
| `Fallback: Automatically firing onLoadStop...` | Flutter loading overlay dismissed |
| `Iframe load detected, scheduling unlock in 2s.` | `load` event đã fire, đợi 2s |
| `Iframe dimensions unlocked to responsive.` | ✅ Unlock thành công |

#### Nếu CSS vẫn bị vỡ
1. Kiểm tra Console: `Iframe dimensions locked: WxH` có xuất hiện không?
   - **Không xuất hiện** → `getBoundingClientRect()` trả về 0 → tăng delay trước khi lock (hiện 150ms)
   - **Có xuất hiện** → kiểm tra xem `unlocked` xuất hiện quá sớm không → tăng `_kPostLoadBuffer`
2. Nếu unlock quá sớm (trước khi splash screen kết thúc): tăng `_kPostLoadBuffer` từ 2s lên 3-5s
3. Nếu `load` event không bao giờ fire: giảm `_kMaxStabilizationDuration` từ 15s (nhưng không nên dưới 10s)

#### Nếu WebView biến mất khi xoay
1. Kiểm tra `game_player_scaffold.dart` — phải dùng `_AdaptiveGameLayout`, **KHÔNG** dùng `GamePortraitLayout` / `GameLandscapeLayout`
2. Kiểm tra không có widget nào khác đổi type dọc theo tree path từ `GamePlayerScaffold` đến `HtmlElementView`
3. Console log: `Iframe has zero dimensions` → iframe chưa được render → tăng delay

#### Tuneable Constants

| Constant | File | Default | Mô tả |
|---|---|---|---|
| `_kMaxStabilizationDuration` | `web/game_web_view_dimension_lock_mixin.dart` | 15s | Timeout tối đa giữ lock nếu `load` không fire |
| `_kPostLoadBuffer` | `web/game_web_view_dimension_lock_mixin.dart` | 2s | Delay sau `load` event trước khi unlock |
| `Future.delayed(150ms)` | `web/game_web_view_web.dart` | 150ms | Delay đợi browser layout trước khi đọc dimensions |
| `Future.delayed(300ms)` | `web/game_web_view_web.dart` | 300ms | Fallback onLoadStop delay |
| `AnimatedPositioned duration` | `game_player_scaffold.dart` | 200ms | Animation khi chuyển layout portrait ↔ landscape |

### Tóm tắt files đã thay đổi

| File | Thay đổi |
|---|---|
| `game_player_scaffold.dart` | Thay `GamePortraitLayout`/`GameLandscapeLayout` (Column/Row) bằng `_AdaptiveGameLayout` (Stack) |
| `web/game_web_view_web.dart` | Thêm iframe size lock/unlock pattern với event-driven timing (logic ở `game_web_view_dimension_lock_mixin.dart`) |

---

## Phương pháp 7: Patch `window.matchMedia` — Fix Mobile Layout trên iPad (2026-04-02)

**Nền tảng:** iPad / iPadOS (native mobile)  
**File:** `packages/game_engine/lib/src/provider_live_runner/inapp/inapp_runner_ctrl.dart`  
**Được kích hoạt bởi:** `GameBlockX.shouldForceLandscapeViewport(context)` → `forceLandscapeViewportOnIpad: true`

### Bối cảnh

Sau khi các Phương pháp 1–5 ổn định được hầu hết trường hợp, vẫn còn một tỉ lệ lỗi (~15%) là game hiển thị layout Mobile trên iPad dù đang ở landscape. Root cause được xác định: game engine dùng **`window.matchMedia('(orientation: landscape)')`** — API này đọc `window.innerWidth/innerHeight`, và trong giai đoạn khởi tạo WebView (trước khi browser layout xong), cả hai giá trị đều là `0`. Kết quả: `0 > 0 = false` → game quyết định đây là portrait → khởi tạo layout Mobile và **không bao giờ tự thay đổi lại**.

Các patch trước (screen.width/height, screen.orientation.type) không đủ vì game engine ưu tiên `matchMedia`.

### Giải pháp

Intercept `window.matchMedia` tại điểm sớm nhất (`onWebViewCreated` và `onLoadStart`):

```javascript
(function() {
  if (window.__matchMediaPatched) return; // Idempotent guard
  window.__matchMediaPatched = true;

  const origMatchMedia = window.matchMedia.bind(window);
  window.matchMedia = function(query) {
    const real = origMatchMedia(query);
    const isLandscapeQuery = query.includes('orientation') &&
                             query.includes('landscape');
    const isPortraitQuery  = query.includes('orientation') &&
                             query.includes('portrait');

    if (!isLandscapeQuery && !isPortraitQuery) return real; // pass-through

    const fake = Object.create(real);
    Object.defineProperty(fake, 'matches', {
      get: () => isLandscapeQuery, // force landscape=true, portrait=false
    });
    fake.addEventListener = (type, listener) => {
      if (type === 'change') listener(fake); // notify game immediately
    };
    fake.addListener = (listener) => listener(fake); // legacy support
    return fake;
  };
})();
```

### Tính chất

| Tính chất | Giải thích |
|-----------|------------|
| **Idempotent** | Guard `__matchMediaPatched` ngăn patch 2 lần khi script inject ở nhiều trigger |
| **Targeted** | Chỉ can thiệp query có chứa `orientation`; dark mode, prefers-reduced-motion... không bị ảnh hưởng |
| **Backward-compatible** | Hỗ trợ cả `addEventListener` (modern) và `addListener` (legacy Safari) |
| **Immediate notification** | Khi game đăng ký listener, gọi ngay lập tức → game nhận sự kiện orientation từ đầu |

### Điều kiện kích hoạt

Script này **chỉ được inject** khi `forceLandscapeViewport = true`, giá trị do `GameBlockX.shouldForceLandscapeViewport(context)` tính:

```dart
// game_extensions.dart
bool shouldForceLandscapeViewport(BuildContext context) {
  if (!forceLandscapeViewportOnIpad) return false;  // GameBlock config
  final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  if (!isTablet) return false;                       // Tablet only
  return tabletOrientation.every((o) => o.isLandscape); // All landscape
}
```

### Kết quả

- Tỉ lệ hiển thị đúng Tablet Landscape tăng từ ~85% lên ~100%
- Không có side-effect với game portrait hoặc game mobile
- Phối hợp với các inject khác (screen props, viewport meta) để tạo môi trường landscape toàn diện

### Tóm tắt files đã thay đổi (Phương pháp 7)

| File | Thay đổi |
|---|---|
| `provider_live_runner/inapp/inapp_runner_ctrl.dart` | Thêm matchMedia patch vào `_orientationApiPolyfillScript` |
| `lib/features/game/game_extensions.dart` | Thêm `shouldForceLandscapeViewport(BuildContext)` vào `GameBlockX` |
| `lib/features/game/player/game_player_screen.dart` | Dùng `shouldForceLandscapeViewport` thay inline logic |
| `lib/core/.../game_block.dart` | Rename `forceLandscapeViewport` → `forceLandscapeViewportOnIpad`, `openInNewTab` → `openInNewTabOnIOSSafariWeb` |

---

## Phương pháp 8: Active Lifecycle & Synchronized Transition (2026-05-08)

**Nền tảng:** iPad / Tablet (Native) & Toàn bộ ứng dụng.  
**Bối cảnh:** Mặc dù các bản patch script giúp game hiển thị đúng layout, nhưng quá trình chuyển đổi (transition) vẫn gặp các lỗi về UI:
1. **Nháy giao diện (Flicker)**: Khi thoát game, màn hình Home phát hiện mismatch trong vài mili giây thiết bị đang xoay.
2. **Double Rotation**: Cả Notifier và Guard đều gọi lệnh xoay đồng thời, gây giựt màn hình.
3. **Crash khi thoát**: Lỗi `Bad state` do gửi event vào stream đã đóng hoặc gọi `setState` khi đang dispose.

### Giải pháp: Quản lý Lifecycle Chủ động

Chúng ta chuyển đổi từ cơ chế bị động (đợi xoay xong rồi chạy) sang cơ chế chủ động điều phối:

1. **Đồng bộ trạng thái xoay toàn cục (`isApplying`)**:
   Thuộc tính `isApplying` được thêm vào `OrientationController`. Khi bất kỳ lệnh xoay nào (`apply` hoặc `restore`) đang chạy, giá trị này là `true`. Các `OrientationGuard` khác (vd: ở màn hình Home) sẽ tự động ẩn UI mismatch để tránh gây nháy.

2. **Cơ chế "Thoát mượt" (Smooth Exit)**:
   Mọi đường thoát đều được tập trung vào `requestExit()` trong Notifier.
   - Trình tự thoát: Đặt trạng thái `exiting` (Khóa UI) → Xoay màn hình về Portrait → Phát event `ExitEvent` → UI gọi `Navigator.pop()`.
   - Điều này đảm bảo iPad đã xoay xong xuôi mới thực sự gỡ bỏ màn hình game.

3. **Ngăn chặn trùng lặp (Redundancy Protection)**:
   Hàm `restore()` được nâng cấp để kiểm tra xem hướng mong muốn đã active chưa. Nếu Notifier đã gọi xoay rồi, Guard sẽ bỏ qua lệnh xoay thừa, loại bỏ hiện tượng giựt màn hình 2 lần.

4. **An toàn Lifecycle (`_isDisposed` & `_safeNotifyListeners`)**:
   - Thêm flag `_isDisposed` kiểm tra sau mỗi `await`.
   - Dùng `Future.microtask` trong `_safeNotifyListeners` để đảm bảo không gọi `notifyListeners` trong lúc Flutter đang lock widget tree (build/dispose).

5. **Xác định chính xác Trạng thái trước đó (Previous State Capture)**:
   - Sửa lỗi không xoay về Portrait ở lần vào game thứ 2: Đảm bảo `previousPolicy` được chụp lại bằng `ref.read` ngay trong block khởi tạo đầu tiên của `GamePlayerScreen`. Việc này ngăn chặn việc hệ thống chụp nhầm chính sách "đang xoay" làm chính sách "trước đó".

### Kết quả

- Triệt tiêu hoàn toàn hiện tượng nháy giao diện khi vào/thoát game trên iPad.
- Quá trình xoay màn hình diễn ra đúng 1 lần duy nhất, cực kỳ mượt mà.
- Độ ổn định cao, không còn lỗi crash âm thầm khi tương tác nhanh.

### Tóm tắt files đã thay đổi (Phương pháp 8)

| File | Thay đổi |
|---|---|
| `orientation_guard` package | Thêm `isApplying`, sửa lỗi locked tree, chống double-rotation. |
| `game_player_notifier.dart` | Refactor sang 8 trạng thái đồng bộ, thêm luồng `requestExit` chủ động. |
| `game_player_screen.dart` | Chuyển hướng mọi lệnh thoát qua Notifier, thêm Transition Overlay. |
| `game_player_notifier_test.dart` | Thêm bộ unit test bao phủ 100% logic lifecycle. |


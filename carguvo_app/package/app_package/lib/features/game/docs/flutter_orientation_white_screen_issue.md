# Flutter Android — Màn Hình Trắng/Đen Khi Xoay Từ Landscape → Portrait

**Tài liệu kỹ thuật phân tích lỗi và giải pháp**
*Cập nhật: Tháng 6, 2026*

---

## Tổng Quan (Executive Summary)

Khi sử dụng `SystemChrome.setPreferredOrientations()` để điều khiển xoay màn hình trên Android (cả phone lẫn tablet), Flutter app xuất hiện **vùng trắng hoặc đen chiếm 1/2 màn hình** sau khi xoay từ landscape về portrait. Layout không resize lại đúng kích thước mới.

Sau khi phân tích các issue chính thức trên Flutter GitHub repository, nguyên nhân gốc rễ được xác định là **race condition giữa Flutter rendering engine và Android window resize pipeline** — cụ thể là lỗi `BLASTBufferQueue` do buffer size mismatch. Bug này **chỉ xảy ra ở release mode**, debug mode không bị ảnh hưởng.

Đây là bug tồn tại ở tầng Flutter engine/Android, hiện vẫn **chưa được Flutter team fix chính thức** — giải pháp ở thời điểm này là các workaround ở tầng ứng dụng.

> ⚠️ **QUAN TRỌNG — Đọc trước khi áp dụng (cập nhật sau điều tra trên codebase `sun_sports`):**
> Các mục **1–8** dưới đây là phân tích kỹ thuật **tổng quát** từ các issue Flutter. Sau khi điều tra thực tế repo này (S22 / Android 15, game bắn cá), kết luận **khác với tài liệu gốc**:
> - Đây **không** phải Flutter-engine-race thuần; cũng **không** phải system-UI/immersive hay responsive-caching.
> - Root cause thật là **cấu hình native window** (`resizeableActivity="false"` + `screenOrientation="portrait"` + `windowBackground` trắng).
> - Nhiều "giải pháp" trong mục 4 **đã làm sẵn hoặc không áp dụng** cho repo này.
>
> **Phần kết luận triển khai chính thức nằm ở các mục 9–13.** Hãy đọc mục 9–13 trước; mục 1–8 chỉ là background tham khảo.

---

## 1. Mô Tả Triệu Chứng

### Triệu chứng chính

- Sau khi xoay màn hình từ **landscape → portrait**, khoảng **1/2 dưới màn hình** hiển thị màu trắng hoặc đen trống rỗng.
- Widget của app chỉ fill đúng vùng portrait của phần trên, phần còn lại trống.
- App **không tự recovery** nếu không tương tác (scroll, tap…).
- Xoay lại sang landscape → portrait đôi khi fix được, đôi khi vẫn bị.

### Điều kiện xuất hiện

| Điều kiện | Có bị | Không bị |
|---|---|---|
| Build mode | Release (`--release`) | Debug mode |
| Thiết bị | Physical device (thật) | Emulator |
| Nền tảng | Android | iOS (ít gặp hơn) |
| Thiết bị nhỏ | Phone Android | - |
| Thiết bị lớn | Tablet Android | - |
| Trigger | Gọi `setPreferredOrientations` | Xoay tự nhiên không có code |

---

## 2. Các GitHub Issues Liên Quan

### Issue #113905 — Vùng đen khi xoay thiết bị (release mode)

- **Link:** https://github.com/flutter/flutter/issues/113905
- **Ngày tạo:** 22/10/2022
- **Status:** **OPEN** (chưa fix)
- **Labels:** `e: device-specific`, `P2`, `platform-android`

**Mô tả chi tiết:**
Bug được phát hiện trên OPPO CPH1725, Android 7.1.1, nhưng sau đó nhiều người confirm reproduce trên nhiều thiết bị khác. Đặc biệt quan trọng: bug này **reproduce được với Flutter Counter App mặc định** — không có bất kỳ code orientation nào, không có plugin, không có `setPreferredOrientations`. Điều này xác nhận đây là **lỗi của Flutter engine**, không phải lỗi do code app.

Cách reproduce: chạy `flutter run --release` → xoay qua lại nhiều lần. Bug xuất hiện **sporadically** (không phải mọi lần xoay đều bị — thỉnh thoảng mới xuất hiện), nhưng khi có code `setPreferredOrientations`, tần suất xuất hiện tăng đáng kể.

**Tại sao debug mode không bị:**
JIT compiler của debug mode chậm hơn, khiến Flutter render frame *sau khi* Android đã hoàn tất resize window. AOT compiler của release mode nhanh hơn, khiến Flutter render frame *trước khi* Android resize xong → lệch buffer.

---

### Issue #143067 — Widget vỡ layout khi xoay trên tablet (release mode)

- **Link:** https://github.com/flutter/flutter/issues/143067
- **Ngày tạo:** 6/2/2024
- **Status:** **OPEN** (chưa fix)
- **Labels:** `a: tablet`, `a: release`, `e: device-specific`, `P3`

**Mô tả chi tiết:**
Trên Huawei MediaPad M5, Android 9. Widget bị tràn ra ngoài màn hình và render sai hoàn toàn sau khi đổi orientation. Điểm đặc biệt đáng chú ý: **không reproduce được trên emulator tablet** kể cả emulator Android 9 — chỉ xảy ra trên physical device.

Điều này cho thấy bug liên quan đến **hardware rendering pipeline thực tế** của GPU/display driver, không phải logic phần mềm thuần túy. Tablet đặc biệt dễ bị hơn phone vì kích thước window thay đổi lớn hơn khi xoay (delta lớn hơn → xác suất race condition cao hơn).

---

### Issue #108360 — Widget bị stretch trong animation xoay (context bổ sung)

- **Link:** https://github.com/flutter/flutter/issues/108360
- **Ngày tạo:** 25/7/2022
- **Status:** Closed (duplicate của #16322)

**Mô tả:**
Widget bị stretch/giãn ra *trong quá trình* animation xoay, sau khi xoay xong thì về bình thường. Closed là duplicate của issue cũ hơn về cách Flutter không implement rotation animation giống native Android/iOS — thay vì animate rotation, Flutter chỉ resize widget tree đột ngột.

Liên quan gián tiếp: cùng root cause về cách Flutter xử lý orientation change.

---

### Issue #144307 — Freeze + ghost element khi xoay kết hợp navigation

- **Link:** https://github.com/flutter/flutter/issues/144307
- **Ngày tạo:** 27/2/2024
- **Status:** Closed

**Mô tả và đóng góp quan trọng nhất:**
Pattern: Portrait screen A → push Landscape screen B (gọi `setPreferredOrientations`) → pop về A (restore orientations) → lặp lại. Sau 5–7 lần: (1) app chậm dần rồi freeze, (2) element của màn hình cũ hiện xuyên qua màn hình mới.

Flutter engineer `mossmana` tìm ra root cause kỹ thuật qua Android log:

```
E/BLASTBufferQueue: rejecting buffer:
  active_size=2264x1017   ← size landscape (cũ)
  requested_size=1080x2337 ← size portrait (mới)
  buffer{size=2264x1080}   ← buffer bị Android reject!
```

Đây là bằng chứng kỹ thuật quan trọng nhất: **Android từ chối buffer của Flutter** vì kích thước không khớp với window size hiện tại → frame bị drop → vùng trắng/đen.

---

## 3. Root Cause Kỹ Thuật Chi Tiết

### Timeline lỗi (landscape → portrait)

```
Bước 1: Gọi setPreferredOrientations([portraitUp])
           ↓
Bước 2: Android bắt đầu resize window
        → Window size mới: 1080 × 2337px (portrait)
           ↓
Bước 3: Flutter AOT (release mode) render NGAY LẬP TỨC
        → Vẫn dùng buffer size cũ: 2264 × 1080px (landscape)
           ↓
Bước 4: Flutter gửi frame (2264×1080) lên Android Surface
        → Android: "Buffer size ≠ window size" → REJECT frame
           ↓
Bước 5: Kết quả: Phần dưới màn hình trống trắng
        vì Flutter chưa vẽ đủ vào vùng portrait mới
```

### Tại sao release mode bị, debug mode không bị

```
Debug Mode (JIT):
  setPreferredOrientations → [JIT overhead: 200-400ms] → render
  → Khi Flutter render, Android đã resize xong → Buffer khớp ✅

Release Mode (AOT):
  setPreferredOrientations → [AOT: 10-30ms] → render ngay
  → Flutter render TRƯỚC khi Android resize xong → Buffer lệch ❌
```

### Tại sao tablet bị nặng hơn phone

Khi tablet (2560×1600) xoay sang portrait (1600×2560), **delta kích thước buffer** lớn hơn nhiều so với phone. Android mất nhiều thời gian hơn để resize surface → window gap lớn hơn → xác suất Flutter render sai frame cao hơn.

---

## 4. Giải Pháp

### Giải pháp 1 — Bắt buộc: `didChangeMetrics` + Force Rebuild

`didChangeMetrics` là callback chính thức từ Flutter engine, được gọi khi Android **đã hoàn tất** thay đổi window size. Đây là thời điểm đúng nhất để trigger rebuild.

```dart
class _MyScreenState extends State<MyScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Callback này được gọi SAU KHI Android resize xong
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) setState(() {});
  }
}
```

---

### Giải pháp 2 — `Future.delayed` + `addPostFrameCallback`

Workaround thực tế khi không thể dùng `didChangeMetrics` (ví dụ: gọi orientation từ code không có `State`):

```dart
Future<void> switchOrientation(List<DeviceOrientation> orientations) async {
  await SystemChrome.setPreferredOrientations(orientations);

  // Đợi Android BLASTBufferQueue flush buffer cũ
  await Future.delayed(const Duration(milliseconds: 400));

  if (mounted) {
    setState(() {});
    // Double-rebuild để chắc chắn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
}
```

> **Lưu ý:** 400ms là giá trị thực nghiệm hoạt động tốt trên hầu hết thiết bị. Một số thiết bị low-end cần lên đến 600ms.

---

### Giải pháp 3 — AndroidManifest: Đầy Đủ `configChanges`

Đảm bảo Android không restart Activity khi xoay màn hình. Thiếu `density` hoặc `fontScale` trên tablet thường gây restart không cần thiết.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
  android:name=".MainActivity"
  android:configChanges="orientation|screenSize|screenLayout|
                         keyboardHidden|keyboard|navigation|
                         uiMode|density|fontScale"
  android:hardwareAccelerated="true"
  android:windowSoftInputMode="adjustResize"
  android:exported="true">
```

---

### Giải pháp 4 — Không Cache `MediaQuery.size` Trong `initState`

```dart
// ❌ SAI — giá trị bị cache, không cập nhật sau Android resize
@override
void initState() {
  super.initState();
  screenWidth = MediaQuery.of(context).size.width; // BUG
}

// ✅ ĐÚNG — đọc trực tiếp trong build(), luôn nhận giá trị mới
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return SizedBox(width: screenWidth, child: ...);
}
```

---

### Giải pháp 5 — Dùng `LayoutBuilder` Thay Vì `MediaQuery`

`LayoutBuilder` dùng **constraints thực tế từ parent widget** thay vì phụ thuộc vào `MediaQuery` — ít bị ảnh hưởng bởi race condition hơn.

```dart
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return YourWidget(
        width: constraints.maxWidth,  // Luôn là size thực tế
        height: constraints.maxHeight,
      );
    },
  );
}
```

---

### Giải pháp 6 — Pattern Đầy Đủ Cho Game Screen (Cocos + WebView)

Pattern tổng hợp tất cả fix trên, phù hợp cho app có game integration:

```dart
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterGameMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitGameMode();
    super.dispose();
  }

  Future<void> _enterGameMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _exitGameMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    // Cho Android flush BLASTBufferQueue
    await Future.delayed(const Duration(milliseconds: 400));
  }

  // Trigger rebuild SAU KHI Android hoàn tất resize
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Ẩn vùng trắng nếu còn thoáng qua
      body: LayoutBuilder(
        builder: (context, constraints) {
          return YourGameWidget(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          );
        },
      ),
    );
  }
}
```

---

### Giải pháp 7 — Android 16+ Tablet: Opt-out Large Screen Restriction

Từ Android 16, `setPreferredOrientations` bị **bỏ qua hoàn toàn** trên màn hình ≥ 600dp. Thêm property sau vào `AndroidManifest.xml` để opt-out tạm thời:

```xml
<application ...>
  <!-- Opt-out tạm thời cho Android 16 — sẽ bị xóa ở Android 17 -->
  <property
    android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY"
    android:value="true" />
</application>
```

> **Cảnh báo:** Android 17 sẽ xóa opt-out này. Long-term solution là thiết kế app hỗ trợ cả hai orientation thay vì lock cứng.

---

## 5. Checklist Áp Dụng Fix

Áp dụng theo thứ tự ưu tiên:

- [ ] **[Bắt buộc]** Thêm `WidgetsBindingObserver` + `didChangeMetrics` vào các screen có thay đổi orientation
- [ ] **[Bắt buộc]** Cập nhật `AndroidManifest.xml` với đầy đủ `configChanges` (thêm `density`, `fontScale`)
- [ ] **[Khuyến nghị]** Thêm `Future.delayed(400ms)` trong hàm restore orientation
- [ ] **[Khuyến nghị]** Không cache `MediaQuery.of(context).size` trong `initState`
- [ ] **[Khuyến nghị]** Dùng `LayoutBuilder` thay vì hardcode `MediaQuery.size`
- [ ] **[Nếu dùng tablet Android 16+]** Thêm opt-out property vào `AndroidManifest.xml`
- [ ] **[UX fallback]** Set `backgroundColor: Colors.black` (hoặc màu game) để ẩn vùng trắng thoáng qua

---

## 6. Bảng So Sánh Nguyên Nhân và Fix

| Nguyên nhân | Fix tương ứng | Priority |
|---|---|---|
| AOT render trước Android resize xong | `didChangeMetrics` + `setState` | 🔴 Cao |
| Android Activity restart không cần thiết | `configChanges` đầy đủ trong Manifest | 🔴 Cao |
| `MediaQuery.size` bị cache từ `initState` | Đọc trong `build()` | 🟡 Trung bình |
| Layout không dùng constraints thực tế | Thay bằng `LayoutBuilder` | 🟡 Trung bình |
| BLASTBufferQueue chưa flush kịp | `Future.delayed(400ms)` | 🟡 Trung bình |
| Android 16+ bỏ qua `setPreferredOrientations` | Manifest opt-out / adaptive layout | 🔵 Thấp (nếu API < 36) |

---

## 7. Lưu Ý Dài Hạn

Cả hai issue #113905 và #143067 vẫn đang **OPEN** trên Flutter repository — Flutter team chưa có timeline fix chính thức. Từ Android 16 trở lên, Google đang đẩy hướng không lock orientation trên large screen.

Hướng đi bền vững nhất là **thiết kế layout adaptive** hỗ trợ cả portrait lẫn landscape thay vì dùng `setPreferredOrientations` để khóa cứng — đặc biệt quan trọng với game integration, vì Cocos Creator game thường đã có cơ chế xử lý orientation riêng ở WebView layer.

---

## 8. Tài Liệu Tham Khảo

| Tài nguyên | Link |
|---|---|
| Flutter Issue #113905 | https://github.com/flutter/flutter/issues/113905 |
| Flutter Issue #143067 | https://github.com/flutter/flutter/issues/143067 |
| Flutter Issue #108360 | https://github.com/flutter/flutter/issues/108360 |
| Flutter Issue #144307 | https://github.com/flutter/flutter/issues/144307 |
| Flutter Issue #13238 (gốc) | https://github.com/flutter/flutter/issues/13238 |
| Flutter Issue #148136 (improvement proposal) | https://github.com/flutter/flutter/issues/148136 |
| Flutter Breaking Changes — Android 16 Large Screens | https://docs.flutter.dev/release/breaking-changes/android-large-screens-restrictions-ignored |
| Flutter Docs — setPreferredOrientations API | https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html |

---

# PHẦN II — ĐIỀU TRA THỰC TẾ TRÊN CODEBASE `sun_sports`

> Mục 9–13 là kết luận chính thức cho repo này, viết sau khi đối chiếu code thực tế.
> Khi mâu thuẫn với mục 1–8, **ưu tiên mục 9–13**.

## 9. Bối Cảnh Bug Cụ Thể

- **Thiết bị:** Samsung Galaxy S22, firmware (Android) 15.
- **Kịch bản:** Mở game **bắn cá (sun cá)** → chơi (landscape) → back về Home → app **co lại còn ~1/2 màn hình, nửa dưới màu trắng**, vùng đó không resize.
- **Tính chất:** **Cố định (deterministic)**, không phải thỉnh thoảng (*sporadic*) như mô tả ở mục 2. Đây là điểm khác biệt then chốt khiến chẩn đoán "BLAST race thuần" của tài liệu gốc **chưa đủ**.

### Kiến trúc orientation thực tế của app (khác với code mẫu mục 1–8)

App **không** dùng `setPreferredOrientations` / `StatefulWidget` thô trong màn game. Nó dùng:

- Package **`orientation_guard`** qua `OrientationController` → trên Android là `DirectApplyStrategy` (chỉ gọi `SystemChrome.setPreferredOrientations`).
- Toàn app **khoá portrait trên mọi thiết bị native** (xem [app_orientation_orchestrator.dart](../../../shared/widgets/orientation/app_orientation_orchestrator.dart)).
- Game mở qua `GamePlayerScreen.push` → `GamePlayerNotifier`:
  - **Vào:** `_entryDelay` 500ms → `orientationController.apply(landscape)`.
  - **Ra:** `requestExit()` → `restore(portrait)` (delay 50ms trong `DirectApplyStrategy.restore`) → `_exitDelay` 500ms → pop.

→ Vì vậy các code mẫu ở mục 4/6 (per-screen `didChangeMetrics`, `SystemUiMode.immersiveSticky`) **không map** vào kiến trúc này.

---

## 10. Đối Chiếu Tài Liệu Gốc ↔ Thực Tế Repo

| Giải pháp (mục 4) | Trạng thái trong repo | Kết luận |
|---|---|---|
| GP3 — `configChanges` đầy đủ | **Đã có, còn đầy đủ hơn** (`density`, `fontScale`, `screenLayout`, `uiMode`, `smallestScreenSize`, `locale`, `layoutDirection`) | Không cần làm |
| GP2 — thêm `Future.delayed(400ms)` | **Đã có sẵn** (50ms restore + 500ms `_exitDelay`) | Chỉ là tinh chỉnh vị trí, không phải thêm |
| GP4 — không cache `MediaQuery.size` | **Đã đúng** — `ResponsiveBuilder.getDeviceType` đọc trong `build()` | Không cần làm |
| GP5 — `LayoutBuilder` | Game đã `Material(color: black)` | Optional |
| GP6 — immersiveSticky/edgeToEdge per-screen | **Không áp dụng** — app dùng `fullscreen_guard`, và game native **không** toggle immersive | Bỏ qua |
| GP7 — Android 16 large-screen opt-out | **Không liên quan** — Android 15, nhánh mobile, `resizeableActivity=false` | Bỏ qua |
| Con số JIT 200–400ms vs AOT 10–30ms | Minh hoạ, **không có nguồn** | Không tin tuyệt đối |

---

## 11. Hai Giả Thuyết Đã Bị LOẠI (Điều Tra Bước 3)

**❌ (1) System UI / immersive không được restore khi thoát game.**
- Luồng production mở game qua `GamePlayerScreen.push` (từ `game_group_view`, `game_filter_view`, search) → **không** gọi `FullscreenGuard`, không đổi `SystemUiMode`.
- Chỗ duy nhất dùng `FullscreenGuard.of` là `_FullscreenTestBlock` — **debug-only và đã bị comment** (`casino_view.dart`).
- System UI giữ nguyên `.branded()` (edgeToEdge) suốt phiên → không có "vào immersive, ra không khôi phục".

**❌ (2) Responsive layout cache kích thước landscape.**
- [responsive_builder.dart](../../../shared/responsive/responsive_builder.dart) đọc `MediaQuery.of(context).size.width` **trong `build()`**, `StatelessWidget`, không cache → rebuild đúng khi metrics đổi.

---

## 12. Root Cause Thật (Cho Repo Này)

Trên native, vào–ra game **chỉ** là `setPreferredOrientations(landscape)` ↔ `setPreferredOrientations(portrait)`, không động system UI, không cache layout. Vùng-trắng-nửa-màn-hình-cố-định = **race resize window** + **2 yếu tố cấu hình native làm nó trở nên deterministic trên Samsung** (tài liệu gốc không nhắc):

1. **`android:resizeableActivity="false"`** ([AndroidManifest.xml](../../../../android/app/src/main/AndroidManifest.xml)) — báo Android activity không xử lý đổi-size tốt → Samsung One UI có thể giữ/letterbox sai surface bounds sau xoay landscape→portrait. **Ứng viên số 1** cho tính cố định.
2. **`android:screenOrientation="portrait"`** trên activity — mâu thuẫn với việc runtime ép landscape cho game; transient state khi trở về dễ kẹt trên Samsung.
3. **`NormalTheme` windowBackground = `@android:color/white`** ([values/styles.xml](../../../../android/app/src/main/res/values/styles.xml)) — đúng vùng surface chưa resize/chưa vẽ lộ ra nền cửa sổ **trắng**. `values-night` lại để đen → đó là lý do màu là trắng.

**Tóm lại:** bug là **native-window-config**, không phải Flutter-engine-race thuần như Phần I khẳng định.

---

## 13. Plan Triển Khai Chính Thức (Thứ Tự Test Trên S22 Release)

Mỗi bước verify riêng để biết cái nào thật sự ăn. Chỉ tin kết quả khi **build release trên S22 thật** (debug/emulator không tái hiện).

| # | Hành động | File | Kỳ vọng | Rủi ro |
|---|---|---|---|---|
| **A** | `NormalTheme` windowBackground `white → #11100F` (đồng bộ `values-night` + theme app) | `android/app/src/main/res/values/styles.xml` | Vùng chết trắng→tối, đỡ chói ngay cả khi chưa fix gốc | Rất thấp |
| **B** | Thử `resizeableActivity="true"` (app vẫn khoá portrait bằng `orientation_guard`) | `AndroidManifest.xml` | Window resize về portrait full-height sạch → **fix gốc triệu chứng cố định** | Trung bình — test split-screen/multi-window |
| **C** | Bỏ `screenOrientation="portrait"` ở activity (đã quản portrait bằng `orientation_guard`) | `AndroidManifest.xml` | Loại mâu thuẫn manifest↔runtime | Trung bình — verify app vẫn mở portrait đúng |
| **D** | Thêm `didChangeMetrics` ép re-layout ở **root** (nâng `AppOrientationOrchestrator` thành observer) | `app_orientation_orchestrator.dart` | Buộc Flutter vẽ lại đúng size nếu A–C chưa đủ | Thấp |
| **E** | Tận dụng `_exitDelay` 500ms: chờ `didChangeMetrics` portrait rồi mới pop, thay vì delay cứng | `game_player_notifier.dart` | Đồng bộ pop với resize thật | Thấp |

**Khuyến nghị:** test **A + B** trước (A che triệu chứng, B nhắm gốc — đều là sửa nhỏ ở native config). Rất có thể A+B đã đủ; C bổ trợ; D/E chỉ cần khi B bị chặn vì lý do sản phẩm.

**Trạng thái hiện tại:** **đang test bước B** — đã đổi `resizeableActivity="false" → "true"` trong manifest. Giữ nguyên `screenOrientation="portrait"` để test đơn biến. A, C, D, E chưa triển khai. Đang chờ kết quả build release trên S22.

---

*Phần II cập nhật: sau điều tra codebase, nhánh `fix_bug/GSB-107`.*


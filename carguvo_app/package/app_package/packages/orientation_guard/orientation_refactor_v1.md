# Tài liệu refactor v1 cho package quản lý orientation trong Flutter

## Tổng quan

Tài liệu này mô tả bối cảnh, mục tiêu, vấn đề hiện tại, định hướng kiến trúc, kế hoạch refactor và cách triển khai phiên bản v1 cho một package Flutter chuyên quản lý orientation theo screen và theo nền tảng.[cite:1][cite:84][cite:96]

Phạm vi của v1 là thu gọn package về đúng một trách nhiệm: quản lý orientation policy, apply orientation theo policy, restore policy trước đó, và hiển thị mismatch UI khi cần; package không còn quản lý immersive, fullscreen hay các system UI concern khác.[cite:84][cite:96][cite:6]

Use case trọng tâm của v1 là luồng Navigator thuần trong Flutter: Home dùng portrait, Game dùng landscape, và khi thoát Game thì ứng dụng quay lại portrait một cách ổn định, dễ dự đoán và dễ debug.[cite:13][cite:1]

## Bối cảnh

Flutter cung cấp `SystemChrome.setPreferredOrientations()` để giới hạn orientation mà ứng dụng cho phép sử dụng trên thiết bị.[cite:1]

Tuy nhiên, hành vi orientation không đồng nhất giữa các nền tảng. Trên web, Flutter chủ yếu có thể phản ứng theo orientation hiện có của viewport thay vì ép xoay thiết bị. Trên iPad, tài liệu Flutter nêu rõ orientation lock chỉ được tôn trọng đầy đủ khi tắt multitasking bằng `UIRequiresFullScreen`.[cite:6][cite:1]

Ngoài ra, các issue liên quan đến iOS 16+ và iPadOS cho thấy việc đổi orientation theo từng screen có thể gặp lỗi runtime như `UISceneErrorDomain Code=101`, restore không đúng như mong đợi, hoặc cần đi qua các bước trung gian trước khi apply policy đích.[cite:38][cite:54]

Trong bối cảnh đó, package hiện tại đã đi đúng hướng ở mặt ý tưởng vì đã tách native/web controller, có guard widget, provider và mismatch view. Tuy nhiên, package vẫn còn pha trộn nhiều concern và chưa khóa chặt được runtime semantics cho iOS/web/native.[cite:84]

## Mục đích của bản refactor v1

Bản refactor v1 nhằm đạt bốn mục tiêu chính:

- Chuẩn hóa package thành orientation-only package, tránh trộn fullscreen hoặc immersive vào cùng một boundary.[cite:84][cite:96]
- Xây lại lõi runtime theo strategy để xử lý đúng sự khác biệt giữa Android, iOS và web.[cite:67]
- Đảm bảo restore orientation theo `previous policy` hoặc `default policy`, thay vì mở mù toàn bộ orientation sau mỗi screen.[cite:1][cite:38]
- Giữ API đủ gọn để áp dụng thực tế với `Navigator.push/pop`, đặc biệt cho app game hoặc app có một vài screen đặc biệt cần landscape.[cite:13][cite:39]

## Vấn đề hiện tại

### 1. Boundary trách nhiệm chưa rõ

Package hiện tại đang ôm nhiều concern hơn mức cần thiết cho một orientation package. Cụ thể, phần web controller đang gắn với fullscreen hoặc immersive trong khi orientation và fullscreen là hai bài toán khác nhau về bản chất và vòng đời xử lý.[cite:6][cite:84]

Điều này làm API dễ gây hiểu nhầm: caller tưởng đang điều khiển orientation, nhưng thực tế controller còn đụng tới presentation state. Khi fullscreen có bug riêng trên browser, package orientation sẽ bị kéo theo dù không liên quan trực tiếp.[cite:6][cite:84]

### 2. Restore semantics chưa đúng

Việc restore về “all orientations” không tương đương với restore về trạng thái trước đó. Với flow thực tế như Home portrait -> Game landscape -> Back Home portrait, điều cần thiết là quay về policy trước đó hoặc policy mặc định, không phải lúc nào cũng mở toàn bộ orientation.[cite:1][cite:38]

Đây là nguyên nhân phổ biến làm behavior trở nên khó đoán khi push/pop screen nhanh hoặc có nhiều guard lồng nhau.[cite:13][cite:38]

### 3. iOS có hành vi runtime đặc biệt

Trên iOS 16+, việc đổi orientation không còn là bài toán đơn giản “gọi API là xong”. Các issue cho thấy có trường hợp cần flush orientation mask, có trường hợp cần đi qua một orientation trung gian, và có trường hợp việc thay đổi programmatic orientation bị từ chối bởi scene/window mode hiện tại.[cite:38][cite:54][cite:76]

Nếu logic này tiếp tục nằm trực tiếp trong một controller native duy nhất, class đó sẽ phình to, khó test, và đầy điều kiện rẽ nhánh khó bảo trì.[cite:67]

### 4. Web không thể force rotate như native

Trên web, orientation là trạng thái của viewport nhiều hơn là một capability có thể ép được bằng Flutter. Vì vậy cách đúng là phát hiện mismatch và đưa ra UI phù hợp, thay vì cố mô phỏng native orientation lock trên browser.[cite:6]

### 5. Widget layer đang gánh quá nhiều việc

Một guard widget mà đồng thời resolve controller, apply policy, restore policy, log trạng thái, detect mismatch và quyết định block UI sẽ sớm trở thành “god widget”. Kiến trúc như vậy khó kiểm soát khi package mở rộng hoặc khi cần test unit từng phần.[cite:84][cite:96]

## Nguyên tắc thiết kế cho v1

Phiên bản v1 sẽ bám theo các nguyên tắc sau:

- Một package, một trách nhiệm: package này chỉ quản lý orientation.[cite:84][cite:96]
- Runtime behavior phải được chọn theo chiến lược, không hard-code rẽ nhánh tràn lan trong controller.[cite:67]
- Public API cần nhỏ, typed rõ ràng và dễ đoán.[cite:84]
- Web được xem là nền tảng mismatch-aware, không phải force-rotation-capable platform.[cite:6]
- Restore orientation phải dựa trên policy stack hoặc ít nhất là previous policy, không dùng restore mù.[cite:1][cite:38]

## Phạm vi của v1

### Bao gồm

- Orientation policy.
- Orientation controller.
- Native/web runtime strategy.
- Guard widget để apply policy theo vòng đời screen.
- Mismatch view để chặn hoặc hướng dẫn người dùng khi orientation không phù hợp.[cite:1][cite:6]

### Không bao gồm

- Fullscreen.
- Immersive mode.
- Status bar hoặc system overlays.
- Gesture để ẩn UI trình duyệt.
- Quản lý presentation mode ngoài orientation.[cite:6][cite:84]

## Kiến trúc mục tiêu của v1

### Lớp mô hình

Các model cốt lõi của v1 gồm:

- `OrientationPolicy`: mô tả orientation đích mà screen mong muốn.[cite:1]
- `OrientationApplyResult`: mô tả kết quả của một lần apply policy, có trạng thái rõ ràng như matched, mismatched, unsupported hoặc failed.[cite:1]
- `OrientationRuntimeContext`: chứa state runtime cần thiết để strategy ra quyết định như current policy, previous policy, platform, số lần thử và metadata nền tảng.[cite:38][cite:76]

### Lớp service/controller

`OrientationController` là boundary chính mà widget layer sử dụng. Interface này chỉ nên có ba hành vi: apply policy, restore policy, và đánh giá orientation hiện tại có match policy hay không.[cite:84][cite:1]

Controller không nên nhúng trực tiếp toàn bộ logic iOS workaround. Thay vào đó, controller chỉ giữ runtime context và ủy quyền cho strategy phù hợp.[cite:67][cite:38]

### Lớp strategy

Đây là phần quan trọng nhất của v1. Strategy pattern phù hợp vì package đang có cùng một mục tiêu nghiệp vụ là “apply orientation”, nhưng cần nhiều thuật toán runtime khác nhau tùy nền tảng và tình huống.[cite:67]

Các strategy cốt lõi của v1 gồm:

- `DirectApplyStrategy`: áp dụng trực tiếp bằng `SystemChrome.setPreferredOrientations()` cho Android hoặc case native đơn giản.[cite:1]
- `IosFlushThenApplyStrategy`: dành cho iOS khi cần flush hoặc đi qua trạng thái trung gian trước khi set target, đặc biệt khi vào landscape.[cite:38][cite:54]
- `IosRestoreStrategy`: dùng cho case restore từ landscape về portrait hoặc về previous policy trên iOS.[cite:38]
- `WebNoopStrategy`: không force rotate, chỉ phản ánh kết quả theo khả năng của web và để UI layer xử lý mismatch.[cite:6]

### Lớp widget

Widget layer được thu gọn thành hai thành phần chính:

- `OrientationScope`: cung cấp controller xuống cây widget theo kiểu InheritedWidget đơn giản.[cite:84]
- `OrientationGuard`: gắn policy vào một subtree hoặc screen và apply/restore theo lifecycle của widget.[cite:13]

Ngoài ra, `OrientationMismatchView` là widget độc lập để hiển thị khi orientation hiện tại không thỏa policy. Widget này nên cho phép custom builder hoặc localization để package có thể tái sử dụng tốt hơn.[cite:6]

## iOS orientation strategy matrix trong v1

V1 chưa cần một matrix quá chi tiết, nhưng vẫn cần ít nhất một bảng quyết định runtime cho iOS vì behavior trên iOS 16+/iPadOS không đủ ổn định để dùng một thuật toán duy nhất.[cite:38][cite:54][cite:76]

| Tình huống | Điều kiện | Strategy đề xuất |
|---|---|---|
| Apply đơn giản | iOS nhưng target không phải case đặc biệt | `DirectApplyStrategy` [cite:1] |
| Vào game landscape | Từ portrait sang landscape trên iOS | `IosFlushThenApplyStrategy` [cite:38][cite:54] |
| Thoát game về portrait | Từ landscape về previous/default portrait policy | `IosRestoreStrategy` [cite:38] |
| Web hoặc không force được | Browser hoặc runtime không đảm bảo rotate | `WebNoopStrategy` + mismatch UI [cite:6] |

Mục tiêu của matrix này không phải là “hack để luôn xoay được”, mà là giúp runtime chọn cách xử lý phù hợp và fallback có kiểm soát khi không thể ép orientation như mong muốn.[cite:38][cite:76]

## Public API đề xuất cho v1

### OrientationController

```dart
abstract class OrientationController {
  Future<OrientationApplyResult> apply(OrientationPolicy policy);
  Future<void> restore();

  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });
}
```

Thiết kế này giúp contract trở nên typed, rõ ràng và dễ kiểm thử hơn việc để `Future` không có kiểu trả về cụ thể.[cite:84]

### OrientationPolicy

```dart
class OrientationPolicy {
  final List<DeviceOrientation> targets;
  final bool blockOnMismatch;
  final String? debugLabel;

  const OrientationPolicy({
    required this.targets,
    this.blockOnMismatch = false,
    this.debugLabel,
  });
}
```

`OrientationPolicy` trong v1 chỉ chứa các field liên quan trực tiếp đến orientation. Mọi field như immersive hoặc fullscreen sẽ bị loại bỏ khỏi package này.[cite:6][cite:84]

### OrientationApplyResult

```dart
enum OrientationStatus {
  matched,
  mismatched,
  unsupported,
  failed,
}

class OrientationApplyResult {
  final OrientationPolicy policy;
  final OrientationStatus status;
  final bool matched;
  final bool canControlPlatform;
  final Object? error;

  const OrientationApplyResult({
    required this.policy,
    required this.status,
    required this.matched,
    required this.canControlPlatform,
    this.error,
  });
}
```

Model này cho phép widget layer hoặc app layer phản ứng rõ hơn với từng loại kết quả thay vì chỉ dựa vào exception hoặc debug print.[cite:84]

## Cấu trúc thư mục đề xuất

```text
lib/
  orientation_guard.dart

  src/
    models/
      orientation_policy.dart
      orientation_apply_result.dart
      orientation_runtime_context.dart

    services/
      orientation_controller.dart
      orientation_strategy.dart
      orientation_strategy_resolver.dart

    controllers/
      native_orientation_controller.dart
      web_orientation_controller.dart

    strategies/
      direct_apply_strategy.dart
      ios_flush_then_apply_strategy.dart
      ios_restore_strategy.dart
      web_noop_strategy.dart

    widgets/
      orientation_guard.dart
      orientation_scope.dart
      orientation_mismatch_view.dart
```

Cấu trúc này đơn giản hơn mô hình cũ vì loại bỏ orchestrator dư thừa và gom các abstraction theo đúng vai trò: model, service, controller, strategy, widget.[cite:84][cite:113]

## Kế hoạch refactor

### Giai đoạn 1: Chốt phạm vi và API

- Loại immersive/fullscreen ra khỏi package hiện tại.[cite:6][cite:84]
- Chốt `OrientationPolicy`, `OrientationApplyResult`, `OrientationController`.[cite:84]
- Đổi mọi interface trả `Future` không typed thành kiểu cụ thể.[cite:84]

### Giai đoạn 2: Tạo runtime context và strategy layer

- Tạo `OrientationRuntimeContext`.
- Tạo `OrientationStrategy` interface.
- Cài đặt `DirectApplyStrategy`, `IosFlushThenApplyStrategy`, `IosRestoreStrategy`, `WebNoopStrategy`.[cite:67][cite:38]
- Tạo `OrientationStrategyResolver` để chọn strategy phù hợp theo platform và transition runtime.[cite:67]

### Giai đoạn 3: Refactor controller

- `NativeOrientationController` chỉ còn vai trò giữ context và delegate sang strategy.[cite:67]
- `WebOrientationController` chỉ phản ánh match/mismatch hoặc trả kết quả phù hợp với khả năng web, không đụng đến fullscreen.[cite:6]
- `restore()` phải dùng previous policy hoặc default policy.[cite:1][cite:38]

### Giai đoạn 4: Refactor widget layer

- Đổi `OrientationProvider` thành `OrientationScope` với naming rõ ràng hơn.[cite:84]
- Giảm trách nhiệm của `OrientationGuard` để nó chỉ lo lifecycle apply/restore và mismatch rendering ở mức tối thiểu.[cite:84][cite:96]
- `OrientationMismatchView` cho phép custom text hoặc builder.[cite:6]

### Giai đoạn 5: Example và test

- Viết example `Home -> Game -> Back` dùng `Navigator.push/pop`.[cite:13]
- Viết example web mismatch UI.[cite:6]
- Viết unit test cho strategy resolver, controller và guard lifecycle.[cite:96]

## Cách triển khai cụ thể

### Bước 1: Dọn boundary của package

Xóa hoặc deprecate các field và logic liên quan đến immersive/fullscreen. Nếu ứng dụng cần cả fullscreen lẫn orientation, fullscreen phải được quản lý bởi một module khác ở app layer hoặc một package riêng.[cite:6][cite:84]

### Bước 2: Chuẩn hóa model

Tạo ba model public mới:

- `OrientationPolicy`
- `OrientationApplyResult`
- `OrientationRuntimeContext`

Ba model này phải độc lập, ít phụ thuộc chéo và dễ serialize/debug nếu cần.[cite:84]

### Bước 3: Tạo strategy interface

```dart
abstract class OrientationStrategy {
  Future<OrientationApplyResult> apply({
    required OrientationPolicy policy,
    required OrientationRuntimeContext context,
  });

  Future<void> restore({
    required OrientationRuntimeContext context,
  });
}
```

Mục tiêu là để controller không còn chứa thuật toán apply/restore đặc thù theo từng nền tảng hoặc từng tình huống.[cite:67]

### Bước 4: Tạo strategy resolver

Resolver của v1 chỉ cần đủ đơn giản để quyết định ba case chính:

- Web -> `WebNoopStrategy`.[cite:6]
- iOS + landscape target -> `IosFlushThenApplyStrategy`.[cite:38]
- Còn lại -> `DirectApplyStrategy`.[cite:1]

Khi restore trên iOS, resolver sẽ trả `IosRestoreStrategy` thay vì direct strategy.[cite:38]

### Bước 5: Refactor controller

Controller phải giữ `currentPolicy` và `previousPolicy`. Sau mỗi lần apply thành công, `previousPolicy` được cập nhật từ policy cũ. Khi restore, controller khôi phục về `previousPolicy` hoặc `defaultPolicy`.[cite:1][cite:38]

Đây là thay đổi semantics lớn nhất và cũng quan trọng nhất của v1.[cite:38]

### Bước 6: Refactor widget layer

`OrientationScope` là nơi cung cấp controller xuống widget tree. `OrientationGuard` dùng controller này để apply policy trong `didChangeDependencies` hoặc `didUpdateWidget`, và gọi restore trong `dispose()`.[cite:84][cite:13]

Mismatch UI chỉ hiển thị khi `blockOnMismatch` được bật và orientation hiện tại không thỏa policy. Điều này đặc biệt hữu ích trên web hoặc trên các nền tảng không thể bảo đảm rotate chính xác như native mobile.[cite:6]

## Ví dụ use case mục tiêu

Use case mà v1 phải chạy ổn định là:

1. Ứng dụng khởi động ở Home với `OrientationPolicy.portrait`.[cite:1]
2. Người dùng bấm vào Game, `Navigator.push()` mở `GamePage` với `OrientationPolicy.landscape`.[cite:13]
3. Trên iOS, runtime resolver chọn `IosFlushThenApplyStrategy`; trên Android chọn `DirectApplyStrategy`; trên web chỉ detect mismatch.[cite:38][cite:6]
4. Khi thoát Game, `dispose()` hoặc route pop kích hoạt restore về previous policy là portrait.[cite:13][cite:38]

## Rủi ro và lưu ý nền tảng

### iOS/iPad

- iPad cần `UIRequiresFullScreen` nếu muốn orientation lock được tôn trọng đầy đủ.[cite:1]
- iOS 16+ có thể xuất hiện lỗi runtime liên quan đến scene orientation và restore behavior.[cite:38][cite:54][cite:76]
- Strategy phải được thiết kế theo hướng best-effort, có fallback rõ ràng.[cite:38]

### Android

- `SystemChrome.setPreferredOrientations()` hoạt động tốt hơn native web, nhưng hành vi trên thiết bị màn hình lớn và Android mới cần được kiểm tra cẩn thận.[cite:1]

### Web

- Web không nên được xem là nền tảng force-rotation-capable.[cite:6]
- Package chỉ nên detect mismatch và hiển thị UI phù hợp khi cần.[cite:6]

## Tiêu chí hoàn thành v1

Bản v1 được xem là đạt yêu cầu khi thỏa tất cả các điều kiện sau:

- Package không còn chứa logic immersive/fullscreen.[cite:6]
- Public API nhỏ, typed rõ ràng và dễ sử dụng.[cite:84]
- `Home -> Game -> Back` chạy ổn định bằng `Navigator` trong example app.[cite:13]
- iOS có strategy riêng cho apply và restore.[cite:38]
- Web không force rotate, chỉ mismatch-aware.[cite:6]
- Restore semantics dựa trên previous policy thay vì all orientations.[cite:1][cite:38]
- Có example và test tối thiểu cho controller, strategy resolver và guard lifecycle.[cite:96]

## Kết luận

Refactor v1 không nhằm giải quyết mọi edge case orientation trên mọi nền tảng, mà nhằm đưa package về một lõi kiến trúc đúng, gọn, dễ bảo trì và đủ thực dụng cho use case chính là orientation theo screen trong Flutter.[cite:84][cite:96]

Khi v1 ổn định, các bước phát triển tiếp theo mới nên bao gồm policy stack nâng cao, matrix chi tiết hơn cho iOS, adaptive resolver public, telemetry hoặc các tối ưu dành cho app quy mô lớn.[cite:38][cite:67]

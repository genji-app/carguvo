# Dynamic Assets — Tài liệu Kiến trúc & Hướng dẫn Sử dụng (Chuẩn Enterprise)

> **Dự án**: S88 (Casino/Game App)  
> **Module**: `dynamic_assets`  
> **Trạng thái**: Refactoring hoàn tất — Đã áp dụng Dependency Injection (DI) & Logging tập trung.

---

## 1. Tổng quan (Executive Summary)

Module `dynamic_assets` chịu trách nhiệm tải, tối ưu hóa bộ nhớ, lưu trữ đệm (caching) và hiển thị toàn bộ tài nguyên hình ảnh (SVG, Bitmap PNG/JPG) của ứng dụng Casino S88 bao gồm Game Card, Banner, Icon danh mục, v.v.

Hệ thống được thiết kế độc lập hoàn toàn khỏi lớp tiện ích chung `ImageHelper` nhằm:
- Cho phép tối ưu cấu hình cache riêng biệt (2000 files, stale period 30 ngày) phù hợp với lượng Game Thumbnail khổng lồ.
- Hỗ trợ tính toán chính xác tổng dung lượng cache và cung cấp chức năng xóa cache.
- Tự động hóa việc chọn luồng xử lý tối ưu theo nền tảng (Web vs Native) và loại tài nguyên (SVG vs Bitmap).
- Đảm bảo tính ổn định tối đa thông qua cơ chế tự động fallback khi lỗi.

---

## 2. Cấu trúc Thư mục (Module Structure)

Để tuân thủ tốt nguyên tắc phân tách trách nhiệm (Separation of Concerns) và đảm bảo tính độc lập, cấu trúc thư mục của module `dynamic_assets` được thiết kế như sau:

```
lib/features/game/
└── dynamic_assets/                        # [CORE MODULE - PURE FLUTTER]
    ├── dynamic_assets.dart                # Entry point cho BASE PACKAGE (Không dùng Riverpod, chỉ export core)
    ├── cache/
    │   ├── asset_cache_controller.dart    # Central Controller quản lý cache lifecycle & InheritedWidget scope
    │   ├── asset_image_cache_manager.dart # Custom ImageCacheManager quản lý dung lượng ảnh bitmap đĩa
    │   └── asset_storage.dart             # Tầng lưu trữ persistent cho SVG (Hive lazyBox)
    └── network_asset/
        ├── network_asset.dart             # Public Widget chính (Pure StatefulWidget)
        ├── network_asset_components.dart  # Các widget UI dùng chung (Placeholder, Error, FadeIn)
        ├── svg_network_widget.dart        # Widget tải và hiển thị SVG kèm cache Hive
        ├── native_bitmap.dart             # Widget tải và hiển thị bitmap native kèm CacheManager
        └── network_retry_mixin.dart       # Mixin hỗ trợ exponential retry cho mạng
```

---

## 3. Kiến trúc Caching Lai (Hybrid Caching)

Hệ thống sử dụng các chiến lược cache khác nhau cho từng loại tài nguyên để tối ưu hiệu năng:

```
AssetCacheController (Core)
         │
         ├── SVG Cache ───────► HiveAssetStorage (lazy lazyBox) ──► IndexedDB (Web) / Disk (Native)
         │
         └── Bitmap Cache ────► AssetImageCacheManager ──────► Native Disk Cache (Max 2000, 30 ngày)
```

### 3.1 Caching Vector (SVG)
- **Công nghệ**: Sử dụng Hive NoSQL (`Hive.lazyBox<String>`).
- **Web**: Hive biên dịch thành `IndexedDB`, cho phép lưu trữ dung lượng lớn và không bị giới hạn 5MB như `LocalStorage`.
- **Native**: Lưu dữ liệu nhị phân trực tiếp trên ổ cứng.
- **Lazy Loading**: Chỉ nạp các "keys" vào RAM, nội dung SVG chỉ nạp khi widget hiển thị thực sự, tránh tràn bộ nhớ RAM (chống Out-Of-Memory).
- **Concurrency Control & Request Deduplication**:
  - `AssetSemaphore`: Giới hạn tối đa 6 kết nối đồng thời trên Web (để phù hợp với Chrome HTTP/1.1 per-origin limit) và 10 kết nối trên Native.
  - Sử dụng một bản đồ in-flight requests (`_inFlight`) để gộp các request tải cùng một SVG trùng nhau tại cùng một thời điểm thành duy nhất một HTTP call.

### 3.2 Caching Bitmap (PNG/JPG)
- **Công nghệ**: Dùng custom `AssetImageCacheManager` (kế thừa `CacheManager with ImageCacheManager`).
- **Tối ưu hóa**:
  - `maxNrOfCacheObjects: 2000` (giữ tối đa 2000 ảnh game thay vì 100).
  - `stalePeriod: Duration(days: 30)` (giữ ảnh game tĩnh trong 30 ngày).
  - Cho phép resize ảnh lúc ghi đĩa đệm (`maxWidthDiskCache` / `maxHeightDiskCache`) giúp tiết kiệm dung lượng đĩa.
  - **Web**: Sử dụng cơ chế cache tự nhiên của trình duyệt qua thẻ `<img>` tiêu chuẩn.

### 3.3 Tự động Dọn dẹp & Quản lý Dung lượng
- **Invalidation 3 ngày**: Khi `AssetCacheController.init()` được gọi, hệ thống kiểm tra mốc thời gian lưu trong storage. If quá 3 ngày, hệ thống sẽ thực hiện dọn dẹp ngầm toàn bộ đĩa đệm và cơ sở dữ liệu Hive, sau đó cập nhật mốc thời gian mới.
- **Tính toán & Dọn dẹp**:
  - Cung cấp phương thức `calculateTotalCacheSizeMB()` để tính dung lượng cache trên disk (trả về 0.0 trên Web).
  - Phương thức `clearAllCaches()` xóa toàn bộ dữ liệu database và file đệm.

---

## 4. Cơ chế Dự phòng & Khả năng Chống lỗi (Fail-safe)

Để đảm bảo hình ảnh luôn được hiển thị kể cả trong điều kiện môi trường thử nghiệm phức tạp (ví dụ: iOS Simulator thay đổi Sandbox UUID làm mất quyền truy cập file cũ, hoặc lỗi ghi đĩa đệm):
- **Exponential Backoff Retry**: Tự động thử lại khi tải lỗi với độ trễ tăng dần (2s, 4s, 8s...).
- **Fallback sang Image.network**: Đối với ảnh Bitmap trên Native, nếu `CachedNetworkImage` sử dụng Custom CacheManager bị lỗi quá số lần quy định (`maxRetries`), widget sẽ tự động chuyển sang hiển thị bằng `Image.network` tiêu chuẩn của Flutter (bỏ qua cache manager) để đảm bảo người dùng không bị treo màn hình chờ.

---

## 5. Đồng bộ hóa Logging tập trung (`LoggerMixin`)

Để chuẩn hóa việc xuất nhật ký ứng dụng và dễ dàng theo dõi lỗi:
- Module kế thừa `LoggerMixin` dùng chung của hệ thống tại [log_helper.dart](file:///Users/admin/Documents/s88-flutter/lib/core/utils/extensions/log_helper.dart).
- Each class chỉ định một `logTag` duy nhất thông qua việc override:
  ```dart
  @override
  String get logTag => 'AssetCache';
  ```
- Việc gọi log được thực hiện trực tiếp thông qua các hàm tiện ích `logInfo(message)` hoặc `logError(message, error, stackTrace)`.
- Hệ thống log tự động tắt trong môi trường Product (`kDebugMode = false`), và in kèm icon trạng thái cũng như timestamp trong Debug mode.

---

## 6. Widget Layer & APIs

### 6.1 `NetworkAsset`
Widget chính bên ngoài để nạp tài nguyên:
```dart
const NetworkAsset({
  required this.path,
  this.width,
  this.height,
  this.fit = BoxFit.cover,
  this.color,
  this.placeholder,
  this.errorWidget,
  this.maxRetries = 3,
  this.cacheWidth,
  this.cacheHeight,
  this.fadeIn = true,
  super.key,
});
```

### 6.2 Tối ưu hóa GPU composite layer (`_NetworkFadeIn`)
Thay thế lớp hoạt ảnh `AnimatedOpacity` (chạy trên UI Thread, trigger rebuild mỗi frame) bằng `FadeTransition` kết hợp với `AnimationController` (chạy trực tiếp trên compositor thread của GPU), giúp giao diện mượt mà tuyệt đối khi có hàng chục card game cùng hiển thị đồng thời.

---

## 7. Chiến lược Kiểm thử (Unit Tests)

Hệ thống đi kèm bộ kiểm thử tự động toàn diện tại [asset_cache_controller_test.dart](file:///Users/admin/Documents/s88-flutter/test/features/game/dynamic_assets/asset_cache_controller_test.dart).
- Sử dụng Mocktail để giả lập `CacheManager` và `AssetStorage`.
- Giả lập file system an toàn thông qua cấu hình `PathProviderPlatform.instance` của package `path_provider_platform_interface` thay thế cho method channel cũ, giúp triệt tiêu hoàn toàn log cảnh báo giả trên Host OS.
- Bao phủ các kịch bản kiểm thử:
  - Khởi tạo controller và thiết lập database.
  - Tự động xóa cache sau chu kỳ 3 ngày.
  - Tính toán dung lượng đĩa đệm.
  - Hoạt động của Semaphore điều phối kết nối.

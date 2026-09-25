# Transaction Repository

Transaction Repository là một core module chuyên trách việc xử lý giao dịch nạp, rút và quản lý lịch sử giao dịch (bao gồm cả khiếu nại, thanh toán qua cổng Codepay, Crypto, thẻ cào điện thoại, và lịch sử hoạt động chơi game) trong dự án `s88-flutter`.

---

## 📖 Master Specification (Source of Truth)

Toàn bộ thiết kế kiến trúc chi tiết, sơ đồ luồng dữ liệu, API Inventory, cấu hình Cache, đặc tả Mapper, Riverpod Providers, Notifiers và giao diện UI của module này được tài liệu hóa tập trung tại:
👉 **[Transaction History — Master Specification (transaction-history-spec.md)](file:///Users/admin/Documents/s88-flutter/lib/core/services/repositories/transaction_repository/transaction-history-spec.md)**

*Vui lòng luôn tham chiếu và cập nhật Master Specification trên làm Source of Truth duy nhất khi thay đổi bất kỳ logic nào trong module này.*

---

## 🛠️ Kiến trúc (Architecture)

Module tuân thủ nghiêm ngặt mô hình **Strongly-Typed** và kiến trúc sạch (**Clean Architecture**):

1. **Data Sources (`src/data_sources/`)**: 
   - Giao tiếp trực tiếp với hạ tầng mạng thông qua `SbHttpManager`.
   - Phân rã dữ liệu thô (Map) thành các strongly-typed models cụ thể cho từng cổng nạp/rút độc lập (ví dụ: Codepay, thẻ cào, lịch sử hoạt động).
   - Mới tích hợp: `ActivityLogDataSource` đảm nhận lấy lịch sử hoạt động và API dọn dẹp lịch sử.
2. **Models (`src/models/`)**: 
   - `api_responses.dart`: Các mô hình phản hồi API cấu trúc động (dùng `Freezed` union classes).
   - `unified_transaction.dart`: Domain Model hợp nhất tên là `UnifiedTransaction` dùng chung cho toàn bộ giao diện UI. 
   - Lưu trữ an toàn dữ liệu gốc nguyên bản thông qua Union Class `TransactionOriginalData` ở trường `originalData`.
3. **Mapper (`src/transaction_mapper.dart`)**:
   - Chịu trách nhiệm chuyển đổi (mapping) các strongly-typed models từ Data Sources sang `UnifiedTransaction`.
   - Đảm bảo tính nhất quán của kiểu dữ liệu, loại bỏ hoàn toàn các logic ép kiểu (cast) không an toàn ở tầng UI.
4. **Repository Layer (`src/transaction_repository.dart`)**:
   - Điều hướng (dispatch) yêu cầu truy vấn đến đúng Data Source tương ứng dựa trên bộ lọc hoạt động (`TransactionFilter`).
   - Tích hợp lớp Cache trang đầu tiên (`InMemoryTransactionCache`) với TTL 2 phút để cải thiện tốc độ tải trang.
   - Phát đi các sự kiện đột biến (`TransactionEvent`) qua luồng Stream để tự động đồng bộ hóa UI giữa các màn hình.

---

## 🌟 Tính Năng Chính

- **Đa nguồn hợp nhất (Multi-source Unified)**: Đồng bộ tất cả hoạt động tài chính (Codepay, Crypto, Thẻ cào, Play History) vào một luồng dữ liệu `UnifiedTransaction` duy nhất.
- **Lịch sử hoạt động (Activity Log / Play History)**: Tích hợp đầy đủ luồng lịch sử biến động số dư game và hỗ trợ API dọn dẹp dữ liệu (`clearActivityLogs()`).
- **Lưu giữ scroll state thông minh**: Áp dụng giải pháp `IndexedStack` cho giao diện tab lọc để bảo toàn 100% vị trí cuộn khi người dùng chuyển đổi tab.
- **Đồng bộ tự động (Event-driven Sync)**: Khi có giao dịch nạp thành công ở màn hình nạp thẻ, hệ thống tự động phát event để refresh lại màn hình Lịch sử giao dịch một cách mượt mà.

---

## 📝 Lịch Sử Thay Đổi Đáng Chú Ý

- **v3.9 (Hiện tại)**: Tích hợp thành công Lịch sử hoạt động (Activity Log) và API dọn dẹp lịch sử. Do endpoint `/gameapi/public/history/cleanup` (GET) chưa deploy trên Staging (`api.ezplace1.net`) gây ra lỗi 404, nút xóa lịch sử tạm thời được **ẩn (comment out) trên UI** để đảm bảo static analysis sạch sẽ. Khi Backend hoàn thành, chỉ cần mở comment code trên UI là tính năng sẽ hoạt động ngay lập tức.
- **v3.7**: Thay thế toàn bộ trường `rawData` (`Map<String, dynamic>`) bằng `originalData` (`TransactionOriginalData` union) trong `UnifiedTransaction`, bắt lỗi không khớp kiểu ngay tại compile-time thay vì runtime.
- **v3.0**: Tách biệt luồng READ/WRITE và tái cơ cấu kiến trúc sang Delegate Pattern nhằm dễ dàng mở rộng thêm Data Source mà không phá vỡ logic cũ.

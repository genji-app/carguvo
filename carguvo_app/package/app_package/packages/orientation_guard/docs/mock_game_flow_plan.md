# Kế hoạch mô phỏng luồng Game Player ở Example (Orientation Guard)

## 1. Ngữ cảnh
Hiện tại ở App Layer (ví dụ `GamePlayerScreen`), luồng hoạt động thông thường khi người dùng mở một game như sau:
1. Màn hình Home mặc định ở **Portrait**.
2. Người dùng chọn một Game (mỗi game có một hướng chỉ định, ví dụ **Landscape**).
3. Ứng dụng chuyển sang màn hình Game, hiển thị **Loading** (để tải asset, khởi tạo engine...).
4. Trong lúc loading, ứng dụng **thực thi việc xoay màn hình** theo hướng của Game.
5. Khi loading xong (và hướng màn hình đã được đảm bảo), ẩn Loading và hiển thị **Game UI**.
6. Khi người dùng thoát (Pop) khỏi màn hình Game, hướng màn hình được **trả về như cũ** (Portrait của Home).

## 2. Mục tiêu ở Example
Mô phỏng lại luồng này ở mức đơn giản trong `packages/orientation_guard/example/lib/main.dart` để chứng minh `OrientationGuard` (phiên bản refactor) có thể xử lý trơn tru lifecycle này bằng cách tiếp cận **Declarative** (Khai báo), không cần gọi API imperative thủ công.

## 3. Các bước triển khai

### Bước 1: Khóa hướng cho Home Screen
- Bọc `HomeScreen` trong một `OrientationGuard(policy: OrientationPolicy.portrait)`.
- Điều này đảm bảo Home luôn ở Portrait. Đồng thời, nó tạo ra một "previous policy" rõ ràng để các màn hình sau có thể khôi phục lại.

### Bước 2: Tạo màn hình `MockGameScreen`
- Tạo một `StatefulWidget` có tên `MockGameScreen`.
- Nhận tham số `OrientationPolicy gamePolicy` (để test cả game ngang lẫn game dọc).
- Khai báo một biến state `bool _isLoading = true`.
- Trong `initState`, sử dụng `Future.delayed(const Duration(seconds: 2))` để giả lập thời gian tải game. Sau đó set `_isLoading = false`.

### Bước 3: Tích hợp `OrientationGuard` vào `MockGameScreen`
- Trong hàm `build` của `MockGameScreen`, bọc nội dung bằng `OrientationGuard`:
  ```dart
  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: widget.gamePolicy,
      // Khi mismatch (sai hướng vật lý), hiển thị popup chặn người dùng
      mismatchBuilder: (context) => const CustomMismatchScreen(), 
      child: Scaffold(
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator()) // Hiển thị Loading
            : const GameUI(), // Hiển thị Game sau khi load xong
      ),
    );
  }
  ```

### Bước 4: Kiểm chứng luồng hoạt động
Với cấu trúc trên, Lifecycle sẽ diễn ra như sau:
1. **Push `MockGameScreen`**: `OrientationGuard` được mount. Nó ghi nhận `previousPolicy` (Portrait) và gọi `controller.apply(gamePolicy)`.
2. **Hiển thị Loading**: Biến `_isLoading` đang là `true`, UI hiển thị `CircularProgressIndicator`. Framework đang xoay màn hình ở dưới nền.
3. **Hide Loading**: Sau 2 giây, `_isLoading = false`, UI chuyển sang `GameUI` (đã ở đúng hướng).
4. **Pop `MockGameScreen`**: `OrientationGuard` bị dispose. Nó gọi `controller.restore(previousPolicy)`, màn hình tự động quay lại Portrait và Home được hiển thị bình thường.

## 4. Lợi ích của cách làm này
- Không cần quản lý vòng đời xoay màn hình rườm rà.
- Trạng thái màn hình (Loading vs Game) độc lập với tiến trình áp dụng định hướng, nhưng vẫn được bảo vệ (nếu xoay sai sẽ bị chặn bởi `mismatchBuilder`).
- Code rất giống với cách implement thực tế ở `GamePlayerScreen` hiện tại.

# Kế hoạch Đồng bộ hóa State Machine cho Game Player

## 1. Mục tiêu (Objective)
Rà soát và đồng bộ lại luồng thực thi (flow) của `GamePlayerNotifier` trong ứng dụng chính sao cho khớp với tính ổn định và tính rõ ràng (clean) của `MockGameNotifier` trong `orientation_guard/example`. Điều này giúp việc debug, test, và mở rộng dễ dàng hơn.

## 2. Các điểm khác biệt phát hiện (Findings)
1. **Sự giật lag khi vào game (Entry stutter)**: 
   - Trong ứng dụng thật, `GamePlayerNotifier` gọi lệnh xoay phần cứng (`orientationController.apply()`) **ngay lập tức** lúc bắt đầu `initializePlayer`.
   - Điều này xung đột với hiệu ứng chuyển trang (page transition) của Flutter (đang trượt/fade vào màn hình).
   - Trong `MockGameNotifier`, có một khoảng chờ `500ms` trước khi gọi lệnh xoay.
2. **Quy trình kết thúc (Exit Flow)**:
   - `MockGameNotifier` có quy trình: `exiting -> restore_orientation -> delay 500ms -> pop`.
   - Ứng dụng thật đang dùng: `exiting -> hide_webview -> restore_orientation -> delay 1000ms -> pop`.
   - Quy trình hiện tại của ứng dụng thật đã rất tốt và an toàn (do ẩn webview sớm), chỉ thiếu sự kết hợp trơn tru khi khởi tạo (entry).

## 3. Giải pháp (Solution Strategy)
Để đảm bảo trải nghiệm điện ảnh và dễ maintain, ta sẽ thêm khoảng chờ (delay) tương tự `MockGameNotifier` vào giai đoạn **Vào game (Entry)**. Khi kế hoạch này được duyệt, tôi sẽ tạo thêm một bản copy tài liệu này vào `lib/features/game/player/docs/game_player_state_machine_review.md` để lưu trữ lâu dài.

## 4. Cấu trúc Code Triển khai Dự kiến (Implementation Snippet)

Sửa đổi `initializePlayer` trong `lib/features/game/player/game_player_notifier.dart`:

```dart
  Future<void> initializePlayer({
    required OrientationController orientationController,
    required OrientationPolicy? previousPolicy,
    required OrientationPolicy gamePolicy,
    bool? isMobileLogin,
  }) async {
    if (_isInitCalled || _isDisposed) return;
    _isInitCalled = true;

    _orientationController = orientationController;
    _previousPolicy = previousPolicy;

    // 1. Setting up orientation
    _updateStage(GamePlayerStage.settingUp);

    // [THAY ĐỔI]: Thêm khoảng chờ 500ms giống MockGameNotifier.
    // Việc này cho phép hiệu ứng PageRouteBuilder hoàn thành trọn vẹn trước khi
    // thiết bị thực hiện thao tác xoay (rotation) tiêu tốn nhiều tài nguyên hệ thống.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_isDisposed) return;

    await orientationController.apply(gamePolicy);
    if (_isDisposed) return;

    // Proceed to load the game URL after orientation is locked (or failed)
    state = state.copyWith(isOrientationReady: true);

    // ... (Phần session guard và loadGameUrl giữ nguyên)
```
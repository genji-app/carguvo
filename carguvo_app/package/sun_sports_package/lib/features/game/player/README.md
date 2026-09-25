# Game Player Module

Tính năng **Game Player** (`lib/features/game/player`) chịu trách nhiệm vận hành WebView chơi game, đồng thời giải quyết các bài toán phức tạp về định hướng màn hình (Orientation), System UI, và giới hạn phần cứng trên các thiết bị như iPad.

## 1. Kiến trúc Lifecycle Chủ động (Active Lifecycle)

Chúng ta chuyển đổi từ cơ chế bị động sang cơ chế chủ động điều phối hướng màn hình và dữ liệu thông qua `GamePlayerNotifier`. Quy trình 5 bước đảm bảo iPad xoay mượt mà và không bị crash:

| Trạng thái | Hành động kỹ thuật | Ý nghĩa trải nghiệm |
|---|---|---|
| `settingUp` | `controller.apply(gamePolicy)` | Xoay thiết bị vật lý sang hướng yêu cầu. |
| `connecting` | `repository.getGameUrl(...)` | Hiện màn hình chào/loading trong lúc chờ API. |
| `loadingAssets`| Bàn giao cho WebView | Trình duyệt bắt đầu tải mã nguồn game. |
| `playing` | `onLoadStop` callback | Game sẵn sàng, ẩn overlay để người chơi bắt đầu. |
| `exiting` | `requestExit()` logic | Khóa UI, xoay về Portrait rồi mới gỡ màn hình. |

---

## 2. Cấu trúc thư mục (Refactored)

```text
game/player/
├── README.md                           ← Bạn đang đọc file này
├── docs/                               ← Hồ sơ kỹ thuật (Historical logs)
│   ├── orientation-issues.md           ← CHI TIẾT NHẤT: Cách iPadOS 16+ được xử lý
│   ├── game-player-issues.md           ← Các lỗi chung (Android/Web/iOS)
│   └── background-resume.md            ← Xử lý WebSocket khi resume app
├── game_player_screen.dart             ← UI chính (Sử dụng AnimatedSwitcher & PopScope)
├── game_player_notifier.dart           ← Bộ não điều khiển (Sync lifecycle & Orientation)
├── game_player_provider.dart           ← Riverpod providers
├── game_session_guard.dart             ← Chống spam mở game (Cooldown 3s)
├── player.dart                         ← Điểm export tập trung
├── widgets/                            ← Giao diện thành phần
│   ├── game_player_scaffold.dart       ← Layout thích ứng (Appbar/Sidebar)
│   ├── game_player_loading.dart        ← Màn hình chờ chuyên nghiệp
│   └── game_player_failure.dart        ← Xử lý lỗi & Retry
```

---

## 3. Các quy tắc "Vàng" khi phát triển

### Thoát Game an toàn (Smooth Exit)
Mọi lệnh đóng game (Nút Back, Gesture iPad, Lệnh từ Game) **KHÔNG ĐƯỢC** gọi `Navigator.pop` trực tiếp. 
- **Phải gọi**: `notifier.requestExit()`.
- **Lý do**: Để iPad có đủ thời gian xoay màn hình về Portrait mượt mà trước khi màn hình biến mất.

### Chống nháy giao diện (Flicker Protection)
Sử dụng thuộc tính `isApplying` từ `OrientationController`. 
- **Cơ chế**: Khi hệ thống đang thực hiện lệnh xoay, `OrientationGuard` sẽ tự động ẩn các cảnh báo "mismatch", giúp người dùng không thấy UI bị giựt.

### Safari iOS Memory Limit
Đối với các game nặng (Sexy, Vivo, và một số game bắn cá), Safari iOS sẽ crash iframe nếu dùng chung bộ nhớ với app.
- **Giải pháp**: Bật `openInNewTabOnIOSSafariWeb: true` trong cấu hình Game (hỗ trợ cả In-house và External). Hệ thống sẽ dùng `GamePlayerNewTabPlaceholder` để mở tab mới an toàn.

---

## 4. Tài liệu liên quan

- [Phân tích chuyên sâu về Orientation (iPad/Web)](docs/orientation-issues.md)
- [Hướng dẫn Debug & Issue Log](docs/game-player-issues.md)

---

## Tips cho Developers
- **Check Resolver**: Luôn dùng `GameOrientationResolver` để lấy chính sách xoay cho từng thiết bị.
- **Listen Events**: Luôn lắng nghe `events.listen((e) => navigator.pop())` trong `initState` của Screen.
- **Orientation Ready**: Chỉ render WebView khi `state.isOrientationReady` là `true` để tránh lỗi layout.

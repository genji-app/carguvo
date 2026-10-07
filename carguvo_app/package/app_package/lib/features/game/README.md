# S88 Game Feature - Technical Notes & Gotchas

Tài liệu này tổng hợp các quyết định kỹ thuật quan trọng, cấu hình đặc thù và các cách xử lý lỗi (workarounds) đã được áp dụng trong module `game`.

## 1. Quản lý Hướng Xoay Màn Hình (Orientation)
- **Cơ chế Active Lifecycle**: Thay vì đợi hệ thống xoay xong mới xử lý, module game sử dụng `GamePlayerNotifier` để chủ động điều khiển `OrientationController`. Trình tự: Xoay màn hình (`settingUp`) → Gọi API URL → Tải Game.
- **Phân tách theo thiết bị**: Sử dụng `OrientationExperienceClassifier` để tự động nhận diện thiết bị (Mobile, Tablet, Desktop) và áp dụng chính sách xoay phù hợp từ `GameBlock`.
- **GameOrientationResolver**: Một thành phần tập trung giúp chuyển đổi cấu hình định hướng từ database (`GameOrientation`) sang chính sách của package `orientation_guard`.
- **Quy trình Thoát mượt (Smooth Exit)**: Mọi hành động thoát đều qua `requestExit()`. iPad sẽ xoay về Portrait xong rồi mới thực sự đóng trang, tránh giựt layout.

## 2. Kiến trúc Engine (game_engine package)
- **IHRunner** (In-House): Dành cho game Cocos/Sandbox. Tích hợp sẵn Bridge để giao tiếp JSON Protocol.
- **PLRunner** (Platform/Provider): Dành cho game đối tác. Tối ưu cho iframe (Web) và InAppWebView (Mobile). Có tính năng `forceLandscapeViewport` dành riêng cho iPad để sửa lỗi game không nhận diện đúng chiều ngang.

## 3. Chặn mã HTML5 Fullscreen API
- **Vấn đề**: Game bên thứ 3 tự động gọi `requestFullscreen` làm mất Nút Back của app.
- **Giải pháp**: Inject mã JavaScript vào WebView để vô hiệu hóa các hàm Fullscreen DOM. Điều này buộc game phải chạy bên trong UI của App mà không chiếm quyền điều khiển hệ thống.

## 4. Quản lý Phiên Game (Game Session Guard)
- **Vấn đề**: Tránh lỗi **1028** (phiên cũ chưa đóng hẳn) khi người dùng mở game quá nhanh.
- **Giải pháp**: Tích hợp `GameSessionGuard` với cooldown **3 giây**. Logic này hiện được quản lý trực tiếp bên trong `GamePlayerNotifier` trong giai đoạn `settingUp`.

## 5. Tài liệu chi tiết

| Khu vực | Tài liệu |
|---|---|
| **Tổng quan Player** | [`lib/features/game/player/README.md`](player/README.md) |
| **Xử lý iPad/Web** | [`lib/features/game/player/docs/orientation-issues.md`](player/docs/orientation-issues.md) |
| **Lịch sử Issue** | [`lib/features/game/player/docs/game-player-issues.md`](player/docs/game-player-issues.md) |
| **Thiết kế Gói** | [`lib/features/game/docs/orientation-controller-package-design.md`](docs/orientation-controller-package-design.md) |

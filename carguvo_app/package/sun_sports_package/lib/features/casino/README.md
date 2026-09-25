# Casino Feature

Mô-đun này cung cấp giao diện và logic cho tính năng Casino (Sòng bạc) trong ứng dụng.

## 📁 Cấu trúc

- `casino_screen.dart`: Màn hình chính hợp nhất (Unified Screen) hỗ trợ đa thiết bị (Mobile, Tablet, Desktop).
- `casino_welcome_banner_section.dart`: Phần banner chào mừng với thiết kế thích ứng (adaptive layout).
- `casino.dart`: File export chính.

## 🚀 Tính năng nổi bật

### 1. Unified Interface (Hợp nhất giao diện)
Thay vì duy trì 3 file khác nhau cho Mobile, Tablet và Desktop, chúng tôi đã sử dụng `ResponsiveBuilder` để gộp tất cả vào một file `CasinoScreen.dart` duy nhất. Điều này giúp:
- Giảm thiểu lặp lại code.
- Dễ dàng bảo trì và cập nhật UI đồng bộ.
- Tận dụng `ConstrainedBox` và `Expanded` để card tự động co giãn theo màn hình.

### 2. Adaptive Layouts
Giao diện tự động thay đổi dựa trên loại thiết bị:
- **Mobile:** Sử dụng danh sách cuộn ngang cho các card khuyến mãi và game. Có thanh Live Chat dính (sticky) ở trên cùng cho người dùng đã đăng nhập.
- **Tablet/Desktop:** Sử dụng `Row` kết hợp `Expanded` để card chiếm tối đa không gian ngang. Layout được giới hạn chiều rộng để đảm bảo thẩm mỹ.

### 3. Modular Architecture
Các thành phần như `CasinoWelcomeBannerSection` được thiết kế độc lập. Card không tự quyết định kích thước của chính nó mà tuân theo "quy định" của layout cha, giúp tính tái sử dụng cực cao.

## 🛠️ Cách sử dụng

Để hiển thị màn hình Casino, chỉ cần gọi `CasinoScreen()`:

```dart
const CasinoScreen(
  showLiveChat: true, // Tùy chọn hiển thị Live Chat trên Mobile
  backgroundColor: AppColorStyles.backgroundSecondary,
)
```

Màn hình này sẽ tự động nhận diện thiết bị và render layout phù hợp.

# Phân Tích Feature Parlay (`lib/features/parlay`)

Feature `parlay` (còn gọi là Betting Slip hoặc Phiếu Cược) là một trong những feature quan trọng nhất của ứng dụng, chịu trách nhiệm quản lý các vé cược mà người dùng đã chọn, cho phép đặt cược Đơn (Single), cược Xiên (Combo/Parlay), và cược Nhiều (Multi).

Dưới đây là phân tích chi tiết về kiến trúc, luồng dữ liệu và các thành phần chính.

## 1. Kiến Trúc Tổng Quan (Architecture)

Feature này tuân theo kiến trúc Clean Architecture đơn giản hóa, kết hợp với Riverpod để quản lý trạng thái:

*   **Domain Layer**: Chứa các Models (`SingleBetData`) và Logic nghiệp vụ cốt lõi.
*   **Presentation Layer**:
    *   **State Management**: `ParlayStateProvider` (Logic trung tâm).
    *   **UI**: `ParlayMobileScreen`, `ParlayMatchCard`, và các widget con.
*   **Services Integration**: Tích hợp chặt chẽ với `WebSocketManager` (real-time odds/score) và `ParlayStorage` (lưu trữ local).

## 2. Các Thành Phần Chính (Key Components)

### 2.1. Domain Models
*   **`SingleBetData` (`domain/models/single_bet_data.dart`)**:
    *   Đây là model quan trọng nhất, đại diện cho một vé cược.
    *   **Dữ liệu**: Chứa thông tin Odds, Market, Event, League, Stake (tiền cược), và trạng thái (isCalculating, isDisabled).
    *   **Logic**:
        *   `potentialWinnings`: Tính tiền thắng dự kiến dựa trên `oddsStyle` (Decimal, Malay, Indo, HK).
        *   `displayName`, `selectionName`: Logic hiển thị tên kèo đa ngôn ngữ/định dạng.
        *   `cls`: Logic format điểm chấp (Handicap) cho API.

### 2.2. State Management (The Brain)
*   **`ParlayStateProvider` (`presentation/mobile/providers/parlay_state_provider.dart`)**:
    *   Sử dụng `StateNotifier` để quản lý `ParlayState`.
    *   **Core State**:
        *   `tab`: Tab hiện tại (Single, Combo, Multi).
        *   `singleBets`: Danh sách các vé cược đơn.
        *   `comboBets`: Danh sách các vé cược được chọn vào xiên.
        *   `stake`: Tiền cược chung cho xiên.
    *   **Chức năng chính**:
        *   **Quản lý danh sách**: Thêm/Sửa/Xóa vé cược.
        *   **Real-time Updates**: Lắng nghe WebSocket (`oddsUpdate`, `scoreUpdate`) để cập nhật tỷ lệ cược và tỷ số trận đấu ngay lập tức.
        *   **Odds Change Notification**: Phát hiện thay đổi odds và trigger thông báo/hiệu ứng blink trên UI.
        *   **Validation**: Kiểm tra điều kiện cược xiên (ví dụ: không được chọn 2 kèo cùng 1 trận vào xiên - `hasOtherSelectionInCombo`).
        *   **Persistence**: Tự động lưu/tải vé cược từ Local Storage (`ParlayStorage`) để giữ lại phiếu cược khi user thoát app.
        *   **API Integration**: Gọi `BettingRepository` để tính toán (calculate) và đặt cược (place bet).

### 2.3. Presentation (UI)
*   **`ParlayMobileScreen` (`presentation/mobile/screens/parlay_mobile_screen.dart`)**:
    *   Màn hình chính (thường là BottomSheet).
    *   Lắng nghe `isBettingReadyProvider` để đảm bảo hệ thống betting sẵng sàng (Token, WS connected) trước khi cho phép thao tác.
    *   Hiển thị Loading (Shimmer) hoặc Content dựa trên trạng thái.
    *   Xử lý hiển thị màn hình Success sau khi đặt cược thành công.

*   **`ParlayMatchCard` (`presentation/mobile/widgets/parlay_match_card.dart`)**:
    *   Hiển thị từng vé cược trong danh sách Single.
    *   **Input Tiền cược**: Cho phép nhập tiền, validate min/max stake.
    *   **Real-time FX**: Hiệu ứng nhấp nháy xanh/đỏ khi odds thay đổi (dùng `useAnimationController` và `OddsChangeDirection`).
    *   **Toggle Xiên**: Nút gạt để thêm/bớt kèo này vào Combos. Logic validate (chặn xung đột cùng trận đấu) được gọi từ đây.

## 3. Luồng Hoạt Động (Key Flows)

### 3.1. Thêm Vé Cược (Add Bet)
1.  User nhấn vào Odds trên màn hình danh sách trận.
2.  `BettingPopupData` được tạo ra và gửi tới `ParlayStateNotifier`.
3.  Provider chuyển đổi thành `SingleBetData`, thêm vào danh sách `singleBets`.
4.  Lưu vào Local Storage.
5.  Trigger API `calculate` để lấy Min/Max Stake.

### 3.2. Cược Xiên (Combo Betting)
1.  User bật toggle "Xiên" trên một vé cược đơn.
2.  **Validation**:
    *   Kiểm tra xem trận đấu này đã có kèo nào khác trong xiên chưa (`hasOtherSelectionInCombo`).
    *   Nếu chưa -> Thêm vào `comboBets`.
    *   Nếu có -> Báo lỗi Toast.
3.  Khi đủ số lượng kèo (minMatches), gọi API tính toán Odds tổng (`calculateComboParlay`).

### 3.3. Cập Nhật Real-time (WebSocket)
1.  `ParlayStateNotifier` lắng nghe stream từ `WebSocketManager`.
2.  Khi có message `oddsUpdate`:
    *   Tìm các vé cược khớp (`eventId`, `marketId`).
    *   Cập nhật `updatedOdds` trong Model.
    *   UI (`ParlayMatchCard`) phát hiện thay đổi -> Chạy hiệu ứng nhấp nháy (Xanh/Đỏ).
3.  Khi có message `scoreUpdate`:
    *   Cập nhật điểm số hiển thị trên vé cược (quan trọng cho kèo Live).

### 3.4. Đặt Cược (Place Bet)
1.  User nhấn "Đặt cược".
2.  `ParlayMobileScreen` gọi `placeAllSingleBetsParallel` (cho Single) hoặc `placeComboParlay` (cho Xiên).
3.  Provider gọi API thông qua Repository.
4.  Thành công -> Hiển thị `BetSuccessView` và xóa các vé đã xong.
5.  Thất bại -> Giữ lại vé và hiện lỗi.

## 4. Điểm Nổi Bật (Highlights)
*   **Robust State Sync**: Đồng bộ trạng thái giữa Local Storage, Memory State và Server State (thông qua API/WS) rất chặt chẽ.
*   **User Experience**: Chú trọng trải nghiệm (giữ lại phiếu cược khi tắt app, báo hiệu odds thay đổi rõ ràng, validate logic xiên ngay tại UI).
*   **Clean Separation**: Tách biệt rõ ràng logic tính toán (Provider/Model) và giao diện (Widget).

# Tài liệu Đặc tả Tính năng: Betting History & Resell

## 1. Giới thiệu chung
Module Betting quản lý toàn bộ vòng đời của một vé cược sau khi đã đặt thành công, bao gồm:
*   Theo dõi trạng thái vé (Đang chạy, Chờ duyệt, Thắng, Thua).
*   Hiển thị chi tiết vé cược đơn và cược xiên (Parlay).
*   Tính năng xả kèo (Resell/Cashout) để thu hồi một phần tiền cược.

---

## 2. Cấu trúc thư mục (Architecture)
Module được tổ chức theo mô hình Layered Architecture kết hợp với Provider Pattern (Riverpod):

```text
lib/features/betting/
├── data/
│   ├── models/            # Định nghĩa các đối tượng dữ liệu (BetSlip, ChildBet, CashoutInfo)
│   ├── parsers/           # Chuyển đổi JSON từ nhiều nguồn API khác nhau (BetSlipParser)
│   └── repositories/      # Giao tiếp với API và quản lý dữ liệu thô
├── history/               # Các Widget và Logic hiển thị danh sách/chi tiết lịch sử
│   ├── betting_history_view.dart    # Màn hình danh sách chính
│   ├── betting_history_notifier.dart# Quản lý trạng thái danh sách (Filter, Refresh)
│   ├── detail/            # Chi tiết vé cược
│   └── betting_history_card/# Các component item (Card trận đấu, cược xiên)
├── my_bet/                # [NEW] Tính năng My Bets Overlay (Side Panel)
│   ├── my_bet_overlay/    # Widget hiển thị dạng drawer bên phải màn hình Desktop
│   ├── my_bet_presenter/  # Logic hiển thị danh sách vé nhanh
│   └── my_bet_providers.dart # Quản lý state riêng biệt cho overlay
└── resell/                # Logic và Giao diện xả kèo
    ├── bet_resell_notifier.dart  # Logic xử lý lấy giá và thực hiện xả kèo
    ├── bet_resell_controller.dart# Điều khiển luồng UI (Dialog xả kèo)
    └── bet_slip_cashout_dialog.dart# Giao diện xác nhận xả kèo
```

---

## 3. Luồng dữ liệu và Xử lý (Data & UI Flow)

### 3.1. Luồng lấy dữ liệu (Hybrid API Strategy)
Hệ thống sử dụng chiến lược kết hợp hai loại API để tối ưu hóa thông tin:
*   **Active Bets (Vé đang chạy/chờ):** Sử dụng `getBetSlipByStatus`. API này cung cấp trường `cashOutAbleAmount` cần thiết để kiểm tra tính khả dụng của việc xả kèo.
*   **Settled Bets (Vé đã kết toán):** Sử dụng `betsReporting`. API này sử dụng định dạng khóa số (numeric keys), cung cấp thông tin chuyên sâu về `cashoutHistory`.

### 3.2. Bộ phân tích dữ liệu (Parsing Logic)
*   **Standard Parser:** Dùng `BetSlip.fromJson` cho các trường dữ liệu chuẩn.
*   **Numeric Parser (`BetSlipParser`):** Đặc trị cho API báo cáo/xả kèo với các khóa số:
    *   `2`: ticketId
    *   `20`: Tóm tắt cược (stake, winning, odds)
    *   `21`: Chi tiết các trận con (child bets)
*   **Score Formatting:** Chuyển đổi từ `0:0` (server) sang `[0-0]` (display) và hiển thị tỷ số hiệp 1 (HT).

### 3.3. Cơ chế cập nhật Re-active
*   **Repository Stream:** `onTicketCashoutSuccess` phát đi sự kiện khi xả kèo thành công.
*   **Global Listeners:** Danh sách và Chi tiết tự động cập nhật trạng thái mà không cần reload trang.

---

## 4. Chi tiết Kỹ thuật Xả kèo (Cashout Technical Specs)

Hệ thống triển khai theo mô hình **CQRS (Command Query Responsibility Segregation)**:

### 4.1. Truy vấn giá (getCashout - Query)
*   **Endpoint:** `POST /get-cash-out?sportId=1`
*   **Mục đích:** Kiểm tra tính khả dụng và lấy số tiền có thể nhận được hiện tại.
*   **Request Payload:**
    ```json
    {
      "amount": 47500,
      "displayOdds": "0.66",
      "stake": 50000,
      "ticketId": "542273190",
      "token": "...",
      "userId": ""
    }
    ```
*   **Mapping Numeric Keys (Response):**
    | Key | Field Name | Ý nghĩa |
    |-----|------------|---------|
    | "0" | ticketId | ID vé cược |
    | "1" | isAvailable| Có thể xả hay không |
    | "3" | amount | Số tiền nhận được |
    | "4" | odds | Tỷ lệ hiện tại |
    | "5" | fee | Phí điều chỉnh |

### 4.2. Thực hiện xả kèo (performCashout - Command)
*   **Endpoint:** `POST /cash-out?sportId=1`
*   **Mục đích:** Chốt giao dịch và cập nhật trạng thái vé cược.
*   **Request Payload:** Tương tự `getCashout`.
*   **Xử lý lỗi:** Phương thức này sẽ `throw exception` nếu server trả về lỗi hoặc response rỗng, giúp tầng UI bắt được lỗi chính xác.

---

## 5. Trạng thái và Thành tựu

### ✅ Những gì đã làm được:
*   **Hoàn thiện Model System:** Chuyển đổi toàn bộ monetary fields (`stake`, `winning`, `amount`) sang kiểu `num` để tránh lỗi làm tròn/tràn số.
*   **Dynamic UI Flow:** `BetResellController` quản lý toàn bộ logic: Lấy giá mới -> Hiện Dialog -> Thực thi -> Thông báo thành công.
*   **HT Score Integration:** Hiển thị tỷ số HT trong cả danh sách và chi tiết.

### 📈 Đề xuất cải thiện (Next Steps):
1.  **WebSocket Sync:** Tự động update giá xả kèo (Cashout Amount) mỗi khi tỷ số trận đấu thay đổi trên sân.
2.  **Optimistic UI:** Cộng tiền vào số dư hiển thị ngay lập tức khi API Cashout trả về thành công.
3.  **Local History:** Lưu trữ 50 vé gần nhất vào bộ nhớ máy để hiển thị tức thì khi người dùng mở lại App.

---
*Tài liệu này là nguồn sự thật duy nhất (Single Source of Truth) cho Module Betting.*

---

## 7. Các quyết định kỹ thuật quan trọng (Technical Choices)
*   **Abolish Pagination:** Quyết định dừng phân trang và loại bỏ cấu trúc `PagedResult` vì API trả về dữ liệu gộp. Các phương thức repository hiện trả về trực tiếp `List<BetSlip>`.
*   **Extension Methods:** Sử dụng `BetSlipX` để tách rời logic hiển thị (như format tiền tệ, tỷ số) khỏi data model gốc, giúp code sạch và dễ test.
*   **Provider Lifecycle:** `betResellProvider` không sử dụng `.autoDispose` để đảm bảo StateNotifier tồn tại qua các bước chuyển đổi UI (như đóng/mở Dialog), tránh lỗi "Bad Executing State".

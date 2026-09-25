# 00 — Tổng quan game Kim Cương (Diamond / Trứng Phục Sinh)

> Tài liệu này phân tích **source gốc TypeScript (Cocos Creator)** trong folder `KimCuong/` để bạn hiểu cách game hoạt động trước khi port sang Flutter (`lib/mini/diamond`).

## 1. Kim Cương là game gì?

Kim Cương là một **game slot machine (máy quay hũ)** thuộc nhóm mini-game của SUN88, cùng nhóm với **MiniPoker** và **DragonBall**. Cả 3 game này dùng **chung một cơ chế mạng** (chỉ khác `gid`).

- **Game ID:** `202` (`GAME_ID.MINI_S_DIAMOND`)
- **Tên nội bộ:** `trungphucsinh` = "Trứng Phục Sinh" (easter egg) → thumbnail dùng ảnh `mng_trungphucsinh.png`
- **Loại:** Slot 3×3 (3 cột × 3 hàng), có payline, jackpot và "nổ hũ"
- **Nhóm game:** slot spin-based (không có timer phiên như Tài Xỉu — mỗi lần quay là 1 phiên độc lập)

### Ý tưởng chơi (rất ngắn gọn)
Người chơi chọn **mức cược (chip)** và **số dòng (payline)** muốn ăn, bấm **QUAY (spin)**. 3 cột biểu tượng quay rồi dừng lại tạo ma trận 3×3. Server tính các dòng trúng thưởng và trả về tiền thắng. Nếu trúng tổ hợp jackpot → **nổ hũ** với hiệu ứng riêng.

## 2. Giá trị business (WHY)

| Khía cạnh | Mô tả |
|---|---|
| Doanh thu | Mỗi lần spin là 1 giao dịch cược. Tổng cược = `bet × số dòng`. House edge nằm ở server (payout table + tỉ lệ nổ hũ). |
| Giữ chân người chơi (retention) | Auto-spin + Fast-spin giúp chơi liên tục; jackpot lũy tiến tạo động lực quay tiếp. |
| Cảm xúc (engagement) | Hiệu ứng nổ hũ hoành tráng (skeleton animation `diamond_start`/`diamond_loop`, BGM riêng, glow, số tiền chạy) tạo khoảnh khắc "win big". |
| Social proof | Bảng xếp hạng (BXH) người thắng lớn + lịch sử cược minh bạch tạo niềm tin. |
| Cross-sell | Nằm trong radial menu mini-game chung → điều hướng người chơi giữa các game. |

## 3. Bản đồ file/class (source gốc)

```
KimCuong/
├── KimCuongGameView.ts            ← MÀN HÌNH CHÍNH (điều phối tất cả)
├── KimCuongLineSelectionView.ts   ← Popup chọn dòng (chẵn/lẻ/tất cả/tùy chọn)
├── KimCuongNoHuView.ts            ← Hiệu ứng "nổ hũ" (jackpot)
├── KimCuongBetHistoryView.ts      ← Lịch sử cược (phân trang, HTTP)
│   ├── KimCuongBetHistoryItemView.ts   ← 1 dòng trong danh sách lịch sử
│   └── KimCuongBetHistoryDetail.ts     ← Chi tiết 1 phiên (vẽ lại ma trận + line trúng)
├── KimCuongBetRankView.ts         ← Bảng xếp hạng (phân trang, HTTP)
│   └── KimCuongBetRankItemView.ts      ← 1 dòng trong BXH
├── KimCuongHelpView.ts            ← Popup trợ giúp (rỗng, chỉ kế thừa CommonPopup)
└── SlotMachineCmp/                ← CƠ CHẾ MÁY QUAY
    ├── KimCuong_SlotMachineCmp.ts       ← Quản lý 3 cột + vẽ payline
    ├── KimCuong_SlotMachineColumn.ts    ← 1 cột: logic quay/dừng/nảy
    └── KimCuong_SlotMachineItemView.ts  ← 1 ô biểu tượng (sprite normal/blur)
```

### Quan hệ chính
- `KimCuongGameView` là **nhạc trưởng**: nhận input, gửi request spin, nhận kết quả từ `KimCuongMessageHandler`, ra lệnh cho máy quay dừng, hiển thị kết quả/nổ hũ.
- `KimCuong_SlotMachineCmp` quản lý **3 cột** (`KimCuong_SlotMachineColumn`), mỗi cột chứa nhiều **ô** (`KimCuong_SlotMachineItemView`).
- Các popup (LineSelection, NoHu, BetHistory, BetRank) là các view con được `GameView` gọi khi cần.

## 4. Các tính năng chính (mỗi cái có 1 file docs riêng)

| # | Tính năng | File docs |
|---|---|---|
| 01 | Luồng chơi & vòng đời 1 lần quay | `01_GAME_FLOW.md` |
| 02 | Máy quay: cột, ô, animation, symbol encoding | `02_SLOT_MACHINE.md` |
| 03 | Payline (20 dòng) & bộ chọn dòng | `03_PAYLINES.md` |
| 04 | Cược & chip | `04_BETTING.md` |
| 05 | Giao thức mạng (request/response) | `05_NETWORK_PROTOCOL.md` |
| 06 | Jackpot & Nổ hũ | `06_JACKPOT_NOHU.md` |
| 07 | Lịch sử cược & Bảng xếp hạng | `07_HISTORY_RANK.md` |
| 08 | Auto/Fast spin, âm thanh & quy tắc business | `08_AUTOSPIN_BUSINESS.md` |

## 5. Khung UI trên màn hình chính

Các thành phần `@property` trong `KimCuongGameView`:
- **Jackpot label** (`lblJackpot`) — số hũ hiện tại, chạy số khi cập nhật.
- **3 nút chip** (`btn_chips`) — mức cược `[100, 1000, 10000]`.
- **Nút QUAY** (`btn_spin`), **nút chọn dòng** (`btn_line`) + label số dòng (`line_num_text`).
- **Toggle Auto** (`tog_auto`) và **Toggle Fast** (`tog_fast`).
- **Máy quay** (`kimCuong_SlotMachineCmp`).
- **Khối kết quả** (`result_node` + `lbl_result_amount`) — hiện `+tiền thắng`.
- **Nút BXH** (`btn_rank`), **nút Lịch sử** (`btn_bet_history`), **nút Trợ giúp** (`btn_help`).
- Các popup: `kimCuongNoHuView`, `kimCuongLineSelectionView`, `kimCuongBetHistoryView`, `kimCuongBetRankView`.

## 6. Lưu ý khi port sang Flutter
- Trong dự án Flutter, 3 slot game (MiniPoker/KimCuong/DragonBall) đã được gộp message vào `lib/features/mini_game/messages/slot_message.dart` (phân biệt bằng `gid`). Xem `05_NETWORK_PROTOCOL.md`.
- Thumbnail & enum đã có sẵn: `MiniGameSelection.kimCuong`, `SlotGameId.kimCuong(202)`.
- Toàn bộ hiệu ứng dùng Cocos `tween`/`sp.Skeleton` — khi port cần map sang `AnimationController` / Spine Flutter tương ứng.

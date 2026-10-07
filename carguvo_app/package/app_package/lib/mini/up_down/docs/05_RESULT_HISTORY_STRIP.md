# Tính năng: Dải lịch sử lá trong ván (Result History Strip)

**Nguồn:** `TrenDuoiResultItem.ts` + `TrenDuoiGameView.ts`
(`updateResultPanel`, `hideResultPanel`, `mVecResult`).

---

## 1. Mục đích

Dải ngang hiển thị **các lá đã lật trong ván hiện tại** (hạng + chất), mới nhất
bên phải. Tương ứng `_CardHistoryBar` đã dựng ở Flutter.

---

## 2. `TrenDuoiResultItem` — một ô lá

`show(code)`:
```ts
let S = floor(code % 4) + 1;   // chất 1..4
let N = floor(code / 4) + 1;   // hạng
if (N == 15) N = 2;
// tên hạng:
//   11→"J", 12→"Q", 13→"K", 14 hoặc 1→"A", còn lại N.toString()
// chất → sprite:
//   S==1 ct_bich (bích) | S==2 ct_tep (tép) | S==3 ct_ro (rô) | S==4 ct_co (cơ)
```
- Set `text = tên hạng`, `icon = sprite chất` (từ `loaded_ico_result`).
- `hide()`: ẩn ô.

> Lưu ý: ở đây **A hiển thị là "A"** (rank 1/14). Chất 3 (rô) & 4 (cơ) là đỏ.

---

## 3. `updateResultPanel()` — cập nhật dải

- Nguồn: `mVecResult` (mảng mã lá đã lật, push mỗi `onUpdateResult`).
- Nếu số lá > số ô có sẵn (`result_items.length`) → chỉ lấy phần **đuôi** (các lá
  gần nhất) bằng `slice`.
- Hiện từng ô `result_items[i].show(arr[i])`.
- **Tự tạo thêm ô** (`instantiate(result_items_template)`) khi cần (panel co giãn
  theo số lá): khi `i >= (len-1)/2` thì thêm ô mới ẩn vào content.
- Set `contentSize.width = mVecResult.length × itemWidth`, rồi
  `resultScrollView.scrollToRight(0.1)` → **cuộn sang phải** (mới nhất hiện ra).
- `hideResultPanel()`: ẩn mọi ô (gọi khi reset/thua/rút).

---

## 4. Khi nào cập nhật

- Mỗi lần `onUpdateResult(result)` → `mVecResult.push(result)` →
  `updateResultPanel()`.
- Khôi phục phiên (`resInfoGame`): replay `items[]` → mỗi lá gọi `onUpdateResult`
  → dải dựng lại đầy đủ.
- `resetAll()` / `onGameOver` / `resStopGame` → `hideResultPanel()`.

---

## 5. Gợi ý áp dụng Flutter

- Đã có `_CardHistoryBar` (căn phải, cắt trái bằng `OverflowBox`+`ClipRect`).
  Thay data demo bằng `state.history` (mảng `cardCode`).
- Map mỗi `cardCode` → `(rankLabel, suit)` bằng helper ở `02_CARD_ENCODING_RULES`.
- Cuộn sang phải khi thêm lá: nếu dùng `SingleChildScrollView(reverse:true)` thì
  tự ghim bên phải; hoặc `OverflowBox` căn phải như hiện tại.
- Chất đỏ (rô/cơ) giữ màu đỏ `#EC0000`; bích/tép tô sáng `#C3C2BC` (vì asset gốc
  màu tối) — như `_CardChip` đang làm.
- Giới hạn hiển thị: bản gốc co giãn theo số lá; Flutter có thể giữ toàn bộ và
  cuộn/cắt.

# Tính năng: Chọn mức cược (Bet Chips)

**Nguồn:** `TrenDuoiGameView.ts` — `btn_chips`, `chip_values`, `highlightBet`,
`bet`, `mLblMidPrice`.

---

## 1. Mục đích

Cho người chơi chọn **mức cược** trước khi bắt đầu ván. Mức cược cũng quyết định
**hũ jackpot** nào được hiển thị (xem `08`).

---

## 2. Dữ liệu

```ts
chip_values = [1000, 10000, 50000, 100000, 500000];  // 1K · 10K · 50K · 100K · 500K
bet = chip_values[0];   // mặc định 1.000
```

---

## 3. Logic bấm chip

```ts
chip.node.on("click", () => {
  if (!trenduoi_SlotMachineCmp.isStopped()) {        // đang quay
    NotiView.showMessage(lb_round_undone);           // "Ván chơi chưa kết thúc!"
    return;
  }
  highlightBet(ind);                                 // tick chọn chip ind
  this.bet = chip_values[ind];
  this.mLblMidPrice.string = formatNumber(this.bet); // hiện mức cược ở giữa (lúc IDLE)
  this.updateJackpotLabels(false);                   // đổi hũ theo mức cược mới
});
```

- **Chặn đổi chip khi đang quay** (slot machine chưa dừng) → báo toast.
- `highlightBet(ind)`: bật dấu tick (`chip.node.children[1].active = index==ind`)
  trên chip được chọn, tắt các chip khác.

---

## 4. `mLblMidPrice` đổi nghĩa theo trạng thái

| Trạng thái | `mLblMidPrice` hiển thị |
|------------|-------------------------|
| IDLE (chưa chơi) | **mức cược** (`bet`) |
| PLAYING (đang chơi) | **credit** (tiền đang giữ, từ `crd`) → nút Rút tiền |

→ Cần phân biệt: ở UI Flutter, cột mức cược (1K…500K) là phần chọn cược; còn nút
"Rút tiền" hiển thị credit khi đang chơi.

---

## 5. Liên hệ jackpot

Mỗi lần đổi chip → `updateJackpotLabels(false)` → label hũ nhảy sang hũ ứng với
`(aid=1, bet=mức cược mới)`. Tức **mỗi mức cược có một hũ riêng** (xem `08`).

---

## 6. Gợi ý áp dụng Flutter

- Đã có `_UnitColumn` (5 chip 1K…500K, chọn 1). Thêm:
  - State `selectedBet`; tap → set + cập nhật jackpot label hiển thị.
  - **Chặn đổi chip khi `busy`/đang quay** → toast `lb_round_undone`.
  - Chỉ cho đổi chip ở phase IDLE (trước khi Play). Bản gốc chặn khi đang quay;
    có thể cho đổi giữa các lượt nếu server cho phép — cần xác nhận.
- `chip_values` cố định `[1000,10000,50000,100000,500000]`.
- Khi gửi START_GAME/START_ROUND: `b = selectedBet`.

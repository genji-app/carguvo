# Tính năng: Đa ngôn ngữ (Localization)

**Nguồn:** `UpDownText.ts` + cách dùng trong `TrenDuoiGameView`,
`*ItemView`.

---

## 1. Mục đích

Chuỗi hiển thị riêng của Trên Dưới theo 3 ngôn ngữ: **en / th / vi**.

---

## 2. Bảng chuỗi

| Key | vi | en | Dùng ở đâu |
|-----|----|----|-----------|
| `lb_btn_new_game` | "Lượt\nmới" | "New\nGame" | Nhãn nút Rút tiền / Lượt mới |
| `lb_hint_play` | "Nhấn Play để bắt đầu" | "Press Play to start" | Status lúc IDLE |
| `lb_hint_win` | "Bạn thắng {money} sau {count} lần lật bài!" | "You win {money} after {count} flips!" | Status khi rút tiền |
| `lb_hint_lose` | "Bạn đã thua!" | "You lose!" | Status khi thua |
| `lb_up` | "Up" | "Up" | Lựa chọn (lịch sử) |
| `lb_down` | "Down" | "Down" | Lựa chọn (lịch sử) |
| `lb_big_win` | "Big Win" | "Big Win" | Loại thắng (xếp hạng) |
| `lb_jackpot` | "Jackpot" | "Jackpot" | Loại thắng (nổ hũ) |
| `lb_round_undone` | "Ván chơi chưa kết thúc!" | "This round has not ended yet!" | Toast khi đổi chip lúc đang quay |
| `lb_history_selection` / `lb_history_step` / `lb_history_step_win` | "Selection" / "Win" / "Total Win" | (như vi) | Tiêu đề cột lịch sử |

> `{money}` và `{count}` là placeholder thay bằng số tiền thắng và số lần lật
> (`mVecResult.length`).

---

## 3. Cách dùng

```ts
UpDownText[GameManager.getInstance().curLanguage].lb_hint_play
// thay placeholder:
lb_hint_win.replace("{money}", moneyStr).replace("{count}", count.toString())
```
- Một số nhãn dùng chung từ `CommonText` (vd `lb_common_play` cho nút Play, các
  tiêu đề cột lịch sử/xếp hạng).

---

## 4. Gợi ý áp dụng Flutter

- Đưa các chuỗi này vào hệ i18n của app (arb/intl hoặc map theo locale).
- Chuỗi có placeholder → dùng hàm format: `winHint(money, count)`.
- Lưu ý `lb_btn_new_game` có **xuống dòng** (`\n`).
- Các nhãn dùng chung (Play, tiêu đề cột) lấy từ hệ CommonText sẵn có của app —
  không cần định nghĩa lại.

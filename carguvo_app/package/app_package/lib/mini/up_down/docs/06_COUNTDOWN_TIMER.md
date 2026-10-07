# Tính năng: Đồng hồ đếm ngược (Countdown Timer)

**Nguồn:** `TrenDuoiGameView.ts` — `mLblTimer`, `updateTimer`, `startTimer`,
`stopTimer`, `mTimeToCountDown`, `mTimeEndCountDown`.

---

## 1. Mục đích

Đếm ngược thời gian cho mỗi **quyết định/lượt** (đoán Trên/Dưới). Hiển thị dạng
`mm:ss`, mặc định `02:00`.

---

## 2. Biến

| Biến | Ý nghĩa |
|------|---------|
| `mTimeToCountDown` | Số giây còn lại (mặc định **120**) |
| `mTimeEndCountDown` | Mốc kết thúc (timestamp ms). `-1` = không chạy |
| `mLblTimer` | Label hiển thị |

---

## 3. Logic

**`updateTimer()`** — format `mm:ss` từ `mTimeToCountDown` (pad 0):
```ts
minutes = floor(t/60); seconds = floor(t%60);  // "02:00"
```

**`startTimer()`** — chạy đồng hồ:
- Lặp vô hạn mỗi **1.0 giây**:
  - nếu `mTimeEndCountDown != -1`:
    `mTimeToCountDown = floor((mTimeEndCountDown - Date.now())/1000)` → `updateTimer()`.
  - ngược lại: dừng tween.
- Tức là đếm ngược theo **thời gian thực** (so với mốc kết thúc), không đếm thủ
  công từng giây (tránh lệch).

**`stopTimer()`** — reset:
- Dừng tween; `mTimeToCountDown = 120`; `mTimeEndCountDown = Date.now() + 120s`;
  `updateTimer()` → hiện lại `02:00`.

---

## 4. Khi nào gọi

| Sự kiện | Gọi |
|---------|-----|
| `spin()` (bấm Play/Trên/Dưới) | `stopTimer()` (dừng + reset 02:00) |
| `onUpdateResult` (có kết quả, chưa thua) | `startTimer()` (chạy lại 120s cho lượt mới) |
| `resStartNewRound` | `stopTimer()` trước, rồi `onUpdateResult`→`startTimer()` |
| `onGameOver` / `resStopGame` / `resetAll` | `stopTimer()` |
| `resInfoGame` (khôi phục phiên) | `mTimeEndCountDown = now + rmT(ms)`; `mTimeToCountDown = rmT/1000`; `startTimer()` |

→ Mỗi lượt mới reset **120 giây**. Khi khôi phục phiên đang chạy thì dùng đúng
`rmT` còn lại của server.

---

## 5. Gợi ý áp dụng Flutter

- Lưu `deadline = DateTime.now().add(remaining)` (mốc kết thúc), `Timer.periodic(1s)`
  tính `remaining = deadline - now`, format `mm:ss`. Không đếm thủ công.
- Mặc định 120s mỗi lượt; khôi phục phiên dùng `rmT` (ms) từ INFO_GAME.
- Hết giờ (`remaining <= 0`): bản gốc không xử lý rõ phía client (server tự quyết)
  → nên **khoá nút** Trên/Dưới và chờ message; hoặc theo quy ước server.
- Hủy timer khi dispose / đóng game.
- Nối vào `_CountdownPill` (đang hiện `02:00` tĩnh).

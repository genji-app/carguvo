# 06 — Jackpot & Nổ hũ

> Nguồn: `KimCuongGameView.ts` (`updateJackpot`, `updateJackpotLabels`), `KimCuongNoHuView.ts`

## 1. Jackpot (hũ) là gì?

- Là **hũ lũy tiến (progressive)**: một phần cược của người chơi tích vào hũ, tăng dần theo thời gian.
- Mỗi cặp **(aid, bet)** có một hũ riêng. Nghĩa là cùng 1 pool `aid` nhưng mỗi mức chip (100/1.000/10.000) có số hũ khác nhau.
- Số hũ hiển thị trên `lblJackpot`, chạy số mượt (tween 0.5s) khi cập nhật.

## 2. Luồng dữ liệu hũ

```
Vào game / đổi chip
   └─ sendSubscribeMiniGame(MINI, 202)
         └─ server trả cmd 1300 (SUBSCRIBE_JACKPOT) → updateJackpot(jars, isSubscribe=true)
               ├─ dựng lại _jackpotInfos
               └─ SẮP XẾP: aid=1 trước, aid=2 sau; trong mỗi nhóm, bet tăng dần
Trong lúc chơi
   └─ server push cmd 1304 (UPDATE_JACKPOT) → updateJackpot(jars, isSubscribe=false)
         └─ tìm entry khớp (aid, bet) → cập nhật J
Cuối cùng
   └─ updateJackpotLabels(withFx): chỉ hiện hũ khớp (_aid, bet đang chọn)
```

### Chi tiết `updateJackpotLabels(withFx)`
- Duyệt `_jackpotInfos`, tìm entry có `aid == _aid && bet == this.bet`.
- Nếu `withFx=false`: gán thẳng số.
- Nếu `withFx=true`: tween `jackpot_amount → giá trị mới` trong 0.5s, cập nhật label từng frame bằng `StringUtils.formatNumber(Math.floor(current))`.

> Vì hũ đổi theo chip, **mỗi lần đổi chip phải subscribe lại** để lấy đúng hũ (xem `04_BETTING.md`).

## 3. Trúng jackpot — cách nhận biết

Trong `receiveData`:
```ts
this.wonJackpot = this.rewards.filter(rew => rew["iJ"] == true).length > 0;
```
Tức là chỉ cần **một dòng trúng có cờ `iJ == true`** → coi như nổ hũ.

Khi `showResult` chạy, nếu `wonJackpot` → chạy `showNoHuEffect` thay vì kết quả thường:
```ts
this.kimCuongNoHuView.showJackpot(this.moneyExchange);
```

## 4. Hiệu ứng Nổ Hũ — `KimCuongNoHuView`

Có 2 hàm hiển thị:

### a) `showJackpot(win_amount, timeScale=1)` — dùng cho Kim Cương
- Phát **BGM riêng** `nohu_bgm`.
- Bật màn đen (`black_screen`) + root.
- Chạy **skeleton animation**:
  - `diamond_start` (chơi 1 lần) → khi xong tự chuyển `diamond_loop` (lặp).
- Số tiền thắng chạy từ 0 → `win_amount` trong **2 giây** (`StringUtils.formatNumber(floor(current))`).

### b) `show(win_amount)` — biến thể hiệu ứng đầy đủ (money bg + glow + finishFx)
- `finishFx`: scale từ 3→1 (delay 0.4s).
- `noHuMoneyBg`: trượt từ `y=-485` lên `y=-260` (delay 0.6s).
- `glow` (BlinkCmp) nhấp nháy.
- Số tiền chạy 0 → `win_amount` trong 2 giây.

### Đóng hiệu ứng — `hide()`
- Cho phép bấm đóng chỉ khi `activated_click = true`.
- `finishFx` scale 3 + fade, sau đó phát lại nhạc nền lobby (`GAME_EVENT.LOBBY.PLAY_BG_MUSIC`).
- `noHuMoneyBg` trượt về `y=-485`.

## 5. Thời điểm cho phép đóng nổ hũ

Trong `showResult` (GameView):
- Nếu **Auto bật**: tự động ẩn nổ hũ sau **14.5s** (`kimCuongNoHuView.hide()`).
- Nếu **không Auto**: sau **2.5s** cho phép người chơi bấm đóng (`activeClick()`).

Điều này đảm bảo người chơi kịp "chiêm ngưỡng" khoảnh khắc thắng lớn, đồng thời auto-spin không bị kẹt.

## 6. Ý nghĩa business
- Jackpot lũy tiến là **động lực retention mạnh**: người chơi thấy hũ càng lớn càng muốn quay tiếp.
- Hiệu ứng nổ hũ hoành tráng (animation + BGM + số tiền chạy) tạo **cảm xúc đỉnh cao** — yếu tố cốt lõi giữ chân người chơi slot.
- Nhiều hũ theo mức cược khuyến khích người chơi **nâng chip** để "săn" hũ lớn hơn.

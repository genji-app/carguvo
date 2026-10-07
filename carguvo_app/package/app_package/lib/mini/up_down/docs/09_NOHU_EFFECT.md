# Tính năng: Hiệu ứng Nổ Hũ (Jackpot Win — NoHu)

**Nguồn:** `TrenDuoiNoHuView.ts` + điểm gọi trong `TrenDuoiGameView.onUpdateResult`.

---

## 1. Mục đích

Hiệu ứng **toàn màn hình** khi người chơi **trúng jackpot**: nền đen, bảng tiền
trượt lên, hào quang nhấp nháy, đếm số tiền thắng, nhạc nền riêng.

---

## 2. Khi nào kích hoạt

Trong `onUpdateResult(result, jackpot)` (sau khi lật lá, khi **chưa** thua):
```ts
if (this.mIsWinJackpot && jackpot > 0) {
  tween(noHuView.node).sequence(
    tween().call(() => trenDuoiNoHuView.show(jackpot)),
    tween().sequence(
      tween().delay(2.5),
      tween().call(() => { this.mIsWinJackpot = false; trenDuoiNoHuView.activeClick(); })
    )
  ).start();
}
```
- `mIsWinJackpot` = `iJ` từ `resStartNewRound`; `jackpot` = `J`.
- Hiện effect → **sau 2.5s** mới cho phép bấm tắt (`activeClick`).

---

## 3. `TrenDuoiNoHuView`

**Thành phần:** `root`, `black_screen` (nền đen click để tắt), `noHuMoneyBg`
(bảng tiền), `glow` (BlinkCmp nhấp nháy), `finishFx`, `nohu_win_amount` (label
số tiền), `nohu_bgm`.

**`show(win_amount)`:**
1. Phát `nohu_bgm`; bật `root` + `black_screen`; `activated_click=false`.
2. `finishFx`: ẩn → sau 0.4s hiện, scale từ 3→1 trong 0.3s.
3. `noHuMoneyBg`: đặt y=-485 → sau 0.6s trượt tới y=-260 trong 0.3s.
4. `glow.run()` (nhấp nháy).
5. **Đếm số tiền** từ 0 → `win_amount` trong **2 giây** (tween progress, format
   number), kết thúc set đúng giá trị.

**`activeClick()`:** bật `black_screen` + `activated_click=true` → cho phép click
nền để tắt.

**`hide()`:** ẩn nền, `glow.stop()`, `finishFx` scale 1→3 + ẩn, `noHuMoneyBg`
trượt về y=-485, **phát lại BGM lobby** (`GAME_EVENT.LOBBY.PLAY_BG_MUSIC`).

---

## 4. Gợi ý áp dụng Flutter

- Dựng 1 overlay full-screen (Stack trên cùng / `Overlay`): scrim đen + bảng
  tiền (Image) trượt lên + glow (AnimatedOpacity nhấp nháy) + đếm số
  (`TweenAnimationBuilder` 2s) + (tuỳ) âm thanh.
- Chặn tắt trong **2.5s** đầu (giống `activeClick` trễ), sau đó tap scrim để
  đóng.
- Khi đóng: khôi phục nhạc nền (nếu có hệ thống audio), tiếp tục ván.
- Trigger: khi `TrenDuoiStartRound` có `isJackpot==true && jackpot>0`.
- Cần asset: bảng tiền nổ hũ, hào quang, fx — **chưa có** trong repo → bổ sung
  hoặc làm bản tối giản (scrim + text + glow) trước.

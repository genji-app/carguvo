# Tính năng: Hũ Jackpot (Jackpot Pools & Label)

**Nguồn:** `TrenDuoiGameView.ts` — `updateJackpot`, `updateJackpotLabels`,
`_jackpotInfos`, `lblJackpot`, `TrenDuoiJackpotInfo`.

---

## 1. Mục đích

Hiển thị **giá trị hũ jackpot** đang tích luỹ. Có **nhiều hũ** theo cặp
(`aid`, `bet`); label chỉ hiện hũ ứng với mức cược đang chọn.

---

## 2. Mô hình dữ liệu

```ts
class TrenDuoiJackpotInfo { aid = 0; jackpot = 0; bet = 0; }
_jackpotInfos: TrenDuoiJackpotInfo[];  // tất cả hũ
```

Server gửi `Js = [{ J: <jackpot>, aid: <loại>, b: <bet> }, ...]`:
- `aid`: loại hũ (giá trị **1** và **2** — 2 nhóm).
- `b`: mức cược gắn với hũ.
- `J`: giá trị hũ.

---

## 3. `updateJackpot(jars)`

- **Lần đầu** (`_jackpotInfos` rỗng) → `push = true`:
  - Tạo `TrenDuoiJackpotInfo` cho từng phần tử.
  - **Sắp xếp**: trước theo `aid` (nhóm aid=1 rồi aid=2), trong mỗi nhóm sắp theo
    `bet` **tăng dần** (bubble sort thủ công).
- **Lần sau** → cập nhật tại chỗ: tìm hũ trùng `(aid, bet)` rồi gán `J` mới.
- Cuối cùng: `updateJackpotLabels(withFx = !push)` (lần đầu không fx, cập nhật sau
  có fx đếm số).

---

## 4. `updateJackpotLabels(withFx)`

```ts
for (info of _jackpotInfos) {
  if (info.aid == _aid /*=1*/ && info.bet == this.bet) {  // hũ khớp mức cược đang chọn
    if (!withFx) lblJackpot.string = formatNumber(info.jackpot);
    else /* tween đếm số từ giá trị cũ → mới trong 0.5s */;
    break;
  }
}
```

- Chỉ hiển thị hũ có `aid == 1` **và** `bet == mức cược đang chọn`.
- Đổi chip → đổi hũ hiển thị (xem `07`).
- `withFx`: animation đếm số (count-up) 0.5s khi giá trị thay đổi.

---

## 5. Khi nào cập nhật

- `resInfoGame` → `updateJackpot(Js)` (đầu mỗi subscribe).
- `UPDATE_JAR` (1504) → `updateJackpot(Js)` (server đẩy định kỳ).
- Bấm chip → `updateJackpotLabels(false)` (đổi hũ theo cược).

---

## 6. Nổ hũ (liên kết)

- `resStartNewRound` set `mIsWinJackpot = iJ`. Trong `onUpdateResult`, nếu
  `mIsWinJackpot && jackpot > 0` → hiện `TrenDuoiNoHuView.show(jackpot)` (xem `09`).

---

## 7. Gợi ý áp dụng Flutter

- Model `JackpotData` đã có sẵn (`features/mini_game/messages/common/jackpot_data.dart`)
  — kiểm tra field khớp `{J, aid, b}`.
- State giữ `List<JackpotData> jackpots`; getter lấy hũ `aid==1 && bet==selectedBet`
  để hiển thị `lblJackpot`.
- Animation đếm số: dùng `TweenAnimationBuilder<double>` 0.5s khi giá trị đổi.
- Cập nhật khi nhận `TrenDuoiInfoGame` / `TrenDuoiUpdateJar`.
- UI hiện chưa có chỗ hiển thị label jackpot → cần thêm (theo thiết kế: thường ở
  gần logo hoặc header).

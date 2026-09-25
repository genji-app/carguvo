# Trên Dưới (Up/Down) — Tổng quan & Bản đồ tính năng

> Bộ tài liệu này được dựng từ **toàn bộ source gốc Cocos Creator / TypeScript**
> (folder `TrenDuoi/`). Mỗi tính năng một file `.md` để dễ port sang Flutter.
> Mỗi file gồm: mô tả, logic gốc (kèm số liệu/công thức), business rule, và gợi
> ý áp dụng vào dự án Flutter (`lib/mini/up_down/`).

---

## 1. Trò chơi là gì

**Trên Dưới (Cao Thấp / Hi‑Lo)**: đoán lá bài kế tiếp **cao hơn (Trên)** hay
**thấp hơn (Dưới)** lá hiện tại.

- Chọn **mức cược** (1K · 10K · 50K · 100K · 500K) → bấm **Play** → server chia
  một lá mốc.
- Đoán **Trên/Dưới**. Đúng → **tiền thắng cộng dồn (credit)**, lật lá mới, đoán
  tiếp hoặc **Rút tiền (Lượt mới)**. Sai → **thua**, mất hết, reset.
- Mỗi lá Át (A) xuất hiện → cộng vào bộ đếm **AAA** (tối đa 3) — liên quan
  jackpot/nổ hũ.
- Có **hũ Jackpot** tích luỹ theo (loại, mức cược); một số kết quả nổ hũ.
- Mỗi quyết định có **đồng hồ 02:00** (120 giây).

---

## 2. ⚠️ ĐÍNH CHÍNH field server (RẤT QUAN TRỌNG)

Tên field viết tắt trong message **gây hiểu nhầm**. Đối chiếu cách
`TrenDuoiMessageHandler` truyền tham số vào `TrenDuoiGameView.res*()` cho thấy:

| Field gốc | Tên trong code Flutter hiện tại | **Ý nghĩa THỰC** |
|-----------|--------------------------------|------------------|
| `iid` | `instanceId` ❌ | **Mã LÁ BÀI** (0–51). Được decode ra rank/chất. |
| `crd` | `card` ❌ | **CREDIT** = tiền thắng đang giữ (số trên nút Rút tiền). |
| `b`   | `bet` ✅ | Mức cược. |
| `up`  | `up` ✅ | **Tiền thưởng** nếu đoán **Trên** đúng (label trên). |
| `down`| `down` ✅ | **Tiền thưởng** nếu đoán **Dưới** đúng (label dưới). |
| `sid` | `sessionId` ✅ | Id phiên. |
| `iF`  | `isFree`/`isFinish` | `mIsGameOver` — **THUA / hết ván**. |
| `iJ`  | `isJackpot` ✅ | Thắng jackpot. |
| `J`   | `jackpot` ✅ | Giá trị jackpot. |
| `ng`  | `nextGame` | `forcedNewGame` — khoá nút Trên/Dưới. |
| `udr` (gửi đi) | `upDown` (0/1) ❌ | **`1` = Trên, `-1` = Dưới** (KHÔNG phải 0/1). |
| `items` (khôi phục phiên) | — | Mảng **mã lá** đã lật trong phiên. |

Bằng chứng (TrenDuoiGameView):
```ts
// handler gọi: resStartGame(iid, crd, b, sid, up, down, aid)
resStartGame(result, credit, curBet, sessionID, upValue, downValue, aid) {
  this.onUpdateResult(result, 0);                    // result = iid = LÁ BÀI
  this.mLblHighPrice.string = formatMoneyNumber(upValue);   // up   = thưởng Trên
  this.mLblMidPrice.string  = formatMoneyNumber(credit);    // crd  = CREDIT
  this.mLblLowPrice.string  = formatMoneyNumber(downValue); // down = thưởng Dưới
}
```
→ **Phải sửa `tren_duoi_message.dart`** (parser đang đặt `crd`→card, `iid`→
instanceId) và **comment `udr` 0/1** trong `TrenDuoiSender` trước khi nối logic.
Chi tiết: xem `03_NETWORK_PROTOCOL.md`.

---

## 3. Bản đồ file gốc → tính năng → tài liệu

| File gốc (.ts) | Tính năng | Tài liệu |
|----------------|-----------|----------|
| `TrenDuoiGameView.ts` (777) | Bộ điều khiển chính: luồng, nút, label, timer | `01_GAME_FLOW.md`, `06_COUNTDOWN_TIMER.md`, `07_BET_CHIPS.md` |
| `TrenDuoiGameView.ts` (`onUpdateResult`, `onGameOver`) | Mã hoá lá + luật Trên/Dưới + thắng/thua + đếm A | `02_CARD_ENCODING_RULES.md` |
| `TrenDuoiMessageHandler.ts` | Giao thức 5 message | `03_NETWORK_PROTOCOL.md` |
| `TrenDuoi_SlotMachineCmp.ts`, `TrenDuoi_SlotMachineItemView.ts` | Lá bài quay (slot machine) | `04_CARD_SLOT_MACHINE.md` |
| `TrenDuoiResultItem.ts` (+ `updateResultPanel`) | Dải lịch sử lá trong ván | `05_RESULT_HISTORY_STRIP.md` |
| `TrenDuoiGameView.ts` (`updateJackpot*`) | Hũ jackpot + label theo mức cược | `08_JACKPOT_POOLS.md` |
| `TrenDuoiNoHuView.ts` | Hiệu ứng **nổ hũ** toàn màn | `09_NOHU_EFFECT.md` |
| `TrenDuoiBetHistoryView.ts`, `TrenDuoiBetHistoryItemView.ts` | Lịch sử cược (popup, HTTP) | `10_BET_HISTORY.md` |
| `TrenDuoiBetRankView.ts`, `TrenDuoiBetRankItemView.ts` | Bảng xếp hạng (popup, HTTP) | `11_BET_RANK.md` |
| `UpDownText.ts` | Chuỗi đa ngôn ngữ (en/th/vi) | `12_LOCALIZATION.md` |

---

## 4. Hằng số / dữ liệu chốt

- **Mức cược:** `chip_values = [1000, 10000, 50000, 100000, 500000]`. Mặc định
  chọn `chip_values[0]` (1.000).
- **Đồng hồ:** mặc định `120` giây (`02:00`).
- **Số ô A tối đa:** `mVecAAA.length` (= 3 theo thiết kế).
- **Trang HTTP:** 6 item/trang (lịch sử cược & xếp hạng).
- **`aid` (jackpot/account type):** giá trị `1` và `2` (2 nhóm hũ); client dùng
  `_aid = 1`.
- **Lá bài:** mã `0–51`; `suit = code % 4` (1 bích, 2 tép, 3 rô, 4 cơ); `rank =
  floor(code/4)+1`; **A là rank 1 nhưng giá trị 14 (cao nhất)** khi so Trên/Dưới.

---

## 5. Thứ tự khuyến nghị khi port

1. Sửa protocol (`03`) — **bắt buộc trước**, vì sai semantics sẽ hỏng toàn bộ.
2. State + luồng (`01`) + luật lá (`02`).
3. Các thành phần UI (`04`–`08`).
4. Phụ trợ: nổ hũ (`09`), lịch sử (`10`), xếp hạng (`11`), ngôn ngữ (`12`).

> Xem thêm `../TREN_DUOI_IMPLEMENTATION_PLAN.md` cho kế hoạch nối Riverpod state
> (đã có sẵn message model + sender trong `features/mini_game/`).

# Tính năng: Lá bài quay (Slot Machine)

**Nguồn:** `TrenDuoi_SlotMachineCmp.ts`, `TrenDuoi_SlotMachineItemView.ts`.

---

## 1. Mục đích

Lá bài ở **giữa màn hình** — khi bấm Play / Trên / Dưới thì **quay nhanh** (đổi
mặt liên tục), khi có kết quả thì **dừng và hiện đúng lá** server trả về.

---

## 2. Cấu trúc

- `TrenDuoi_SlotMachineCmp`: bộ điều khiển (spin/stop/reset), bọc 1
  `TrenDuoi_SlotMachineItemView`.
- `TrenDuoi_SlotMachineItemView`: 1 lá bài (`Card` + `Sprite`), quản lý hình +
  độ mờ.

---

## 3. Hành vi `TrenDuoi_SlotMachineCmp`

| Hàm | Logic |
|-----|-------|
| `reset()` | `itemView.reset()` — về lá úp/ẩn |
| `refresh()` | làm sáng lại lá |
| `spin()` | lặp vô hạn: mỗi **0.02s** gọi `itemView.randomize()` (đổi mặt ngẫu nhiên) → tạo cảm giác quay |
| `stop()` | dừng mọi tween trên itemView (đứng yên mặt hiện tại) |
| `stopAndUpdateResult(cardID)` | dừng tween + `itemView.updateResult(cardID)` (hiện đúng lá kết quả) |
| `isStopped()` | `itemView.isHiddenCard()` — true nếu đang ở lá úp/ẩn |

> `isStopped()` được dùng để **chặn đổi chip khi đang quay**: nếu chưa dừng, bấm
> chip sẽ báo "Ván chơi chưa kết thúc!" (`lb_round_undone`).

---

## 4. Hành vi `TrenDuoi_SlotMachineItemView`

| Hàm | Logic |
|-----|-------|
| `reset()` | `card.decodeCard(-1000)` (lá rỗng/úp), sáng, opacity 255 |
| `randomize()` | `card.decodeCard(getRandomInt(0,53))` — mặt ngẫu nhiên, **opacity 190** (mờ nhẹ lúc quay) |
| `updateResult(cardID)` | opacity 255, `card.setTextureWithCode(cardID, UPDOWN)` — hiện đúng lá, sáng |
| `setCard(card)` | gán lá cụ thể, opacity 255, sáng |
| `blur()` | đổi sang sprite `*_blur` (lá mờ) từ `loaded_card_blur` |
| `bright()` | hiện lá thường (texture theo code, kiểu `UPDOWN`) |
| `isHiddenCard()` | `card.isHiddenCard()` |

- Mã giải lá quay random: `getRandomInt(0, 53)` (53 để gồm cả lá đặc biệt/biên).
- Kiểu decode: `TYPE_DECODE_CARD.UPDOWN` (bộ texture riêng cho game này).

---

## 5. Tích hợp với luồng game

- `spin()` (GameView) → `SlotMachineCmp.spin()` (quay) + sfx loop.
- Khi nhận kết quả → `onUpdateResult` gọi
  `trenduoi_SlotMachineCmp.stopAndUpdateResult(result)` → dừng quay, hiện lá.
- `resetAll()` → `SlotMachineCmp.reset()` + `stop()`.

---

## 6. Gợi ý áp dụng Flutter

- Bản Flutter hiện dùng ảnh tĩnh `updown_face_down_card.webp` (lá úp). Để có
  hiệu ứng quay:
  - Trạng thái **idle/spinning**: hiện lá úp (hoặc đổi nhanh giữa vài ảnh lá để
    giả lập quay — dùng `AnimatedSwitcher`/`Timer` ~50ms).
  - Trạng thái **revealed**: hiện đúng lá theo `cardCode` (cần bộ ảnh 52 lá kiểu
    UPDOWN, hoặc render rank+suit lên khung lá).
- Cần asset 52 lá (hoặc 1 khung lá + overlay rank/suit). Hiện repo **chưa có** bộ
  52 lá → cần bổ sung hoặc dựng widget vẽ lá.
- `isStopped()` → cờ `busy`/`spinning` để chặn đổi chip khi đang quay (báo toast
  `lb_round_undone`).
- Thời gian quay tối thiểu: server delay ~0.5s trước khi `onUpdateResult` → giữ
  hiệu ứng quay ít nhất ~0.5s cho mượt.

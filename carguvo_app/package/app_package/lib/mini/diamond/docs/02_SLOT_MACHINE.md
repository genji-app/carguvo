# 02 — Máy quay: cột, ô, animation & mã hoá biểu tượng

> Nguồn: `SlotMachineCmp/KimCuong_SlotMachineCmp.ts`, `KimCuong_SlotMachineColumn.ts`, `KimCuong_SlotMachineItemView.ts`

## 1. Cấu trúc 3×3

Máy quay = **3 cột** (`colums`), mỗi cột hiển thị **3 ô kết quả**. Ma trận 9 ô được đánh số theo hàng:

```
        Cột0   Cột1   Cột2
Hàng0    0      1      2
Hàng1    3      4      5
Hàng2    6      7      8
```

Vì vậy cột `index` nhận symbol `[items[index], items[index+3], items[index+6]]`.

Mỗi cột thực chất chứa **nhiều hơn 3 node ô** (`items[]`) để tạo hiệu ứng cuộn vô tận — các ô chạy xuống, khi vượt đáy thì được "teleport" lên đỉnh và sắp xếp lại.

## 2. Biểu tượng (symbol) & cách mã hoá

Class `KimCuongItem` (trong `KimCuong_SlotMachineItemView.ts`):
```ts
class KimCuongItem {
  code: number = 0;
  decodeItem(code) { this.code = code; }              // symbol chỉ là 1 số nguyên
  getResourceNormalName() { return "tps_symbol_" + code; }        // ảnh nét
  getResourceBlurName()   { return "tps_symbol_blur_" + code; }   // ảnh mờ (khi quay)
}
```

- **Symbol = 1 số nguyên** (`code`). Server trả về mảng số này trong `sbs`.
- Có **7 loại biểu tượng**: `Utils.getRandomInt(0, 6)` khi khởi tạo ngẫu nhiên → code từ 0..6.
- Prefix ảnh: `tps_` = **T**rứng **P**hục **S**inh.
- Mỗi ô có 2 dạng sprite: **normal** (`loaded_item_normal`) và **blur** (`loaded_item_blur`), cộng thêm skeleton animation (`loaded_anim_item`) — được load sẵn trong `GameView`.

### Trạng thái hiển thị 1 ô (`KimCuong_SlotMachineItemView`)
| Hàm | Tác dụng |
|---|---|
| `init()` | Gán symbol ngẫu nhiên 0..6, hiện sprite nét |
| `setItem(item)` | Gán symbol cụ thể |
| `blur()` | Bật sprite **mờ** (dùng khi cột đang quay) |
| `bright()` | Bật sprite **nét** (dùng khi đứng yên / kết quả) |

## 3. Vòng đời animation của một cột

### a) Khởi tạo — `init(default_items)`
- Reset về `STOPPED`.
- Ô đáy được set 3 biểu tượng mặc định (từ `default_items`) và `bright()`.
- `default_items` của máy = `[[0,1,2],[1,2,3],[3,4,5]]` (mỗi cột 3 symbol khởi đầu).

### b) Quay — `spin()`
- Ghi nhớ ô đỉnh (`item_top`).
- Tất cả ô chuyển sang `blur()`.
- State = `SPINNING`.

### c) Cuộn liên tục — `spinning(dt)` (gọi trong `update`)
- Mỗi frame, mọi ô dịch xuống: `y -= SPIN_SPEED × FIXED_DELTA_TIME`.
  - `SPIN_SPEED = 1500`, `FIXED_DELTA_TIME = 0.008333` (~1 frame @120fps).
- Ô nào chạm giới hạn dưới (`item_position_y_limited`) → nhảy lên `item_position_y_top` → đánh dấu cần `sort()` lại theo y.

### d) Nhận kết quả & chuẩn bị dừng — `stop(symbols)`
- Gán 3 symbol kết quả vào ô đỉnh, `bright()`.
- State = `CHECK_TO_STOP`.

### e) Chạy tới điểm dừng — `checkToStop(dt)`
- Tiếp tục cuộn cho đến khi ô đỉnh chạm `item_position_y_stop`.
- Khi chạm → gọi `bounce()` và chuyển `STOPPING`.

### f) Hiệu ứng nảy — `bounce()`
- Sắp lại các ô đúng lưới (khoảng cách = `spacingY + chiều cao ô`).
- Tween nảy nhẹ `by(0.1s, +offset y)` rồi set `STOPPED`.
- **Chỉ cột cuối** khi dừng mới gọi `onStopped()` (và chỉ gọi 1 lần, không x3 theo số ô).
- Phát SFX kết thúc cột: `KimCuongGameView.getInstance().playColumnEndSfx()`.

## 4. Điều phối 3 cột — `KimCuong_SlotMachineCmp`

| Hàm | Vai trò |
|---|---|
| `init()` | Init 3 cột; gắn `onStopped` của cột cuối → `stopped=true` + `onMachineStopped()` |
| `spin()` | Xoá line cũ, cho cả 3 cột `spin()` |
| `stop(items)` | Dừng lệch pha `[0.6, 1.2, 1.8]s` |
| `stopImmediately(items)` | Dừng tức thì `[0,0,0]s` (chế độ Fast) |
| `isStopped()` / `isSpinning()` | Kiểm tra đồng bộ trạng thái 3 cột |
| `showLines / showEachLines / showLine / clearLine` | Vẽ payline trúng (xem `03_PAYLINES.md`) |

### Hằng số quan trọng
```ts
SPIN_SPEED          = 1500     // tốc độ cuộn
FIXED_DELTA_TIME    = 0.008333 // bước thời gian cố định
TIME_TO_SHOW_RESULT = 0.05     // delay nhỏ trước khi dừng
```

## 5. Điểm cần lưu ý khi port Flutter
- Cocos dùng toạ độ y tăng lên trên; hiệu ứng cuộn là **thao tác vị trí thủ công theo frame** (không phải tween) → ở Flutter nên dùng `Ticker`/`AnimationController` với logic wrap tương tự, hoặc dùng `ListWheelScrollView`/custom painter.
- `sort()` theo y để duy trì thứ tự ô — cần tái hiện để tránh ô chồng lệch.
- Symbol chỉ là số `0..6` → asset đặt tên theo convention `tps_symbol_{code}` và `tps_symbol_blur_{code}`.

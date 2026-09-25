# 01 — Luồng chơi & vòng đời một lần quay

> Nguồn: `KimCuongGameView.ts`, `KimCuong_SlotMachineCmp.ts`, `KimCuong_SlotMachineColumn.ts`

## 1. Sơ đồ tổng quát 1 lần quay

```
Người chơi bấm QUAY (btn_spin)
        │
        ▼
[Kiểm tra] Máy đang quay? ──Yes──► báo "đang quay" rồi return
        │ No
        ▼
[Kiểm tra] Có chọn dòng nào không? ──No──► báo "chọn dòng cược" rồi return
        │ Yes
        ▼
GameView.spin()
   ├─ kimCuong_SlotMachineCmp.spin()   → 3 cột bắt đầu quay (client tự animate)
   ├─ startRandomSpinSfxLoop()         → phát tiếng quay ngẫu nhiên
   └─ requestSpin()                    → GỬI request lên server (cmd 1302)
        │
        ▼   (bất đồng bộ — chờ server)
Server trả kết quả ─► KimCuongMessageHandler ─► GameView.receiveData(aid, moneyExchange, rewards, symbols)
   ├─ lưu symbols (giải mã), rewards, moneyExchange
   ├─ wonJackpot = có reward nào iJ==true?
   └─ stop(symbols)   → lên lịch dừng máy quay
        │
        ▼
Máy quay dừng từng cột (0.6s / 1.2s / 1.8s) → cột cuối dừng
        │
        ▼
onMachineStopped()
   ├─ nếu moneyExchange > 0 → showResult()  (vẽ line trúng, hiện +tiền / nổ hũ)
   ├─ nếu = 0 → chỉ delay 0.5s
   ├─ stopSpinSfxLoop()
   └─ sendRefreshMoney(MAIN)   → cập nhật số dư ví
        │
        ▼
Nếu Auto bật → tự spin lại. Nếu không → hiển thị lặp các dòng trúng.
```

## 2. Điều kiện chặn (guard) trước khi quay

Trong `spin()` (dòng 296) và các handler:
- **Đang quay** (`!isStopped()`): bấm QUAY / đổi chip / mở chọn dòng đều bị chặn, hiện message `txt_slot_is_spinning`.
- **Chưa chọn dòng** (`lineArr.length <= 0`): hiện `txt_slot_pls_select_bet_line`.
- Đổi chip / mở chọn dòng còn bị chặn khi **Auto đang bật** (`tog_auto.isChecked`).

## 3. Máy quay: 4 trạng thái (state machine mỗi cột)

`KimCuong_SlotMachineColumn` có enum `SlotMachineState`:

| State | Ý nghĩa |
|---|---|
| `SPINNING` | Đang quay tự do, biểu tượng chạy xuống liên tục và wrap vòng lại lên trên |
| `CHECK_TO_STOP` | Đã nhận symbol kết quả, tiếp tục chạy đến khi ô đỉnh chạm vị trí dừng |
| `STOPPING` | Đang thực hiện hiệu ứng "nảy" (bounce) |
| `STOPPED` | Đã dừng hẳn |

- `SlotMachineCmp.isStopped()` = **tất cả** cột `STOPPED`.
- `SlotMachineCmp.isSpinning()` = **tất cả** cột `SPINNING`.

## 4. Cơ chế dừng lệch pha (stagger)

Trong `KimCuong_SlotMachineCmp.stop()`:
```
time = [0.6, 1.2, 1.8]   // cột 0 dừng trước, cột 2 dừng sau cùng
```
Mỗi cột nhận đúng 3 symbol của mình: `[items[i], items[i+3], items[i+6]]` (vì ma trận 9 ô đánh số theo hàng).

Nếu **Fast** bật → `stopImmediately()` dùng `time = [0,0,0]` (dừng tức thì cả 3 cột).

Trước khi thực sự dừng còn có delay `TIME_TO_SHOW_RESULT = 0.05s` (trong `GameView.stop()`).

## 5. Xử lý sau khi dừng: `onMachineStopped` → `showResult`

`showResult(onContinue)` (GameView dòng 232) làm các việc:
1. Vẽ các dòng trúng: `showLines(resultLines, timeShowLine, 0.3)`. `timeShowLine = 0` nếu Fast, ngược lại `0.7`.
2. Set label kết quả: `lbl_result_amount = "+" + format(moneyExchange)`.
3. Phân nhánh:
   - **Nổ hũ** (`wonJackpot`) → chạy `showNoHuEffect` (gọi `kimCuongNoHuView.showJackpot`).
   - **Thường** → `showNormalResult`: phát `win_sfx`, hiện khối kết quả, trượt lên 20px (`expoOut`), giữ 1.5s (0s nếu Fast).
4. Fade khối kết quả ra sau đó.
5. Gọi `onContinue()` để: **auto spin tiếp** nếu Auto bật, hoặc **lặp hiển thị từng dòng trúng** (`showEachLines`).

## 6. Trường hợp lỗi từ server

`KimCuongMessageHandler.onResultError = (code, mes) => {...}` (GameView dòng 130):
- Hiện `NotiView` với thông báo lỗi.
- Gọi `forceMachineStop()` → tắt Auto + dừng máy với mảng rỗng (`stop([])` → `moneyExchange=0`, `rewards=[]`).

## 7. Các hàm điều khiển ngoài (dùng bởi hệ thống)
- `isSpinning()`, `isFastSpin()`, `turnOffAutoSpin()`
- `forceMachineStop(stopAuto=true)` — buộc dừng, thường dùng khi có sự kiện ngắt (chuyển màn, mất kết nối...).

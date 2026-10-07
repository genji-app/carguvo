# 05 — Giao thức mạng (Network Protocol)

> Nguồn: `KimCuongGameView.ts` (`requestSpin`, `receiveData`, `updateJackpot`), và bản port Flutter đã xác thực trong `lib/features/mini_game/messages/slot_message.dart` + `common/jackpot_data.dart`.

## 1. Kênh & định tuyến

- Game dùng **2 socket**:
  - `SocketType.MINI` — luồng gameplay mini-game (spin, jackpot).
  - `SocketType.MAIN` — ví/tiền (`sendRefreshMoney`).
- Mọi message gửi qua plugin: 
  ```ts
  let mes = [MessageRequest.ZonePlugin_Type, "MiniGame", "slotMachinePlugin", dict];
  SocketManager.getInstance().sendData(SocketType.MINI, mes);
  ```
- **Game ID**: `202` (`GAME_ID.MINI_S_DIAMOND`). KimCuong/MiniPoker/DragonBall dùng **chung wire shape**, chỉ khác `gid`.

## 2. Bảng lệnh (cmd codes)

| Cmd | Tên | Chiều | Ý nghĩa |
|---|---|---|---|
| 1300 | `SUBSCRIBE_JACKPOT` | server→client | Trả danh sách hũ ban đầu + trạng thái auto-spin nếu có |
| 1301 | `UNSUBSCRIBE_JACKPOT` | client→server | Huỷ đăng ký hũ |
| 1302 | `SPIN_RESULT` | 2 chiều | Gửi lệnh quay / nhận kết quả quay |
| 1303 | `AUTO_SPIN` | — | Auto spin |
| 1304 | `UPDATE_JACKPOT` | server→client | Push cập nhật số hũ realtime |
| 1305 | `CANCEL_AUTO_SPIN` | — | Huỷ auto spin |
| 1308 | `SPIN_FREE` | — | Quay miễn phí (dùng ở DragonBall) |

## 3. Request: SPIN (cmd 1302)

`requestSpin()` gửi lên:
```json
{
  "cmd": 1302,
  "b":   1000,            // bet mỗi dòng
  "aid": 1,               // pool id
  "ls":  [0,1,2,...,19],  // các dòng đang chọn
  "gid": 202              // KimCuong
}
```

## 4. Response: SPIN RESULT (cmd 1302)

Client nhận qua `KimCuongMessageHandler` → `GameView.receiveData(aid, moneyExchange, rewards, symbols)`.

Wire shape (đã xác thực trong `slot_message.dart`):
```json
{
  "cmd": 1302,
  "aid": 1,
  "mX":  50000,           // moneyExchange = tiền thắng ròng lượt này
  "sbs": [3,1,2,0,...],   // symbols: 9 số cho ma trận 3x3 (theo hàng)
  "wls": [ {"lid": 1, "iJ": false}, ... ],  // winning lines / rewards
  "mgs": null             // nếu có string => server BÁO LỖI (reject)
}
```

Diễn giải trong `receiveData`:
- `symbols` = `sbs.map(decodeItem)` → mỗi số là 1 biểu tượng (0..6).
- `rewards` = `wls`; mỗi phần tử có:
  - `lid` — line ID trúng (0..19) → dùng để vẽ đường trúng.
  - `iJ` — cờ dòng đó có trúng **jackpot** hay không.
- `wonJackpot` = tồn tại reward nào `iJ == true`.
- `moneyExchange` (`mX`) = tổng tiền thắng lượt này (0 nếu thua).

### Xử lý lỗi
Nếu response có `mgs` (message) → `onResultError(code, mes)` → hiện Noti + `forceMachineStop()`.

## 5. Jackpot: SUBSCRIBE (cmd 1300) & UPDATE (cmd 1304)

Cả hai trả danh sách hũ trong `dict["Js"]`:
```json
{
  "cmd": 1304,
  "Js": [
    {"J": 1234567, "aid": 1, "b": 100},
    {"J": 8901234, "aid": 1, "b": 1000},
    ...
  ]
}
```
Mỗi entry (`JackpotData`):
- `J` — số tiền hũ hiện tại
- `aid` — pool id
- `b` — mức cược tương ứng hũ đó

Client (`updateJackpot`):
- Lần **subscribe** (1300): dựng lại toàn bộ danh sách rồi **sắp xếp** theo `aid` (1 trước, 2 sau) và theo `bet` tăng dần.
- Lần **update** (1304): tìm entry khớp `(aid, bet)` và cập nhật `J`.
- Chỉ label khớp `(_aid, bet đang chọn)` mới được hiển thị & chạy số (`updateJackpotLabels`).

Gói subscribe (1300) còn có thể kèm trạng thái auto-spin: `as` (bool), `asb` (bet), `asaid` (aid).

## 6. Refresh ví
Sau khi máy dừng (`onMachineStopped`):
```ts
SocketSend.sendRefreshMoney(SocketType.MAIN);
```
→ đồng bộ số dư sau khi trừ cược / cộng thưởng (server-authoritative).

## 7. HTTP (không qua socket)
Lịch sử cược & BXH lấy qua **HTTP GET** (không phải socket) — xem `07_HISTORY_RANK.md`.

## 8. Tóm tắt mapping key (rút gọn)
| Key | Nghĩa |
|---|---|
| `b` | bet / mức cược mỗi dòng |
| `ls` | danh sách dòng chọn (request) |
| `aid` | pool / account id |
| `mX` | moneyExchange (tiền thắng) |
| `sbs` | symbols (9 số) |
| `wls` | winning lines (rewards) — `lid`, `iJ` |
| `iJ` | cờ trúng jackpot |
| `Js` | danh sách hũ jackpot |
| `J` | số tiền 1 hũ |
| `mgs` | message lỗi (nếu có) |

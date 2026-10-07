# 04 — Cược & Chip

> Nguồn: `KimCuongGameView.ts` (`chip_values`, `bet`, `highlightBet`, `requestSpin`), `KimCuongBetHistoryItemView.ts`

## 1. Mức cược (chip)

```ts
private chip_values: number[] = [100, 1000, 10000];
```

- Có **3 nút chip** (`btn_chips`) tương ứng 3 mệnh giá: **100 / 1.000 / 10.000**.
- Khi vào game, mặc định chọn chip đầu tiên: `this.bet = this.chip_values[0]` = **100**.
- `bet` là **cược trên mỗi dòng** (per-line bet), KHÔNG phải tổng cược.

## 2. Chọn chip

Handler mỗi nút chip (`onLoad`):
```ts
chip.node.on("click", () => {
   // Chặn nếu đang quay hoặc Auto đang bật
   this.highlightBet(ind);            // đánh dấu chip đang chọn (checkmark)
   this.bet = this.chip_values[ind];  // đổi mức cược
   SocketSend.sendSubscribeMiniGame(SocketType.MINI, GAME_ID.MINI_S_DIAMOND); // re-subscribe (lấy đúng hũ theo bet)
});
```

- `highlightBet(ind)`: bật `checkmark` (`chip.target`) cho đúng chip đang chọn, tắt các chip khác.
- Đổi chip sẽ **subscribe lại jackpot** vì mỗi mức cược có hũ riêng (xem `06_JACKPOT_NOHU.md`).
- **Không đổi được chip khi đang quay hoặc đang Auto.**

## 3. Tổng cược (total bet)

Công thức nghiệp vụ:
```
Tổng cược 1 lượt = bet (per-line) × số dòng đang chọn (lineArr.length)
```

Ví dụ: chip 1.000, chọn 20 dòng → tổng cược = **20.000**/lượt.

Trong lịch sử cược, mỗi phiên trả về cả:
- `bet` (`betting`) — cược mỗi dòng
- `numLines` — số dòng
- `totalBet` — tổng cược
(xem `07_HISTORY_RANK.md`).

## 4. Cược được gửi lên server thế nào

Trong `requestSpin()`:
```ts
dict["cmd"] = MINI_GAME_MESSAGE.SPIN_RESULT;  // 1302
dict["b"]   = this.bet;      // cược mỗi dòng
dict["aid"] = this._aid;     // account/jackpot pool id
dict["ls"]  = this.lineArr;  // mảng các dòng đang chọn
dict["gid"] = GAME_ID.MINI_S_DIAMOND; // 202
```

Server tự tính tổng cược = `b × ls.length` và trừ tiền. Client **không** tự trừ ví — chỉ gọi `sendRefreshMoney(MAIN)` sau khi máy dừng để đồng bộ số dư.

## 5. `aid` — mã hồ (account/pool id)

- `_aid` mặc định = `1`, được cập nhật lại từ mỗi kết quả server (`receiveData(aid, ...)`).
- Dùng để chọn đúng **hũ jackpot** khớp cặp `(aid, bet)` khi hiển thị số hũ (`updateJackpotLabels`).
- Có ít nhất 2 nhóm `aid` (1 và 2) được sắp xếp trong `updateJackpot`.

## 6. Ràng buộc & lưu ý business
- Mệnh giá chip cố định trong client (`[100, 1000, 10000]`) — nếu backend đổi thì phải sửa cả client.
- Tổng cược tỉ lệ thuận số dòng → UI luôn phải hiển thị rõ số dòng (`line_num_text`) để người chơi biết mình đang cược bao nhiêu.
- Toàn bộ tính tiền thắng/thua là **server-authoritative** (client chỉ hiển thị). Điều này quan trọng cho tính công bằng và chống gian lận.

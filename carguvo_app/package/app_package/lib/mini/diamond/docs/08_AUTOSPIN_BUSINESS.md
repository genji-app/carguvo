# 08 — Auto/Fast spin, Âm thanh & Quy tắc Business

> Nguồn: `KimCuongGameView.ts`

## 1. Auto Spin (`tog_auto`)

- Là toggle cho phép **quay tự động liên tục**.
- Khi bật (`onLoad`): nếu máy đang dừng → `spin()` ngay.
  ```ts
  this.tog_auto.node.on("toggle", () => {
     if (this.tog_auto.isChecked && this.kimCuong_SlotMachineCmp.isStopped()) this.spin();
  });
  ```
- Sau mỗi lần dừng (`onMachineStopped` / `showResult` callback): nếu Auto vẫn bật và máy đã dừng → tự `spin()` tiếp.
- Auto bị **tắt** khi: người chơi tắt toggle, `forceMachineStop(true)`, hoặc `hide()` (đóng game).
- Khi Auto bật, **không cho** đổi chip / mở chọn dòng.
- `isCanDeactiveRoot()` = `!tog_auto.isChecked` → khi đang auto thì không cho deactivate root view (giữ game chạy nền).

### Auto + Nổ hũ
Khi trúng hũ lúc auto: hiệu ứng nổ hũ tự ẩn sau **14.5s** rồi quay tiếp (không cần người chơi bấm).

## 2. Fast Spin (`tog_fast`)

Chế độ tăng tốc, ảnh hưởng nhiều chỗ:
| Nơi | Bình thường | Fast |
|---|---|---|
| Dừng 3 cột | lệch pha `[0.6,1.2,1.8]s` (`stop`) | tức thì `[0,0,0]s` (`stopImmediately`) |
| Thời gian hiện line trúng (`timeShowLine`) | `0.7s` | `0s` |
| Giữ khối kết quả | `1.5s` | `0s` |
| Fade kết quả | `2.0s` | `0.5s` |

→ Fast rút ngắn toàn bộ animation để chơi nhanh hơn (thường kết hợp với Auto để "cày").

## 3. Âm thanh (SFX/BGM)

| Clip | Khi nào |
|---|---|
| `spin_loop_1_sfx` / `spin_loop_2_sfx` | Tiếng quay — **luân phiên ngẫu nhiên mỗi 100ms** (`startRandomSpinSfxLoop`) |
| `spin_column_end_sfx` | Mỗi khi 1 cột dừng (`playColumnEndSfx`, gọi từ `bounce()`) |
| `win_sfx` | Khi hiện kết quả thắng thường |
| `nohu_bgm` | BGM khi nổ hũ (`KimCuongNoHuView`) |

### Chi tiết loop tiếng quay
```ts
setInterval(() => {
   stop(currentSpinSfx);
   currentSpinSfx = Math.random() < 0.5 ? spin_loop_1_sfx : spin_loop_2_sfx;
   play(currentSpinSfx);
}, 100);
```
- Bắt đầu khi `spin()`, dừng khi máy dừng (`stopSpinSfxLoop`) hoặc `hide()`.
- Nếu vào lại game mà máy chưa dừng (`getStopped()==false`) → khởi động lại loop tiếng quay.

## 4. Vòng đời view: `show()` / `hide()` / `init()`

**`show()`**:
- Subscribe mini-game (lấy jackpot).
- Đưa view lên trên cùng (`bringGameViewToTop`).
- Nếu máy chưa dừng → phát lại tiếng quay.
- Scale `0.9` nếu **portrait**, `1.0` nếu landscape.

**`hide()`**:
- Dừng tiếng quay, ẩn history/rank, tắt Auto, ẩn help & popup nổ hũ, xoá line.

**`init()`**: gọi `super.init()` rồi `hideImmediately()` (ẩn ngay khi khởi tạo).

## 5. Quy tắc Business tổng hợp (rất quan trọng khi port)

1. **Server-authoritative**: client KHÔNG tự tính thắng/thua/trừ tiền. Client chỉ gửi (`b`, `ls`, `aid`, `gid`), nhận kết quả (`mX`, `sbs`, `wls`), rồi `sendRefreshMoney` để đồng bộ ví. → Chống gian lận, đảm bảo công bằng.
2. **Tổng cược = bet × số dòng**. Số dòng do người chơi chọn (1..20).
3. **Mức cược cố định**: `[100, 1000, 10000]`.
4. **Jackpot theo (aid, bet)**: đổi chip = đổi hũ = phải subscribe lại.
5. **Trúng hũ khi có dòng `iJ==true`** trong `wls`.
6. **Chặn thao tác khi đang quay / auto**: không đổi chip, không đổi dòng, không spin chồng.
7. **Không chọn dòng thì không quay được** (`lineArr.length > 0`).
8. **7 loại biểu tượng** (code 0..6), ma trận 3×3, 20 payline cố định.

## 6. Checklist khi port sang Flutter (`lib/mini/diamond`)
- [ ] State machine cột (SPINNING/CHECK_TO_STOP/STOPPING/STOPPED) → dùng `AnimationController`/`Ticker`.
- [ ] Reuse `slot_message.dart` (đã có, gid=202) cho socket.
- [ ] History & Rank qua HTTP (`BET_HISTORY_URL`, `BET_RANK_TOP_URL`) — phân trang 6/trang.
- [ ] Jackpot subscribe/update + label chạy số.
- [ ] Hiệu ứng nổ hũ: skeleton `diamond_start`/`diamond_loop` (Spine Flutter) + BGM.
- [ ] Auto (14.5s auto-hide nổ hũ) & Fast (rút gọn timing).
- [ ] Vẽ payline (LINE table 20 dòng) + nhãn số dòng trái/phải theo `lineID`.
- [ ] Chuẩn hoá lại logic chẵn/lẻ trong bộ chọn dòng (xem lưu ý ở `03_PAYLINES.md`).
- [ ] Asset đặt tên `tps_symbol_{code}` / `tps_symbol_blur_{code}`.

# 📘 Tài liệu game Kim Cương (Diamond)

Bộ tài liệu phân tích **tính năng, logic và business** của game slot **Kim Cương** (gid=202, "Trứng Phục Sinh"), dựa trên source gốc TypeScript/Cocos trong folder `KimCuong/`. Mục tiêu: giúp đọc, nắm bắt và hiểu trò này trước khi port sang Flutter (`lib/mini/diamond`).

## Đọc theo thứ tự

| # | File | Nội dung |
|---|---|---|
| 00 | [00_OVERVIEW.md](./00_OVERVIEW.md) | Game là gì, business value, bản đồ file/class, khung UI |
| 01 | [01_GAME_FLOW.md](./01_GAME_FLOW.md) | Luồng 1 lần quay, state machine, guard, xử lý lỗi |
| 02 | [02_SLOT_MACHINE.md](./02_SLOT_MACHINE.md) | Cột/ô, animation quay–dừng–nảy, mã hoá 7 biểu tượng |
| 03 | [03_PAYLINES.md](./03_PAYLINES.md) | Bảng 20 payline, vẽ đường trúng, bộ chọn dòng |
| 04 | [04_BETTING.md](./04_BETTING.md) | Chip [100/1.000/10.000], bet, tổng cược, aid |
| 05 | [05_NETWORK_PROTOCOL.md](./05_NETWORK_PROTOCOL.md) | cmd codes, request/response spin, jackpot, mapping key |
| 06 | [06_JACKPOT_NOHU.md](./06_JACKPOT_NOHU.md) | Hũ lũy tiến theo (aid,bet), nhận biết & hiệu ứng nổ hũ |
| 07 | [07_HISTORY_RANK.md](./07_HISTORY_RANK.md) | Lịch sử cược + chi tiết phiên, bảng xếp hạng (HTTP) |
| 08 | [08_AUTOSPIN_BUSINESS.md](./08_AUTOSPIN_BUSINESS.md) | Auto/Fast spin, âm thanh, tổng hợp quy tắc business + checklist port |

## Tóm tắt nhanh (TL;DR)

- **Loại**: slot 3×3, **20 payline**, **7 biểu tượng** (code 0..6).
- **Cược**: 3 mức chip cố định `[100, 1000, 10000]`; **tổng cược = bet × số dòng chọn**.
- **Mạng**: chung wire với MiniPoker/DragonBall (khác `gid`). Spin = cmd `1302`; jackpot = `1300`/`1304`. Đã có port `slot_message.dart`.
- **Server-authoritative**: client gửi cược & hiển thị, server tính kết quả (`mX`, `sbs`, `wls`).
- **Jackpot**: hũ lũy tiến theo cặp `(aid, bet)`; trúng khi có dòng `iJ==true` → **nổ hũ** (skeleton `diamond_start`/`diamond_loop` + BGM riêng).
- **Tiện ích**: Auto spin, Fast spin, Lịch sử cược, BXH — tất cả qua HTTP cho history/rank.

## Nguồn phân tích
- Source gốc: `KimCuong/*.ts` + `KimCuong/SlotMachineCmp/*.ts`
- Đối chiếu port Flutter: `lib/features/mini_game/messages/slot_message.dart`, `common/jackpot_data.dart`, `INTEGRATION_NOTES.md`

> ⚠️ Có 1 điểm logic cần chuẩn hoá khi port: quy ước "chọn/bỏ chọn" trong bộ chọn dòng đang bị đảo (chi tiết trong `03_PAYLINES.md` mục 4).

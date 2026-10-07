# Tính năng: Bảng xếp hạng (Bet Rank / Leaderboard)

**Nguồn:** `TrenDuoiBetRankView.ts`, `TrenDuoiBetRankItemView.ts`.

---

## 1. Mục đích

Popup hiển thị **bảng xếp hạng thắng lớn / nổ hũ** của người chơi khác, phân
trang, lấy qua **HTTP API**.

---

## 2. Nguồn dữ liệu (HTTP)

- Endpoint: `URL_DEFINE.BET_RANK_URL_CAOTHAP`, thay `%skip%`.
- Base URL: `SAdomainURL` hoặc `urlGameApi` (khi `IS_USE_GAME_API`).
- Phân trang **6/trang**; `skip = (page-1)*6`; `maxPage = ceil(count/6)`.
- `HTTPManager.sendGET` → `doc.data.items`, `doc.data.count`.

---

## 3. Field mỗi bản ghi (`MiniPokerBetRankDict`)

> Tên class là "MiniPoker..." nhưng dùng cho Trên Dưới (copy nhầm tên).

| JSON | Biến | Ý nghĩa |
|------|------|---------|
| `betting` | bet | Mức cược |
| `displayName` | displayName | Tên người chơi |
| `credit` | money | Tiền thắng |
| `description` | type | Loại thắng (Big Win / Jackpot) |
| `createdTime` | betTime | Thời gian (`formatTime`) |

---

## 4. Hiển thị item (`TrenDuoiBetRankItemView.show`)

`show(time, username, bet, winamount, type)`:
- `time`; `username` (cắt theo bề rộng 200px qua `setLabelTruncateStringByWidth`);
- `bet` = formatNumber; `win_amount` = formatNumber;
- `type` = `lb_big_win` ("Big Win"); nếu chuỗi == "Nổ hũ" thì đổi sang
  `lb_jackpot` ("Jackpot").
- Có check ký tự tiếng Việt: nếu `type` chứa ký tự VN thì để rỗng (tránh font
  lỗi) — chi tiết tuỳ asset font.

Cột bảng: **Thời gian · Tài khoản · Cược · Tiền thắng · Loại**.

---

## 5. Điều hướng trang

- `btn_prev`/`btn_next`: đổi `current_page`, `fetchRank(false)`.
- Prev hiện khi `page > 1`; next khi `page < maxPage`.
- 2 bản ngang/dọc (`trenDuoiBetRankView` / `trenDuoiBetRankPortrait`).

---

## 6. Gợi ý áp dụng Flutter

- Provider HTTP riêng trả `List<BetRankItem>` + `count`.
- Endpoint `BET_RANK_URL_CAOTHAP` cần lấy từ config app — **xác nhận URL thật**.
- UI: bottom sheet / dialog phân trang 6/trang, cột như mục 4.
- `type`: map "Big Win" / "Jackpot" theo ngôn ngữ (`12_LOCALIZATION`).
- Nút Xếp hạng (icon cúp trong header) mở popup này.

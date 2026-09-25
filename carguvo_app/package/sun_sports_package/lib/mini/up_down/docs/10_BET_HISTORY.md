# Tính năng: Lịch sử cược (Bet History)

**Nguồn:** `TrenDuoiBetHistoryView.ts`, `TrenDuoiBetHistoryItemView.ts`.

---

## 1. Mục đích

Popup hiển thị **lịch sử các ván đã chơi** của người chơi, phân trang, lấy qua
**HTTP API** (không qua socket).

---

## 2. Nguồn dữ liệu (HTTP)

- Endpoint: `URL_DEFINE.BET_HISTORY_CAOTHAP`, thay `%skip%` (và `%gameid%` =
  `GAME_ID.UPDOWN` nếu dùng game API).
- Base URL: `GameConfigManager.SAdomainURL` hoặc `urlGameApi` (khi
  `GAME_DEFINE.IS_USE_GAME_API`).
- Phân trang: **6 item/trang**; `skip = (page-1)*6`.
- `HTTPManager.sendGET(url, cb)` → parse JSON `doc.data.items`, `doc.data.count`;
  `max_pages = ceil(count/6)`.

---

## 3. Field mỗi bản ghi (`UpDownBetHistory`)

| JSON | Biến | Ý nghĩa |
|------|------|---------|
| `sessionId` | sessionID | Id phiên |
| `betting` | bet | Mức cược |
| `credit` | money | Tiền thắng |
| `createdTime` | betTime | Thời điểm (format theo `formatTime`, ngang/dọc) |
| `itemId` | card | **Mã lá kết quả** |
| `turn` | turn | Số bước (lượt đã lật) |
| `predictId` | valueBet | Lựa chọn: **1 = Trên, -1 = Dưới** |

---

## 4. Hiển thị item (`TrenDuoiBetHistoryItemView.show`)

`show(sessionID, time, chon, buoc, buocthang, thang, card)`:
- `#session`, `time`, `chon` → "Up"/"Down" (theo `predictId` 1/-1),
- `buoc` = `turn` (số bước), `buocthang` = `bet`, `thang` = `money` (tiền thắng),
- `card` → `setTextureWithCode(cardID, DEFAULT)` (ảnh lá kết quả).

Cột bảng: **Phiên · Thời gian · Lựa chọn · Bước · Cược · Tiền thắng · Lá**.

---

## 5. Điều hướng trang

- `btn_prev`/`btn_next`: đổi `currentPage`, `fetchHistory(false)` (không nhảy về
  trang 1).
- Nút prev hiện khi `page > 1`; next hiện khi `page < max_pages`.
- `goToFirstPage()` khi mở mới.
- Có 2 bản: **ngang** (`trenDuoiBetHistoryView`) và **dọc/portrait**
  (`trenDuoiBetHistoryPortrait`) — chọn theo `isCurViewPortrait()`.

---

## 6. Gợi ý áp dụng Flutter

- Đây là **API HTTP**, không phải socket → tách provider riêng (Dio/HTTP) trả
  `List<UpDownBetHistory>` + `count`.
- Endpoint + cách build URL cần lấy từ config app (tương đương
  `GameConfigManager`/`URL_DEFINE.BET_HISTORY_CAOTHAP`) — **xác nhận URL thật**.
- UI: bottom sheet / dialog danh sách phân trang 6/trang, cột như mục 4.
- Map `predictId` 1/-1 → "Trên"/"Dưới"; `itemId` → render lá (helper `02`).
- Nút Lịch sử (icon đồng hồ trong header) mở popup này.

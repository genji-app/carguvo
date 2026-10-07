# 07 — Lịch sử cược & Bảng xếp hạng

> Nguồn: `KimCuongBetHistoryView.ts`, `KimCuongBetHistoryItemView.ts`, `KimCuongBetHistoryDetail.ts`, `KimCuongBetRankView.ts`, `KimCuongBetRankItemView.ts`

Cả hai tính năng này lấy dữ liệu qua **HTTP GET** (không qua socket), phân trang **6 dòng/trang**.

---

## A. Lịch sử cược (Bet History)

Mở bằng `btn_bet_history` → `GameView.showBetHistory()` → `kimCuongBetHistoryView.fetchHistory()`.

### 1. Gọi API
```ts
url = <domain> + URL_DEFINE.BET_HISTORY_URL
        .replace("%gameid%", "202")
        .replace("%skip%", skip);   // skip = (page-1)*6
// Nếu GAME_DEFINE.IS_USE_GAME_API → dùng urlGameApi thay vì SAdomainURL
HTTPManager.getInstance().sendGET(url, callback);
```

### 2. Cấu trúc response (JSON)
```json
{
  "data": {
    "count": 123,
    "items": [
      {
        "sessionId": 456,
        "betting": 1000,        // bet mỗi dòng
        "money": 50000,         // tiền thắng
        "totalBet": 20000,      // tổng cược
        "numLines": 20,         // số dòng
        "createdTime": <ms>,
        "symbols": [3,1,2,...], // 9 số ma trận
        "payoutLines": [ {"id": 1}, {"id": 7}, ... ]  // các dòng trúng
      }
    ]
  }
}
```
- `max_pages = ceil(count / 6)`.
- Thời gian format bằng `StringUtils.formatTime(new Date(createdTime))`.

### 3. Hiển thị 1 dòng — `KimCuongBetHistoryItemView.show(...)`
Mỗi dòng hiện: `#sessionID`, thời gian, cược/dòng, số dòng cược, tổng cược, số dòng trúng, tiền thắng, và nút **Chi tiết**.

### 4. Chi tiết phiên — `KimCuongBetHistoryDetail`
Bấm "Chi tiết" → `showDetail(sessionID, symbols, payoutLines)`:
- Vẽ lại **ma trận 9 ô** từ `symbols` (mỗi ô `setItem` + `bright`).
- Vẽ **các dòng trúng** (`payoutLines`) lần lượt (mỗi dòng cách 1s) bằng cùng `LINE` table trong `KimCuong_SlotMachineCmp`.
- Nút back → quay lại danh sách (`onBack`).

> Lưu ý index ô trong detail: `column + (row * 3)` — khớp cách đánh số ma trận theo hàng.

### 5. Phân trang
- `btn_prev` / `btn_next` đổi `currentPage`, gọi lại `fetchHistory(false)`.
- Ở chế độ **portrait** thì ẩn logic hiện/ẩn nút prev/next (khác landscape).

---

## B. Bảng xếp hạng (Bet Rank / Leaderboard)

Mở bằng `btn_rank` → `GameView.showRank()` → `kimCuongBetRankView.fetchRank()`.

### 1. Gọi API
```ts
url = <domain> + URL_DEFINE.BET_RANK_TOP_URL
        .replace("%gameid%", "202")
        .replace("%skip%", skip);   // skip = (page-1)*6
```

### 2. Cấu trúc response (JSON)
```json
{
  "data": {
    "count": 80,
    "items": [
      {
        "betting": 10000,
        "displayName": "Player***",
        "money": 5000000,      // tiền thắng
        "description": "Nổ hũ", // loại thắng
        "createdTime": <ms>
      }
    ]
  }
}
```

### 3. Hiển thị 1 dòng — `KimCuongBetRankItemView.show(...)`
Cột hiển thị: thời gian, tên (cắt bớt theo bề rộng 200px), cược, tiền thắng, **loại** (`type`/`description`).

Xử lý đặc biệt cho cột "loại":
- Nếu `type == "Nổ hũ"` → đổi sang chuỗi đa ngôn ngữ `lb_common_jackpot`.
- Nếu chuỗi còn chứa ký tự tiếng Việt (`isContainVietNameseChar`) → **xoá trắng** (fallback tránh lỗi font). *(Đây là hack tạm; khi port nên chuẩn hoá bằng key đa ngôn ngữ.)*

### 4. Phân trang: giống Lịch sử (6 dòng/trang, prev/next).

---

## C. Đa ngôn ngữ (i18n)
Cả hai view đều `refreshLanguage(lang)` set các label tĩnh từ `CommonText[lang]`:
- Lịch sử: tiêu đề, phiên, thời gian, cược, số dòng, tổng cược, số dòng thắng, tiền thắng.
- BXH: tiêu đề, thời gian, tên, cược, tiền thắng, loại (jackpot type).

## D. Ý nghĩa business
- **Minh bạch**: lịch sử cược cho người chơi tự kiểm tra kết quả từng phiên → tăng niềm tin.
- **Social proof / FOMO**: BXH khoe người thắng lớn (đặc biệt "Nổ hũ") → kích thích người khác chơi.
- Dữ liệu tách khỏi socket (qua HTTP) → giảm tải cho luồng gameplay realtime.

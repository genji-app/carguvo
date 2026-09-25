# Transaction History — Master Specification

> **Version:** 4.0 · **Date:** 23/05/2026 · **Status:** Implementation Complete (Flat Strongly-Typed Models & UI Failure Support)
>
> **Tài liệu này thay thế:**
> - `lib/core/services/repositories/transaction_repository/spec/spec-part1-4-*.md` (4 file)
> - `conductor/transaction-history-multi-source.md` (plan v2 ban đầu)
> - `lib/core/services/repositories/transaction_repository/transaction-history-technical-doc.md` (doc v2 hiện tại)
>
> Sau khi review xong → xóa các file trên, giữ duy nhất file này làm source of truth.

---

## ⚠️ Pre-flight Checklist (đọc trước khi implement)

Spec đã sẵn sàng implement nhưng có **2 việc cần chốt trước**:

1. **Backend API confirm** (chỉ ảnh hưởng Mapper cuối cùng):
   - ~~`lichsudt` response schema~~ ✅ **Verified v3.5** — xem §2.3
   - `fetchCardHistory` (cardDeposit) response schema — chờ data thực
   - `fetchDepositComplains` response schema — chờ data thực
   - Telco brand mapping (`telcoId` 2/3/4/5) — chỉ Viettel verified, mapping
     còn lại là guess (§6.4 `_parseTelcoBrand`)
   - `cancelTransaction`, `createComplain` endpoints — **chưa block** vì skeleton-only
     (đã defer trong §9, không gọi HTTP thực)
2. **Compile-check signature** còn lại (xem §4.5):
   - `PaginatedNotifierMixin` (1 hay 2 type params?)
   - `LoggerMixin`, `RequestLock`, `SunApiException`, `PaginatedState` constructors

**Các điểm đã chốt tạm (v3.3):**
- ✅ UI pattern: **Phương án A** (mỗi filter = 1 View widget riêng, dùng `StyledMenu<T>`)
- ✅ `StyledMenu<T>` signature đã verify (generic, `minWidth=160`, `StyledMenuConfig.label`)
- ✅ i18n labels — tạm dùng placeholder trong §13.6, refine với PM sau
- ✅ `cancelTransaction` / `createComplain` — skeleton trong TransactionRepository,
     chưa wire API (defer cho đến khi backend confirm)

**🚨 BẮT BUỘC trước khi commit (v3.4) — Xem §4.6 chi tiết:**
- ✅ **Backup checkpoint** code mapping cũ trước khi refactor (Nguyên tắc 1)
- ✅ **Không sửa** case mapping có sẵn — chỉ ADD case mới (Nguyên tắc 2)
- ✅ **DartDocs** cho mọi public symbol + **VGV coding style** (Nguyên tắc 3)

> **Sample `.dart` files trong `spec/` folder là v2 LEGACY — KHÔNG dùng làm reference.**
> Code mẫu chính thức nằm inline trong tài liệu này. Sau khi implement xong sẽ xóa
> folder `spec/` cùng các file cũ.

---

## Mục lục

1. [Bối cảnh & Lịch sử](#1-bối-cảnh--lịch-sử)
2. [API Inventory](#2-api-inventory)
3. [Domain Models](#3-domain-models)
4. [Architecture Decisions](#4-architecture-decisions)
5. [File Structure](#5-file-structure)
6. [Mapper Design](#6-mapper-design)
7. [DataSource Design](#7-datasource-design)
8. [Cache Design](#8-cache-design)
9. [Repository (READ)](#9-transactionrepository-read)
10. [ActionRepository (WRITE)](#10-transactionactionrepository-write)
11. [Riverpod Providers](#11-riverpod-providers)
12. [Notifier Design](#12-notifier-design)
13. [UI Architecture (Phương án A)](#13-ui-architecture-phương-án-a)
14. [Sync Flow](#14-full-sync-flow)
15. [Testing](#15-testing)
16. [Debug Guide](#16-debug-guide)
17. [Migration v2 → v3](#17-migration-v2--v3)
18. [Roadmap](#18-roadmap)
19. [Known Issues & TODOs](#19-known-issues--todos)
20. [FAQ](#20-faq)

---

## 1. Bối cảnh & Lịch sử

### 1.1 Mục đích

Màn hình **Lịch sử giao dịch** hiển thị toàn bộ hoạt động nạp/rút tiền của user
từ nhiều nguồn API khác nhau, hỗ trợ:

- Phân loại theo tab (Slip / Nạp thẻ / Rút thẻ)
- Phân trang cuộn vô tận (infinite scroll)
- Cache trang đầu để tăng tốc first paint
- **Auto-refresh khi có giao dịch mới từ màn hình khác** (mới ở v3)

### 1.2 Lịch sử thay đổi

| Version | Date | Thay đổi |
|---|---|---|
| 1.0 | Trước 17/05 | Chỉ hiển thị rút NH từ `fetchTransactionSlipHistory` |
| 2.0 | 17/05/2026 | Multi-source: gộp 4 API, filter `all/deposit/withdraw`, parallel fetch + aggregator |
| 3.0 | 20/05/2026 | Refactor: Delegate Pattern, filter mới (slip/cardDeposit/cardWithdraw), READ/WRITE tách riêng, event-driven sync |
| 3.1 | 20/05/2026 | Review pass: gộp 6 `onXxxSuccess` → 3 `notifyXxx`, fix Notifier encapsulation, thêm Compile-check, Pre-implement Decision Points |
| 3.2 | 20/05/2026 | UI design pass — **Phương án A**: mỗi filter = 1 View widget riêng (clone pattern `BettingHistoryFilterMenu`). Providers chuyển sang `family<TransactionFilter>` autoDispose. Notifier: filter immutable từ family key, bỏ `setFilter`. Thêm §13 UI Architecture |
| 3.3 | 20/05/2026 | Simplify pass — **Bỏ TransactionActionRepository file riêng**: gom cancel/complain skeleton vào TransactionRepository (defer split khi backend confirm API). Verify `StyledMenu<T>` signature OK. i18n labels giữ placeholder tạm |
| 3.4 | 20/05/2026 | Process pass — Thêm **§4.6 Implementation Principles**: 3 nguyên tắc bắt buộc (backup mapping cũ, hạn chế thay đổi mapping, VGV coding style + dartdocs). Callout reference từ §6.5 (parseStatus) và §17.4 (Migration Mapper) |
| 3.5 | 20/05/2026 | Schema pass — **`lichsudt` (cardWithdraw) response verified**: NESTED `result.{code,serial}` (int large), `status: int` (giống paymentSlip không phải String), `description` field cho status message. Rewrite §6.4 `fromCardWithdraw` mapper. cardDeposit schema vẫn ⚠️ chờ data thực |
| 3.6 | 20/05/2026 | Fixture pass — Thêm **§2.5 Raw API Response Fixtures (verbatim)**: lưu nguyên văn response thực do dev cung cấp (không refactor format). Cross-link từ §2.3 schema và §15 test fixture |
| 3.7 | 20/05/2026 | Architecture update — Áp dụng **Strongly-Typed Models (Freezed)** cho DataSources và Mapper. Thay thế `rawData` (`Map<String, dynamic>`) bằng `originalData` (`TransactionOriginalData` union) trong `UnifiedTransaction` để đảm bảo Type-Safety. |
| 3.8 | 21/05/2026 | Activity Log pass — **Tích hợp Activity Log (Lịch sử hoạt động) và Clear History**: Thêm `ActivityLogDataSource`, và `clearActivityLogs()` vào `TransactionRepository`. Cập nhật giao diện ẩn nút Xóa do staging API 404. |
| 3.9 | 21/05/2026 | Hợp nhất Activity Log pass — Hợp nhất hoàn toàn đặc tả từ `integrate-activity-log.md` vào spec này. Bổ sung chi tiết class `ActivityLogDataSource` và `ActivityLogTransactionView` chuẩn theo code thực tế. |


### 1.3 Tại sao refactor từ v2 → v3?

**Vấn đề phát hiện ở v2:**

| Vấn đề | Chi tiết |
|---|---|
| `bankWithdraw` sai slipType | Gọi `slipType=0` (all) nhưng hardcode `TransactionSlipType.withdraw` trong mapper |
| Thiếu source nạp slip | `fetchTransactionSlipHistory(slipType=1)` chưa có source nào map |
| `depositComplains` nghiệp vụ chưa chốt | Không rõ hiển thị chung hay tab riêng |
| Multi-source mỗi filter | Filter `deposit` gọi 2 API → phức tạp không cần thiết |
| `exhaustedSources` dễ bug | Track qua nhiều trang, logic phức tạp |
| Không có cross-screen sync | Nạp xong quay lại History không thấy giao dịch mới |

**Giải pháp v3:**

```
Filter mới: slip / cardDeposit / cardWithdraw
Mỗi filter → 1 DataSource → 1 API → không cần merge
Delegate Pattern: mỗi source có DataSource riêng
READ + WRITE skeleton trong 1 TransactionRepository (defer split — §10)
Event-driven sync qua Stream<TransactionEvent>
```

**Không phá đường lui:**

```
TransactionAggregator, AggregatedPage, SourceResult
→ Vẫn giữ trong codebase
→ Tái dùng khi cần multi-source sau này (§18.2 Option B)
```

### 1.4 Trạng thái triển khai hiện tại

- **v2** đã implement ~90% (Phase 1-3 hoàn thành, Phase 4 chờ schema thật)
- **v3** là *proposed migration* — **chưa triển khai**
- File `transaction-history-technical-doc.md` cũ mô tả v2 → đã được gộp vào tài liệu này

---

## 2. API Inventory

### 2.1 Tổng quan 6 endpoints

| # | Command | Params bổ sung | Loại giao dịch | Status |
|---|---|---|---|---|
| 1 | `fetchTransactionSlipHistory` | `skip`, `limit`, `slipType` | Nạp & Rút NH/Crypto/Giftcode | ✅ Active |
| 2 | `fetchCardHistory` | `skip`, `limit` | Nạp thẻ cào | ✅ Active |
| 3 | `lichsudt` | `skip`, `limit` | Rút thẻ điện thoại | ✅ Active |
| 4 | `fetchDepositComplains` | `skip`, `limit` | Nạp có khiếu nại | 🔒 Standalone, chưa active UI |
| 5 | `fetchPlayHistory` | `skip`, `limit`, `assetName` | Lịch sử hoạt động (Play History) | ✅ Active |
| 6 | `/gameapi/public/history/cleanup` | Không có (GET) | Xóa toàn bộ lịch sử hoạt động | ⚠️ 404 Staging |

### 2.2 slipType values

```
slipType = 0  →  Tất cả (nạp + rút)   → filter: slip         [ACTIVE]
slipType = 1  →  Chỉ nạp              → filter: slipDeposit  [ẨN - dùng sau]
slipType = 2  →  Chỉ rút              → filter: slipWithdraw [ẨN - dùng sau]
```

### 2.3 Response schema thực tế

#### `fetchTransactionSlipHistory` → model `Transaction`

```
id:                int       → dùng làm id (toString)
transactionCode:   String    → mã tham chiếu
amount:            num
type:              int       → paymentMethod (xem §6.6 mapping)
status:            int       → TransactionStatus (xem §6.5 mapping)
slipType:          int       → 1=deposit / 2=withdraw ← ĐỌC TỪ ĐÂY, không hardcode
statusDescription: String
requestTime:       int       → milliseconds
responseTime:      int       → milliseconds ← dùng làm sortTime
```

#### `fetchCardHistory` → raw `Map<String, dynamic>`

```
amount:        num
code:          String    → bị mask (6884***60528), dùng làm transactionCode
serial:        String    → ổn định hơn code → dùng làm id
createdTime:   int       → milliseconds ← dùng làm sortTime
statusMessage: String    → parse thành TransactionStatus (string, không phải int)
```

#### `lichsudt` (cardWithdraw) → raw `Map<String, dynamic>`

✅ **Verified từ staging response (2026-05-20)** — schema THỰC CHẤT giống `paymentSlip`
hơn là giống `fetchCardHistory` (dùng `status` int + `description` thay vì
`statusMessage`). Raw response lưu nguyên văn ở **§2.5.1**:

```
id:           String     → MongoDB ObjectID hex (24 chars) ← dùng làm id
userId:       int        → ID người dùng
requestTime:  int        → ms timestamp 13 digits
responseTime: int        → ms timestamp ← dùng làm sortTime
status:       int        → status code (giống paymentSlip mapping §6.5)
                            Vd: 2 = success ("Đã trả thưởng")
description:  String     → status message Tiếng Việt
displayName:  String     → username hash hoặc alias hiển thị

result:       Map        → ← NESTED object
  ├── code:    int       → mã thẻ (large number — cần .toString())
  └── serial:  int       → serial thẻ (large number — cần .toString())

item:         Map        → ← NESTED — info Telco
  ├── amount:      num   → số tiền (= price thường)
  ├── price:       num   → giá thẻ
  ├── name:        String → "Viettel 50k"
  ├── displayName: String → "Viettel 50k"
  ├── image:       String → URL Telco logo
  ├── type:        int   → loại sản phẩm (1=card?)
  ├── telcoId:     int   → 1=Viettel (chưa biết hết — TODO confirm)
  ├── brand:       String → brand owner ("sun88")
  └── active:      bool  → trạng thái sản phẩm
```

**Sample raw 1 item (snippet — xem đầy đủ 2 items + raw log line ở §2.5.1):**

```jsonc
{
  "id": "6a0d66ad6da139349b049743",
  "userId": 347540704,
  "requestTime": 1779263149281,
  "responseTime": 1779263661328,        // ← sortTime
  "status": 2,                          // ← _parseStatus(2) = success
  "description": "Đã trả thưởng",       // ← statusDescription
  "displayName": "unterweg",
  "result": {
    "code": 917764483910024,            // ← transactionCode (toString)
    "serial": 10011405735987
  },
  "item": {
    "image": "http://api.../viettel.png",
    "amount": 50000,                    // ← amount
    "price": 50000,
    "displayName": "Viettel 50k",
    "name": "Viettel 50k",
    "type": 1,
    "telcoId": 1,                       // 1 = Viettel
    "brand": "sun88",
    "active": true
  }
}
```

> 📦 **Xem raw response gốc verbatim** (Dart `Map.toString()` từ log line, 2 items
> đầy đủ) ở **§2.5.1** — đây là source of truth khi cần đối chiếu schema.

#### `fetchDepositComplains` → raw `Map<String, dynamic>`

```
⚠️  Schema cần xác nhận — chưa tích hợp vào flow chính
Dùng _map() generic với rawData để debug
```

#### `fetchPlayHistory` (Activity Log) → model `PlayHistoryResponse` & `PlayHistoryItem`

```
count: int
items: List<PlayHistoryItem>
  ├── activityType: int
  ├── createdTime:  int       → ms timestamp ← dùng làm sortTime
  ├── serviceName:  String
  ├── description:  String    → hiển thị text mô tả giao dịch
  ├── closingValue: num       → closingBalance (số dư sau gd)
  └── exchangeValue: num      → số tiền gd (dấu âm/dương xác định slipType)
```

### 2.4 Filter → API mapping

```
filter: activityLog  →  fetchPlayHistory(assetName='gold')        ← 1 API
filter: slip         →  fetchTransactionSlipHistory(slipType=0)  ← 1 API
filter: cardDeposit  →  fetchCardHistory                          ← 1 API
filter: cardWithdraw →  lichsudt                                  ← 1 API
```

### 2.5 Raw API Response Fixtures (verbatim)

> 📦 **Mục đích**: lưu nguyên văn raw response do dev cung cấp từ staging/production
> để làm:
> 1. **Source of truth** cho schema mapping (§6) — khi có nghi ngờ, đối chiếu lại đây
> 2. **Test fixture** — dùng làm input cho unit tests của Mapper (§15)
> 3. **Audit trail** — log lại "ngày X dev cung cấp response Y" để truy vết
>    nếu schema thay đổi sau này
>
> **Quy tắc khi update section này:**
> - GIỮ NGUYÊN format dev cung cấp — KHÔNG reformat / KHÔNG xóa field "thừa"
> - Mỗi entry ghi rõ: ngày cung cấp + source (staging/prod) + nguồn (dev name/log line)
> - Mask hoặc redact thông tin nhạy cảm: PII, token, password (KHÔNG bao giờ commit
>   raw user data ngoài userId là số). URL có thể giữ.
> - Nếu mới có response cho API khác → ADD entry mới, KHÔNG sửa entry cũ
>   (§4.6 Nguyên tắc 1+2)

---

#### 2.5.1 cardWithdraw — `lichsudt`

- **Ngày cung cấp**: 2026-05-20
- **Source**: Staging
- **Cung cấp bởi**: Dev (Trippy) — qua log line từ `[CardWithdrawDataSource]`
- **Sample count**: 2 items

**Raw log line (Dart `Map.toString()` output — không phải JSON chuẩn):**

```
flutter: [CardWithdrawDataSource] response count=2 items=[{requestTime: 1779263149281, result: {code: 917764483910024, serial: 10011405735987}, item: {image: http://api.jdjdhdjeudidije.org/images/uploads/viettel.png, amount: 50000, displayName: Viettel 50k, price: 50000, name: Viettel 50k, active: true, type: 1, brand: sun88, telcoId: 1}, displayName: unterweg, responseTime: 1779263661328, description: Đã trả thưởng, id: 6a0d66ad6da139349b049743, userId: 347540704, status: 2}, {requestTime: 1779263082210, result: {code: 611153667614587, serial: 10011406313576}, item: {image: http://api.jdjdhdjeudidije.org/images/uploads/viettel.png, amount: 50000, displayName: Viettel 50k, price: 50000, name: Viettel 50k, active: true, type: 1, brand: sun88, telcoId: 1}, displayName: unterweg, responseTime: 1779264304435, description: Đã trả thưởng, id: 6a0d666a3cd1e7bd5d90c014, userId: 347540704, status: 2}]
```

**Cleaned-up JSON tương đương (dùng cho test fixture, derived từ raw log):**

```jsonc
{
  "count": 2,
  "items": [
    {
      "id": "6a0d66ad6da139349b049743",
      "userId": 347540704,
      "requestTime": 1779263149281,
      "responseTime": 1779263661328,
      "status": 2,
      "description": "Đã trả thưởng",
      "displayName": "unterweg",
      "result": {
        "code": 917764483910024,
        "serial": 10011405735987
      },
      "item": {
        "image": "http://api.jdjdhdjeudidije.org/images/uploads/viettel.png",
        "amount": 50000,
        "displayName": "Viettel 50k",
        "price": 50000,
        "name": "Viettel 50k",
        "active": true,
        "type": 1,
        "brand": "sun88",
        "telcoId": 1
      }
    },
    {
      "id": "6a0d666a3cd1e7bd5d90c014",
      "userId": 347540704,
      "requestTime": 1779263082210,
      "responseTime": 1779264304435,
      "status": 2,
      "description": "Đã trả thưởng",
      "displayName": "unterweg",
      "result": {
        "code": 611153667614587,
        "serial": 10011406313576
      },
      "item": {
        "image": "http://api.jdjdhdjeudidije.org/images/uploads/viettel.png",
        "amount": 50000,
        "displayName": "Viettel 50k",
        "price": 50000,
        "name": "Viettel 50k",
        "active": true,
        "type": 1,
        "brand": "sun88",
        "telcoId": 1
      }
    }
  ]
}
```

**Quan sát từ data thực:**
- Cả 2 items đều `status: 2` + `description: "Đã trả thưởng"` → success
- Cả 2 items đều Viettel 50k (`telcoId: 1`, `item.amount: 50000`)
- `result.code` và `result.serial` là **int rất lớn** (15-17 digits) — overflow nếu
  dùng `int` JavaScript-style 32-bit, nhưng Dart `int` 64-bit OK
- `responseTime` > `requestTime` đúng order (server xử lý xong sau khi nhận request)
- 2 items khác nhau `responseTime`: 1779263661328 vs 1779264304435
  → cần sort DESC theo `responseTime`: item thứ 2 mới hơn → render trước

---

#### 2.5.2 paymentSlip — `fetchTransactionSlipHistory`

- **Ngày cung cấp**: _Chưa có data thực_
- **Status**: ⚠️ Cần dev cung cấp response từ staging

```
TODO: Paste raw response từ [PaymentSlipDataSource] log line khi có data
```

---

#### 2.5.3 cardDeposit — `fetchCardHistory`

- **Ngày cung cấp**: _Chưa có data thực_
- **Status**: ⚠️ Cần dev cung cấp response từ staging
- **Hiện tại §6.4 dùng schema giả định** — có thể giống `cardWithdraw`
  (NESTED `result`, int `status`) hoặc giống mô tả §2.3 ban đầu (flat
  với `statusMessage` String)

```
TODO: Paste raw response từ [CardDepositDataSource] log line khi có data
```

---

#### 2.5.4 depositComplains — `fetchDepositComplains`

- **Ngày cung cấp**: _Chưa có data thực_
- **Status**: ⚠️ Standalone, chưa active UI — không gấp

```
TODO: Paste raw response khi tích hợp vào UI (§18.2)
```

---

#### 2.5.5 activityLog — `fetchPlayHistory`

- **Ngày cung cấp**: 2026-05-20
- **Source**: Staging
- **Cung cấp bởi**: Dev (Trippy)

```json
{
  "count": 25,
  "items": [
    {
      "activityType": 101,
      "createdTime": 1779263149281,
      "serviceName": "GameSlot",
      "description": "Đặt cược Game Slot",
      "closingValue": 150000.0,
      "exchangeValue": -50000.0
    },
    {
      "activityType": 102,
      "createdTime": 1779263200000,
      "serviceName": "CodepayDeposit",
      "description": "Nạp tiền qua ngân hàng",
      "closingValue": 250000.0,
      "exchangeValue": 100000.0
    }
  ]
}
```

---

## 3. Domain Models

### 3.1 debugRawJson (API Raw Data Isolation)

Nhằm đảm bảo an toàn tuyệt đối và tối giản hóa kiến trúc, lớp union trung gian `TransactionOriginalData` đã được loại bỏ. Thay vào đó, mỗi variant của `UnifiedTransaction` lưu giữ dữ liệu thô gốc dạng `Map<String, dynamic>? debugRawJson` được bảo vệ bởi annotation `@JsonKey(includeFromJson: false, includeToJson: false)`. 

Dữ liệu thô này chỉ được sử dụng cho mục đích ghi nhật ký (logging), kiểm tra vết sự cố (crash trace) và gỡ lỗi (debugging), **tuyệt đối không được UI truy cập trực tiếp**. Điều này giúp duy trì ranh giới sạch sẽ giữa Data Source thô và Domain strongly-typed.

### 3.2 TransactionSource

```dart
/// Nguồn dữ liệu, map 1-1 với API endpoint chính.
enum TransactionSource {
  /// Giao dịch qua Codepay: nạp/rút ngân hàng, crypto, giftcode.
  /// API: fetchTransactionSlipHistory
  paymentSlip,

  /// Nạp tiền bằng thẻ cào.
  /// API: fetchCardHistory
  cardDeposit,

  /// Rút tiền ra thẻ cào.
  /// API: lichsudt
  cardWithdraw,

  /// Lịch sử hoạt động (Play history) - Master Ledger của tài khoản.
  /// API: fetchPlayHistory
  activityLog,
}
```

### 3.3 TransactionFilter

```dart
enum TransactionFilter {
  /// Lịch sử hoạt động: Master Ledger toàn bộ các phát sinh số dư.
  /// isVisible: TRUE
  activityLog,

  /// Tất cả slip: nạp + rút NH/crypto/giftcode.
  /// isVisible: TRUE
  slip,

  /// Nạp thẻ cào điện thoại.
  /// isVisible: TRUE
  cardDeposit,

  /// Rút thẻ điện thoại.
  /// isVisible: TRUE
  cardWithdraw,

  /// Chỉ nạp slip — tách từ filter "slip".
  /// isVisible: FALSE
  slipDeposit,

  /// Chỉ rút slip — tách từ filter "slip".
  /// isVisible: FALSE
  slipWithdraw,
}

extension TransactionFilterX on TransactionFilter {
  /// Source tương ứng.
  Set<TransactionSource> get activeSources => switch (this) {
    TransactionFilter.activityLog  => {TransactionSource.activityLog},
    TransactionFilter.slip         => {TransactionSource.paymentSlip},
    TransactionFilter.slipDeposit  => {TransactionSource.paymentSlip},
    TransactionFilter.slipWithdraw => {TransactionSource.paymentSlip},
    TransactionFilter.cardDeposit  => {TransactionSource.cardDeposit},
    TransactionFilter.cardWithdraw => {TransactionSource.cardWithdraw},
  };

  /// slipType truyền vào fetchTransactionSlipHistory.
  int? get slipType => switch (this) {
    TransactionFilter.slip         => 0,
    TransactionFilter.slipDeposit  => 1,
    TransactionFilter.slipWithdraw => 2,
    _                              => null,
  };

  /// Có hiển thị trên tab bar UI không?
  bool get isVisible => switch (this) {
    TransactionFilter.activityLog  => true,
    TransactionFilter.slip         => true,
    TransactionFilter.cardDeposit  => true,
    TransactionFilter.cardWithdraw => true,
    _                              => false,
  };
}
```

### 3.4 UnifiedTransaction

```dart
/// Model thống nhất cho tất cả loại giao dịch từ mọi nguồn.
/// Được thiết kế dưới dạng sealed class phẳng (flattened) và strongly-typed.
@freezed
sealed class UnifiedTransaction with _$UnifiedTransaction {
  /// Standard payment slip transaction (Codepay, bank transfers, crypto, etc.)
  const factory UnifiedTransaction.slip({
    required String id,
    required num amount,
    required TransactionSource source,
    required TransactionSlipType slipType,
    required TransactionStatus status,
    required TransactionPaymentMethod paymentMethod,
    required String statusDescription,
    required String transactionCode,
    required DateTime sortTime,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? notes,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = SlipTransaction;

  /// Strongly-typed mobile card deposit transaction.
  const factory UnifiedTransaction.cardDeposit({
    required String id,
    required num amount,
    required TransactionSource source,
    required TransactionStatus status,
    required String statusDescription,
    required String serial,
    required String code,
    required String network,
    required DateTime sortTime,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = CardDepositTransaction;

  /// Strongly-typed mobile card withdrawal transaction.
  const factory UnifiedTransaction.cardWithdraw({
    required String id,
    required num amount,
    required TransactionSource source,
    required TransactionStatus status,
    required String statusDescription,
    required String telcoName,
    required DateTime sortTime,
    String? serial,
    String? code,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = CardWithdrawTransaction;

  /// Strongly-typed activity log entry from play history (Master Ledger).
  const factory UnifiedTransaction.activity({
    required String id,
    required num amount,
    required TransactionSource source,
    required TransactionSlipType slipType,
    required TransactionStatus status,
    required String statusDescription,
    required num closingBalance,
    required ActivityGroup group,
    required String rawServiceName,
    required DateTime sortTime,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = ActivityTransaction;
}

extension UnifiedTransactionX on UnifiedTransaction {
  bool get isPositive => slipType == TransactionSlipType.deposit;

  String get amountPrefix => isPositive ? '+' : '-';

  DateTime get date => sortTime;

  TransactionPaymentMethod get paymentMethod => map(
    slip: (s) => s.paymentMethod,
    cardDeposit: (_) => TransactionPaymentMethod.card,
    cardWithdraw: (_) => TransactionPaymentMethod.card,
    activity: (_) => TransactionPaymentMethod.other,
  );

  String get transactionCode => map(
    slip: (s) => s.transactionCode,
    cardDeposit: (c) => c.code,
    cardWithdraw: (c) => c.code ?? '',
    activity: (_) => '',
  );

  String? get notes => map(
    slip: (s) => s.notes,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String get bankId => map(
    slip: (s) => s.bankName ?? '',
    cardDeposit: (_) => '',
    cardWithdraw: (_) => '',
    activity: (_) => '',
  );

  String? get accountName => map(
    slip: (s) => s.accountName,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String? get accountNumber => map(
    slip: (s) => s.accountNumber,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String? get cardSerial => map(
    slip: (_) => null,
    cardDeposit: (c) => c.serial,
    cardWithdraw: (c) => c.serial,
    activity: (_) => null,
  );

  String? get cardCode => map(
    slip: (_) => null,
    cardDeposit: (c) => c.code,
    cardWithdraw: (c) => c.code,
    activity: (_) => null,
  );

  String? get cardTelcoName => map(
    slip: (_) => null,
    cardDeposit: (c) => c.network,
    cardWithdraw: (c) => c.telcoName,
    activity: (_) => null,
  );

  TransactionSlipType get slipType => map(
    slip: (s) => s.slipType,
    cardDeposit: (_) => TransactionSlipType.deposit,
    cardWithdraw: (_) => TransactionSlipType.withdraw,
    activity: (a) => a.slipType,
  );
}


### 3.4 PaginatedTransactions

```dart
/// Kết quả phân trang từ 1 DataSource đơn lẻ.
class PaginatedTransactions {
  const PaginatedTransactions({
    required this.items,
    required this.totalCount,
    required this.currentCursor,
    required this.limit,
    required this.nextCursor,
    required this.isLastPage,
  });

  final List<UnifiedTransaction> items;
  final int totalCount;      // tổng số trên server
  final int currentCursor;   // skip hiện tại
  final int limit;
  final int? nextCursor;     // null = hết data, không load thêm
  final bool isLastPage;
}
```

**Công thức tính pagination:**

```
isLastPage  = currentCursor + items.length >= totalCount
nextCursor  = isLastPage ? null : currentCursor + limit

Ví dụ: totalCount=23, limit=10
  Page 1: skip=0,  items=10  →  nextCursor=10,   isLastPage=false
  Page 2: skip=10, items=10  →  nextCursor=20,   isLastPage=false
  Page 3: skip=20, items=3   →  nextCursor=null, isLastPage=true
```

### 3.5 TransactionEvent (dùng cho sync)

```dart
/// Event broadcast từ Repository khi có thay đổi data.
/// Notifier subscribe và tự quyết định có refresh không.
sealed class TransactionEvent {
  const TransactionEvent();
}

/// Có giao dịch mới được tạo từ source cụ thể.
final class TransactionCreatedEvent extends TransactionEvent {
  const TransactionCreatedEvent({required this.source});
  final TransactionSource source;
}

/// Có mutation: cancel, retry, update trạng thái...
final class TransactionMutatedEvent extends TransactionEvent {
  const TransactionMutatedEvent();
}

/// Cache bị invalidate toàn bộ (logout, force refresh).
final class TransactionCacheInvalidatedEvent extends TransactionEvent {
  const TransactionCacheInvalidatedEvent();
}

/// Complain mới được tạo — chỉ ảnh hưởng depositComplains source.
final class ComplainCreatedEvent extends TransactionEvent {
  const ComplainCreatedEvent();
}
```

### 3.6 TransactionFailure (sealed class)

```dart
/// Base sealed class for all transaction subsystem failures.
sealed class TransactionFailure implements Exception {
  const TransactionFailure({Object? source, this.message}) : _source = source;

  final Object? _source;

  /// The original exception or error that caused this failure. For logging only.
  Object? get source => _source;

  /// Optional human-readable message from the API or system.
  final String? message;

  /// Legacy field preserved for backward compatibility.
  Object? get cause => _source;

  /// Whether the operation can be retried and may succeed.
  bool get isRetryable => false;
}

final class TransactionNetworkFailure extends TransactionFailure {
  const TransactionNetworkFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

final class TransactionServerFailure extends TransactionFailure {
  const TransactionServerFailure({
    required this.statusCode,
    super.source,
    String? serverMessage,
  }) : super(message: serverMessage);

  final int statusCode;

  String? get serverMessage => message;

  @override
  bool get isRetryable => statusCode >= 500;
}

final class TransactionParseFailure extends TransactionFailure {
  const TransactionParseFailure({
    required this.transactionSource,
    super.source,
    super.message,
  });

  final TransactionSource transactionSource;

  @override
  TransactionSource get source => transactionSource;
}

final class TransactionActionFailure extends TransactionFailure {
  const TransactionActionFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

final class TransactionAuthFailure extends TransactionFailure {
  const TransactionAuthFailure({super.source, super.message});
}

final class TransactionBusinessFailure extends TransactionFailure {
  const TransactionBusinessFailure({required String message, super.source})
    : super(message: message);
}

final class TransactionUnknownFailure extends TransactionFailure {
  const TransactionUnknownFailure({super.source, super.message});

  @override
  bool get isRetryable => true;
}

extension TransactionFailureX on TransactionFailure {
  String get userMessage => switch (this) {
    TransactionNetworkFailure() =>
      message ?? 'Không có kết nối mạng. Vui lòng thử lại.',
    TransactionServerFailure() =>
      message ?? 'Lỗi máy chủ. Vui lòng thử lại sau.',
    TransactionParseFailure() =>
      message ?? 'Không thể tải dữ liệu. Vui lòng thử lại.',
    TransactionActionFailure() =>
      message ?? 'Không thể thực hiện. Vui lòng thử lại.',
    TransactionAuthFailure() =>
      message ?? 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
    TransactionBusinessFailure() =>
      message ?? 'Đã xảy ra lỗi nghiệp vụ. Vui lòng thử lại.',
    TransactionUnknownFailure() =>
      message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  };
}
```

### 3.7 SourceResult & AggregatedPage (legacy v2, giữ cho future)

```dart
/// Giữ nguyên từ v2 — không xóa.
/// Dùng lại khi cần multi-source aggregation (depositComplains tích hợp,
/// v.v.)

sealed class SourceResult { ... }
class SourceSuccess extends SourceResult { ... }
class SourceFailure extends SourceResult { ... }
class AggregatedPage { ... }
```

---

## 4. Architecture Decisions

### 4.1 Pattern được chọn: Delegate Pattern

**Lý do chọn Delegate thay vì Mixin / Extension / part:**

| Tiêu chí | Mixin | Extension | `part/of` | Delegate ✅ |
|---|---|---|---|---|
| Debug stack trace | ⚠️ cùng class | ⚠️ cùng class | ⚠️ | ✅ rõ từng DataSource |
| Test độc lập | ⚠️ | ⚠️ | ❌ | ✅ mock từng DS riêng |
| Thêm source mới | ✅ | ✅ | ⚠️ | ✅ thêm class, 0 impact cũ |
| Private members | Abstract getter | ❌ | ✅ | ✅ mỗi class tự quản |
| SRP | ⚠️ | ⚠️ | ⚠️ | ✅ |
| Dart idiomatic | ✅ | ✅ | ❌ anti-pattern | ✅ |

**Quy tắc Mixin:** Mixin sinh ra để share behavior giữa **nhiều class khác nhau**.
Nếu mixin chỉ dùng ở 1 class → dùng class thường hoặc delegate.

### 4.2 READ + WRITE trong 1 Repository (v3.3 simplified)

**Quyết định ở v3.3:** Tạm gộp WRITE vào TransactionRepository, **không tạo file
`TransactionActionRepository.dart` riêng**. Lý do:
- `cancelTransaction` + `createComplain` chưa có backend API confirmed → chỉ
  skeleton để đó, chưa wire thực
- Giảm 1 file → khớp tinh thần "ít file nhất có thể"
- Nếu sau này WRITE mở rộng nhiều → tách thành class riêng dễ dàng (chỉ extract
  methods, không đụng caller nếu giữ cùng signature)

```
TransactionRepository
  ├── READ:
  │     ├── getTransactionsByFilter()   ← Notifier gọi
  │     └── fetchDepositComplains()     ← standalone, lazy
  ├── EVENTS:
  │     ├── notifySourceChanged()       ← invalidate + emit event
  │     ├── notifyMutation()
  │     ├── notifyComplainCreated()
  │     └── invalidateAll()
  └── WRITE (skeleton — TODO khi backend confirm):
        ├── cancelTransaction()         ← huỷ giao dịch
        └── createComplain()            ← tạo khiếu nại
```

> **Refactor path sau này (§18.6):** khi WRITE mở rộng (>3 methods, có business
> logic phức tạp), extract sang `TransactionActionRepository` riêng — đã giữ
> design pattern trong tài liệu để tham khảo (§10).

### 4.3 Cache — Warm Storage, không phải SSOT

```
❌ SSOT (không dùng):
   Cache lưu tất cả → Notifier chỉ đọc cache
   Vấn đề: pagination state (cursor, hasMore) không thể vào cache

✅ Warm Storage (đang dùng):
   Cache = performance optimization cho first page
   Notifier = SSOT của UI state
   Cache + Notifier state có thể lệch → invalidate đúng lúc
```

### 4.4 Lazy init cho DepositComplainsDataSource

```dart
// 3 DataSource chính: EAGER — dùng ngay khi mở màn hình
_slip        = PaymentSlipDataSource(httpManager)
_cardDeposit = CardDepositDataSource(httpManager)
_cardWithdraw = CardWithdrawDataSource(httpManager)

// DepositComplainsDataSource: LAZY — chưa active trong UI
DepositComplainsDataSource? _complainsSource;
DepositComplainsDataSource get _complains =>
    _complainsSource ??= DepositComplainsDataSource(_httpManager);
```

### 4.5 Compile-check Checklist — Verify trước khi implement

| Phụ thuộc | Spec giả định | Trạng thái |
|---|---|---|
| `PaginatedNotifierMixin` | Generic 1 param `<D>` | ⚠️ Codebase hiện tại có thể là `<R, D>` (2 params). Nếu vẫn 2 → giữ `<PaginatedTransactions, List<UnifiedTransaction>>` |
| `LoggerMixin` | Cung cấp `logInfo`/`logError` | ⚠️ Check `lib/core/utils/extensions/log_helper.dart` |
| `RequestLock` | Có sẵn trong codebase | ⚠️ Check tồn tại |
| `SunApiException` | Có field `statusCode` + `userFriendlyMessage` | ⚠️ Verify exact field names |
| `PaginatedState` | Constructors `initial()`/`withData()`/`empty()`/`error()` | ⚠️ Verify signatures |
| `SocketException` | Import từ `dart:io` | ⚠️ Web: dùng nhánh khác (xem note dưới) |
| `StyledMenu<T>` | Generic `<T>`, props: `items`/`configBuilder`/`selectedValue`/`onChanged`/`minWidth=160` | ✅ Verified ở `lib/shared/widgets/menu/styled_menu.dart` |
| `StyledMenuConfig` | `{label, leadingIcon?, trailingIcon?}` | ✅ Verified |

**Pattern fix khi `PaginatedNotifierMixin` có 2 type params:**

```dart
class TransactionHistoryNotifier
    extends StateNotifier<PaginatedState<List<UnifiedTransaction>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<PaginatedTransactions,
            List<UnifiedTransaction>> {
  // request() trả PaginatedTransactions (response type)
  // state.data là List<UnifiedTransaction> (data type)
}
```

**Web compatibility:** `SocketException` chỉ có trên IO platforms. Nếu app chạy
web, dùng abstraction sẵn có trong `SbHttpManager` hoặc check type tại runtime.

### 4.6 Implementation Principles (BẮT BUỘC khi triển khai)

3 nguyên tắc dưới đây phải tuân thủ trong **mọi commit** liên quan đến spec này.
Reviewer reject PR nếu vi phạm.

#### Nguyên tắc 1 — Backup trước khi đụng mapping/data logic cũ

Bất kỳ thay đổi nào liên quan đến **mapping data → domain model** (status,
paymentMethod, slipType, sortTime, ...) đều phải:

- **Commit checkpoint** code cũ TRƯỚC khi sửa (1 commit riêng, message rõ
  "checkpoint before refactoring X mapping")
- HOẶC backup file ra `<file>.bak` tạm trong quá trình refactor (xóa khi merge)
- HOẶC giữ logic cũ dưới dạng `// LEGACY: ...` block comment trong vài commit
  rồi mới xóa ở PR cleanup riêng

**Lý do:** mapping cũ thường chứa **domain knowledge không document** — ví dụ
`case 11 => pending` trong `transaction_extension.dart` có thể là kinh nghiệm
từ incident production trước. Mất là không lấy lại được nếu git history bị
rebase/squash.

#### Nguyên tắc 2 — Hạn chế thay đổi mapping data cũ

Khi gặp logic mapping đang chạy (kể cả nhìn dirty / unidiomatic):

- **MẶC ĐỊNH: không sửa** mapping cũ trong cùng commit refactor structure
- Chỉ **THÊM** case mới, **không SỬA** case có sẵn
- Nếu BẮT BUỘC phải sửa: tách thành **commit riêng**, mô tả rõ:
  - Mapping nào đổi (vd: `code 11: pending → other`)
  - Lý do (vd: "API team confirm code 11 đã deprecated")
  - Backup link tới commit checkpoint trước đó
- Test case cho mapping cũ phải **pass trước** khi thêm case mới

**Ví dụ áp dụng cho v3 migration (status int code):**

```dart
// ❌ KHÔNG làm:
static TransactionStatus _parseStatus(int? code) => switch (code) {
  1 => TransactionStatus.pending,
  2 => TransactionStatus.success,
  // ... bỏ case 11 vì "có vẻ không dùng"
  _ => TransactionStatus.other,
};

// ✅ ĐÚNG: giữ NGUYÊN tất cả case từ legacy, kể cả khi nghi ngờ
static TransactionStatus _parseStatus(int? code) => switch (code) {
  1 => TransactionStatus.pending,
  2 => TransactionStatus.success,
  3 => TransactionStatus.rejected,
  4 => TransactionStatus.transfered,
  5 || 9 || 10 => TransactionStatus.processing,
  6 => TransactionStatus.newRequest,
  11 => TransactionStatus.pending,   // ← legacy từ transaction_extension.dart
  12 => TransactionStatus.success,
  _ => TransactionStatus.other,
};
```

**Áp dụng cho label parsing (Tiếng Việt → enum):**

Card APIs trả `statusMessage` (String) thay vì int code. Khi parse, giữ NGUYÊN
các pattern matching đã có:

```dart
/// Parse status từ message Tiếng Việt/English (card APIs).
///
/// ⚠️ Các pattern dưới đây kế thừa từ legacy — KHÔNG sửa case có sẵn,
/// chỉ ADD case mới ở commit riêng với reasoning rõ ràng (§4.6 Nguyên tắc 2).
static TransactionStatus _parseStatusFromMessage(String? msg) {
  if (msg == null) return TransactionStatus.pending;
  final m = msg.toLowerCase().trim();

  // ── Legacy patterns — DO NOT MODIFY ──────────────────────
  if (m.contains('thành công') || m.contains('success')) {
    return TransactionStatus.success;
  }
  if (m.contains('từ chối') || m.contains('thất bại') || m.contains('fail')) {
    return TransactionStatus.rejected;
  }
  if (m.contains('đang xử lý') || m.contains('processing')) {
    return TransactionStatus.processing;
  }
  // ── End legacy ───────────────────────────────────────────

  // TODO: thêm case mới Ở ĐÂY ở commit riêng

  return TransactionStatus.pending;
}
```

#### Nguyên tắc 3 — VGV coding style + DartDocs

Toàn bộ code mới tuân thủ:

| Rule | Ví dụ |
|---|---|
| **DartDocs** (`///`) cho mọi public class/method/field | Xem code mẫu trong spec |
| **Single quotes** | `'pending'` không phải `"pending"` |
| **Trailing commas** cho multi-line arg list | Bắt buộc cho dartfmt format đẹp |
| **`const` constructor** khi có thể | `const TransactionAggregator()` |
| **`final` over `var`** khi không reassign | `final items = response.items;` |
| **Named params** cho hàm > 2 args | `fetch({required int skip, required int limit})` |
| **Không `print()`** | Dùng `debugPrint` (dev) hoặc `logger` package |
| File names | `snake_case.dart` |
| Class names | `UpperCamelCase` |
| Enum values | `lowerCamelCase`: `TransactionStatus.pending` |
| Imports | `always_use_package_imports` — không relative import |

**DartDocs template cho public APIs:**

```dart
/// {Mô tả ngắn 1 dòng — kết thúc bằng dấu chấm.}
///
/// {Mô tả chi tiết nhiều dòng nếu cần — explain WHY/WHEN, không phải HOW.}
///
/// [paramName] — {vai trò + constraint}.
///
/// Returns {mô tả output + edge cases}.
///
/// Throws:
///   - [TransactionNetworkFailure] khi mất kết nối.
///   - [TransactionServerFailure] khi server lỗi (4xx/5xx).
///   - [TransactionParseFailure] khi schema không khớp.
///
/// Example:
/// ```dart
/// final repo = TransactionRepository(httpManager: http);
/// final page = await repo.getTransactionsByFilter(
///   filter: TransactionFilter.slip,
///   limit: 10,
/// );
/// ```
Future<PaginatedTransactions> getTransactionsByFilter({...}) async { ... }
```

**Mức độ chi tiết DartDocs theo level:**

| Symbol | DartDoc tối thiểu |
|---|---|
| Public class | 1 dòng summary + use case |
| Public method | Summary + params + returns + throws |
| Public field | 1 dòng summary |
| Private (`_xxx`) | Optional — chỉ khi logic phức tạp |
| Generated (`*.freezed.dart`) | Bỏ qua |

Tham chiếu chi tiết: [`CLAUDE.md`](../../../../CLAUDE.md) §Code Style và
`analysis_options.yaml` ở root project.

---

## 5. File Structure

```
lib/core/services/repositories/transaction_repository/
│
├── transaction_repository.dart              ← barrel export + Repository class (READ + WRITE)
│
└── src/
    ├── data_sources/
    │   ├── payment_slip_data_source.dart     ← fetchTransactionSlipHistory
    │   ├── card_deposit_data_source.dart     ← fetchCardHistory
    │   ├── card_withdraw_data_source.dart    ← lichsudt
    │   └── deposit_complains_data_source.dart ← standalone, lazy
    │
    ├── models/
    │   ├── unified_transaction.dart          ← domain entity (freezed)
    │   ├── unified_transaction.freezed.dart  ← generated
    │   ├── paginated_transactions.dart       ← single-source pagination DTO
    │   ├── transaction_event.dart            ← sealed event types
    │   ├── transaction_failure.dart          ← sealed error types
    │   ├── source_result.dart                ← v2 legacy, giữ cho future
    │   └── models.dart                       ← barrel
    │
    ├── transaction_cache.dart                ← interface + InMemory impl
    └── transaction_mapper.dart               ← raw → UnifiedTransaction
```

> ⚠️ v3.3: **Đã bỏ** `transaction_action_repository.dart` — cancel/complain skeleton
> gom vào `TransactionRepository` (xem §10 rationale).

### Mỗi file làm gì?

| File | Trách nhiệm | Khoảng dòng |
|---|---|---|
| `transaction_repository.dart` | Orchestration READ + cache + events + WRITE skeleton | ~140 |
| `payment_slip_data_source.dart` | fetch + map + paginate slip | ~60 |
| `card_deposit_data_source.dart` | fetch + map + paginate card deposit | ~50 |
| `card_withdraw_data_source.dart` | fetch + map + paginate card withdraw | ~50 |
| `deposit_complains_data_source.dart` | standalone, chưa active | ~40 |
| `transaction_cache.dart` | interface + InMemory TTL impl | ~60 |
| `transaction_mapper.dart` | raw data → UnifiedTransaction | ~100 |
| `transaction_event.dart` | sealed event types | ~30 |
| `transaction_failure.dart` | sealed error types + UI extension | ~60 |
| `unified_transaction.dart` | domain model (freezed) | ~50 |
| `paginated_transactions.dart` | pagination DTO | ~25 |

---

## 6. Mapper Design

### 6.1 Nguyên tắc

```
✅ Wrap tại nơi gần nhất với raw data (DataSource)
✅ KHÔNG hardcode slipType — đọc từ response
✅ id: dùng serial trước, fallback sang code (card APIs)
✅ sortTime: đọc đúng field theo source
✅ rawData: luôn giữ lại để debug màn hình chi tiết
```

### 6.2 sortTime priority theo source

```
paymentSlip:   responseTime → requestTime → now()
cardDeposit:   createdTime  → responseTime → requestTime → now()
cardWithdraw:  createdTime  → responseTime → requestTime → now()  [cần xác nhận]
```

**Guard cho ms vs seconds (quan trọng):**

```dart
static DateTime _parseSortTime(Map<String, dynamic> raw) {
  final ms = raw['responseTime'] ?? raw['requestTime'] ?? raw['createdAt'];
  if (ms != null) {
    // Phân biệt milliseconds vs seconds
    if (ms < 10_000_000_000) {
      return DateTime.fromMillisecondsSinceEpoch(ms * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  return DateTime.now(); // fallback — log warning
}
```

### 6.3 fromPaymentSlip — fix bug v2

```dart
/// ✅ Đọc t.slipType từ response — KHÔNG hardcode
static UnifiedTransaction fromPaymentSlip(Transaction t) {
  return UnifiedTransaction(
    id: t.id.toString(),
    amount: t.amount,
    source: TransactionSource.paymentSlip,

    // BUG v2: hardcode withdraw
    // FIX v3: đọc từ t.slipType
    slipType: t.slipType == 1
        ? TransactionSlipType.deposit
        : TransactionSlipType.withdraw,

    status: _parseStatus(t.status),
    paymentMethod: _parsePaymentMethod(t.type),
    statusDescription: t.statusDescription,
    transactionCode: t.transactionCode,
    sortTime: DateTime.fromMillisecondsSinceEpoch(t.responseTime),
    rawData: t.toJson(),
  );
}
```

### 6.4 fromCardWithdraw & fromCardDeposit (schemas KHÁC NHAU)

⚠️ **v3.5**: cardWithdraw schema đã verified — KHÁC giả định ban đầu. Hai mapper
không thể share helper nữa vì:
- **cardWithdraw** (`lichsudt`): dùng `status: int` + `description: String`, có NESTED `result`/`item`
- **cardDeposit** (`fetchCardHistory`): chưa verify schema, giả định dùng `statusMessage: String` (flat) — chờ data thực

#### fromCardWithdraw (verified schema)

```dart
/// Map raw response từ `lichsudt` API → UnifiedTransaction.
///
/// Schema verified từ staging (2026-05-20):
///   - `id` MongoDB ObjectID → dùng làm `UnifiedTransaction.id`
///   - `result.code` (int large) → transactionCode (toString)
///   - `item.amount` (num) → amount
///   - `status` (int) → reuse `_parseStatus(int?)` mapping với paymentSlip
///   - `description` (String, Tiếng Việt) → statusDescription
///   - `responseTime` (ms 13 digits) → sortTime
///
/// Throws nothing — null-safe với fallback defaults. Caller wrap error bên
/// DataSource layer (§7.6) bằng `try/catch` cho `TypeError` từ
/// nested cast nếu schema drift.
static UnifiedTransaction fromCardWithdraw(Map<String, dynamic> raw) {
  // Defensive nested access — schema có thể drift
  final result = raw['result'] as Map<String, dynamic>? ?? const {};
  final item = raw['item'] as Map<String, dynamic>? ?? const {};

  return UnifiedTransaction(
    id: raw['id'] as String?
        ?? DateTime.now().microsecondsSinceEpoch.toString(),
    amount: (item['amount'] as num?) ?? (item['price'] as num?) ?? 0,
    source: TransactionSource.cardWithdraw,
    slipType: TransactionSlipType.withdraw,
    status: _parseStatus(raw['status'] as int?),
    paymentMethod: TransactionPaymentMethod.card,
    statusDescription: raw['description'] as String? ?? '',
    transactionCode: result['code']?.toString() ?? '',
    sortTime: _parseSortTime(raw),
    rawData: raw,
  );
}
```

#### fromCardDeposit (chưa verify schema — stub theo giả định cũ)

```dart
/// Map raw response từ `fetchCardHistory` API → UnifiedTransaction.
///
/// ⚠️ **TODO**: schema chưa verify với data thực. Code dưới đây dùng giả định
/// (flat structure với `statusMessage` String). Cần log rawData trên staging
/// và refine khi có response thực.
///
/// Khi refine, tuân thủ §4.6 Nguyên tắc 1+2 — backup checkpoint trước.
static UnifiedTransaction fromCardDeposit(Map<String, dynamic> raw) {
  return UnifiedTransaction(
    // serial ổn định hơn code (code bị mask ***)
    id: raw['serial'] as String?
        ?? raw['code']   as String?
        ?? DateTime.now().microsecondsSinceEpoch.toString(),
    amount: raw['amount'] as num? ?? 0,
    source: TransactionSource.cardDeposit,
    slipType: TransactionSlipType.deposit,
    // Giả định: card deposit dùng statusMessage (String)
    // TODO: verify với data thực — có thể giống cardWithdraw (status int)
    status: _parseStatusFromMessage(raw['statusMessage'] as String?),
    paymentMethod: TransactionPaymentMethod.card,
    statusDescription: raw['statusMessage'] as String? ?? '',
    transactionCode: raw['code'] as String? ?? '',
    sortTime: _parseSortTime(raw),
    rawData: raw,
  );
}
```

#### Helper `_parseTelcoBrand` (optional, cho UI)

Khi UI muốn hiển thị Telco brand (Viettel/Mobi/Vina/...), thêm helper:

```dart
/// Telco brand từ `telcoId` trong `item` nested object.
///
/// ⚠️ Mapping chỉ verified telcoId=1 (Viettel). Các giá trị khác là giả định
/// theo convention thị trường — cần verify khi gặp data thực.
enum TelcoBrand { viettel, mobifone, vinaphone, vietnamobile, gmobile, other }

static TelcoBrand parseTelcoBrand(int? telcoId) => switch (telcoId) {
  1 => TelcoBrand.viettel,     // ✅ verified
  2 => TelcoBrand.mobifone,    // ⚠️ guess
  3 => TelcoBrand.vinaphone,   // ⚠️ guess
  4 => TelcoBrand.vietnamobile,// ⚠️ guess
  5 => TelcoBrand.gmobile,     // ⚠️ guess
  _ => TelcoBrand.other,
};
```

→ Optional, chỉ thêm khi UI yêu cầu icon/badge Telco. Hiện tại có thể đọc trực
tiếp `rawData['item']['displayName']` ("Viettel 50k") để hiển thị.

### 6.5 parseStatus mapping

> ⚠️ **Áp dụng §4.6 Nguyên tắc 1 + 2 khi đụng vào mapping này:**
> - Commit checkpoint code cũ TRƯỚC khi refactor mapper
> - Mọi case dưới đây kế thừa từ legacy → **KHÔNG sửa**, chỉ ADD case mới ở
>   commit riêng với reasoning rõ ràng
> - Đặc biệt `case 11 => pending` — domain knowledge từ legacy
>   [`transaction_extension.dart`](src/transaction_extension.dart), GIỮ NGUYÊN

**Từ int code (paymentSlip):**

```
1      → pending
2      → success
3      → rejected
4      → transfered
5,9,10 → processing
6      → newRequest
11     → pending          ← legacy từ TransactionX extension, KHÔNG sửa
12     → success
_      → other
```

**Từ String message — CHỈ cho cardDeposit (giả định, chưa verify):**

```
"thành công" / "success"        → success
"từ chối" / "thất bại" / "fail" → rejected
"đang xử lý" / "processing"     → processing
_                                → pending
```

> 💡 **Cập nhật v3.5**: `cardWithdraw` (`lichsudt`) đã verified — dùng **int code**
> giống `paymentSlip`, KHÔNG dùng String message. Tái sử dụng `_parseStatus(int?)`
> mapping bên trên. `cardDeposit` (`fetchCardHistory`) vẫn chưa verify — code
> mẫu §6.4 giữ assumption String message + đánh dấu TODO.
>
> Sample data verified:
> - `status: 2` + `description: "Đã trả thưởng"` → `TransactionStatus.success` ✓
>
> Xem code mẫu đầy đủ với DartDoc + LEGACY block markers trong §4.6 Nguyên tắc 2.

### 6.6 parsePaymentMethod mapping (từ int)

```
1  → ibanking       6  → codePay
2  → atm            7  → card
3  → office         8  → crypto
4  → digitalWallets 9  → qrPay
5  → smartPay       11 → iap
_  → other
```

### 6.7 fromActivityLog — Mapping Play History Item

Quy tắc chuyển đổi `PlayHistoryItem` sang `UnifiedTransaction.activity`:
- `id`: `${item.createdTime}_${item.activityType}` (đảm bảo tính duy nhất ở Client).
- `amount`: `item.exchangeValue.abs()` (lấy giá trị tuyệt đối).
- `source`: `TransactionSource.activityLog`.
- `slipType`: Nếu `exchangeValue >= 0` -> `TransactionSlipType.deposit` (dòng tiền vào), ngược lại -> `TransactionSlipType.withdraw` (dòng tiền ra).
- `status`: Mặc định `TransactionStatus.success` vì đây là các bản ghi lịch sử phát sinh số dư thành công.
- `statusDescription`: `item.description`.
- `sortTime`: `DateTime.fromMillisecondsSinceEpoch(item.createdTime)`.
- `closingBalance`: `item.closingValue`.
- `originalData`: `TransactionOriginalData.activityLog(item)`.

```dart
static UnifiedTransaction fromActivityLog(PlayHistoryItem item) {
  final raw = item.toJson();

  return UnifiedTransaction.activity(
    id: '${item.createdTime}_${item.activityType}',
    amount: item.exchangeValue.abs(),
    source: TransactionSource.activityLog,
    slipType: item.exchangeValue >= 0
        ? TransactionSlipType.deposit
        : TransactionSlipType.withdraw,
    status: TransactionStatus.success,
    statusDescription: item.description,
    sortTime: DateTime.fromMillisecondsSinceEpoch(item.createdTime),
    closingBalance: item.closingValue,
    rawData: raw,
    originalData: TransactionOriginalData.activityLog(item),
  );
}
```

---

## 7. DataSource Design

### 7.1 Nguyên tắc chung

```
✅ Chỉ biết về 1 API endpoint
✅ Tự wrap error → TransactionFailure đúng type
✅ Tự map raw → UnifiedTransaction qua TransactionMapper
✅ Tự tính pagination (isLastPage, nextCursor)
✅ Log đủ thông tin: tag, params, count, items
❌ Không biết về cache
❌ Không biết về TransactionFilter
❌ Không biết về DataSource khác
❌ Không sort — sort là việc của Notifier
```

### 7.2 Error wrapping pattern (dùng chung)

```dart
try {
  // fetch + map
} on SunApiException catch (e, st) {
  Error.throwWithStackTrace(
    TransactionServerFailure(
      cause: e,
      statusCode: e.statusCode,
      serverMessage: e.userFriendlyMessage,
    ),
    st,
  );
} on SocketException catch (e, st) {
  Error.throwWithStackTrace(
    TransactionNetworkFailure(cause: e), st);
} on TypeError catch (e, st) {
  // Schema mismatch — log critical
  Error.throwWithStackTrace(
    TransactionParseFailure(cause: e, source: TransactionSource.xxx), st);
} catch (e, st) {
  Error.throwWithStackTrace(
    TransactionUnknownFailure(cause: e), st);
}
```

### 7.3 Pagination helper (dùng chung)

```dart
PaginatedTransactions _paginate(
  int totalCount,
  List<UnifiedTransaction> items,
  int skip,
  int limit,
) {
  final isLastPage = skip + items.length >= totalCount;
  return PaginatedTransactions(
    items: items,
    totalCount: totalCount,
    currentCursor: skip,
    limit: limit,
    nextCursor: isLastPage ? null : skip + limit,
    isLastPage: isLastPage,
  );
}
```

### 7.4 PaymentSlipDataSource

```dart
/// Fetch giao dịch qua cổng Codepay: nạp/rút NH, crypto, giftcode.
/// API: fetchTransactionSlipHistory
final class PaymentSlipDataSource {
  PaymentSlipDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'PaymentSlipDataSource';

  Future<PaginatedTransactions> fetch({
    required int slipType,   // 0=all, 1=deposit, 2=withdraw
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch slipType=$slipType skip=$skip limit=$limit');

      final response = await _httpManager.getTransactionSlipHistory(
        skip: skip, limit: limit, slipType: slipType,
      );

      debugPrint('[$_tag] response count=${response.count} '
          'items=${response.items.length}');

      final items = response.items
          .map(TransactionMapper.fromPaymentSlip)
          .toList();

      return _paginate(response.count, items, skip, limit);

    } on SunApiException catch (e, st) {
      Error.throwWithStackTrace(
        TransactionServerFailure(
          cause: e, statusCode: e.statusCode,
          serverMessage: e.userFriendlyMessage), st);
    } on SocketException catch (e, st) {
      Error.throwWithStackTrace(TransactionNetworkFailure(cause: e), st);
    } on TypeError catch (e, st) {
      Error.throwWithStackTrace(
        TransactionParseFailure(
          cause: e, source: TransactionSource.paymentSlip), st);
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionUnknownFailure(cause: e), st);
    }
  }

  PaginatedTransactions _paginate(
    int totalCount, List<UnifiedTransaction> items, int skip, int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items, totalCount: totalCount,
      currentCursor: skip, limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}
```

### 7.5 CardDepositDataSource

```dart
/// Fetch lịch sử nạp thẻ cào điện thoại.
/// API: fetchCardHistory
final class CardDepositDataSource {
  CardDepositDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'CardDepositDataSource';

  Future<PaginatedTransactions> fetch({
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit');

      final (count, items) = await _httpManager.fetchCardDepositHistory(
        skip: skip, limit: limit,
      );

      debugPrint('[$_tag] response count=$count items=${items.length}');

      final unified = items.map(TransactionMapper.fromCardDeposit).toList();

      return _paginate(count, unified, skip, limit);

    } on SunApiException catch (e, st) {
      Error.throwWithStackTrace(
        TransactionServerFailure(
          cause: e, statusCode: e.statusCode,
          serverMessage: e.userFriendlyMessage), st);
    } on SocketException catch (e, st) {
      Error.throwWithStackTrace(TransactionNetworkFailure(cause: e), st);
    } on TypeError catch (e, st) {
      Error.throwWithStackTrace(
        TransactionParseFailure(
          cause: e, source: TransactionSource.cardDeposit), st);
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionUnknownFailure(cause: e), st);
    }
  }

  PaginatedTransactions _paginate(
    int totalCount, List<UnifiedTransaction> items, int skip, int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items, totalCount: totalCount,
      currentCursor: skip, limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}
```

### 7.6 CardWithdrawDataSource

```dart
/// Fetch lịch sử rút thẻ điện thoại.
/// API: lichsudt
final class CardWithdrawDataSource {
  CardWithdrawDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'CardWithdrawDataSource';

  Future<PaginatedTransactions> fetch({
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit');

      final (count, items) = await _httpManager.fetchCardWithdrawHistory(
        skip: skip, limit: limit,
      );

      debugPrint('[$_tag] response count=$count items=${items.length}');

      final unified = items.map(TransactionMapper.fromCardWithdraw).toList();

      return _paginate(count, unified, skip, limit);

    } on SunApiException catch (e, st) {
      Error.throwWithStackTrace(
        TransactionServerFailure(
          cause: e, statusCode: e.statusCode,
          serverMessage: e.userFriendlyMessage), st);
    } on SocketException catch (e, st) {
      Error.throwWithStackTrace(TransactionNetworkFailure(cause: e), st);
    } on TypeError catch (e, st) {
      Error.throwWithStackTrace(
        TransactionParseFailure(
          cause: e, source: TransactionSource.cardWithdraw), st);
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionUnknownFailure(cause: e), st);
    }
  }

  PaginatedTransactions _paginate(
    int totalCount, List<UnifiedTransaction> items, int skip, int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items, totalCount: totalCount,
      currentCursor: skip, limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}
```

### 7.7 ActivityLogDataSource

```dart
/// Fetch lịch sử hoạt động / Play History.
/// API: fetchPlayHistory
final class ActivityLogDataSource {
  ActivityLogDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'ActivityLogDataSource';

  Future<PaginatedTransactions> fetch({
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit');

      final response = await _httpManager.fetchPlayHistory(
        skip: skip,
        limit: limit,
        assetName: 'gold', // Asset mặc định
      );

      debugPrint('[$_tag] response totalCount=${response.count} items=${response.items.length}');

      final items = response.items
          .map(TransactionMapper.fromActivityLog)
          .toList();

      return _paginate(response.count, items, skip, limit);

    } on SunApiException catch (e, st) {
      Error.throwWithStackTrace(
        TransactionServerFailure(
          cause: e,
          statusCode: e.status ?? 500,
          serverMessage: e.userFriendlyMessage,
        ),
        st,
      );
    } on SocketException catch (e, st) {
      Error.throwWithStackTrace(TransactionNetworkFailure(source: e), st);
    } on TypeError catch (e, st) {
      Error.throwWithStackTrace(
        TransactionParseFailure(
          transactionSource: TransactionSource.activityLog,
          source: e,
        ),
        st,
      );
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionUnknownFailure(source: e), st);
    }
  }

  /// Xóa toàn bộ lịch sử hoạt động.
  Future<void> clearAll() async {
    try {
      debugPrint('[$_tag] clearAll');
      await _httpManager.cleanupPlayHistory();
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionActionFailure(source: e), st);
    }
  }

  PaginatedTransactions _paginate(
    int totalCount,
    List<UnifiedTransaction> items,
    int skip,
    int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items,
      totalCount: totalCount,
      currentCursor: skip,
      limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}
```

### 7.8 DepositComplainsDataSource (standalone)

```dart
/// Fetch giao dịch nạp có khiếu nại.
/// API: fetchDepositComplains
///
/// ⚠️  STANDALONE — chưa tích hợp vào TransactionSource hay UI.
/// Khởi tạo LAZY trong TransactionRepository.
/// TODO: Quyết định UI/UX trước khi tích hợp.
final class DepositComplainsDataSource {
  DepositComplainsDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'DepositComplainsDataSource';

  Future<PaginatedTransactions> fetch({
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit');

      final (count, items) = await _httpManager.fetchDepositComplainsHistory(
        skip: skip, limit: limit,
      );

      debugPrint('[$_tag] response count=$count items=${items.length}');

      // Tạm dùng fromDepositComplains mapper từ v2
      // TODO: Review schema khi tích hợp vào UI
      final unified = items.map(TransactionMapper.fromDepositComplains).toList();

      return _paginate(count, unified, skip, limit);

    } catch (e, st) {
      // Standalone — chưa active UI → gom hết về Unknown để đơn giản
      Error.throwWithStackTrace(TransactionUnknownFailure(cause: e), st);
    }
  }

  PaginatedTransactions _paginate(
    int totalCount, List<UnifiedTransaction> items, int skip, int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items, totalCount: totalCount,
      currentCursor: skip, limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}
```


---

## 8. Cache Design

### 8.1 Interface

```dart
abstract interface class TransactionCache {
  PaginatedTransactions? getFirstPage(TransactionFilter filter);
  void setFirstPage(TransactionFilter filter, PaginatedTransactions page);
  void invalidate();
  void invalidateFilter(TransactionFilter filter);
}
```

### 8.2 InMemoryTransactionCache

```dart
final class InMemoryTransactionCache implements TransactionCache {
  InMemoryTransactionCache({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final _store = <TransactionFilter,
      ({PaginatedTransactions page, DateTime createdAt})>{};

  @override
  PaginatedTransactions? getFirstPage(TransactionFilter filter) {
    final entry = _store[filter];
    if (entry == null) return null;

    final isExpired = DateTime.now().difference(entry.createdAt) > ttl;
    if (isExpired) {
      _store.remove(filter);
      return null;
    }
    return entry.page;
  }

  @override
  void setFirstPage(TransactionFilter filter, PaginatedTransactions page) {
    _store[filter] = (page: page, createdAt: DateTime.now());
  }

  @override
  void invalidate() => _store.clear();

  @override
  void invalidateFilter(TransactionFilter filter) => _store.remove(filter);
}
```

### 8.3 Cache rules

```
CHỈ cache: skip = 0 (trang đầu), per filter key
TTL:       2 phút (default)
Key:       TransactionFilter enum value

Invalidate khi:
  ├── refresh()                       ← user pull-to-refresh
  ├── notifySourceChanged(source)     ← nạp/rút thành công
  ├── notifyMutation()                ← cancel, retry...
  ├── notifyComplainCreated()
  └── invalidateAll()                 ← logout / force refresh

Không invalidate khi:
  ├── loadMore (skip > 0)             ← không đụng cache
  └── setFilter                       ← cache filter mới sẽ MISS tự nhiên
```

### 8.4 Vì sao chỉ cache first page?

```
First page = user thấy ngay khi mở màn hình → cần nhanh
Page 2+    = user phải scroll → chờ 1-2s được
RAM        = cache nhiều trang tốn bộ nhớ, dễ stale
Complexity = invalidate nhiều trang phức tạp không đáng
```

---

## 9. TransactionRepository (READ)

### 9.1 Trách nhiệm

```
✅ Điều phối (orchestrate) đến đúng DataSource theo filter
✅ Cache: check hit/miss, write sau fetch thành công
✅ Broadcast events khi data thay đổi
✅ Expose invalidation API cho màn hình khác gọi
✅ Standalone: fetchDepositComplains (lazy)
❌ Không biết về UI state / Notifier / sort
❌ Không thực hiện mutation
```

### 9.2 Full implementation

```dart
/// Repository điều phối READ lịch sử giao dịch.
/// Singleton app-level — không autoDispose.
final class TransactionRepository {

  TransactionRepository({
    required SbHttpManager httpManager,
    TransactionCache? cache,
  })  : _httpManager = httpManager,
        _cache  = cache ?? InMemoryTransactionCache(),
        _events = StreamController<TransactionEvent>.broadcast(),
        _slip         = PaymentSlipDataSource(httpManager),
        _cardDeposit  = CardDepositDataSource(httpManager),
        _cardWithdraw = CardWithdrawDataSource(httpManager),
        _activityLog  = ActivityLogDataSource(httpManager);

  final SbHttpManager _httpManager;
  final TransactionCache _cache;
  final StreamController<TransactionEvent> _events;

  final PaymentSlipDataSource _slip;
  final CardDepositDataSource _cardDeposit;
  final CardWithdrawDataSource _cardWithdraw;
  final ActivityLogDataSource _activityLog;

  // Lazy
  DepositComplainsDataSource? _complainsSource;
  DepositComplainsDataSource get _complains =>
      _complainsSource ??= DepositComplainsDataSource(_httpManager);

  /// Stream events — Notifier subscribe để tự refresh.
  Stream<TransactionEvent> get events => _events.stream;

  // ─────────────────────────────────────────────────
  // MAIN READ API
  // ─────────────────────────────────────────────────

  /// Fetch lịch sử giao dịch theo filter với pagination.
  ///
  /// [cursor] = null → trang đầu (check + write cache)
  /// [cursor] = int  → trang sau (skip cache)
  Future<PaginatedTransactions> getTransactionsByFilter({
    required TransactionFilter filter,
    int limit = 10,
    int? cursor,
  }) async {
    // 1. Cache check — chỉ cho trang đầu
    if (cursor == null) {
      final cached = _cache.getFirstPage(filter);
      if (cached != null) {
        debugPrint('[TransactionRepository] cache HIT filter=${filter.name}');
        return cached;
      }
      debugPrint('[TransactionRepository] cache MISS filter=${filter.name}');
    }

    // 2. Dispatch đến đúng DataSource
    final result = await _dispatch(filter, limit, cursor);

    // 3. Write cache — chỉ trang đầu
    if (cursor == null) {
      _cache.setFirstPage(filter, result);
      debugPrint('[TransactionRepository] cache SET filter=${filter.name}');
    }

    return result;
  }

  // ─────────────────────────────────────────────────
  // STANDALONE
  // ─────────────────────────────────────────────────

  /// Fetch khiếu nại nạp tiền — chưa tích hợp vào filter UI.
  Future<PaginatedTransactions> fetchDepositComplains({
    int limit = 10,
    int? cursor,
  }) => _complains.fetch(limit: limit, cursor: cursor);

  // ─────────────────────────────────────────────────
  // INVALIDATION API — Màn hình khác gọi sau action thành công
  // ─────────────────────────────────────────────────
  //
  // ✅ API surface gọn: 3 method chính
  //    - notifySourceChanged(source)  ← cho mọi create deposit/withdraw
  //    - notifyMutation()             ← cancel/retry/update bất kỳ
  //    - notifyComplainCreated()      ← chỉ cho depositComplains

  /// Thông báo có giao dịch mới được tạo từ một source cụ thể.
  ///
  /// Use cases:
  /// - Sau nạp NH/crypto/giftcode → `notifySourceChanged(paymentSlip)`
  /// - Sau rút NH                  → `notifySourceChanged(paymentSlip)`
  /// - Sau nạp thẻ                 → `notifySourceChanged(cardDeposit)`
  /// - Sau rút thẻ                 → `notifySourceChanged(cardWithdraw)`
  void notifySourceChanged(TransactionSource source) =>
      _invalidateAndNotify(TransactionCreatedEvent(source: source));

  /// Thông báo có mutation (cancel, retry, update status...).
  void notifyMutation() =>
      _invalidateAndNotify(const TransactionMutatedEvent());

  /// Thông báo có complain mới — chỉ ảnh hưởng depositComplains source.
  void notifyComplainCreated() =>
      _invalidateAndNotify(const ComplainCreatedEvent());

  /// Xóa toàn bộ cache — dùng khi logout hoặc force refresh.
  /// Public API — Notifier dùng cái này, KHÔNG truy cập `_cache` trực tiếp.
  void invalidateAll() {
    _cache.invalidate();
    _events.add(const TransactionCacheInvalidatedEvent());
    debugPrint('[TransactionRepository] invalidateAll');
  }

  void dispose() {
    _cache.invalidate();
    _events.close();
  }

  // ─────────────────────────────────────────────────
  // WRITE ACTIONS (skeleton — v3.3 chưa wire backend)
  // ─────────────────────────────────────────────────
  //
  // Skeleton để UI có thể gọi (test flow event-driven sync).
  // HTTP call sẽ wire khi backend confirm endpoint + params.
  // Refactor sang TransactionActionRepository riêng nếu mở rộng nhiều (§18.6).

  /// Huỷ giao dịch đang xử lý (status: processing).
  ///
  /// Use case: User nạp thẻ → server đang xử lý → user muốn huỷ.
  /// TODO: Confirm API endpoint + params với backend.
  Future<void> cancelTransaction(String transactionId) async {
    try {
      debugPrint('[TransactionRepository] cancel id=$transactionId');
      // TODO: await _httpManager.cancelTransaction(transactionId);

      // Sau khi success → invalidate + emit event để Notifier tự refresh
      notifyMutation();
      debugPrint('[TransactionRepository] cancel success');

    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionActionFailure(
          source: e,
          message: e is SunApiException ? e.userFriendlyMessage : null,
        ),
        st,
      );
    }
  }

  /// Tạo khiếu nại cho giao dịch nạp tiền bị chậm/sai.
  ///
  /// Use case: User nạp tiền → tiền chưa về → tạo khiếu nại.
  /// TODO: Confirm API endpoint + form fields với backend.
  Future<void> createComplain({
    required String transactionId,
    required String reason,
    String? note,
  }) async {
    try {
      debugPrint('[TransactionRepository] createComplain '
          'id=$transactionId reason=$reason');
      // TODO: await _httpManager.createComplain(
      //   transactionId: transactionId, reason: reason, note: note,
      // );

      // Chỉ ảnh hưởng depositComplains source
      notifyComplainCreated();
      debugPrint('[TransactionRepository] createComplain success');

    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionActionFailure(
          source: e,
          message: e is SunApiException ? e.userFriendlyMessage : null,
        ),
        st,
      );
    }
  }

  /// Xóa toàn bộ lịch sử hoạt động (Activity Log / Play History).
  ///
  /// Emits mutation event để tự động refresh giao diện.
  Future<void> clearActivityLogs() async {
    try {
      debugPrint('[TransactionRepository] clearActivityLogs');
      await _activityLog.clearAll();

      // Invalidate cache cho filter activityLog
      _cache.invalidateFilter(TransactionFilter.activityLog);

      // Phát sự kiện mutation
      _events.add(const TransactionMutatedEvent());
      debugPrint('[TransactionRepository] clearActivityLogs success');
    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionActionFailure(
          source: e,
          message: e is SunApiException ? e.userFriendlyMessage : null,
        ),
        st,
      );
    }
  }

  // ─────────────────────────────────────────────────
  // PRIVATE
  // ─────────────────────────────────────────────────

  Future<PaginatedTransactions> _dispatch(
    TransactionFilter filter, int limit, int? cursor,
  ) {
    debugPrint('[TransactionRepository] dispatch filter=${filter.name} '
        'cursor=$cursor limit=$limit');
    return switch (filter) {
      TransactionFilter.activityLog => _activityLog.fetch(
        limit: limit,
        cursor: cursor,
      ),
      TransactionFilter.slip ||
      TransactionFilter.slipDeposit ||
      TransactionFilter.slipWithdraw =>
          _slip.fetch(slipType: filter.slipType!, limit: limit, cursor: cursor),
      TransactionFilter.cardDeposit =>
          _cardDeposit.fetch(limit: limit, cursor: cursor),
      TransactionFilter.cardWithdraw =>
          _cardWithdraw.fetch(limit: limit, cursor: cursor),
    };
  }

  void _invalidateAndNotify(TransactionEvent event) {
    _cache.invalidate();
    _events.add(event);
    debugPrint('[TransactionRepository] invalidate + emit ${event.runtimeType}');
  }
}
```

---

## 10. Action Skeletons (Deferred Split)

### 10.1 Trạng thái hiện tại (v3.3)

`cancelTransaction()` và `createComplain()` **đã được merge vào**
`TransactionRepository` (xem §9). Không tạo class `TransactionActionRepository`
riêng ở giai đoạn này.

**Lý do gộp:**
- Backend chưa confirm endpoint/params → 2 methods chỉ là skeleton, không có
  logic phức tạp đáng tách
- Giảm 1 file + 1 provider → khớp nguyên tắc "ít file nhất có thể"
- Caller chỉ cần 1 reference duy nhất: `transactionRepositoryProvider`

### 10.2 Refactor path (tương lai)

Khi nào nên tách thành `TransactionActionRepository` riêng?
- WRITE methods > 3 (mở rộng: retry, batch-cancel, dispute, refund...)
- Cần test WRITE riêng biệt mà không pull READ dependencies
- Có business logic phức tạp ở WRITE (validation, multi-step, rollback)

**Khi tách, design ban đầu (giữ để tham khảo):**

```dart
final class TransactionActionRepository {
  TransactionActionRepository({
    required SbHttpManager httpManager,
    required TransactionRepository transactionRepo,
  })  : _httpManager = httpManager,
        _repo = transactionRepo;

  final SbHttpManager _httpManager;
  final TransactionRepository _repo;

  /// Tách logic cancel/complain từ TransactionRepository sang đây.
  /// Sau success → gọi _repo.notifyMutation() / notifyComplainCreated()
  /// để READ side tự refresh.
  Future<void> cancelTransaction(String id) async { ... }
  Future<void> createComplain({...}) async { ... }
}

// Provider riêng
final transactionActionRepositoryProvider =
    Provider<TransactionActionRepository>((ref) =>
        TransactionActionRepository(
          httpManager: ref.watch(httpManagerProvider),
          transactionRepo: ref.watch(transactionRepositoryProvider),
        ));
```

### 10.3 Caller migration khi tách

Khi tách trong tương lai, caller chỉ cần đổi provider reference:

```dart
// Trước (v3.3 — hiện tại):
await ref.read(transactionRepositoryProvider)
    .cancelTransaction(transactionId);

// Sau (khi tách):
await ref.read(transactionActionRepositoryProvider)
    .cancelTransaction(transactionId);
```

Method signature giữ nguyên → low-effort refactor.

---

## 11. Riverpod Providers

```dart
// Repository — Singleton app-level (gộp READ + WRITE skeleton)
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) {
    final repo = TransactionRepository(
      httpManager: ref.watch(httpManagerProvider),
    );
    ref.onDispose(repo.dispose);
    return repo;
  },
  name: 'TransactionRepository',
);

// ⚠️ v3.3: KHÔNG có transactionActionRepositoryProvider —
//   cancel/complain gọi qua transactionRepositoryProvider (xem §10).

// Notifier — autoDispose + family theo filter (Phương án A)
//
// Mỗi (provider, filter) là một instance riêng. Đổi filter ở UI = render
// View khác = watch family key khác → instance cũ autoDispose, instance mới
// tạo + loadInitial. Cache trang đầu được Repository giữ per filter nên
// quay lại tab cũ trong 2 phút → cache HIT.
final transactionHistoryProvider = StateNotifierProvider.autoDispose
    .family<
        TransactionHistoryNotifier,
        PaginatedState<List<UnifiedTransaction>>,
        TransactionFilter>(
  (ref, filter) {
    final repo = ref.watch(transactionRepositoryProvider);
    return TransactionHistoryNotifier(repository: repo, filter: filter)
      .._initEventListener(ref)
      ..loadInitial();
  },
  name: 'TransactionHistoryNotifier',
);
```

### Sử dụng từ màn hình khác

```dart
// Sau khi nạp tiền NH/crypto/giftcode thành công:
ref.read(transactionRepositoryProvider)
   .notifySourceChanged(TransactionSource.paymentSlip);

// Sau khi nạp thẻ cào thành công:
ref.read(transactionRepositoryProvider)
   .notifySourceChanged(TransactionSource.cardDeposit);

// Sau khi rút thẻ thành công:
ref.read(transactionRepositoryProvider)
   .notifySourceChanged(TransactionSource.cardWithdraw);

// Huỷ giao dịch (v3.3 — gọi qua transactionRepositoryProvider):
await ref.read(transactionRepositoryProvider)
    .cancelTransaction(transactionId);

// Tạo complain:
await ref.read(transactionRepositoryProvider)
    .createComplain(transactionId: id, reason: 'Chưa nhận tiền');
```

### UI tab bar — visible filter list

```dart
final visibleFilters =
    TransactionFilter.values.where((f) => f.isVisible).toList();
// KHÔNG quên .toList() — .where trả Iterable
```

---

## 12. Notifier Design

```dart
class TransactionHistoryNotifier
    extends StateNotifier<PaginatedState<List<UnifiedTransaction>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<
          PaginatedTransactions,
          List<UnifiedTransaction>
        > {
  TransactionHistoryNotifier({
    required TransactionRepository repository,
    required TransactionFilter filter,
  }) : _repository = repository,
       _filter = filter,
       super(const PaginatedState.initial()) {
    _subscribeToEvents();
  }

  final TransactionRepository _repository;
  final TransactionFilter _filter;
  StreamSubscription<TransactionEvent>? _eventSubscription;

  final _errorController = StreamController<TransactionFailure>.broadcast();
  TransactionFailure? _failure;

  /// Stream of transaction failures, useful for UI one-off notifications (e.g. SnackBar/Toast).
  Stream<TransactionFailure> get errorEvents => _errorController.stream;

  /// The last transaction failure, useful for UI rendering detailed failure state.
  TransactionFailure? get failure => _failure;

  static const int _limit = 30;

  Future<void> initialize() {
    logInfo(
      'TransactionHistoryNotifier initialized with filter=${_filter.name}',
    );
    return loadInitial();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _errorController.close();
    logInfo('TransactionHistoryNotifier disposed filter=${_filter.name}');
    super.dispose();
  }

  @override
  Future<PaginatedTransactions> request([int? cursor]) {
    _failure = null; // Reset failure state before making a new request
    logDebug(
      'Requesting transaction history... | filter: ${_filter.name}, cursor (skip): $cursor, limit: $_limit',
    );
    return _repository.getTransactionsByFilter(
      filter: _filter,
      limit: _limit,
      cursor: cursor,
    );
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError(
      'Transaction request failed with filter=${_filter.name}',
      error,
      stackTrace,
    );

    final mappedFailure = error is TransactionFailure
        ? error
        : TransactionUnknownFailure(source: error);

    _failure = mappedFailure;
    _errorController.add(mappedFailure);
    
    // UI lắng nghe failure hoặc errorEvents để hiển thị giao diện báo lỗi chi tiết,
    // thay vì gán lỗi vào state làm mất đi dữ liệu pagination cũ của state.
  }

  @override
  Future<void> onInitialResponse(PaginatedTransactions response) async {
    logInfo(
      'Loaded initial transactions for filter=${_filter.name}. Count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.nextCursor,
      );
    }
  }

  @override
  Future<void> onRefreshResponse(PaginatedTransactions response) async {
    logInfo(
      'Refreshed transactions for filter=${_filter.name}. Count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.nextCursor,
      );
    }
  }

  @override
  Future<void> onMoreResponse(
    PaginatedTransactions response,
    List<UnifiedTransaction> data,
  ) async {
    logInfo(
      'Loaded more transactions for filter=${_filter.name}. Current count: ${data.length}, new count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    final newData = [...data, ...response.items];
    state = PaginatedState.withData(data: newData, cursor: response.nextCursor);
  }

  void _subscribeToEvents() {
    _eventSubscription = _repository.events.listen((event) {
      if (!mounted) return;

      bool shouldRefresh = false;

      if (event is TransactionCreatedEvent) {
        if (_filter.activeSources.contains(event.source)) {
          logInfo(
            'Received TransactionCreatedEvent for source=${event.source.name}. Triggering sync for filter=${_filter.name}',
          );
          shouldRefresh = true;
        }
      } else if (event is TransactionMutatedEvent ||
          event is TransactionCacheInvalidatedEvent ||
          event is ComplainCreatedEvent) {
        logInfo(
          'Received ${event.runtimeType}. Triggering sync for filter=${_filter.name}',
        );
        shouldRefresh = true;
      }

      if (shouldRefresh) {
        refresh(false); // keep showing old data while loading, preventing UI flickering
      }
    });
  }
}
```

---

## 13. UI Architecture (Phương án A)

### 13.1 Tổng quan

Tham chiếu mẫu UI: [`lib/features/betting/history/betting_history_screen.dart`](../../../features/betting/history/betting_history_screen.dart)
và [`lib/features/betting/history/betting_history_filter_menu.dart`](../../../features/betting/history/betting_history_filter_menu.dart).

**Phương án A với IndexedStack** — Lưu giữ trạng thái scroll của từng tab view riêng biệt bằng `IndexedStack`.

```
TransactionHistoryScreen (StatefulWidget)
  └── ProfileHubScaffold.withCenterTitle(
        title: I18n.txtTransactionHistory,
        body: Scaffold(
          appBar: TransactionHistoryFilterMenu(
            initialValue: _currentFilter,
            onChanged: (v) => _currentFilter = v,
          ),
          body: IndexedStack(
            index: currentIndex,
            children: [
              ActivityLogTransactionView(),
              SlipTransactionView(),
              CardDepositTransactionView(),
              CardWithdrawTransactionView(),
            ],
          ),
        ),
      )
```

> [!IMPORTANT]
> **Sự cố Staging API 404 & UI Temporary Hiding (Nút Xóa Lịch Sử):**
> Do endpoint `/gameapi/public/history/cleanup` sử dụng phương thức `GET` chưa được deploy trên Staging (`api.ezplace1.net`) dẫn đến lỗi 404, nút xóa lịch sử hoạt động ("Clear All") tạm thời đã được **ẩn (comment out) trên UI** ở file [transaction_history_screen.dart](file:///Users/admin/Documents/s88-flutter/lib/features/transaction/history/transaction_history_screen.dart).
>
> Khi Backend hoàn thành và deploy API này lên Staging, chỉ cần mở comment các phần code tương ứng trong file UI. Logic bên dưới (Repository, Data Source, API Service) đã hoạt động hoàn chỉnh.

**Lưu ý quan trọng:**
- UI chuyển sang dùng `IndexedStack` để giữ nguyên scroll controller của từng View thay vì dùng `ValueNotifier` switch body thuần.
- 4 View widget bên trong watch `transactionHistoryProvider(filter)` riêng qua family.
- `slipDeposit` / `slipWithdraw` cố ý ẩn (`isVisible=false`) → không xuất hiện trong menu bar.

### 13.2 TransactionHistoryFilterMenu (Thiết kế inline)

Nhằm tối giản hóa cấu trúc thư mục và giảm thiểu việc tạo quá nhiều file widget nhỏ không cần thiết, bộ menu lọc tab được triển khai trực tiếp (inline) trong `TransactionHistoryScreen` thông qua widget `StyledMenu<TransactionFilter>` dùng chung của dự án. 

Các bộ lọc hiển thị được giới hạn chỉ đối với các filter có thuộc tính `isVisible = true` (bao gồm `activityLog`, `slip`, `cardDeposit`, và `cardWithdraw`). Các filter ẩn như `slipDeposit` và `slipWithdraw` được tự động ẩn khỏi UI.

### 13.3 TransactionHistoryScreen

Màn hình chính sử dụng `IndexedStack` để giữ nguyên trạng thái cuộn (scroll controller) và `PageStorageKey` của từng tab view khi người dùng chuyển đổi qua lại.

Do API endpoint `/gameapi/public/history/cleanup` (GET) chưa được deploy trên môi trường Staging (`api.ezplace1.net`) dẫn đến lỗi 404, nút xóa lịch sử hoạt động ("Clear All") và logic liên quan tạm thời được **ẩn (comment out) trên UI** để đảm bảo code phân tích tĩnh (`No issues found!`) hoàn toàn sạch sẽ.

Mã nguồn thực tế tại `lib/features/transaction/history/transaction_history_screen.dart`:

```dart
import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
// import 'package:sun_sports/core/services/providers/transaction_provider.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
// import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/transaction/history/views/activity_log_transaction_view.dart';
import 'package:sun_sports/features/transaction/history/views/card_deposit_transaction_view.dart';
import 'package:sun_sports/features/transaction/history/views/card_withdraw_transaction_view.dart';
import 'package:sun_sports/features/transaction/history/views/slip_transaction_view.dart';
// import 'package:sun_sports/features/transaction/widgets/dialog_confirm_clear_history.dart';
import 'package:sun_sports/shared/profile_hub_system/profile_hub_system.dart';
import 'package:sun_sports/shared/widgets/menu/styled_menu.dart';
// import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

/// {@template transaction_history_screen}
/// Transaction History Screen v3.
///
/// Manages a filter selection bar using [StyledMenu] and stores child views
/// (`SlipTransactionView`, `CardDepositTransactionView`, `CardWithdrawTransactionView`)
/// inside an [IndexedStack] to perfectly preserve scroll position when the user
/// switches between transaction tabs (Approach A).
/// {@endtemplate}
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  /// Initializes [TransactionHistoryScreen].
  const TransactionHistoryScreen({super.key});

  /// Creates Route to the screen.
  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  TransactionFilter _currentFilter = TransactionFilter.activityLog;

  final List<TransactionFilter> _visibleFilters = TransactionFilter.values
      .where((f) => f.isVisible)
      .toList();

  String _getFilterLabel(TransactionFilter filter) {
    return switch (filter) {
      TransactionFilter.activityLog => 'Tất cả giao dịch',
      TransactionFilter.slip => 'Codepay/Crypto/Giftcode',
      TransactionFilter.cardDeposit => 'Nạp thẻ cào',
      TransactionFilter.cardWithdraw => 'Rút thẻ cào',
      _ => 'Khác',
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _visibleFilters.indexOf(_currentFilter);

    return ProfileHubScaffold.withCenterTitle(
      title: const Text(I18n.txtDepositAndWithdrawalHistory),
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: [
          const Gap(16),
          // Premium Menu Anchor Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StyledMenu<TransactionFilter>(
                  items: _visibleFilters,
                  configBuilder: (filter) =>
                      StyledMenuConfig(label: _getFilterLabel(filter)),
                  selectedValue: _currentFilter,
                  onChanged: (filter) {
                    setState(() {
                      _currentFilter = filter;
                    });
                  },
                  minWidth: 180.0,
                ),
                // Temporarily hide delete button due to backend API 404
                // if (_currentFilter == TransactionFilter.activityLog)
                //   _DeleteButton(onPressed: () => _handleClearAll(context, ref)),
              ],
            ),
          ),
          const Gap(8),
          // IndexedStack preserves scroll controller and PageStorageKey of each view
          Expanded(
            child: IndexedStack(
              index: currentIndex >= 0 ? currentIndex : 0,
              children: const [
                ActivityLogTransactionView(),
                SlipTransactionView(),
                CardDepositTransactionView(),
                CardWithdrawTransactionView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Temporarily commented out due to backend API 404
  // void _handleClearAll(BuildContext context, WidgetRef ref) async {
  //   final confirmed = await DialogConfirmClearHistory.show(context);
  //
  //   if (confirmed == true) {
  //     try {
  //       await ref.read(transactionRepositoryProvider).clearActivityLogs();
  //       // The repository emits MutatedEvent, which notifier listens to and refreshes.
  //     } catch (e) {
  //       if (context.mounted) {
  //         AppToast.showError(
  //           context,
  //           message: 'Xoá thất bại. Vui lòng thử lại.',
  //         );
  //       }
  //     }
  //   }
  // }
}

// Temporarily commented out due to backend API 404
// class _DeleteButton extends StatelessWidget {
//   const _DeleteButton({this.onPressed});
//
//   final VoidCallback? onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     final shape = RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     );
//
//     return SizedBox.square(
//       dimension: 40,
//       child: IconButton(
//         onPressed: onPressed,
//         // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         color: AppColorStyles.contentSecondary,
//         icon: const Icon(Icons.delete_outline_rounded),
//         // icon: ImageHelper.load(path: AppIcons.tras),
//         style: IconButton.styleFrom(
//           backgroundColor: AppColorStyles.backgroundQuaternary,
//           shape: shape,
//           iconSize: 24,
//         ),
//       ),
//     );
//   }
// }
```

### 13.4 Per-filter View widgets (Thiết kế độc lập)

Để đảm bảo hiệu năng cuộn tối ưu, cô lập việc quản lý `PageStorageKey` độc lập tuyệt đối giữa các tab, và cho phép tùy biến giao diện/hành vi cụ thể của từng tab (như xử lý nút "Nạp tiền ngay" trong Empty State), thiết kế thực tế **không sử dụng** widget dùng chung `_TransactionHistoryBody` như giả định cũ. 

Thay vào đó, mỗi View widget được định nghĩa riêng biệt trong một file riêng nhưng chia sẻ chung cấu trúc thiết kế chuẩn chỉ:
1. Đọc trạng thái data và `canLoadMore` từ `transactionHistoryProvider(filter)`.
2. Wrap trong `RefreshIndicator.adaptive` để thực hiện Pull-to-refresh (`notifier.refresh`).
3. Sử dụng `LoadMoreListener` để lắng nghe hành vi cuộn cuối trang (`notifier.loadMore`).
4. Dùng `CustomScrollView` với một `PageStorageKey` duy nhất để giữ nguyên vị trí cuộn khi đổi tab.
5. Render list giao dịch thông qua sliver `DateGroupedSliverList`.
6. Xử lý các trạng thái PaginatedStatus (`loading`, `noData`, `error`).

### 13.5 ActivityLogTransactionView

View này chịu trách nhiệm hiển thị Lịch sử hoạt động (Play History) - là tab mặc định hiển thị toàn bộ hoạt động biến động số dư.

Mã nguồn thực tế tại `lib/features/transaction/history/views/activity_log_transaction_view.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/transaction/transaction.dart';
import 'package:sun_sports/shared/animations/animations.dart';
import 'package:sun_sports/shared/listener/listener.dart';
import 'package:sun_sports/shared/profile_hub_system/profile_hub_system.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/slivers/slivers.dart';

/// {@template activity_log_transaction_view}
/// View for displaying all financial activities (Play History).
/// {@endtemplate}
class ActivityLogTransactionView extends ConsumerWidget {
  /// Initializes [ActivityLogTransactionView].
  const ActivityLogTransactionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TransactionFilter.activityLog;
    final state = ref.watch(transactionHistoryProvider(filter));
    final notifier = ref.read(transactionHistoryProvider(filter).notifier);

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await notifier.refresh();
      },
      child: LoadMoreListener(
        onLoadMore: notifier.loadMore,
        listen: state.canLoadMore,
        child: CustomScrollView(
          key: const PageStorageKey<String>('activity_log_scroll_key'),
          slivers: [
            const SliverToBoxAdapter(child: Gap(20)),
            Consumer(
              builder: (context, ref, _) {
                final data = ref.watch(
                  transactionHistoryProvider(filter).select((s) => s.data),
                );
                return DateGroupedSliverList(
                  data ?? [],
                  onItemPressed: (t) {
                    Navigator.of(
                      context,
                    ).push(TransactionDetailsScreen.route(t));
                  },
                );
              },
            ),

            Consumer(
              builder: (context, ref, _) {
                final status = ref.watch(
                  transactionHistoryProvider(filter).select((s) => s.status),
                );

                return switch (status) {
                  PaginatedStatus.loading => const SliverLoadingIndicator(),
                  PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
                  PaginatedStatus.noData => _SliverNoTransactionData(
                    onDepositPressed: () => _handleDepositPressed(context, ref),
                  ),
                  PaginatedStatus.error => SliverFillLoadingError(
                    message: const Text(I18n.msgSomethingWentWrong),
                    onRetry: notifier.loadInitial,
                  ),
                  _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
                };
              },
            ),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }

  void _handleDepositPressed(BuildContext context, WidgetRef ref) {
    ref.invalidate(configDepositProvider);
    unawaited(ref.read(configDepositProvider.future));

    final deviceType = ResponsiveBuilder.getDeviceType(context);
    if (deviceType == DeviceType.mobile) {
      DepositMobileBottomSheet.show(context);
    } else {
      ProfileHub.of(context).close();
      ref.read(depositOverlayVisibleProvider.notifier).state = true;
    }
  }
}

class _SliverNoTransactionData extends StatelessWidget {
  const _SliverNoTransactionData({this.onDepositPressed});

  final VoidCallback? onDepositPressed;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ImmediateOpacityAnimation(
        duration: Durations.short4,
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 160,
                child: ImageHelper.load(
                  path: AppImages.imgTransactionEmpty,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(48),
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                child: const Text(I18n.msgNoTransaction),
              ),
              const Gap(16),
              ShineButton(
                style: ShineButtonStyle.primaryYellow,
                text: I18n.msgDepositNow,
                onPressed: onDepositPressed,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 13.6 i18n keys thực tế đã sử dụng

Các khóa đa ngôn ngữ thực tế được sử dụng trong giao diện Lịch sử giao dịch:

```dart
class I18n {
  // Title màn hình chính
  static const txtDepositAndWithdrawalHistory = 'Lịch sử nạp rút';

  // Empty State & Errors
  static const msgNoTransaction = 'Không có lịch sử giao dịch';
  static const msgDepositNow = 'Nạp tiền ngay';
  static const msgSomethingWentWrong = 'Đã xảy ra lỗi';
}
```

### 13.7 Cấu trúc Files UI thực tế

Sơ đồ cây cấu trúc file thực tế được thiết lập cho phần giao diện lịch sử giao dịch:

```
lib/features/transaction/
└── history/
    ├── transaction_history.dart                  ← Barrel file re-export screen
    ├── transaction_history_notifier.dart         ← Quản lý phân trang cho view
    ├── transaction_history_provider.dart         ← Provider family
    ├── transaction_history_screen.dart           ← Màn hình chính (IndexedStack + StyledMenu)
    └── views/
        ├── activity_log_transaction_view.dart    ← Tab "Tất cả giao dịch" (Activity Log)
        ├── card_deposit_transaction_view.dart    ← Tab "Nạp thẻ cào"
        ├── card_withdraw_transaction_view.dart   ← Tab "Rút thẻ cào"
        └── slip_transaction_view.dart            ← Tab "Codepay/Crypto/Giftcode"
```

### 13.8 Trade-off của Phương án A (IndexedStack)

**Ưu điểm (Pros):**
- **Trải nghiệm mượt mà tuyệt đối:** Nhờ `IndexedStack`, khi chuyển đổi giữa các tab lọc, các scroll positions và widget state đều được bảo toàn 100% thay vì bị hủy và khởi tạo lại từ đầu.
- **Tính đóng gói cao:** Mỗi view quản lý riêng file của mình, độc lập về `PageStorageKey` và các xử lý nghiệp vụ cụ thể (ví dụ: tab Activity Log cho phép click nạp tiền, xoá lịch sử).
- **Riverpod Family Provider tối ưu:** Hệ thống tự động quản lý vòng đời của Notifier ứng với từng tab. Nếu tab đó không hiển thị, Riverpod sẽ tự động dispose notifier (nhờ `.autoDispose`) để tiết kiệm tài nguyên bộ nhớ nhưng dữ liệu cache trang đầu tại Repository vẫn được giữ lại.

**Nhược điểm (Cons):**
- Có sự lặp lại nhẹ (boilerplate) về khung CustomScrollView và các Loading/Empty states ở 4 file View. Tuy nhiên, việc lặp lại này là hoàn toàn đáng đánh đổi để đổi lấy khả năng bảo trì độc lập và tối ưu hóa hiệu năng cuộn của Flutter.


---

## 14. Full Sync Flow

```
═══════════════════════════════════════════════════════
[1] MỞ MÀN HÌNH TRANSACTION HISTORY
═══════════════════════════════════════════════════════

Provider tạo TransactionHistoryNotifier
  → _initEventListener() subscribe events
  → loadInitial() gọi request(cursor: null)

Repository.getTransactionsByFilter(filter: slip, cursor: null)
  → cache.getFirstPage(slip) → MISS
  → _dispatch(slip) → PaymentSlipDataSource.fetch(slipType=0, skip=0)
    → httpManager.getTransactionSlipHistory(skip=0, limit=10, slipType=0)
    → response: count=23, items=10
    → TransactionMapper.fromPaymentSlip() × 10
    → PaginatedTransactions(items:10, nextCursor:10, isLastPage:false)
  → cache.setFirstPage(slip, result)

Notifier.onInitialResponse:
  → state = withData(data: 10 items, cursor: 10)


═══════════════════════════════════════════════════════
[2] USER SCROLL XUỐNG (LOAD MORE)
═══════════════════════════════════════════════════════

Notifier.loadMore() → request(cursor: 10)
Repository skip cache (cursor != null)
  → PaymentSlipDataSource.fetch(slipType=0, skip=10)
  → response: 10 items more

Notifier.onMoreResponse:
  → all = old(10) + new(10) = 20 items, sort DESC
  → state = withData(data: 20 items, cursor: 20)


═══════════════════════════════════════════════════════
[3] USER ĐỔI TAB → "NẠP THẺ" (Phương án A)
═══════════════════════════════════════════════════════

User tap option "Nạp thẻ" trên TransactionHistoryFilterMenu
  → _filterNotifier.value = cardDeposit
  → ValueListenableBuilder rebuild
  → switch case match cardDeposit → CardDepositTransactionView()

Widget cũ (SlipTransactionView):
  → unmount → không còn watcher của transactionHistoryProvider(slip)
  → family instance (slip) autoDispose
  → cache trang đầu (slip) vẫn được Repository giữ — chỉ Notifier mất

Widget mới (CardDepositTransactionView):
  → ref.watch(transactionHistoryProvider(cardDeposit))
  → family instance (cardDeposit) tạo mới
  → constructor: TransactionHistoryNotifier(filter: cardDeposit)
  → _initEventListener + loadInitial()

Repository.getTransactionsByFilter(filter: cardDeposit, cursor: null)
  → cache.getFirstPage(cardDeposit) → MISS (lần đầu tab này)
  → CardDepositDataSource.fetch(skip=0)
  → response: count=1, items=1 → isLastPage=true
  → cache.setFirstPage(cardDeposit, result)

CardDepositTransactionView render với 1 item


═══════════════════════════════════════════════════════
[4] MÀN HÌNH NẠP THẺ: NẠP THÀNH CÔNG
═══════════════════════════════════════════════════════

DepositScreen success:
  ref.read(transactionRepositoryProvider)
     .notifySourceChanged(TransactionSource.cardDeposit)

Repository._invalidateAndNotify(TransactionCreatedEvent(cardDeposit))
  → cache.invalidate()   ← xóa tất cả cache
  → events.add(event)

Notifier nhận event (chỉ instance ĐANG MOUNTED — autoDispose):
  → Nếu user đang ở tab cardDeposit:
    transactionHistoryProvider(cardDeposit) instance còn tồn tại
    → TransactionCreatedEvent(source: cardDeposit)
    → filter.activeSources.contains(cardDeposit) == true → refresh()

  → Nếu user đang ở tab khác (vd: slip):
    transactionHistoryProvider(slip) instance — filter=slip
    → filter.activeSources.contains(cardDeposit) == false → noop
    Khi user quay lại tab cardDeposit sau đó:
      family instance mới tạo → loadInitial → cache MISS (đã bị invalidate)
      → re-fetch → thấy giao dịch mới

Notifier.refresh() (trường hợp đang ở tab):
  → repository.invalidateAll() (redundant nhưng safe)
  → loadInitial() lại từ skip=0
  → UI cập nhật với giao dịch mới nhất


═══════════════════════════════════════════════════════
[5] USER PULL-TO-REFRESH
═══════════════════════════════════════════════════════

Notifier.refresh()
  → repository.invalidateAll()
  → loadInitial()


═══════════════════════════════════════════════════════
[6] USER QUAY LẠI TAB "SLIP" (cache còn hạn)
═══════════════════════════════════════════════════════

User tap "Slip" trên filter menu
  → _filterNotifier.value = slip
  → CardDepositTransactionView unmount → family instance (cardDeposit) autoDispose
  → SlipTransactionView mount → watch transactionHistoryProvider(slip)
  → family instance (slip) tạo mới → loadInitial → request(cursor: null)

Repository:
  → cache.getFirstPage(slip) → HIT (nếu < 2 phút TTL)
  → return cached immediately ← không gọi API

UI hiển thị ngay, không loading

⚠️  Note: tuy Notifier instance mới được tạo mỗi lần đổi tab, cache trang đầu
   của Repository (singleton app-level) vẫn giữ → UX vẫn nhanh.


═══════════════════════════════════════════════════════
[7] LOGOUT
═══════════════════════════════════════════════════════

repository.invalidateAll()
  → cache.invalidate()
  → events.add(TransactionCacheInvalidatedEvent)
repository.dispose() (ref.onDispose)
  → events.close()
```

### Quy tắc cursor

```
cursor = null   → trang đầu (skip=0)
                  → check cache trước
                  → write cache sau fetch
                  → Notifier gọi khi: loadInitial, setFilter, refresh

cursor = int    → trang sau (skip=cursor)
                  → bỏ qua cache hoàn toàn
                  → Notifier gọi khi: loadMore

nextCursor = null → isLastPage = true → Notifier dừng loadMore
```

### Edge cases

**Đổi filter khi đang ở page 2 (Phương án A):**

```
✅ Tự động an toàn:
   User ở slip page 2 (cursor=10) — instance Notifier(filter=slip)
   Đổi sang cardDeposit
   → Notifier(slip) autoDispose, mất state (cursor=10)
   → Notifier(cardDeposit) mới tạo, state.initial → loadInitial → cursor=null

   Không có chance request(cursor=10) cho cardDeposit vì là 2 instance khác nhau.
```

**Cache của filter khác không bị ảnh hưởng (theo design):**

```
User nạp thẻ thành công
→ notifySourceChanged(cardDeposit) → cache.invalidate() (xóa tất cả)
→ Notifier refresh tab cardDeposit

User quay lại slip tab
→ cache MISS → re-fetch → đúng behavior (safe)

Alternative tối ưu: invalidateFilter(...) theo source nếu cần.
```

---

## 15. Testing

### 15.1 Nguyên tắc

```
Unit test:        DataSource, Mapper, Cache, Repository routing, Aggregator
Integration test: Notifier + Repository + mock DataSource
Widget test:      Filter tab bar, list render, error/empty states

Mock strategy:
  DataSource  → mock trực tiếp, inject vào Repository
  HttpManager → mock cho DataSource tests
  Cache       → dùng InMemoryTransactionCache với ttl=0 để test expire
  Stream      → dùng StreamController thật, đóng trong tearDown
```

### 15.2 DataSource tests (sample)

```dart
group('PaymentSlipDataSource', () {
  late MockSbHttpManager mockHttp;
  late PaymentSlipDataSource dataSource;

  setUp(() {
    mockHttp = MockSbHttpManager();
    dataSource = PaymentSlipDataSource(mockHttp);
  });

  test('page 1: nextCursor=10 khi còn data', () async {
    when(() => mockHttp.getTransactionSlipHistory(
          skip: 0, limit: 10, slipType: 0))
        .thenAnswer((_) async => _fakeResponse(count: 23, itemCount: 10));

    final result = await dataSource.fetch(slipType: 0, limit: 10);

    expect(result.isLastPage, false);
    expect(result.nextCursor, 10);
    expect(result.items.length, 10);
  });

  test('slipType đọc từ response — không hardcode', () async {
    final fakeTransaction = Transaction(
      id: 1, amount: 100000, status: 2, type: 1,
      slipType: 1, // ← 1 = deposit
      ...
    );
    when(() => mockHttp.getTransactionSlipHistory(...))
        .thenAnswer((_) async => _fakeResponseWith([fakeTransaction]));

    final result = await dataSource.fetch(slipType: 0);

    expect(result.items.first.slipType, TransactionSlipType.deposit);
  });

  test('SocketException → TransactionNetworkFailure', () async {
    when(() => mockHttp.getTransactionSlipHistory(...))
        .thenThrow(const SocketException('no connection'));

    expect(() => dataSource.fetch(slipType: 0),
      throwsA(isA<TransactionNetworkFailure>()));
  });

  test('SunApiException → TransactionServerFailure với statusCode', () async {
    when(() => mockHttp.getTransactionSlipHistory(...))
        .thenThrow(SunApiException(statusCode: 500, message: 'Server error'));

    expect(() => dataSource.fetch(slipType: 0),
      throwsA(isA<TransactionServerFailure>()
          .having((e) => e.statusCode, 'statusCode', 500)));
  });

  test('TypeError → TransactionParseFailure với đúng source', () async {
    when(() => mockHttp.getTransactionSlipHistory(...)).thenThrow(TypeError());

    expect(() => dataSource.fetch(slipType: 0),
      throwsA(isA<TransactionParseFailure>()
          .having((e) => e.source, 'source', TransactionSource.paymentSlip)));
  });
});
```

### 15.3 TransactionMapper tests (sample)

```dart
group('TransactionMapper', () {
  test('fromPaymentSlip: slipType=1 → deposit (fix v2 bug)', () {
    final t = Transaction(slipType: 1, ...);
    expect(TransactionMapper.fromPaymentSlip(t).slipType,
        TransactionSlipType.deposit);
  });

  test('fromPaymentSlip: slipType=2 → withdraw', () {
    final t = Transaction(slipType: 2, ...);
    expect(TransactionMapper.fromPaymentSlip(t).slipType,
        TransactionSlipType.withdraw);
  });

  test('fromCardDeposit: dùng serial làm id', () {
    final raw = {'serial': 'SN123', 'code': '6884***60528', ...};
    expect(TransactionMapper.fromCardDeposit(raw).id, 'SN123');
  });

  test('fromCardDeposit: fallback sang code nếu không có serial', () {
    final raw = {'code': 'CODE001', ...};
    expect(TransactionMapper.fromCardDeposit(raw).id, 'CODE001');
  });

  // ── fromCardWithdraw — schema verified (v3.5) ────────────

  /// Fixture từ staging response 2026-05-20.
  /// Source of truth verbatim: §2.5.1 — raw log line + cleaned JSON.
  /// Khi update fixture này → đối chiếu §2.5.1, KHÔNG sửa silent.
  Map<String, dynamic> get _cardWithdrawFixture => {
    'id': '6a0d66ad6da139349b049743',
    'userId': 347540704,
    'requestTime': 1779263149281,
    'responseTime': 1779263661328,
    'status': 2,
    'description': 'Đã trả thưởng',
    'displayName': 'unterweg',
    'result': {
      'code': 917764483910024,
      'serial': 10011405735987,
    },
    'item': {
      'amount': 50000,
      'price': 50000,
      'displayName': 'Viettel 50k',
      'telcoId': 1,
    },
  };

  test('fromCardWithdraw: dùng id (MongoDB ObjectID) làm id', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.id, '6a0d66ad6da139349b049743');
  });

  test('fromCardWithdraw: amount từ item.amount nested', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.amount, 50000);
  });

  test('fromCardWithdraw: transactionCode từ result.code (int → toString)', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.transactionCode, '917764483910024');
  });

  test('fromCardWithdraw: status int 2 → success', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.status, TransactionStatus.success);
  });

  test('fromCardWithdraw: statusDescription từ description (Tiếng Việt)', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.statusDescription, 'Đã trả thưởng');
  });

  test('fromCardWithdraw: sortTime từ responseTime', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.sortTime.millisecondsSinceEpoch, 1779263661328);
  });

  test('fromCardWithdraw: source + slipType const', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.source, TransactionSource.cardWithdraw);
    expect(tx.slipType, TransactionSlipType.withdraw);
    expect(tx.paymentMethod, TransactionPaymentMethod.card);
  });

  test('fromCardWithdraw: amount fallback item.price khi không có amount', () {
    final raw = Map<String, dynamic>.from(_cardWithdrawFixture)
      ..['item'] = {'price': 100000};
    expect(TransactionMapper.fromCardWithdraw(raw).amount, 100000);
  });

  test('fromCardWithdraw: result null → transactionCode rỗng (defensive)', () {
    final raw = Map<String, dynamic>.from(_cardWithdrawFixture)
      ..remove('result');
    final tx = TransactionMapper.fromCardWithdraw(raw);
    expect(tx.transactionCode, '');
  });

  test('fromCardWithdraw: rawData giữ nguyên', () {
    final tx = TransactionMapper.fromCardWithdraw(_cardWithdrawFixture);
    expect(tx.rawData, _cardWithdrawFixture);
  });

  test('parseSortTime: milliseconds (>10^10)', () {
    final raw = {'responseTime': 1716000000000};
    expect(TransactionMapper.parseSortTime(raw).millisecondsSinceEpoch,
        1716000000000);
  });

  test('parseSortTime: seconds (<10^10) → nhân 1000', () {
    final raw = {'responseTime': 1716000000};
    expect(TransactionMapper.parseSortTime(raw).millisecondsSinceEpoch,
        1716000000000);
  });

  test('status=11 → pending (legacy code)', () { ... });
  test('status=12 → success (bonus code)', () { ... });
});
```

### 15.4 InMemoryTransactionCache tests

```dart
group('InMemoryTransactionCache', () {
  test('set rồi get → trả về đúng data', () { ... });
  test('get filter khác → null (isolation)', () { ... });

  test('TTL hết hạn → trả null', () async {
    final cache = InMemoryTransactionCache(
        ttl: const Duration(milliseconds: 10));
    cache.setFirstPage(TransactionFilter.slip, mockPage);
    await Future.delayed(const Duration(milliseconds: 20));
    expect(cache.getFirstPage(TransactionFilter.slip), null);
  });

  test('invalidate → tất cả filter đều null', () { ... });
  test('invalidateFilter → chỉ xóa đúng filter', () { ... });
});
```

### 15.5 Repository routing tests

```dart
group('TransactionRepository routing', () {
  test('filter=slip → gọi PaymentSlipDataSource với slipType=0', () async {
    await repo.getTransactionsByFilter(filter: TransactionFilter.slip);
    verify(() => mockSlip.fetch(slipType: 0, limit: 10, cursor: null))
        .called(1);
    verifyNever(() => mockCardDeposit.fetch());
  });

  test('cache hit → không gọi DataSource', () async {
    repo.cache.setFirstPage(TransactionFilter.slip, mockPage);
    await repo.getTransactionsByFilter(filter: TransactionFilter.slip);
    verifyNever(() => mockSlip.fetch());
  });

  test('cursor != null → skip cache', () async {
    repo.cache.setFirstPage(TransactionFilter.slip, cachedPage);
    final result = await repo.getTransactionsByFilter(
        filter: TransactionFilter.slip, cursor: 10);
    expect(result, isNot(cachedPage));
    verify(() => mockSlip.fetch(slipType: 0, limit: 10, cursor: 10)).called(1);
  });

  test('notifySourceChanged(cardDeposit) → emit TransactionCreatedEvent',
      () async {
    final events = <TransactionEvent>[];
    final sub = repo.events.listen(events.add);

    repo.notifySourceChanged(TransactionSource.cardDeposit);

    await Future.delayed(Duration.zero);
    expect(events.first, isA<TransactionCreatedEvent>()
        .having((e) => e.source, 'source', TransactionSource.cardDeposit));
    await sub.cancel();
  });

  test('notifyMutation → emit + invalidate', () async {
    repo.cache.setFirstPage(TransactionFilter.slip, mockPage);
    repo.notifyMutation();
    expect(repo.cache.getFirstPage(TransactionFilter.slip), null);
  });
});
```

### 15.6 Notifier integration tests

```dart
test('TransactionCreatedEvent đúng source → refresh', () async {
  final controller = StreamController<TransactionEvent>.broadcast();
  when(() => mockRepo.events).thenAnswer((_) => controller.stream);
  // ... setup, emit event, verify refresh called
});

test('TransactionCreatedEvent sai source → không refresh', () async {
  // filter = slip, event source = cardDeposit → không refresh
});

test('setFilter → reset về trang đầu', () async {
  await notifier.setFilter(TransactionFilter.cardDeposit);
  verify(() => mockRepo.getTransactionsByFilter(
        filter: TransactionFilter.cardDeposit,
        limit: 10, cursor: null)).called(1);
});

test('loadMore → merge + sort DESC', () async {
  // Initial: t2 (9:00)
  // LoadMore: t1 (10:00), t3 (8:00)
  // Expected sort: [t1, t2, t3]
});
```

### 15.7 Manual test checklist

| # | Test case | Expected |
|---|---|---|
| 1 | Mở màn hình | Không crash, hiện loading |
| 2 | Account không giao dịch | Empty state |
| 3 | Account có giao dịch | List sort DESC theo ngày |
| 4 | Scroll cuối | loadMore trigger, items append |
| 5 | Scroll cuối khi hết | Không load thêm |
| 6 | Pull-to-refresh | Fetch lại từ đầu |
| 7 | Mở lần 2 trong 2 phút | Cache HIT, không network |
| 8 | Mở sau 2 phút | Fetch lại |
| 9 | setFilter(cardDeposit) | Chỉ hiện card deposit |
| 10 | Nạp xong → quay lại History | Auto refresh, thấy giao dịch mới |
| 11 | Tắt mạng → mở | Hiện error state với retry |

---

## 16. Debug Guide

### 16.1 Log tags

```
[TransactionRepository]      → routing, cache hit/miss, events
[PaymentSlipDataSource]      → fetch params, response count
[CardDepositDataSource]      → fetch params, response count
[CardWithdrawDataSource]     → fetch params, response count
[DepositComplainsDataSource] → fetch params, response count
[TransactionRepository]      → cancel, complain actions (cùng tag với READ — log line đủ rõ qua method name)
TransactionHistoryNotifier   → LoggerMixin tự xử lý
```

### 16.2 Checklist debug theo triệu chứng

**Màn hình trống / không load data:**

```
□ Log có [TransactionRepository] dispatch? Không → Notifier chưa gọi request()
□ Log có [PaymentSlipDataSource] fetch? Không → cache HIT, kiểm tra stale
□ response items.length == 0? → state = PaginatedState.empty()
□ state.error != null → xem userMessage
```

**Data hiển thị sai (nhầm loại giao dịch):**

```
□ Log [PaymentSlipDataSource] fetch slipType=X — đúng (0/1/2)?
□ TransactionMapper.fromPaymentSlip — t.slipType đọc từ response, KHÔNG hardcode
□ Dùng rawData trong chi tiết để so sánh raw vs mapped
```

**Load more không hoạt động:**

```
□ state.cursor sau initial: null = isLastPage = true → đúng behavior
□ PaginatedNotifierMixin.hasMore flag
□ UI scroll listener có trigger loadMore() không?
```

**Refresh không cập nhật:**

```
□ Sau refresh() phải thấy log cache MISS
□ Nếu thấy HIT → invalidate chưa gọi
□ Kiểm tra event flow: notifySourceChanged(cardDeposit)
  → invalidate → emit event → Notifier refresh
```

**Tab bar hiển thị filter ẩn:**

```
□ TransactionFilter.slipDeposit.isVisible phải false
□ UI: TransactionFilter.values.where((f) => f.isVisible).toList()
```

**Stream event không nhận được:**

```
□ Notifier đã disposed (autoDispose)?
□ sub.cancel() trong ref.onDispose?
□ events stream phải broadcast (StreamController.broadcast())
```

### 16.3 rawData debug flow

```dart
// Trong TransactionListTile hoặc Details screen (debug mode only)
if (kDebugMode && transaction.rawData != null) {
  debugPrint('=== RAW DATA [${transaction.source.name}] ===');
  debugPrint(const JsonEncoder.withIndent('  ')
      .convert(transaction.rawData));
  debugPrint('=== MAPPED ===');
  debugPrint('  slipType: ${transaction.slipType}');
  debugPrint('  status: ${transaction.status}');
  debugPrint('  sortTime: ${transaction.sortTime}');
  debugPrint('  paymentMethod: ${transaction.paymentMethod}');
}
```

---

## 17. Migration v2 → v3

### 17.1 Những gì GIỮ LẠI nguyên

```
✅ UnifiedTransaction model (freezed) — chỉ đổi source enum values
✅ unified_transaction.freezed.dart — regenerate sau đổi enum
✅ InMemoryTransactionCache — thêm invalidateFilter()
✅ TransactionMapper — sửa fromPaymentSlip + thêm fromCardDeposit/Withdraw
✅ PaginatedNotifierMixin — giữ nguyên hoàn toàn
✅ PaginatedState — giữ nguyên
✅ TransactionAggregator — giữ, không dùng flow chính nhưng sẵn sàng
✅ AggregatedPage, SourceResult — giữ
✅ RequestLock, LoggerMixin — giữ
```

### 17.2 Những gì THAY ĐỔI

```
🔄 TransactionSource enum:
   Xóa: depositComplains, bankWithdraw
   Đổi tên: (giữ cardDeposit, cardWithdraw)
   Thêm: paymentSlip

🔄 TransactionFilter enum:
   Xóa: all, deposit, withdraw
   Thêm: slip, cardDeposit, cardWithdraw, slipDeposit (hidden), slipWithdraw (hidden)

🔄 TransactionFilterX extension:
   activeSources: mỗi filter chỉ 1 source
   Thêm: slipType, isVisible

🔄 TransactionRepository:
   Xóa: getAggregatedTransactions, _fetchFromSource, _fetchDepositComplains (public)
   Thêm: DataSource fields, getTransactionsByFilter, event stream
   Thêm invalidation API (3 method gọn):
     - notifySourceChanged(source)   ← cho create deposit/withdraw
     - notifyMutation()              ← cho cancel/retry
     - notifyComplainCreated()       ← cho depositComplains
     - invalidateAll()               ← logout / force refresh
   Giữ: getTransactions (legacy), cache logic

🔄 TransactionHistoryNotifier:
   Thêm: filter param trong constructor (immutable, inject từ family key)
   Xóa: setFilter() — không cần với Phương án A
   Xóa: _exhaustedSources
   Đổi: request() dùng getTransactionsByFilter thay vì getAggregatedTransactions
   Thêm: _initEventListener()
   Thêm: onRefreshResponse override

🔄 Riverpod Provider (transactionHistoryProvider):
   Đổi: StateNotifierProvider.autoDispose → autoDispose.family<...,TransactionFilter>
   Lifecycle: mỗi filter key có instance riêng, autoDispose khi widget unmount

🔄 TransactionHistoryScreen:
   Rewrite hoàn toàn theo Phương án A:
     - ValueNotifier<TransactionFilter> local (không phải Riverpod state)
     - appBar = TransactionHistoryFilterMenu (PreferredSizeWidget)
     - body = ValueListenableBuilder → switch ra 3 View widgets riêng

🔄 TransactionMapper:
   Đổi: fromBankWithdraw → fromPaymentSlip (fix slipType bug)
   Thêm: fromCardDeposit, fromCardWithdraw (dùng _fromCardSlip helper)
   Thêm: case 11 → pending trong _parseStatus

🔄 transaction_failure.dart:
   GetTransactionsFailure → giữ cho legacy
   Thêm: sealed class hierarchy đầy đủ
```

### 17.3 Những gì THÊM MỚI

```
➕ PaymentSlipDataSource       ← file mới
➕ CardDepositDataSource        ← file mới
➕ CardWithdrawDataSource       ← file mới
➕ DepositComplainsDataSource   ← file mới (standalone)
➕ transaction_event.dart       ← sealed events
➕ paginated_transactions.dart  ← thay thế PaginatedTransactions trong repo

🚫 KHÔNG tạo (v3.3):
   TransactionActionRepository — gom cancel/complain vào TransactionRepository
                                  (xem §10 deferred split rationale)
```

### 17.4 Thứ tự implement an toàn

```
Bước 1: Models (không phá UI)
  └── Thêm TransactionSource.paymentSlip
  └── Thêm TransactionFilter.slip/cardDeposit/cardWithdraw + isVisible/slipType
  └── Cập nhật TransactionFilterX.activeSources

Bước 2: Infrastructure (không phá business logic)
  └── Tạo PaginatedTransactions model
  └── Tạo TransactionEvent sealed class
  └── Mở rộng TransactionFailure sealed class
  └── Thêm invalidateFilter() vào cache

Bước 3: DataSources (code mới, không đụng cũ)
  └── PaymentSlipDataSource
  └── CardDepositDataSource
  └── CardWithdrawDataSource
  └── DepositComplainsDataSource

Bước 4: Mapper  ⚠️  ÁP DỤNG §4.6 NGUYÊN TẮC 1+2
  └── 4a. COMMIT CHECKPOINT trước: copy transaction_mapper.dart hiện tại
       + transaction_extension.dart sang vị trí mới, KHÔNG sửa nội dung.
       Commit message: "checkpoint: backup mapper before v3 refactor (§4.6)"
  └── 4b. Đổi fromBankWithdraw → fromPaymentSlip — chỉ fix bug hardcode slipType,
       GIỮ NGUYÊN tất cả case parseStatus/parsePaymentMethod
  └── 4c. Thêm fromCardDeposit, fromCardWithdraw — chỉ ADD case mới, không
       sửa case có sẵn
  └── 4d. Verify case 11 → pending còn nguyên (từ legacy TransactionX)
  └── 4e. Mỗi public method/class có DartDoc theo template §4.6 Nguyên tắc 3

Bước 5: Repository
  └── Thêm DataSource fields
  └── Thêm getTransactionsByFilter
  └── Thêm event stream + invalidation API
  └── Thêm cancel/complain SKELETON (chưa wire backend — TODO)
  └── (giữ getAggregatedTransactions cho backward compat tạm thời)

Bước 6: Notifier (Phương án A)
  └── Constructor nhận `filter: TransactionFilter` immutable
  └── BỎ setFilter() — không cần
  └── BỎ _exhaustedSources
  └── Đổi request() sang getTransactionsByFilter (dùng `filter` final field)
  └── Thêm _initEventListener — chỉ refresh khi event source match filter

Bước 7: Provider + UI (Phương án A)
  └── Provider: đổi sang StateNotifierProvider.autoDispose.family<...,TransactionFilter>
  └── i18n: thêm 4 keys vào I18n class (xem §13.6)
  └── Component mới: TransactionHistoryFilterMenu (clone BettingHistoryFilterMenu)
       + TransactionFilterLabelX extension cho .label
  └── Rewrite TransactionHistoryScreen với pattern Phương án A:
       - ValueNotifier<TransactionFilter> local
       - Body switch theo filter → 3 View widgets
  └── Tạo 3 View widget mới: SlipTransactionView, CardDepositTransactionView,
       CardWithdrawTransactionView (mỗi cái 5 dòng)
  └── Tạo _TransactionHistoryBody (private shared) — render PaginatedState

Bước 8: Cleanup
  └── Xóa getAggregatedTransactions nếu không còn dùng
  └── Xóa old TransactionSource values nếu không còn reference
  └── Xóa folder spec/ + conductor/transaction-history-multi-source.md
       + transaction-history-technical-doc.md (file này là source of truth)
  └── Regenerate freezed
  └── Chạy toàn bộ test
```

### 17.5 Pre-implement Decision Points

```
[A] UX với PM:
    Filter labels "Slip / Nạp thẻ / Rút thẻ" vs giữ "Tất cả / Nạp / Rút"?
    → Nếu giữ semantic cũ → spec vẫn dùng được nhưng cần đổi tab labels
      và cân nhắc gộp paymentSlip với cardDeposit/cardWithdraw cho tab Nạp
      (lúc đó cần TransactionAggregator trong flow chính)

[B] Backend confirm API:
    - cancelTransaction endpoint + params
    - createComplain endpoint + form fields
    - ✅ lichsudt response schema — Verified v3.5, documented §2.3
    - fetchCardHistory (cardDeposit) response schema — chờ data thực
    - fetchDepositComplains response schema — chờ data thực
    - Telco brand mapping (telcoId 2/3/4/5)

[C] Codebase compile check (§4.5):
    - PaginatedNotifierMixin signature (1 hay 2 type params?)
    - LoggerMixin có tồn tại + method tên gì?
    - SunApiException.userFriendlyMessage có không?
    - PaginatedState constructors khớp signature?

[D] Cross-screen sync priority:
    - Có yêu cầu nạp xong refresh history ngay trong sprint tới?
    - Nếu KHÔNG → v2 hiện tại đủ dùng, hoãn migration
    - Nếu CÓ → bắt buộc migrate vì v2 không có cơ chế này
```

---

## 18. Roadmap

### 18.1 Bật slipDeposit / slipWithdraw

```
Effort: XS — 5 phút

Thay đổi DUY NHẤT:
  TransactionFilter.slipDeposit:  isVisible → true
  TransactionFilter.slipWithdraw: isVisible → true

Logic đã hoàn toàn sẵn:
  slipType=1/2 đã được map
  DataSource đã nhận slipType động
  Notifier không cần sửa
```

### 18.2 Tích hợp depositComplains vào UI

```
Effort: M

Option A — Tab riêng:
  1. Thêm TransactionSource.depositComplains
  2. Thêm TransactionFilter.depositComplains (isVisible: true)
  3. Thêm case vào _dispatch trong Repository
  4. Notifier handle ComplainCreatedEvent → refresh nếu đang ở tab này

Option B — Gộp vào filter slip:
  1. Thêm TransactionSource.depositComplains vào slip.activeSources
  2. _dispatch cần multi-source → tái dùng TransactionAggregator
  3. Notifier nhận TransactionCreatedEvent(depositComplains) → refresh slip

Cần hỏi team: depositComplains hiển thị chung hay tab riêng?
```

### 18.3 Cancel transaction

```
Effort: S (skeleton đã có)

1. Confirm API endpoint + params với backend
2. Điền httpManager call vào TransactionRepository.cancelTransaction() (§9 skeleton)
3. UI: thêm button Cancel trên giao dịch có status = processing
4. Gọi: ref.read(transactionRepositoryProvider).cancelTransaction(id)
5. Handle TransactionActionFailure → show snackbar lỗi
6. Cân nhắc tách sang TransactionActionRepository nếu WRITE mở rộng (§10.2)
```

### 18.4 Tạo Complain từ UI

```
Effort: S-M

1. Confirm API endpoint + form fields
2. Điền httpManager call vào TransactionRepository.createComplain() (§9 skeleton)
3. UI: thêm form/bottom sheet tạo complain
4. Sau success → confirm + navigate đến tab depositComplains
```

### 18.5 Real-time updates (WebSocket)

```
Effort: L

Khi có WS push về giao dịch mới:
  1. Service nhận WS event
  2. Gọi transactionRepo.notifySourceChanged(...) hoặc notifyMutation()
  3. Notifier tự refresh

Không cần sửa Repository/Notifier — đã thiết kế cho event-driven.
Chỉ cần thêm WS service layer.
```

### 18.6 Tách TransactionActionRepository (deferred từ v3.3)

```
Effort: S — tách method từ TransactionRepository sang class mới

Trigger: WRITE methods > 3, hoặc cần test WRITE riêng biệt

Steps:
  1. Tạo file lib/core/services/repositories/transaction_repository/
     transaction_action_repository.dart
  2. Extract cancelTransaction + createComplain (+ WRITE methods mới) sang class này
  3. Inject TransactionRepository qua constructor để gọi notifyMutation /
     notifyComplainCreated
  4. Tạo transactionActionRepositoryProvider
  5. Update callsite: transactionRepositoryProvider → transactionActionRepositoryProvider
     (signature method giữ nguyên → search-replace đơn giản)
  6. Xóa cancel/complain methods khỏi TransactionRepository

Design pattern đã lưu sẵn trong §10.2 — copy-paste vào file mới.
```

### 18.7 Phase 4 — Schema Refinement

```
Khi nhận được data thực từ backend:

1. Mở rawData log trên device thực/staging
2. So sánh từng field với TransactionMapper
3. Cập nhật:
   └── _parseStatus: thêm/sửa mapping code → TransactionStatus
   └── _parsePaymentMethod: thêm/sửa code → TransactionPaymentMethod
   └── sortTime: xác nhận field name và unit (ms hay s?)
   └── cardWithdraw (lichsudt): xác nhận schema thực

4. Viết test với data thực
5. Xóa rawData khỏi production build (chỉ giữ khi kDebugMode)
```

---

## 19. Known Issues & TODOs

| # | Vấn đề | Severity | Action |
|---|---|---|---|
| 1 | ~~`lichsudt` schema chưa xác nhận~~ ✅ Verified v3.5 | Done | Schema documented §2.3, mapper §6.4. Telco mapping (telcoId 2/3/4/5) còn ⚠️ |
| 1b | `fetchCardHistory` (cardDeposit) schema chưa verify | Medium | Log rawData trên staging tiếp theo, update §6.4 fromCardDeposit |
| 2 | `fetchDepositComplains` schema chưa đủ | Medium | Review khi tích hợp UI |
| 3 | `cancelTransaction` API chưa có | Low | Chờ backend confirm |
| 4 | `createComplain` API chưa có | Low | Chờ backend confirm |
| 5 | invalidateAll() xóa hết cache mọi filter | Low | Optimize: dùng invalidateFilter() theo source nếu cần |
| 6 | rawData trong production | Low | Bọc trong kDebugMode trước release |
| 7 | Status mapping còn `other` nhiều | Medium | Cập nhật sau Phase 4 có data thực |
| 8 | Sample `.dart` files trong `spec/` là v2 legacy | High | Xóa folder `spec/` sau khi implement xong (§17.4 Bước 8) |
| 9 | UX filter labels chưa chốt với PM | High | Confirm trước khi triển khai (§17.5 [A]) |
| 10 | Compile-check signature chưa verify | Medium | Theo §4.5 trước khi copy-paste code mẫu |
| 11 | v2 `TransactionX.transactionStatus` có code 11 → pending, v3 mapper thiếu | Medium | Thêm `11 => pending` khi viết `_parseStatus` (đã note ở §6.5) |

---

## 20. FAQ

**Q: Tại sao chọn Phương án A (mỗi filter = 1 widget riêng) thay vì 1 widget với `setFilter`?**

A: 3 lý do:
1. **UX đồng bộ**: Khớp pattern `BettingHistoryScreen` đã có trong app — user không phải
   học hành vi khác nhau cho 2 màn hình history tương tự.
2. **Đơn giản hóa Notifier**: Filter immutable → không cần guard `if (filter == newFilter)`,
   không cần reset cursor/exhaustion/error manually. Type-safe — không thể truyền nhầm filter.
3. **Lifecycle tự nhiên**: Đổi filter = dispose Notifier cũ + tạo mới qua family. Không có
   risk state leak giữa các filter (vd: items cũ flash trước khi loading mới hiện ra).

Cost: đổi tab mất 1 frame (Notifier mới khởi tạo + loadInitial). Vì cache trang đầu giữ
ở Repository (không bị dispose theo Notifier), quay lại tab cũ trong 2 phút vẫn HIT cache
→ vẫn nhanh.

**Q: Vì sao filter menu dùng `ValueNotifier` local thay vì Riverpod state?**

A: Filter menu chỉ là local UI state của Screen — không có ai bên ngoài cần biết. Dùng
`ValueNotifier` + `ValueListenableBuilder` đơn giản, không tốn provider. Đây cũng là pattern
mà `BettingHistoryScreen` đang dùng.

**Q: Tại sao không gộp 4 API thành 1 multi-source request như v2?**

A: v3 đơn giản hóa: 1 filter = 1 API. User chỉ xem 1 tab tại một thời điểm → không cần
gọi đồng thời 4 sources. Tab "Slip" gộp deposit+withdraw qua `slipType=0` ở server side.
`TransactionAggregator` vẫn giữ để dùng khi tích hợp `depositComplains` (§18.2 Option B).

**Q: `getTransactions` (legacy) còn dùng không?**

A: Giữ trong codebase tạm thời cho backward compat. Migration §17.4 Bước 8 sẽ xóa nếu
không còn caller. Entry point chính là `getTransactionsByFilter`.

**Q: Có thể thêm nguồn mới không?**

A: Có:
1. Thêm value vào `TransactionSource`
2. Thêm `TransactionFilter` mới (hoặc gộp vào filter có sẵn)
3. Tạo `XxxDataSource` class mới
4. Thêm field + case trong `TransactionRepository._dispatch`
5. Thêm `TransactionMapper.fromXxx`

**Q: Tại sao cache chỉ trang đầu?**

A: Trang đầu user thấy ngay khi mở màn hình → cần fast. Trang sau load khi scroll → có
thể chờ. Cache nhiều trang tốn RAM và phức tạp invalidate.

**Q: Sao dùng Stream events thay vì Riverpod listen trực tiếp?**

A: Stream cho phép multiple Notifier (nếu sau này có) cùng subscribe. Riverpod listen
cũng được nhưng coupling chặt giữa Notifier và Repository. Stream giữ Repository
unaware của Notifier — đúng SRP.

**Q: `autoDispose` cho Notifier có làm mất state khi navigate?**

A: Có — đó là design intent. Cache trang đầu (TTL 2 phút) giúp giảm thiểu cảm giác
"load lại từ đầu". Nếu cần giữ state lâu hơn → thêm `ref.keepAlive()` trong Notifier.

**Q: SourceFailure = exhausted ngay → mạng chập chờn mất data?**

A: (Áp dụng cho v2 multi-source, không phải v3 single-source flow chính.) Trade-off
giữa UX (không load mãi) và correctness (có thể thiếu data). v3 đơn giản hóa: 1 source
fail → toàn bộ filter fail → state.error → user retry. Cleaner UX.

**Q: Re-sort toàn bộ list mỗi lần loadMore có chậm không?**

A: O(n log n) với n ~50-100 items → < 1ms trên thiết bị thấp. Không vấn đề. Cần thiết
vì source A page 2 có thể chứa item mới hơn source B page 1 (chỉ áp dụng nếu trong
tương lai gộp multi-source).

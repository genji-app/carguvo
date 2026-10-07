# Trên Dưới (Up/Down) — Luật chơi & Logic

> Tài liệu này được dựng từ việc đọc `TrenDuoiMessageHandler.ts` (handler socket
> phía client gốc — Cocos Creator/TypeScript). Mục đích: làm cơ sở để nối logic
> cho bản Flutter (`up_down_screen.dart`).
>
> Những chỗ **suy luận** (do tên field viết tắt, không có comment) được đánh dấu
> _(suy luận)_. Phần **chắc chắn** lấy trực tiếp từ code.

---

## 1. Tổng quan

Trên Dưới là minigame **đoán lá bài cao/thấp** (Hi‑Lo):

1. Người chơi chọn **mức cược** (1K · 10K · 50K · 100K · 500K).
2. Bấm **Bắt đầu** → server chia **một lá bài mốc** và trả về hệ số/tiền thưởng
   cho 2 cửa **Trên** (lá kế cao hơn) và **Dưới** (lá kế thấp hơn).
3. Người chơi chọn **Trên** hoặc **Dưới**:
   - **Đúng** → tiền thắng cộng dồn, server lật lá mới làm mốc, trả hệ số mới →
     có thể **đoán tiếp** (lượt mới) hoặc **Rút tiền**.
   - **Sai** → thua, ván kết thúc, reset về trạng thái ban đầu.
4. Có cơ chế **Jackpot** (các "hũ" — *jars*) tích luỹ; một số kết quả có thể nổ
   jackpot.
5. Mỗi phiên/lượt có **đồng hồ đếm ngược** (thời gian còn lại để ra quyết định).

Tương ứng UI hiện có: số dư (góc trên), lá bài úp ở giữa, đồng hồ `02:00`, cột
mức cược bên phải, nút Bắt đầu tròn; sau khi bắt đầu: dải lịch sử lá, 2 cửa
Trên/Dưới (xanh/đỏ) kèm tiền thưởng, nút **"Rút tiền & Lượt mới"**.

---

## 2. Giao thức message

Tất cả message gửi qua `SocketManager` kênh **`SocketType.MINI`**, đóng gói:

```ts
let mes = [MessageRequest.ZonePlugin_Type, "MiniGame", "updownPlugin", dict];
SocketManager.getInstance().sendData(SocketType.MINI, mes);
```

Trong đó `dict["cmd"]` là mã lệnh. Khi nhận, handler đọc `mes[1]` làm `dict` rồi
switch theo `dict["cmd"]`.

| cmd  | Tên           | Hướng        | Ý nghĩa                                            |
|------|---------------|--------------|----------------------------------------------------|
| 1500 | `INFO_GAME`   | gửi ⇄ nhận   | Lấy thông tin game hiện tại (hũ, phiên, đồng hồ)   |
| 1501 | `START_GAME`  | gửi ⇄ nhận   | Bắt đầu ván mới (đặt cược, chia lá mốc)            |
| 1502 | `START_ROUND` | gửi ⇄ nhận   | Đoán Trên/Dưới cho lượt kế (lật lá mới)            |
| 1503 | `STOP_GAME`   | gửi ⇄ nhận   | Dừng/Rút tiền (chốt thắng)                          |
| 1504 | `UPDATE_JAR`  | nhận         | Server đẩy cập nhật giá trị hũ jackpot              |

---

## 3. Từ điển field

| Field   | Tên đầy đủ (suy luận)         | Ý nghĩa                                                        |
|---------|-------------------------------|---------------------------------------------------------------|
| `cmd`   | command                       | Mã lệnh (1500–1504)                                            |
| `Js`    | Jars                          | Danh sách "hũ" jackpot (giá trị tích luỹ)                      |
| `ss`    | session                       | Id phiên đang diễn ra (nếu có) — INFO_GAME                     |
| `rmT`   | remaining Time                | Thời gian còn lại (đồng hồ đếm ngược)                          |
| `up`    | up                            | Hệ số/tiền thưởng cửa **Trên** _(suy luận)_                    |
| `down`  | down                          | Hệ số/tiền thưởng cửa **Dưới** _(suy luận)_                    |
| `iid`   | instance id                   | Id ván/instance _(suy luận)_                                   |
| `crd`   | card                          | Lá bài (giá trị lá vừa chia/lật)                               |
| `b`     | bet                           | Tiền cược                                                      |
| `aid`   | action/account id             | Trong request luôn `= 1` (hằng số) _(suy luận)_                |
| `sid`   | session id                    | Id phiên (dùng cho START_ROUND/STOP_GAME)                     |
| `iF`    | is Finish                     | Ván kết thúc (thua/hết lượt) → reset _(suy luận)_              |
| `iJ`    | is Jackpot                    | Có nổ jackpot không _(suy luận)_                               |
| `ng`    | next game / new game          | Cờ sang ván mới _(suy luận)_                                   |
| `J`     | Jackpot                       | Giá trị jackpot (chỉ có khi `iJ = true`)                       |
| `udr`   | up/down result                | Lựa chọn của người chơi: Trên hay Dưới _(suy luận)_           |
| `mgs`   | message                       | Thông báo lỗi từ server                                        |
| `c`     | error code                    | Mã lỗi đi kèm `mgs`                                            |

---

## 4. Luồng chơi (state machine)

```
                subcribe()
                   │ gửi INFO_GAME
                   ▼
        ┌────────────────────┐
        │   IDLE (chờ chơi)  │  ← resInfoGame: hiện hũ, đồng hồ, (nếu có phiên)
        │  - chọn mức cược   │     thì hiện cửa Trên/Dưới của phiên đang chạy
        └─────────┬──────────┘
                  │ bấm Bắt đầu → gửi START_GAME(aid, b)
                  ▼
        ┌────────────────────┐
        │  PLAYING (đã chia) │  ← resStartGame: lá mốc crd, hệ số up/down
        │  - hiện lá + 2 cửa │
        └─────────┬──────────┘
            ┌──────┴───────────────┐
   chọn cửa │ gửi START_ROUND       │ bấm Rút tiền
  (udr)     │ (aid,b,sid,udr)       │ gửi STOP_GAME(sid)
            ▼                       ▼
   resStartNewRound          resStopGame(crd)
   (crd, up, down,           → chốt thắng, về IDLE
    iF, iJ, J, ng)
            │
   ┌────────┴─────────┐
   │ iF = false       │ iF = true  → THUA / hết ván
   │ → lật lá mới,    │ (hoặc lỗi START_GAME: mgs/c)
   │   đoán tiếp hoặc │ → resetAll() → về IDLE
   │   rút tiền       │
   └──────────────────┘

  Song song: server đẩy UPDATE_JAR(Js) bất kỳ lúc nào → updateJackpot()
```

---

## 5. Chi tiết từng message

### 5.1. `INFO_GAME` (1500) — lấy trạng thái

**Gửi:** chỉ `{cmd: 1500}` (không kèm field).

**Nhận → `resInfoGame(jars, session, rmT, up, down)`:**
- `Js` → `jars`: danh sách hũ jackpot (luôn có).
- Nếu `ss != undefined`: có phiên đang chạy → đọc thêm `up`, `down` (hệ số 2 cửa
  hiện tại); `session = ss`.
- Nếu `rmT != undefined`: `rmT` = thời gian còn lại.
- Mặc định khi không có phiên: `session = null, rmT = -1, up = 0, down = 0`.

> Dùng để **khởi tạo màn**: hiển thị hũ + đồng hồ; nếu vào lúc đang có phiên thì
> dựng luôn cửa Trên/Dưới.

### 5.2. `START_GAME` (1501) — bắt đầu ván

**Gửi:** `{cmd: 1501, aid: 1, b: <mức cược hiện tại>}`
(`b = TrenDuoiGameView.getCurBetValue()`).

**Nhận:**
- **Nhánh lỗi:** nếu có `mgs` → `NotiView.showMessage(mgs)` (kèm mã lỗi `c`) rồi
  `miniGameView.resetAll()` và dừng. (Ví dụ: không đủ tiền, phiên lỗi…)
- **Nhánh thành công → `resStartGame(iid, crd, bet, sid, up, down, aid)`:**
  `iid`, `crd` (lá mốc), `b` (cược), `sid` (id phiên mới), `up`, `down`
  (hệ số 2 cửa cho lượt kế), `aid`.

### 5.3. `START_ROUND` (1502) — đoán Trên/Dưới

**Gửi:** `{cmd: 1502, aid: 1, b: <cược>, sid: <session id>, udr: <Trên|Dưới>}`
(`sid = getSessionID()`, `udr = getUpDownValue()`).

**Nhận → `resStartNewRound(iid, crd, bet, sid, up, down, iF, iJ, jackpot, nG)`:**
- `crd`: lá mới được lật (để so với lá mốc → biết thắng/thua).
- `up`, `down`: hệ số 2 cửa cho lượt **kế tiếp** (nếu chơi tiếp).
- `iF` (is finish): `true` → ván kết thúc (thua/hết lượt).
- `iJ` (is jackpot): `true` → nổ jackpot, khi đó đọc `J` làm `jackpot`
  (mặc định `jackpot = 0`).
- `ng`: cờ ván mới _(suy luận)_.

### 5.4. `STOP_GAME` (1503) — rút tiền / dừng

**Gửi:** `{cmd: 1503, sid: <session id>}`.

**Nhận:** nếu có `crd` → `resStopGame(crd)` (lá chốt cuối). Chốt tiền thắng,
quay về trạng thái chờ chơi.

> Tương ứng nút **"Rút tiền & Lượt mới"** trong UI.

### 5.5. `UPDATE_JAR` (1504) — cập nhật hũ

**Nhận:** `Js` → `updateJackpot(jars)`. Server tự đẩy định kỳ để cập nhật giá
trị hũ jackpot hiển thị.

---

## 6. Ánh xạ sang UI Flutter (`up_down_screen.dart`)

| Thành phần UI                         | Dữ liệu / hành động                                   |
|---------------------------------------|-------------------------------------------------------|
| Số dư (banner trên header)            | Ví người chơi (cập nhật sau mỗi thắng/thua/rút)       |
| Lá bài úp ở giữa                      | `crd` — lá mốc hiện tại                                |
| Đồng hồ `02:00`                       | `rmT` — thời gian còn lại                              |
| Cột mức cược (1K…500K)                | `getCurBetValue()` → field `b` khi gửi                |
| Nút Bắt đầu (tròn)                    | Gửi `START_GAME`                                      |
| Dải lịch sử lá (sau khi bắt đầu)      | Chuỗi `crd` đã lật qua các lượt                        |
| Cửa **Trên** (xanh) + tiền            | `up` (hệ số/tiền thưởng cửa Trên); chọn → `udr = Trên`|
| Cửa **Dưới** (đỏ) + tiền              | `down`; chọn → `udr = Dưới`; gửi `START_ROUND`        |
| Cửa available / not_available         | Trạng thái cho cược hay không (khoá khi hết giờ…)     |
| Nút **"Rút tiền & Lượt mới"**         | Gửi `STOP_GAME(sid)`                                   |
| Hũ jackpot                            | `Js` từ `INFO_GAME` / `UPDATE_JAR`                     |

---

## 7. Ghi chú khi triển khai

- **Singleton view:** handler gốc thao tác qua `TrenDuoiGameView.getInstance()`
  và luôn kiểm tra null trước khi gọi. Bản Flutter nên tách phần **state/socket**
  (provider/notifier) khỏi **widget** để tránh phụ thuộc singleton.
- **Reset:** cả nhánh lỗi `START_GAME` (có `mgs`) lẫn `iF = true` của
  `START_ROUND` đều dẫn tới **kết thúc ván** → cần một hàm `resetAll()` đưa UI về
  trạng thái IDLE (hiện nút Bắt đầu).
- **Giá trị `up`/`down`:** chưa rõ là *hệ số nhân* hay *số tiền thưởng tuyệt đối*
  — cần xác nhận với server/`TrenDuoiGameView`. UI đang hiển thị dạng số tiền
  (vd `9,876,543`).
- **`aid = 1` cứng** trong request: cần xác nhận ý nghĩa (action id? account id?)
  trước khi nối thật.
- **Thiếu file tham chiếu:** logic xử lý cụ thể nằm trong `TrenDuoiGameView`
  (`resInfoGame`, `resStartGame`, `resStartNewRound`, `resStopGame`,
  `updateJackpot`, `getCurBetValue`, `getSessionID`, `getUpDownValue`) — chưa có
  trong repo. Khi có, nên bổ sung phần "so lá → thắng/thua", "cộng dồn tiền
  thắng", và quy tắc jackpot vào tài liệu này.

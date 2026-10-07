# Tính năng: Giao thức mạng (Network Protocol)

**Nguồn:** `TrenDuoiMessageHandler.ts` + cách `TrenDuoiGameView.res*()` dùng
tham số. **Bản này đính chính semantics so với `../TREN_DUOI_GAME_LOGIC.md`.**

---

## 1. Kênh & gói tin

- Socket: `SocketType.MINI`.
- Gói gửi: `[MessageRequest.ZonePlugin_Type, "MiniGame", "updownPlugin", dict]`.
- `dict["cmd"]` = mã lệnh. Khi nhận: `dict = mes[1]`, switch theo `dict["cmd"]`.

| cmd | Tên | Hướng |
|-----|-----|-------|
| 1500 | INFO_GAME | gửi ⇄ nhận |
| 1501 | START_GAME | gửi ⇄ nhận |
| 1502 | START_ROUND | gửi ⇄ nhận |
| 1503 | STOP_GAME | gửi ⇄ nhận |
| 1504 | UPDATE_JAR | chỉ nhận |

---

## 2. ⚠️ Bảng field ĐÚNG (đính chính)

| Field | Ý nghĩa thực | Ghi chú |
|-------|--------------|---------|
| `iid` | **Mã lá bài** (0–51) | Truyền vào `onUpdateResult` như "result". KHÔNG phải instance id. |
| `crd` | **Credit** (tiền thắng đang giữ) | Hiển thị nút Rút tiền. KHÔNG phải card. |
| `b` | Mức cược | |
| `up` | Tiền thưởng cửa **Trên** | label high price |
| `down` | Tiền thưởng cửa **Dưới** | label low price |
| `sid` | Session id | |
| `iF` | **isGameOver** (thua/hết ván) | |
| `iJ` | isWinJackpot | |
| `J` | Giá trị jackpot | chỉ khi `iJ` |
| `ng` | **forcedNewGame** (khoá Trên/Dưới) | |
| `udr` (gửi) | **1 = Trên, -1 = Dưới** | KHÔNG phải 0/1 |
| `ss` | Object phiên đang chạy | gồm `items, sid, crd, b` |
| `items` | Mảng **mã lá** đã lật | khôi phục phiên |
| `mgs` / `c` | message lỗi / error code | nhánh lỗi START_GAME |
| `Js` | Mảng hũ jackpot `[{J, aid, b}]` | xem `08` |

---

## 3. Chi tiết từng message

### 3.1. INFO_GAME (1500)
**Gửi:** `{cmd:1500}`.
**Nhận →** `resInfoGame(jars=Js, session=ss, remainTime=rmT, up, down)`:
- Luôn: `updateJackpot(Js)` + `resetAll()`.
- Nếu `ss != null` (đang có phiên): đọc `ss.items` (mảng lá), `ss.sid`, `ss.crd`
  (credit), `ss.b` (bet) → khôi phục:
  - high = `up`, mid = `crd` (credit), low = `down`;
  - replay từng lá `items[i]` qua `onUpdateResult`;
  - ẩn nút Play; đặt đồng hồ = `rmT` (ms) và chạy.

### 3.2. START_GAME (1501)
**Gửi:** `{cmd:1501, aid:1, b:<bet>}`.
**Nhận:**
- Lỗi: có `mgs` → `NotiView.showMessage(mgs)` (kèm `c`) → `resetAll()`, dừng.
- OK → `resStartGame(iid, crd, b, sid, up, down, aid)`:
  - `mSessionID = sid`; delay 0.5s → `onUpdateResult(iid=lá)`; high=`up`,
    mid=`crd`, low=`down`.

### 3.3. START_ROUND (1502)
**Gửi:** `{cmd:1502, aid:1, b:<bet>, sid:<session>, udr:<1|-1>}`.
**Nhận →** `resStartNewRound(iid, crd, b, sid, up, down, iF, iJ, jackpot=J, ng)`:
- `mIsGameOver=iF`, `mIsWinJackpot=iJ`, `stopTimer()`, `mSessionID=sid`;
- delay 0.5s → `onUpdateResult(iid, J)`; cập nhật high/mid/low;
- nếu `ng` (forcedNewGame) → tắt nút Trên/Dưới.

### 3.4. STOP_GAME (1503)
**Gửi:** `{cmd:1503, sid:<session>}`.
**Nhận →** `resStopGame(crd=credit)`: hiện `+credit`, sfx thắng, status thắng,
disable nút, sau 3s `subcribe()`.

### 3.5. UPDATE_JAR (1504)
**Nhận →** `updateJackpot(Js)` (xem `08`). Server đẩy định kỳ.

---

## 4. Việc cần sửa trong code Flutter hiện có

File `features/mini_game/messages/tren_duoi_message.dart` đang map **SAI**:

```dart
// HIỆN TẠI (sai):
card: dict['crd'] as int?,          // crd KHÔNG phải card
instanceId: dict['iid'] as int?,    // iid MỚI là card
```

**Sửa thành** (đề xuất đổi tên field cho đúng nghĩa):

```dart
const factory TrenDuoiMessage.startGame({
  String? errorMessage,            // mgs
  int? cardCode,                   // iid  ← LÁ BÀI
  int? credit,                     // crd  ← TIỀN GIỮ
  int? bet,                        // b
  int? sessionId,                  // sid
  int? upPayout,                   // up
  int? downPayout,                 // down
  int? accountId,                  // aid
}) = TrenDuoiStartGame;
```

Và `TrenDuoiStartRound`: thêm `cardCode (iid)`, `credit (crd)`, `upPayout`,
`downPayout`, `isGameOver (iF)`, `isJackpot (iJ)`, `jackpot (J)`,
`forcedNewGame (ng)`.

`TrenDuoiSender.startRound`: sửa comment/encoding `udr`:
```dart
/// udr: 1 = Trên (UP), -1 = Dưới (DOWN).
void startRound({required int bet, required int sessionId, required int upDown, int accountId = 1});
```
(map UI: Trên→1, Dưới→-1).

Khôi phục phiên (INFO_GAME có `ss`): parser cần đọc cả `ss.items`, `ss.crd`,
`ss.b`, `ss.sid` (hiện chỉ đọc `ss` như sessionId).

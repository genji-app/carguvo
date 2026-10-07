# Trên Dưới — PLAN handle Logic & Business

> Dựa trên `TREN_DUOI_GAME_LOGIC.md` + khảo sát code hiện có. Mục tiêu: nối
> `up_down_screen.dart` (đang là UI tĩnh) vào socket thật theo đúng pattern Tài
> Xỉu (`tai_xiu_state_provider.dart`).

---

## 0. Hiện trạng — ĐÃ CÓ vs CÒN THIẾU

**Đã có sẵn (tái dùng, KHÔNG làm lại):**

| Thành phần | File |
|---|---|
| Model + parser 5 message | `features/mini_game/messages/tren_duoi_message.dart` (`TrenDuoiMessage`, `parseTrenDuoiMessage`) |
| Sender (subscribe/start/round/stop) | `messages/mini_game_senders.dart` → `TrenDuoiSender` |
| Stream message | `messages/mini_game_message_streams.dart` → `trenDuoiMessageStreamProvider` |
| Subscribe lúc vào lobby | `mini_game_lobby.dart` |
| Countdown badge ngoài FAB | `presentation/state/mini_game_countdown_provider.dart` (`trenDuoiSec`) |
| Socket client | `socket/mini_game_socket_providers.dart` → `miniGameSocketClientProvider` |
| Refresh số dư app | `userProvider.notifier.refreshBalance()` |
| UI (tĩnh, demo) | `lib/mini/up_down/up_down_screen.dart` |

**Còn thiếu (cần làm):**

1. **State + Notifier** cho Trên Dưới (tương tự `TaiXiuSocketNotifier`).
2. **Wiring** `up_down_screen.dart` → đọc state thật, gọi action thật.
3. **Phụ trợ**: toast lỗi, refresh số dư, hiển thị jackpot, lịch sử lá, đồng hồ.

> ⚠️ `TrenDuoiSender.startRound(upDown)` quy ước **0 = DƯỚI, 1 = TRÊN**.

---

## 1. Kiến trúc đề xuất

```
trenDuoiMessageStreamProvider (đã có)
            │  ref.listen
            ▼
TrenDuoiGameNotifier  ──(actions)──►  TrenDuoiSender ──► socket
   (StateNotifier)                         (đã có)
            │  state
            ▼
trenDuoiGameStateProvider (.autoDispose)
            │  ref.watch
            ▼
UpDownScreen / _Interface (ConsumerStatefulWidget)
```

File mới đặt tại: `presentation/state/tren_duoi_state_provider.dart` (cạnh
`tai_xiu_state_provider.dart`) để đồng nhất tổ chức.

---

## 2. State model — `TrenDuoiGameState`

Dùng freezed (như `tai_xiu_message`) hoặc class immutable + `copyWith`.

```dart
enum TrenDuoiPhase { idle, playing, revealing, finished }
enum TrenDuoiPick { none, up, down }

class TrenDuoiGameState {
  final TrenDuoiPhase phase;        // idle = chưa chơi; playing = đã có lá mốc
  final int sessionId;              // sid (0 = chưa có)
  final int instanceId;             // iid
  final int selectedBet;            // mức cược đang chọn (1k..500k)
  final int? currentCard;           // crd – lá mốc hiện tại
  final int upPayout;               // up – thưởng/hệ số cửa Trên
  final int downPayout;             // down – thưởng/hệ số cửa Dưới
  final int winnings;               // tiền đang có thể rút (nút "Rút tiền")
  final int remainingSec;           // rmT → giây còn lại
  final List<int> history;          // chuỗi crd đã lật
  final List<JackpotData> jackpots; // Js – các hũ
  final int jackpot;                // J – khi nổ jackpot
  final bool isJackpot;             // iJ
  final bool canBetUp;              // cửa Trên còn cho cược? (→ ảnh available)
  final bool canBetDown;            // cửa Dưới còn cho cược?
  final bool busy;                  // chặn double-tap khi chờ phản hồi
  final String? error;
  // copyWith(...) ...
}
```

> `winnings` / `upPayout` / `downPayout`: **CHƯA chắc** lấy từ field nào (xem
> mục 5). Tạm map `up`→upPayout, `down`→downPayout; `winnings` suy từ `b` của
> `startRound`/`startGame`. Cần chốt với server.

---

## 3. Notifier — `TrenDuoiGameNotifier`

Khung theo `TaiXiuSocketNotifier`:

```dart
final trenDuoiGameStateProvider = StateNotifierProvider
  .autoDispose<TrenDuoiGameNotifier, TrenDuoiGameState>((ref) =>
    TrenDuoiGameNotifier(ref));

class TrenDuoiGameNotifier extends StateNotifier<TrenDuoiGameState> {
  TrenDuoiGameNotifier(this._ref) : super(const TrenDuoiGameState.initial()) {
    _listen();      // ref.listen(trenDuoiMessageStreamProvider, _onMessage)
    subscribe();    // gửi INFO_GAME khi mở màn
  }
  final _toast = StreamController<String>.broadcast(); // view hiện AppToast
  Timer? _countdown;
  // ...
}
```

### 3.1. Actions (UI gọi)

| Action UI | Điều kiện | Gửi |
|---|---|---|
| `selectBet(int v)` | phase == idle | chỉ đổi state, không gửi |
| `start()` | idle & selectedBet>0 & !busy | `startGame(bet)` (cmd 1501), set busy |
| `pick(TrenDuoiPick)` | playing & canBet* & !busy | `startRound(bet, sid, udr)` (1502) |
| `cashout()` | playing & winnings>0 | `stopGame(sid)` (1503) |

Mọi action lấy client: `await _ref.read(miniGameSocketClientProvider.future)`.

### 3.2. Xử lý message (`_onMessage`)

```dart
switch (message) {
  case TrenDuoiInfoGame(:final jackpots, :final sessionId,
                        :final remainingTimeMs, :final up, :final down):
    // set hũ + đồng hồ. Nếu sessionId != null → đang có phiên dở:
    //   khôi phục phase = playing, up/down, sid, re-arm countdown(remainingTimeMs).
    //   Ngược lại → idle.

  case TrenDuoiStartGame(:final errorMessage, ...):
    if (errorMessage != null) { _toast.add(errorMessage); _reset(); break; }
    // set currentCard=crd, up, down, sessionId=sid, instanceId=iid,
    //   phase=playing, busy=false; push crd vào history; refreshBalance().

  case TrenDuoiStartRound(:final card, :final up, :final down,
                          :final isFinish, :final isJackpot, :final jackpot, ...):
    // push card vào history; cập nhật up/down cho lượt kế.
    if (isJackpot) { state = ... jackpot=jackpot, isJackpot=true; }
    if (isFinish)  { // THUA / hết ván → (tuỳ chọn) delay reveal rồi _reset(); }
    else           { // THẮNG → tiếp tục playing; cập nhật winnings. }
    refreshBalance();

  case TrenDuoiStopGame(:final finalCard):
    // chốt: cộng winnings vào ví, _reset() về idle; refreshBalance();
    //   (có thể bắn toast "Rút tiền thành công").

  case TrenDuoiUpdateJar(:final jackpots):
    state = state.copyWith(jackpots: jackpots);
}
```

### 3.3. Đồng hồ đếm ngược

Re-arm `Timer.periodic(1s)` từ `remainingTimeMs` mỗi khi nhận INFO_GAME (hoặc
mỗi lượt nếu server gửi thời gian). Hết giờ (`remainingSec == 0`): khoá cược
(`canBetUp/Down = false`) hoặc tự động xử lý theo server. Hủy timer khi dispose.

### 3.4. Vòng đời

- `.autoDispose`: notifier sống theo lúc `UpDownScreen` watch; đóng game →
  dispose → mở lại tạo mới → `subscribe()` lại (giống Tài Xỉu).
- `dispose()`: cancel `_countdown`, đóng `_subscription`, đóng `_toast`.

---

## 4. Wiring UI (`up_down_screen.dart`)

Hiện `_Interface` đang là `StatefulWidget` với `bool _started` + data demo. Đổi:

1. `_Interface` → `ConsumerStatefulWidget`; bỏ `_started` local, thay bằng
   `ref.watch(trenDuoiGameStateProvider)`.
2. **Ánh xạ state → widget:**
   - Số dư header ← `userProvider` (ví thật), không hard-code.
   - Lá giữa ← `state.currentCard` (chưa có → úp).
   - Đồng hồ `_CountdownPill` ← `state.remainingSec` (format mm:ss).
   - `_UnitColumn` chọn ← `state.selectedBet`, tap → `notifier.selectBet(v)`.
   - Nút Start ← enable khi `phase==idle`; tap → `notifier.start()`.
   - `phase==idle` → `_HintBar` + `_StartArea`; ngược lại → `_CardHistoryBar` +
     `_BetArea`.
   - `_CardHistoryBar` ← `state.history` (map số lá → rank+suit).
   - `_BetBar` Trên: amount ← `upPayout`, `available: state.canBetUp`,
     tap → `notifier.pick(up)`; Dưới tương tự với `downPayout`/`canBetDown`.
   - `_CashoutButton` ← `state.winnings`; tap → `notifier.cashout()`.
3. **Toast**: trong `initState` của view, `listen` `notifier.toastMessages` →
   `AppToast.showGeneric(context, message)` (copy nguyên pattern Tài Xỉu — view
   có context, notifier không).
4. **Chặn double-tap**: disable nút khi `state.busy`.

> Map "số lá → rank + chất": cần quy ước encoding của `crd` (xem mục 5).

---

## 5. Business cần CHỐT với server / `TrenDuoiGameView` gốc

| Câu hỏi | Vì sao quan trọng |
|---|---|
| `up`/`down` là **hệ số nhân** hay **số tiền thưởng**? | Quyết định hiển thị 2 cửa + cách tính `winnings`. |
| `winnings` (nút Rút tiền) lấy từ field nào? `b` có phải tiền tích luỹ tăng dần? | Hiện message không có field "tiền đang giữ" rõ ràng. |
| `crd` encode lá thế nào? (1–52? rank*4+suit? chỉ rank?) | Để render `_CardHistoryBar` + lá giữa đúng rank/chất. |
| Thắng/thua: client tự so lá hay chỉ dựa `iF`? | Theo handler, **server quyết** (`iF=true` = hết ván). Client chỉ phản ứng. |
| `iF=false` luôn nghĩa là THẮNG để chơi tiếp? | Xác nhận semantics "is finish". |
| `ng` (nextGame) dùng để làm gì? | Có thể là cờ tự mở ván mới. |
| `iJ`/`J`: điều kiện nổ jackpot + hiển thị? | Cần animation/thông báo riêng. |
| `aid = 1` cứng nghĩa là gì? | Trước khi nối thật. |
| Khi hết `rmT` thì server xử lý gì? | Để khoá UI / auto-resolve đúng. |

---

## 6. Edge cases / Non-functional

- **Mở màn lúc đang có phiên** (`INFO_GAME` có `ss`): khôi phục đúng phase
  playing + đồng hồ, không bắt chơi lại từ đầu.
- **Lỗi `START_GAME`** (`mgs`): toast + reset về idle (đã có nhánh).
- **Mất kết nối / resubscribe**: stream là broadcast (không replay) → notifier
  tự `subscribe()` trong constructor để lấy snapshot (giống Tài Xỉu).
- **Double-tap / spam**: cờ `busy` cho tới khi nhận phản hồi tương ứng.
- **autoDispose**: đảm bảo hủy timer + controller, tránh leak.
- **Số dư**: luôn `refreshBalance()` sau start/round/stop thay vì tự suy diễn.
- **Reveal animation** (tuỳ chọn): khi `iF=true`, có thể delay lật lá rồi mới
  reset để người chơi thấy lá thua (giống `_diceRevealTimer` của Tài Xỉu).

---

## 7. Phân rã task (theo thứ tự)

- [ ] **T1.** Tạo `TrenDuoiGameState` (+`copyWith`/initial) + enum phase/pick.
- [ ] **T2.** Tạo `tren_duoi_state_provider.dart`: notifier + `_listen` +
      `subscribe()` + `_onMessage` (5 nhánh) + countdown + toast + dispose.
- [ ] **T3.** Actions: `selectBet` / `start` / `pick` / `cashout` (+ guard busy,
      điều kiện phase) gọi `TrenDuoiSender`.
- [ ] **T4.** Map encoding `crd` → (rank, suit) cho UI (helper riêng).
- [ ] **T5.** Đổi `_Interface` → `ConsumerStatefulWidget`, watch state, bỏ data
      demo, nối số dư từ `userProvider`.
- [ ] **T6.** Nối từng widget: card · countdown · unit · start · history · 2 cửa
      (amount + available) · cashout.
- [ ] **T7.** Toast listener + disable theo `busy` + format mm:ss.
- [ ] **T8.** Jackpot: hiển thị hũ (`jackpots`) + xử lý nổ (`iJ`/`J`).
- [ ] **T9.** Test luồng: idle → start → pick (thắng) → pick → cashout; và
      idle → start → pick (thua) → reset; mở lúc đang có phiên; lỗi start.
- [ ] **T10.** Dọn: xoá `up_down_button_up.svg`/`up_download_button_down.svg`
      nếu không còn dùng; cập nhật `TREN_DUOI_GAME_LOGIC.md` khi chốt mục 5.

---

## 8. Rủi ro chính

1. **Thiếu `TrenDuoiGameView` gốc** → một số business (tiền thắng, encode lá,
   điều kiện jackpot) phải đoán/chốt với backend trước khi nối thật → ưu tiên
   làm rõ **mục 5** trước khi code T2–T3.
2. **up/down ý nghĩa** ảnh hưởng cả hiển thị lẫn tính tiền → blocker mềm.
3. Nếu server **không** trả "tiền đang giữ" → phải tự tính phía client từ
   bet × hệ số tích luỹ ⇒ cần công thức chính xác.

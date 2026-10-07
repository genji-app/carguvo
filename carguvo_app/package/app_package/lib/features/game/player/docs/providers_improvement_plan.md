# 🏗️ Kế hoạch triển khai: Cải thiện Provider Layer

> **Module**: `lib/features/game/player/providers/`
> **Branch**: `fix/orientation_android`
> **Baseline**: Commit `35032fd1` — providers review đã hoàn tất

---

## 📋 Tổng quan Tasks

| # | Task | File chính | Impact | Effort |
|---|---|---|---|---|
| T1 | Refactor `GamePlayerStage` → `GamePlayerLoadingStage` | `game_player_state.dart` + `notifier` + `view` + `test` | 🔴 High | ~45 min |
| T2 | Loại bỏ Vietnamese strings khỏi Notifier | `notifier` + `test` | 🟡 Medium | ~15 min |
| T3 | Rename `_updateStage` → `_transitionToLoading` | `notifier` | 🟡 Medium | ~10 min |
| T4 | Gom Timer management | `notifier` | 🟡 Medium | ~15 min |
| T5 | Bổ sung test coverage (6 edge cases) | `test/` | 🟡 Medium | ~30 min |

**Thứ tự bắt buộc**: T1 → T2 → T3 → T4 → T5 (mỗi task 1 commit)

---

## T1: Refactor `GamePlayerStage` → `GamePlayerLoadingStage`

### Lý do
`GamePlayerStage` enum có 7 giá trị (`initial, settingUp, connecting, loadingAssets, playing, failure, exiting`) — trùng ngữ nghĩa với Freezed variant `GamePlayerState`. Gây confusion khi trace: "stage nào? enum hay freezed?".

### Thiết kế mới

**BEFORE** — 7 giá trị, phần lớn redundant:
```dart
enum GamePlayerStage {
  initial, settingUp, connecting, loadingAssets, playing, failure, exiting;
  bool get isLoading => ...;
  bool get isPlaying => ...;
  bool get isExiting => ...;
}
```

**AFTER** — chỉ chứa loading sub-stages:
```dart
/// Sub-stages within the [GamePlayerLoadingState] variant.
/// Only meaningful when state is [GamePlayerState.loading].
enum GamePlayerLoadingStage {
  /// Setting up orientation and environment.
  settingUp,
  /// Connecting to server to fetch game URL.
  connecting,
  /// WebView is loading game assets.
  loadingAssets,
}
```

### Các bước triển khai

#### Bước 1.1: Cập nhật `game_player_state.dart`

```dart
// XÓA toàn bộ enum GamePlayerStage (line 29-65)
// THÊM enum mới:
enum GamePlayerLoadingStage { settingUp, connecting, loadingAssets }

// CẬP NHẬT factory:
const factory GamePlayerState.loading({
  @Default(GamePlayerLoadingStage.settingUp) GamePlayerLoadingStage stage,
  // ... giữ nguyên các field khác
}) = GamePlayerLoadingState;
```

Cập nhật computed getters:

```dart
// XÓA getter `stage` (line 142-148) — không cần map ngược nữa

// CẬP NHẬT `isOrientationReady`:
bool get isOrientationReady => maybeMap(
  loading: (s) => s.stage != GamePlayerLoadingStage.settingUp,
  playing: (_) => true,
  exiting: (_) => true,
  orElse: () => false,
);

// XÓA `isExiting` getter (line 155) — dùng trực tiếp pattern match
// THÊM nếu cần:
bool get isExiting => this is GamePlayerExitingState;
```

#### Bước 1.2: Cập nhật `game_player_notifier.dart`

Tất cả references `GamePlayerStage.xxx` → thay bằng pattern match hoặc `GamePlayerLoadingStage.xxx`:

```dart
// _updateStage — đổi parameter type:
void _updateStage(GamePlayerLoadingStage newStage) {
  if (_isDisposed) return;
  // Guard: không revert nếu đã playing hoặc exiting
  if (state is GamePlayerPlayingState || state is GamePlayerExitingState) {
    logDebug('Ignoring stage update to $newStage — already ${state.runtimeType}');
    return;
  }
  // Guard: không downgrade loadingAssets → connecting
  final currentLoadingStage = state.maybeMap(
    loading: (s) => s.stage,
    orElse: () => null,
  );
  if (currentLoadingStage == GamePlayerLoadingStage.loadingAssets &&
      newStage == GamePlayerLoadingStage.connecting) {
    logInfo('Ignoring downgrade to connecting — already loadingAssets');
    return;
  }
  state = GamePlayerState.loading(
    stage: newStage,
    retryCount: state.retryCount,
    gameUrl: state.gameUrl,
  );
}

// initializePlayer:
_updateStage(GamePlayerLoadingStage.settingUp);    // was GamePlayerStage.settingUp
_updateStage(GamePlayerLoadingStage.connecting);   // was GamePlayerStage.connecting

// loadGameUrl:
_updateStage(GamePlayerLoadingStage.connecting);
// ...trong URL fetch success:
state = GamePlayerState.loading(
  stage: state.maybeMap(
    loading: (s) => s.stage == GamePlayerLoadingStage.loadingAssets
        ? GamePlayerLoadingStage.loadingAssets
        : GamePlayerLoadingStage.connecting,
    orElse: () => GamePlayerLoadingStage.connecting,
  ),
  gameUrl: url,
  retryCount: state.retryCount,
);

// requestExit — thay guard:
if (state is GamePlayerExitingState || _isDisposed) return;
// was: state.stage == GamePlayerStage.exiting

// onLoadStart — thay guard:
if (_isDisposed || state is GamePlayerExitingState) return;
// ...và thay GamePlayerStage.loadingAssets → GamePlayerLoadingStage.loadingAssets
if (state.maybeMap(loading: (s) => s.stage, orElse: () => null) 
    != GamePlayerLoadingStage.loadingAssets) {
  // ...transition
}

// onLoadStop — tương tự pattern
if (_isDisposed || state is GamePlayerExitingState) return;

// retry:
state = GamePlayerState.loading(
  stage: GamePlayerLoadingStage.connecting,  // was GamePlayerStage.connecting
  retryCount: nextRetryCount,
  gameUrl: state.gameUrl,
);
```

#### Bước 1.3: Cập nhật `game_player_view.dart`

```dart
// _StatusOverlay — thay reference:
final isExiting = ref.watch(
  gamePlayerProvider(game).select((s) => s is GamePlayerExitingState),
);
// was: s.stage.isExiting
```

#### Bước 1.4: Cập nhật `game_player_screen.dart`

```dart
// _syncMismatchState — không cần thay đổi (đã dùng maybeMap)
```

#### Bước 1.5: Cập nhật Tests

```dart
// Thay tất cả GamePlayerStage.xxx → GamePlayerLoadingStage.xxx
// Ví dụ:
expect(
  notifier.state.maybeMap(
    loading: (s) => s.stage == GamePlayerLoadingStage.settingUp,
    orElse: () => false,
  ),
  isTrue,
);
```

#### Bước 1.6: Chạy build_runner + verify

```bash
cd /Users/admin/Documents/s88-flutter
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/game/player/
```

> **Commit**: `refactor(game/player): replace GamePlayerStage with GamePlayerLoadingStage`

---

## T2: Loại bỏ Vietnamese Strings khỏi Notifier

### Lý do
Business logic layer (Notifier) chứa 3 Vietnamese strings — vi phạm layer separation. View layer (`GamePlayerFailureView`) đã có mapping `failureType → UI string`, nên Notifier không cần giữ message.

### Vị trí cần sửa

| Dòng | Nội dung hiện tại | Hành động |
|---|---|---|
| L334 | `'Quá số lần thử lại. Game đang bảo trì.'` | Xóa — View đã handle `maintenance` type |
| L377 | `'Tải game quá lâu hoặc gặp lỗi hiển thị nội dung.'` | Thay bằng `failureType: .loadTimeout` |
| L476 | `'Không tìm thấy địa chỉ trò chơi.'` | Thay bằng `failureType: .missingGameUrl` |

### Thiết kế

Thêm 2 failure types mới cho các trường hợp runtime:

```dart
enum GamePlayerErrorType {
  network,
  sessionExpired,
  comingSoon,
  unavailable,
  serverError,
  maintenance,
  unknown,
  // NEW:
  /// WebView load timed out or fallback triggered.
  loadTimeout,
  /// Game URL was null when expected.
  missingGameUrl,
}
```

Cập nhật Notifier — xóa Vietnamese strings:

```dart
// retry() — line 332-335:
state = const GamePlayerState.failure(
  failureType: GamePlayerErrorType.maintenance,
  // XÓA: failureMessage: 'Quá số lần thử lại...',
  retryCount: 0,
);

// _startTimeoutTimer — line 377:
handleError(
  failureType: GamePlayerErrorType.loadTimeout,
  // XÓA message parameter — View sẽ map type → string
);

// onLoadStop — line 476:
handleError(
  failureType: GamePlayerErrorType.missingGameUrl,
);
```

Cập nhật `handleError` signature:

```dart
void handleError({
  String? message,  // optional, chỉ cho CaxiloBusinessFailure
  bool isRetryable = true,
  GamePlayerErrorType failureType = GamePlayerErrorType.unknown,
}) { ... }
```

Cập nhật `GamePlayerFailureView` — thêm 2 case mới:

```dart
GamePlayerErrorType.loadTimeout => GamePlayerMessage(
  icon: const GamePlayerErrorIcon(),
  message: const Text('Tải game quá lâu'),
  secondaryMessage: const Text('Vui lòng thử lại'),
  onPrimaryAction: onRetry,
  primaryActionText: I18n.txtRetry,
),
GamePlayerErrorType.missingGameUrl => GamePlayerMessage(
  icon: const GamePlayerErrorIcon(),
  message: const Text('Không tìm thấy trò chơi'),
  onPrimaryAction: onClose,
  primaryActionText: I18n.txtGoBack,
),
```

Cập nhật test — xóa assertion Vietnamese string:

```dart
// line 309 — thay:
expect(s.failureType, GamePlayerErrorType.maintenance);
// XÓA: expect(s.failureMessage, 'Quá số lần thử lại...');
```

> **Commit**: `refactor(game/player): extract failure messages to View layer`

---

## T3: Rename `_updateStage` → `_transitionToLoading`

### Lý do
Tên `_updateStage` không phản ánh behavior thật (có guard logic bên trong). Method này thực chất là "attempt to transition into a loading sub-stage, silently ignore if terminal".

### Thay đổi

```dart
// BEFORE:
void _updateStage(GamePlayerLoadingStage newStage) { ... }

// AFTER:
/// Attempts to transition into a loading sub-stage.
///
/// Silently ignores if the player is already in a terminal state
/// (playing/exiting) or if the transition would be a downgrade
/// (e.g. loadingAssets → connecting).
void _transitionToLoading(GamePlayerLoadingStage stage) { ... }
```

Tìm & thay tất cả call sites trong notifier (3 chỗ):
- `initializePlayer`: 2 lần
- `loadGameUrl`: 1 lần

> **Commit**: `refactor(game/player): rename _updateStage to _transitionToLoading`

---

## T4: Gom Timer Management

### Lý do
4 chỗ cancel timer rải rác: `requestExit()`, `handleError()`, `onLoadStart()`, `dispose()`. Dễ quên 1 timer khi thêm logic mới.

### Thay đổi

Thêm helper method:

```dart
/// Cancels all active timers to prevent stale callbacks.
void _cancelAllTimers() {
  _timeoutTimer?.cancel();
  _finishLoadTimer?.cancel();
  _fallbackLoadTimer?.cancel();
}
```

Thay thế tại các call sites:

```dart
// requestExit() — line 228-230:
_cancelAllTimers();  // was 3 dòng cancel riêng

// handleError() — line 506-508:
_cancelAllTimers();  // was 3 dòng cancel riêng

// dispose() — line 316-318:
_cancelAllTimers();  // was 3 dòng cancel riêng

// onLoadStart() — line 407-408 và 412-413:
_cancelAllTimers();  // gom lại, chỉ gọi 1 lần ở đầu method

// onLoadStop() — line 447-448:
_cancelAllTimers();  // was 2 dòng cancel riêng
```

> **Commit**: `refactor(game/player): centralize timer management with _cancelAllTimers`

---

## T5: Bổ sung Test Coverage

### 6 Edge Cases cần cover

#### 5.1: `onLoadStart` duplicate guard
```dart
test('onLoadStart ignores duplicate calls when already loadingAssets', () async {
  await notifier.initializePlayer(...);
  notifier.onLoadStart(Uri.parse('https://game.com'));
  
  // Already loadingAssets — second call should be no-op
  final stateBefore = notifier.state;
  notifier.onLoadStart(Uri.parse('https://game.com/page2'));
  expect(notifier.state, stateBefore);
});
```

#### 5.2: `onLoadStop` when gameUrl is null
```dart
test('onLoadStop emits failure when gameUrl is null', () {
  // Don't initialize — no gameUrl
  notifier.onLoadStop();
  
  // After finishLoadDelay, should transition to failure
  await Future<void>.delayed(const Duration(milliseconds: 900));
  expect(notifier.state, isA<GamePlayerFailureState>());
});
```

#### 5.3: `onNewTabOpened` flow
```dart
test('onNewTabOpened sets isNewTabOpened flag', () async {
  await notifier.initializePlayer(...);
  notifier.onNewTabOpened();
  
  expect(
    notifier.state.maybeMap(
      playing: (s) => s.isNewTabOpened,
      orElse: () => false,
    ),
    isTrue,
  );
});
```

#### 5.4: Timeout timer fires → handleError
```dart
test('timeout timer triggers failure after _loadTimeout', () async {
  await notifier.initializePlayer(...);
  // gameUrl is set, timeout timer is running
  
  // Wait for timeout (30s) — use fakeAsync
  fakeAsync((async) {
    notifier.initializePlayer(...);
    async.elapse(const Duration(seconds: 31));
    expect(notifier.state, isA<GamePlayerFailureState>());
  });
});
```

#### 5.5: Events stream closed after dispose
```dart
test('events stream is closed after dispose', () {
  notifier.dispose();
  expect(notifier.events.isEmpty, completion(isTrue));
});
```

#### 5.6: onLoadStart ignored during exiting
```dart
test('onLoadStart is ignored when state is exiting', () async {
  await notifier.initializePlayer(...);
  await notifier.requestExit();
  
  final stateBefore = notifier.state;
  notifier.onLoadStart();
  expect(notifier.state, stateBefore);
});
```

> **Commit**: `test(game/player): add edge case coverage for notifier lifecycle`

---

## ✅ Checklist xác nhận hoàn tất

- [ ] T1: `GamePlayerStage` → `GamePlayerLoadingStage` — build_runner pass
- [ ] T2: Không còn Vietnamese string trong notifier
- [ ] T3: `_updateStage` → `_transitionToLoading`
- [ ] T4: `_cancelAllTimers()` helper — dùng ở 5 call sites
- [ ] T5: 6 edge case tests pass
- [ ] `flutter test test/features/game/player/` — ALL GREEN
- [ ] `flutter analyze` — no new warnings

# Mini Game — Integration Notes

> Working document. Append any JS↔Flutter mismatch you discover while porting.
> Link to plan v1.4.1 at `~/.claude/plans/ch-ng-ta-s-l-m-sorted-lake.md`.

---

## File layout — deviation from plan §6.1

| Plan §6.1 said | Actual location | Why |
|---|---|---|
| `lib/mini_game/` (top-level) | `lib/features/mini_game/` | Sport app convention is `lib/features/<name>/` — keeps mini game discoverable alongside `auth/`, `casino/`, `sport/`, etc. |
| `kim_cuong_message.dart` + `mini_poker_message.dart` + `dragon_ball_message.dart` (3 files) | `slot_message.dart` (1 file) | Wire shapes identical across all 3 slot games — they only differ by `gid` payload. Discriminator is the `SlotGameId` enum baked into each variant. 3 sender classes still exist (`MiniPokerSender`, `KimCuongSender`, `DragonBallSender`) for ergonomic call sites. |

If sport team / Flutter team prefer the literal plan layout, splitting `slot_message.dart` into 3 thin re-export files is a one-commit refactor.

---

## JS source → Flutter file mapping

| JS file | Flutter file |
|---|---|
| `CCMiniGameRoot.ts` (config URL) | `config/mini_game_config_loader.dart` |
| `MiniGameNetworkHandler.ts:127-144` (login packet) | `socket/mini_game_socket_client.dart` (`connect()`) |
| `MiniGameNetworkHandler.ts:18-35` (enums) | `socket/enums.dart` |
| `MiniGameNetworkHandler.ts:119-125` + `SocketManager.setPingTimeout` (ping) | `socket/mini_game_ping_manager.dart` |
| `Downloader.ts:22-130` (zip extract) | `downloader/mini_game_downloader.dart` (`downloadAndExtractZip`) |
| `Downloader.ts:398-430` (version check) | `downloader/mini_game_downloader.dart` (`checkVersion`) |
| `TaiXiuMessageHandler.ts` | `messages/tai_xiu_message.dart` + `TaiXiuSender` |
| `TrenDuoiMessageHandler.ts` | `messages/tren_duoi_message.dart` + `TrenDuoiSender` |
| `MiniPokerMessageHandler.ts`, `KimCuongMessageHandler.ts`, `DragonBallMessageHandler.ts` | `messages/slot_message.dart` (shared) + 3 senders |

---

## JS quirks worth flagging when reviewing

### `info` is a JSON string on the wire (not an object)

`MiniGameNetworkHandler.ts:172` does `JSON.stringify(data["info"])` before writing
to `cc.sys.localStorage`. Flutter sport app mirrors this at `sb_login.dart:236`
with `jsonEncode(data['info'])`. Therefore the WS login packet field is:

```json
{"info": "<stringified JSON>", "signature": "<plain string>"}
```

Do **not** double-decode — pass through as-is.

### `useWSJSON` string equality footgun

JS: `GlobalVariables.useWSJSON == "true"` (string equality, NOT boolean).
If Backend ever changes config from `"useWSJSON": "true"` to `"useWSJSON": true`
(JSON boolean), JS silently falls back to binary mode. Flutter's
`_boolFromString` handles both — but coordinate the migration steps in plan §1.3
to keep JS web stable.

### `.fnt` (BMFont) currently dropped on extract

`Downloader.ts:67-72` only whitelists `.png` / `.atlas` / `.json`. If any game
zip contains BMFont files, JS silently skips them. Flutter [`MiniGameDownloader`]
accepts a `allowFnt` flag — flip to `true` after Inv #1 audit (plan §11) shows
which zips contain `.fnt`.

### Ping response schedules the next ping

Per `SocketManager.setPingTimeout`, ping starts after login success, then each
`Ping_Response` schedules the next ping after `GAME_DEFINE.PING_INTERVAL_MS`
(2 seconds). Flutter mirrors this with `MiniGamePingManager`; it also adds a
5-second response timeout that triggers reconnect if a ping response never
arrives.

---

## Lobby bootstrap pattern — `miniGameLobbyProvider`

JS `CCMiniGameRoot` boots eagerly on app start: fetch config → WS connect →
on `LogIn_Response` → subscribe 5 games. Cocos app = mini game only, so eager
makes sense there.

Flutter sport app is multi-feature — eager-loading mini game on every cold
start wastes bandwidth for users who don't touch it. To match the JS
behavioral intent while keeping module API decoupled, the bootstrap is
**opt-in via Riverpod composition**:

```dart
// In your lobby screen (or authenticated shell):
final client = await ref.watch(miniGameLobbyProvider.future);
// → fetches config, connects WS, auto-subscribes 5 games on auth response.
// → from here, watch taiXiuMessageStreamProvider / slotMessageStreamProvider(...)
//   for live session pushes (countdown, jackpot updates, etc.)
```

**Asset downloads remain lazy per-game** (matches JS exactly — see
`TrenDuoiGameView.ts:276` which calls `Downloader.checkVersion` inside its
own `onLoad`). Wire your game screen to call
`(await ref.read(miniGameDownloaderProvider.future)).downloadAndExtractZip(...)`
when the user taps a game card.

**Recommended boot timing**:

| Trigger | Action |
|---|---|
| User completes sport login | `SbConfig.wsToken/mainWsLoginInfo/Signature` populated. **No mini game traffic yet.** |
| User navigates to "Mini Game" tab in lobby | Watch `miniGameLobbyProvider` → WS connect + auto-subscribe. Thumbnails start receiving session info for countdowns. |
| User taps a specific game card | Show download progress (lazy zip download). On `done`, navigate to game UI. |

## App-wide UI overlay (`MiniGameFloatingOverlay`)

The trophy FAB + radial menu is wired app-wide via a single wrap in
[lib/app.dart](../../app.dart) inside `MaterialApp.router`'s `builder`:

```dart
builder: (context, child) => buildBaseApp(
  context,
  MiniGameFloatingOverlay(
    child: NetworkManagerListener(...),
  ),
),
```

The overlay handles its own auth gating + lobby bootstrap; pre-login screens
see `child` unchanged. To revert, delete the wrap + the import — 4-line change.

To wire game navigation (replace default snackbar feedback), pass
`onGameSelected: (context, game) => GoRouter.of(context).go(...)`.

### Boot sequence (verified against JS — bro confirmed)

JS Cocos webview behavior:
1. App boot → Cocos loads bundled assets (icons + UI sprites) — "tải về 1 lúc"
2. WS connect → on `loginResponse` → subscribe 5 games
3. Trophy FAB shows; countdown badge updates from server pushes
4. User taps FAB → radial menu (icons already loaded)
5. User taps a game thumbnail → `Downloader.checkVersion` + `downloadAndExtractZipData`
   → load that game's zip → enter game

Flutter port:
1. App boot → Flutter loads bundled PNGs from `assets/images/mini_game/` (declared in pubspec)
2. Sport login completes → `MiniGameFloatingOverlay` becomes active → watches
   `miniGameLobbyProvider` → WS connect + auto-subscribe 5 games
3. Trophy FAB appears; countdown badge updates via `miniGameCountdownProvider`
4. User taps FAB → `MiniGameRadialMenu` modal (icons already bundled)
5. User taps a thumbnail → caller's `onGameSelected` fires; navigation handler
   should call `MiniGameDownloader.downloadAndExtractZip` for that game's zip
   before entering the game UI (Phase 2)

### Asset attribution

All 9 PNGs in `assets/images/mini_game/` are verbatim copies from the JS Cocos
project's bundled resources at
`/sb-s-213/assets/minigames/resources/cc-mini-game-node/sprites/`:

| Flutter path | JS source | Used in |
|---|---|---|
| `mng_btn.png` | same | Closed FAB icon + central decoration in menu |
| `mng_bg.png` | same | Radial menu background |
| `mng_btnfx.png` | same | FAB glow halo |
| `mng_timebg.png` | same | Countdown badge background |
| `mng_taixiu.png` | same | TaiXiu thumbnail |
| `mng_caothap.png` | same | TrenDuoi thumbnail (`caothap` = "cao thấp" = up/down) |
| `mng_trungphucsinh.png` | same | KimCuong thumbnail (`trungphucsinh` = "trứng phục sinh" = easter egg / diamond) |
| `mng_minipoker.png` | same | MiniPoker thumbnail |
| `mng_dball.png` | same | DragonBall thumbnail |

The "FIFA"-branded trophy in the user's reference screenshot is a different
brand variant. To swap, replace `mng_btn.png` (and update `mng_bg.png` if the
host frame differs) — no code changes needed.

### Countdown semantics

`miniGameCountdownProvider` subscribes to `taiXiuMessageStreamProvider` and
`trenDuoiMessageStreamProvider`:

- TaiXiu: takes `remainingTimeSec` from `TaiXiuSubscribeInfo` (cmd 1005).
- TrenDuoi: takes `remainingTimeMs / 1000` from `TrenDuoiInfoGame` (cmd 1500).
- Slot games (MiniPoker, KimCuong, DragonBall): no session timer (spin-based);
  thumbnails render without a countdown badge.

Between server pushes, a local 1Hz `Timer` decrements the displayed seconds.
On new INFO message, the value resets to the server-provided snapshot.

The FAB badge shows the **minimum** non-null seconds across TaiXiu/TrenDuoi
("next thing about to happen"). Each thumbnail in the menu shows its own
game's seconds independently.

## Outstanding questions / pings

See plan v1.4.1 §9.1 for the full list. Critical ones blocking forward progress:

- [ ] **Sport-1**: SbConfig needs `wsCredentialsVersion ValueNotifier` (Day 2 block; falls back to polling per plan §10 Option B if delayed).
- [ ] **JS-F1.1**: server's concurrent-WS-per-token limit. Sport already runs 2 (mainWs + chatWs); mini game = 3rd. Confirm before Phase 1C commits.
- [ ] **BE-N5**: staging WS URL + 2 test accounts (block end-to-end smoke).

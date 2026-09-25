# Mini Game — Behavior Deviations from JS

> Per plan v1.4.1 §12. Each row documents an intentional divergence from the
> JS reference behavior. If you discover an unintentional mismatch, file it in
> `INTEGRATION_NOTES.md` instead.

| # | JS behavior | Flutter behavior | Reason |
|---|---|---|---|
| **D1** | Stores password plain-text in `localStorage` under `user_password` (`MiniGameNetworkHandler.ts:172`). | **Does not touch credentials at all** — reads only from `SbConfig` in-memory snapshot. Path A architecture (plan §2). | Sport app is the single source of token truth. Eliminates the JS plain-text password security risk entirely. |
| **D2** | Mini game calls `loginAccessToken` HTTP endpoint independently. | **Skips HTTP auth** — reuses `SbConfig.wsToken/mainWsLoginInfo/mainWsLoginSignature` populated by sport `SbLogin.refreshToken()`. | Both Flutter sport and JS mini game hit the same backend with identical response shape; sport already populates the same fields → no duplicate call. |
| **D3** | `Downloader` HTTP retry is unbounded (`Downloader.ts:472-498`). | Dio retry capped at **5 attempts**, explicit backoff `[1, 2, 4, 8, 16]s` (total ~31s worst case). | Prevents battery drain / hang when CDN is unavailable for extended periods. |
| **D4** | `extractZipData` whitelists `.png` / `.atlas` / `.json` only (`Downloader.ts:67-72`). BMFont `.fnt` is silently dropped. | [`MiniGameDownloader`] accepts an `allowFnt` flag (default `false` to mirror JS). Flip to `true` if Inv #1 audit (plan §11) shows any game zip contains `.fnt`. | JS bug — silent BMFont drop causes missing fonts in some games. Flutter exposes the toggle so the team can opt in when needed. |
| **D5** | Concurrent downloads have no upper bound (JS uses `Future.wait`-style fire-all). | Currently mirrors JS — no semaphore. Add semaphore (limit 5-10) if Phase 2 perf metrics show network congestion. | Defer until evidence. |
| **D6** | Web has no asset cache — every session re-downloads from CDN. | Phase 1 mirrors JS — relies on browser HTTP cache + CDN `Cache-Control` headers (Backend responsibility, see plan §4.8). | Phase 1 priority is 1:1 behavior parity. IndexedDB caching is a Phase 2+ discussion. |
| **D7** | JS `CCMiniGameRoot` boots eagerly on app start: fetch config → WS connect → subscribe 5. | Eager boot is **opt-in** via `miniGameLobbyProvider` — caller watches it when the user enters the mini game tab. Asset download stays lazy per-game (matches JS `TrenDuoiGameView.onLoad`). | Sport app is multi-feature; cold-start should not pay for mini game WS for users who never open the tab. The lobby provider gives the lobby screen 1-line eager opt-in. |
| **D8** | JS Cocos bundles lobby UI sprites (trophy + 5 thumbnails + bg) inside the Cocos build — loaded automatically by the engine on boot. | Flutter bundles the same 9 PNGs in `assets/images/mini_game/` declared in `pubspec.yaml`. Loaded via `Image.asset(...)` on widget mount; no runtime HTTP. | Direct functional parity. Asset cost (~177 KB) is negligible compared to a separate HTTP fetch per session, and the icons rarely change. Branded variants can be swapped by replacing the PNGs without code changes. |

---

## Phase 1 deferred items (Phase 2 candidates)

These are intentional Phase 1 cut-outs, not bugs:

- **Binary MessagePack codec** ([`BinaryMessageCodec`]) — stubbed with
  `UnimplementedError`. Set `useWSJSON=true` in remote config for Phase 1.
  Phase 2: implement via `messagepack` or `msgpack_dart` pub package; verify
  byte-identical encode/decode against JS `msgpack-lite` before flipping
  config to binary mode.

- **Dispatcher pattern for game streams** — current `mini_game_message_streams.dart`
  has each per-game `StreamProvider` independently listen to the client's
  broadcast `messageStream` and filter. For Phase 1's expected message rate
  this is fine; if S1 metrics (plan §9.1) show high msg/sec, refactor to a
  single dispatcher with N controllers.

- **R10 — FutureProvider rebuild guard** — when sport refreshes credentials,
  `miniGameAuthProvider` re-executes, which can cycle `miniGameSocketProvider`
  through loading → data and create two `MiniGameSocketClient` instances
  briefly. Phase 2 mitigation: use `ref.listen` (explicit subscribe) + state
  machine guard in the notifier.

- **Reactive credential refresh** — currently relies on `ref.invalidate` or
  reconnect path re-reading `SbConfig` snapshot. Once sport team lands the
  `ValueNotifier<int> wsCredentialsVersion` per Sport-1, wire it into
  `sbCredentialsVersionProvider` (currently emits empty stream — see TODO(F4)).

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0+1] - 2026-04-15

### Added

- **`PlatformUiConfig`** — Immutable configuration model with preset constructors:
  `.immersive()`, `.normal()`, `.splash()`. Extensible for future fields
  (status bar color, nav bar color, brightness).
- **`FullscreenGateRequest`** — String-tagged request model for gate activation.
  Supports `isRequired` flag to distinguish blocking vs informational gates.
- **`PlatformUiController`** — Abstract interface for platform UI control
  with `ValueListenable<bool> isFullscreen` for reactive state observation.
  - `PlatformUiControllerWeb` — Web implementation using browser
    Fullscreen API, `fullscreenchange` event listener, scroll-blocking hack,
    and PWA standalone detection via `display-mode: standalone` media query.
  - `PlatformUiControllerNative` — Native implementation using
    `SystemChrome.setEnabledSystemUIMode` for immersive/edge-to-edge modes.
  - `PlatformUiControllerStub` — Stub for unsupported platforms
    (throws `UnsupportedError`).
  - Conditional imports factory (`platform_ui_controller_factory.dart`)
    auto-selects the correct implementation at compile time.
- **`FullscreenGuardController`** — `ChangeNotifier` implementing the gate
  state machine:
  - `request()` / `satisfy()` / `clear()` lifecycle.
  - Auto re-gate when fullscreen is lost externally (e.g., user presses Esc).
  - Auto-satisfy in PWA standalone mode.
  - Accepts optional `PlatformUiController` for dependency injection in tests.
- **`FullscreenGuard`** — Single root widget combining `InheritedWidget` +
  gate overlay management:
  - `FullscreenGuard.of(context)` → `FullscreenGuardController`.
  - `FullscreenGuard.controllerOf(context)` → `PlatformUiController`.
  - `gateBuilder` parameter for custom gate UI (defaults to `FullscreenGateView`).
- **`FullscreenGateView`** — Default animated gate overlay UI with
  parameterized title, subtitle, colors, and icons. Supports tap and
  swipe-up gestures.
- **`FullscreenGateBuilder`** typedef for custom gate UI builders.

### Fixed & Workarounds

- **iOS Safari Minimal UI Swipe Gate**: Resolved the gap issue at the bottom of the screen when entering Minimal UI. Flutter's canvas (`flt-glass-pane`) is now preemptively sized to `100lvh` via CSS. This forces the browser to render the full viewport *before* the native toolbar disappears. A `window.onResize` listener was also added to automatically fall back to the swipe gate if the user taps the screen and reveals the toolbar again.

### Architecture

- **Zero state management dependency** — pure Flutter (`InheritedWidget` +
  `ChangeNotifier`). No Riverpod, Bloc, or other external packages.
- **2-layer controller design**: `PlatformUiController` (platform API) +
  `FullscreenGuardController` (gate logic) — cleanly separated concerns.
- **Extensible model**: add fields to `PlatformUiConfig` without changing
  gate logic or widget code.

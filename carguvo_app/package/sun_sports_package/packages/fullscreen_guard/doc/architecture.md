# Architecture Design: Fullscreen Guard

## 1. Overview

The `fullscreen_guard` package employs a **Strategy Pattern** to separate fullscreen logic into independent classes. Each class encapsulates **one way** to achieve fullscreen on **one specific platform**.

## 2. Layered Architecture

```text
┌──────────────────────────────────────────────────┐
│                    App Layer                      │
│   PlatformUiGuard → FullscreenGuard → App        │
└───────┬─────────────────────────┬────────────────┘
        │                         │
  ┌─────▼─────────┐     ┌───────▼──────────────┐
  │  Core Layer    │     │  Plugin Layer         │
  │  platform_ui/  │     │  fullscreen_guard/    │
  │                │     │                       │
  │ PlatformUi     │◄────│ FullscreenGuard       │
  │  Controller    │uses │  Controller           │
  │ PlatformUi     │     │                       │
  │  Config        │     │ FullscreenStrategy    │◄── Abstract
  │ PlatformUi     │     │  ├ NativeImmersive    │
  │  Guard         │     │  ├ DomFullscreen      │
  └────────────────┘     │  ├ SafariMinimalUi    │
                         │  └ PwaStandalone      │
                         │                       │
                         │ StrategyFactory       │◄── Conditional import
                         │ GateView / Request    │
                         └───────────────────────┘
```

## 3. Core Components

### 3.1. `PlatformUiGuard` & `PlatformUiController` (Core Layer)
- **Responsibility:** Manages the system UI (status bar, navigation bar) colors and visibility.
- **Source of Truth:** `PlatformUiGuard` acts as the source of truth for the app's default "branded" look. It ensures that when a sub-feature finishes (e.g., exiting a game), the UI reverts to this base configuration.
- **No Gate Logic:** This layer knows nothing about user gestures or fullscreen gate overlays.

### 3.2. `FullscreenGuard` & `FullscreenStrategy` (Plugin Layer)
- **Responsibility:** Manages entering and exiting fullscreen modes, specifically dealing with browser restrictions that require user interaction (the "Gate").
- **Strategies:**
  - `NativeImmersiveStrategy`: Calls `SystemChrome` for Android/iOS. Always auto-satisfies (no gate).
  - `DomFullscreenStrategy`: Uses the standard HTML5 Fullscreen API for Chrome/Firefox/Safari Desktop. Requires a gate overlay.
  - `SafariMinimalUiStrategy`: Uses a scroll trick (`window.scrollTo(0,1)`) to collapse the Safari toolbar on iOS Web since Apple blocks the Fullscreen API on iPhones. Requires a gate overlay (swipe up).
  - `PwaStandaloneStrategy`: Detects if the app is installed as a PWA (`display-mode: standalone`). Auto-satisfies because the browser chrome is already hidden.

## 4. The "Gate" Lifecycle

1. App requests fullscreen: `FullscreenGuard.of(context).request(...)`
2. Controller checks the current strategy (`needsUserGesture`).
3. If gesture is needed (e.g., Safari iOS), the `FullscreenGateView` overlay appears.
4. User interacts (taps or swipes up).
5. `FullscreenGuardController.satisfy()` is called.
6. Strategy executes its specific logic (e.g., `element.requestFullscreen()`).
7. User presses Escape or the app calls `clear()`.
8. Strategy exits fullscreen.
9. `PlatformUiGuard` detects the change and automatically restores the default System UI configuration.

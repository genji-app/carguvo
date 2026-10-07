# fullscreen_guard

A robust fullscreen and system UI chrome management package for Flutter. Provides a clean, extensible API for controlling fullscreen mode, system UI overlays, and related platform features across web, Android, iOS, and macOS.

## Core Concepts

The package is built on three main layers:
1. **`PlatformUiController`**: The execution layer. Handles direct calls to native APIs (`SystemChrome`) or Web APIs.
2. **`PlatformUiGuard`**: The management layer. Acts as the source of truth for the app's "Base" UI configuration. It manages the controller's lifecycle and ensures the branded look is maintained (e.g., after returning from a game's fullscreen mode).
3. **`FullscreenGuard`**: The interaction layer. Manages the "Gate" logic (user gesture requirements) specifically for entering/exiting immersive modes.

## Features

- **Declarative System UI** — Use `PlatformUiGuard` to define how your app should look by default.
- **Cross-platform fullscreen management** — Web (Fullscreen API), Native (SystemChrome).
- **Gesture requirement handling** — Automatically manages gate overlays for browsers that require user interaction.
- **Auto-restore mechanism** — `PlatformUiGuard` detects app lifecycle changes (like returning to foreground) and ensures your UI config is re-applied.
- **Extensible design** — `PlatformUiConfig` supports status bar/nav bar colors, brightness, and visibility.
- **Zero state management dependency** — Pure Flutter `InheritedWidget` + `ChangeNotifier` pattern.

## Quick Start

### 1. Initialize the Base UI

Wrap your app root (usually in `app.dart`) with `PlatformUiGuard`. This is where you define your app's standard look.

```dart
PlatformUiGuard(
  initialConfig: const PlatformUiConfig.branded(),
  child: MaterialApp(...),
)
```

### 2. Add Fullscreen Support

Wrap specific parts of your app (or the whole app) with `FullscreenGuard` to enable the fullscreen gate mechanism.

```dart
FullscreenGuard(
  // Automatically links to the nearest PlatformUiGuard's controller
  platformUiController: PlatformUiGuard.of(context),
  child: MyGameScreen(),
)
```

### 3. Request Fullscreen

```dart
FullscreenGuard.of(context).request(
  const FullscreenGateRequest(tag: 'game_id_123'),
);
```

### 4. Clear when done

```dart
// This will restore the UI to the initialConfig defined in PlatformUiGuard
FullscreenGuard.of(context).clear();
```

## API Reference

### `PlatformUiGuard` (Widget)
Manages the lifecycle of a `PlatformUiController`.
- `initialConfig`: The default configuration (e.g., status bar color, visibility).
- `controller`: (Optional) An external controller if you're using a DI container like Riverpod.
- `PlatformUiGuard.of(context)`: Access the controller from descendants.

### `FullscreenGuard` (Widget)
The gatekeeper for fullscreen mode.
- `gateBuilder`: Customize the UI that asks the user to "Tap to enter fullscreen".
- `FullscreenGuard.of(context)`: Access the `FullscreenGuardController`.

### `PlatformUiConfig` (Data Class)
A declarative way to describe System UI state.
- `PlatformUiConfig.branded()`: Standard app look (visible bars, specific colors).
- `PlatformUiConfig.immersive()`: Hide all bars for focus.
- `PlatformUiConfig.splash()`: Custom look for splash screens.

## Platform Support

| Platform | Fullscreen Implementation | System UI Control |
|----------|---------------------------|-------------------|
| **Android / iOS** | `SystemChrome` (Immersive) | Status/Nav bar colors & icons |
| **Web (Desktop)** | Browser Fullscreen API | N/A (Handled by browser) |
| **Web (Mobile)** | Scroll-to-hide (Minimal UI) | N/A |
| **PWA** | Standalone Mode detection | N/A |

## Design Philosophy

- **Surgical Changes**: Only modify what's needed.
- **Platform Agnostic**: Your UI code shouldn't care if it's running on a MacBook or an Android phone.
- **Predictable Restore**: When a feature (like a game) finishes using fullscreen, the app should automatically snap back to its original branded state.

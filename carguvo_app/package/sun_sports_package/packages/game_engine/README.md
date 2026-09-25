# Package: game_engine 🎮

A specialized Flutter package providing high-performance WebView rendering engines for game integration. It provides two core engines: **IHRunner** for in-house/proprietary games and **PLRunner** for 3rd-party provider/live-stream content.

---

## 🚀 Key Features

- **IHRunner (InHouseGameRunner)**: Optimized specialized runner for proprietary/in-house games using the custom host bridge protocol (e.g., Cocos Creator games).
- **PLRunner (ProviderLiveRunner)**: Specialized runner for 3rd-party Live Casino and streaming games, optimized for interactive vendor content.
- **Refactored Performance Architecture**: Leaner and faster `Ctrl` (Controller) logic with unified platform handling.
- **Platform-Abstraction Layer**: Source code organized by `inapp/`, `html_iframe/`, `web/`, and `_plugins/` directories for maximum maintainability.
- **Unified Bridge Messaging**: Intelligent communication system via `GameHostEvent` and the consolidated `GameBridgeMixin`.
- **Customizable Runner States**: Modular `IHRunnerState` (idle, loading, loaded, error) for deep integration with UI loading screens.
- **Advanced Resource Management**: Automatically stops media playback (audio/video) and releases resources (WebView dispose) upon widget removal.
- **Smart Layout Handling**: Built-in `KeyboardObserverMixin` prevents UI glitches by gracefully handling virtual keyboard dismissals during screen rotations. It includes advanced debouncing and DOM layer locking (`position: fixed`) for perfect iOS WebView keyboard synchronization.
- **Safe Plugin Architecture**: Plugins are segregated into `plugins.dart` (Mobile/Cross-platform) and `web_plugins.dart` (Web-only), ensuring zero compile-time conflicts with `dart:js_interop` when building for iOS/Android.
- **Visual Stability**: Built-in support for transparent WebView backgrounds to prevent white flashes and provide seamless transitions with Flutter-based loading screens.
- **Auto Injection**: Built-in script injection for `window.FlutterChannel` shim via `IHRunnerScripts`, ensuring 100% compatibility for both new and existing games.

---

## 📦 Installation

Add the package path to your project's `pubspec.yaml`:

```yaml
dependencies:
  game_engine:
    path: packages/game_engine
```

---

## 📖 Usage Guide

### 1. Running a Game with IHRunner

The simplest way to run a game:

```dart
IHRunner(
  gameUrl: 'https://cdn.games.com/my-awesome-game',
  onLoadStart: () => print('Game started loading'),
  onLoadStop: () => print('Game finished loading'),
  onHostMessage: (event) {
    if (event.isCloseWebView) {
      Navigator.pop(context);
    }
  },
)
```

### 2. Advanced: Using IHRunnerCtrl

For programmatic control (reloading, sending messages, evaluating JS):

```dart
// 1. Create a controller
final ctrl = IHRunnerCtrl.inApp();

// 2. Pass to the runner
IHRunner(
  gameUrl: '...',
  controller: ctrl,
);

// 3. Send message TO the game
ctrl.sendMessage(GameHostEvent(type: 'BONUS_REWARD', data: {'amount': 100}));
```

### 3. Monitoring Game States

Use `onStateChanged` to react to loading or error statuses:

```dart
ctrl.onStateChanged.listen((state) {
  if (state == IHRunnerState.error) {
    showErrorDialog('Failed to load game');
  }
});
```

### 4. Running a 3rd-Party Live Game with PLRunner

```dart
PLRunner(
  gameUrl: 'https://vendor-live-stream.com/baccarat',
  onLoadStart: () => print('Loading live game...'),
  onLoadStop: () => print('Game ready!'),
  onError: (error) => print('Provider error: $error'),
  forceLandscapeViewport: true, // Recommended for most live games
)
```

---

## ⚠️ Platform Considerations & Troubleshooting

### Android: WebGL and Transparent Backgrounds
When loading web games that rely heavily on **WebGL** (e.g., Cocos, PixiJS, Unity WebGL) on Android, you must set `transparentBackground: false` in `InAppWebViewSettings`. 
Setting this to `true` can cause severe rendering issues on Android System WebView, including:
- **Black Screens:** The WebView fails to compute the alpha layer for the WebGL canvas.
- **Flickering & FPS Drops:** Hardware-accelerated blending between the WebGL surface and native Flutter widgets consumes excessive GPU resources.
- **WebGL Context Loss:** The browser may fail to initialize the WebGL context entirely.

### Android: Native Fullscreen & White Screen Issues
When a game uses the HTML5 `requestFullscreen()` API, Android's `InAppWebView` attempts to create a native `FrameLayout` overlay. If the Flutter WebView widget is disposed (`Navigator.pop()`) while this native overlay is still active, the app may become completely white or unresponsive.
- **Solution:** `IHRunner` automatically injects a **Soft Fake Fullscreen** script on Mobile platforms (`blockFullscreen` defaults to `!kIsWeb`). This script intercepts the `requestFullscreen` calls and synthetically dispatches `fullscreenchange` events back to the game. This tricks the game engine (e.g. Cocos) into updating its UI buttons properly, without ever triggering the problematic Android native fullscreen mode.

*Note: iOS (`WKWebView`) handles transparency better, but `false` is still recommended for maximum game performance.*

### iOS: Cross-Origin SecurityErrors
When running games on iOS, you may see errors like `SecurityError: Blocked a frame with origin "..." from accessing a cross-origin frame.` in the console.
- **Cause:** iOS `WKWebView` enforces a very strict **Same-Origin Policy (SOP)**. If the game's JavaScript attempts to access `window.parent`, `window.top.location.href`, or `window.history` across different domains, WebKit will block it and throw a `SecurityError`.
- **Impact:** This typically **does not crash** the Flutter application. If the game continues to run normally, these warnings can be safely ignored.
- **Fix:** If the game fails to load or communicate due to this, the game provider must update their web code to use `window.postMessage` for cross-origin iframe communication instead of directly accessing parent window properties.

### Firefox: Iframe Sandbox & Scrolling Issues
When running web-based games and livestreams on Firefox (Desktop & Mobile), you may encounter black screens or unwanted scrollbar/viewport-panning behaviors.
- **Cause 1 (Black Screen):** Flutter 3.27+ `HtmlElementView` wraps iframe platform views in HTML slots and automatically injects a default, highly restrictive `sandbox` attribute. Firefox enforces sandbox attributes strictly for WebGL contexts; if key sandbox permissions (like `allow-forms`, `allow-popups-to-escape-sandbox`, `allow-downloads`) are missing, the WebGL context fails to initialize, rendering a black screen.
- **Cause 2 (Scrolling & Gestures):** Iframes on Firefox and mobile browsers can display scrollbars or allow touch-panning if default inline spaces or overscroll behaviors are not handled defensively.
- **Solution:** Both `IHHtmlIframeRunnerView` and `PLHtmlIframeRunnerView` automatically override the sandbox attribute to grant all necessary permissions, set `iframe.src` as the final instruction to ensure the browser applies the updated policy on load, and apply defensive CSS properties (`touch-action: none`, `overscroll-behavior: none`, `user-select: none`, `overflow: hidden`, and `scrolling="no"`) to disable browser viewport scrolling while keeping game touch interactions intact.

---

## 🔄 Lifecycle & Flow

`game_engine` follows a strictly event-driven architecture:

1. **Initialization**: Widget build triggers bridge script injection via `GameBridgeMixin`.
2. **Loading**: Emits states through `onLoadStart` and `onLoadStop`.
3. **Bridge Ready**: `FlutterChannel` handler is registered and ready for bi-directional traffic.
4. **Web Support**: On Web, `WebMessageListenerMixin` automatically handles `postMessage` traffic and routes it to the controller.
5. **Active State**: Game emits `GameHostEvent`s; Flutter listens and reacts.
6. **Termination**: WebView automatically navigates to `about:blank` and disposes of resources when the widget is popped.

---

## 🛠️ Development & Testing

- **Tests**: Navigate to the package directory and run `flutter test`.
- **Scripts**: JavaScript shims are located directly within their respective `inapp/` directories to maintain high cohesion.
- **Formatting**: Always run `dart format .` before committing changes.
- **Analysis**: Maintain zero issues with `flutter analyze`.
- **Documentation**: All public APIs are fully documented using standard `dartdoc` in English.

---
*Developed by Trippy*

# Changelog

All notable changes to the `game_engine` package will be documented here.

## [Unreleased]

### Fixed
- **Firefox Iframe WebGL & Sandbox**: Overrode default restricted sandbox attributes and deferred setting `iframe.src` to the end of the load cycle in both `IHHtmlIframeRunnerView` and `PLHtmlIframeRunnerView`. This resolves the silent WebGL initialization failures and cross-origin black screen issues on Firefox Web (JS mode).
- **Iframe Scroll & Gestures on Firefox & Mobile**: Integrated defensive CSS styling (`overflow: hidden`, `display: block`, `touch-action: none`, `overscroll-behavior: none`, `user-select: none`) and HTML attributes (`scrolling="no"`) on native iframe elements to completely prevent unwanted scrollbars, panning, viewport zoom, and text selection highlights during gameplay.
- **Native Fullscreen Conflict**: Implemented a "Soft Fake Fullscreen" script in `IHRunner` to intercept `requestFullscreen` API calls. This allows games (like Cocos) to visually update their UI states correctly without triggering the Android OS native CustomView, effectively fixing the "white screen on pop" issue.

### Refactored
- **PLRunner Architecture**: Extracted web dispatcher into `PLRunnerWebImpl` and renamed `PLRunnerPlatform` to `PLRunnerBase` for better semantic accuracy and cleaner compile-time conditional imports.
- **Project Structure**: Renamed `plugins` directory to `_plugins` to prioritize its position in the IDE file explorer.
- **Architectural Cleanup**: Merged `GameMediaControlMixin` directly into `IHInAppRunnerCtrl` and eliminated redundant web post-load scripts by routing through a centralized `forceGameResize()`.
- **Keyboard Stability**: Introduced `KeyboardObserverMixin` within `_plugins` to automatically handle native keyboard dismissals and UI repaints on device rotation. Implemented robust debouncing and `position: fixed` viewport locking to prevent iOS WebViews from suffering the "scroll drop" layout bug when activating the virtual keyboard.
- **Plugin Separation**: Segregated internal plugins into `plugins.dart` (safe for Mobile/Cross-Platform) and `web_plugins.dart` (Web exclusively) to prevent `dart:js_interop` compilation failures on Mobile target deployments.
- **Code Standardization**: Translated remaining Vietnamese comments to English and ensured 100% compliance with `dartdocs` standards.

## [1.4.1] - 2026-05-15


### Fixed
- **Visual Stability**: Enabled transparent background for both `IHRunner` and `PLRunner` (Mobile and Web) to prevent white flashes during orientation changes and ensure Flutter loading overlays are visible during the entire game initialization phase.

## [1.4.0] - 2026-04-02

### Refactored
- **IHRunner Bridge & Listener Architecture**: Simplified the internal bridge logic by merging `BaseBridgeMixin` and `IHRunnerBridgeMixin` into a single `GameBridgeMixin`.
- **Standalone Event Model**: Extracted `GameHostEvent` into its own file (`lib/src/ih_runner/game_host_event.dart`) for better isolation and testability.
- **Unified JS Scripts**: Centralized all JavaScript shims and fixes into `IHRunnerScripts` located in `lib/src/ih_runner/scripts/ih_runner_scripts.dart`.
- **Logic Decoupling**: Moved bridge injection and platform-specific fixes from `IHInAppRunnerView` to `IHInAppRunnerCtrl`.
- **Automated Web Listener**: Integrated `WebMessageListenerMixin` directly into the IHRunner pipeline, automating message parsing for Web platforms.

### Added
- **Diagnostic Logging**: Added direct logging for `onReceivedError` in `IHInAppRunnerView` to improve troubleshooting for failed page loads.
- **Bridge Configuration**: Added `enableHostMessage` flag to `IHRunnerCtrl` to allow fine-grained control over bridge injection.

### Fixed
- **JS Interop Type Safety**: Updated Web Message Listener to use `isA<web.MessageEvent>()` for compliant runtime type checks on Web.

## [1.3.0] - 2026-03-30
<truncated 112 lines>

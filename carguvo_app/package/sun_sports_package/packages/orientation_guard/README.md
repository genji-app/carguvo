# orientation_guard

A robust cross-platform orientation management package for Flutter. It provides a unified API for forcing orientation on native platforms (Android, iOS) and guarding viewports on Web.

## Features

- **Unified API**: Control orientation using a single `OrientationPolicy` for all platforms.
- **Native Force**: Programmatically force physical rotation on Android and iOS using `SystemChrome`.
- **Web Guard**: Detect viewport orientation on Web and display a guided UI (mismatch view) when the requirement isn't met.
- **Adaptive Breakpoints**: Categorize devices into Mobile, Tablet, and Desktop using standard shortest-side breakpoints.
- **Immersive Mode**: Easily toggle full-screen (immersive) mode.
- **Lifecycle Safety**: Automatic restoration of previous orientation/UI state when a guarded screen is disposed.
- **Extension-friendly**: Easily resolve custom domain models (e.g., `GameBlock`) into orientation policies.

## Usage

### 1. Global Setup

Wrap your `MaterialApp` with `GlobalOrientationOrchestrator` to provide the default orientation behavior.

```dart
final orientationController = kIsWeb 
    ? const WebOrientationController() 
    : const NativeOrientationController();

GlobalOrientationOrchestrator(
  controller: orientationController,
  child: MaterialApp(...),
)
```

### 2. Guarding a Special Screen

Use `OrientationGuard` or `OrientationOverride` to enforce a specific orientation on a particular screen (e.g., a Game Player).

```dart
@override
Widget build(BuildContext context) {
  return OrientationGuard(
    policy: OrientationPolicy(
      targets: DeviceOrientations.landscape,
      debugLabel: 'ImmersiveGame',
      screenUi: const ScreenUiPolicy(immersive: true),
    ),
    child: MyGameView(),
  );
}
```

### 3. Adaptive Logic

The `OrientationAdaptiveResolver` provides standard breakpoints to determine the best orientation for the current device size.

```dart
final policy = OrientationAdaptiveResolver.resolveDefault(context);
// -> Returns Portrait for Phone, Both for Tablet/Desktop.
```

## Platform behavior

| Platform | Strategy | Result |
| :--- | :--- | :--- |
| **Android / iOS** | **Force** | The device physically rotates or locks to the target. |
| **Mobile Web** | **Guard** | Content is hidden behind a "Please Rotate" overlay until the viewport matches. |
| **Desktop Web** | **Guard** | Content is hidden behind a "Please Resize" overlay if the window is too narrow. |

## Core Components

- **`OrientationPolicy`**: The domain model defining the target (`portrait`, `landscape`, `both`) and UI rules.
- **`OrientationController`**: Abstract service for applying and restoring orientation.
- **`OrientationGuard`**: Widget that monitors orientation state and applies/restores policies via its lifecycle.
- **`OrientationMismatchView`**: The UI shown when the device isn't in the correct orientation.

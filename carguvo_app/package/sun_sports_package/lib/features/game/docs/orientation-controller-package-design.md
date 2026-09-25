# orientation_controller package design

## Overview

`orientation_controller` is proposed as a cross-platform Flutter package that centralizes orientation handling for app-native and web targets under one clean API. On native platforms, it applies orientation and immersive-mode rules through platform services such as `SystemChrome` and the existing `SystemUiService`; on web, it evaluates whether the current viewport satisfies the required orientation and blocks rendering with a guided UI when the target orientation is not met. [cite:6][cite:8][cite:27][cite:36]

This package is designed to solve a real architectural problem already visible in the current codebase: orientation logic exists, but it is distributed across `GameBlock`, `GamePlayerNotifier`, `SystemUiService`, screen widgets, and platform-specific workarounds. `GameBlock` already stores orientation intent through `mobileOrientation` and `tabletOrientation`, while `GamePlayerNotifier.initializePlayer()` currently translates that intent into platform-specific calls and load sequencing. [cite:40][cite:32][cite:27]

The purpose of the package is not only to “set orientation,” but to define a repeatable contract for these responsibilities:

- Resolve the orientation target for a screen or feature.
- Apply native orientation and screen presentation policies when possible.
- Detect whether the current presentation actually matches the target.
- Block screen content when the target cannot or should not yet be satisfied.
- Restore the app to a default state cleanly when the screen is dismissed. [cite:27][cite:36][cite:38]

## 1. Problem statement

### 1.1 Orientation intent exists, but control is fragmented

The current model layer already contains a strong signal for orientation behavior. `GameBlock` includes `mobileOrientation`, `tabletOrientation`, and additional flags such as `forceLandscapeViewport`, `openInNewTab`, and `requiresSessionGuard`. This makes `GameBlock` the natural source of truth for orientation intent, but that intent is not yet fully encapsulated into a reusable platform-agnostic flow. [cite:40]

Today, `GamePlayerNotifier.initializePlayer()` accepts a `GameOrientation` parameter and directly maps it to `systemUi.setPortraitOnly()`, `setLandscapeOnly()`, or `setAllOrientations()`, then hides the system bars, waits for native rotation timing, and finally loads the game URL. That works for the current feature, but it tightly couples feature logic, platform control, and orchestration into a single notifier. [cite:32][cite:27]

### 1.2 Native and web require fundamentally different behavior

Flutter provides official support for setting preferred orientations through `SystemChrome.setPreferredOrientations`, which makes native orientation control possible on Android and iOS. However, Flutter’s broader adaptive design guidance emphasizes responding to screen size and orientation rather than assuming a uniform device-control model across every platform. [cite:6][cite:8]

On web, the problem is different. Orientation is primarily a viewport/browser state, not a device-level UI contract under Flutter’s control. The current internal notes show that Flutter Web game rendering is especially sensitive to when and how the iframe or HTML platform view is mounted during orientation changes. This includes iframe unmounting caused by widget tree instability and incorrect game CSS initialization when the viewport changes during splash/loading. [cite:36][cite:38]

### 1.3 “Apply orientation” does not guarantee “target is satisfied”

On native platforms, requesting a preferred orientation does not guarantee that the user interface is already in the expected orientation at the exact moment the next widget renders. The codebase already includes timing workarounds, including a delay after orientation changes so the WebView does not initialize against stale pre-rotation bounds. [cite:32][cite:36]

This is especially important because there are edge cases where the platform constraints or lifecycle leave the UI in a mismatched state. The internal orientation notes document iPadOS-specific issues such as code 101 errors, stale orientation masks, and cases where the physical device state, app constraint state, and WebView bounds do not align. [cite:36] Therefore, the package must distinguish between “an orientation policy was applied” and “the screen is now actually safe to render.” [cite:36][cite:38]

### 1.4 Current cleanup responsibility is not consistently located

In `player_providers.dart`, `systemUi.restoreDefaultSystemUI()` is currently tied to the `requiresSessionGuard` branch inside `ref.onDispose`. This means a system UI concern is partially gated by a provider-session concern, even though restoring UI state is conceptually a responsibility of the screen lifecycle itself. [cite:29][cite:27]

That kind of coupling is one of the strongest signals that orientation and system presentation behavior should be extracted into a package or infrastructure module with a single lifecycle contract. [cite:29][cite:52]

## 2. Recommended solution

### 2.1 Best solution: a unified cross-platform orientation orchestration package

The best solution is to introduce a dedicated `orientation_controller` package that exposes a single public abstraction for orientation policy and screen presentation control, while internally delegating to platform-specific implementations. On native platforms, it should apply orientation and immersive-screen behavior through a thin native adapter built on `SystemChrome` or the existing `SystemUiService`; on web, it should evaluate the viewport and provide a block-or-render decision instead of attempting unreliable hard locking. [cite:6][cite:8][cite:27][cite:36]

This approach is preferable because it preserves the differences between native and web instead of pretending both platforms can be handled by the same primitive. It aligns with Flutter architecture guidance by separating domain rules from platform integration and keeping feature code focused on intent instead of platform APIs. [cite:52][cite:63]

### 2.2 Why this is stronger than alternative approaches

The most common alternatives are all weaker in this codebase:

| Approach | Strengths | Weaknesses |
|---|---|---|
| Keep logic inside `GamePlayerNotifier` | Fastest short-term path; no new module needed. [cite:32] | Increases coupling; hard to reuse; hard to test independently; orientation concerns stay mixed with game URL loading and session guard orchestration. [cite:32][cite:52] |
| Put everything into `SystemUiService` | Simple single service on native. [cite:27] | Misleading for web because web is not actually a `SystemUi` problem; pushes too much feature logic into a low-level service. [cite:27][cite:36] |
| Lock orientation only and never block UI | Minimal implementation. [cite:6] | Unsafe for web and some iPad flows; does not handle the “target not yet satisfied” state; allows third-party game views to initialize with wrong bounds. [cite:36][cite:38] |
| Use web-only responsive layout without policy layer | Good for simple responsive screens. [cite:8] | Too weak for games or immersive full-screen flows that require strict orientation readiness before render. [cite:36][cite:38] |
| Build `orientation_controller` with native control + web guard | Clear abstraction; reusable; testable; platform-correct; easier to debug and extend. [cite:6][cite:8][cite:36][cite:52] | Requires package design and migration effort; needs lifecycle discipline and clear ownership of system UI concerns. [cite:52] |

### 2.3 Strengths of the package approach

The package approach has several strong advantages:

- **Clear ownership**: orientation policy resolution, application, validation, and cleanup move to one place instead of being distributed across notifier, widgets, and helpers. [cite:32][cite:27][cite:40]
- **Cross-platform correctness**: native uses control APIs; web uses validation and blocking UX; both share the same policy language. [cite:6][cite:8][cite:36]
- **Improved maintainability**: feature modules can depend on a stable API rather than platform implementation details. [cite:52][cite:63]
- **Better debugging**: package-level state and logs can tell whether a failure is caused by policy resolution, native apply failure, mismatch detection, or viewport instability. [cite:36][cite:38]
- **Reuse**: the same package can later support video players, onboarding flows, galleries, and full-screen modules beyond game player. [cite:8][cite:52]

### 2.4 Weaknesses and trade-offs

The package also introduces trade-offs that should be acknowledged early:

- **Higher upfront design cost**: the initial design must be careful, especially around scope boundaries. [cite:52]
- **Need for strict boundaries**: not every system UI rule belongs inside the package; app-global presentation concerns such as splash styling should remain outside if they are unrelated to orientation flow. [cite:27][cite:65]
- **Potential over-generalization**: if the package tries to solve every platform display issue, it may become too broad. It should focus on orientation and screen presentation lifecycle, not all visual shell concerns. [cite:27][cite:52]
- **Migration effort**: code such as `GamePlayerNotifier.initializePlayer()` will need refactoring to consume policies instead of directly switching on `GameOrientation`. [cite:32][cite:40]

## 3. Implementation approach

### 3.1 Design goals

The implementation should follow these goals:

- **Single responsibility**: the package owns orientation orchestration, not unrelated app-shell presentation concerns. [cite:52][cite:63]
- **Explicit platform behavior**: native and web are both supported, but via different strategies. [cite:6][cite:8][cite:36]
- **Source-of-truth architecture**: orientation intent should be resolved from feature/domain data such as `GameBlock` into a package-level policy model. [cite:40]
- **Traceability**: every step should be loggable and inspectable. [cite:36][cite:38]
- **Customizability**: consumers should be able to override mismatch views, tablet breakpoints, restoration policy, and immersive behavior. [cite:8][cite:52]
- **Maintainability**: code should follow Dart package layout conventions and Flutter architecture boundaries. [cite:62][cite:52]

### 3.2 Scope boundaries

The package should own these responsibilities:

- `portrait`, `landscape`, `both` orientation targets. [cite:40]
- Native orientation apply and restore behavior. [cite:27][cite:6]
- Native immersive/full-screen screen presentation behavior. [cite:27]
- Viewport-orientation validation on web. [cite:44][cite:36]
- Mismatch blocking and user guidance UI. [cite:36][cite:38]
- Lifecycle-safe restore on screen exit. [cite:27][cite:29]

The package should not own these responsibilities by default:

- Global splash screen overlay styles. [cite:27]
- Global app-shell status bar theme unrelated to a specific orientation flow. [cite:27][cite:65]
- Feature-specific viewport injection hacks such as `forceLandscapeViewport`, which should remain in the game/webview layer and consume orientation state rather than define it. [cite:36][cite:40]

### 3.3 Public API design

The public API should be small, explicit, and easy to mock.

#### Core enums and models

```dart
enum OrientationTarget { portrait, landscape, both }

enum OrientationStatus {
  idle,
  applying,
  matched,
  mismatched,
  blocked,
}

class ScreenUiPolicy {
  const ScreenUiPolicy({
    this.immersive = false,
    this.restoreOnDispose = true,
  });

  final bool immersive;
  final bool restoreOnDispose;
}

class OrientationPolicy {
  const OrientationPolicy({
    required this.target,
    this.screenUi = const ScreenUiPolicy(),
    this.blockOnWebMismatch = true,
    this.debugLabel,
  });

  final OrientationTarget target;
  final ScreenUiPolicy screenUi;
  final bool blockOnWebMismatch;
  final String? debugLabel;
}
```

#### Controller contract

```dart
abstract class OrientationController {
  Future<OrientationApplyResult> apply(OrientationPolicy policy);

  Future<void> restore();

  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });
}
```

#### Optional observer state

```dart
class OrientationViewState {
  const OrientationViewState({
    required this.policy,
    required this.status,
    required this.matched,
    required this.canControlPlatform,
    this.message,
  });

  final OrientationPolicy policy;
  final OrientationStatus status;
  final bool matched;
  final bool canControlPlatform;
  final String? message;
}
```

This API is intentionally small. It allows the package to remain clear and easy to integrate without overexposing internal platform logic. [cite:52][cite:63]

### 3.4 Internal architecture

Recommended internal structure:

```text
lib/core/orientation_controller/
  orientation_controller.dart
  src/
    models/
      orientation_policy.dart
      orientation_target.dart
      orientation_status.dart
      orientation_view_state.dart
      screen_ui_policy.dart
      viewport_class.dart
    resolvers/
      orientation_policy_resolver.dart
      game_orientation_resolver.dart
    services/
      orientation_controller_base.dart
      native_orientation_controller.dart
      web_orientation_controller.dart
      system_chrome_orientation_delegate.dart
      orientation_platform_adapter.dart
    widgets/
      orientation_guard.dart
      orientation_mismatch_view.dart
    providers/
      orientation_controller_provider.dart
    utils/
      orientation_matcher.dart
      viewport_classifier.dart
```

This package layout follows Dart package conventions and keeps the public API separate from implementation details. [cite:62]

### 3.5 Resolver strategy

The package should not depend directly on the entire game feature layer, but it should support adapters/resolvers. `GameBlock` already contains the information needed to create a policy. `mobileOrientation` and `tabletOrientation` are the core input fields, and desktop can reasonably reuse tablet behavior for the game-player use case. [cite:40]

Example resolver contract:

```dart
abstract class OrientationPolicyResolver<T> {
  OrientationPolicy resolve(
    T source, {
    required double width,
    required double height,
    required double shortestSide,
  });
}
```

Example `GameBlock` resolver behavior:

- `mobileOrientation` is used for phone-sized viewports. [cite:40]
- `tabletOrientation` is used for tablet and desktop-sized game screens. [cite:40]
- `immersive = true` for game-player screens. [cite:32][cite:27]
- `blockOnWebMismatch = true` for strict game render safety. [cite:36][cite:38]

### 3.6 Native implementation strategy

The native implementation should wrap orientation and screen presentation control behind a delegate that can be tested and replaced if needed.

Recommended native delegate responsibilities:

- `setPortraitOnly()` [cite:27]
- `setLandscapeOnly()` [cite:27]
- `setAllOrientations()` [cite:27]
- `enterImmersive()` [cite:27]
- `restore()` [cite:27]

The implementation may reuse the existing `SystemUiService`, but should narrow and rename the surface so the package depends on a focused delegate rather than a generic all-purpose system UI service. This keeps boundaries clean and improves maintainability. [cite:27][cite:52]

The native implementation must keep the iPadOS orientation-mask flush workaround and other known lifecycle protections already documented in the internal notes. Those are not optional details; they are part of the production behavior required for stability. [cite:27][cite:36]

### 3.7 Web implementation strategy

The web implementation must not pretend to lock orientation in the same way as native. Instead, it should:

1. Evaluate viewport orientation from Flutter `MediaQuery` or an equivalent browser-safe source. [cite:44]
2. Compare it against the active `OrientationPolicy`. [cite:44]
3. Return `matched` or `mismatched` state. [cite:44]
4. Block rendering of sensitive content until the requirement is satisfied. [cite:36][cite:38]

This is the safest behavior for the current game-player architecture, because the internal notes show that rendering the iframe or platform view too early can break game initialization, especially while the viewport is changing. [cite:36][cite:38]

### 3.8 Widget layer

The package should include a reusable `OrientationGuard` widget. This widget should:

- Read current orientation from context.
- Ask the controller whether the policy is matched.
- Render `child` when matched.
- Render a customizable mismatch view when not matched and blocking is enabled.

This keeps the feature layer declarative and avoids duplicating “rotate screen” logic across screens. [cite:8][cite:36]

The mismatch view should support:

- Different messages for portrait-required and landscape-required states.
- Different copy for desktop web, such as “resize the window” rather than “rotate the device.” [cite:44]
- Optional callback hooks for analytics or support logging.

### 3.9 Debugging and traceability requirements

The package should be easy to debug and trace in production and QA. The internal orientation issues show how difficult platform timing bugs become when state transitions are not explicit. [cite:36][cite:38]

Recommended logging fields per transition:

- Active policy target.
- Debug label or feature name.
- Platform type.
- Viewport width/height/shortestSide.
- Current orientation.
- Whether the controller can control the platform.
- Whether the target is matched.
- Whether a block screen is currently shown.
- Apply/restore success or failure.

Examples of transitions worth logging:

- `policy_resolved`
- `native_apply_started`
- `native_apply_succeeded`
- `native_apply_failed`
- `web_mismatch_detected`
- `blocker_shown`
- `blocker_dismissed`
- `restore_started`
- `restore_succeeded`

### 3.10 VGV-style and Dartdoc expectations

To follow VGV-style and modern Dart/Flutter best practices, implementation should observe the following:

- Use small public APIs and keep implementation details in `src/`. [cite:62]
- Prefer immutable configuration models with const constructors where possible. [cite:52]
- Use descriptive names and consistent suffixes such as `Policy`, `Resolver`, `Controller`, `Delegate`, and `Guard`. [cite:52][cite:63]
- Add complete Dartdoc on all public APIs, including behavior differences between native and web. [cite:52]
- Avoid hidden side effects; `apply()` and `restore()` should be explicit lifecycle calls. [cite:52][cite:63]
- Keep platform branching centralized in one adapter/factory. [cite:52]
- Separate domain policy from widget/UI rendering. [cite:52][cite:63]
- Keep code dependency direction clean: feature → package API, not feature → platform detail. [cite:52][cite:61]

Examples of required Dartdoc topics:

- What `apply()` does on native versus web. [cite:6][cite:44]
- What `blockOnWebMismatch` means. [cite:36]
- Whether `restore()` must be called manually or is integrated with a scope widget. [cite:27]
- Whether desktop uses viewport orientation rather than physical rotation. [cite:44]

## 4. How to use the package

### 4.1 Feature-level usage flow

A feature such as `GamePlayerScreen` should use the package like this:

1. Resolve an `OrientationPolicy` from feature input such as `GameBlock`. [cite:40]
2. Obtain `OrientationController` from provider/DI. [cite:52]
3. Apply the policy when entering the screen. [cite:27][cite:32]
4. Wrap the screen content in `OrientationGuard`. [cite:36][cite:38]
5. Restore presentation defaults when the screen is disposed. [cite:27][cite:29]

### 4.2 Example usage with `GameBlock`

```dart
final resolver = ref.read(gameOrientationResolverProvider);
final controller = ref.read(orientationControllerProvider);

final size = MediaQuery.sizeOf(context);
final policy = resolver.resolve(
  game,
  width: size.width,
  height: size.height,
  shortestSide: size.shortestSide,
);
```

Then during initialization:

```dart
final result = await controller.apply(policy);

if (kIsWeb && !result.isMatched && policy.blockOnWebMismatch) {
  return;
}

await ref.read(gamePlayerProvider(game).notifier).loadGame();
```

And in the widget tree:

```dart
OrientationGuard(
  policy: policy,
  controller: controller,
  child: const GamePlayerBody(),
)
```

This ensures that web-sensitive content is not rendered before the viewport satisfies the target orientation. That behavior directly addresses the known iframe and layout initialization issues described in the existing internal documents. [cite:36][cite:38]

### 4.3 Expected platform behavior

| Platform | What the package does | Expected result |
|---|---|---|
| Android/iOS | Applies orientation through native APIs, enters immersive mode if requested, then checks readiness. [cite:6][cite:27] | The screen rotates or constrains as required; if the target is not actually satisfied, the package can surface a blocker state. [cite:16][cite:36] |
| Web mobile browser | Does not rely on hard lock; compares viewport orientation to target. [cite:44][cite:36] | Sensitive content is blocked until the user rotates the device to a satisfying viewport orientation. [cite:36][cite:38] |
| Web desktop | Uses browser-window orientation semantics. [cite:44] | The package can show a “resize window / use a wider viewport” blocker when a screen requires landscape. [cite:44] |
| Tablet / iPad | Applies native constraints where possible, but still validates final readiness. [cite:27][cite:36] | Prevents unsafe render timing that could initialize the game with stale bounds. [cite:36] |

## 5. Migration plan for the current codebase

### 5.1 Step-by-step migration

1. Introduce the package and public API models. [cite:62]
2. Move native orientation/full-screen lifecycle logic behind a focused delegate or controller adapter, reusing `SystemUiService` internally at first. [cite:27]
3. Add a `GameOrientationResolver` to translate `mobileOrientation` and `tabletOrientation` into package policies. [cite:40]
4. Refactor `GamePlayerNotifier.initializePlayer()` so it consumes `OrientationPolicy` or delegates orientation handling to the package instead of directly switching on `GameOrientation`. [cite:32]
5. Introduce `OrientationGuard` into `GamePlayerScreen` or the screen scaffold layer. [cite:36][cite:38]
6. Move restore logic out of the session-guard branch and into orientation lifecycle cleanup. [cite:29][cite:27]
7. Keep `forceLandscapeViewport` and other game-engine-specific workarounds in the webview/game layer, but allow them to observe package state if useful. [cite:36][cite:40]

### 5.2 What should remain outside the package

To keep responsibilities clean, these should stay outside unless there is a compelling reason to move them later:

- Game-engine viewport injection and about:blank stabilization logic. [cite:36]
- Provider-specific session guard and cooldown logic. [cite:28][cite:29]
- Global splash-screen overlay style. [cite:27]

## 6. Quality requirements

The package should be considered production-ready only if it satisfies the following standards:

- **Clean API**: consumers should need only the policy, controller, resolver, and optional guard widget. [cite:52]
- **Clear docs**: public APIs must describe cross-platform behavior explicitly. [cite:52][cite:63]
- **Easy debugging**: all state transitions and mismatches should be observable in logs. [cite:36][cite:38]
- **Customizable UI**: mismatch screens must be overridable without forking the package. [cite:8]
- **Safe defaults**: strict blocking should be available for sensitive flows such as game player. [cite:36][cite:38]
- **Maintainable boundaries**: app-shell styling remains outside; orientation lifecycle stays inside. [cite:27][cite:65]
- **Testability**: resolver logic, match logic, and platform adapter branching should all be unit-testable. Flutter widget tests should verify guard behavior. [cite:3][cite:52]

## 7. Conclusion

The package is both feasible and strategically valuable for the current Flutter codebase. The existing feature already contains most of the necessary primitives—policy data in `GameBlock`, native control in `SystemUiService`, orchestration in `GamePlayerNotifier`, and real-world web/native edge-case knowledge in the internal orientation notes. What is missing is a clean package boundary and a stable abstraction that separates intent, platform application, mismatch detection, and blocking behavior. [cite:40][cite:27][cite:32][cite:36]

The recommended implementation is to build `orientation_controller` as a small but disciplined infrastructure package that owns orientation policy and screen presentation lifecycle, while leaving unrelated app-shell styling and game-engine-specific viewport hacks outside. That gives the codebase a clean foundation that is easier to debug, easier to document, easier to reuse, and significantly safer for strict game-player flows on both native app and web. [cite:52][cite:63][cite:36][cite:38]

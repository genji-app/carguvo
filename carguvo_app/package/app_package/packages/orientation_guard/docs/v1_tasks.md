# ✅ Orientation Guard — V1 Task Breakdown

> 33 tasks chia thành 7 phases. Mỗi task có file path, checklist, và tiêu chí verify.

---

## Phase 0: Chuẩn bị cấu trúc song song (~15 phút)

### T0.1 — Tạo thư mục `src_v1/`

**Mục tiêu**: Tạo skeleton cho code v1 mà không ảnh hưởng v0.

- [x] Tạo `lib/src_v1/models/`
- [x] Tạo `lib/src_v1/strategies/`
- [x] Tạo `lib/src_v1/controllers/`
- [x] Tạo `lib/src_v1/widgets/`

### T0.2 — Tạo library export v1

**File mới**: `lib/orientation_guard.dart`

- [x] Tạo file với `library;` declaration
- [x] Để trống exports (sẽ thêm dần theo phase)
- [x] **Kiểm tra**: `lib/orientation_guard.dart` (v0) KHÔNG bị thay đổi

### T0.3 — Cập nhật example app

**File sửa**: `example/lib/main.dart`

- [x] Đổi import sang `orientation_guard.dart`
- [x] Comment code cũ tạm thời (vì v1 exports còn trống)
- [x] **Verify**: `flutter analyze example/` — pass

---

## Phase 1: Model Layer (~30 phút)

### T1.1 — Tạo `OrientationPolicy` v1

**File mới**: `lib/src_v1/models/orientation_policy.dart`

**Nội dung**:
- [x] Copy `DeviceOrientationX` extension từ v0
- [x] Copy `DeviceOrientations` class từ v0
- [x] Copy `OrientationPolicy` từ v0
- [x] **Xóa** field `screenUi` (`ScreenUiPolicy`)
- [x] **Xóa** field `customMismatchViewBuilder`
- [x] **Đổi** `blockOnWebMismatch` → `blockOnMismatch` (default `true`)
- [x] Giữ: `targets`, `debugLabel`, `allowsLandscape`, `allowsPortrait`, `isAdaptive`
- [x] Giữ: `operator ==` và `hashCode` (bỏ `screenUi` và `customMismatchViewBuilder` khỏi compare)

### T1.2 — Tạo `OrientationApplyResult`

**File mới**: `lib/src_v1/models/orientation_apply_result.dart`

**Nội dung**:
- [x] Enum `OrientationResultStatus`: `matched`, `mismatched`, `unsupported`, `failed`
- [x] Class `OrientationApplyResult`:
  - `final OrientationResultStatus status`
  - `final OrientationPolicy policy`
  - `final bool canControlPlatform`
  - `final String? message`
- [x] Const constructor
- [x] Named constructors tiện ích:
  - `OrientationApplyResult.matched(policy)` 
  - `OrientationApplyResult.unsupported(policy)`

### T1.3 — Tạo `OrientationRuntimeContext`

**File mới**: `lib/src_v1/models/orientation_runtime_context.dart`

**Nội dung**:
- [x] Class gồm:
  - `final TargetPlatform platform`
  - `final bool isWeb`
- [x] Factory `OrientationRuntimeContext.current()`:
  - Dùng `kIsWeb` và `defaultTargetPlatform` để tự detect

### T1.4 — Verify Phase 1

- [x] Export 3 model files trong `orientation_guard.dart`
- [x] `flutter analyze` trên package root — no issues

---

## Phase 2: Strategy Layer (~1.5 giờ)

### T2.1 — Tạo `OrientationStrategy` interface

**File mới**: `lib/src_v1/strategies/orientation_strategy.dart`

- [x] Import `OrientationPolicy`, `OrientationApplyResult`
- [x] Abstract class:
  ```dart
  abstract class OrientationStrategy {
    Future<OrientationApplyResult> apply(OrientationPolicy policy);
    Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);
    bool isMatched({
      required OrientationPolicy policy,
      required Orientation currentOrientation,
    });
  }
  ```

### T2.2 — Implement `DirectApplyStrategy`

**File mới**: `lib/src_v1/strategies/direct_apply_strategy.dart`

**Logic**: Extract từ `NativeOrientationController` bỏ phần iOS.

- [x] `apply(policy)`:
  1. Gọi `SystemChrome.setPreferredOrientations(policy.targets)`
  2. Return `OrientationApplyResult.matched(policy)`
  3. Catch error → return `failed`
- [x] `restore(previousPolicy)`:
  - Nếu `previousPolicy != null` → `apply(previousPolicy)`
  - Nếu `null` → `setPreferredOrientations(DeviceOrientation.values)`, return `matched`
- [x] `isMatched()`: So sánh portrait/landscape (copy logic v0)

### T2.3 — Implement `IosOrientationStrategy`

**File mới**: `lib/src_v1/strategies/ios_orientation_strategy.dart`

**Logic**: Extract workaround iOS từ `NativeOrientationController`.

- [x] `apply(policy)`:
  1. **Flush mask**: `setPreferredOrientations(DeviceOrientation.values)` + delay 50ms
  2. **Lock break** (nếu về portrait): Force `portraitUp` + delay 50ms
  3. **Apply**: `setPreferredOrientations(policy.targets)`
  4. Return `matched` hoặc `failed`
- [x] `restore(previousPolicy)`:
  - Tương tự logic apply nhưng dùng `previousPolicy.targets` hoặc `DeviceOrientation.values`
  - Vẫn cần flush mask khi restore trên iOS
- [x] `isMatched()`: Dùng chung logic (copy từ DirectApply)
- [x] Comment giải thích **tại sao** cần flush mask (iOS 16+ bug reference)

### T2.4 — Implement `WebNoopStrategy`

**File mới**: `lib/src_v1/strategies/web_noop_strategy.dart`

- [x] `apply(policy)`:
  - **KHÔNG** gọi `requestFullscreen()` (đã tách sang `fullscreen_guard`)
  - Return `OrientationApplyResult(status: unsupported, canControlPlatform: false)`
- [x] `restore()`:
  - No-op, return `unsupported`
- [x] `isMatched()`:
  - So sánh `Orientation.portrait/landscape` vs `policy.targets`
  - Logic giống native (viewport orientation check)

### T2.5 — Tạo `OrientationStrategyResolver`

**File mới**: `lib/src_v1/strategies/orientation_strategy_resolver.dart`

- [x] `OrientationStrategy resolve(OrientationRuntimeContext context)`:
  - `context.isWeb` → `WebNoopStrategy()`
  - `context.platform == TargetPlatform.iOS` → `IosOrientationStrategy()`
  - Else → `DirectApplyStrategy()`
- [x] Cho phép override qua constructor:
  ```dart
  class OrientationStrategyResolver {
    const OrientationStrategyResolver({this.strategyOverride});
    final OrientationStrategy? strategyOverride;
    
    OrientationStrategy resolve(OrientationRuntimeContext context) {
      if (strategyOverride != null) return strategyOverride!;
      // ... auto resolve
    }
  }
  ```

### T2.6 — Verify Phase 2

- [x] Export strategy files trong `orientation_guard.dart`
- [x] `flutter analyze` — no issues

---

## Phase 3: Controller Refactor (~45 phút)

### T3.1 — Tạo `OrientationController` v1 interface

**File mới**: `lib/src_v1/controllers/orientation_controller.dart`

- [x] Abstract class:
  ```dart
  abstract class OrientationController {
    Future<OrientationApplyResult> apply(OrientationPolicy policy);
    Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);
    bool isMatched({
      required OrientationPolicy policy,
      required Orientation currentOrientation,
    });
  }
  ```

### T3.2 — Tạo `PlatformOrientationController`

**File mới**: `lib/src_v1/controllers/platform_orientation_controller.dart`

- [x] Nhận `OrientationStrategy` qua constructor
- [x] Delegate tất cả methods sang strategy:
  ```dart
  class PlatformOrientationController implements OrientationController {
    const PlatformOrientationController(this._strategy);
    final OrientationStrategy _strategy;
    
    @override
    Future<OrientationApplyResult> apply(OrientationPolicy policy) {
      debugPrint('[OrientationController] apply: ${policy.debugLabel}');
      return _strategy.apply(policy);
    }
    // ...
  }
  ```

### T3.3 — Tạo Controller Dispatcher v1

**Files mới**:
- `lib/src_v1/controllers/controller_dispatcher.dart` (conditional import hub)
- `lib/src_v1/controllers/controller_dispatcher_native.dart`
- `lib/src_v1/controllers/controller_dispatcher_web.dart`
- `lib/src_v1/controllers/controller_dispatcher_stub.dart`

**Logic**:
- [x] `createOrientationControllerV1()`:
  - Native: resolve strategy qua `OrientationStrategyResolver` → tạo `PlatformOrientationController`
  - Web: `PlatformOrientationController(WebNoopStrategy())`
  - Stub: throw `UnsupportedError`

### T3.4 — Verify Phase 3

- [x] Export controller files trong `orientation_guard.dart`
- [x] `flutter analyze` — no issues

---

## Phase 4: Widget Layer (~1 giờ)

### T4.1 — Tạo `OrientationScope`

**File mới**: `lib/src_v1/widgets/orientation_scope.dart`

- [x] `InheritedWidget` cung cấp `OrientationController`
- [x] `OrientationScope.of(context)` — non-nullable, throw nếu thiếu
- [x] `OrientationScope.maybeOf(context)` — nullable
- [x] `updateShouldNotify` → compare controller reference

### T4.2 — Tạo `OrientationGuard` v1

**File mới**: `lib/src_v1/widgets/orientation_guard.dart`

**Props**:
- [x] `OrientationPolicy policy` (required)
- [x] `Widget child` (required)
- [x] `OrientationController? controller` (optional, fallback to Scope)
- [x] `WidgetBuilder? mismatchBuilder` (optional, thay thế default MismatchView)
- [x] `bool blockOnMismatch` (default from policy)

**Lifecycle**:
- [x] `didChangeDependencies()`:
  - Resolve controller (widget param → OrientationScope)
  - Gọi `_applyPolicy()` 
- [x] `_applyPolicy()`:
  - `addPostFrameCallback` → `controller.apply(policy)`
  - Lưu `_lastAppliedPolicy` cho restore
- [x] `didUpdateWidget()`:
  - So sánh policy mới vs cũ → re-apply nếu khác
- [x] `dispose()`:
  - **Gọi `controller.restore(_lastAppliedPolicy)`** ← quan trọng, KHÁC v0
- [x] `build()`:
  - Check `isMatched` → hiển thị child hoặc mismatch
  - Dùng `mismatchBuilder` nếu có, fallback `OrientationMismatchView`
  - Điều kiện block: `blockOnMismatch && !isMatched && hasValidSize`
  - **KHÔNG** check `kIsWeb` hardcode — dùng `blockOnMismatch` flag

### T4.3 — Tạo `OrientationMismatchView` v1

**File mới**: `lib/src_v1/widgets/orientation_mismatch_view.dart`

- [x] Props: `policy`, `title?`, `message?`
- [x] Default text bằng **tiếng Anh**:
  - Landscape: "Please rotate your device to landscape"
  - Portrait: "Please rotate your device to portrait"
- [x] App override text qua `mismatchBuilder` trên Guard (không phải trên view)
- [x] Giữ visual design hiện tại (dark bg, icon, centered text)

### T4.4 — Tạo `OrientationEntryPoint`

**File mới**: `lib/src_v1/widgets/orientation_entry_point.dart`

**Mục tiêu**: Convenience widget thay `GlobalOrientationOrchestrator`.

- [x] Props: `controller`, `defaultPolicy`, `child`, `mismatchBuilder?`
- [x] Build: `OrientationScope` → `OrientationGuard` (gom 2 widget)
- [x] Default policy: `DeviceOrientations.portrait`

### T4.5 — Verify Phase 4

- [x] Export widget files trong `orientation_guard.dart`
- [x] `flutter analyze` — no issues

---

## Phase 5: Test + Example App (~2 giờ)

### T5.1 — Unit test Strategies

**Files mới**:
- `test/strategies/direct_apply_strategy_test.dart`
- `test/strategies/ios_orientation_strategy_test.dart`
- `test/strategies/web_noop_strategy_test.dart`

**Test cases cho mỗi strategy**:
- [x] `apply()` trả đúng status (`matched` / `unsupported`)
- [x] `restore(previousPolicy)` apply policy đó
- [x] `restore(null)` mở tất cả orientation
- [x] `isMatched()` trả `true` khi portrait policy + portrait orientation
- [x] `isMatched()` trả `false` khi landscape policy + portrait orientation
- [x] `apply()` catch error → trả `failed`

### T5.2 — Unit test StrategyResolver

**File mới**: `test/strategies/strategy_resolver_test.dart`

- [x] iOS context → `IosOrientationStrategy`
- [x] Android context → `DirectApplyStrategy`
- [x] Web context → `WebNoopStrategy`
- [x] Override → trả override strategy

### T5.3 — Widget test OrientationGuard v1

**File mới**: `test/widgets/orientation_guard_v1_test.dart`

- [x] Mount guard → `apply()` được gọi với đúng policy
- [x] Dispose guard → `restore()` được gọi với `previousPolicy`
- [x] Policy change → re-apply
- [x] Mismatch + blockOnMismatch=true → hiển thị mismatch UI
- [x] Matched → hiển thị child
- [x] Custom mismatchBuilder → render custom widget
- [x] blockOnMismatch=false → không block dù mismatch

### T5.4 — Example app hoàn chỉnh

**File sửa**: `example/lib/main.dart`

- [x] Home screen (portrait) với nút "Enter Game"
- [x] Game screen (landscape) với nút "Back to Home"
- [x] Navigate Home → Game: màn hình xoay landscape
- [x] Navigate Game → Home: màn hình restore về portrait
- [x] Web: khi viewport sai hướng → hiển thị mismatch UI
- [x] Custom mismatch builder demo

### T5.5 — Verify Phase 5

- [x] `flutter test` trên package root — all green
- [x] `flutter analyze` — no issues
- [x] Manual test example trên ≥2 platforms (iOS sim + Chrome recommended)

---

## Phase 6: Migrate App Chính (~1 giờ)

> ⚠️ Phase này CHỈ thực hiện sau khi Phase 5 pass hoàn toàn.

### T6.1 — Đổi import trong app

- [x] Grep `import 'package:orientation_guard/orientation_guard.dart'`
- [x] Đổi sang `import 'package:orientation_guard/orientation_guard.dart'`
- [x] Fix compilation errors

### T6.2 — Migrate `GameBlockOrientationResolver`

**File**: `lib/features/game/player/resolvers/game_block_orientation_resolver.dart`

- [x] Xóa `screenUi: ScreenUiPolicy(immersive: ...)` khỏi `OrientationPolicy` return
- [x] Tách logic `immersive` sang lời gọi `fullscreen_guard` riêng (hoặc giao cho caller)
- [x] Đổi `blockOnWebMismatch` → dùng default `blockOnMismatch`

### T6.3 — Migrate `AppOrientationNotifier`

**File**: `lib/shared/widgets/orientation/app_orientation_provider.dart`

- [x] Đổi `OrientationController` → v1 interface
- [x] Sửa `_applyActive()`: truyền `previousPolicy` khi cần restore
- [x] Xóa đoạn comment-out về `PlatformUiConfig.immersive`

### T6.4 — Migrate `AppOrientationOrchestrator`

**File**: `lib/shared/widgets/orientation/app_orientation_orchestrator.dart`

- [x] Đổi `GlobalOrientationOrchestrator` → `OrientationEntryPoint`
- [x] Đổi `createOrientationController()` → `createOrientationControllerV1()`

### T6.5 — Cleanup

- [x] Xóa `lib/src/` (v0 code)
- [x] Rename `lib/src_v1/` → `lib/src/`
- [x] Rename `lib/orientation_guard.dart` → `lib/orientation_guard.dart`
- [x] Fix tất cả import paths
- [x] `flutter analyze` toàn app — pass
- [x] `flutter test` (nếu có) — pass

### T6.6 — Commit & Tag

- [x] Commit: `refactor(orientation_guard): migrate to v1 strategy-based architecture`
- [x] Tag: `orientation_guard-v1.0.0`

---

## 📊 Tổng kết

| Phase | Tasks | Ước lượng | Dependency |
|:---|:---:|:---|:---|
| Phase 0 — Chuẩn bị | 3 | ~15 phút | Không |
| Phase 1 — Models | 4 | ~30 phút | Phase 0 |
| Phase 2 — Strategies | 6 | ~1.5 giờ | Phase 1 |
| Phase 3 — Controller | 4 | ~45 phút | Phase 2 |
| Phase 4 — Widgets | 5 | ~1 giờ | Phase 3 |
| Phase 5 — Test + Example | 5 | ~2 giờ | Phase 4 |
| Phase 6 — Migrate app | 6 | ~1 giờ | Phase 5 ✅ |
| **Tổng** | **33** | **~7 giờ** | |

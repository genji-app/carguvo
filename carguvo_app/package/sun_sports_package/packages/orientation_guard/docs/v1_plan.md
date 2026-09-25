# 🏗️ Orientation Guard — V1 Implementation Plan

> Kế hoạch triển khai chi tiết cho refactor orientation_guard theo kiến trúc v1.

---

## 1. Mục tiêu

Chuyển đổi `orientation_guard` từ "God package" (orientation + fullscreen + iOS hacks lẫn lộn) sang kiến trúc sạch:

- **Một trách nhiệm**: Chỉ quản lý screen orientation
- **Strategy-based**: Logic nền tảng nằm trong strategy, không trong controller
- **Typed results**: `apply()` và `restore()` trả `OrientationApplyResult` thay vì `void`
- **Restore chính xác**: Nhận `previousPolicy` thay vì mở mù tất cả orientation

---

## 2. Chiến lược triển khai: Song song v0/v1

```
orientation_guard/
  lib/
    orientation_guard.dart          ← v0 (GIỮU NGUYÊN, app chính vẫn dùng)
    orientation_guard.dart       ← v1 (MỚI, example app dùng để test)
    src/                            ← v0 code, KHÔNG ĐỤNG
    src_v1/                         ← v1 code mới
      models/
      strategies/
      controllers/
      widgets/
```

**Lợi ích**: App chính không bị ảnh hưởng. Test v1 hoàn toàn trên example app. Khi ổn định → migrate app → xóa v0.

---

## 3. Kiến trúc mục tiêu v1

```
┌──────────────────────────────────────────────────┐
│                   Widget Layer                   │
│  ┌──────────────┐  ┌───────────────────────────┐ │
│  │ Orientation   │  │ OrientationGuard          │ │
│  │ Scope         │  │ (lifecycle + mismatch)    │ │
│  │ (Inherited    │  │ - mount → apply           │ │
│  │  Widget)      │  │ - dispose → restore       │ │
│  │               │  │ - mismatchBuilder param   │ │
│  └──────┬───────┘  └──────────┬────────────────┘ │
│         │                     │                  │
├─────────┼─────────────────────┼──────────────────┤
│         ▼    Controller Layer ▼                  │
│  ┌──────────────────────────────────────────┐    │
│  │ PlatformOrientationController            │    │
│  │ - apply(policy) → delegate to strategy   │    │
│  │ - restore(prev?) → delegate to strategy  │    │
│  │ - isMatched(policy, orientation)          │    │
│  └──────────────────┬───────────────────────┘    │
│                     │                            │
├─────────────────────┼────────────────────────────┤
│                     ▼    Strategy Layer           │
│  ┌──────────────────────────────────────────┐    │
│  │ OrientationStrategy (abstract)           │    │
│  │                                          │    │
│  │ ┌────────────────┐ ┌──────────────────┐  │    │
│  │ │DirectApply     │ │IosOrientation    │  │    │
│  │ │Strategy        │ │Strategy          │  │    │
│  │ │(Android)       │ │(flush+lockbreak) │  │    │
│  │ └────────────────┘ └──────────────────┘  │    │
│  │ ┌────────────────┐                       │    │
│  │ │WebNoop         │ ← StrategyResolver    │    │
│  │ │Strategy        │   chọn đúng strategy  │    │
│  │ └────────────────┘                       │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
├──────────────────────────────────────────────────┤
│                   Model Layer                    │
│  ┌─────────────────┐  ┌──────────────────────┐   │
│  │OrientationPolicy│  │OrientationApplyResult│   │
│  │(targets, block, │  │(status, policy,      │   │
│  │ debugLabel)     │  │ canControl, message)  │   │
│  └─────────────────┘  └──────────────────────┘   │
│  ┌──────────────────────┐                        │
│  │OrientationRuntimeCtx │                        │
│  │(platform, isWeb)     │                        │
│  └──────────────────────┘                        │
└──────────────────────────────────────────────────┘
```

---

## 4. API Changes: v0 → v1

### 4.1. OrientationPolicy

```diff
 class OrientationPolicy {
   const OrientationPolicy({
     required this.targets,
-    this.screenUi = const ScreenUiPolicy(),
-    this.blockOnWebMismatch = true,
-    this.customMismatchViewBuilder,
+    this.blockOnMismatch = true,
     this.debugLabel,
   });
 }
```

### 4.2. OrientationController

```diff
 abstract class OrientationController {
-  Future<OrientationViewState> apply(OrientationPolicy policy);
-  Future<void> restore();
+  Future<OrientationApplyResult> apply(OrientationPolicy policy);
+  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);
   bool isMatched({required OrientationPolicy policy, required Orientation current});
 }
```

### 4.3. OrientationGuard

```diff
 class OrientationGuard extends StatefulWidget {
   const OrientationGuard({
     required this.policy,
     required this.child,
     this.controller,
+    this.mismatchBuilder,
+    this.blockOnMismatch,
   });
+  final WidgetBuilder? mismatchBuilder;
+  final bool? blockOnMismatch;
 }
```

### 4.4. Xóa hoàn toàn

| Class/File | Lý do |
|:---|:---|
| `ScreenUiPolicy` | Fullscreen concern → `fullscreen_guard` |
| `OrientationViewState` | Thay bằng `OrientationApplyResult` |
| `GlobalOrientationOrchestrator` | Thay bằng `OrientationEntryPoint` |
| `OrientationOverride` | Không cần — Guard v1 đã đủ |

---

## 5. Cây file v1 hoàn chỉnh

```
src_v1/
  models/
    orientation_policy.dart          ← Policy (không có ScreenUiPolicy)
    orientation_apply_result.dart    ← Typed result từ apply/restore
    orientation_runtime_context.dart ← Platform context cho resolver
  strategies/
    orientation_strategy.dart        ← Abstract interface
    direct_apply_strategy.dart       ← Android
    ios_orientation_strategy.dart    ← iOS (flush + lock break)
    web_noop_strategy.dart           ← Web (detect only, no force)
    orientation_strategy_resolver.dart ← Chọn strategy theo platform
  controllers/
    orientation_controller.dart      ← Abstract interface v1
    platform_orientation_controller.dart ← Delegate sang strategy
    controller_dispatcher.dart       ← Conditional import
    controller_dispatcher_native.dart
    controller_dispatcher_web.dart
    controller_dispatcher_stub.dart
  widgets/
    orientation_scope.dart           ← InheritedWidget
    orientation_guard.dart           ← Lifecycle + mismatch
    orientation_mismatch_view.dart   ← Default UI (tiếng Anh, builder override)
    orientation_entry_point.dart     ← Convenience = Scope + Guard
```

---

## 6. Verification Plan

### Automated Tests
- Unit test cho 3 strategies (apply, restore, isMatched)
- Unit test cho StrategyResolver
- Widget test cho OrientationGuard lifecycle (mount/dispose)
- Widget test cho mismatch UI rendering

### Manual Verification
- Example app: Home (portrait) → Game (landscape) → Back (portrait restored)
- iOS Simulator: verify flush mask workaround
- Chrome: verify mismatch UI hiển thị khi viewport sai hướng
- `flutter analyze` pass cho cả package và example

---

## 7. Risk Mitigation

| Rủi ro | Biện pháp |
|:---|:---|
| Strategy phình nhiều class | Merge iOS apply/restore thành 1 `IosOrientationStrategy` |
| Break app chính | Phát triển song song v0/v1, test example trước |
| Restore sai policy | Nhận `previousPolicy` tường minh, app giữ stack |
| MismatchView hardcode | Builder parameter, default text tiếng Anh |
| iPadOS edge case | Để app tự config `Info.plist`, package không can thiệp |

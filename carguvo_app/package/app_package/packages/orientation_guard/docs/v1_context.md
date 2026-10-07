# 📦 Orientation Guard — V1 Context & Current State

> Tài liệu mô tả hiện trạng package, các vấn đề đã nhận diện, và bối cảnh kỹ thuật làm nền tảng cho refactor v1.

---

## 1. Package Overview

| Thuộc tính | Giá trị |
|:---|:---|
| Package | `orientation_guard` |
| Version hiện tại | v0 (chưa tag chính thức) |
| Location | `packages/orientation_guard/` |
| Branch | `fix/orientation_android` |
| Dependencies | `flutter`, `meta`, `web` |

---

## 2. Cấu trúc hiện tại (v0)

```
lib/
  orientation_guard.dart              ← Library exports
  src/
    models/
      orientation_models.dart         ← OrientationPolicy, ScreenUiPolicy, OrientationViewState
    services/
      orientation_controller.dart     ← Abstract interface
      native_orientation_controller.dart  ← iOS + Android (trộn lẫn)
      web_orientation_controller.dart     ← Web + Fullscreen API (vi phạm boundary)
      orientation_controller_dispatcher.dart  ← Conditional import
      orientation_controller_stub.dart
      orientation_adaptive_resolver.dart
      orientation_policy_resolver.dart
    widgets/
      orientation_guard.dart          ← God Widget (149 dòng, 5-6 concerns)
      orientation_provider.dart       ← InheritedWidget cung cấp controller
      orientation_mismatch_view.dart  ← Hardcode tiếng Việt
      global_orientation_orchestrator.dart ← Orchestrator + OrientationOverride
```

---

## 3. Các vấn đề đã nhận diện

### 3.1. Boundary trách nhiệm bị vi phạm

**File**: `web_orientation_controller.dart` (dòng 20-24, 40-63)

WebController đang gọi `requestFullscreen()` / `exitFullscreen()` — đây là **fullscreen concern**, không phải orientation. Package `fullscreen_guard` đã tồn tại tại `packages/fullscreen_guard/` và nên đảm nhận trách nhiệm này.

### 3.2. Restore semantics sai

**File**: `native_orientation_controller.dart` (dòng 64-73)

`restore()` gọi `DeviceOrientation.values` (mở tất cả orientation) thay vì quay về policy trước đó. Với guard lồng nhau (Screen A → Dialog B → pop), điều này gây sai hành vi.

**Lưu ý**: App layer đã có policy stack tại `AppOrientationNotifier` (`lib/shared/widgets/orientation/app_orientation_provider.dart`), nhưng controller không nhận `previousPolicy` khi restore.

### 3.3. iOS workaround phình trong controller

**File**: `native_orientation_controller.dart` (dòng 17-42)

~25 dòng logic iOS-specific (flush mask, lock break) trộn lẫn với Android logic trong cùng một `apply()` method. Cần extract sang strategy riêng.

### 3.4. Web cố force rotate

**File**: `web_orientation_controller.dart` (dòng 30)

`canControlPlatform: true` trong khi Web thực tế không force rotation được — gây hiểu nhầm cho widget layer.

### 3.5. God Widget

**File**: `orientation_guard.dart` (149 dòng)

Widget vừa resolve controller, apply, restore, detect mismatch, render block UI, check `kIsWeb`. Cần thu gọn còn lifecycle + delegate.

### 3.6. MismatchView hardcode tiếng Việt

**File**: `orientation_mismatch_view.dart` (dòng 44, 55-56)

Text "Vui lòng xoay ngang thiết bị" hardcode. Package nên ngôn ngữ trung lập, app tự override qua builder.

---

## 4. Nơi sử dụng trong App chính

| File trong App | API đang dùng | Impact khi refactor |
|:---|:---|:---|
| `game_block_orientation_resolver.dart` | `OrientationPolicy`, `ScreenUiPolicy(immersive:)` | Tách `immersive` sang `fullscreen_guard` |
| `app_orientation_provider.dart` | `OrientationController.apply()`, `restore()` | Đổi interface, truyền `previousPolicy` |
| `app_orientation_orchestrator.dart` | `GlobalOrientationOrchestrator`, `createOrientationController()` | Đổi sang widget mới |
| `game_player_screen.dart` | Tham chiếu OrientationGuard (comments) | Cập nhật comments |

---

## 5. Các quyết định đã chốt

| Câu hỏi | Quyết định |
|:---|:---|
| iPadOS `UIRequiresFullScreen` | Để app tự config trong `Info.plist`, package không can thiệp |
| Fullscreen migration | Dùng `fullscreen_guard` package có sẵn |
| Backward compatibility | Phát triển v1 song song (`src_v1/`), test trên example trước, migrate app sau |
| Testing | Cả unit test thuần + widget test với `MediaQuery` mock |
| Policy stack | Giữ ở tầng app (Riverpod), package chỉ nhận `previousPolicy` khi restore |

---

## 6. Ranh giới trách nhiệm Package vs App

| Concern | Package (orientation_guard) | App layer |
|:---|:---:|:---:|
| Apply orientation | ✅ | |
| Restore (nhận policy cụ thể) | ✅ | |
| Quản lý thứ tự policy (stack) | | ✅ |
| Detect mismatch | ✅ | |
| Hiển thị mismatch UI (default) | ✅ | |
| Custom mismatch UI (builder) | | ✅ |
| Fullscreen / Immersive | | ✅ (via `fullscreen_guard`) |
| iPadOS plist config | | ✅ |

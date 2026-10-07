# PiP Video Player - Implementation Plan

## 📋 Tổng quan

Tài liệu này mô tả kế hoạch triển khai tính năng Picture-in-Picture (PiP) Video Player cho ứng dụng Flutter, dựa trên flow document `PIP_FLOW.md`.

---

## 🎯 Mục tiêu

Triển khai hệ thống PiP Video Player với các tính năng:
- ✅ Phát video từ URL (HLS stream)
- ✅ PiP window hiển thị trên mọi màn hình (Overlay-based)
- ✅ Drag & Drop window
- ✅ Minimize/Maximize window (40% và 80% width device)
- ✅ Auto-hide/show controls với timer 3s
- ✅ PiP icon ở top-right của video
- ✅ Background playback khi ở PiP mode
- ✅ Smart close logic: về page play hoặc tắt video
- ✅ Video tiếp tục phát khi navigate sang màn hình khác
- ✅ Statistics overlay trên video player (hiển thị match statistics giống tab "bảng điểm")
- ✅ Dynamic height management (video player 16:9 aspect ratio theo device width, không set height cố định)
- ✅ Auto PiP khi scroll quá 60% của VideoPlayer (tự động chuyển sang PiP mode khi scroll)
- ✅ Tự động chuyển tab sang "Bảng điểm" khi vào PiP mode

---

## 🏗️ Kiến trúc

### **Components chính:**

1. **LivestreamWidgetImpl** (`livestream_widget_mobile.dart`)
   - Quản lý video player chính
   - Load và phát video từ URL
   - Hiển thị video player UI với tỉ lệ 16:9 (tính theo device width)
   - Hiển thị statistics overlay trên video player (nếu có eventData)
   - Tích hợp với PipManager
   - Dynamic height: Column tự tính height từ statistics overlay + video player

2. **PipManager** (`pip_manager.dart`)
   - **Singleton Manager** quản lý PiP window toàn cục
   - Sử dụng **Overlay** để hiển thị PiP trên mọi màn hình
   - Quản lý state tập trung (position, size, controls)
   - Cho phép video tiếp tục phát khi navigate

### **Overlay Architecture:**

```
MaterialApp
  └─ Overlay (Global)
      └─ PipManager._overlayEntry
          └─ PiP Window (Positioned)
              └─ VideoPlayer + Controls
```

**Lợi ích:**
- ✅ PiP window hiển thị trên mọi màn hình
- ✅ Không phụ thuộc vào widget tree của màn hình hiện tại
- ✅ Video tiếp tục phát khi navigate
- ✅ Persistent across navigation

---

## 📝 Implementation Tasks

### **Phase 1: Core Infrastructure**

#### **Task 1.1: Tạo PipManager Singleton**
- [x] Tạo file `lib/shared/widgets/livestream/pip_manager.dart`
- [x] Implement Singleton pattern
- [x] Define state variables:
  - `_controller: VideoPlayerController?` (Reference)
  - `_isPiPMode: bool`
  - `_isMinimized: bool`
  - `_pipPosition: Offset`
  - `_isDragging: bool`
  - `_showControls: bool`
  - `_isOnVideoPage: bool`
  - `_controlsTimer: Timer?`
  - `_overlayEntry: OverlayEntry?`
  - `_context: BuildContext?`
  - `_onClose: VoidCallback?`
  - `_onPlayPause: Function(bool)?`
- [x] Implement methods:
  - `initialize(context, controller, onClose, onPlayPause)`
  - `showPiP()`
  - `hidePiP()`
  - `closePiP()`
  - `setOnVideoPage(bool)`
  - `togglePlayPause()`
  - `_createOverlay()`
  - `_removeOverlay()`
  - `_updateOverlay()`
  - `_buildPiPOverlay()`
  - `_showControlsWithAutoHide()`
  - `_hideControls()`
  - `_videoListener()`

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`

**Estimated Time:** 4-6 hours

**Status:** ✅ Completed

---

#### **Task 1.2: Refactor LivestreamWidgetImpl để sử dụng VideoPlayer**
- [x] Chuyển từ `WebView` sang `video_player` package
- [x] Implement `VideoPlayerController` initialization
- [x] Implement video loading flow
- [x] Implement play/pause controls
- [x] Implement auto-show/hide controls với timer 3s
- [x] Add PiP icon ở top-right video
- [x] Integrate với PipManager:
  - [x] Call `PipManager().initialize()` sau khi video load xong (line 103)
  - [x] Call `PipManager().showPiP()` khi click PiP icon (line 298)
  - [x] Sync state với PipManager:
    - [x] `_isPiPMode` sync khi click PiP icon (line 295) và khi close (line 133)
    - [x] `_isPlaying` sync qua `_onPipPlayPause` callback (line 154-159)
    - [x] `PipManager().setOnVideoPage(true)` khi click PiP icon (line 297)

**State Variables:**
- `_controller: VideoPlayerController?`
- `_isPlaying: bool`
- `_isLoading: bool`
- `_isPiPMode: bool` (Sync với PipManager)
- `_showControls: bool`
- `_controlsTimer: Timer?`

**Files:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`

**Estimated Time:** 3-4 hours

**Status:** ✅ Completed

---

### **Phase 2: PiP Window Implementation**

#### **Task 2.1: Implement PiP Overlay UI**
- [x] Implement `_buildPiPOverlay()` trong PipManager (line 253)
- [x] Create Positioned widget với vị trí động (line 298-300)
- [x] Implement VideoPlayer widget trong PiP window (line 363-370)
- [x] Implement controls overlay (play/pause, minimize/maximize, close):
  - [x] Play/Pause overlay (line 384-405)
  - [x] Minimize/Maximize button (line 415-435)
  - [x] Close button (line 438-452)
- [x] Implement drag indicator khi đang drag (line 370-382)
- [x] Implement AnimatedContainer cho smooth transitions (line 337-357)

**UI Components:**
- VideoPlayer (aspect ratio 16:9)
- Play/Pause overlay (center)
- Controls bar (top-right):
  - Minimize/Maximize button
  - Close button
- Drag indicator (top bar khi dragging)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`

**Estimated Time:** 4-5 hours

---

#### **Task 2.2: Implement Drag & Drop**
- [x] Implement `onScaleStart` handler (line 302-306)
  - [x] Set `_isDragging = true`
  - [x] Hide controls
  - [x] Show drag indicator (line 374-386)
- [x] Implement `onScaleUpdate` handler (line 307-323)
  - [x] Check `pointerCount == 1` (drag mode)
  - [x] Update `_pipPosition` với delta (sử dụng `_pipPosition` hiện tại)
  - [x] Clamp position trong bounds
  - [x] Call `_updateOverlay()` để rebuild
- [x] Implement `onScaleEnd` handler (line 324-327)
  - [x] Set `_isDragging = false`
  - [x] Show controls với auto-hide

**Bounds Calculation:**
```dart
_pipPosition.dx.clamp(safeArea.left, bodyWidth - _pipWidth - safeArea.right)
_pipPosition.dy.clamp(0, bodyHeight - _pipHeight - safeArea.bottom)
```

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`

**Estimated Time:** 2-3 hours

---

#### **Task 2.3: Implement Minimize/Maximize**
- [x] Implement toggle logic (line 273):
  - [x] Minimized: 40% width device, aspect ratio 16:9
  - [x] Maximized: 80% width device, aspect ratio 16:9
- [x] Implement button click handler (line 419-424)
- [x] Implement double-tap handler (line 331-336)
- [x] Adjust position khi resize để giữ trong bounds (line 245-270: `_toggleMinimizeMaximize()`)
- [x] Animate resize với AnimatedContainer (line 337-357)

**Size Calculation:**
```dart
final availableWidth = screenSize.width - safeArea.left - safeArea.right;
final pipWidth = _isMinimized 
    ? availableWidth * 0.4  // Minimized
    : availableWidth * 0.8; // Maximized
final pipHeight = pipWidth * (9 / 16); // 16:9 aspect ratio
```

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`

**Estimated Time:** 2-3 hours

---

### **Phase 3: Controls & Interactions**

#### **Task 3.1: Implement Controls Auto-Hide/Show**
- [x] Implement `_showControlsWithAutoHide()` (line 235-242):
  - [x] Set `_showControls = true`
  - [x] Cancel timer cũ (nếu có)
  - [x] Create timer mới với 3s delay
  - [x] Auto-hide sau 3s
- [x] Implement `_hideControls()` (line 245-250):
  - [x] Cancel timer
  - [x] Set `_showControls = false`
- [x] Show controls khi:
  - [x] Video load xong (delay 100ms) - livestream_widget_mobile.dart line 112-116
  - [x] User tap vào video - livestream_widget_mobile.dart line 220-223
  - [x] User tap vào PiP window - pip_manager.dart line 361-363
  - [x] User drag window (hide khi drag, show khi end) - pip_manager.dart line 335-360
  - [x] User click controls button - pip_manager.dart line 281, 424

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`

**Estimated Time:** 2 hours

---

#### **Task 3.2: Implement Play/Pause trong PiP**
- [x] Implement `togglePlayPause()` trong PipManager (line 141-157)
- [x] Sync state với controller (line 146-152)
- [x] Call `_onPlayPause?.call(_isPlaying)` để sync với LivestreamWidgetImpl (line 153)
- [x] Update UI icon (play ↔ pause) - line 430-436 trong _buildPiPOverlay
- [x] Implement tap vào video để play/pause - line 419-440 (Play/Pause overlay)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`

**Estimated Time:** 1-2 hours

---

#### **Task 3.3: Implement Smart Close Logic**
- [x] Implement `closePiP()` trong PipManager (line 92-139)
- [x] Check `_isOnVideoPage` (line 97):
  - [x] **true** (đang ở video page):
    - [x] Call `_onClose?.call()` (line 100)
    - [x] LivestreamWidgetImpl: `_isPiPMode = false` (line 133 trong _onPipClose)
    - [x] Về trạng thái ban đầu (video lớn hiển thị)
  - [x] **false** (đã rời khỏi video page):
    - [x] Call `_onClose?.call()` với try-catch (line 107)
    - [x] `_controller?.pause()` (line 117)
    - [x] `_controller?.dispose()` (line 119)
    - [x] `_controller = null` (line 120)
    - [x] Tắt video và giải phóng data
- [x] Remove OverlayEntry (line 88 trong hidePiP)
- [x] Cleanup state (line 127-138)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`

**Estimated Time:** 2-3 hours

---

#### **Task 3.4: Implement Fullscreen Icon trong PiP Window**
- [x] Implement fullscreen icon (`AppIcons.iconVideoFull`) trong PiP controls (pip_manager.dart line 587-608)
- [x] Set callback `onFullscreenRequested` trong `PipManager.initialize()` hoặc `setFullscreenCallback()` (bet_detail_mobile_v2_screen.dart line 75-77, 83-84)
- [x] Implement `_handleFullscreenRequest()` trong `bet_detail_mobile_v2_screen.dart` (line 150-175):
  - [x] Reset sticky state nếu đang ở tab 'bảng điểm' và có sticky headers
  - [x] Switch tab sang 'Trực tuyến' thông qua `_switchToLiveTab()`
  - [x] PiP sẽ tự động close trong `LivestreamWidgetImpl.didUpdateWidget()`
- [x] Implement `_switchToLiveTab()` với scroll to top (line 177-191):
  - [x] Switch tab sang 'Trực tuyến' bằng `MatchHeaderTabController.setTab(MatchTab.live)`
  - [x] Scroll về top position với animation 50ms (`_scrollController.animateTo(0)`)
- [x] Flow: Click fullscreen icon → `_onFullscreenRequested?.call()` → `_handleFullscreenRequest()` → Reset sticky → Switch tab → Scroll to top → Close PiP
- [x] **Update: PiP hiển thị mọi màn hình, fullscreen logic theo context:**
  - [x] PiP window hiển thị trên mọi màn hình trong ứng dụng (không dispose khi rời khỏi bet_detail_mobile_v2_screen)
  - [x] Update `bet_detail_mobile_v2_screen.dispose()`: Chỉ set `setOnVideoPage(false)`, không dispose PipManager
    - **Lý do:** `setOnVideoPage(false)` để track navigation state và điều chỉnh behavior:
      - `closePiP()`: Cleanup callbacks thay vì giữ lại
      - Fullscreen icon: Dispose PipManager thay vì gọi callback
  - [x] Update fullscreen callback logic: Check `_isOnVideoPage`:
    - [x] Nếu `_isOnVideoPage = true`: Gọi callback `_onFullscreenRequested` (logic hiện tại)
    - [x] Nếu `_isOnVideoPage = false`: Dispose PipManager (đóng PiP và cleanup)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 587-608, update fullscreen callback logic)
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart` (line 91-98, update dispose logic)

**Estimated Time:** 2-3 hours

---

### **Phase 4: Navigation & Background Playback**

#### **Task 4.1: Implement Navigation Tracking**
- [x] Implement `setOnVideoPage(bool)` trong PipManager (line 156-159)
- [x] Call `setOnVideoPage(true)` khi vào video page (bet_detail_mobile_v2_screen.dart line 68)
- [x] Call `setOnVideoPage(false)` khi rời khỏi video page (bet_detail_mobile_v2_screen.dart line 93)

**Mục đích của `_isOnVideoPage`:**
- **Track navigation state:** Biết đang ở `bet_detail_mobile_v2_screen` hay đã rời khỏi
- **Điều chỉnh behavior của `closePiP()`:**
  - `_isOnVideoPage = true`: Giữ lại callbacks (có thể cần dùng lại), chỉ reset state
  - `_isOnVideoPage = false`: Cleanup callbacks (set = null), giữ lại controller
- **Điều chỉnh behavior của Fullscreen Icon:**
  - `_isOnVideoPage = true`: Gọi callback `_onFullscreenRequested` (reset sticky, switch tab, scroll to top)
  - `_isOnVideoPage = false`: Dispose PipManager (đóng PiP và cleanup controller)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 156-159, 219-257, 593-599)
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart` (line 68, 93)

**Implementation Details:**
- Import `PipManager` vào `bet_detail_mobile_v2_screen.dart`
- Gọi `PipManager().setOnVideoPage(true)` trong `initState()` với `addPostFrameCallback` để đảm bảo widget đã mount
- Gọi `PipManager().setOnVideoPage(false)` trong `dispose()` để track khi rời khỏi video page
- **QUAN TRỌNG:** Không dispose PipManager trong `dispose()` để PiP có thể hiển thị trên mọi màn hình

**Estimated Time:** 2-3 hours

---

#### **Task 4.2: Implement Background Playback**
- [x] Đảm bảo OverlayEntry được insert ở cấp MaterialApp (line 310: `Navigator.of(_context!, rootNavigator: true)`)
- [x] Đảm bảo PiP window vẫn hiển thị khi navigate (OverlayEntry ở MaterialApp level)
- [x] Đảm bảo video tiếp tục phát khi navigate (Controller được quản lý bởi PipManager, không bị dispose khi switch tab)
- [x] Test với các scenarios:
  - Navigate từ video page sang page khác ✅
  - Navigate back về video page ✅
  - Close PiP từ page khác ✅
  - Close PiP từ video page ✅

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 298-323: `_createOverlay()`)

**Implementation Details:**
- Sử dụng `Navigator.of(_context!, rootNavigator: true).overlay` để insert OverlayEntry ở MaterialApp level
- Controller được quản lý bởi PipManager (OWNER), không bị dispose khi LivestreamWidgetImpl bị remove khỏi widget tree
- Video tiếp tục phát khi navigate vì controller vẫn tồn tại trong PipManager

**Estimated Time:** 2-3 hours

---

### **Phase 5: Error Handling & Edge Cases**

#### **Task 5.1: Implement Error Handling**
- [x] Try-catch trong tất cả controller operations (line 77-85, 97-121, 226-240, 249-259)
- [x] Check `controller != null` và `controller.value.isInitialized` (line 45-46, 227, 390)
- [x] Graceful degradation khi controller dispose (line 395-403: check dispose và close PiP)
- [x] Error handling trong Overlay operations (line 307-322: try-catch khi insert overlay)
- [x] Error handling trong callback calls (line 207-210: try-catch khi gọi callbacks)

**Error Scenarios:**
- Controller đã dispose ✅ (line 395-403)
- Overlay context invalid ✅ (line 301, 310-322)
- Callback widget đã dispose ✅ (line 207-210)
- Network errors ✅ (line 97-121: try-catch trong loadVideo)
- Video load errors ✅ (line 97-121: catch và cleanup)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 77-85, 97-121, 207-210, 226-240, 249-259, 301, 307-322, 390-403)
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`

**Estimated Time:** 3-4 hours

---

#### **Task 5.2: Handle Edge Cases**
- [x] URL thay đổi khi đang ở PiP mode (line 64-72: check URL và dispose controller cũ nếu URL khác)
- [x] Widget dispose khi đang ở PiP mode (line 243-277: dispose() method cleanup tất cả)
- [ ] Screen rotation khi đang ở PiP mode (chưa implement, có thể cải thiện sau)
- [x] Multiple video instances (line 64-72: chỉ có 1 controller tại 1 thời điểm, dispose controller cũ khi load URL mới)
- [x] Memory leaks (timer cleanup, controller disposal) (line 267-268: cancel timer, line 249-259: dispose controller)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 64-72, 243-277)
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`

**Implementation Details:**
- URL change handling: Check `_currentUrl == url` trước khi load, dispose controller cũ nếu URL khác
- Widget dispose: `dispose()` method cleanup controller, timer, callbacks, và overlay
- Memory leaks prevention: Timer được cancel trong `dispose()`, controller được dispose đúng cách

**Estimated Time:** 3-4 hours

---

### **Phase 6: Integration & Testing**

#### **Task 6.1: Integrate với Bet Detail Screen**
- [x] Update `bet_detail_mobile_v2_screen.dart`:
  - Call `PipManager().setOnVideoPage(true)` khi vào screen (line 58-61: initState với addPostFrameCallback)
  - Call `PipManager().setOnVideoPage(false)` khi rời screen (line 65-66: dispose)
  - Dispose PipManager khi dispose screen (line 67: `PipManager().dispose()`)
- [x] Update `match_header_mobile_widget.dart`:
  - Check PiP mode khi render Live tab (không cần thiết vì controller được quản lý bởi PipManager)
  - Handle tab switching khi đang ở PiP mode (controller không bị dispose khi switch tab)

**Files:**
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart` (line 17, 58-61, 65-67)
- `lib/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart`

**Implementation Details:**
- `initState()`: Gọi `PipManager().setOnVideoPage(true)` với `addPostFrameCallback` để đảm bảo widget đã mount
- `dispose()`: Gọi `PipManager().setOnVideoPage(false)` và `PipManager().dispose()` để cleanup controller và overlay
- Tab switching: Controller được quản lý bởi PipManager, không bị dispose khi LivestreamWidgetImpl bị remove khỏi widget tree

**Estimated Time:** 2-3 hours

---

#### **Task 6.2: Testing**
- [ ] Test video loading và playback
- [ ] Test PiP mode activation
- [ ] Test drag & drop
- [ ] Test minimize/maximize
- [ ] Test controls auto-hide/show
- [ ] Test play/pause
- [ ] Test close logic (on video page và off video page)
- [ ] Test navigation scenarios
- [ ] Test background playback
- [ ] Test error scenarios
- [ ] Test edge cases

**Test Scenarios:**
1. Xem video bình thường
2. Vào PiP mode
3. Navigate sang màn hình khác
4. Tương tác với PiP window
5. Close PiP từ video page
6. Close PiP từ page khác
7. URL thay đổi khi đang ở PiP mode
8. Widget dispose khi đang ở PiP mode

**Estimated Time:** 4-6 hours

---

## 📦 Dependencies

### **Packages cần thiết:**
- `video_player: ^2.8.0` (hoặc version mới nhất)
- `hooks_riverpod: ^2.4.0` (nếu sử dụng Riverpod)

### **Files cần tạo:**
- `lib/shared/widgets/livestream/pip_manager.dart` (mới)
- `lib/shared/widgets/livestream/pip_extensions.dart` (nếu cần helper methods)

### **Files cần update:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`
- `lib/shared/widgets/livestream/livestream_widget_web.dart` (nếu cần)
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart`
- `lib/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart`

---

## 🎨 UI/UX Specifications

### **PiP Window:**
- **Minimized Size:** 40% width device, aspect ratio 16:9
- **Maximized Size:** 80% width device, aspect ratio 16:9
- **Default Position:** Bottom-right với padding 16px
- **Border Radius:** 12px
- **Shadow:** BoxShadow với blur 10-15px
- **Background:** Black (#000000)

### **Controls:**
- **Auto-hide Timer:** 3 seconds
- **Show Controls khi:**
  - Video load xong (delay 100ms)
  - User tap vào video
  - User tap vào PiP window
  - User click controls button
- **Hide Controls khi:**
  - Auto-hide sau 3s không tương tác
  - User đang drag window

### **Icons:**
- **PiP Icon:** `AppIcons.iconPip` (top-right video)
- **Play Icon:** `AppIcons.iconPlay`
- **Pause Icon:** `AppIcons.iconPause`
- **Fullscreen Icon:** `AppIcons.iconVideoFull` (top-left PiP window, để quay về fullscreen)
- **Close Icon:** `AppIcons.iconClosePip` (top-right PiP window)

---

## 🔄 State Management Flow

### **LivestreamWidgetImpl State:**
```
_controller: VideoPlayerController? (Getter từ PipManager, không phải owner)
_isPlaying: bool (Sync với PipManager qua callback)
_isLoading: bool (Sync với PipManager qua callback)
_isPiPMode: bool (Sync với PipManager)
_showControls: bool (Local state cho main video)
_controlsTimer: Timer? (Local timer cho main video)
```

### **PipManager State (Singleton):**
```
_controller: VideoPlayerController? (OWNER: PipManager quản lý lifecycle)
_currentUrl: String? (Track URL hiện tại)
_isPiPMode: bool
_isMinimized: bool
_pipPosition: Offset
_isDragging: bool
_showControls: bool (Controls cho PiP window)
_isPlaying: bool
_isLoading: bool
_isOnVideoPage: bool
_controlsTimer: Timer? (Timer cho PiP controls)
_overlayEntry: OverlayEntry?
_context: BuildContext?
_onClose: VoidCallback?
_onPlayPause: Function(bool)?
_onLoadingChanged: Function(bool)?
```

### **State Synchronization:**
```
LivestreamWidgetImpl ↔ PipManager:
1. LivestreamWidgetImpl → PipManager:
   - loadVideo(): Load video và tạo controller (PipManager là owner)
   - initialize(): Set context và callbacks
   - showPiP(): Bật PiP mode
   - setOnVideoPage(): Track navigation

2. PipManager → LivestreamWidgetImpl:
   - _onClose?.call(): Khi close PiP
   - _onPlayPause?.call(): Khi play/pause thay đổi
   - _onLoadingChanged?.call(): Khi loading state thay đổi
   - _videoListener(): Sync playing state
```

---

## ⚠️ Important Notes

### **Controller Management:**
- **Single Controller Instance:** Chỉ có 1 `VideoPlayerController` instance tại 1 thời điểm
- **Controller Owner:** `PipManager` là OWNER của controller (quản lý lifecycle: create, initialize, dispose)
- **Controller Usage:** `LivestreamWidgetImpl` chỉ sử dụng controller từ PipManager, không dispose
- **Controller Disposal:** Chỉ dispose khi:
  - Load video mới với URL khác (trong PipManager.loadVideo())
  - Dispose PipManager khi rời khỏi bet_detail_mobile_v2_screen (trong PipManager.dispose())
- **URL Change Handling:** Khi URL thay đổi, dispose controller cũ và tạo controller mới (line 75-87)
- **Tab Switching:** Controller không bị dispose khi switch tab vì được quản lý bởi PipManager (không phụ thuộc vào LivestreamWidgetImpl lifecycle)

### **Overlay Management:**
- **OverlayEntry Creation:** Tạo khi `showPiP()`
- **OverlayEntry Removal:** Remove khi `hidePiP()` hoặc `closePiP()`
- **Overlay Rebuild:** Gọi `_updateOverlay()` để rebuild overlay
- **Context Validity:** Kiểm tra `_context != null` trước khi tạo Overlay

### **Memory Management:**
- **Timer Cleanup:** Cancel timer trong `dispose()` hoặc khi hide controls
- **Controller Cleanup:** Dispose controller khi không cần thiết
- **Overlay Cleanup:** Remove OverlayEntry khi không cần thiết
- **Callback Cleanup:** Set callbacks = null khi dispose

### **Error Handling:**
- **Try-catch ở mọi nơi:** Controller operations, Overlay operations, Callback calls
- **Null Checks:** Kiểm tra null trước khi access
- **Graceful Degradation:** Return empty widget hoặc ignore errors
- **Logging:** Debug print errors để dễ debug

---

## 📊 Estimated Timeline

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1: Core Infrastructure | 2 tasks | 7-10 hours |
| Phase 2: PiP Window Implementation | 3 tasks | 8-11 hours |
| Phase 3: Controls & Interactions | 3 tasks | 5-7 hours |
| Phase 4: Navigation & Background Playback | 2 tasks | 4-6 hours |
| Phase 5: Error Handling & Edge Cases | 2 tasks | 6-8 hours |
| Phase 6: Integration & Testing | 2 tasks | 6-9 hours |
| **Total** | **14 tasks** | **36-51 hours** |

---

## ✅ Definition of Done

- [x] PipManager được implement với Singleton pattern
- [x] LivestreamWidgetImpl sử dụng VideoPlayer thay vì WebView
- [x] PiP window hiển thị trên mọi màn hình (Overlay-based)
- [x] Drag & Drop hoạt động mượt mà
- [x] Minimize/Maximize hoạt động đúng
- [x] Controls auto-hide/show với timer 3s
- [x] Play/Pause hoạt động trong PiP
- [x] Smart close logic hoạt động đúng
- [x] Background playback hoạt động khi navigate
- [x] Error handling đầy đủ
- [x] Edge cases được xử lý (URL change, widget dispose, memory leaks)
- [x] Integration với Bet Detail Screen hoàn tất
- [ ] Testing đầy đủ các scenarios (cần test thêm)
- [ ] Code review và cleanup (cần review)
- [x] Documentation đầy đủ (PIP_FLOW.md, PIP_IMPLEMENTATION_PLAN.md)

---

## 🐛 Bug Fixes & Improvements

### **Fix 1: Drag Bounds - PiP Window có thể drag tới bottom của device**
**Vấn đề:** PiP window không thể drag xuống bottom của device vì bị giới hạn bởi `bodyHeight` (đã trừ AppBar).

**Giải pháp:**
- Thay đổi bounds calculation từ `bodyHeight` sang `screenSize.height`
- Drag bounds (Y-axis): Từ `0` đến `screenSize.height - pipHeight - safeArea.bottom`
- Cập nhật trong `_buildPiPOverlay()` và `_toggleMinimizeMaximize()`

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 317, 333, 355, 371, 460)

**Date:** 2024

---

### **Fix 2: Close PiP Logic - Không cleanup context khi đang ở video page**
**Vấn đề:** Khi close PiP và đang ở video page, `closePiP()` cleanup `_context`, `_onClose`, `_onPlayPause`, khiến lần sau click PiP icon không thể show PiP window (vì `_context == null`).

**Giải pháp:**
- Khi đang ở video page: Chỉ reset state (position, minimized, etc.), **KHÔNG cleanup** `_context`, `_onClose`, `_onPlayPause`
- Chỉ cleanup khi rời khỏi video page (dispose controller và cleanup tất cả)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart` (line 97-144)

**Date:** 2024

---

### **Fix 3: Re-initialize PipManager khi click PiP icon**
**Vấn đề:** Khi click PiP icon lần 2, không re-initialize PipManager, có thể dẫn đến context hoặc controller không được update đúng.

**Giải pháp:**
- Luôn re-initialize PipManager trước khi show PiP để đảm bảo context và controller được update đúng
- Đảm bảo `_context`, `_controller`, `_onClose`, `_onPlayPause` luôn được set lại

**Files:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart` (line 289-296)

**Date:** 2024

---

### **Fix 4: Tap vào video chỉ show controls, không toggle play/pause**
**Vấn đề:** Tap vào video sẽ toggle play/pause, không phù hợp với UX.

**Giải pháp:**
- Tap vào video: Chỉ show controls (không toggle play/pause)
- Tap vào Play/Pause icon overlay: Toggle play/pause

**Files:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart` (line 216-219)

**Date:** 2024

---

### **Fix 5: Controller Ownership - Di chuyển controller từ LivestreamWidgetImpl sang PipManager**
**Vấn đề:** Controller được quản lý bởi `LivestreamWidgetImpl`, khi switch tab trong `MatchHeaderMobileWidget`, `LivestreamWidgetImpl` bị dispose, dẫn đến controller bị dispose và PiP window không thể play video.

**Giải pháp:**
- **PipManager là OWNER của VideoPlayerController**: PipManager quản lý toàn bộ lifecycle (create, initialize, dispose)
- **LivestreamWidgetImpl chỉ sử dụng controller**: Không dispose controller, chỉ sử dụng controller từ PipManager
- **loadVideo() trong PipManager**: Method này tạo, initialize, và quản lý controller. Nếu URL giống nhau và controller đã có, không load lại.
- **dispose() trong PipManager**: Method này được gọi từ `bet_detail_mobile_v2_screen.dispose()` để cleanup controller và overlay
- **Tab switching**: Controller không bị dispose khi switch tab vì được quản lý bởi PipManager (không phụ thuộc vào LivestreamWidgetImpl lifecycle)

**Files:**
- `lib/shared/widgets/livestream/pip_manager.dart`:
  - Line 18: `VideoPlayerController? _controller; // OWNER: PipManager quản lý controller`
  - Line 50-121: `loadVideo()` method tạo và quản lý controller
  - Line 243-277: `dispose()` method cleanup controller
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`:
  - Removed `VideoPlayerController` instance variable
  - `_controller` getter: `PipManager().controller`
  - `_loadVideo()`: Gọi `PipManager().loadVideo()` thay vì tạo controller
  - `dispose()`: Không dispose controller (chỉ cancel local timer)
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart`:
  - Line 67: Gọi `PipManager().dispose()` trong `dispose()` method

**Date:** 2024

---

### **Fix 6: Statistics Overlay trên Video Player**
**Vấn đề:** Cần hiển thị statistics table (giống tab "bảng điểm") trên video player khi đang play.

**Giải pháp:**
- Thêm `eventData` parameter vào `LivestreamWidget` và `LivestreamWidgetImpl`
- Implement `_buildStatisticsOverlay()` sử dụng `MobileStatisticsTableWidget`
- Hiển thị statistics overlay trong Column layout:
  - Statistics overlay ở trên (nếu có `eventData`)
  - Video player ở dưới (tỉ lệ 16:9 theo width device)
- Khi `_isPiPMode = true`: chỉ hiển thị statistics overlay, ẩn video player

**Files:**
- `lib/shared/widgets/livestream/livestream_widget.dart`:
  - Line 22: Thêm `eventData: LeagueEventData?` parameter
  - Line 33: Truyền `eventData` vào `LivestreamWidgetImpl`
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`:
  - Line 13: Thêm `eventData: LeagueEventData?` parameter
  - Line 169-170: Hiển thị statistics overlay trong Column
  - Line 314-322: Implement `_buildStatisticsOverlay()` method
- `lib/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart`:
  - Line 278-282: Truyền `eventData` vào `LivestreamWidget`

**Date:** 2024

---

### **Fix 7: Dynamic Height Management - Không set height cố định**
**Vấn đề:** Widget đang sử dụng height cố định, không responsive theo device width.

**Giải pháp:**
- Bỏ `height` parameter khỏi `LivestreamWidget` và `LivestreamWidgetImpl`
- Tính video player height theo tỉ lệ 16:9: `videoPlayerHeight = screenWidth * 9 / 16`
- Column tự động tính height từ children:
  - Statistics overlay: height cố định (130px)
  - Video player: height tính theo 16:9
- AnimatedContainer không set height, để Column tự tính

**Files:**
- `lib/shared/widgets/livestream/livestream_widget.dart`:
  - Removed `height` parameter
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`:
  - Removed `height` parameter
  - Line 151-153: Tính `videoPlayerHeight` theo 16:9
  - Line 161-165: AnimatedContainer không set height
  - Line 166-177: Column với `mainAxisSize: MainAxisSize.min` tự tính height
- `lib/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart`:
  - Removed `height: 380` parameter

**Date:** 2024

---

### **Fix 8: Bottom Overflow - Sửa lỗi overflow khi ở PiP mode**
**Vấn đề:** Khi `_isPiPMode = true`, chỉ hiển thị statistics overlay nhưng vẫn bị bottom overflow.

**Giải pháp:**
- Đơn giản hóa logic: Luôn dùng Column, không tách riêng logic cho PiP mode
- Statistics overlay: Hiển thị nếu có `eventData` (không phụ thuộc PiP mode)
- Video player: Chỉ hiển thị khi `!_isPiPMode`
- Column với `mainAxisSize: MainAxisSize.min` tự động tính height đúng

**Files:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`:
  - Line 166-177: Column đơn giản với conditional rendering
  - Line 169-170: Statistics overlay luôn hiển thị nếu có `eventData`
  - Line 172-275: Video player chỉ hiển thị khi `!_isPiPMode`

**Date:** 2024

---

### **Fix 9: Code Simplification - Đơn giản hóa logic hiển thị**
**Vấn đề:** Code kiểm tra rườm rà với nhiều điều kiện lồng nhau cho PiP mode và eventData.

**Giải pháp:**
- Đơn giản hóa logic: Luôn dùng Column với conditional rendering
- Statistics overlay: Hiển thị nếu có `eventData` (không cần kiểm tra PiP mode)
- Video player: Chỉ hiển thị khi `!_isPiPMode`
- Bỏ logic tách riêng cho PiP mode, sử dụng Column thống nhất

**Files:**
- `lib/shared/widgets/livestream/livestream_widget_mobile.dart`:
  - Line 166-177: Column đơn giản với conditional rendering
  - Line 169-170: `if (widget.eventData != null) _buildStatisticsOverlay()`
  - Line 172-275: `if (!_isPiPMode) SizedBox(height: videoPlayerHeight, ...)`

**Date:** 2024

---

### **Fix 10: Auto PiP khi scroll quá 60% của VideoPlayer**
**Vấn đề:** Cần tự động chuyển sang PiP mode khi user scroll quá 60% chiều cao của VideoPlayer trong tab "Trực tuyến".

**Giải pháp:**
- Track scroll position của `LivestreamWidget` bằng `GlobalKey`
- Tính scroll percentage: `(screenTop - livestreamOffsetY) / livestreamHeight`
- Khi scroll percentage >= 0.6 và đang ở tab "Trực tuyến", tự động trigger PiP mode
- Tự động chuyển tab sang "Bảng điểm" (scoreboard) khi vào PiP mode để hiển thị statistics

**Files:**
- `lib/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart`:
  - Line 53: Thêm `GlobalKey _livestreamKey` để track LivestreamWidget
  - Line 54: Thêm `GlobalKey _matchHeaderKey` để control tab
  - Line 127-202: Implement `_handleScrollAutoPiP()` method
  - Line 181-195: Auto trigger PiP và chuyển tab khi scroll >= 60%
- `lib/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart`:
  - Line 28: Thêm `GlobalKey? livestreamKey` parameter
  - Line 29: Thêm `void Function(MatchTab)? onTabChanged` callback
  - Line 50-51: Tạo public `MatchTab` enum và `MatchHeaderTabController` interface
  - Line 58-67: Implement `setTab()` method để set tab từ bên ngoài
  - Line 214-226: Implement `_convertToInternalTab()` method
  - Line 330-337: Gán `livestreamKey` cho `LivestreamWidget`
  - Line 364-369, 402-407, 446-451: Gọi `onTabChanged` callback khi tab thay đổi

**Implementation Details:**
- Scroll detection: Sử dụng `_handleScroll()` listener để track scroll position
- Scroll percentage calculation: `(screenTop - livestreamOffsetY) / livestreamHeight` khi `livestreamOffsetY < screenTop`
- Auto PiP trigger: Chỉ trigger khi `_currentTab == MatchTab.live && !PipManager().isPiPMode && scrollPercentage >= 0.6`
- Tab switching: Sử dụng `MatchHeaderTabController` interface và `addPostFrameCallback` để đảm bảo widget đã build

**Date:** 2024

---

## 📚 References

- `PIP_FLOW.md`: Flow document chi tiết
- `pip.dart`: Reference implementation
- `video_player` package documentation
- Flutter Overlay documentation

---

## 🔄 Next Steps

1. Review và approve plan này
2. Setup dependencies (video_player package)
3. Bắt đầu Phase 1: Core Infrastructure
4. Regular checkpoints sau mỗi phase
5. Testing và bug fixes
6. Code review và cleanup
7. Documentation update


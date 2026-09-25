# Fix Game Reload When Resuming From Background

## Root Cause

Khi app đi vào background, **cả iOS và Android** đều suspend WebView's network connections (WebSocket).
Khi app resume → game phát hiện mất kết nối WebSocket → hiển thị **reconnect UI của chính game** (không phải của app).

Game provider (SEXY) dùng WebSocket để duy trì session real-time. Khi WebSocket bị ngắt quá lâu (~30-60s), session không thể recover → game hiển thị reconnect/reload screen.

## Fix Strategy

**Thay vì để game hiển thị reconnect screen lỗi**, app sẽ chủ động detect background duration và **reload game với URL mới** (fresh session):

1. Detect app went to background → record timestamp
2. App resumes → check duration > 30s
3. Nếu đủ lâu → lấy fresh game URL từ API → reload WebView
4. Hiển thị app loading overlay mượt mà trong khi reload

**Kết quả**: User thấy loading overlay ngắn → game tiếp tục, thay vì reconnect screen lỗi.

## Changes Required

### 1. `game_player_screen.dart`

Thêm `WidgetsBindingObserver` để handle background/resume lifecycle:

```dart
class _GamePlayerScreenState extends ConsumerState<GamePlayerScreen>
    with LoggerMixin, WidgetsBindingObserver {
  
  DateTime? _backgroundTimestamp;
  static const _backgroundThreshold = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ... existing code
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ... existing code
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundTimestamp = DateTime.now();
        logInfo('App went to background');
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      default:
        break;
    }
  }

  void _handleAppResumed() {
    final bg = _backgroundTimestamp;
    if (bg == null) return;
    
    final duration = DateTime.now().difference(bg);
    _backgroundTimestamp = null;
    
    if (duration > _backgroundThreshold) {
      logInfo('Background duration: ${duration.inSeconds}s > threshold, reloading game');
      _reloadGameWithFreshUrl();
    }
  }

  void _reloadGameWithFreshUrl() {
    _isLoading.update(true);
    _errorMessage.update(null);
    _showWebView.update(false);
    _gameUrl.update(null); // Remove old WebView
    
    _gameUrlNotifier.clear();
    _loadGameUrl(); // Fetches fresh URL → rebuilds WebView
  }
}
```

### 2. `web_view/game_web_view_mobile.dart`

Xóa `_hasNotifiedLoadStart`/`_hasNotifiedLoadStop` flags → cho phép notify loading state trên mỗi lần navigation:

```diff
-  bool _hasNotifiedLoadStart = false;
-  bool _hasNotifiedLoadStop = false;

   onPageStarted: (String url) {
-    if (!_hasNotifiedLoadStart) {
-      _hasNotifiedLoadStart = true;
       widget.onLoadStart?.call();
-    }
   },

   onPageFinished: (String url) {
-    if (!_hasNotifiedLoadStop) {
-      _hasNotifiedLoadStop = true;
       widget.onLoadStop?.call();
-    }
   },
```

## Manual Test Steps

1. Login → mở game SEXY → chờ load xong
2. Ấn Home (background) → chờ **1 phút**
3. Mở lại app
4. ✅ Thấy loading overlay của app → game load lại với session mới → chơi tiếp
5. ❌ Không thấy game reconnect screen lỗi hoặc màn hình trắng

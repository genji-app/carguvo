import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

const double _pipBorderRadius = 12.0;
const double _pipAspectRatio = 9 / 16;
const double _pipMinimizedWidthFactor = 0.4;
const double _pipMaximizedWidthFactor = 0.8;
const Duration _controlsAutoHideDuration = Duration(seconds: 3);
const Duration _showControlsDelay = Duration(milliseconds: 100);
const Duration _containerAnimationDuration = Duration(milliseconds: 200);

class PipManager {
  static final PipManager _instance = PipManager._internal();
  factory PipManager() => _instance;
  PipManager._internal();

  WebViewController? _webViewController;
  String? _currentUrl;

  int? _currentEventId;
  bool _isPiPMode = false;

  bool _isLiftedToOverlay = false;
  bool _isMinimized = false;
  Offset _pipPosition = Offset.zero;
  bool _isDragging = false;
  bool _showControls = false;
  bool _isOnVideoPage = true;

  bool _userClosed = false;

  Timer? _controlsTimer;
  OverlayEntry? _overlayEntry;
  bool _overlayEntryInserted =
      false;
  BuildContext? _context;
  VoidCallback? _onClose;
  void Function(bool)? _onPiPModeChanged;
  VoidCallback? _onFullscreenRequested;
  Widget Function(BuildContext)? _overlayControlsBuilder;

  final ValueNotifier<bool> isVideoPlaying = ValueNotifier(false);

  bool get isPiPMode => _isPiPMode;
  bool get isLiftedToOverlay => _isLiftedToOverlay;
  bool get isMinimized => _isMinimized;
  Offset get pipPosition => _pipPosition;
  bool get isDragging => _isDragging;
  bool get showControls => _showControls;
  bool get isOnVideoPage => _isOnVideoPage;

  bool get userClosed => _userClosed;

  bool get hasContent => _webViewController != null;

  int? get currentEventId => _currentEventId;

  WebViewController? get webViewController => _webViewController;

  void loadUrl(String url, BuildContext context, {int? eventId}) {
    debugPrint(
      '[LS-Load] loadUrl called. empty=${url.isEmpty} '
      'sameAsCurrent=${_currentUrl == url} '
      'isHls=${url.isEmpty ? "?" : _isHlsStreamUrl(url)} url=$url',
    );

    if (url.isEmpty) return;
    _context = context;
    if (eventId != null) _currentEventId = eventId;
    if (_webViewController != null && _currentUrl == url) return;
    _userClosed = false;
    _currentUrl = url;

    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params =
          WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{
              PlaybackMediaTypes.audio,
            },
          );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params =
          AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
          );
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectInlineGuardScript(controller),
          onWebResourceError: (err) {
            if (kDebugMode) {
              debugPrint(
                'PipManager WebView error: code=${err.errorCode} '
                'type=${err.errorType} desc=${err.description}',
              );
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'LogChannel',
        onMessageReceived: (message) {
          final msg = message.message;
          if (kDebugMode) debugPrint('[LS-WebView] $msg');
          if (msg == 'playing') {
            isVideoPlaying.value = true;
          } else if (msg == 'paused') {
            isVideoPlaying.value = false;
          }
        },
      );

    if (_isHlsStreamUrl(url)) {
      controller.loadHtmlString(
        _buildInlinePlayerHtml(url),
        baseUrl: _extractOrigin(url),
      );
    } else {
      controller.loadRequest(Uri.parse(url));
    }

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
    _updateOverlay();
  }

  static bool _isHlsStreamUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.m3u8');
  }

  static String _extractOrigin(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'https://localhost/';
    }
    return '${uri.scheme}://${uri.host}/';
  }

  static String _buildInlinePlayerHtml(String streamUrl) {
    final safeUrl = jsonEncode(streamUrl);
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no,viewport-fit=cover">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;height:100%;background:#000;overflow:hidden;}
video{
  width:100%;height:100%;
  object-fit:contain;background:#000;display:block;
  /* Force video vào compositing layer riêng — fix bug rendering noise
     (sọc màu YUV) trên Android WebView. TextureView compositing trên
     Android API 23+ có thể render sai decoder surface nếu video element
     nằm cùng layer với HTML content chính. `translate3d` và
     `will-change` buộc browser tạo hardware layer riêng cho video. */
  transform:translate3d(0,0,0);
  -webkit-transform:translate3d(0,0,0);
  will-change:transform;
  -webkit-backface-visibility:hidden;
  backface-visibility:hidden;
}
video::-webkit-media-controls-fullscreen-button{display:none!important;}
</style>
</head>
<body>
<video id="v" autoplay playsinline webkit-playsinline x5-playsinline
       preload="auto"></video>
<script src="https://cdn.jsdelivr.net/npm/hls.js@1.5.15/dist/hls.min.js"></script>
<script>
(function(){
  var v = document.getElementById('v');
  var url = $safeUrl;

  // Start muted — iOS policy yêu cầu muted để autoplay. Video giữ muted
  // xuyên suốt vòng đời. Nếu cần audio, thêm mute/unmute button (điều
  // khiển qua Flutter → runJavaScript) hoặc implement pattern khác.
  v.muted = true;
  v.defaultMuted = true;
  v.setAttribute('muted', '');

  function log(msg){
    try { document.title = 'LS: ' + msg; } catch(_){}
    try {
      if (window.LogChannel && window.LogChannel.postMessage)
        window.LogChannel.postMessage(msg);
    } catch(_){}
    try { console.log('[LS] ' + msg); } catch(_){}
  }

  var playing = false;
  function attemptPlay(from){
    if (playing) return;
    // GIỮ muted — iOS chỉ cho autoplay khi muted. Unmute chỉ có thể từ
    // Flutter runJavaScript (không count là WebView gesture, nhưng OK cho
    // chỉnh mute state) hoặc nếu thêm native UI.
    v.muted = false;
    v.defaultMuted = false;
    v.setAttribute('muted', '');
    var p;
    try { p = v.play(); } catch(e){ log('play-throw from=' + from + ' e=' + e); return; }
    if (p && p.then) {
      p.then(function(){
        playing = true;
        log('play-ok from=' + from);
      }).catch(function(e){
        log('play-reject from=' + from + ' err=' + e);
        // Video giữ pause state, user dùng Flutter play button để resume.
        // kỳ chỗ nào trong wrapper — xem `tapKick` bên dưới).
      });
    }
  }

  // Retry ở mọi event có thể play được — iOS đôi khi chần chừ giữa các
  // trạng thái, cần gọi play() nhiều lần cho chắc.
  ['loadstart','loadedmetadata','loadeddata','canplay','canplaythrough']
    .forEach(function(ev){
      v.addEventListener(ev, function(){ log(ev); attemptPlay(ev); });
    });

  v.addEventListener('playing', function(){
    playing = true;
    log('playing');
  });
  v.addEventListener('pause',    function(){ playing = false; log('paused'); });
  v.addEventListener('waiting',  function(){ log('waiting'); });
  v.addEventListener('stalled',  function(){ log('stalled'); });
  v.addEventListener('error',    function(){
    var e = v.error;
    log('video-error code=' + (e ? e.code : '?') + ' msg=' + (e ? e.message : '?'));
  });

  // Không còn tapKick trong WebView. Trên iOS, Flutter's GestureDetector
  // KHÔNG block được native touch xuyên xuống WKWebView (PlatformView
  // limitation) — nếu tapKick tồn tại, user tap Flutter button sẽ:
  //   - touchstart → WebView nhận → tapKick → v.play() → icon = pause
  //   - tap up     → Flutter onTap → togglePlayPause → pause
  // gây ra flicker "tap down = play, tap up = pause".
  //
  // Toàn bộ play/pause giờ chạy qua Flutter button (runJavaScript từ
  // Dart). Video giữ muted xuyên suốt — audio là concern riêng, có thể
  // thêm mute/unmute button sau nếu cần.

  var canNative = v.canPlayType('application/vnd.apple.mpegurl');
  log('canPlayType(m3u8)="' + canNative + '" hasHls=' + !!window.Hls);

  if (canNative) {
    log('path=native');
    v.src = url;
    v.load();
    attemptPlay('native-initial');
  } else if (window.Hls && window.Hls.isSupported()) {
    log('path=hlsjs');
    // Android WebView config: tắt worker mode (main-thread parse ổn định
    // hơn — Web Worker trên Android WebView hay gây rendering glitch).
    // Buffer nhỏ giảm memory, giảm chance của MSE stutter gây lỗi decoder.
    var hls = new Hls({
      lowLatencyMode: true,
      enableWorker: false,
      backBufferLength: 30,
      maxBufferLength: 20,
      maxMaxBufferLength: 30,
    });
    hls.loadSource(url);
    hls.attachMedia(v);
    hls.on(Hls.Events.MANIFEST_PARSED, function(){
      log('hls-manifest-parsed');
      attemptPlay('hls-manifest');
    });
    hls.on(Hls.Events.ERROR, function(_, d){
      log('hls-error type=' + d.type + ' details=' + d.details + ' fatal=' + d.fatal);
      if (d && d.fatal) {
        try { hls.destroy(); } catch(_){}
        v.src = url;
        v.load();
        attemptPlay('fallback');
      }
    });
  } else {
    log('path=fallback-direct');
    v.src = url;
    v.load();
    attemptPlay('direct');
  }
})();
</script>
</body>
</html>''';
  }

  static Future<void> _injectInlineGuardScript(
    WebViewController controller,
  ) async {
    const script = r'''
      (function() {
        if (window.__s88InlineGuardInstalled) return;
        window.__s88InlineGuardInstalled = true;

        function harden(v) {
          if (!v || v.__inlineHardened) return;
          v.__inlineHardened = true;
          try {
            v.setAttribute('playsinline', '');
            v.setAttribute('webkit-playsinline', '');
            v.setAttribute('x5-playsinline', '');
            v.playsInline = true;
          } catch (e) {}
        }

        function harvest(root) {
          if (!root || root.nodeType !== 1) return;
          if (root.tagName === 'VIDEO') harden(root);
          else if (root.querySelectorAll) {
            root.querySelectorAll('video').forEach(harden);
          }
        }

        function exitFullscreenSoft() {
          try {
            var v = document.querySelector('video');
            if (v && typeof v.webkitExitFullscreen === 'function') {
              v.webkitExitFullscreen();
            }
          } catch (e) {}
          try {
            if (document.exitFullscreen && document.fullscreenElement) {
              document.exitFullscreen().catch(function(){});
            }
          } catch (e) {}
        }

        function install() {
          harvest(document.body);
          harvest(document.documentElement);
          document.addEventListener('webkitbeginfullscreen', exitFullscreenSoft, true);
          document.addEventListener('fullscreenchange', function(){
            if (document.fullscreenElement) exitFullscreenSoft();
          });
          var target = document.documentElement || document.body;
          if (!target || !window.MutationObserver) return;
          new MutationObserver(function(mutations) {
            for (var i = 0; i < mutations.length; i++) {
              var added = mutations[i].addedNodes;
              for (var j = 0; j < added.length; j++) harvest(added[j]);
            }
          }).observe(target, { childList: true, subtree: true });
        }

        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', install);
        } else {
          install();
        }
      })();
    ''';
    try {
      await controller.runJavaScript(script);
    } catch (_) {}
  }

  void loadUrlForPiP(String url, BuildContext context, {int? eventId}) =>
      loadUrl(url, context, eventId: eventId);

  void releaseWebView() {
    final controller = _webViewController;
    if (controller != null) {
      controller
          .runJavaScript(
            "try{document.querySelectorAll('video,audio').forEach(function(m){try{m.pause();m.muted=true;m.src='';m.load&&m.load();}catch(e){}});}catch(e){}",
          )
          .catchError((_) {});
      controller.loadRequest(Uri.parse('about:blank')).catchError((_) {});
    }
    _webViewController = null;
    _currentUrl = null;
    _currentEventId = null;
    isVideoPlaying.value = false;
    _updateOverlay();
  }

  Future<void> playVideo() async {
    await _webViewController?.runJavaScript(
      "var v=document.getElementById('v');"
      "if(v){v.muted=true;var p=v.play();if(p&&p.catch)p.catch(function(){});}",
    );
  }

  Future<void> pauseVideo() async {
    await _webViewController?.runJavaScript(
      "var v=document.getElementById('v');if(v)v.pause();",
    );
  }

  Future<void> togglePlayPause() async {
    if (isVideoPlaying.value) {
      await pauseVideo();
    } else {
      await playVideo();
    }
  }

  void initialize(
    BuildContext context, {
    VoidCallback? onClose,
    void Function(bool)? onPiPModeChanged,
    VoidCallback? onFullscreenRequested,
  }) {
    _context = context;
    if (onClose != null) _onClose = onClose;
    if (onPiPModeChanged != null) _onPiPModeChanged = onPiPModeChanged;
    if (onFullscreenRequested != null)
      _onFullscreenRequested = onFullscreenRequested;
  }

  void setOnVideoPage(bool value) {
    _isOnVideoPage = value;
    if (!value) {
      _context = null;
    }
  }

  void setFullscreenCallback(VoidCallback? callback) {
    _onFullscreenRequested = callback;
  }

  void setOverlayControlsBuilder(Widget Function(BuildContext)? builder) {
    _overlayControlsBuilder = builder;
  }

  void requestFullscreen() {
    if (_isOnVideoPage) {
      if (_onFullscreenRequested != null) {
        _hideControls();
        try {
          _onFullscreenRequested!.call();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('PipManager _onFullscreenRequested: $e');
          }
        }
        _isPiPMode = false;
        _notifyPiPModeChanged(false);
      } else {
        hidePiP();
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => dispose());
    }
  }

  void showPiP() {
    if (!_isPiPMode) {
      _isPiPMode = true;
      _isLiftedToOverlay = false;
      _notifyPiPModeChanged(true);
    }
  }

  void liftToOverlay(BuildContext context) {
    if (_isLiftedToOverlay) return;
    _context = context;
    _isLiftedToOverlay = true;
    _removeOverlay();
    _createOverlay();
    if (_overlayEntry != null) {
      Future.delayed(_showControlsDelay, () {
        if (_overlayEntry != null) _showControlsWithAutoHide();
      });
    }
  }

  void returnToContainer() {
    if (!_isLiftedToOverlay) return;
    _removeOverlay();
    _isLiftedToOverlay = false;
    _pipPosition = Offset.zero;
    _updateOverlay();
  }

  void hidePiP() {
    _removeOverlay();
    _isLiftedToOverlay = false;
    if (!_isPiPMode) return;
    _isPiPMode = false;
    _notifyPiPModeChanged(false);
  }

  void _notifyPiPModeChanged(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _onPiPModeChanged?.call(value);
      } catch (e) {
        if (kDebugMode) debugPrint('PipManager onPiPModeChanged error: $e');
      }
    });
  }

  void closePiP({bool userInitiated = false}) {
    if (userInitiated) _userClosed = true;
    hidePiP();
    try {
      _onClose?.call();
    } catch (e) {
      if (kDebugMode) debugPrint('PipManager onClose error: $e');
    }
    if (userInitiated) {
      releaseWebView();
      _pipPosition = Offset.zero;
      _isMinimized = false;
      _isDragging = false;
      _showControls = false;
    } else if (!_isOnVideoPage) {
      dispose();
    } else {
      _pipPosition = Offset.zero;
      _isMinimized = false;
      _isDragging = false;
      _showControls = false;
    }
  }

  Future<void> dispose() async {
    _removeOverlay();
    _controlsTimer?.cancel();
    _controlsTimer = null;
    _webViewController = null;
    _currentUrl = null;
    _currentEventId = null;
    _context = null;
    _onClose = null;
    _onPiPModeChanged = null;
    _onFullscreenRequested = null;
    _overlayControlsBuilder = null;
    if (_isPiPMode) _isPiPMode = false;
    _isLiftedToOverlay = false;
    _pipPosition = Offset.zero;
    _isMinimized = false;
    _isDragging = false;
    _showControls = false;
    _isOnVideoPage = true;
  }

  void _createOverlay() {
    if (_context == null || _overlayEntry != null) return;
    final ctx = _context!;
    OverlayState? overlayState;
    try {
      final navigator = Navigator.of(ctx, rootNavigator: true);
      overlayState = navigator.overlay;
    } catch (_) {}
    if (overlayState == null) {
      try {
        overlayState = Overlay.of(ctx);
      } catch (_) {}
    }
    if (overlayState == null) {
      if (kDebugMode) debugPrint('PipManager: could not get OverlayState');
      return;
    }
    final entry = OverlayEntry(builder: (context) => _buildPiPOverlay(context));
    _overlayEntry = entry;
    _overlayEntryInserted = false;

    final state = overlayState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        state.insert(entry);
        _overlayEntry = entry;
        _overlayEntryInserted = true;
        _isLiftedToOverlay = true;
        _isPiPMode = true;
        if (kDebugMode) debugPrint('PipManager: overlay inserted');
      } catch (e) {
        if (kDebugMode) debugPrint('PipManager: overlay.insert error: $e');
        _overlayEntry = null;
      }
    });
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _overlayEntryInserted) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        if (kDebugMode) debugPrint('PipManager: overlay remove error: $e');
      }
      _overlayEntryInserted = false;
    }
    _overlayEntry = null;
  }

  void _updateOverlay() {
    if (_isLiftedToOverlay) {
      final entry = _overlayEntry;
      if (entry == null || !_overlayEntryInserted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlayEntry == entry && _overlayEntryInserted) {
          entry.markNeedsBuild();
        }
      });
    } else {
      _notifyPiPModeChanged(_isPiPMode);
    }
  }

  void _showControlsWithAutoHide() {
    _showControls = true;
    _controlsTimer?.cancel();
    _controlsTimer = Timer(_controlsAutoHideDuration, _hideControls);
    _updateOverlay();
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    _showControls = false;
    _updateOverlay();
  }

  void _toggleMinimizeMaximize(
    Size screenSize,
    EdgeInsets safeArea,
    double screenHeight,
  ) {
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;

    _isMinimized = !_isMinimized;

    final newWidth = _isMinimized
        ? availableWidth * _pipMinimizedWidthFactor
        : availableWidth * _pipMaximizedWidthFactor;
    final newHeight = newWidth * _pipAspectRatio;

    final actualMaxHeight = screenHeight - newHeight - safeArea.bottom;
    final newPosition = Offset(
      _pipPosition.dx.clamp(
        safeArea.left,
        screenSize.width - newWidth - safeArea.right,
      ),
      _pipPosition.dy.clamp(0, actualMaxHeight),
    );

    if (newPosition != _pipPosition) {
      _pipPosition = newPosition;
    }

    _showControlsWithAutoHide();
  }

  BoxDecoration _buildPiPDecoration() {
    if (_isDragging) {
      return BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_pipBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      );
    }
    return const BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.all(Radius.circular(_pipBorderRadius)),
      boxShadow: [
        BoxShadow(color: Color(0x4D000000), blurRadius: 10, spreadRadius: 2),
      ],
    );
  }

  Widget buildPiPContent(
    BuildContext context, {
    required double width,
    required double height,
    required bool isInOverlay,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final safeArea = mediaQuery.padding;
    final maxHeight = screenSize.height - height - safeArea.bottom;
    final isWebViewMode = _webViewController != null;

    return Material(
      type: MaterialType.transparency,
      elevation: 8,
      child: RepaintBoundary(
        child: GestureDetector(
          onScaleStart: (_) {
            if (!isInOverlay) return;
            _isDragging = true;
            _hideControls();
            _updateOverlay();
          },
          onScaleUpdate: (details) {
            if (!isInOverlay || details.pointerCount != 1) return;
            final newPosition = Offset(
              (_pipPosition.dx + details.focalPointDelta.dx).clamp(
                safeArea.left,
                screenSize.width - width - safeArea.right,
              ),
              (_pipPosition.dy + details.focalPointDelta.dy).clamp(
                0,
                maxHeight,
              ),
            );
            _pipPosition = newPosition;
            _updateOverlay();
          },
          onScaleEnd: (_) {
            _isDragging = false;
            _showControlsWithAutoHide();
          },
          onTap: SoundTap.wrap(() => _showControlsWithAutoHide()),
          onDoubleTap: () {
            if (hasContent && isInOverlay) {
              _toggleMinimizeMaximize(screenSize, safeArea, screenSize.height);
            }
          },
          child: AnimatedContainer(
            duration: _isDragging || !isInOverlay
                ? Duration.zero
                : _containerAnimationDuration,
            curve: Curves.easeOut,
            width: width,
            decoration: _buildPiPDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_pipBorderRadius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWebViewMode && _overlayControlsBuilder != null)
                    _overlayControlsBuilder!(context),
                  SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        if (isWebViewMode && _webViewController != null)
                          Positioned.fill(
                            child: WebViewWidget(
                              controller: _webViewController!,
                            ),
                          )
                        else
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (_isDragging)
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmbeddedPiP(
    BuildContext context, {
    required double containerWidth,
  }) {
    final fallbackWidth = MediaQuery.sizeOf(context).width;
    final h = fallbackWidth * _pipAspectRatio;
    return buildPiPContent(
      context,
      width: fallbackWidth,
      height: h,
      isInOverlay: false,
    );
  }

  Widget _buildPiPOverlay(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final safeArea = mediaQuery.padding;
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;
    final pipWidth = _isMinimized
        ? availableWidth * _pipMinimizedWidthFactor
        : availableWidth * _pipMaximizedWidthFactor;
    final pipHeight = pipWidth * _pipAspectRatio;
    final maxHeight = screenSize.height - pipHeight - safeArea.bottom;

    if (_pipPosition == Offset.zero) {
      _pipPosition = Offset(
        screenSize.width - pipWidth - 16 - safeArea.right,
        maxHeight - 16,
      );
    }
    final clampedPosition = Offset(
      _pipPosition.dx.clamp(
        safeArea.left,
        screenSize.width - pipWidth - safeArea.right,
      ),
      _pipPosition.dy.clamp(0, maxHeight),
    );

    return Positioned(
      left: clampedPosition.dx,
      top: clampedPosition.dy,
      child: buildPiPContent(
        context,
        width: pipWidth,
        height: pipHeight,
        isInOverlay: true,
      ),
    );
  }
}

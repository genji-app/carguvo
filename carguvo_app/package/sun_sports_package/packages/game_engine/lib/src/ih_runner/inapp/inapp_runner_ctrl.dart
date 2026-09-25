import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../logger.dart';
import '../game_bridge_mixin.dart';
import '../ih_runner_ctrl.dart';
import '../scripts/ih_runner_scripts.dart';

class IHInAppRunnerCtrl extends IHRunnerCtrl with GameBridgeMixin {
  IHInAppRunnerCtrl({
    GameEngineLogger logger = silentLogger,
    this.loadStopDebounce = Duration.zero,
    this.enableHostMessage = true,
    bool? blockFullscreen,
    bool? enableKeyboardScrollFix,
    bool? enableWebCompatibilityFixes,
  })  : _logger = logger,
        blockFullscreen = blockFullscreen ?? !kIsWeb,
        enableKeyboardScrollFix = enableKeyboardScrollFix ?? !kIsWeb,
        enableWebCompatibilityFixes = enableWebCompatibilityFixes ?? kIsWeb;

  static const MethodChannel _surfaceCompositorChannel =
      MethodChannel('com.caxilo.engine.surface_compositor');

  final Duration loadStopDebounce;

  final bool enableHostMessage;

  final bool blockFullscreen;

  final bool enableKeyboardScrollFix;

  final bool enableWebCompatibilityFixes;

  @override
  GameEngineLogger get logger => _logger;
  final GameEngineLogger _logger;

  IHRunnerState _state = IHRunnerState.idle;
  String? _currentUrl;
  String? _lastErrorMessage;
  bool _isDisposed = false;
  Timer? _debounceTimer;

  InAppWebViewController? webViewController;

  final _stateController = StreamController<IHRunnerState>.broadcast();

  @override
  IHRenderStrategy get strategy => IHRenderStrategy.inAppWebView;

  @override
  IHRunnerState get state => _state;

  @override
  String? get currentUrl => _currentUrl;

  @override
  Stream<IHRunnerState> get onStateChanged => _stateController.stream;

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  InAppWebViewSettings get initialSettings {
    if (kIsWeb) {
      return InAppWebViewSettings(
        useShouldOverrideUrlLoading: false,
        javaScriptEnabled: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        isInspectable: kDebugMode,
        transparentBackground: false,

        iframeAllow:
            'autoplay *; fullscreen *; accelerometer *; gyroscope *; camera *; microphone *; geolocation *; clipboard-read *; clipboard-write *; payment *; midi *',

      );
    } else {
      return InAppWebViewSettings(
        useHybridComposition: true,
        needInitialFocus: true,
        allowContentAccess: true,
        useShouldOverrideUrlLoading: false,
        javaScriptEnabled: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        allowsBackForwardNavigationGestures: false,
        isInspectable: kDebugMode,
        transparentBackground: false,
        sharedCookiesEnabled: true,
        thirdPartyCookiesEnabled: true,

        textZoom: 100,
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,

        useWideViewPort: true,
        loadWithOverviewMode: true,
        layoutAlgorithm: LayoutAlgorithm.NORMAL,

        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,

        hardwareAcceleration: true,
        cacheMode: CacheMode.LOAD_DEFAULT,
        cacheEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,

        safeBrowsingEnabled: false,
        allowFileAccess: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        javaScriptCanOpenWindowsAutomatically: true,

        disallowOverScroll: true,
        alwaysBounceVertical: false,
        alwaysBounceHorizontal: false,
        contentInsetAdjustmentBehavior: ScrollViewContentInsetAdjustmentBehavior.NEVER,
      );
    }
  }

  List<UserScript> get initialUserScripts {
    if (!enableKeyboardScrollFix) return [];

    return [
      UserScript(
        source: IHRunnerScripts.scrollLocker,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
      ),
    ];
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    setupHostBridge();

    if (enableWebCompatibilityFixes) {
      applyEarlyWebFixes();
    }
  }

  Future<void> loadUrl(String url) async {
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  @override
  Future<void> reload() async {
    await webViewController?.reload();
  }

  @override
  void forceGameResize() {
    evaluateJavascript('''
      if (window.cc && cc.view) {
          cc.view._orientationChanging = false;
      }
      window.dispatchEvent(new Event('resize'));
    ''');
  }

  @override
  void updateState(IHRunnerState newState, {String? url, String? message}) {
    if (_state == newState && _currentUrl == url) return;

    if (newState == IHRunnerState.idle || newState == IHRunnerState.loading) {
      _lastErrorMessage = null;
    } else if (newState == IHRunnerState.error) {
      _lastErrorMessage = message;
    }

    if (newState == IHRunnerState.loaded) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(loadStopDebounce, () async {
        if (_isDisposed || _stateController.isClosed) return;
        _state = newState;
        _currentUrl = url;
        _stateController.add(newState);

        if (kIsWeb) {
          await applyPostLoadWebFixes();
          if (_isDisposed) return;
        }

        _injectEnvironmentFixes();

        if (enableHostMessage) {
          await injectHostBridge(url: url);
        }
      });
      return;
    }

    _debounceTimer?.cancel();
    _state = newState;
    _currentUrl = url;
    _stateController.add(newState);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    disposeGameBridge();
    _stateController.close();
    webViewController = null;
  }

  @override
  @protected
  Future<dynamic> evaluateJavascript(String source) async {
    return await webViewController?.evaluateJavascript(source: source);
  }

  @override
  @protected
  void addJavaScriptHandler({
    required String handlerName,
    required void Function(List<dynamic> args) callback,
  }) {
    if (kIsWeb) {
      logger(
        'warning',
        'addJavaScriptHandler is not supported on Web. Use postMessage instead.',
      );
      return;
    }
    webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: callback,
    );
  }

  Future<void> applyEarlyWebFixes() async {
    await evaluateJavascript(IHRunnerScripts.earlyWebFix);
  }

  Future<void> applyPostLoadWebFixes() async {
    if (enableWebCompatibilityFixes) {
      forceGameResize();
    }
  }

  void _injectEnvironmentFixes() {
    try {
      if (enableKeyboardScrollFix && defaultTargetPlatform == TargetPlatform.iOS) {
        webViewController?.evaluateJavascript(source: IHRunnerScripts.scrollLocker);
      }

      if (blockFullscreen) {
        webViewController?.evaluateJavascript(source: IHRunnerScripts.fullscreenBlocker);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        webViewController?.evaluateJavascript(source: IHRunnerScripts.playsInlineEnforcer);
      }

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        syncRenderSurface();
      }
    } catch (e) {
      logger('error', '[IHRunner] Failed to inject environment fixes: $e');
    }
  }

  Future<void> syncRenderSurface() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _surfaceCompositorChannel.invokeMethod<bool>('syncRenderSurface');
    } catch (e) {
    }
  }

  @override
  void unregisterMessageListener() {}

  @override
  void cleanupIframe() {}

  @override
  Future<void> stopAllMedia({bool clearPage = false}) async {
    try {
      await evaluateJavascript(
        "document.querySelectorAll('video, audio').forEach(el => { el.pause(); el.src = ''; el.load(); });",
      );

      if (clearPage) {
      }
    } catch (e) {
      logger('warning', 'stopAllMedia failed: $e');
    }
  }
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../logger.dart';
import '../pl_runner_ctrl.dart';
import 'inapp_runner_scripts.dart';

class PLInAppRunnerCtrl extends PLRunnerCtrl {
  PLInAppRunnerCtrl({
    GameEngineLogger logger = silentLogger,
    this.blockFullscreen = true,
    this.forceLandscapeViewport = false,
    this.loadStopDebounce = Duration.zero,
  }) : _logger = logger {
    _checkPlatformCompatibility();
    _initUserScripts();
  }

  final bool blockFullscreen;

  final bool forceLandscapeViewport;

  final Duration loadStopDebounce;

  @override
  GameEngineLogger get logger => _logger;
  final GameEngineLogger _logger;

  PLRunnerState _state = PLRunnerState.idle;
  String? _currentUrl;

  InAppWebViewController? webViewController;

  final List<UserScript> _userScripts = [];

  final _stateController = StreamController<PLRunnerState>.broadcast();
  final _loadStartController = StreamController<void>.broadcast();
  final _loadStopController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  PLRunnerState get state => _state;

  @override
  String? get currentUrl => _currentUrl;

  @override
  Stream<PLRunnerState> get onStateChanged => _stateController.stream;

  @override
  Stream<void> get onLoadStart => _loadStartController.stream;

  @override
  Stream<void> get onLoadStop => _loadStopController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  UnmodifiableListView<UserScript> get initialUserScripts =>
      UnmodifiableListView<UserScript>(_userScripts);

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    _applyAllInjections('onWebViewCreated');
  }

  @override
  void updateState(PLRunnerState newState, {String? url, String? message}) {
    if (_state == newState && _currentUrl == url) return;
    _state = newState;
    _currentUrl = url;
    _stateController.add(newState);

    switch (newState) {
      case PLRunnerState.loading:
        if (!_loadStartController.isClosed) _loadStartController.add(null);
        _applyAllInjections('onLoadStart');
      case PLRunnerState.loaded:
        _applyAllInjections('onLoadStop:immediate');
        Timer(loadStopDebounce, () {
          if (_loadStopController.isClosed) return;
          _applyAllInjections('onLoadStop:debounced');
          _loadStopController.add(null);
        });
      case PLRunnerState.failure:
        if (!_errorController.isClosed) {
          _errorController.add(message ?? 'Failed to load game');
        }
      case PLRunnerState.idle:
        break;
    }
  }

  @override
  Future<void> reload() async {
    await webViewController?.reload();
  }

  @override
  Future<dynamic> evaluateJavascript(String source) async {
    return webViewController?.evaluateJavascript(source: source);
  }

  Future<void> loadUrl(String url) async {
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  void onEnterFullscreen(InAppWebViewController controller) {
    logger('warning', '[PLRunner] Native fullscreen entered — blocking and restoring inline mode.');
    controller.evaluateJavascript(source: _exitFullscreenScript).catchError((Object e) {
      logger('error', '[PLRunner] Failed to exit native fullscreen: \$e');
    });
    _applyAllInjections('onEnterFullscreen:restore');
  }

  void onExitFullscreen(InAppWebViewController controller) {
    logger('info', '[PLRunner] Native fullscreen exited — re-applying injections.');
    _applyAllInjections('onExitFullscreen:restore');
  }

  void onConsoleMessage(ConsoleMessage message) {
    final text = message.message;
    if (!text.contains('[PLRunner')) return;
    switch (message.messageLevel) {
      case ConsoleMessageLevel.ERROR:
        logger('error', '[WebView] $text');
      case ConsoleMessageLevel.WARNING:
        logger('warning', '[WebView] $text');
      default:
        logger('info', '[WebView] $text');
    }
  }

  @override
  void dispose() {
    _stateController.close();
    _loadStartController.close();
    _loadStopController.close();
    _errorController.close();
    webViewController = null;
  }

  void _initUserScripts() {
    if (kIsWeb) return;

    if (forceLandscapeViewport) {
      _userScripts.addAll([
        UserScript(
          source: PLInAppRunnerScripts.orientationPolyfill,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLInAppRunnerScripts.landscapeViewport,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLInAppRunnerScripts.orientationPolyfill,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLInAppRunnerScripts.landscapeViewport,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
      ]);
    }

    if (blockFullscreen) {
      _userScripts.addAll([
        UserScript(
          source: PLInAppRunnerScripts.fullscreenBlocker,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLInAppRunnerScripts.fullscreenBlocker,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
      ]);
    }

    _userScripts.addAll([
      UserScript(
        source: PLInAppRunnerScripts.playsInlineEnforcer,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        forMainFrameOnly: false,
      ),
      UserScript(
        source: PLInAppRunnerScripts.playsInlineEnforcer,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        forMainFrameOnly: false,
      ),
    ]);
  }

  static const String _exitFullscreenScript = '''
    (function() {
      try {
        if (document.fullscreenElement || document.webkitFullscreenElement) {
          (document.exitFullscreen || document.webkitExitFullscreen || function(){}).call(document);
        }
      } catch (e) { /* ignore — element may have already exited */ }
    })();
  ''';

  void _applyAllInjections(String trigger) {
    logger(
      'info',
      '[PLRunner] _applyAllInjections — trigger=$trigger forceLandscape=$forceLandscapeViewport',
    );

    _injectOrientationPolyfill();
    _injectLandscapeViewport();
    _injectFullscreenBlocker();
    _injectPlaysInlineEnforcer();

    if (kDebugMode) {
      _injectDiagnostics(trigger);
    }
  }

  void _injectOrientationPolyfill() {
    if (!forceLandscapeViewport) return;
    webViewController
        ?.evaluateJavascript(source: PLInAppRunnerScripts.orientationPolyfill)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject orientation polyfill: $e');
    });
  }

  void _injectLandscapeViewport() {
    if (!forceLandscapeViewport) return;
    webViewController
        ?.evaluateJavascript(source: PLInAppRunnerScripts.landscapeViewport)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject landscape viewport meta: $e');
    });
  }

  void _injectFullscreenBlocker() {
    if (!blockFullscreen) return;
    webViewController
        ?.evaluateJavascript(source: PLInAppRunnerScripts.fullscreenBlocker)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject fullscreen blocker: $e');
    });
  }

  void _injectPlaysInlineEnforcer() {
    webViewController
        ?.evaluateJavascript(source: PLInAppRunnerScripts.playsInlineEnforcer)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject playsinline enforcer: $e');
    });
  }

  void _injectDiagnostics(String trigger) {
    final taggedScript = PLInAppRunnerScripts.diagnostics.replaceFirst(
      '[PLRunner:DIAG]',
      '[PLRunner:DIAG:$trigger]',
    );
    webViewController?.evaluateJavascript(source: taggedScript).catchError(
      (Object e) {
        logger('error', '[PLRunner] Failed to inject diagnostics: $e');
      },
    );
  }

  void _checkPlatformCompatibility() {
    if (!kIsWeb) return;
    if (blockFullscreen) {
      logger(
        'warning',
        '[PLRunner] blockFullscreen might not work reliably on Web due to Browser security policies.',
      );
    }
    if (forceLandscapeViewport) {
      logger(
        'warning',
        '[PLRunner] forceLandscapeViewport on Web might cause unexpected layout on Desktop browsers.',
      );
    }
  }
}

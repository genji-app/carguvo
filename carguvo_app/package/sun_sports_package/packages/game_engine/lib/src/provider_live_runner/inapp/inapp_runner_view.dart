import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../pl_runner_base.dart';
import '../pl_runner_ctrl.dart';
import 'inapp_runner_ctrl.dart';

class PLInAppRunnerView extends PLRunnerBase {
  const PLInAppRunnerView({
    required super.gameUrl,
    super.logger,
    super.controller,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.forceLandscapeViewport,
    super.scaleContent,
    super.enableDimensionLock,
    super.blockFullscreen,
    super.loadStopDebounce,
    super.viewId = 'pl-runner',
    super.useInAppWebViewOnWeb,
    super.backgroundColor,
  });

  @override
  State<PLInAppRunnerView> createState() => _PLInAppRunnerState();
}

class _PLInAppRunnerState extends State<PLInAppRunnerView> {
  PLInAppRunnerCtrl? _ownedController;

  late final PLInAppRunnerCtrl _ctrl;

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _checkPlatformWarnings();
    _initController();
    _setupSubscriptions();
  }

  void _checkPlatformWarnings() {
    if (widget.enableDimensionLock) {
      widget.logger(
        'warning',
        '[PLRunner] enableDimensionLock is a Web-only feature; ignored on Mobile.',
      );
    }
  }

  void _initController() {
    final external = widget.controller;
    if (external != null) {
      if (external is! PLInAppRunnerCtrl) {
        throw ArgumentError(
          'PLInAppRunnerView requires a PLInAppRunnerCtrl. '
          'Received: ${external.runtimeType}',
        );
      }
      _ctrl = external;
    } else {
      _ownedController = PLInAppRunnerCtrl(
        logger: widget.logger,
        blockFullscreen: widget.blockFullscreen,
        forceLandscapeViewport: widget.forceLandscapeViewport,
        loadStopDebounce: widget.loadStopDebounce ?? Duration.zero,
      );
      _ctrl = _ownedController!;
    }
  }

  void _setupSubscriptions() {
    _subs.addAll([
      _ctrl.onLoadStart.listen((_) {
        if (mounted) widget.onLoadStart?.call();
      }),
      _ctrl.onLoadStop.listen((_) {
        if (mounted) widget.onLoadStop?.call();
      }),
      _ctrl.onError.listen((error) {
        if (mounted) widget.onError?.call(error);
      }),
    ]);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.black,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.gameUrl)),
        initialSettings: InAppWebViewSettings(
          useHybridComposition: true,
          needInitialFocus: true,
          allowContentAccess: true,
          useShouldOverrideUrlLoading: false,
          javaScriptEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
          transparentBackground: false,
          sharedCookiesEnabled: true,
          thirdPartyCookiesEnabled: true,
          verticalScrollBarEnabled: false,
          horizontalScrollBarEnabled: false,
          allowsBackForwardNavigationGestures: false,
          isInspectable: kDebugMode,

          textZoom: 100,
          layoutAlgorithm: LayoutAlgorithm.NORMAL,
          supportZoom: false,
          builtInZoomControls: false,
          displayZoomControls: false,

          useWideViewPort: true,
          loadWithOverviewMode: true,

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
        ),
        initialUserScripts: _ctrl.initialUserScripts,
        onWebViewCreated: _ctrl.onWebViewCreated,
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onLoadStart: (controller, url) {
          _ctrl.updateState(PLRunnerState.loading, url: url?.toString());
        },
        onLoadStop: (controller, url) {
          _ctrl.updateState(PLRunnerState.loaded, url: url?.toString());
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame ?? false) {
            _ctrl.updateState(
              PLRunnerState.failure,
              message: '[${error.type}] ${error.description} for ${request.url}',
            );
          }
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          if (request.isForMainFrame ?? false) {
            final statusCode = errorResponse.statusCode ?? 0;
            if (statusCode >= 400) {
              _ctrl.updateState(
                PLRunnerState.failure,
                message: 'HTTP $statusCode for ${request.url}',
              );
            }
          }
        },
        onEnterFullscreen: _ctrl.onEnterFullscreen,
        onExitFullscreen: _ctrl.onExitFullscreen,
        onConsoleMessage: (controller, message) {
          _ctrl.onConsoleMessage(message);
        },
      ),
    );
  }
}

typedef PLRunnerImpl = PLInAppRunnerView;

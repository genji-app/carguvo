import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../_plugins/web_plugins.dart';
import '../pl_runner_base.dart';
import '../pl_runner_ctrl.dart';
import 'pl_html_iframe_runner_ctrl.dart';

class PLHtmlIframeRunnerView extends PLRunnerBase {
  const PLHtmlIframeRunnerView({
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
  State<PLHtmlIframeRunnerView> createState() => _PLHtmlIframeRunnerViewState();
}

class _PLHtmlIframeRunnerViewState extends State<PLHtmlIframeRunnerView>
    with IFrameDimensionLockMixin, IFrameCrashDetectionMixin {
  late final PLHtmlIframeRunnerCtrl _controller;
  StreamSubscription? _onLoadStateSub;
  StreamSubscription? _onErrorSub;

  @override
  void onTopLevelJsError(web.Event event) {
    widget.logger('error', '[PLRunner] TOP-LEVEL JS ERROR detected');
  }

  @override
  void onUnhandledPromiseRejection(web.Event event) {
    widget.logger('error', '[PLRunner] UNHANDLED PROMISE REJECTION detected');
  }

  @override
  void onPageHide(web.Event event) {
    widget.logger('warning', '[PLRunner] PAGE HIDE detected');
  }

  @override
  void onVisibilityChange(String visibilityState) {
    widget.logger('info', '[PLRunner] Visibility changed: $visibilityState');
  }

  @override
  void initState() {
    super.initState();
    _setupController();
    installCrashDetection();
  }

  void _setupController() {
    if (widget.controller != null) {
      if (widget.controller is PLHtmlIframeRunnerCtrl) {
        _controller = widget.controller! as PLHtmlIframeRunnerCtrl;
      } else {
        throw ArgumentError('PLRunner on Web requires PLHtmlIframeRunnerCtrl');
      }
    } else {
      _controller = PLHtmlIframeRunnerCtrl(logger: widget.logger);
    }

    _onLoadStateSub = _controller.onStateChanged.listen((state) {
      if (state == PLRunnerState.loading) {
        if (mounted) widget.onLoadStart?.call();
      } else if (state == PLRunnerState.loaded) {
        if (mounted) widget.onLoadStop?.call();
      } else if (state == PLRunnerState.failure) {
        if (mounted) widget.onError?.call('WebView Error');
      }
    });

    _onErrorSub = _controller.onError.listen((error) {
      if (mounted) widget.onError?.call(error);
    });
  }

  @override
  void dispose() {
    removeDimensionLockTimers();
    removeCrashDetection();

    _onLoadStateSub?.cancel();
    _onErrorSub?.cancel();

    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as web.HTMLIFrameElement;

        iframe.setAttribute(
          'sandbox',
          'allow-modals '
              'allow-scripts '
              'allow-same-origin '
              'allow-popups '
              'allow-popups-to-escape-sandbox '
              'allow-forms '
              'allow-top-navigation-by-user-activation '
              'allow-downloads',
        );

        iframe.allow = 'autoplay; fullscreen; accelerometer; gyroscope; '
            'camera; microphone; geolocation; '
            'clipboard-read; clipboard-write; payment; midi';

        iframe.style.border = 'none';
        iframe.style.display = 'block';
        if (widget.backgroundColor != null) {
          iframe.style.background = widget.backgroundColor!.toCssRgba();
        } else {
          iframe.style.background = '#f5f4eb';
        }
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.overflow = 'hidden';
        iframe.style.setProperty('touch-action', 'none');
        iframe.style.setProperty('overscroll-behavior', 'none');
        iframe.style.setProperty('user-select', 'none');
        iframe.style.setProperty('-webkit-user-select', 'none');
        iframe.setAttribute('scrolling', 'no');

        _controller.attach(iframe);
        _controller.handleLoadStart();

        iframe.onLoad.listen((_) {
          _controller.handleLoadStop();
        });

        iframe.onError.listen((_) {
          _controller.handleLoadError('Failed to load iframe');
        });

        iframe.src = widget.gameUrl;
      },
    );
  }
}

import 'package:flutter/widgets.dart';

import '../html_iframe/pl_html_iframe_runner_view.dart' show PLHtmlIframeRunnerView;
import '../inapp/inapp_runner_view.dart' show PLInAppRunnerView;
import '../pl_runner_base.dart';

class PLRunnerWebImpl extends PLRunnerBase {
  const PLRunnerWebImpl({
    required super.gameUrl,
    super.logger,
    super.controller,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.viewId,
    super.forceLandscapeViewport,
    super.scaleContent,
    super.enableDimensionLock,
    super.blockFullscreen,
    super.useInAppWebViewOnWeb,
    super.loadStopDebounce,
    super.backgroundColor,
  });

  @override
  State<PLRunnerWebImpl> createState() => _PLRunnerWebImplState();
}

class _PLRunnerWebImplState extends State<PLRunnerWebImpl> {
  @override
  Widget build(BuildContext context) {
    final useInAppWebView = widget.useInAppWebViewOnWeb ?? false;
    if (useInAppWebView) {
      return PLInAppRunnerView(
        gameUrl: widget.gameUrl,
        logger: widget.logger,
        controller: widget.controller,
        onLoadStart: widget.onLoadStart,
        onLoadStop: widget.onLoadStop,
        onError: widget.onError,
        viewId: widget.viewId,
        forceLandscapeViewport: widget.forceLandscapeViewport,
        scaleContent: widget.scaleContent,
        enableDimensionLock: widget.enableDimensionLock,
        blockFullscreen: widget.blockFullscreen,
        loadStopDebounce: widget.loadStopDebounce,
        backgroundColor: widget.backgroundColor,
      );
    }
    return PLHtmlIframeRunnerView(
      gameUrl: widget.gameUrl,
      logger: widget.logger,
      controller: widget.controller,
      onLoadStart: widget.onLoadStart,
      onLoadStop: widget.onLoadStop,
      onError: widget.onError,
      viewId: widget.viewId,
      forceLandscapeViewport: widget.forceLandscapeViewport,
      scaleContent: widget.scaleContent,
      enableDimensionLock: widget.enableDimensionLock,
      blockFullscreen: widget.blockFullscreen,
      loadStopDebounce: widget.loadStopDebounce,
      backgroundColor: widget.backgroundColor,
    );
  }
}

typedef PLRunnerImpl = PLRunnerWebImpl;

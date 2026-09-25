import 'package:flutter/material.dart';

import '../logger.dart';
import 'pl_runner_ctrl.dart';
import 'pl_runner_stub.dart'
    if (dart.library.io) 'inapp/inapp_runner_view.dart'
    if (dart.library.js_interop) 'web/pl_runner_web.dart';

export 'pl_runner_ctrl.dart';

class PLRunner extends StatelessWidget {
  const PLRunner({
    required this.gameUrl,
    this.logger = silentLogger,
    this.controller,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.viewId = 'pl-runner',
    this.forceLandscapeViewport = false,
    this.enableDimensionLock = false,
    this.blockFullscreen = true,
    this.useInAppWebViewOnWeb,
    this.loadStopDebounce,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  final PLRunnerCtrl? controller;

  final String gameUrl;

  final GameEngineLogger logger;

  final String viewId;

  final VoidCallback? onLoadStart;

  final VoidCallback? onLoadStop;

  final ValueChanged<String>? onError;

  final bool forceLandscapeViewport;

  final bool enableDimensionLock;

  final bool blockFullscreen;

  final bool? useInAppWebViewOnWeb;

  final Duration? loadStopDebounce;

  @override
  Widget build(BuildContext context) {
    return PLRunnerImpl(
      gameUrl: gameUrl,
      logger: logger,
      controller: controller,
      onLoadStart: onLoadStart,
      onLoadStop: onLoadStop,
      onError: onError,
      viewId: viewId,
      forceLandscapeViewport: forceLandscapeViewport,
      enableDimensionLock: enableDimensionLock,
      blockFullscreen: blockFullscreen,
      useInAppWebViewOnWeb: useInAppWebViewOnWeb,
      loadStopDebounce: loadStopDebounce,
      backgroundColor: backgroundColor,
    );
  }
}

import 'package:flutter/widgets.dart';

import '../logger.dart';
import 'pl_runner_ctrl.dart';

abstract class PLRunnerBase extends StatefulWidget {
  const PLRunnerBase({
    required this.gameUrl,
    this.logger = silentLogger,
    this.controller,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.viewId = 'pl-runner',
    this.forceLandscapeViewport = false,
    this.scaleContent = true,
    this.enableDimensionLock = false,
    this.blockFullscreen = true,
    this.useInAppWebViewOnWeb,
    this.loadStopDebounce,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  final String gameUrl;

  final GameEngineLogger logger;

  final PLRunnerCtrl? controller;

  final Duration? loadStopDebounce;

  final String viewId;

  final bool scaleContent;

  final bool enableDimensionLock;

  final bool? useInAppWebViewOnWeb;

  final bool forceLandscapeViewport;

  final bool blockFullscreen;

  final VoidCallback? onLoadStart;

  final VoidCallback? onLoadStop;

  final ValueChanged<String>? onError;
}

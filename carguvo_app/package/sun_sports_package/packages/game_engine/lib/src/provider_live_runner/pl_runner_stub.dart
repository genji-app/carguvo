import 'package:flutter/material.dart';

import 'pl_runner_base.dart';

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
    super.enableDimensionLock,
    super.blockFullscreen,
    super.loadStopDebounce,
    super.viewId = 'pl-runner',
    super.useInAppWebViewOnWeb,
    super.backgroundColor,
  });

  @override
  State<PLInAppRunnerView> createState() => _PLInAppRunnerStubState();
}

class _PLInAppRunnerStubState extends State<PLInAppRunnerView> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Unsupported Platform'));
  }
}

typedef PLRunnerImpl = PLInAppRunnerView;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import '../logger.dart';
import 'html_iframe/ih_html_iframe_runner_ctrl.dart';
import 'html_iframe/ih_html_iframe_runner_stub.dart'
    if (dart.library.js_interop) 'html_iframe/ih_html_iframe_runner.dart';
import 'ih_runner_ctrl.dart';
import 'inapp/inapp_runner.dart';
import 'inapp/inapp_runner_ctrl.dart';

export 'game_bridge_mixin.dart';
export 'ih_runner_ctrl.dart';

class IHRunner extends StatelessWidget {
  const IHRunner({
    required this.gameUrl,
    this.controller,
    this.logger = silentLogger,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.onHostMessage,
    this.enableHostMessage = true,
    this.loadStopDebounce,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  final String gameUrl;

  final IHRunnerCtrl? controller;

  final GameEngineLogger logger;

  final VoidCallback? onLoadStart;

  final VoidCallback? onLoadStop;

  final ValueChanged<String>? onError;

  final ValueChanged<GameHostEvent>? onHostMessage;

  final bool enableHostMessage;

  final Duration? loadStopDebounce;

  IHRenderStrategy get _resolvedStrategy {
    if (controller != null) return controller!.strategy;
    if (kIsWeb) return IHRenderStrategy.htmlIframe;
    return IHRenderStrategy.inAppWebView;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      controller == null ||
          (controller!.strategy == IHRenderStrategy.inAppWebView
              ? controller is IHInAppRunnerCtrl
              : controller is IHHtmlIframeRunnerCtrl),
      'IHRunner: external controller reports strategy '
      '"${controller?.strategy}" but its runtime type '
      '"${controller?.runtimeType}" does not match the expected view type. '
      'This will cause a TypeError when the runner builds.',
    );

    return switch (_resolvedStrategy) {
      IHRenderStrategy.inAppWebView => IHInAppRunner(
          gameUrl: gameUrl,
          controller: controller as IHInAppRunnerCtrl?,
          logger: logger,
          onLoadStart: onLoadStart,
          onLoadStop: onLoadStop,
          onError: onError,
          onHostMessage: onHostMessage,
          enableHostMessage: enableHostMessage,
          loadStopDebounce: loadStopDebounce,
          backgroundColor: backgroundColor,
        ),
      IHRenderStrategy.htmlIframe => IHHtmlIframeRunner(
          gameUrl: gameUrl,
          controller: controller as IHHtmlIframeRunnerCtrl?,
          logger: logger,
          onLoadStart: onLoadStart,
          onLoadStop: onLoadStop,
          onError: onError,
          onHostMessage: onHostMessage,
          enableHostMessage: enableHostMessage,
          backgroundColor: backgroundColor,
        ),
    };
  }
}

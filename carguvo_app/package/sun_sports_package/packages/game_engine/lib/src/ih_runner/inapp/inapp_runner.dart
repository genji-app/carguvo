import 'package:flutter/widgets.dart';

import '../ih_runner_base.dart';
import 'inapp_runner_ctrl.dart';
import 'inapp_runner_view.dart';

class IHInAppRunner extends IHRunnerBase {
  const IHInAppRunner({
    required super.gameUrl,
    this.controller,
    super.logger,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.onHostMessage,
    super.enableHostMessage,
    this.loadStopDebounce,
    super.backgroundColor,
  });

  final IHInAppRunnerCtrl? controller;

  final Duration? loadStopDebounce;

  @override
  State<IHInAppRunner> createState() => _IHInAppRunnerState();
}

class _IHInAppRunnerState extends State<IHInAppRunner> with IHRunnerForwardingMixin {
  @override
  void initState() {
    super.initState();
    initController(
      externalController: widget.controller,
      createDefault: () => IHInAppRunnerCtrl(
        logger: widget.logger,
        loadStopDebounce: widget.loadStopDebounce ?? Duration.zero,
        enableHostMessage: widget.enableHostMessage,
      ),
    );
    setupForwarding();
  }

  @override
  void dispose() {
    disposeForwarding();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IHInAppRunnerView(
      gameUrl: widget.gameUrl,
      controller: ctrl as IHInAppRunnerCtrl,
      logger: widget.logger,
      enableHostMessage: widget.enableHostMessage,
      backgroundColor: widget.backgroundColor,
    );
  }
}

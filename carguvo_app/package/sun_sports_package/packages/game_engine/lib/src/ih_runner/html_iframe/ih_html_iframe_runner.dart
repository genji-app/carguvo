import 'package:flutter/widgets.dart';

import '../ih_runner_base.dart';
import 'ih_html_iframe_runner_ctrl.dart';
import 'ih_html_iframe_runner_view.dart';

class IHHtmlIframeRunner extends IHRunnerBase {
  const IHHtmlIframeRunner({
    required super.gameUrl,
    this.controller,
    super.logger,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.onHostMessage,
    super.enableHostMessage,
    super.backgroundColor,
  });

  final IHHtmlIframeRunnerCtrl? controller;

  @override
  State<IHHtmlIframeRunner> createState() => _IHHtmlIframeRunnerState();
}

class _IHHtmlIframeRunnerState extends State<IHHtmlIframeRunner> with IHRunnerForwardingMixin {
  @override
  void initState() {
    super.initState();
    initController(
      externalController: widget.controller,
      createDefault: () => IHHtmlIframeRunnerCtrl(logger: widget.logger),
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
    return IHHtmlIframeRunnerView(
      gameUrl: widget.gameUrl,
      controller: ctrl as IHHtmlIframeRunnerCtrl,
      logger: widget.logger,
      enableHostMessage: widget.enableHostMessage,
      backgroundColor: widget.backgroundColor,
    );
  }
}

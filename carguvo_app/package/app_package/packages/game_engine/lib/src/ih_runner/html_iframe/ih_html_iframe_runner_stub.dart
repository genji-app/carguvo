import 'package:flutter/widgets.dart';

import '../ih_runner_base.dart';
import 'ih_html_iframe_runner_ctrl.dart';

class IHHtmlIframeRunner extends IHRunnerBase {
  // ignore: avoid_unused_constructor_parameters
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
  State<IHHtmlIframeRunner> createState() => _StubState();
}

class _StubState extends State<IHHtmlIframeRunner> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

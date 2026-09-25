import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../../_plugins/web_plugins.dart';
import '../../logger.dart';
import '../ih_runner_ctrl.dart';
import 'body_level_game_iframe.dart';
import 'ih_html_iframe_runner_ctrl.dart';

class IHHtmlIframeRunnerView extends StatefulWidget {
  const IHHtmlIframeRunnerView({
    required this.gameUrl,
    required this.controller,
    required this.logger,
    super.key,
    this.enableHostMessage = true,
    this.backgroundColor,
  });

  final String gameUrl;

  final IHHtmlIframeRunnerCtrl controller;

  final GameEngineLogger logger;

  final bool enableHostMessage;

  final Color? backgroundColor;

  @override
  State<IHHtmlIframeRunnerView> createState() => _IHHtmlIframeRunnerViewState();
}

class _IHHtmlIframeRunnerViewState extends State<IHHtmlIframeRunnerView>
    with WebMessageListenerMixin {
  BodyLevelGameIframe? _bodyLevel;

  late final bool _useBodyLevel = isPhoneWeb;

  @override
  void initState() {
    super.initState();
    if (widget.enableHostMessage) {
      registerWebMessageListener();
    }
    if (_useBodyLevel) {
      _bodyLevel = BodyLevelGameIframe.attach(configure: _configureIframe);
    }
  }

  @override
  void dispose() {
    _bodyLevel?.detach();
    _bodyLevel = null;
    unregisterWebMessageListener();
    super.dispose();
  }

  @override
  void onMessageReceive(dynamic data) {
    if (data == null) return;
    widget.controller.processHostMessage(data);
  }

  void _configureIframe(web.HTMLIFrameElement iframe) {
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
    iframe.style.overflow = 'hidden';
    iframe.style.setProperty('overscroll-behavior', 'none');
    iframe.style.setProperty('user-select', 'none');
    iframe.style.setProperty('-webkit-user-select', 'none');
    iframe.setAttribute('scrolling', 'no');
    if (widget.backgroundColor != null) {
      iframe.style.background = widget.backgroundColor!.toCssRgba();
    } else {
      iframe.style.background = '#f5f4eb';
    }

    widget.controller.updateState(IHRunnerState.loading);

    iframe.onLoad.listen((_) {
      widget.logger('info', '[IHHtmlIframe] Game loaded: ${widget.gameUrl}');
      widget.controller.updateState(IHRunnerState.loaded);
      _bodyLevel?.show();
    });

    iframe.onError.listen((_) {
      widget.logger('error', '[IHHtmlIframe] Failed to load: ${widget.gameUrl}');
      widget.controller.updateState(
        IHRunnerState.error,
        message: 'Failed to load game iframe',
      );
    });

    iframe.src = widget.gameUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (_useBodyLevel) {
      return const SizedBox.expand();
    }

    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as web.HTMLIFrameElement;
        _configureIframe(iframe);
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.setProperty('touch-action', 'none');
      },
    );
  }
}

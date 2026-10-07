import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../_plugins/plugins.dart';
import '../../logger.dart';
import '../ih_runner_ctrl.dart';
import 'inapp_runner_ctrl.dart';

class IHInAppRunnerView extends StatefulWidget {
  const IHInAppRunnerView({
    required this.gameUrl,
    required this.controller,
    required this.logger,
    super.key,
    this.enableHostMessage = true,
    this.backgroundColor,
  });

  final String gameUrl;

  final IHInAppRunnerCtrl controller;

  final GameEngineLogger logger;

  final bool enableHostMessage;

  final Color? backgroundColor;

  @override
  State<IHInAppRunnerView> createState() => _IHInAppRunnerViewState();
}

class _IHInAppRunnerViewState extends State<IHInAppRunnerView>
    with WebMessageListenerMixin, WidgetsBindingObserver, KeyboardObserverMixin {
  final GlobalKey _webViewKey = GlobalKey();

  @override
  void onKeyboardDismissed() {
    widget.controller.forceGameResize();
  }

  @override
  void onMessageReceive(dynamic data) {
    if (data == null) return;
    try {
      widget.controller.processHostMessage(data);
    } catch (e) {
      widget.logger('error', 'Web message parse error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.enableHostMessage) {
      registerWebMessageListener();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      unregisterWebMessageListener();
    }
    widget.controller.stopAllMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.black,
      child: InAppWebView(
        key: _webViewKey,
        initialUrlRequest: URLRequest(
          url: WebUri(widget.gameUrl),
        ),
        initialSettings: widget.controller.initialSettings,
        initialUserScripts: widget.controller.initialUserScripts.isEmpty
            ? null
            : UnmodifiableListView<UserScript>(
                widget.controller.initialUserScripts,
              ),
        onWebViewCreated: (controller) {
          widget.controller.onWebViewCreated(controller);
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onLoadStart: (controller, url) {
          widget.logger('info', 'Started: $url');
          widget.controller.updateState(
            IHRunnerState.loading,
            url: url?.toString(),
          );
        },
        onLoadStop: (controller, url) async {
          widget.logger('info', 'Finished: $url');
          widget.controller.updateState(
            IHRunnerState.loaded,
            url: url?.toString(),
          );
        },
        onConsoleMessage: (controller, consoleMessage) {
          widget.logger('info', 'Console: ${consoleMessage.message}');
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame ?? false) {
            widget.logger('error', 'ReceivedError: $error');
            widget.controller.updateState(
              IHRunnerState.error,
              url: request.url.toString(),
            );
          }
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          if (request.isForMainFrame ?? false) {
            final statusCode = errorResponse.statusCode ?? 0;
            if (statusCode >= 400) {
              widget.logger(
                'error',
                'HTTP $statusCode for ${request.url}',
              );
              widget.controller.updateState(
                IHRunnerState.error,
                url: request.url.toString(),
                message: 'HTTP $statusCode for ${request.url}',
              );
            }
          }
        },
      ),
    );
  }
}

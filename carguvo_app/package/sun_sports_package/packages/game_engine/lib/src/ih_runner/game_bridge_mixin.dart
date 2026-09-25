import 'dart:async';
import 'dart:convert';

import 'ih_runner_ctrl.dart';
import 'scripts/ih_runner_scripts.dart';

export 'game_host_event.dart';

mixin GameBridgeMixin on IHRunnerCtrl {

  final _hostMessageController = StreamController<GameHostEvent>.broadcast();

  @override
  Stream<GameHostEvent> get onHostMessage => _hostMessageController.stream;

  @override
  void processHostMessage(dynamic message, {String defaultSource = 'game'}) {
    if (message == null) return;
    logger('info', '[IHRunner] Bridge received: $message');

    try {
      dynamic input = message;

      if (message is String && message.trim().startsWith('{')) {
        try {
          input = jsonDecode(message);
        } catch (e) {
          logger('error', '[IHRunner] Failed to parse bridge JSON: $e');
        }
      }

      final event = GameHostEvent.fromJson(input);

      if (event.type.isNotEmpty) {
        _hostMessageController.add(
          GameHostEvent(
            type: event.type,
            source: event.source ?? defaultSource,
            data: event.data,
            raw: message.toString(),
          ),
        );
      }
    } catch (e, st) {
      logger(
        'error',
        '[IHRunner] Failed to process bridge message',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> sendMessage(GameHostEvent event) async {
    final payload = event.encode();
    final escaped = payload.replaceAll("'", r"\'");
    await evaluateJavascript(
      "if(window.onFlutterMessage) window.onFlutterMessage('$escaped');",
    );
  }

  @override
  Future<void> injectHostBridge({String? url}) async {
    try {
      await evaluateJavascript(IHRunnerScripts.bridgeShim);
      logger(
        'info',
        '[IHRunner] Bridge shim injected into: ${url ?? 'unknown'}',
      );
    } catch (e) {
      logger('error', '[IHRunner] Bridge shim injection failed: $e');
    }
  }

  void setupHostBridge() {
    addJavaScriptHandler(
      handlerName: 'flutterChannel',
      callback: (args) {
        if (args.isEmpty) return;
        processHostMessage(args.first, defaultSource: 'ih_runner-game');
      },
    );
  }

  void disposeGameBridge() {
    _hostMessageController.close();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logger.dart';
import 'game_host_event.dart';
import 'inapp/inapp_runner_ctrl.dart';

export 'game_host_event.dart';

enum IHRenderStrategy {
  inAppWebView,

  htmlIframe,
}

enum IHRunnerState {
  idle,

  loading,

  loaded,

  error,
}

abstract class IHRunnerCtrl {
  @protected
  IHRunnerCtrl();

  factory IHRunnerCtrl.inApp({
    GameEngineLogger logger = silentLogger,
    bool? blockFullscreen,
  }) =>
      IHInAppRunnerCtrl(logger: logger, blockFullscreen: blockFullscreen);

  IHRenderStrategy get strategy;

  GameEngineLogger get logger;

  IHRunnerState get state;

  Stream<IHRunnerState> get onStateChanged;

  Stream<GameHostEvent> get onHostMessage;

  String? get currentUrl;

  String? get lastErrorMessage => null;

  bool get isLoading => state == IHRunnerState.loading;

  Future<void> reload();

  void forceGameResize() {}

  Future<void> stopAllMedia({bool clearPage = false});

  void updateState(IHRunnerState newState, {String? url, String? message});

  Future<void> sendMessage(GameHostEvent event);

  void processHostMessage(dynamic message, {String defaultSource = 'game'});

  Future<void> injectHostBridge({String? url});

  @protected
  Future<dynamic> evaluateJavascript(String source);

  @protected
  void addJavaScriptHandler({
    required String handlerName,
    required void Function(List<dynamic> args) callback,
  });

  void unregisterMessageListener() {}

  void cleanupIframe() {}

  @mustCallSuper
  void dispose();
}

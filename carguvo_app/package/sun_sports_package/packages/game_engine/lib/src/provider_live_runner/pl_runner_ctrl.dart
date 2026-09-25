import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logger.dart';

enum PLRunnerState {
  idle,

  loading,

  loaded,

  failure,
}

abstract class PLRunnerCtrl {
  @protected
  PLRunnerCtrl();

  GameEngineLogger get logger;

  PLRunnerState get state;

  Stream<PLRunnerState> get onStateChanged;

  String? get currentUrl;

  Stream<void> get onLoadStart;

  Stream<void> get onLoadStop;

  Stream<String> get onError;

  Future<void> reload();

  Future<dynamic> evaluateJavascript(String source);

  void updateState(PLRunnerState newState, {String? url, String? message});

  @mustCallSuper
  void dispose();
}

extension PLRunnerStateX on PLRunnerState {
  bool get isLoading => this == PLRunnerState.loading;

  bool get isLoaded => this == PLRunnerState.loaded;

  bool get isFailure => this == PLRunnerState.failure;
}

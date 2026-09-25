import 'dart:async';

import '../../logger.dart';
import '../game_bridge_mixin.dart';
import '../ih_runner_ctrl.dart';

class IHHtmlIframeRunnerCtrl extends IHRunnerCtrl with GameBridgeMixin {
  IHHtmlIframeRunnerCtrl({
    GameEngineLogger logger = silentLogger,
  }) : _logger = logger;

  final GameEngineLogger _logger;

  IHRunnerState _state = IHRunnerState.idle;
  String? _currentUrl;
  String? _lastErrorMessage;

  final _stateController = StreamController<IHRunnerState>.broadcast();

  @override
  GameEngineLogger get logger => _logger;

  @override
  IHRenderStrategy get strategy => IHRenderStrategy.htmlIframe;

  @override
  IHRunnerState get state => _state;

  @override
  String? get currentUrl => _currentUrl;

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  @override
  Stream<IHRunnerState> get onStateChanged => _stateController.stream;

  @override
  void updateState(IHRunnerState newState, {String? url, String? message}) {
    if (_state == newState && _currentUrl == url) return;
    if (newState == IHRunnerState.error) _lastErrorMessage = message;
    _state = newState;
    _currentUrl = url;
    if (!_stateController.isClosed) _stateController.add(newState);
  }

  @override
  Future<void> reload() async {}

  @override
  Future<dynamic> evaluateJavascript(String source) async => null;

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required void Function(List<dynamic> args) callback,
  }) {}

  @override
  Future<void> stopAllMedia({bool clearPage = false}) async {}

  @override
  void dispose() {
    _stateController.close();
    disposeGameBridge();
  }
}

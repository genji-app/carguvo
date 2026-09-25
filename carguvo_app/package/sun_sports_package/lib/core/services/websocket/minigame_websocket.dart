import 'dart:async';
import 'dart:convert';

import 'package:sun_sports/core/services/websocket/base_websocket.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class MinigameWsCommand {
  static const String confirmBet = 'CONFIRM_BET';
  static const String allIn = 'ALL_IN';
  static const String getRanking = 'GET_RANKING';
  static const String getHistory = 'GET_HISTORY';
  static const String getSessionAnalytic = 'GET_SESSION_ANALYTIC';

  static const String login = 'login';
  static const String launch = 'launch';
  static const String error = 'error';
  static const String ping = 'ping';
  static const String pong = 'pong';
}

class MinigamePortType {
  static const String mini = 'MiniGame';
}

class MinigameWsCmd {
  static const int login = 1;
  static const int subscribeInfo = 1005;
  static const int bet = 1000;
  static const int showResult = 1003;
  static const int calculateResultMoney = 1004;
  static const int startGame = 1002;
  static const int sessionAnalytic = 1007;
  static const int updateBetInfo = 1008;
  static const int getBetHistory = 1009;
  static const int chat = 1011;

  static const int betFree = 1010;
}

class MinigameSocketEvent {
  const MinigameSocketEvent({
    required this.messageType,
    required this.payload,
    this.cmd,
  });

  final String messageType;
  final int? cmd;
  final Map<String, dynamic> payload;
}

class MinigameWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  String? _username;
  String? _password;
  Map<String, dynamic>? _mainLoginData;
  bool _isAuthenticated = false;

  final StreamController<MinigameSocketEvent> _eventController =
      StreamController<MinigameSocketEvent>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _loginStatusController =
      StreamController<bool>.broadcast();

  @override
  String get name => 'MinigameWebSocket';

  bool get isAuthenticated => _isAuthenticated;
  Stream<MinigameSocketEvent> get eventStream => _eventController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get loginStatusStream => _loginStatusController.stream;

  Future<bool> connectWithAuth({
    required String url,
    required String username,
    required String password,
    required Map<String, dynamic> mainLoginData,
  }) {
    _username = username;
    _password = password;
    _mainLoginData = mainLoginData;
    _isAuthenticated = false;
    return connect(url);
  }

  void launchGame({
    required String gameCode,
    Map<String, dynamic> params = const {},
  }) {
    _sendCommand(MinigameWsCommand.launch, {
      'gameCode': gameCode,
      ...params,
    });
  }

  void sendGameAction(String action, Map<String, dynamic> payload) {
    _sendMessageType(action, payload);
  }

  @override
  void onConnected() {
    _logger.i('$name: connected, sending login');
    _sendLogin();
  }

  @override
  void onMessage(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is List) {
        _handleArrayMessage(decoded);
        return;
      }

      if (decoded is! Map<String, dynamic>) {
        _logger.w('$name: ignored non-object message: $message');
        return;
      }

      final command = decoded['command'] as String? ?? '';
      if (command == MinigameWsCommand.pong) return;

      if (command == MinigameWsCommand.login) {
        final ok = decoded['success'] == true || decoded['status'] == 'success';
        _isAuthenticated = ok;
        _loginStatusController.add(ok);
        if (!ok) {
          _errorController.add(decoded['message'] as String? ?? 'Login failed');
        }
        return;
      }

      if (command == MinigameWsCommand.error) {
        _errorController.add(decoded['message'] as String? ?? 'Unknown error');
      }

      final cmd = _readCmd(decoded);
      final messageType =
          decoded['messageType'] as String? ?? _messageTypeFromCmd(cmd);

      _eventController.add(
        MinigameSocketEvent(
          messageType: messageType.isEmpty ? command : messageType,
          cmd: cmd,
          payload: decoded,
        ),
      );
    } catch (e) {
      _logger.e('$name: parse error: $e');
      _errorController.add(e.toString());
    }
  }

  @override
  void onDisconnected() {
    _isAuthenticated = false;
    _loginStatusController.add(false);
  }

  @override
  void onError(dynamic error) {
    _errorController.add(error.toString());
  }

  @override
  void dispose() {
    _eventController.close();
    _errorController.close();
    _loginStatusController.close();
    super.dispose();
  }

  void _sendLogin() {
    if (!isConnected) {
      _logger.w('$name: cannot send MINI login - not connected');
      return;
    }

    final loginData = _mainLoginData;
    if (loginData == null) {
      _logger.e('$name: cannot send MINI login - missing MAIN login data');
      return;
    }

    final packet = [
      MinigameWsCmd.login,
      MinigamePortType.mini,
      _username ?? '',
      _password ?? '',
      loginData,
    ];
    send(jsonEncode(packet));
  }

  int? _readCmd(Map<String, dynamic> payload) {
    final raw = payload['cmd'];
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  String _messageTypeFromCmd(int? cmd) {
    return switch (cmd) {
      MinigameWsCmd.login => MinigameWsCommand.login,
      MinigameWsCmd.subscribeInfo => 'SUBSCRIBE_INFO',
      MinigameWsCmd.bet => 'BET',
      MinigameWsCmd.showResult => 'SHOW_RESULT',
      MinigameWsCmd.calculateResultMoney => 'CALCULATE_RESULT_MONEY',
      MinigameWsCmd.startGame => 'START_GAME',
      MinigameWsCmd.sessionAnalytic => 'SESSION_ANALYTIC',
      MinigameWsCmd.updateBetInfo => 'UPDATE_BET_INFO',
      MinigameWsCmd.getBetHistory => 'GET_BET_HISTORY',
      MinigameWsCmd.chat => 'CHAT',
      MinigameWsCmd.betFree => 'BET_FREE',
      _ => '',
    };
  }

  void _sendMessageType(String messageType, Map<String, dynamic> payload) {
    if (!isConnected) {
      _logger.w('$name: cannot send "$messageType" - not connected');
      return;
    }

    send(jsonEncode({
      'messageType': messageType,
      ...payload,
    }));
  }

  void _sendCommand(String command, Map<String, dynamic> payload) {
    if (!isConnected) {
      _logger.w('$name: cannot send "$command" - not connected');
      return;
    }

    send(jsonEncode({
      'command': command,
      ...payload,
    }));
  }

  void _handleArrayMessage(List<dynamic> data) {
    if (data.isEmpty) return;

    final rawCmd = data.first;
    final cmd = rawCmd is int ? rawCmd : int.tryParse(rawCmd.toString());

    if (cmd == MinigameWsCmd.login) {
      final payload = data.length > 1 ? data[1] : null;
      final ok = payload == true ||
          payload == 'success' ||
          (payload is Map &&
              (payload['success'] == true || payload['status'] == 'success'));
      _isAuthenticated = ok;
      _loginStatusController.add(ok);
      if (!ok) _errorController.add('Minigame login failed');
      return;
    }

    _eventController.add(
      MinigameSocketEvent(
        messageType: _messageTypeFromCmd(cmd),
        cmd: cmd,
        payload: {
          'raw': data,
          if (data.length > 1) 'payload': data[1],
        },
      ),
    );
  }
}

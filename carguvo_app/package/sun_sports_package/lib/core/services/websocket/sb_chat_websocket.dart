import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:auth_domain/auth_domain.dart' show JwtClaims;
import 'package:sun_sports/core/services/websocket/base_websocket.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/auth/token_error_handler.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/network_manger.dart';

import 'package:chat_protocol/chat_protocol.dart';

class ChatMessageData {
  final String? displayName;
  final String message;
  final int top;
  final bool isNoti;
  final bool isError;
  final DateTime timestamp;

  const ChatMessageData({
    required this.message,
    required this.timestamp,
    this.displayName,
    this.top = 0,
    this.isNoti = false,
    this.isError = false,
  });

  bool get isHighlighted => top > 0;

  bool get isSystemMessage => displayName == null || displayName!.isEmpty;

  factory ChatMessageData.fromServerMessage({
    required String? fromUser,
    required String messageJson,
    int top = 0,
    String? type,
  }) {
    final content = unwrapChatContent(messageJson);

    return ChatMessageData(
      displayName: fromUser,
      message: content,
      top: top,
      isNoti: type == 'TIP',
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessageData.error(String message) => ChatMessageData(
    message: message,
    isError: true,
    timestamp: DateTime.now(),
  );

  factory ChatMessageData.system(String message) => ChatMessageData(
    message: message,
    isNoti: true,
    timestamp: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'message': message,
    'top': top,
    'isNoti': isNoti,
    'isError': isError,
    'timestamp': timestamp.toIso8601String(),
  };
}

class SbChatWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  String? _accessToken;

  String? _wsToken;

  String? _currentUserName;

  @override
  bool get enableHeartbeat => false;

  StreamSubscription<NetworkManagerEvent>? _networkSub;

  late final ChatSessionMachine _machine = ChatSessionMachine(
    name: 'SbChatWebSocket',
    config: ChatSessionConfig.app,
    hooks: ChatSessionHooks(
      isTransportAlive: () => isConnected,
      canDial: () => SbConfig.instance.chatWs.isNotEmpty,
      isSignedOut: () => false,
      chatZone: () => SbConfig.chatZone,
      wsTokenExpiry: () {
        try {
          final token = _wsToken ?? '';
          return token.isEmpty ? null : JwtClaims.expiry(token);
        } catch (_) {
          return null;
        }
      },
      sendFrame: send,
      dial: _dialWithFreshTokens,
      teardownTransport: () {},
      refreshSession: ({required bool force}) async =>
          TokenErrorHandler.instance.handleTokenError(closeGameOnFail: false),
      onLoginStateChange: _loginStatusController.add,
      onLoginSuccess: fetchChatBox,
      onFatalStop: () {},
      log: (m) => _logger.w('[reconnectWS] $name: $m'),
    ),
  );

  static const Duration _resumeProbeTimeout = Duration(seconds: 5);

  Timer? _resumeProbe;

  final StreamController<ChatMessageData> _messageController =
      StreamController<ChatMessageData>.broadcast();

  final StreamController<List<ChatMessageData>> _historyController =
      StreamController<List<ChatMessageData>>.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final StreamController<bool> _loginStatusController =
      StreamController<bool>.broadcast();

  @override
  String get name => 'SbChatWebSocket';

  @override
  bool get reconnectViaReauth => true;

  String get _snapshot {
    final cfg = SbConfig.instance;
    final pongAt = _machine.lastPongAt;
    final pongAgo =
        pongAt == null ? 'n/a' : '${DateTime.now().difference(pongAt).inSeconds}s';
    return 'state=$state loggedIn=${_machine.isLoggedIn} '
        'chatWsEmpty=${cfg.chatWs.isEmpty} wsTokenLen=${cfg.wsToken.length} '
        'userTokenLen=${SbHttpManager.instance.userToken.length} sincePong=$pongAgo';
  }

  void _dlog(String msg) {
    if (kDebugMode) _logger.i('[reconnectWS] $name: $msg');
  }

  bool get isLoggedIn => _machine.isLoggedIn;

  String? get currentUserName => _currentUserName;

  Stream<ChatMessageData> get chatMessageStream => _messageController.stream;

  Stream<List<ChatMessageData>> get historyStream => _historyController.stream;

  Stream<String> get errorStream => _errorController.stream;

  Stream<bool> get loginStatusStream => _loginStatusController.stream;

  Future<bool> connectWithAuth(
    String url,
    String accessToken,
    String wsToken,
    String userName,
  ) async {
    _accessToken = accessToken;
    _wsToken = wsToken;
    _currentUserName = userName;
    _machine.rearm();

    _ensureNetworkWatch();

    return connect(url);
  }

  void _ensureNetworkWatch() {
    if (_networkSub != null) return;
    NetworkManager.instance.startListening();
    _networkSub = NetworkManager.instance.stream.listen((event) {
      if (event == NetworkManagerEvent.connectionRestored) _onNetworkRestored();
    });
  }

  void _onNetworkRestored() {
    if (_wsToken == null) return;
    if (isConnected && _machine.isLoggedIn) return;
    _logger.w('[reconnectWS] $name: connectivity restored → recover | $_snapshot');
    _machine.recover('connectivity restored', bypassDebounce: true);
  }

  final List<String> _roomStack = <String>[];

  String get activeRoom =>
      _roomStack.isNotEmpty ? _roomStack.last : SbConfig.chatRoom;

  bool pushRoom(String room) {
    if (room.isEmpty) return false;
    final String before = activeRoom;
    _roomStack.add(room);
    if (activeRoom == before) return false;
    fetchChatBox();
    return true;
  }

  bool popRoom(String room) {
    final int at = _roomStack.lastIndexOf(room);
    if (at < 0) return false;
    final String before = activeRoom;
    _roomStack.removeAt(at);
    if (activeRoom == before) return false;
    fetchChatBox();
    return true;
  }

  void probeWithHistory() {
    if (_resumeProbe != null) return;
    if (!isConnected || !_machine.isLoggedIn) {
      _machine.recover('resume probe: session not healthy');
      return;
    }
    fetchChatBox();
    _resumeProbe = Timer(_resumeProbeTimeout, () {
      _resumeProbe = null;
      _logger.w('[reconnectWS] $name: no reply to resume history probe '
          '→ recover | $_snapshot');
      _machine.recover('resume: no reply to history probe', bypassDebounce: true);
    });
  }

  void _cancelResumeProbe() {
    _resumeProbe?.cancel();
    _resumeProbe = null;
  }

  void fetchChatBox() {
    final command = jsonEncode(buildChatHistoryPayload(activeRoom));
    if (!_machine.isLoggedIn) {
      _machine.queueFrame(command);
      return;
    }

    send(command);
  }

  void sendChatMessage(String content) {
    if (!isConnected) {
      _logger.w('[reconnectWS] $name: send BLOCKED — not connected | $_snapshot');
      _machine.recover('send while not connected');
      return;
    }

    if (!_machine.isLoggedIn) {
      _logger.w('[reconnectWS] $name: send BLOCKED — not logged in | $_snapshot');
      _machine.recover('send while not logged in');
      return;
    }

    final command = jsonEncode(buildChatSendPayload(activeRoom, content));
    send(command);
    if (kDebugMode) _logger.i('$name: sendChatMessage OK → "$content"');
  }

  @override
  void dispose() {
    _machine.kill();
    _cancelResumeProbe();
    _networkSub?.cancel();
    _networkSub = null;
    _messageController.close();
    _historyController.close();
    _errorController.close();
    _loginStatusController.close();
    super.dispose();
  }

  @override
  void kill() {
    _machine.kill();
    _cancelResumeProbe();
    _networkSub?.cancel();
    _networkSub = null;
    super.kill();
  }

  @override
  Future<void> disconnect() async {
    _machine.kill();
    _cancelResumeProbe();
    _networkSub?.cancel();
    _networkSub = null;
    await super.disconnect();
  }

  @override
  void onConnected() {
    _dlog('TCP connected → sending login | $_snapshot');
    _machine.notifyTransportOpened();
    _sendLogin();
  }

  @override
  void onMessage(String message) {
    _handleMessage(message);
  }

  @override
  void onDisconnected() {
    _logger.w('[reconnectWS] $name: socket disconnected '
        '(wasLoggedIn=${_machine.isLoggedIn}) | $_snapshot');
    _cancelResumeProbe();
    _machine.notifyTransportClosed();
  }

  @override
  void onError(dynamic error) {
    _logger.e('[reconnectWS] $name: socket error: $error');
    _errorController.add(error.toString());
  }

  @override
  void onReconnectNeeded() => _machine.onTransportDropped();

  void _sendLogin() {
    if (_accessToken == null || _wsToken == null) {
      _logger.e('[reconnectWS] $name: cannot login — missing tokens '
          '(accessToken=${_accessToken != null}, wsToken=${_wsToken != null})');
      return;
    }

    send(jsonEncode(buildChatLoginPayload(_accessToken!, _wsToken!)));
    _dlog('login command sent (wsTokenLen=${_wsToken!.length})');
  }

  void _handleMessage(String rawMessage) {
    _cancelResumeProbe();
    dispatchChatFrame(
      rawMessage,
      onPong: _machine.notifyPong,
      onLogin: _machine.notifyLoginSuccess,
      onHistory: _onFetchChatBox,
      onChat: _onReceivedChat,
      onError: _onChatError,
      onUnknown: (command) => _logger.d('$name: Unknown command: $command'),
      onParseError: (e) =>
          _logger.e('$name: Parse message error: $e, raw: $rawMessage'),
    );
  }

  void _onFetchChatBox(Map<String, dynamic> data) {
    final String roomName = data['roomName'] as String? ?? '';
    if (roomName != activeRoom) return;

    final List<dynamic> messages = data['messages'] as List<dynamic>? ?? [];
    final List<ChatMessageData> chatMessages = [];

    for (final msg in messages) {
      if (msg is! Map<String, dynamic>) continue;

      final String? fromUser = msg['fromUser'] as String?;
      final String? messageJson = msg['message'] as String?;
      final int top = msg['top'] as int? ?? 0;
      final String? type = msg['t'] as String?;

      if (messageJson == null || type == 'TIP') continue;

      final chatMessage = ChatMessageData.fromServerMessage(
        fromUser: fromUser,
        messageJson: messageJson,
        top: top,
        type: type,
      );
      chatMessages.add(chatMessage);
    }

    _historyController.add(chatMessages);
  }

  void _onReceivedChat(Map<String, dynamic> data) {
    final String roomName = data['roomName'] as String? ?? '';
    if (roomName != activeRoom) return;

    final String? fromUser = data['fromUser'] as String?;
    final String? messageJson = data['message'] as String?;
    final int top = data['top'] as int? ?? 0;
    final String? type = data['t'] as String?;

    if (messageJson == null) return;

    final chatMessage = ChatMessageData.fromServerMessage(
      fromUser: fromUser,
      messageJson: messageJson,
      top: top,
      type: type,
    );

    _messageController.add(chatMessage);
  }

  void _onChatError(String? errorMessage) {
    final message = errorMessage ?? 'Unknown error';
    _logger.e('[reconnectWS] $name: server error frame: $message');
    _errorController.add(message);

    if (TokenErrorHandler.instance.isTokenError(message)) {
      _logger.w('[reconnectWS] $name: server reported a TOKEN error → recover');
      _machine.recover('server token error: $message');
      return;
    }

    _messageController.add(ChatMessageData.error(message));
  }

  Future<void> recover(String reason) => _machine.recover(reason);

  Future<void> _dialWithFreshTokens() async {
    final url = SbConfig.instance.chatWs;
    final accessToken = SbHttpManager.instance.userToken;
    final wsToken = SbConfig.instance.wsToken;
    final userName = SbHttpManager.instance.displayName;

    if (url.isEmpty || accessToken.isEmpty || wsToken.isEmpty) {
      _logger.e('[reconnectWS] $name: recover ABORT after refresh — '
          'urlEmpty=${url.isEmpty} accessTokenEmpty=${accessToken.isEmpty} '
          'wsTokenEmpty=${wsToken.isEmpty}');
      return;
    }

    _dlog('reconnecting chat (wsTokenLen=${wsToken.length}) ...');
    await connectWithAuth(url, accessToken, wsToken, userName);
    _dlog('reconnect dispatched (login pending)');
  }

}

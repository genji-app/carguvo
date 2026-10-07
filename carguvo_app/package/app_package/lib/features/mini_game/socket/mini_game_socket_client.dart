import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../auth/mini_game_auth_data.dart';
import 'enums.dart';
import 'mini_game_active_scopes.dart';
import 'mini_game_message_codec.dart';
import 'mini_game_ping_manager.dart';
import 'mini_game_socket_state.dart';

class MiniGameSocketClient {
  final String url;

  MiniGameAuthData auth;
  final MiniGameMessageCodec codec;
  final Logger _logger;

  final Future<MiniGameAuthData> Function()? readAuth;

  final Future<void> Function()? refreshCredentials;

  final WebSocketChannel Function(Uri uri) _channelFactory;

  final MiniGameActiveScopes? scopes;

  final Duration pingInterval;

  final StreamController<MiniGameSocketState> _stateController =
      StreamController<MiniGameSocketState>.broadcast();
  final StreamController<RawMessage> _messageController =
      StreamController<RawMessage>.broadcast();

  final StreamController<String> _kickController =
      StreamController<String>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  MiniGamePingManager? _pingManager;
  MiniGameSocketState _state = const MiniGameSocketState.disconnected();
  int _reconnectAttempt = 0;

  Timer? _reconnectTimer;

  int _connectEpoch = 0;

  Timer? _loginTimer;

  int _consecutiveLoginTimeouts = 0;

  static const Duration _loginResponseTimeout = Duration(seconds: 10);

  static const int _loginTimeoutEscalationThreshold = 2;

  bool _wantConnected = false;

  bool _disposed = false;

  static const List<Duration> _reconnectBackoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
  ];

  MiniGameSocketClient({
    required this.url,
    required this.auth,
    required this.codec,
    this.readAuth,
    this.refreshCredentials,
    this.scopes,
    this.pingInterval = MiniGamePingManager.defaultPingInterval,
    WebSocketChannel Function(Uri uri)? channelFactory,
    Logger? logger,
  }) : _channelFactory = channelFactory ?? WebSocketChannel.connect,
       _logger = logger ?? Logger();

  @visibleForTesting
  int get consecutiveLoginTimeouts => _consecutiveLoginTimeouts;

  Stream<MiniGameSocketState> get stateStream => _stateController.stream;

  Stream<RawMessage> get messageStream => _messageController.stream;

  Stream<String> get kickStream => _kickController.stream;

  MiniGameSocketState get state => _state;

  Future<void> connect() async {
    if (_disposed) return;
    _wantConnected = true;
    final epoch = ++_connectEpoch;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _teardownChannel();
    if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
    _setState(const MiniGameSocketState.connecting());

    try {
      final uri = _withWsToken(Uri.parse(url), auth.wsToken);
      _channel = _channelFactory(uri);
      await _channel!.ready.timeout(const Duration(seconds: 10));
      if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
      _setState(const MiniGameSocketState.connected());

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onClose,
        cancelOnError: false,
      );

      final loginPacket = [
        MessageRequest.loginType.code,
        'MiniGame',
        '',
        '',
        {'info': auth.info, 'signature': auth.signature},
      ];
      _logger.i(
        '[MiniGameAuth] login_request zone=MiniGame username_empty=true password_empty=true',
      );
      send(loginPacket);

      _loginTimer?.cancel();
      _loginTimer = Timer(_loginResponseTimeout, () {
        _loginTimer = null;
        if (_disposed || !_wantConnected) return;
        _logger.w('[MiniGameAuth] login_response timeout — schedule reconnect');
        _consecutiveLoginTimeouts++;
        _scheduleReconnect('login-timeout');
      });

      _pingManager = MiniGamePingManager(
        send: send,
        reconnect: _reconnect,
        pingInterval: pingInterval,
      );
    } catch (e, st) {
      if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
      _logger.e(
        'MiniGameSocketClient.connect failed',
        error: e,
        stackTrace: st,
      );
      _setState(MiniGameSocketState.failed(e.toString()));
      _scheduleReconnect('connect-failed');
      rethrow;
    }
  }

  Uri _withWsToken(Uri uri, String wsToken) {
    return uri.replace(
      queryParameters: {...uri.queryParameters, 'token': wsToken},
    );
  }

  void send(List<Object?> message) {
    final ch = _channel;
    if (ch == null) {
      _logger.w('send() called with no open channel — message dropped');
      return;
    }
    try {
      ch.sink.add(codec.encode(message));
    } catch (e, st) {
      _logger.e('MiniGameSocketClient.send failed', error: e, stackTrace: st);
    }
  }

  void _onMessage(dynamic data) {
    try {
      final raw = codec.decode(data as Object);
      if (raw.type == MessageResponse.pingResponse.code) {
        _pingManager?.onPingResponse(_readPingId(raw));
      } else if (raw.type == MessageResponse.loginResponse.code) {
        _logger.i('[MiniGameAuth] login_response success');
        _reconnectAttempt = 0;
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _loginTimer?.cancel();
        _loginTimer = null;
        _consecutiveLoginTimeouts = 0;
        _setState(const MiniGameSocketState.authenticated());
        _logger.i('[MiniGameAuth] authenticated');
        _pingManager?.start();
      } else if (raw.type == MessageResponse.logoutResponse.code) {
        _handleKick();
        return;
      }
      if (_shouldDropWhileClosed(raw)) return;
      _messageController.add(raw);
    } catch (e, st) {
      _logger.e('MiniGameSocketClient.decode failed', error: e, stackTrace: st);
    }
  }

  void _handleKick() {
    _logger.w('[MiniGameWS] cmd 2 — đăng nhập ở thiết bị khác → ngắt socket');
    unawaited(disconnect());
    if (!_kickController.isClosed) {
      _kickController.add('LOGIN_ANOTHER_DEVICE');
    }
  }

  static const Set<int> _taiXiuNoiseCmds = {
    1000, 1004, 1007, 1008, 1009, 1010, 1011,
  };

  bool _shouldDropWhileClosed(RawMessage raw) {
    final scopes = this.scopes;
    if (scopes == null) return false;
    if (raw.type != MessageResponse.extensionResponse.code) return false;
    final cmd = raw.cmd;
    if (cmd >= 1300 && cmd <= 1399) return !scopes.slotsActive;
    if (cmd >= 1500 && cmd <= 1599) return !scopes.trenDuoiActive;
    if (!scopes.taiXiuActive && _taiXiuNoiseCmds.contains(cmd)) return true;
    return false;
  }

  void _onError(Object error, StackTrace stackTrace) {
    _logger.e('WebSocket error', error: error, stackTrace: stackTrace);
    _pingManager?.stop();
    _loginTimer?.cancel();
    _loginTimer = null;
    _setState(MiniGameSocketState.failed(error.toString()));
    _scheduleReconnect('onerror');
  }

  void _onClose() {
    _logger.i('WebSocket onclose');
    _pingManager?.stop();
    _loginTimer?.cancel();
    _loginTimer = null;
    _scheduleReconnect('onclose');
  }

  void _scheduleReconnect(String reason) {
    if (_disposed || !_wantConnected) return;
    if (_reconnectTimer?.isActive ?? false) return;

    final delay = _reconnectBackoff[_reconnectAttempt.clamp(
      0,
      _reconnectBackoff.length - 1,
    )];
    _reconnectAttempt++;
    _setState(MiniGameSocketState.reconnecting(_reconnectAttempt));
    _logger.i(
      '[MiniGameWS] schedule reconnect #$_reconnectAttempt in '
      '${delay.inSeconds}s ($reason)',
    );
    _reconnectTimer = Timer(delay, () async {
      _reconnectTimer = null;
      if (_disposed || !_wantConnected) return;
      final epoch = _connectEpoch;

      if (_consecutiveLoginTimeouts >= _loginTimeoutEscalationThreshold &&
          refreshCredentials != null) {
        try {
          await refreshCredentials!();
        } catch (e) {
          _logger.w(
            '[MiniGameAuth] refreshCredentials failed (transient) — retry sau: $e',
          );
        }
        _consecutiveLoginTimeouts = 0;
        if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
      }

      if (readAuth != null) {
        try {
          final freshAuth = await readAuth!();
          if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
          auth = freshAuth;
        } catch (e) {
          _logger.w('[MiniGameAuth] readAuth failed — giữ snapshot cũ: $e');
          if (_disposed || !_wantConnected || epoch != _connectEpoch) return;
        }
      }

      try {
        await connect();
      } catch (_) {
      }
    });
  }

  Future<void> recover(MiniGameAuthData freshAuth) async {
    if (_disposed) return;
    auth = freshAuth;
    _reconnectAttempt = 0;
    _logger.i('[MiniGameWS] recover() — reconnect with fresh auth snapshot');
    await connect();
  }

  Future<void> _reconnect() async {
    _scheduleReconnect('ping-timeout');
  }

  Future<void> ensureConnected() async {
    if (_disposed) return;
    final s = _state;
    if (s is SocketAuthenticated ||
        s is SocketConnecting ||
        s is SocketReconnecting) {
      return;
    }
    _logger.i('[MiniGameWS] ensureConnected() — socket không sống → mở lại');
    _reconnectAttempt = 0;
    await connect();
  }

  void _setState(MiniGameSocketState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  int _readPingId(RawMessage raw) {
    final value = raw.payload['pingId'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _teardownChannel() async {
    _loginTimer?.cancel();
    _loginTimer = null;
    _pingManager?.dispose();
    _pingManager = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        await channel.sink.close().timeout(const Duration(seconds: 2));
      } catch (_) {
        _logger.w('[MiniGameWS] sink.close() timed out/failed — bỏ qua, reconnect tiếp');
      }
    }
  }

  Future<void> disconnect() async {
    _wantConnected = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _teardownChannel();
    if (_state is! SocketDisconnected) {
      _setState(const MiniGameSocketState.disconnected());
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _kickController.close();
  }
}

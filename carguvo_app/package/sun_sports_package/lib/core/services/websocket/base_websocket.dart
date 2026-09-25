import 'dart:async';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/shared/domain/enums/websocket_enums.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:sun_sports/shared/domain/enums/websocket_enums.dart'
    show WsConnectionState;

abstract class BaseWebSocket {
  final AppLogger _logger = AppLogger();

  WebSocketChannel? _channel;

  WsConnectionState _state = WsConnectionState.disconnected;

  String _url = '';

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  final StreamController<WsConnectionState> _stateController =
      StreamController<WsConnectionState>.broadcast();

  Timer? _reconnectTimer;

  Timer? _heartbeatTimer;

  StreamSubscription<dynamic>? _channelSubscription;

  int _reconnectAttempts = 0;

  bool _isConnecting = false;

  bool _needsTokenRefresh = false;

  static const int maxReconnectAttempts = 5;

  static const int heartbeatInterval = 30;

  static const int baseReconnectDelay = 2;

  WsConnectionState get state => _state;

  bool get isConnected => _state == WsConnectionState.connected;

  Stream<String> get messageStream => _messageController.stream;

  Stream<WsConnectionState> get stateStream => _stateController.stream;

  String get name;

  Future<bool> connect(String url) async {
    if (_state == WsConnectionState.connecting) {
      _logger.w('$name: Already connecting...');
      return false;
    }

    if (_state == WsConnectionState.connected && _url == url) {
      _logger.w('$name: Already connected to $url');
      return true;
    }

    _cancelTimers();
    _killCurrentChannel();
    _needsTokenRefresh = false;

    _url = url;
    _setState(WsConnectionState.connecting);
    _reconnectAttempts = 0;

    return _doConnect();
  }

  Future<void> disconnect() async {
    _logger.i('$name: Disconnecting...');

    _cancelTimers();
    _reconnectAttempts = maxReconnectAttempts;

    await _closeCurrentChannel();

    _setState(WsConnectionState.disconnected);
  }

  void send(String message) {
    if (!isConnected) {
      _logger.w('$name: Cannot send - not connected');
      return;
    }

    try {
      _channel?.sink.add(message);
    } catch (e) {
      _logger.e('$name: Send error: $e');
    }
  }

  void ping() {
    send('PING');
  }

  void kill() {
    _cancelTimers();
    _reconnectAttempts = maxReconnectAttempts;
    _isConnecting = false;

    _killCurrentChannel();

    _setState(WsConnectionState.disconnected);
    _logger.i('$name: Killed');
  }

  void dispose() {
    kill();
    _messageController.close();
    _stateController.close();
  }

  void markTokenExpired() {
    _needsTokenRefresh = true;
  }

  void onConnected() {
  }

  void onMessage(String message) {
  }

  void onDisconnected() {
  }

  void onError(dynamic error) {
  }

  bool get reconnectViaReauth => false;

  void onReconnectNeeded() {
  }

  void _killCurrentChannel() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  Future<void> _closeCurrentChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;

    if (_channel != null) {
      try {
        await _channel!.sink.close().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _logger.w('$name: sink.close() timed out after 5s');
          },
        );
      } catch (e) {
        _logger.w('$name: sink.close() error (ignored): $e');
      }
      _channel = null;
    }
  }

  Future<bool> _doConnect() async {
    if (_isConnecting) return false;
    _isConnecting = true;

    try {

      final uri = Uri.parse(_url);
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _setState(WsConnectionState.connected);
      _logger.i('$name: Connected');

      _startHeartbeat();

      await _channelSubscription?.cancel();

      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      onConnected();

      return true;
    } catch (e) {
      _logger.e('$name: Connection failed: $e');
      _setState(WsConnectionState.error);
      onError(e);

      if (reconnectViaReauth) {
        onReconnectNeeded();
      } else {
        _scheduleReconnect();
      }

      return false;
    } finally {
      _isConnecting = false;
    }
  }

  void _handleMessage(dynamic message) {
    final messageStr = message.toString();

    if (messageStr.toUpperCase() == 'PONG') {
      return;
    }

    _messageController.add(messageStr);

    onMessage(messageStr);
  }

  void _handleError(dynamic error) {
    _logger.e('$name: Error: $error');
    _setState(WsConnectionState.error);
    onError(error);

    if (reconnectViaReauth) {
      onReconnectNeeded();
    } else {
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    _logger.w(
      '[reconnectWS] $name: connection closed '
      '(needsTokenRefresh=$_needsTokenRefresh, reconnectViaReauth=$reconnectViaReauth)',
    );

    if (_state != WsConnectionState.disconnected) {
      _setState(WsConnectionState.disconnected);
      onDisconnected();

      if (_needsTokenRefresh) {
        _logger.i('[reconnectWS] $name: auto-reconnect skipped — token refresh in progress');
      } else if (reconnectViaReauth) {
        onReconnectNeeded();
      } else {
        _scheduleReconnect();
      }
      _needsTokenRefresh = false;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _logger.e('[reconnectWS] $name: max reconnect attempts reached — giving up');
      return;
    }

    _reconnectAttempts++;
    _setState(WsConnectionState.reconnecting);

    final delay =
        (baseReconnectDelay * (1 << (_reconnectAttempts - 1))).clamp(0, 60);
    _logger.i('[reconnectWS] $name: self-redial in ${delay}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (_state == WsConnectionState.reconnecting && !_isConnecting) {
        _killCurrentChannel();
        _doConnect();
      }
    });
  }

  bool get enableHeartbeat => true;

  void _startHeartbeat() {
    if (!enableHeartbeat) return;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: heartbeatInterval),
      (_) {
        if (isConnected) {
          ping();
        }
      },
    );
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _setState(WsConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }
}

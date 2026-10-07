import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_config.dart';
import '../events/connection_state.dart';
import '../utils/logger.dart';

class ConnectionHandler {
  final SocketConfig _config;
  final Logger _logger;

  String _currentUrl;

  WebSocketChannel? _channel;

  ConnectionState _state = ConnectionState.disconnected;

  int _reconnectAttempts = 0;

  bool _manualDisconnect = false;

  static const Duration _readyTimeout = Duration(seconds: 15);

  Timer? _reconnectTimer;

  Timer? _pingTimer;

  Timer? _pongTimeoutTimer;

  int _pingCounter = 0;

  int? _awaitingPongNumber;

  StreamSubscription<dynamic>? _messageSubscription;

  final StreamController<ConnectionStateEvent> _stateController =
      StreamController<ConnectionStateEvent>.broadcast();

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  final StreamController<Uint8List> _binaryController =
      StreamController<Uint8List>.broadcast();

  final StreamController<void> _reconnectedController =
      StreamController<void>.broadcast();

  Stream<ConnectionStateEvent> get onStateChanged => _stateController.stream;

  Stream<String> get onMessage => _messageController.stream;

  Stream<Uint8List> get onBinaryMessage => _binaryController.stream;

  Stream<void> get onReconnected => _reconnectedController.stream;

  ConnectionState get state => _state;

  bool get isConnected => _state == ConnectionState.connected;

  ConnectionHandler({
    required SocketConfig config,
  })  : _config = config,
        _logger = config.logger,
        _currentUrl = config.url;

  Future<void> connect() async {
    if (_state == ConnectionState.connecting ||
        _state == ConnectionState.connected) {
      _logger.debug('Already connecting or connected');
      return;
    }

    _updateState(ConnectionState.connecting);
    _manualDisconnect = false;

    try {
      _logger.info('Connecting to $_currentUrl');

      final uri = Uri.parse(_currentUrl);
      _channel = _config.channelFactory?.call(uri) ?? WebSocketChannel.connect(uri);

      await _channel!.ready.timeout(_readyTimeout);

      final wasReconnecting =
          _state == ConnectionState.reconnecting || _reconnectAttempts > 0;

      _state = ConnectionState.connected;
      final previousAttempts = _reconnectAttempts;
      _reconnectAttempts = 0;

      _emitStateEvent(ConnectionStateEvent.connected(
        previousState: ConnectionState.connecting,
      ));

      _logger.info('Connected to WebSocket');

      if (wasReconnecting || previousAttempts > 0) {
        _logger.info('Reconnection successful, notifying subscribers...');
        _reconnectedController.add(null);
      }

      _startListening();

      _startPingTimer();
    } catch (e, stackTrace) {
      _logger.error('Connection failed', e, stackTrace);

      unawaited(_channel?.sink.close());
      _channel = null;

      _updateState(ConnectionState.error);
      _emitStateEvent(ConnectionStateEvent.error(
        previousState: ConnectionState.connecting,
        message: e.toString(),
      ));

      if (_config.autoReconnect) {
        _scheduleReconnect();
      }
    }
  }

  Future<void> ensureAlive() async {
    if (_manualDisconnect) return;

    switch (_state) {
      case ConnectionState.connected:
        ping();
        return;
      case ConnectionState.connecting:
        return;
      case ConnectionState.reconnecting:
      case ConnectionState.disconnected:
      case ConnectionState.error:
        _logger.info(
          'ensureAlive: state=$_state after resume — forcing reconnect '
          '(attempts were $_reconnectAttempts)',
        );
        _cancelReconnectTimer();
        _reconnectAttempts = 0;
        if (_config.onTokenRefresh != null) {
          try {
            final newToken = await _config.onTokenRefresh!();
            if (newToken != null) _updateUrlToken(newToken);
          } catch (e) {
            _logger.error('ensureAlive: token refresh failed', e);
          }
        }
        await connect();
    }
  }

  Future<void> disconnect() async {
    _logger.info('Disconnecting...');
    _manualDisconnect = true;

    _cancelReconnectTimer();
    _cancelPingTimer();
    _cancelPongTimeoutTimer();

    _awaitingPongNumber = null;

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Manual disconnect',
    ));

    _logger.info('Disconnected');
  }

  void send(dynamic message) {
    if (_channel == null || !isConnected) {
      _logger.warning('Cannot send: not connected');
      return;
    }

    try {
      _channel!.sink.add(message);
    } catch (e) {
      _logger.error('Send error', e);
    }
  }

  void ping() {
    if (!isConnected) return;

    final pingNum = _pingCounter++;
    _awaitingPongNumber = pingNum;

    final message = 'ping_$pingNum';

    if (_config.useV2Protocol) {
      final bytes = Uint8List.fromList(utf8.encode(message));
      send(bytes);
      _logger.debug('Sent $message as binary (${bytes.length} bytes)');
    } else {
      final base64Encoded = base64Encode(utf8.encode(message));
      send(base64Encoded);
      _logger.debug('Sent ping_$pingNum (V1 Base64)');
    }

    _cancelPongTimeoutTimer();
    _pongTimeoutTimer = Timer(_config.pongTimeout, () {
      _logger.warning(
          'Pong timeout - no response for ping_$pingNum, reconnecting...');
      _awaitingPongNumber = null;
      _handlePongTimeout();
    });
  }

  void _handlePongTimeout() {
    _messageSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Pong timeout',
    ));

    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  void _handlePongMessage(String pongMessage) {
    final number = int.tryParse(pongMessage.replaceFirst('pong_', ''));
    if (number == _awaitingPongNumber) {
      _logger.debug('Received pong_$number');
      _cancelPongTimeoutTimer();
      _awaitingPongNumber = null;
    }
  }

  void _cancelPongTimeoutTimer() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _startListening() {
    _messageSubscription = _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );
  }

  void _handleMessage(dynamic message) {
    if (message is List<int>) {
      final bytes = Uint8List.fromList(message);

      if (_config.useV2Protocol && bytes.length < 100) {
        try {
          final textContent = utf8.decode(bytes);
          if (textContent.startsWith('pong_')) {
            _handlePongMessage(textContent);
            return;
          }
          try {
            final decoded = utf8.decode(base64Decode(textContent));
            if (decoded.startsWith('pong_')) {
              _handlePongMessage(decoded);
              return;
            }
          } catch (_) {
          }
        } catch (_) {
        }
      }

      _binaryController.add(bytes);
      return;
    }

    if (message is String) {
      if (message.startsWith('pong_')) {
        _handlePongMessage(message);
        return;
      }

      if (message == 'pong') {
        _cancelPongTimeoutTimer();
        _awaitingPongNumber = null;
        return;
      }

      try {
        final decoded = utf8.decode(base64Decode(message));
        if (decoded.startsWith('pong_')) {
          _handlePongMessage(decoded);
          return;
        }
        _messageController.add(message);
      } catch (_) {
        _messageController.add(message);
      }
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _logger.error('WebSocket error', error, stackTrace);

    final previousState = _state;
    _updateState(ConnectionState.error);

    _emitStateEvent(ConnectionStateEvent.error(
      previousState: previousState,
      message: error.toString(),
    ));

    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    _logger.info('WebSocket connection closed');

    if (_state == ConnectionState.disconnected) {
      return;
    }

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Connection closed',
    ));

    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_config.maxReconnectAttempts > 0 &&
        _reconnectAttempts >= _config.maxReconnectAttempts) {
      _logger.warning(
        'Max reconnect attempts reached ($_reconnectAttempts)',
      );
      return;
    }

    _reconnectAttempts++;

    final delay = Duration(
      milliseconds: _config.reconnectDelay.inMilliseconds *
          (1 << (_reconnectAttempts - 1).clamp(0, 5)),
    );

    _logger.info(
      'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _updateState(ConnectionState.reconnecting);

    _emitStateEvent(ConnectionStateEvent.reconnecting(
      previousState: _state,
      attempt: _reconnectAttempts,
    ));

    _reconnectTimer = Timer(delay, () async {
      if (_config.onTokenRefresh != null) {
        try {
          _logger.info(
            'Refreshing token before reconnect (attempt $_reconnectAttempts)...',
          );
          final newToken = await _config.onTokenRefresh!();
          if (newToken != null) {
            _logger.info('Token refreshed successfully');
            _updateUrlToken(newToken);
          }
        } catch (e) {
          _logger.error('Token refresh before reconnect failed', e);
        }
      }

      await connect();
    });
  }

  void updateUrl(String url) {
    _currentUrl = url;
    _logger.debug('URL updated');
  }

  void _updateUrlToken(String newToken) {
    final uri = Uri.parse(_currentUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams['token'] = newToken;
    _currentUrl = uri.replace(queryParameters: newParams).toString();
    _logger.debug('URL updated with new token');
  }

  void _startPingTimer() {
    _cancelPingTimer();

    _pingTimer = Timer.periodic(_config.pingInterval, (_) {
      if (isConnected) {
        ping();
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cancelPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _updateState(ConnectionState newState) {
    _state = newState;
  }

  void _emitStateEvent(ConnectionStateEvent event) {
    _stateController.add(event);
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _binaryController.close();
    await _reconnectedController.close();
  }
}

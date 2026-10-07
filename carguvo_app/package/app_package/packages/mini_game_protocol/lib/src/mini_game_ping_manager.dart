library;

import 'dart:async';

import 'enums.dart';

class MiniGamePingManager {
  static const Duration defaultPingInterval = Duration(seconds: 5);
  static const Duration defaultResponseTimeout = Duration(seconds: 5);

  final void Function(List<Object?> message) _send;
  final Future<void> Function() _reconnect;
  final Duration _pingInterval;
  final Duration _responseTimeout;

  Timer? _pingTimer;
  Timer? _responseTimer;
  int _lastPingId = 0;
  bool _isLoggedIn = false;
  bool _disposed = false;

  MiniGamePingManager({
    required void Function(List<Object?> message) send,
    required Future<void> Function() reconnect,
    Duration pingInterval = defaultPingInterval,
    Duration responseTimeout = defaultResponseTimeout,
  }) : _send = send,
       _reconnect = reconnect,
       _pingInterval = pingInterval,
       _responseTimeout = responseTimeout;

  bool get isDisposed => _disposed;

  bool get isLoggedIn => _isLoggedIn;

  void pause() {
    if (_disposed || !_isLoggedIn) return;
    _cancelTimers();
  }

  void resume() {
    if (_disposed || !_isLoggedIn) return;
    if (!_hasActiveTimer) _scheduleNextPing();
  }

  void start({int lastPingId = 0}) {
    if (_disposed) return;
    _isLoggedIn = true;
    _lastPingId = lastPingId;
    _scheduleNextPing();
  }

  void stop() {
    _isLoggedIn = false;
    _lastPingId = 0;
    _cancelTimers();
  }

  void onPingResponse(int pingId) {
    if (_disposed || !_isLoggedIn) return;
    _responseTimer?.cancel();
    _responseTimer = null;
    _lastPingId = pingId;
    _scheduleNextPing();
  }

  void _scheduleNextPing() {
    if (_disposed || !_isLoggedIn) return;
    _pingTimer?.cancel();
    _pingTimer = Timer(_pingInterval, _sendPing);
  }

  void _sendPing() {
    if (_disposed || !_isLoggedIn) {
      stop();
      return;
    }

    _pingTimer?.cancel();
    _pingTimer = null;

    _send([
      MessageRequest.pingType.code,
      kMiniGamePort,
      _lastPingId + 1,
      0,
    ]);

    _responseTimer?.cancel();
    _responseTimer = Timer(_responseTimeout, () {
      if (_disposed || !_isLoggedIn) return;
      stop();
      _reconnect();
    });
  }

  bool get _hasActiveTimer =>
      (_pingTimer?.isActive ?? false) || (_responseTimer?.isActive ?? false);

  bool get isStalled => !_disposed && _isLoggedIn && !_hasActiveTimer;

  void ensureRunning() {
    if (_disposed || !_isLoggedIn || _hasActiveTimer) return;
    _sendPing();
  }

  void _cancelTimers() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _responseTimer?.cancel();
    _responseTimer = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cancelTimers();
  }
}

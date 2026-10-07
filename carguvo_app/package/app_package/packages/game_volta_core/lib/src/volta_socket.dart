import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'volta_platform.dart';
import 'volta_socket_config.dart';
import 'volta_socket_frame.dart';
import 'volta_wire.dart';

abstract class VoltaSocketChannel {
  Future<void> get ready;

  Stream<dynamic> get stream;

  void send(String data);

  int? get closeCode;

  Future<void> close();
}

class VoltaWsChannel implements VoltaSocketChannel {
  VoltaWsChannel(Uri uri) : _inner = WebSocketChannel.connect(uri);

  final WebSocketChannel _inner;

  @override
  Future<void> get ready => _inner.ready;

  @override
  Stream<dynamic> get stream => _inner.stream;

  @override
  void send(String data) => _inner.sink.add(data);

  @override
  int? get closeCode => _inner.closeCode;

  @override
  Future<void> close() async {
    try {
      await _inner.sink.close();
    } on Object {
    }
  }
}

enum VoltaSocketStatus { idle, connecting, open, waiting, stopped }

class VoltaSocket {
  VoltaSocket({
    required this.uri,
    required this.tokenProvider,
    this.config = const VoltaSocketConfig(),
    VoltaSocketChannel Function(Uri uri)? openChannel,
    this.onNeedsAuth,
    this.onRetriesExhausted,
  }) : _openChannel = openChannel ?? VoltaWsChannel.new;

  final Uri uri;

  final Future<String?> Function() tokenProvider;

  final VoltaSocketConfig config;

  final void Function()? onNeedsAuth;

  final void Function()? onRetriesExhausted;

  final VoltaSocketChannel Function(Uri uri) _openChannel;

  final StreamController<List<VoltaWireEvent>> _events =
      StreamController<List<VoltaWireEvent>>.broadcast();
  final StreamController<VoltaSocketStatus> _status =
      StreamController<VoltaSocketStatus>.broadcast();

  Stream<List<VoltaWireEvent>> get events => _events.stream;

  Stream<VoltaSocketStatus> get status => _status.stream;

  VoltaSocketStatus get currentStatus => _current;
  VoltaSocketStatus _current = VoltaSocketStatus.idle;

  late final VoltaSocketFrameCodec _codec = VoltaSocketFrameCodec(
    config: config,
  );

  VoltaSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  Timer? _pingTimer;
  Timer? _retryTimer;

  bool _connecting = false;
  bool _dropHandled = true;

  int _attempt = 0;
  int _pingSeq = 0;
  DateTime? _lastAliveAt;
  DateTime? _pausedAt;
  bool _paused = false;
  bool _stopped = true;
  bool _disposed = false;

  final Random _random = Random();

  Future<void> connect() async {
    if (_disposed) return;
    _stopped = false;
    await _open();
  }

  Future<void> disconnect() async {
    _stopped = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _teardown();
    _emitStatus(VoltaSocketStatus.stopped);
  }

  Future<void> reconnectNow() async {
    if (_disposed) return;
    _retryTimer?.cancel();
    _retryTimer = null;
    _attempt = 0;
    _stopped = false;
    await _teardown();
    await _open();
  }

  Future<void> _open() async {
    if (_disposed || _stopped || _paused) return;
    if (config.singleFlightConnect && _connecting) return;
    _connecting = true;

    if (config.cancelAllTimersOnConnect) _cancelAllTimers();
    _emitStatus(VoltaSocketStatus.connecting);

    try {
      final String? token = await tokenProvider();
      if (_disposed || _stopped) return;

      final VoltaSocketChannel channel = _openChannel(_uriWith(token));
      _channel = channel;
      _dropHandled = false;

      await channel.ready.timeout(config.connectTimeout);
      if (_disposed || _stopped) {
        await channel.close();
        _channel = null;
        return;
      }

      _sub = channel.stream.listen(
        _onMessage,
        onError: (Object _) => _onDropped(),
        onDone: _onDropped,
        cancelOnError: false,
      );

      _attempt = 0;
      _lastAliveAt = DateTime.now();
      _startHeartbeat();
      _emitStatus(VoltaSocketStatus.open);
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaSocket: mở kết nối hỏng — $e');
      await _teardown();
      _scheduleRetry();
    } finally {
      _connecting = false;
    }
  }

  Uri _uriWith(String? token) {
    if (!config.sendTokenInQuery || token == null || token.isEmpty) return uri;
    return uri.replace(
      queryParameters: <String, String>{...uri.queryParameters, 'token': token},
    );
  }

  void _cancelAllTimers() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = null;
    if (config.pingWaitsForPong) {
      _sendPing();
      return;
    }
    _pingTimer = Timer.periodic(config.pingInterval, (_) => _beat());
  }

  void _beat() {
    if (_channel == null || _paused) return;

    final Duration? timeout = config.pongTimeout;
    final DateTime? aliveAt = _lastAliveAt;
    if (timeout != null &&
        aliveAt != null &&
        DateTime.now().difference(aliveAt) > timeout) {
      if (voltaDebug) {
        voltaLog(() =>
          'VoltaSocket: im lặng quá ${timeout.inMilliseconds}ms — nối lại.',
        );
      }
      _onDropped();
      return;
    }
    _sendPing();
  }

  void _sendPing() {
    final VoltaSocketChannel? channel = _channel;
    if (channel == null || _paused) return;
    try {
      channel.send('${config.pingPrefix}${++_pingSeq}');
    } on Object {
      _onDropped();
    }
  }

  void _schedulePingAfterPong() {
    if (!config.pingWaitsForPong) return;
    _pingTimer?.cancel();
    _pingTimer = Timer(config.pingInterval, _sendPing);
  }

  void _onMessage(dynamic raw) {
    if (config.treatAnyMessageAsAlive) _lastAliveAt = DateTime.now();

    final VoltaSocketFrame frame = _codec.decode(raw);
    switch (frame) {
      case VoltaPongFrame():
        _lastAliveAt = DateTime.now();
        _schedulePingAfterPong();
      case VoltaDataFrame(:final List<VoltaWireEvent> events):
        if (!_events.isClosed) _events.add(events);
      case VoltaDroppedFrame(:final String reason, :final bool corrupt):
        if (corrupt && voltaDebug) {
          voltaLog(() => 'VoltaSocket: bỏ gói tin — $reason');
        }
    }
  }

  void _onDropped() {
    if (config.dedupeDrop && _dropHandled) return;
    _dropHandled = true;

    final int? code = _channel?.closeCode;
    unawaited(_teardown());

    if (_stopped || _disposed) return;

    if (!config.distinguishAuthClose) {
      onNeedsAuth?.call();
    } else if (code != null &&
        VoltaSocketConfig.authCloseCodes.contains(code)) {
      if (voltaDebug) {
        voltaLog(() => 'VoltaSocket: server đóng vì auth (mã $code) — xin token.');
      }
      onNeedsAuth?.call();
    }
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (_stopped || _disposed || _paused) return;
    _retryTimer?.cancel();

    final int? limit = config.maxAttempts;
    if (limit != null && _attempt >= limit) {
      _emitStatus(VoltaSocketStatus.stopped);
      onRetriesExhausted?.call();
      return;
    }

    final Duration wait = backoffFor(_attempt);
    _attempt++;
    _emitStatus(VoltaSocketStatus.waiting);
    _retryTimer = Timer(wait, () {
      _retryTimer = null;
      unawaited(_open());
    });
  }

  @visibleForTesting
  Duration backoffFor(int attempt) {
    if (!config.useBackoff) return config.retryInterval;

    final int base = config.retryInterval.inMilliseconds;
    final int capped = config.maxBackoff.inMilliseconds;
    final int shift = attempt.clamp(0, 20);
    final int raw = min(base * (1 << shift), capped);
    final double jitter =
        1 + (_random.nextDouble() * 2 - 1) * config.backoffJitter;
    return Duration(milliseconds: (raw * jitter).round().clamp(0, capped));
  }

  void onAppPaused() {
    if (_paused) return;
    _paused = true;
    _pausedAt = DateTime.now();
    _cancelAllTimers();
  }

  void onAppResumed() {
    if (!_paused) return;
    _paused = false;
    final DateTime? pausedAt = _pausedAt;
    _pausedAt = null;
    if (_stopped || _disposed) return;

    final bool longGap =
        pausedAt != null &&
        DateTime.now().difference(pausedAt) >= config.resumeReconnectThreshold;

    if (longGap || _channel == null) {
      unawaited(reconnectNow());
      return;
    }
    _lastAliveAt = DateTime.now();
    _startHeartbeat();
  }

  Future<void> _teardown() async {
    _cancelAllTimers();
    final StreamSubscription<dynamic>? sub = _sub;
    _sub = null;
    final VoltaSocketChannel? channel = _channel;
    _channel = null;
    _lastAliveAt = null;
    await sub?.cancel();
    await channel?.close();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stopped = true;
    await _teardown();
    await _events.close();
    await _status.close();
  }

  void _emitStatus(VoltaSocketStatus value) {
    if (_current == value) return;
    _current = value;
    if (!_status.isClosed) _status.add(value);
  }
}

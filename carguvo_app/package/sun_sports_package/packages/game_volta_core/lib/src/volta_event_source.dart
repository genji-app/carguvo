import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';
import 'volta_wire.dart';

abstract class VoltaEventSource {
  Stream<List<VoltaWireEvent>> get batches;

  Future<void> refresh();

  void setActive(bool active) {}

  Future<void> dispose();
}

class VoltaDemoEventSource implements VoltaEventSource {
  VoltaDemoEventSource() {
    _emitRound();
    _tick = Timer.periodic(const Duration(seconds: 2), (_) => _emitDelta());
  }

  static const int _bettingSeconds = 30;
  static const int _matchSeconds = 12;

  final StreamController<List<VoltaWireEvent>> _controller =
      StreamController<List<VoltaWireEvent>>.broadcast();
  final Random _random = Random(20260912);

  Timer? _tick;
  Timer? _finish;
  int _eventId = 326039;
  int _startSecond = 0;
  int _finishSecond = 0;
  int _homeStake = 0;
  int _awayStake = 0;
  int _homePlayers = 0;
  int _awayPlayers = 0;

  @override
  Stream<List<VoltaWireEvent>> get batches => _controller.stream;

  @override
  Future<void> refresh() async => _emitDelta();

  @override
  void setActive(bool active) {
    if (active) {
      _tick ??= Timer.periodic(
        const Duration(seconds: 2),
        (_) => _emitDelta(),
      );
      return;
    }
    _tick?.cancel();
    _tick = null;
  }

  @override
  Future<void> dispose() async {
    _tick?.cancel();
    _finish?.cancel();
    await _controller.close();
  }

  int get _now => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  void _emitRound() {
    _eventId++;
    _startSecond = _now + _bettingSeconds;
    _finishSecond = _startSecond + _matchSeconds;
    _homeStake = 800000000 + _random.nextInt(100000000);
    _awayStake = 800000000 + _random.nextInt(100000000);
    _homePlayers = 9000 + _random.nextInt(2000);
    _awayPlayers = 9000 + _random.nextInt(2000);
    _push(won: 0);

    _finish?.cancel();
    _finish = Timer(
      Duration(seconds: _finishSecond - _now + 1),
      () {
        _push(won: _random.nextBool() ? 1 : 2);
        _finish = Timer(const Duration(seconds: 4), _emitRound);
      },
    );
  }

  void _emitDelta() {
    if (_startSecond == 0 || _now > _startSecond) return;
    _homeStake += _random.nextInt(5000000);
    _awayStake += _random.nextInt(5000000);
    _homePlayers += _random.nextInt(30);
    _awayPlayers += _random.nextInt(30);
    _push(won: 0);
  }

  void _push({required int won}) {
    if (_controller.isClosed) return;
    _controller.add(<VoltaWireEvent>[
      VoltaWireEvent(
        eventId: _eventId,
        home: 'Manchester Utd',
        away: 'Real Madrid FC',
        startSecond: _startSecond,
        finishSecond: _finishSecond,
        won: won,
        matchType: 4,
        homeStake: _homeStake,
        awayStake: _awayStake,
        homePlayers: _homePlayers,
        awayPlayers: _awayPlayers,
        odds: const VoltaWireOdds(
          homeOdds: 1.98,
          awayOdds: 1.98,
          homeSelectionId: 'demo-home',
          awaySelectionId: 'demo-away',
          offerId: 'demo-offer',
        ),
      ),
    ]);
  }
}

class VoltaRestEventSource implements VoltaEventSource {
  VoltaRestEventSource({Duration? pollInterval})
    : _pollInterval = pollInterval ?? defaultPollInterval {
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_fetch()));
    unawaited(_fetch());
  }

  static const Duration defaultPollInterval = Duration(seconds: 3);

  Duration _pollInterval;

  void setPollInterval(Duration value) {
    if (_disposed || value == _pollInterval) return;
    _pollInterval = value;
    if (_timer == null) return;
    _timer!.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_fetch()));
  }

  static const bool logEveryResponse = false;

  static const int _chunk = 800;

  static const int _isolateThreshold = 64 * 1024;

  final StreamController<List<VoltaWireEvent>> _controller =
      StreamController<List<VoltaWireEvent>>.broadcast();

  Timer? _timer;
  bool _inFlight = false;
  bool _disposed = false;

  @override
  Stream<List<VoltaWireEvent>> get batches => _controller.stream;

  @override
  Future<void> refresh() => _fetch();

  @override
  void setActive(bool active) {
    if (_disposed) return;
    if (!active) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (_timer != null) return;
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_fetch()));
    unawaited(_fetch());
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await _controller.close();
  }

  Future<void> _fetch() async {
    if (_inFlight || _disposed) return;
    if (!VoltaEndpoints.isReady) return;
    _inFlight = true;
    try {
      final dynamic raw = await VoltaHttp.get(
        VoltaEndpoints.snapshot(),
      ).timeout(VoltaRules.httpTimeout);
      final List<VoltaWireEvent> events = _decode(raw);
      _logResponse(raw, events);
      if (_disposed || _controller.isClosed) return;
      if (events.isEmpty) return;
      _controller.add(events);
    } on Object catch (e) {
      if (voltaDebug) {
        voltaLog(() => 'VoltaRestEventSource: lỗi gọi ${VoltaEndpoints.snapshot()}');
        voltaLog(() => 'VoltaRestEventSource: $e');
      }
    } finally {
      _inFlight = false;
    }
  }

  void _logResponse(dynamic raw, List<VoltaWireEvent> events) {
    if (!voltaDebug) return;

    final String body = raw is String ? raw : '$raw';
    final String kind = raw.runtimeType.toString();

    if (body.length >= _isolateThreshold) {
      voltaLog(() =>
        'VoltaRestEventSource: thân ${body.length} ký tự — vượt ngưỡng '
        '$_isolateThreshold. Giả định "payload nhỏ" không còn đúng, cân nhắc '
        'chuyển giải mã sang isolate (`compute`) như docs/17 §4.5.',
      );
    }
    voltaLog(() =>
      'VoltaRestEventSource: ${events.length} ván | thân $kind '
      '${body.length} ký tự | GET ${VoltaEndpoints.snapshot()}',
    );

    final bool first = !_loggedFullBody;
    if (!logEveryResponse && !first && events.isNotEmpty) return;
    _loggedFullBody = true;

    voltaLog(() => '--- Volta /volta response (đầy đủ) ---');
    for (int i = 0; i < body.length; i += _chunk) {
      final int end = i + _chunk < body.length ? i + _chunk : body.length;
      voltaLog(() => body.substring(i, end));
    }
    voltaLog(() => '--- hết response (${body.length} ký tự) ---');

    if (events.isNotEmpty) {
      final VoltaWireEvent e = events.first;
      voltaLog(() =>
        'VoltaRestEventSource: ván đầu — id=${e.eventId} '
        '"${e.home}" vs "${e.away}" '
        'start=${e.startSecond} finish=${e.finishSecond} won=${e.won} '
        'odds=${e.odds?.homeOdds}/${e.odds?.awayOdds} '
        'selection=${e.odds?.homeSelectionId}/${e.odds?.awaySelectionId}',
      );
    }
  }

  bool _loggedFullBody = false;

  static List<VoltaWireEvent> _decode(dynamic raw) {
    dynamic node = raw;
    for (int depth = 0; depth < 2 && node is String; depth++) {
      final String text = node.trim();
      if (text.isEmpty) return const <VoltaWireEvent>[];
      final Object? decoded = _tryJson(text);
      if (decoded == null) return const <VoltaWireEvent>[];
      node = decoded;
    }

    if (node is List<Object?>) return VoltaWire.decodeLeagues(node);
    if (node is! Map) return const <VoltaWireEvent>[];

    final Map<String, dynamic> body = node.cast<String, dynamic>();

    if (body.containsKey('t') && raw is String) {
      return VoltaWire.decodeFrame(raw);
    }

    for (final String key in const <String>['data', 'd', 'leagues', '0']) {
      final Object? wrapped = body[key];
      if (wrapped is List<Object?>) return VoltaWire.decodeLeagues(wrapped);
      if (wrapped is String) {
        final Object? inner = _tryJson(wrapped);
        if (inner is List<Object?>) return VoltaWire.decodeLeagues(inner);
      }
    }
    for (final Object? wrapped in body.values) {
      if (wrapped is List<Object?>) {
        final List<VoltaWireEvent> found = VoltaWire.decodeLeagues(wrapped);
        if (found.isNotEmpty) return found;
      }
    }
    return const <VoltaWireEvent>[];
  }

  static Object? _tryJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }
}

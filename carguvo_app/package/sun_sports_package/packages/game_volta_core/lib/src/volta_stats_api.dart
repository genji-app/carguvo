import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_models.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';
import 'volta_stats_models.dart';
import 'volta_wire.dart';

@immutable
class VoltaEventFairness {
  const VoltaEventFairness({required this.hash, required this.result});

  final String hash;

  final String result;

  bool get hasHash => hash.isNotEmpty;

  bool get hasResult => result.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaEventFairness &&
          other.hash == hash &&
          other.result == result;

  @override
  int get hashCode => Object.hash(hash, result);
}

@immutable
class VoltaMyStakeSnapshot {
  const VoltaMyStakeSnapshot({
    required this.eventId,
    required this.home,
    required this.away,
  });

  final int eventId;

  final int home;
  final int away;

  bool get isEmpty => home == 0 && away == 0;

  static VoltaMyStakeSnapshot? parse(
    Object? body, {
    required int fallbackEventId,
  }) {
    Object? at(int index) {
      if (body is List) {
        return index < body.length ? body[index] : null;
      }
      if (body is Map) {
        final Map<Object?, Object?> map = body;
        return map[index] ?? map['$index'];
      }
      return null;
    }

    if (body is! List && body is! Map) return null;

    return VoltaMyStakeSnapshot(
      eventId: VoltaStatsApi._asInt(at(1), fallback: fallbackEventId),
      home: VoltaStatsApi._asInt(at(3)),
      away: VoltaStatsApi._asInt(at(4)),
    );
  }

  @override
  String toString() =>
      'VoltaMyStakeSnapshot(event: $eventId, nhà: $home, khách: $away)';
}

class VoltaStatsApi {
  const VoltaStatsApi();

  Future<VoltaMyStakeSnapshot?> fetchMyStake(int eventId) async {
    if (!VoltaEndpoints.isReady || eventId <= 0) return null;
    try {
      final dynamic raw = await VoltaHttp.get(
        VoltaEndpoints.playerStats(eventId),
      ).timeout(VoltaRules.httpTimeout);
      final Object? body = VoltaHttp.decodeBody(raw);
      final VoltaMyStakeSnapshot? snap = VoltaMyStakeSnapshot.parse(
        body,
        fallbackEventId: eventId,
      );
      if (snap == null) {
        if (voltaDebug) {
          voltaLog(() =>
            'VoltaStatsApi: tiền của tôi — KHÔNG đọc được. '
            'thô=$raw · sau decode=${body.runtimeType} $body',
          );
        }
        return null;
      }
      if (voltaDebug) {
        voltaLog(() =>
          'VoltaStatsApi: tiền của tôi ⇐ ${VoltaEndpoints.playerStats(eventId)}'
          ' ⇒ $snap',
        );
      }
      return snap;
    } on Object catch (e) {
      if (voltaDebug) {
        voltaLog(() => 'VoltaStatsApi: tiền của tôi lỗi (event $eventId) — $e');
      }
      return null;
    }
  }

  static const int gridMaxTries = 5;
  static const Duration gridRetryDelay = Duration(seconds: 1);

  Future<VoltaStatsGrid?> fetchGrid() async {
    if (!VoltaEndpoints.isReady) return null;
    for (int attempt = 1; attempt <= gridMaxTries; attempt++) {
      final VoltaStatsGrid? grid = await _fetchGridOnce(attempt);
      if (grid != null && !grid.isEmpty) return grid;
      if (attempt < gridMaxTries) {
        await Future<void>.delayed(gridRetryDelay);
      }
    }
    if (voltaDebug) {
      voltaLog(() => '[VoltaHistory] hết $gridMaxTries lượt, lưới vẫn rỗng');
    }
    return null;
  }

  Future<VoltaStatsGrid?> _fetchGridOnce(int attempt) async {
    try {
      final dynamic raw = await VoltaHttp.get(
        VoltaEndpoints.statistics(),
      ).timeout(VoltaRules.httpTimeout);
      final Object? body = VoltaHttp.decodeBody(raw);
      final VoltaStatsGrid? grid = VoltaStatsGrid.parse(body);
      if ((grid == null || grid.isEmpty) && voltaDebug) {
        voltaLog(() =>
          'VoltaStatsApi: lần $attempt không đọc được lưới — '
          'url=${VoltaEndpoints.statistics()} body=$raw',
        );
      }
      if (voltaDebug) _logGrid(body, grid);
      return grid;
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaStatsApi: lần $attempt lưới lỗi — $e');
      return null;
    }
  }

  static void _logGrid(Object? body, VoltaStatsGrid? grid) {
    const String tag = '[VoltaHistory]';
    voltaLog(() => '$tag GET ${VoltaEndpoints.statistics()}');

    final String dump = '$body';
    voltaLog(() =>
      '$tag   thân thô: '
      '${dump.length > 300 ? '${dump.substring(0, 300)}…' : dump}',
    );

    if (grid == null) {
      voltaLog(() => '$tag   ⚠ KHÔNG parse được — lưới giữ nguyên dữ liệu cũ');
      return;
    }

    final List<VoltaWinner> oldToNew = grid.results;
    final List<VoltaWinner> newToOld = oldToNew.reversed.toList();
    String line(List<VoltaWinner> list) => list
        .take(20)
        .map((VoltaWinner w) => w == VoltaWinner.home ? 'N' : 'K')
        .join(' ');

    final int home =
        oldToNew.where((VoltaWinner w) => w == VoltaWinner.home).length;
    voltaLog(() =>
      '$tag   server trả ${oldToNew.length} ván · N = đội nhà, K = đội khách',
    );
    String ends(List<VoltaWinner> l) => l.length < 6
        ? line(l)
        : '${line(l.take(3).toList())} … ${line(l.skip(l.length - 3).toList())}';
    voltaLog(() => '$tag   mảng thô đầu…cuối: ${ends(oldToNew)}');
    voltaLog(() =>
      '$tag   ô trên-phải (viên đang nhấp nháy) PHẢI khớp phần tử CUỐI',
    );
    voltaLog(() => '$tag   mới→cũ (20 đầu): ${line(newToOld)}');
    voltaLog(() => '$tag   cũ→mới (20 đầu): ${line(oldToNew)}');
    voltaLog(() =>
      '$tag   nhà $home / khách ${oldToNew.length - home}'
      '  ·  server tự khai: ${grid.homeCount}/${grid.awayCount} '
      '(${grid.homePercent}% / ${grid.awayPercent}%)',
    );
    voltaLog(() =>
      '$tag   ⚠ % hiện trên màn KHÔNG lấy từ hai số của server — nó tính trên '
      '50 ô đang vẽ, theo bản gốc `VoltaPopup.ts:1506`',
    );
  }

  Future<VoltaEventStats?> fetchEvent(int eventId) async {
    if (!VoltaEndpoints.isReady) return null;
    final String url = VoltaEndpoints.eventStatistics(
      VoltaWire.voltaLeagueId,
      eventId,
    );
    try {
      final dynamic raw = await VoltaHttp.get(
        url,
      ).timeout(VoltaRules.httpTimeout);
      final VoltaEventStats? stats = _parseEvent(VoltaHttp.decodeBody(raw));
      if (stats == null && voltaDebug) {
        voltaLog(() => 'VoltaStatsApi: ván $eventId không đọc được — url=$url '
            'body=$raw');
      }
      return stats;
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaStatsApi: ván $eventId lỗi — $e');
      return null;
    }
  }

  @visibleForTesting
  static VoltaEventStats? parseForTest(Object? body) => _parseEvent(body);

  static VoltaEventStats? _parseEvent(Object? decoded) {
    if (decoded is! Map) return null;
    final Map<Object?, Object?> body = decoded;

    final String hash = _str(body['h'] ?? body['hash']);
    final String result = _str(body['r'] ?? body['result']);

    final Object? m = body['m'];
    final List<Object?> stats = m is List<Object?> ? m : const <Object?>[];

    final List<bool> homeForm = _form(_at(stats, 0));
    final List<bool> awayForm = _form(_at(stats, 1));
    final String homeName = _str(_at(stats, 6));
    final String awayName = _str(_at(stats, 7));

    if (hash.isEmpty &&
        result.isEmpty &&
        homeForm.isEmpty &&
        awayForm.isEmpty) {
      return null;
    }

    return VoltaEventStats(
      hash: hash,
      result: result,
      homeName: homeName,
      awayName: awayName,
      homeLogo: _url(body['1']),
      awayLogo: _url(body['2']),
      homeForm: homeForm,
      awayForm: awayForm,
    );
  }

  static List<bool> _form(Object? raw) {
    if (raw is! List) return const <bool>[];
    final List<bool> out = <bool>[
      for (final Object? item in raw) '$item'.trim().toUpperCase() == 'W',
    ];
    if (out.length <= VoltaRules.vsCells) {
      return List<bool>.unmodifiable(out);
    }
    return List<bool>.unmodifiable(
      out.sublist(out.length - VoltaRules.vsCells),
    );
  }

  static Object? _at(List<Object?> list, int index) =>
      index >= 0 && index < list.length ? list[index] : null;

  static String _str(Object? value) {
    if (value == null) return '';
    final String text = '$value';
    return text == 'null' ? '' : text;
  }

  static String? _url(Object? value) {
    final String text = _str(value).trim();
    return text.isEmpty ? null : text;
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }
}

import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_models.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';

@immutable
class VoltaBetRow {
  const VoltaBetRow({
    required this.ticketId,
    required this.matchId,
    required this.eventName,
    required this.homeTeam,
    required this.awayTeam,
    required this.side,
    required this.stake,
    required this.payout,
    required this.status,
    required this.placedAt,
    required this.winner,
  });

  final String ticketId;

  final String matchId;

  final String eventName;
  final String homeTeam;
  final String awayTeam;

  final VoltaSide? side;

  final int stake;

  final int payout;

  final String status;

  final DateTime? placedAt;

  final VoltaWinner winner;

  bool get isSettled => status.toLowerCase() == 'settled';

  bool get isWin => isSettled && payout > 0;

  int get signedAmount => isWin ? payout : -stake;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaBetRow &&
          other.ticketId == ticketId &&
          other.matchId == matchId &&
          other.eventName == eventName &&
          other.homeTeam == homeTeam &&
          other.awayTeam == awayTeam &&
          other.side == side &&
          other.stake == stake &&
          other.payout == payout &&
          other.status == status &&
          other.placedAt == placedAt &&
          other.winner == winner;

  @override
  int get hashCode => Object.hash(
    ticketId,
    matchId,
    eventName,
    homeTeam,
    awayTeam,
    side,
    stake,
    payout,
    status,
    placedAt,
    winner,
  );
}

class VoltaBetHistoryApi {
  const VoltaBetHistoryApi();

  Future<List<VoltaBetRow>> fetch({
    int size = VoltaRules.betHistoryFetchSize,
  }) async {
    if (!VoltaEndpoints.isReady) return const <VoltaBetRow>[];
    final String url = VoltaEndpoints.betHistory(size: size);
    try {
      final dynamic raw = await VoltaHttp.get(
        url,
      ).timeout(VoltaRules.httpTimeout);
      return parseBody(VoltaHttp.decodeBody(raw));
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaBetHistoryApi: lỗi — $e');
      return const <VoltaBetRow>[];
    }
  }

  @visibleForTesting
  static List<VoltaBetRow> parseBody(Object? decoded) {
    Object? node = decoded;
    if (node is List && node.length > 1) node = node[1];

    if (node is Map) {
      final Map<Object?, Object?> wrapper = node;
      for (final String key in const <String>['data', 'items', 'list']) {
        final Object? value = wrapper[key];
        if (value is List) {
          node = value;
          break;
        }
      }
    }

    final Object? rows = node;
    if (rows is! List) return const <VoltaBetRow>[];

    final List<VoltaBetRow> out = <VoltaBetRow>[];
    for (final Object? item in rows) {
      final VoltaBetRow? row = _rowOf(item);
      if (row != null) out.add(row);
    }
    return List<VoltaBetRow>.unmodifiable(out);
  }

  static VoltaBetRow? _rowOf(Object? item) {
    if (item is! List) return null;

    final String gameScore = _str(_at(item, 14));
    if (gameScore.isEmpty) return null;

    final String matchName = _str(_at(item, 17));
    final List<String> teams = _teamsOf(
      matchName.isNotEmpty ? matchName : _str(_at(item, 4)),
    );

    _noteStatus(_str(_at(item, 12)));

    return VoltaBetRow(
      ticketId: _str(_at(item, 0)),
      matchId: _str(_at(item, 30)),
      eventName: _cleanTeam(_str(_at(item, 4))),
      homeTeam: teams[0],
      awayTeam: teams[1],
      side: _sideOf(_str(_at(item, 5)), teams),
      stake: _int(_at(item, 9)),
      payout: _int(_at(item, 13)),
      status: _str(_at(item, 12)),
      placedAt: _dateOf(_at(item, 1)),
      winner: _winnerOf(gameScore),
    );
  }

  static final Set<String> _seenStatuses = <String>{};

  static void _noteStatus(String status) {
    if (!voltaDebug || status.isEmpty) return;
    final String value = status.trim().toLowerCase();
    if (value == 'settled' || value == 'active' || value == 'pending') return;
    if (!_seenStatuses.add(value)) return;
    voltaLog(() =>
      '🟠 Volta lịch sử cược: status LẠ "$status". Nếu đây là hoàn tiền thì '
      'VoltaBetRow.signedAmount đang hiện SAI DẤU — chốt với backend.',
    );
  }

  static String _cleanTeam(String name) =>
      name.replaceAll(RegExp(r'\s*\(VLT\)\s*'), ' ').trim();

  static List<String> _teamsOf(String matchName) {
    final String cleaned = _cleanTeam(matchName);
    for (final String sep in const <String>[' vs ', ' VS ', ' - ', ' v ']) {
      final int at = cleaned.indexOf(sep);
      if (at > 0) {
        return <String>[
          cleaned.substring(0, at).trim(),
          cleaned.substring(at + sep.length).trim(),
        ];
      }
    }
    return <String>[cleaned, ''];
  }

  static VoltaSide? _sideOf(String oddsName, List<String> teams) {
    final String value = oddsName.trim().toLowerCase();
    if (value.isEmpty) return null;
    if (value == 'home' || value.endsWith('h')) return VoltaSide.home;
    if (value == 'away' || value.endsWith('a')) return VoltaSide.away;
    final String home = teams[0].toLowerCase();
    final String away = teams[1].toLowerCase();
    if (home.isNotEmpty && value == home) return VoltaSide.home;
    if (away.isNotEmpty && value == away) return VoltaSide.away;
    return null;
  }

  static VoltaWinner _winnerOf(String gameScore) {
    final Match? m = RegExp(r'(\d+)\s*[-:]\s*(\d+)').firstMatch(gameScore);
    if (m == null) return VoltaWinner.unknown;
    final int home = int.tryParse(m.group(1)!) ?? 0;
    final int away = int.tryParse(m.group(2)!) ?? 0;
    if (home > away) return VoltaWinner.home;
    if (away > home) return VoltaWinner.away;
    return VoltaWinner.unknown;
  }

  static DateTime? _dateOf(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    final String text = _str(value);
    if (text.isEmpty) return null;
    final int? epoch = int.tryParse(text);
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch).toLocal();
    }
    return DateTime.tryParse(text)?.toLocal();
  }

  static Object? _at(List<Object?> row, int index) =>
      index >= 0 && index < row.length ? row[index] : null;

  static String _str(Object? value) {
    if (value == null) return '';
    final String text = '$value';
    return text == 'null' ? '' : text;
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return num.tryParse(value)?.round() ?? 0;
    return 0;
  }
}

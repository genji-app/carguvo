import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';

@immutable
class VoltaRankRow {
  const VoltaRankRow({required this.username, required this.winnings});

  final String username;

  final int winnings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaRankRow &&
          other.username == username &&
          other.winnings == winnings;

  @override
  int get hashCode => Object.hash(username, winnings);
}

class VoltaRankApi {
  const VoltaRankApi();

  Future<List<VoltaRankRow>> fetch({int size = VoltaRules.rankingSize}) async {
    final String url = VoltaEndpoints.ranking(size: size);
    try {
      final dynamic raw = await VoltaHttp.getPublic(
        url,
      ).timeout(VoltaRules.httpTimeout);
      final List<VoltaRankRow> rows = parseBody(VoltaHttp.decodeBody(raw));
      if (rows.isEmpty && voltaDebug) {
        voltaLog(() => 'VoltaRankApi: không đọc được bảng — url=$url body=$raw');
      }
      return rows;
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaRankApi: lỗi — $e');
      return const <VoltaRankRow>[];
    }
  }

  @visibleForTesting
  static List<VoltaRankRow> parseBody(Object? decoded) {
    final Object? list = _listOf(decoded);
    if (list is! List) return const <VoltaRankRow>[];

    final List<VoltaRankRow> out = <VoltaRankRow>[];
    for (final Object? item in list) {
      final VoltaRankRow? row = _rowOf(item);
      if (row != null) out.add(row);
    }
    return List<VoltaRankRow>.unmodifiable(out);
  }

  static Object? _listOf(Object? decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return null;
    final Map<Object?, Object?> body = decoded;
    for (final String key in const <String>['data', 'items', 'list', 'result']) {
      final Object? value = body[key];
      if (value is List) return value;
    }
    for (final Object? value in body.values) {
      if (value is List) return value;
    }
    return null;
  }

  static VoltaRankRow? _rowOf(Object? item) {
    if (item is! Map) return null;
    final Map<Object?, Object?> row = item;
    final String name = _str(
      row['name'] ?? row['userName'] ?? row['username'] ?? row['custLogin'],
    );
    if (name.isEmpty) return null;
    return VoltaRankRow(
      username: name,
      winnings: _int(row['score'] ?? row['winMoney'] ?? row['winnings']),
    );
  }

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

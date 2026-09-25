import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_models.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';
import 'volta_wire.dart';

class VoltaResultsApi {
  const VoltaResultsApi();

  static const int size = 20;

  static const int maxTries = 5;
  static const Duration retryDelay = Duration(seconds: 1);

  Future<List<VoltaMatchResult>> fetch() async {
    if (!VoltaEndpoints.isReady) return const <VoltaMatchResult>[];
    final String url = VoltaEndpoints.resultHistory(
      fromDate: DateTime.now(),
      size: size,
    );

    for (int attempt = 1; attempt <= maxTries; attempt++) {
      try {
        final dynamic raw = await VoltaHttp.get(
          url,
        ).timeout(VoltaRules.httpTimeout);
        final List<VoltaMatchResult> list = parse(VoltaHttp.decodeBody(raw));
        if (voltaDebug) {
          voltaLog(() =>
            '[VoltaResults] lần $attempt ⇒ ${list.length} ván · $url',
          );
        }
        if (list.isNotEmpty) return list;
      } on Object catch (e) {
        if (voltaDebug) voltaLog(() => '[VoltaResults] lần $attempt lỗi — $e');
      }
      if (attempt < maxTries) await Future<void>.delayed(retryDelay);
    }
    if (voltaDebug) voltaLog(() => '[VoltaResults] hết $maxTries lượt, vẫn rỗng');
    return const <VoltaMatchResult>[];
  }

  @visibleForTesting
  static List<VoltaMatchResult> parse(Object? decoded) {
    final Object? body = VoltaWire.normalizeIndexed(decoded);
    if (body is! List || body.length < 2) return const <VoltaMatchResult>[];
    final Object? rows = VoltaWire.normalizeIndexed(body[1]);
    if (rows is! List) return const <VoltaMatchResult>[];

    final List<VoltaMatchResult> out = <VoltaMatchResult>[];
    for (final Object? row in rows) {
      final Object? e = VoltaWire.normalizeIndexed(row);
      if (e is! List) continue;

      Object? at(int i) => i >= 0 && i < e.length ? e[i] : null;
      String str(int i) {
        final Object? v = at(i);
        return v is String ? v : '';
      }

      final Object? codes = VoltaWire.normalizeIndexed(at(13));
      String code(String key) {
        if (codes is Map) {
          final Object? v = codes[key];
          if (v is String) return v;
        }
        return '';
      }

      final DateTime? start = DateTime.tryParse(str(0));
      if (start == null) continue;

      final String homeName = str(2);
      final String winnerName = str(11);

      out.add(
        VoltaMatchResult(
          homeName: homeName,
          awayName: str(3),
          homeLogo: _logoOrNull(str(14)),
          awayLogo: _logoOrNull(str(15)),
          winner: winnerName.trim() == homeName.trim()
              ? VoltaWinner.home
              : VoltaWinner.away,
          finishedAt: start.toLocal(),
          md5Code: code('h'),
          resultCode: code('r'),
        ),
      );
    }
    return List<VoltaMatchResult>.unmodifiable(out);
  }

  static String? _logoOrNull(String value) =>
      value.trim().isEmpty ? null : value;
}

import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';

class VoltaLiveApi {
  const VoltaLiveApi();

  static const int maxTries = 5;

  static const Duration retryDelay = Duration(seconds: 2);

  Future<String?> fetchLink(int eventId) async {
    if (!VoltaEndpoints.isReady) return null;
    final String url = VoltaEndpoints.liveLink(eventId, brand: VoltaPlatform.instance.brand);

    for (int attempt = 1; attempt <= maxTries; attempt++) {
      try {
        final dynamic raw = await VoltaHttp.get(
          url,
        ).timeout(VoltaRules.httpTimeout);
        final Object? body = VoltaHttp.decodeBody(raw);
        final String? link = parseLink(body);
        if (voltaDebug) {
          final String dump = body.toString();
          voltaLog(() =>
            '[VoltaLive] ván $eventId lần $attempt ⇒ '
            '${dump.length > 300 ? '${dump.substring(0, 300)}…' : dump}',
          );
        }
        if (link != null && link.isNotEmpty) return link;
      } on Object catch (e) {
        if (voltaDebug) {
          voltaLog(() => 'VoltaLiveApi: ván $eventId lần $attempt lỗi — $e');
        }
      }
      if (attempt < maxTries) await Future<void>.delayed(retryDelay);
    }

    if (voltaDebug) {
      voltaLog(() =>
        'VoltaLiveApi: ván $eventId hết $maxTries lượt vẫn không có link — '
        'url=$url',
      );
    }
    return null;
  }

  @visibleForTesting
  static String? parseLink(Object? decoded) {
    if (decoded is String) return _clean(decoded);
    if (decoded is! Map) return null;
    final Map<Object?, Object?> body = decoded;

    for (final String key in const <String>[
      'url',
      'link',
      'liveLink',
      'streamUrl',
      'data',
    ]) {
      final Object? value = body[key];
      if (value is String) {
        final String? link = _clean(value);
        if (link != null) return link;
      }
      if (value is Map) {
        final String? nested = parseLink(value);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? _clean(String value) {
    final String text = value.trim();
    if (text.isEmpty || text == 'null') return null;
    if (!text.startsWith('http')) return null;
    return text;
  }
}

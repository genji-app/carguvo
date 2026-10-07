import 'dart:convert';

import 'package:sentry/sentry.dart';

const String _redacted = '***';

bool _isSensitiveHeaderKey(String key) {
  final k = key.toLowerCase();
  return k == 'authorization' ||
      k == 'cookie' ||
      k == 'set-cookie' ||
      k == 'proxy-authorization' ||
      k.startsWith('x-auth');
}

final RegExp _kvPattern = RegExp(
  r'''(authorization|token|ws_?token|access_?token|refresh_?token|password|passwd|secret|api_?key|cookie)(\s*["']?\s*[:=/]\s*["']?)[^"',}\s&;\]\)/]+''',
  caseSensitive: false,
);

final RegExp _bearerPattern = RegExp(r'Bearer\s+[\w.\-]+', caseSensitive: false);

final RegExp _jwtPattern = RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+');

String redactText(String input) {
  var out = input;
  out = out.replaceAllMapped(
    _kvPattern,
    (m) => '${m.group(1)}${m.group(2)}$_redacted',
  );
  out = out.replaceAll(_bearerPattern, 'Bearer $_redacted');
  out = out.replaceAll(_jwtPattern, _redacted);
  return out;
}

String _safeRedact(String s) {
  try {
    return redactText(s);
  } catch (_) {
    return s;
  }
}

dynamic _scrubValue(dynamic value) {
  try {
    if (value is String) return redactText(value);
    if (value is num || value is bool || value == null) return value;
    return redactText(jsonEncode(value));
  } catch (_) {
    return '<unserializable>';
  }
}

Map<String, dynamic> _scrubMap(Map<String, dynamic> map) {
  final out = <String, dynamic>{};
  map.forEach((k, v) {
    out[k] = _scrubValue(v);
  });
  return out;
}

SentryRequest _scrubRequest(SentryRequest r) {
  final url = r.url;
  if (url != null) r.url = _safeRedact(url);

  final queryString = r.queryString;
  if (queryString != null) r.queryString = _safeRedact(queryString);

  final cookies = r.cookies;
  if (cookies != null) r.cookies = _safeRedact(cookies);

  final headers = r.headers;
  if (headers.isNotEmpty) {
    final newHeaders = <String, String>{};
    headers.forEach((k, v) {
      newHeaders[k] = _isSensitiveHeaderKey(k) ? _redacted : _safeRedact(v);
    });
    r.headers = newHeaders;
  }

  return r;
}

SentryEvent scrubEvent(SentryEvent event) {
  try {
    final message = event.message;
    if (message != null) {
      message.formatted = _safeRedact(message.formatted);
    }

    final exceptions = event.exceptions;
    if (exceptions != null) {
      for (final ex in exceptions) {
        final v = ex.value;
        if (v != null) ex.value = _safeRedact(v);
      }
    }

    SentryRequest? request = event.request;
    if (request != null) {
      try {
        request = _scrubRequest(request);
      } catch (_) {
      }
    }

    // ignore: deprecated_member_use
    final extra = event.extra;

    event.message = message;
    event.exceptions = exceptions;
    event.request = request;
    if (extra != null) {
      // ignore: deprecated_member_use
      event.extra = _scrubMap(extra);
    }
    return event;
  } catch (_) {
    return event;
  }
}

Breadcrumb scrubBreadcrumb(Breadcrumb crumb) {
  try {
    final message = crumb.message;
    if (message != null) crumb.message = _safeRedact(message);

    final data = crumb.data;
    if (data != null) crumb.data = _scrubMap(data);

    return crumb;
  } catch (_) {
    return crumb;
  }
}

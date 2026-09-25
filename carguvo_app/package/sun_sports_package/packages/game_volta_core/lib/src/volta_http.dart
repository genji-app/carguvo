import 'dart:convert';

import 'volta_platform.dart';
import 'volta_wire.dart';

class VoltaHttpException implements Exception {
  VoltaHttpException(this.statusCode, this.message, {this.body});

  final int statusCode;
  final String message;
  final Object? body;

  @override
  String toString() => 'VoltaHttpException($statusCode): $message';
}

abstract class VoltaHttpTransport {
  const VoltaHttpTransport();

  Future<dynamic> get(String url);

  Future<dynamic> getText(String url);

  Future<dynamic> getPublic(String url);

  Future<dynamic> post(String url, String body, {required String language});
}

class VoltaDebugOverrides {
  const VoltaDebugOverrides._();

  static const String token = '';

  static bool get active => voltaDebug && token.isNotEmpty;
}

class VoltaHttp {
  const VoltaHttp._();

  static const String betLanguage = 'vi';

  static VoltaHttpTransport _transport = const _UninstalledTransport();

  static VoltaHttpTransport get transport => _transport;

  static void install(VoltaHttpTransport transport) => _transport = transport;

  static void reset() => _transport = const _UninstalledTransport();

  static Future<dynamic> get(String url) => _transport.get(url);

  static Future<dynamic> getText(String url) => _transport.getText(url);

  static Future<dynamic> getPublic(String url) => _transport.getPublic(url);

  static Future<dynamic> post(String url, String body) =>
      _transport.post(url, body, language: betLanguage);

  static Object? decodeBody(dynamic raw) {
    Object? node = raw;
    for (int depth = 0; depth < 2 && node is String; depth++) {
      final String text = node.trim();
      if (text.isEmpty) return null;
      try {
        node = jsonDecode(text);
      } on FormatException {
        return null;
      }
    }
    return VoltaWire.normalizeIndexed(node);
  }
}

class _UninstalledTransport extends VoltaHttpTransport {
  const _UninstalledTransport();

  Never _fail() => throw VoltaHttpException(
    0,
    'VoltaHttp: chưa cài transport. App chủ phải gọi VoltaHttp.install(...) '
    'trước khi mở màn Volta.',
  );

  @override
  Future<dynamic> get(String url) => _fail();

  @override
  Future<dynamic> getText(String url) => _fail();

  @override
  Future<dynamic> getPublic(String url) => _fail();

  @override
  Future<dynamic> post(String url, String body, {required String language}) =>
      _fail();
}

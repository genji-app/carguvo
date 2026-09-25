import 'package:flutter/foundation.dart';

enum SocketSubMode {
  sport,
  league;

  static const String rawValue =
      String.fromEnvironment('SOCKET_SUB_MODE', defaultValue: 'league');

  static final SocketSubMode _fromEnv = _parse(rawValue);

  @visibleForTesting
  static SocketSubMode? debugOverride;

  static SocketSubMode get current => debugOverride ?? _fromEnv;

  static SocketSubMode _parse(String raw) {
    switch (raw) {
      case 'sport':
        return SocketSubMode.sport;
      case 'league':
        return SocketSubMode.league;
      default:
        assert(
          false,
          'SOCKET_SUB_MODE="$raw" không hợp lệ (chỉ "sport"|"league") '
          '— fallback "league".',
        );
        if (kDebugMode) {
          debugPrint(
            '[SocketSubMode] ⚠️ giá trị lạ "$raw" → fallback league',
          );
        }
        return SocketSubMode.league;
    }
  }

  bool get isLeague => this == SocketSubMode.league;
}

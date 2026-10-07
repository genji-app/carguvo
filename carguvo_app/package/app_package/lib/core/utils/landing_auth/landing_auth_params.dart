import 'package:flutter/foundation.dart';

import 'package:auth_domain/auth_domain.dart'
    show LandingCredentials, parseLandingCredentials;

import 'landing_auth_hash_stub.dart'
    if (dart.library.js_interop) 'landing_auth_hash_web.dart';

export 'package:auth_domain/auth_domain.dart'
    show LandingCredentials, parseLandingCredentials, kMaxLandingHashLength;

LandingCredentials? parseAppLandingCredentials(String? raw) =>
    parseLandingCredentials(raw, log: debugPrint);

class LandingAuthSession {
  LandingAuthSession._();

  static LandingCredentials? _pending;
  static bool _captured = false;

  static void capture() {
    if (_captured) return;
    _captured = true;
    setBrandTabTitle();
    _pending = parseAppLandingCredentials(readAndClearLandingHash());
    debugPrint(
      _pending != null
          ? '🔑 [LandingAuth] Captured credentials for "${_pending!.username}"'
          : '🔑 [LandingAuth] No landing credentials in URL',
    );
  }

  static LandingCredentials? consume() {
    final c = _pending;
    _pending = null;
    return c;
  }
}

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web/web.dart' as web;

String? readAndClearLandingHash() {
  final loc = web.window.location;
  var hash = loc.hash;
  debugPrint('🔑 [LandingAuth] location.hash="$hash" href="${loc.href}"');
  if (hash.isEmpty) return null;
  if (hash.startsWith('#')) hash = hash.substring(1);
  if (hash.isEmpty) return null;

  final cleanUrl = '${loc.pathname}${loc.search}';
  web.window.history.replaceState(null, '', cleanUrl);

  return hash;
}

void setBrandTabTitle() {
  web.document.title = 'Sun88';
}

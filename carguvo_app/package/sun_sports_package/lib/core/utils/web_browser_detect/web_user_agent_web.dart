library;

import 'package:web/web.dart' as web;

String? get webUserAgent {
  try {
    return web.window.navigator.userAgent;
  } catch (_) {
    return null;
  }
}

int get webMaxTouchPoints {
  try {
    return web.window.navigator.maxTouchPoints;
  } catch (_) {
    return 0;
  }
}

String? get webPageUrl {
  try {
    return web.window.location.href;
  } catch (_) {
    return null;
  }
}

String get webPageBaseUrl {
  try {
    final location = web.window.location;
    final base = '${location.origin}${location.pathname}';
    return base.endsWith('/') ? base : '$base/';
  } catch (_) {
    return '';
  }
}

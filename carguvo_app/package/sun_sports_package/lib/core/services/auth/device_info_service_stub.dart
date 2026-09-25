import 'package:web/web.dart' as web;

Future<String> getDeviceOsVersion() async {
  try {
    final userAgent = web.window.navigator.userAgent;
    return _parseBrowserVersion(userAgent);
  } catch (e) {
    return 'Web';
  }
}

String _parseBrowserVersion(String userAgent) {
  final chromeMatch = RegExp(
    r'Chrome/(\d+\.\d+\.\d+\.\d+)',
  ).firstMatch(userAgent);
  if (chromeMatch != null) {
    return 'chrome ${chromeMatch.group(1)}';
  }

  final safariMatch = RegExp(
    r'Version/(\d+\.\d+).*Safari',
  ).firstMatch(userAgent);
  if (safariMatch != null) {
    return 'safari ${safariMatch.group(1)}';
  }

  final firefoxMatch = RegExp(r'Firefox/(\d+\.\d+)').firstMatch(userAgent);
  if (firefoxMatch != null) {
    return 'firefox ${firefoxMatch.group(1)}';
  }

  final edgeMatch = RegExp(r'Edg/(\d+\.\d+\.\d+\.\d+)').firstMatch(userAgent);
  if (edgeMatch != null) {
    return 'edge ${edgeMatch.group(1)}';
  }

  return 'Web';
}

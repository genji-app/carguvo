import 'package:web/web.dart' as web;

Future<bool> openExternalAfter({
  required String url,
  required Future<bool> Function() task,
  bool sameTab = false,
}) async {
  if (sameTab) {
    final ok = await task();
    if (ok) web.window.location.href = url;
    return ok;
  }

  final handle = web.window.open('', '_blank');
  bool ok = false;
  try {
    ok = await task();
  } finally {
    if (ok) {
      if (handle != null) {
        handle.location.href = url;
      } else {
        web.window.open(url, '_blank');
      }
    } else {
      handle?.close();
    }
  }
  return ok;
}

import 'package:web/web.dart' as web;

import 'ncc_tab_opener.dart';

NccPendingTab? openPendingTabImpl() {
  final win = web.window.open('redirecting.html', '_blank');
  if (win == null) return null;
  return _WebPendingTab(win);
}

class _WebPendingTab implements NccPendingTab {
  _WebPendingTab(this._win);

  final web.Window _win;

  @override
  void navigate(String url) => _win.location.replace(url);

  @override
  void close() => _win.close();
}

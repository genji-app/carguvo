import 'ncc_tab_opener_stub.dart'
    if (dart.library.js_interop) 'ncc_tab_opener_web.dart';

abstract interface class NccPendingTab {
  void navigate(String url);

  void close();
}

NccPendingTab? openPendingTab() => openPendingTabImpl();

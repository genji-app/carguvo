import 'dart:js_interop';

import 'package:web/web.dart' as web;

mixin WebMessageListenerMixin {
  JSExportedDartFunction? _messageListener;

  void onMessageReceive(dynamic data) {}

  void registerWebMessageListener() {
    if (_messageListener != null) return;

    _messageListener = (web.Event event) {
      if (!event.isA<web.MessageEvent>()) return;

      final messageEvent = event as web.MessageEvent;
      onMessageReceive(messageEvent.data?.dartify());
    }.toJS;

    web.window.addEventListener('message', _messageListener);
  }

  void unregisterWebMessageListener() {
    if (_messageListener == null) return;
    web.window.removeEventListener('message', _messageListener);
    _messageListener = null;
  }
}

import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

mixin IFrameCrashDetectionMixin<T extends StatefulWidget> on State<T> {
  web.EventHandler? _errorHandler;
  web.EventHandler? _rejectionHandler;
  web.EventHandler? _pagehideHandler;
  web.EventHandler? _visibilityHandler;

  void onTopLevelJsError(web.Event event);

  void onUnhandledPromiseRejection(web.Event event);

  void onPageHide(web.Event event);

  void onVisibilityChange(String visibilityState);

  void installCrashDetection() {
    final window = web.window;

    void errorHandler(web.Event event) {
      onTopLevelJsError(event);
    }

    _errorHandler = errorHandler.toJS;
    window.addEventListener('error', _errorHandler);

    void rejectionHandler(web.Event event) {
      onUnhandledPromiseRejection(event);
    }

    _rejectionHandler = rejectionHandler.toJS;
    window.addEventListener('unhandledrejection', _rejectionHandler);

    void pagehideHandler(web.Event event) {
      onPageHide(event);
    }

    _pagehideHandler = pagehideHandler.toJS;
    window.addEventListener('pagehide', _pagehideHandler);

    void visibilityHandler(web.Event event) {
      onVisibilityChange(web.document.visibilityState);
    }

    _visibilityHandler = visibilityHandler.toJS;
    web.document.addEventListener('visibilitychange', _visibilityHandler);
  }

  void removeCrashDetection() {
    final window = web.window;
    if (_errorHandler != null) {
      window.removeEventListener('error', _errorHandler);
    }
    if (_rejectionHandler != null) {
      window.removeEventListener('unhandledrejection', _rejectionHandler);
    }
    if (_pagehideHandler != null) {
      window.removeEventListener('pagehide', _pagehideHandler);
    }
    if (_visibilityHandler != null) {
      web.document.removeEventListener('visibilitychange', _visibilityHandler);
    }
  }
}

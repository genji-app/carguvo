import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../../platform_ui/platform_ui.dart';
import 'dom_fullscreen_strategy.dart';
import 'fullscreen_strategy.dart';
import 'pwa_standalone_strategy.dart';
import 'safari_minimal_ui_strategy.dart';
import 'web_mobile_bypass_strategy.dart';

FullscreenStrategy createFullscreenStrategy(PlatformUiController platformUi) {
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  if (isWebMobile && !_isPwaStandalone()) {
    return WebMobileBypassStrategy();
  }

  if (_isPwaStandalone()) {
    return PwaStandaloneStrategy();
  }

  if (_supportsDomFullscreen()) {
    return DomFullscreenStrategy();
  }

  return SafariMinimalUiStrategy();
}

bool _isPwaStandalone() {
  try {
    return web.window.matchMedia('(display-mode: standalone)').matches;
  } on Object catch (_) {
    return false;
  }
}

bool _supportsDomFullscreen() {
  try {
    final element = web.document.documentElement;
    if (element == null) return false;

    final method = (element as JSObject).getProperty<JSAny?>('requestFullscreen'.toJS);
    return method != null;
  } on Object catch (_) {
    return false;
  }
}

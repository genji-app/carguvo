import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

mixin IFrameDimensionLockMixin<T extends StatefulWidget> on State<T> {
  Timer? _maxStabilizationTimer;

  Timer? _postLoadUnlockTimer;

  bool _isDimensionLocked = false;

  static const _kMaxStabilizationDuration = Duration(seconds: 15);

  static const _kPostLoadBuffer = Duration(seconds: 2);

  void removeDimensionLockTimers() {
    _maxStabilizationTimer?.cancel();
    _postLoadUnlockTimer?.cancel();
  }

  // ignore: unused_element
  void lockIframeDimensions(web.HTMLIFrameElement? iframe) {
    if (iframe == null || !mounted) return;

    final rect = iframe.getBoundingClientRect();
    final w = rect.width.toInt();
    final h = rect.height.toInt();

    if (w <= 0 || h <= 0) {
      web.console.warn(
        'Iframe has zero dimensions ($w x $h), skipping stabilization.'.toJS,
      );
      return;
    }

    iframe.style.width = '${w}px';
    iframe.style.height = '${h}px';
    _isDimensionLocked = true;
    web.console.log('Iframe dimensions locked: ${w}x$h'.toJS);

    _maxStabilizationTimer = Timer(
      _kMaxStabilizationDuration,
      () => unlockIframeDimensions(iframe),
    );
  }

  // ignore: unused_element
  void schedulePostLoadUnlock(web.HTMLIFrameElement? iframe) {
    if (!_isDimensionLocked) return;

    _postLoadUnlockTimer?.cancel();

    _postLoadUnlockTimer = Timer(
      _kPostLoadBuffer,
      () => unlockIframeDimensions(iframe),
    );
    web.console.log(
      'Iframe load detected, scheduling unlock in ${_kPostLoadBuffer.inSeconds}s.'.toJS,
    );
  }

  void unlockIframeDimensions(web.HTMLIFrameElement? iframe) {
    _maxStabilizationTimer?.cancel();
    _postLoadUnlockTimer?.cancel();
    if (iframe == null || !mounted || !_isDimensionLocked) return;

    iframe.style.width = '100%';
    iframe.style.height = '100%';
    _isDimensionLocked = false;
    web.console.log('Iframe dimensions unlocked to responsive.'.toJS);
  }
}

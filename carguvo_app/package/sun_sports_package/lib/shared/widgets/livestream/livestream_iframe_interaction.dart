import 'dart:async';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop' as js_interop;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

@js_interop.JS('window.focus')
external void _windowFocus();

class LivestreamIframeInteraction {
  LivestreamIframeInteraction({
    required this.iframeProvider,
    this.interactionWindow = const Duration(seconds: 1),
    this.hintText = '',
  });

  final html.IFrameElement? Function() iframeProvider;

  final Duration interactionWindow;

  final String hintText;

  static const double _dragSlop = 12.0;

  bool _interactive = false;
  Timer? _timer;
  html.EventListener? _blurListener;
  html.DivElement? _hintElement;
  Timer? _hintTimer;

  Timer? _positionWatch;

  Offset? _downPosition;

  Offset? _anchorSlotTopLeft;

  static const double _slotMoveSlop = 12.0;

  bool get isInteractive => _interactive;

  void applyDefault(html.IFrameElement iframe) {
    iframe.style.pointerEvents = 'none';
    _reset();
  }

  void onSlotPointerDown(Offset position) {
    final iframe = iframeProvider();
    if (iframe == null) return;
    _downPosition = position;
    iframe.style.pointerEvents = 'auto';
    _interactive = true;
    final rect = iframe.getBoundingClientRect();
    _anchorSlotTopLeft = Offset(rect.left.toDouble(), rect.top.toDouble());
    _restartTimer();
    _installBlurListener();
    _startPositionWatch();
  }

  void _startPositionWatch() {
    _positionWatch?.cancel();
    _positionWatch = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_interactive || _downPosition != null) return;
      final iframe = iframeProvider();
      final anchor = _anchorSlotTopLeft;
      if (iframe == null || anchor == null) return;
      final rect = iframe.getBoundingClientRect();
      final topLeft = Offset(rect.left.toDouble(), rect.top.toDouble());
      if ((topLeft - anchor).distance > _slotMoveSlop) deactivate();
    });
  }

  void onSlotPointerMove(Offset position) {
    final down = _downPosition;
    if (down == null) return;
    if ((position - down).distance > _dragSlop) {
      _downPosition = null;
      deactivate();
    }
  }

  void onSlotPointerUp() {
    if (_downPosition == null) return;
    _downPosition = null;
    if (!_interactive) return;
    _restartTimer();
    final iframe = iframeProvider();
    if (iframe != null) _showHint(iframe);
    debugPrint(
      '[LS-Interaction] activated (${interactionWindow.inSeconds}s)',
    );
  }

  void onSlotPointerCancel() {
    _downPosition = null;
    deactivate();
  }

  void deactivate() {
    _reset();
    final iframe = iframeProvider();
    if (iframe == null) return;
    if (iframe.style.pointerEvents != 'none') {
      iframe.style.pointerEvents = 'none';
      debugPrint('[LS-Interaction] deactivated → chế độ cuộn');
    }
  }

  void notifySlotMoved(Offset slotTopLeft) {
    if (!_interactive || _downPosition != null) return;
    final anchor = _anchorSlotTopLeft;
    if (anchor == null) return;
    if ((slotTopLeft - anchor).distance > _slotMoveSlop) {
      deactivate();
    }
  }

  void dispose() {
    deactivate();
  }

  void _reset() {
    _interactive = false;
    _downPosition = null;
    _anchorSlotTopLeft = null;
    _timer?.cancel();
    _timer = null;
    _positionWatch?.cancel();
    _positionWatch = null;
    _removeBlurListener();
    _removeHint();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(interactionWindow, deactivate);
  }

  void _installBlurListener() {
    if (_blurListener != null) return;
    _blurListener = (html.Event _) {
      if (!_interactive) return;
      final iframe = iframeProvider();
      if (iframe == null) return;
      if (html.document.activeElement == iframe) {
        _restartTimer();
        Timer(const Duration(milliseconds: 250), () {
          if (!_interactive) return;
          try {
            _windowFocus();
          } catch (_) {}
        });
      }
    };
    html.window.addEventListener('blur', _blurListener);
  }

  void _removeBlurListener() {
    if (_blurListener != null) {
      html.window.removeEventListener('blur', _blurListener);
      _blurListener = null;
    }
  }

  void _showHint(html.IFrameElement iframe) {
    if (hintText.isEmpty) return;
    _removeHint();
    final rect = iframe.getBoundingClientRect();
    final hint = html.DivElement()
      ..text = hintText
      ..style.position = 'fixed'
      ..style.left = '${rect.left + rect.width / 2}px'
      ..style.top = '${rect.top + rect.height - 16}px'
      ..style.transform = 'translate(-50%, -100%)'
      ..style.zIndex = '100001'
      ..style.pointerEvents = 'none'
      ..style.background = 'rgba(0, 0, 0, 0.65)'
      ..style.color = '#FFFFFF'
      ..style.padding = '5px 12px'
      ..style.borderRadius = '14px'
      ..style.fontSize = '12px'
      ..style.fontFamily = 'inherit'
      ..style.whiteSpace = 'nowrap'
      ..style.transition = 'opacity 0.25s ease'
      ..style.opacity = '1';
    html.document.body?.append(hint);
    _hintElement = hint;
    _hintTimer = Timer(const Duration(milliseconds: 500), () {
      hint.style.opacity = '0';
      _hintTimer = Timer(const Duration(milliseconds: 100), _removeHint);
    });
  }

  void _removeHint() {
    _hintTimer?.cancel();
    _hintTimer = null;
    _hintElement?.remove();
    _hintElement = null;
  }
}

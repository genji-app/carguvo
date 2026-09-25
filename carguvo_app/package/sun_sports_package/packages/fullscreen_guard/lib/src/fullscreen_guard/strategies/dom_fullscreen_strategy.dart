import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'fullscreen_strategy.dart';

class DomFullscreenStrategy implements FullscreenStrategy {
  DomFullscreenStrategy() {
    _notifier = ValueNotifier<bool>(_isCurrentlyFullscreen);
    _handler = _handleFullscreenChange.toJS;
    web.document.addEventListener('fullscreenchange', _handler);
    web.document.addEventListener('webkitfullscreenchange', _handler);
  }

  late final ValueNotifier<bool> _notifier;
  late final web.EventHandler _handler;

  @override
  String get name => 'DomFullscreen';

  @override
  ValueListenable<bool> get isFullscreen => _notifier;

  @override
  bool get needsUserGesture => true;

  bool get _isCurrentlyFullscreen {
    try {
      return web.document.fullscreenElement != null;
    } on Object catch (_) {
      return false;
    }
  }

  void _handleFullscreenChange(web.Event _) {
    _notifier.value = _isCurrentlyFullscreen;
  }

  @override
  Future<bool> enter() async {
    try {
      web.document.documentElement?.requestFullscreen();
      _blockScroll();
      return true;
    } on Object catch (e) {
      debugPrint('[DomFullscreenStrategy] requestFullscreen failed: $e');
      return false;
    }
  }

  @override
  Future<void> exit() async {
    try {
      if (_isCurrentlyFullscreen) {
        web.document.exitFullscreen();
      }
      _unblockScroll();
      web.window.scrollTo(0.toJS, 0);
    } on Object catch (_) {
    }
  }

  void _blockScroll() {
    try {
      web.document.documentElement?.setAttribute(
        'style',
        'overflow: hidden',
      );
    } on Object catch (_) {}
  }

  void _unblockScroll() {
    try {
      web.document.documentElement?.removeAttribute('style');
    } on Object catch (_) {}
  }

  @override
  void dispose() {
    web.document.removeEventListener('fullscreenchange', _handler);
    web.document.removeEventListener('webkitfullscreenchange', _handler);
    _notifier.dispose();
  }

  @override
  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) =>
      null;

  @override
  void teardownGate() {}
}

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'fullscreen_strategy.dart';

class SafariMinimalUiStrategy implements FullscreenStrategy {
  SafariMinimalUiStrategy() {
    _notifier = ValueNotifier<bool>(false);
    _resizeHandler = _handleWindowResize.toJS;
    web.window.addEventListener('resize', _resizeHandler);
  }

  late final ValueNotifier<bool> _notifier;
  late final web.EventHandler _resizeHandler;

  int _minimalUiTargetHeight = 0;
  web.HTMLDivElement? _nativeSwipeOverlay;
  JSFunction? _scrollListener;
  bool _skipProgrammaticScroll = false;
  web.HTMLElement? _glassPane;
  VoidCallback? _onCancelCallback;

  @override
  String get name => 'SafariMinimalUI';

  @override
  ValueListenable<bool> get isFullscreen => _notifier;

  @override
  bool get needsUserGesture => true;

  void _log(String message) {
    debugPrint('[SafariMinimalUiStrategy] $message');
  }

  void _handleWindowResize(web.Event _) {
    if (_notifier.value) {
      if (_minimalUiTargetHeight > 0 && web.window.innerHeight < _minimalUiTargetHeight - 30) {
        _log('Lost Minimal UI (innerHeight shrank).');
        _notifier.value = false;
        exit();
      }
    }
  }

  @override
  Future<bool> enter() async {
    _scrollTrick();
    _notifier.value = true;
    return true;
  }

  @override
  Future<void> exit() async {
    _notifier.value = false;
    _unblockScroll();
    web.window.scrollTo(0.toJS, 0);
  }

  @override
  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) {
    _prepareNativeSwipeOverlay(onSatisfied, onCancel: onCancel);
    return const GateSetup(requiresNativeSwipe: true);
  }

  @override
  void teardownGate() {
    _disableNativeSwipeOverlay();
  }

  @override
  void dispose() {
    web.window.removeEventListener('resize', _resizeHandler);
    _notifier.dispose();
  }

  void _scrollTrick() {
    try {
      final htmlEl = web.document.documentElement as web.HTMLElement?;
      final body = web.document.body;
      if (htmlEl == null || body == null) return;

      htmlEl.style.overflow = 'auto';
      body.style.minHeight = '150vh';

      // ignore: unnecessary_statements
      body.offsetHeight;

      if (!_skipProgrammaticScroll) {
        web.window.scrollTo(0.toJS, 100);

        _dispatchDelayedResize(const Duration(milliseconds: 100));
        _dispatchDelayedResize(const Duration(milliseconds: 300));
        _dispatchDelayedResize(const Duration(milliseconds: 650));
        _dispatchDelayedResize(const Duration(milliseconds: 1200));

        Future.delayed(const Duration(milliseconds: 1300), () {
          _setCanvasStretch(false);
        });
      }

      Future.delayed(const Duration(milliseconds: 600), () {
        _minimalUiTargetHeight = web.window.innerHeight;
      });
    } on Object catch (_) {}
  }

  void _unblockScroll() {
    try {
      web.document.documentElement?.removeAttribute('style');
      final body = web.document.body;
      if (body != null) {
        body.style.minHeight = '';
        body.style.removeProperty('height');
        body.style.removeProperty('overflow');
      }
      final pane = web.document.querySelector('flt-glass-pane') as web.HTMLElement?;
      if (pane != null) {
        pane.style.removeProperty('width');
        pane.style.removeProperty('height');
      }
    } on Object catch (_) {}
  }

  void _prepareNativeSwipeOverlay(VoidCallback onScrolled, {VoidCallback? onCancel}) {
    _onCancelCallback = onCancel;
    final htmlEl = web.document.documentElement as web.HTMLElement?;
    final body = web.document.body;
    if (htmlEl == null || body == null) return;

    htmlEl.style.setProperty('overflow', 'auto', 'important');
    body.style.setProperty('overflow', 'auto', 'important');
    body.style.setProperty('height', '200vh', 'important');
    body.style.setProperty('min-height', '200vh', 'important');

    _glassPane = web.document.querySelector('flt-glass-pane') as web.HTMLElement?;
    if (_glassPane != null) {
      _glassPane!.style.setProperty('pointer-events', 'none', 'important');
      _glassPane!.style.setProperty('height', '100lvh', 'important');
      web.window.dispatchEvent(web.Event('resize'));
      _setCanvasStretch(true);
    }

    if (_nativeSwipeOverlay == null) {
      _nativeSwipeOverlay = web.document.createElement('div') as web.HTMLDivElement;
      _nativeSwipeOverlay!.style.position = 'fixed';
      _nativeSwipeOverlay!.style.top = '0';
      _nativeSwipeOverlay!.style.left = '0';
      _nativeSwipeOverlay!.style.width = '100vw';
      _nativeSwipeOverlay!.style.height = '100vh';
      _nativeSwipeOverlay!.style.zIndex = '999999';
      _nativeSwipeOverlay!.style.touchAction = 'pan-y';
      _nativeSwipeOverlay!.style.backgroundColor = 'transparent';

      if (onCancel != null) {
        final backBtn = web.document.createElement('div');
        backBtn.setAttribute(
          'style',
          'position:absolute;top:60px;left:16px;padding:10px 16px;'
              'background:rgba(255,255,255,0.15);border-radius:12px;color:white;'
              'font-size:16px;cursor:pointer;backdrop-filter:blur(8px);'
              '-webkit-backdrop-filter:blur(8px);user-select:none;',
        );
        backBtn.textContent = '\u2190 Back';
        backBtn.addEventListener(
          'click',
          ((web.Event e) {
            e.stopPropagation();
            _setCanvasStretch(false);
            _disableNativeSwipeOverlay();
            _onCancelCallback?.call();
          }).toJS,
        );
        _nativeSwipeOverlay!.appendChild(backBtn);
      }

      web.document.body!.appendChild(_nativeSwipeOverlay!);

      _nativeSwipeOverlay!.addEventListener(
        'click',
        ((web.Event e) {
          _disableNativeSwipeOverlay();
          onScrolled();
        }).toJS,
      );
    } else {
      _nativeSwipeOverlay!.style.display = 'block';
    }

    _scrollListener = (web.Event e) {
      if (web.window.scrollY > 50) {
        _skipProgrammaticScroll = true;
        _disableNativeSwipeOverlay();
        onScrolled();
        Future.delayed(const Duration(milliseconds: 700), () {
          _skipProgrammaticScroll = false;
        });
        _dispatchDelayedResize(const Duration(milliseconds: 100));
        _dispatchDelayedResize(const Duration(milliseconds: 650));
        Future.delayed(const Duration(milliseconds: 1300), () {
          _setCanvasStretch(false);
        });
      }
    }.toJS;

    web.window.addEventListener('scroll', _scrollListener!);
  }

  void _disableNativeSwipeOverlay() {
    if (_glassPane != null) {
      _glassPane!.style.removeProperty('pointer-events');
      _glassPane = null;
    }
    if (_nativeSwipeOverlay != null) {
      try {
        web.document.body!.removeChild(_nativeSwipeOverlay!);
      } on Object catch (_) {}
      _nativeSwipeOverlay = null;
    }
    if (_scrollListener != null) {
      web.window.removeEventListener('scroll', _scrollListener!);
      _scrollListener = null;
    }
    _onCancelCallback = null;
  }

  void _dispatchDelayedResize(Duration delay) {
    Future.delayed(delay, () {
      try {
        web.window.visualViewport?.dispatchEvent(web.Event('resize'));
        web.window.dispatchEvent(web.Event('resize'));
      } on Object catch (_) {}
    });
  }

  void _setCanvasStretch(bool stretch) {
    void applyToElement(web.Element element) {
      if (element is web.HTMLElement && element.tagName.toLowerCase() == 'canvas') {
        if (stretch) {
          element.style.setProperty('height', '100lvh', 'important');
          element.style.setProperty('width', '100vw', 'important');
        } else {
          element.style.removeProperty('height');
          element.style.removeProperty('width');
        }
      }
    }

    final canvases = web.document.getElementsByTagName('canvas');
    for (int i = 0; i < canvases.length; i++) {
      applyToElement(canvases.item(i) as web.Element);
    }

    final flutterView = web.document.querySelector('flutter-view');
    if (flutterView != null && flutterView.shadowRoot != null) {
      final shadowCanvases = flutterView.shadowRoot!.querySelectorAll('canvas');
      for (int i = 0; i < shadowCanvases.length; i++) {
        applyToElement(shadowCanvases.item(i) as web.Element);
      }
    }
  }
}

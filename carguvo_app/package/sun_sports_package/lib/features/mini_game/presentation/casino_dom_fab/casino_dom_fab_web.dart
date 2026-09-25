import 'dart:js_interop';
import 'dart:ui' show Rect;

import 'package:web/web.dart' as web;

class CasinoDomFab {
  CasinoDomFab._();

  static final instance = CasinoDomFab._();

  static const _frontClass = 's88-mini-front';

  static const _interactiveClass = 's88-mini-interactive';

  static const _hitId = 's88-casino-mini-hit';

  web.HTMLElement? _hit;

  void enterCasinoEmbed() {
    web.document.documentElement!.classList.add(_frontClass);
  }

  void exitCasinoEmbed() {
    web.document.documentElement!.classList
      ..remove(_frontClass)
      ..remove(_interactiveClass);
    hideHitArea();
    stopToolbarWatch();
  }

  static const _dragSlop = 8.0;

  bool _dragging = false;
  double? _startX, _startY, _originLeft, _originTop;

  double _clampW = 0;
  double _clampH = 0;

  void showHitArea({
    required double width,
    required double height,
    required void Function() onTap,
    required void Function(double left, double top) onDrag,
    double? dragClampHeight,
    List<Rect> excludeRects = const [],
    double? right,
    double? bottom,
    double? left,
    double? top,
  }) {
    _clampW = width;
    _clampH = dragClampHeight ?? height;
    final creating = _hit == null;
    final el =
        _hit ?? (web.document.createElement('div') as web.HTMLElement..id = _hitId);

    if (!_dragging) {
      final pos = (left != null && top != null)
          ? 'left:${left}px;top:${top}px;'
          : 'right:${right ?? 12}px;'
                'bottom:calc(${bottom ?? 12}px + env(safe-area-inset-bottom));';
      el.setAttribute(
        'style',
        'position:fixed;'
        '$pos'
        'width:${width}px;'
        'height:${height}px;'
        'z-index:30;'
        'background:transparent;'
        '-webkit-tap-highlight-color:transparent;'
        'touch-action:none;',
      );
    }

    _applyExcludeHoles(el, width, height, excludeRects);

    if (!creating) return;

    el.addEventListener(
      'touchstart',
      (web.TouchEvent e) {
        final t = e.touches.item(0);
        if (t == null) return;
        _dragging = false;
        _startX = t.clientX.toDouble();
        _startY = t.clientY.toDouble();
        final r = el.getBoundingClientRect();
        _originLeft = r.left.toDouble();
        _originTop = r.top.toDouble();
      }.toJS,
    );

    el.addEventListener(
      'touchmove',
      (web.TouchEvent e) {
        final t = e.touches.item(0);
        if (t == null || _startX == null) return;
        final dx = t.clientX.toDouble() - _startX!;
        final dy = t.clientY.toDouble() - _startY!;
        if (!_dragging && (dx.abs() + dy.abs()) < _dragSlop) return;
        _dragging = true;
        e.preventDefault();

        final maxL = web.window.innerWidth - _clampW;
        final maxT = web.window.innerHeight - _clampH;
        final nl = (_originLeft! + dx).clamp(0.0, maxL > 0 ? maxL : 0.0);
        final nt = (_originTop! + dy).clamp(0.0, maxT > 0 ? maxT : 0.0);

        el.style
          ..setProperty('left', '${nl}px')
          ..setProperty('top', '${nt}px')
          ..removeProperty('right')
          ..removeProperty('bottom');
        onDrag(nl, nt);
      }.toJS,
    );

    el.addEventListener(
      'touchend',
      (web.TouchEvent e) {
        final wasDragging = _dragging;
        _dragging = false;
        _startX = null;
        _startY = null;
        if (!wasDragging) onTap();
      }.toJS,
    );

    web.document.body!.appendChild(el);
    _hit = el;
  }

  void hideHitArea() {
    _hit?.remove();
    _hit = null;
  }

  void _applyExcludeHoles(
    web.HTMLElement el,
    double width,
    double height,
    List<Rect> excludeRects,
  ) {
    if (excludeRects.isEmpty) {
      el.style.removeProperty('clip-path');
      return;
    }
    final r = el.getBoundingClientRect();
    final l = r.left.toDouble();
    final t = r.top.toDouble();
    final buf = StringBuffer('M 0 0 H $width V $height H 0 Z');
    var holes = 0;
    for (final ex in excludeRects) {
      final x1 = (ex.left - l).clamp(0.0, width);
      final y1 = (ex.top - t).clamp(0.0, height);
      final x2 = (ex.right - l).clamp(0.0, width);
      final y2 = (ex.bottom - t).clamp(0.0, height);
      if (x2 - x1 <= 0 || y2 - y1 <= 0) continue;
      buf.write(' M $x1 $y1 H $x2 V $y2 H $x1 Z');
      holes++;
    }
    if (holes == 0) {
      el.style.removeProperty('clip-path');
      return;
    }
    el.style.setProperty('clip-path', 'path(evenodd, "$buf")');
  }

  static const _toolbarShrinkThreshold = 32.0;

  double _maxViewportH = 0;
  double _lastViewportW = 0;
  JSFunction? _viewportListener;
  void Function()? _onToolbarShown;

  void startToolbarWatch({required void Function() onToolbarShown}) {
    _onToolbarShown = onToolbarShown;
    if (_viewportListener != null) return;
    final vv = web.window.visualViewport;
    if (vv == null) return;
    _maxViewportH = vv.height.toDouble();
    _lastViewportW = vv.width.toDouble();
    final listener = (web.Event e) {
      final v = web.window.visualViewport;
      if (v == null) return;
      final h = v.height.toDouble();
      final w = v.width.toDouble();
      if ((w - _lastViewportW).abs() > 1) {
        _lastViewportW = w;
        _maxViewportH = h;
        return;
      }
      if (h > _maxViewportH) {
        _maxViewportH = h;
        return;
      }
      if (_maxViewportH - h < _toolbarShrinkThreshold) return;
      final active = web.document.activeElement;
      final tag = active?.tagName.toUpperCase();
      if (tag == 'INPUT' || tag == 'TEXTAREA' || tag == 'IFRAME') return;
      _onToolbarShown?.call();
    }.toJS;
    _viewportListener = listener;
    vv.addEventListener('resize', listener);
  }

  void stopToolbarWatch() {
    final listener = _viewportListener;
    if (listener == null) return;
    web.window.visualViewport?.removeEventListener('resize', listener);
    _viewportListener = null;
    _onToolbarShown = null;
    _maxViewportH = 0;
    _lastViewportW = 0;
  }

  void setInteractive({required bool interactive}) {
    final classes = web.document.documentElement!.classList;
    if (interactive) {
      classes.add(_interactiveClass);
    } else {
      classes.remove(_interactiveClass);
    }
  }
}

import 'package:flutter/widgets.dart';

final ValueNotifier<bool> livestreamOverlayBlockedNotifier =
    ValueNotifier<bool>(false);

@immutable
class PunchHole {
  const PunchHole(this.rect, {this.radius = 0});

  final Rect rect;
  final double radius;

  @override
  bool operator ==(Object other) =>
      other is PunchHole && other.rect == rect && other.radius == radius;

  @override
  int get hashCode => Object.hash(rect, radius);

  @override
  String toString() => 'PunchHole($rect, radius: $radius)';
}

final ValueNotifier<List<PunchHole>> livestreamPunchHolesNotifier =
    ValueNotifier<List<PunchHole>>(const <PunchHole>[]);

final Map<Object, PunchHole> _punchHoleByOwner = <Object, PunchHole>{};

void setLivestreamPunchHole(Object owner, Rect? rect, {double radius = 0}) {
  if (rect == null) {
    if (_punchHoleByOwner.remove(owner) == null) return;
  } else {
    final hole = PunchHole(rect, radius: radius);
    if (_punchHoleByOwner[owner] == hole) return;
    _punchHoleByOwner[owner] = hole;
  }
  livestreamPunchHolesNotifier.value =
      List<PunchHole>.unmodifiable(_punchHoleByOwner.values);
}

class _HolePiece {
  _HolePiece(this.rect, this.radius, this.original);

  final Rect rect;
  final double radius;
  final Rect original;
}

String livestreamIframeClipPath({
  required Rect slot,
  Rect? visible,
  List<PunchHole> holes = const <PunchHole>[],
}) {
  final w = slot.width;
  final h = slot.height;
  if (w <= 0 || h <= 0) return 'none';

  double oL = 0, oT = 0, oR = w, oB = h;
  if (visible != null) {
    oL = (visible.left - slot.left).clamp(0.0, w);
    oT = (visible.top - slot.top).clamp(0.0, h);
    oR = (visible.right - slot.left).clamp(0.0, w);
    oB = (visible.bottom - slot.top).clamp(0.0, h);
  }
  final hasOuterClip = oL > 0 || oT > 0 || oR < w || oB < h;

  final overlapping = <_HolePiece>[];
  for (final hole in holes) {
    final l = (hole.rect.left - slot.left).clamp(oL, oR);
    final t = (hole.rect.top - slot.top).clamp(oT, oB);
    final r = (hole.rect.right - slot.left).clamp(oL, oR);
    final b = (hole.rect.bottom - slot.top).clamp(oT, oB);
    if (r - l > 0.5 && b - t > 0.5) {
      final rect = Rect.fromLTRB(l, t, r, b);
      overlapping.add(_HolePiece(rect, hole.radius, rect));
    }
  }

  final clamped = <_HolePiece>[];
  for (final hole in overlapping) {
    var pieces = <_HolePiece>[hole];
    for (final existing in clamped) {
      if (pieces.isEmpty) break;
      pieces = [
        for (final p in pieces)
          for (final r in _subtractRect(p.rect, existing.rect))
            _HolePiece(r, p.radius, p.original),
      ];
    }
    for (final p in pieces) {
      if (p.rect.width > 0.5 && p.rect.height > 0.5) clamped.add(p);
    }
  }

  String px(double v) => '${v.toStringAsFixed(2)}px';
  String n(double v) => v.toStringAsFixed(2);

  if (clamped.isEmpty) {
    if (!hasOuterClip) return 'none';
    return 'inset(${px(oT)} ${px(w - oR)} ${px(h - oB)} ${px(oL)})';
  }

  clamped.sort((a, b) => a.rect.left.compareTo(b.rect.left));
  var prevLeft = double.negativeInfinity;
  final buf = StringBuffer("path('M ${n(oL)} ${n(oT)} L ${n(oL)} ${n(oB)}");
  for (var hole in clamped) {
    var rect = hole.rect;
    if (rect.left <= prevLeft) {
      rect = Rect.fromLTRB(prevLeft + 0.05, rect.top, rect.right, rect.bottom);
      if (rect.width <= 0.5) continue;
    }
    prevLeft = rect.left;
    _writeHole(buf, rect, hole.original, hole.radius, oB, n);
  }
  buf.write(" L ${n(oR)} ${n(oB)} L ${n(oR)} ${n(oT)} Z')");
  return buf.toString();
}

void _writeHole(
  StringBuffer buf,
  Rect rect,
  Rect original,
  double radius,
  double oB,
  String Function(double) n,
) {
  const eps = 0.5;
  bool close(double a, double b) => (a - b).abs() < eps;

  final maxR = (rect.width < rect.height ? rect.width : rect.height) / 2;
  double cornerRadius(bool roundable) =>
      roundable ? radius.clamp(0.0, maxR) : 0.0;

  final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
  final rTl = cornerRadius(close(l, original.left) && close(t, original.top));
  final rTr = cornerRadius(close(r, original.right) && close(t, original.top));
  final rBr = cornerRadius(
    close(r, original.right) && close(b, original.bottom),
  );
  final rBl = cornerRadius(close(l, original.left) && close(b, original.bottom));

  buf.write(' L ${n(l)} ${n(oB)}');
  buf.write(' L ${n(l)} ${n(t + rTl)}');
  if (rTl > 0) {
    buf.write(' A ${n(rTl)} ${n(rTl)} 0 0 1 ${n(l + rTl)} ${n(t)}');
  }
  buf.write(' L ${n(r - rTr)} ${n(t)}');
  if (rTr > 0) {
    buf.write(' A ${n(rTr)} ${n(rTr)} 0 0 1 ${n(r)} ${n(t + rTr)}');
  }
  buf.write(' L ${n(r)} ${n(b - rBr)}');
  if (rBr > 0) {
    buf.write(' A ${n(rBr)} ${n(rBr)} 0 0 1 ${n(r - rBr)} ${n(b)}');
  }
  buf.write(' L ${n(l + rBl)} ${n(b)}');
  if (rBl > 0) {
    buf.write(' A ${n(rBl)} ${n(rBl)} 0 0 1 ${n(l)} ${n(b - rBl)}');
  }
  buf.write(' L ${n(l)} ${n(oB)}');
}

List<Rect> _subtractRect(Rect a, Rect b) {
  final inter = a.intersect(b);
  if (inter.width <= 0 || inter.height <= 0) return <Rect>[a];
  return <Rect>[
    if (inter.top > a.top) Rect.fromLTRB(a.left, a.top, a.right, inter.top),
    if (inter.bottom < a.bottom)
      Rect.fromLTRB(a.left, inter.bottom, a.right, a.bottom),
    if (inter.left > a.left)
      Rect.fromLTRB(a.left, inter.top, inter.left, inter.bottom),
    if (inter.right < a.right)
      Rect.fromLTRB(inter.right, inter.top, a.right, inter.bottom),
  ];
}

int _livestreamOverlayBlockCount = 0;

void pushLivestreamOverlayBlock() {
  _livestreamOverlayBlockCount++;
  if (_livestreamOverlayBlockCount > 0 &&
      !livestreamOverlayBlockedNotifier.value) {
    livestreamOverlayBlockedNotifier.value = true;
  }
}

void popLivestreamOverlayBlock() {
  if (_livestreamOverlayBlockCount > 0) {
    _livestreamOverlayBlockCount--;
  }
  if (_livestreamOverlayBlockCount <= 0) {
    _livestreamOverlayBlockCount = 0;
    if (livestreamOverlayBlockedNotifier.value) {
      livestreamOverlayBlockedNotifier.value = false;
    }
  }
}

class LivestreamDialogRouteObserver extends NavigatorObserver {
  final Set<Route<dynamic>> _tracked = <Route<dynamic>>{};

  bool _shouldBlock(Route<dynamic>? route) => route is PopupRoute;

  void _track(Route<dynamic>? route) {
    if (!_shouldBlock(route)) return;
    if (_tracked.add(route!)) {
      pushLivestreamOverlayBlock();
    }
  }

  void _untrack(Route<dynamic>? route) {
    if (route == null) return;
    if (_tracked.remove(route)) {
      popLivestreamOverlayBlock();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _untrack(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _untrack(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _untrack(oldRoute);
    _track(newRoute);
  }
}

final LivestreamDialogRouteObserver livestreamDialogRouteObserver =
    LivestreamDialogRouteObserver();

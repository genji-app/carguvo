import 'dart:ui' show Rect;

class CasinoDomFab {
  const CasinoDomFab._();
  static const instance = CasinoDomFab._();

  void enterCasinoEmbed() {}
  void exitCasinoEmbed() {}
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
  }) {}
  void hideHitArea() {}
  void startToolbarWatch({required void Function() onToolbarShown}) {}
  void stopToolbarWatch() {}
  void setInteractive({required bool interactive}) {}
}

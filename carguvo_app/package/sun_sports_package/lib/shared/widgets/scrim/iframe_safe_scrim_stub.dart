import 'package:flutter/material.dart';

Widget buildIframeSafeScrim({
  required Color color,
  VoidCallback? onTap,
  GestureTapUpCallback? onTapUp,
  Animation<double>? fade,
}) {
  final Widget box = ColoredBox(color: color);
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    onTapUp: onTapUp,
    child: fade == null ? box : FadeTransition(opacity: fade, child: box),
  );
}

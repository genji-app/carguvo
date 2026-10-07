import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget buildIframeSafeScrim({
  required Color color,
  VoidCallback? onTap,
  GestureTapUpCallback? onTapUp,
  Animation<double>? fade,
}) {
  final css =
      'rgba(${(color.r * 255).round()},${(color.g * 255).round()},'
      '${(color.b * 255).round()},${color.a.toStringAsFixed(3)})';
  return Stack(
    fit: StackFit.expand,
    children: [
      Positioned.fill(
        child: HtmlElementView.fromTagName(
          tagName: 'div',
          onElementCreated: (Object element) {
            (element as web.HTMLElement).style
              ..backgroundColor = css
              ..width = '100%'
              ..height = '100%'
              ..pointerEvents = 'auto'
              ..touchAction = 'none';
          },
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onTapUp: onTapUp,
        child: const SizedBox.expand(),
      ),
    ],
  );
}

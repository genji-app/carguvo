import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class InnerShadowCard extends StatelessWidget {
  final double borderRadius;
  final Color? color;

  final Widget child;

  final bool showHighlight;

  const InnerShadowCard({
    required this.child,
    super.key,
    this.borderRadius = 16,
    this.color,
    this.showHighlight = true,
  });

  static const _highlightColor = Color(0x1FFFFFFF);

  static const _strokeWidth = 1.0;

  static const _sideExtent = 16.0;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      if (color != null)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      RepaintBoundary(child: child),
      if (showHighlight)
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _InnerShadowHighlightPainter(
                  color: _highlightColor,
                  radius: borderRadius,
                  strokeWidth: _strokeWidth,
                  sideExtent: _sideExtent,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _InnerShadowHighlightPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double sideExtent;

  _InnerShadowHighlightPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.sideExtent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final inset = strokeWidth / 2;
    final r = math.max(0.0, radius - inset);

    final sideEndY = math.min(radius + sideExtent, h - radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    if (sideEndY > radius) {
      _drawFadeSegment(canvas, paint, inset, radius, sideEndY);
      _drawFadeSegment(canvas, paint, w - inset, radius, sideEndY);
    }

    final topPath = Path()
      ..moveTo(inset, radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: r),
        math.pi,
        math.pi / 2,
        false,
      )
      ..lineTo(w - radius, inset)
      ..arcTo(
        Rect.fromCircle(center: Offset(w - radius, radius), radius: r),
        -math.pi / 2,
        math.pi / 2,
        false,
      );
    paint
      ..shader = null
      ..color = color;
    canvas.drawPath(topPath, paint);
  }

  void _drawFadeSegment(
    Canvas canvas,
    Paint paint,
    double x,
    double solidY,
    double fadeY,
  ) {
    paint.shader = ui.Gradient.linear(Offset(x, solidY), Offset(x, fadeY), [
      color,
      color.withValues(alpha: 0),
    ]);
    canvas.drawPath(
      Path()
        ..moveTo(x, solidY)
        ..lineTo(x, fadeY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_InnerShadowHighlightPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.sideExtent != sideExtent;
}

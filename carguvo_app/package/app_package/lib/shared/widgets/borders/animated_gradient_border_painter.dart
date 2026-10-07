import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedGradientBorderPainter extends CustomPainter {
  AnimatedGradientBorderPainter({
    required this.rotation,
    required this.borderRadius,
    required this.strokeWidth,
    required this.glowBlur,
    required this.highlight,
    required this.spark,
  });

  final double rotation;

  final double borderRadius;

  final double strokeWidth;

  final double glowBlur;

  final Color highlight;

  final Color spark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final SweepGradient gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      transform: GradientRotation(rotation * 2 * math.pi),
      colors: <Color>[
        highlight,
        spark,
        highlight,
        spark,
        highlight,
      ],
      stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
    );
    final Shader shader = gradient.createShader(rect);

    if (glowBlur > 0) {
      final Paint glowPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);
      canvas.drawRRect(rrect, glowPaint);
    }

    final Paint borderPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(AnimatedGradientBorderPainter old) {
    return rotation != old.rotation ||
        borderRadius != old.borderRadius ||
        strokeWidth != old.strokeWidth ||
        glowBlur != old.glowBlur ||
        highlight != old.highlight ||
        spark != old.spark;
  }
}

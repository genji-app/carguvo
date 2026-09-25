import 'package:flutter/material.dart';

class TooltipArrowPainter extends CustomPainter {
  const TooltipArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();

    path.moveTo(1.0, 0);

    path.lineTo(size.width - 1.0, 0);

    path.quadraticBezierTo(size.width, 0, size.width - 0.5, 0.5);

    path.lineTo(size.width / 2 + 0.5, size.height - 0.3);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width / 2 - 0.5,
      size.height - 0.3,
    );

    path.lineTo(0.5, 0.5);

    path.quadraticBezierTo(0, 0, 1.0, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TooltipArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

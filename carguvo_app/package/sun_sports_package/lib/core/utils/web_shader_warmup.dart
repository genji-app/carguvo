import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class WebShaderWarmUp extends StatefulWidget {
  const WebShaderWarmUp({required this.child, super.key});

  final Widget child;

  @override
  State<WebShaderWarmUp> createState() => _WebShaderWarmUpState();
}

class _WebShaderWarmUpState extends State<WebShaderWarmUp> {
  bool _active = kIsWeb;

  @override
  void initState() {
    super.initState();
    if (!_active) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _active = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return widget.child;
    return CustomPaint(
      painter: _ShaderWarmUpPainter(),
      child: widget.child,
    );
  }
}

class _ShaderWarmUpPainter extends CustomPainter {
  static const Rect _clip = Rect.fromLTWH(0, 0, 8, 8);
  static const Rect _shape = Rect.fromLTWH(8, 8, 100, 100);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(_clip);

    final rrect = RRect.fromRectAndRadius(_shape, const Radius.circular(24));

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawCircle(
      const Offset(58, 58),
      60,
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0x1FFFFFFF),
    );
    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF888888)],
        ).createShader(_shape),
    );

    canvas.drawCircle(
      const Offset(58, 58),
      50,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
        ).createShader(_shape),
    );

    canvas.drawArc(
      _shape,
      0,
      3.14,
      false,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = const SweepGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        ).createShader(_shape),
    );

    canvas.drawShadow(Path()..addRRect(rrect), const Color(0xFF000000), 8, true);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x88000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.saveLayer(
      _shape,
      Paint()
        ..blendMode = BlendMode.srcOver
        ..color = const Color(0x80FFFFFF),
    );
    canvas.drawCircle(
      const Offset(40, 40),
      20,
      Paint()..color = const Color(0xFFFF0000),
    );
    canvas.drawCircle(
      const Offset(70, 70),
      20,
      Paint()
        ..color = const Color(0xFF00FF00)
        ..blendMode = BlendMode.multiply,
    );
    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..color = const Color(0x1FFFFCDB),
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Ag',
        style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(0, 0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

final ValueNotifier<double?> upDownCashoutAnchorY = ValueNotifier<double?>(null);

class UpDownCashoutResult extends StatefulWidget {
  final int amount;

  final VoidCallback onDone;

  const UpDownCashoutResult({
    required this.amount,
    required this.onDone,
    super.key,
  });

  @override
  State<UpDownCashoutResult> createState() => _UpDownCashoutResultState();
}

class _UpDownCashoutResultState extends State<UpDownCashoutResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dy = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
    final scale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
    final opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_c);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: Offset(0, dy.value),
            child: Transform.scale(
              scale: scale.value,
              child: _moneyBox(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _moneyBox() {
    return CustomPaint(
      foregroundPainter: const _GradientBorderPainter(radius: 16, width: 0.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF391500), Color(0xFF221300)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 1.35,
              offset: Offset(0, 1.35),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.1,
                    colors: [
                      const Color(0xFFFFBA71).withValues(alpha: 0.32),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: GradientText(
                '+${upDownMoney(widget.amount)}',
                gradient: kUpDownGoldGradient,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 24 / 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double width;

  const _GradientBorderPainter({required this.radius, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFF666666)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.radius != radius || old.width != width;
}

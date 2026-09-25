import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';

class MiniGamePreloadRing extends StatelessWidget {
  const MiniGamePreloadRing({
    required this.progress,
    required this.size,
    super.key,
  });

  final double progress;

  final double size;

  static const double _kRingRatio = 0.62;

  static const double _kStrokeRatio = 0.075;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    final ring = size * _kRingRatio;
    final stroke = (size * _kStrokeRatio).clamp(3.0, 8.0);
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: ring, height: ring),
            ),
            SizedBox(
              width: ring,
              height: ring,
              child: CustomPaint(
                painter: _RingPainter(value: value, stroke: stroke),
                child: Center(
                  child: Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ring * 0.27,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniGameBundleProgressRing extends StatefulWidget {
  const MiniGameBundleProgressRing({
    required this.bundleKey,
    required this.size,
    super.key,
  });

  final String bundleKey;
  final double size;

  @override
  State<MiniGameBundleProgressRing> createState() =>
      _MiniGameBundleProgressRingState();
}

class _MiniGameBundleProgressRingState extends State<MiniGameBundleProgressRing>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<double> _source;

  double _real = 0;

  static const Duration _kSweep = Duration(milliseconds: 800);

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: _kSweep,
  );

  @override
  void initState() {
    super.initState();
    _source = BundleManager.instance.progressFor(widget.bundleKey);
    _real = _source.value.clamp(0.0, 1.0);
    _source.addListener(_onTick);
    _sweep.forward();
  }

  void _onTick() {
    if (!mounted) return;
    final next = _source.value.clamp(0.0, 1.0);
    if (next <= _real) return;
    setState(() => _real = next);
  }

  @override
  void dispose() {
    _source.removeListener(_onTick);
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _sweep,
    builder: (context, _) => MiniGamePreloadRing(
      progress: math.min(
        Curves.easeOutCubic.transform(_sweep.value),
        _real,
      ),
      size: widget.size,
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.stroke});

  final double value;
  final double stroke;

  static const List<Color> _kSweep = [
    Color(0xFF7BE8A3),
    Color(0xFFC8F06A),
    Color(0xFFF5D423),
    Color(0xFF7BE8A3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF15120F).withValues(alpha: 0.92),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: 0.16),
    );

    if (value <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: _kSweep,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.stroke != stroke;
}

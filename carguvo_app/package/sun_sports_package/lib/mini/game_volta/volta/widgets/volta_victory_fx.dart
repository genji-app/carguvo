library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum VoltaFxTone {
  warm(
    star: Color(0xFFFFE0A8),
    glow: Color(0xFFFFCD78),
    ember: Color(0xFFFFC24D),
    density: 1,
  ),
  cool(
    star: Color(0xFFFFFDF6),
    glow: Color(0xFFFFFFFF),
    ember: Color(0xFFFFE9B0),
    density: 0.8,
  );

  const VoltaFxTone({
    required this.star,
    required this.glow,
    required this.ember,
    required this.density,
  });

  final Color star;
  final Color glow;
  final Color ember;
  final double density;
}

mixin _FxClock<T extends StatefulWidget> on State<T>, TickerProvider {
  final ValueNotifier<double> clock = ValueNotifier<double>(0);
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      clock.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    })..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    clock.dispose();
    super.dispose();
  }
}

class VoltaVictoryFx extends StatefulWidget {
  const VoltaVictoryFx({
    required this.tone,
    required this.seed,
    super.key,
  });

  final VoltaFxTone tone;

  final int seed;

  @override
  State<VoltaVictoryFx> createState() => _VoltaVictoryFxState();
}

class _VoltaVictoryFxState extends State<VoltaVictoryFx>
    with SingleTickerProviderStateMixin, _FxClock<VoltaVictoryFx> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ParticlePainter(
            clock: clock,
            tone: widget.tone,
            seed: widget.seed,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.size,
    required this.period,
    required this.phase,
    required this.drift,
    required this.spin,
    required this.alpha,
    this.color,
    this.height = 0,
  });

  final double x;
  final double size;
  final double period;
  final double phase;
  final double drift;
  final double spin;
  final double alpha;

  final Color? color;

  final double height;

  double progress(double t) => ((t + phase) % period) / period;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.clock,
    required this.tone,
    required this.seed,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final VoltaFxTone tone;
  final int seed;

  List<_Particle>? _stars;
  List<_Particle>? _confetti;
  List<_Particle>? _embers;
  double _builtFor = -1;

  static final Path _starPath = _buildStar();

  static Path _buildStar() {
    final Path p = Path();
    const int points = 5;
    const double inner = 0.44;
    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? 1.0 : inner;
      final double a = math.pi / points * i - math.pi / 2;
      final Offset o = Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  int _count(double h, int tall, int short) =>
      ((h >= 170 ? tall : short) * tone.density).round();

  void _build(double h) {
    if (_builtFor == h) return;
    _builtFor = h;
    final _Seeded r = _Seeded(seed);

    _stars = <_Particle>[
      for (int i = 0; i < _count(h, 14, 12); i++) _makeStar(r, h),
    ];
    _confetti = <_Particle>[
      for (int i = 0; i < _count(h, 9, 7); i++) _makeConfetti(r, i),
    ];
    _embers = <_Particle>[
      for (int i = 0; i < _count(h, 9, 7); i++) _makeEmber(r),
    ];
  }

  _Particle _makeStar(_Seeded r, double h) {
    final double u = r.next();
    final double t = u * u;
    final double lo = math.max(4.5, h * 0.030);
    final double hi = math.min(22.0, h * 0.135);
    final double period = (1.55 - 0.6 * t) * r.range(0.85, 1.15);
    return _Particle(
      x: r.range(-4, 100),
      size: lo + t * (hi - lo),
      period: period,
      phase: r.range(0, period),
      drift: r.range(-14, 14) * (0.7 + 0.6 * t),
      spin: r.range(-520, 520) * math.pi / 180,
      alpha: math.min(1.0, (0.58 + 0.42 * t) * r.range(0.92, 1.06)),
    );
  }

  _Particle _makeConfetti(_Seeded r, int index) {
    final double period = r.range(2.4, 3.6);
    return _Particle(
      x: r.range(-4, 100),
      size: r.range(4.5, 7.5),
      height: r.range(7, 12),
      period: period,
      phase: r.range(0, period),
      drift: r.range(-34, 34),
      spin: r.range(-360, 360) * math.pi / 180,
      alpha: 0.9,
      color: _confettiColors[index % _confettiColors.length],
    );
  }

  _Particle _makeEmber(_Seeded r) {
    final double period = r.range(1.5, 2.6);
    return _Particle(
      x: r.range(0, 100),
      size: r.range(4, 10),
      period: period,
      phase: r.range(0, period),
      drift: r.range(-24, 24),
      spin: 0,
      alpha: 1,
    );
  }

  static const List<Color> _confettiColors = <Color>[
    Color(0xFFFFD24D), Color(0xFFFF7A7A), Color(0xFF8ED2FF),
    Color(0xFFB4FF6B), Color(0xFFFFFFFF), Color(0xFFD98BFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _build(size.height);
    final double t = clock.value;
    final Paint paint = Paint()..isAntiAlias = true;

    for (final _Particle p in _stars!) {
      _drawStar(canvas, size, p, p.progress(t), paint);
    }
    for (final _Particle p in _confetti!) {
      _drawConfetti(canvas, size, p, p.progress(t), paint);
    }
    for (final _Particle p in _embers!) {
      _drawEmber(canvas, size, p, p.progress(t), paint);
    }
  }

  static double _fade(double k) {
    if (k < 0.10) return k / 0.10;
    if (k > 0.72) return (1 - k) / 0.28;
    return 1;
  }

  void _drawStar(
      Canvas canvas, Size size, _Particle p, double k, Paint paint) {
    final double a = p.alpha * _fade(k);
    if (a <= 0.01) return;
    final double x = size.width * p.x / 100 + p.drift * k;
    final double y = -14 + (size.height + 42) * k;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(p.spin * k);
    canvas.scale(p.size / 2);

    for (int i = 0; i < 3; i++) {
      paint.color = tone.glow.withValues(alpha: a * (0.22 - i * 0.062));
      canvas.drawCircle(Offset.zero, 2.1 - i * 0.45, paint);
    }
    paint.color = tone.star.withValues(alpha: a);
    canvas.drawPath(_starPath, paint);
    canvas.restore();
  }

  void _drawConfetti(
      Canvas canvas, Size size, _Particle p, double k, Paint paint) {
    final double a = p.alpha * _fade(k);
    if (a <= 0.01) return;
    final double x = size.width * p.x / 100 + p.drift * k;
    final double y = -16 + (size.height + 52) * k;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(p.spin * k);
    canvas.scale(
      math.cos(k * 4 * math.pi).abs().clamp(0.15, 1.0).toDouble(),
      1,
    );
    paint.color = p.color!.withValues(alpha: a);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: p.size, height: p.height),
      paint,
    );
    canvas.restore();
  }

  void _drawEmber(
      Canvas canvas, Size size, _Particle p, double k, Paint paint) {
    final double a = k < 0.14 ? k / 0.14 : (1 - k) / 0.86;
    if (a <= 0.01) return;
    final double x = size.width * p.x / 100 + p.drift * k;
    final double y = size.height - (size.height + 22) * k;
    final double r = p.size * (0.5 + 0.65 * k) / 2;

    for (int i = 0; i < 3; i++) {
      paint.color = tone.ember.withValues(alpha: a * (0.55 - i * 0.16));
      canvas.drawCircle(Offset(x, y), r * (1 + i * 0.55), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.seed != seed || old.tone != tone;
}

class VoltaVictoryGlow extends StatefulWidget {
  const VoltaVictoryGlow({
    required this.innerGradient,
    required this.borderRadius,
    this.innerLayer,
    super.key,
  });

  final Widget? innerLayer;

  final Gradient innerGradient;

  final BorderRadius borderRadius;

  @override
  State<VoltaVictoryGlow> createState() => _VoltaVictoryGlowState();
}

class _VoltaVictoryGlowState extends State<VoltaVictoryGlow>
    with SingleTickerProviderStateMixin, _FxClock<VoltaVictoryGlow> {
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _GlowPainter(
              clock: clock,
              innerGradient: widget.innerGradient,
              borderRadius: widget.borderRadius,
            ),
            size: Size.infinite,
            child: widget.innerLayer == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(_kMaskInset),
                    child: ClipRRect(
                      borderRadius: widget.borderRadius,
                      child: widget.innerLayer,
                    ),
                  ),
          ),
        ),
      );
}

const double _kMaskInset = 3;

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.clock,
    required this.innerGradient,
    required this.borderRadius,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final Gradient innerGradient;
  final BorderRadius borderRadius;

  static const double _borderPeriod = 2;

  static const double pulsePeriod = 1.5;

  static const int pulseMillis = 1500;

  static const Color _gold = Color(0xFFFFE2AA);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final double t = clock.value;

    final double side = math.max(size.width, size.height) * 2;
    final Rect square = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate((t % _borderPeriod) / _borderPeriod * 2 * math.pi);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(
      square,
      Paint()
        ..shader = const SweepGradient(
          colors: <Color>[
            Color(0x00FFE2AA), _gold, Color(0x00FFE2AA),
            Color(0x00FFE2AA), Color(0x8CFFE2AA), Color(0x00FFE2AA),
            Color(0x00FFE2AA),
          ],
          stops: <double>[0, 0.117, 0.267, 0.5, 0.617, 0.767, 1],
        ).createShader(square),
    );
    canvas.restore();

    final Rect inner = Rect.fromLTWH(
      _kMaskInset,
      _kMaskInset,
      size.width - 2 * _kMaskInset,
      size.height - 2 * _kMaskInset,
    );
    if (!inner.isEmpty) {
      canvas.drawRRect(
        borderRadius.toRRect(inner),
        Paint()..shader = innerGradient.createShader(inner),
      );
    }

    final double k = (t % pulsePeriod) / pulsePeriod;
    final double a = 0.12 + 0.88 * (0.5 - 0.5 * math.cos(k * 2 * math.pi));
    final Rect full = Offset.zero & size;
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.75,
          colors: <Color>[
            const Color(0xFFFFE2AA).withValues(alpha: 0.30 * a),
            const Color(0xFFFFC878).withValues(alpha: 0.10 * a),
            const Color(0x00FFB450),
          ],
          stops: const <double>[0, 0.45, 0.75],
        ).createShader(full),
    );
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) =>
      old.innerGradient != innerGradient || old.borderRadius != borderRadius;
}

class VoltaWinLogoPulse extends StatefulWidget {
  const VoltaWinLogoPulse({required this.child, super.key});

  final Widget child;

  @override
  State<VoltaWinLogoPulse> createState() => _VoltaWinLogoPulseState();
}

class _VoltaWinLogoPulseState extends State<VoltaWinLogoPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _GlowPainter.pulseMillis),
  )..repeat();

  late final Animation<double> _scale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 1.14)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 18,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.14, end: 0.98)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 22,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.98, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ],
  ).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

class _Seeded {
  _Seeded(int seed) : _s = seed & 0x7FFFFFFF {
    next();
    next();
    next();
  }

  int _s;

  double next() {
    _s = (_s * 1664525 + 1013904223) & 0x7FFFFFFF;
    return _s / 0x7FFFFFFF;
  }

  double range(double a, double b) => a + next() * (b - a);
}

int voltaFxSeed(String eventId, {required bool isHome}) {
  int h = 17;
  for (int i = 0; i < eventId.length; i++) {
    h = (h * 31 + eventId.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return (h * 2 + (isHome ? 0 : 1)) & 0x7FFFFFFF;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_metrics.dart';

class VoltaHistoryBoard extends ConsumerStatefulWidget {
  const VoltaHistoryBoard({super.key});

  @override
  ConsumerState<VoltaHistoryBoard> createState() => _VoltaHistoryBoardState();
}

class _VoltaHistoryBoardState extends ConsumerState<VoltaHistoryBoard>
    with TickerProviderStateMixin {
  static const Duration _pulsePeriod = Duration(milliseconds: 730);
  static const Duration _shiftDuration = Duration(milliseconds: 600);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: _pulsePeriod,
  )..repeat();

  late final AnimationController _shift = AnimationController(
    vsync: this,
    duration: _shiftDuration,
    value: 1,
  );

  List<VoltaHistoryCell> _shown = const <VoltaHistoryCell>[];

  @override
  void initState() {
    super.initState();
    _shown = ref.read(voltaStateProvider).history;
  }

  @override
  void dispose() {
    _pulse.dispose();
    _shift.dispose();
    super.dispose();
  }

  static bool _isOneNewer(
    List<VoltaHistoryCell> old,
    List<VoltaHistoryCell> next,
  ) {
    if (old.isEmpty) return false;
    if (next.length == old.length + 1) {
      for (int i = 0; i < old.length; i++) {
        if (next[i] != old[i]) return false;
      }
      return true;
    }
    if (next.length == old.length) {
      for (int i = 0; i < old.length - 1; i++) {
        if (next[i] != old[i + 1]) return false;
      }
      return true;
    }
    return false;
  }

  static bool _sameCells(
    List<VoltaHistoryCell> a,
    List<VoltaHistoryCell> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onHistory(List<VoltaHistoryCell>? _, List<VoltaHistoryCell> next) {
    if (_sameCells(_shown, next)) return;

    if (_isOneNewer(_shown, next)) {
      _shift.forward(from: 0);
    } else {
      _shift.value = 1;
    }
    _shown = next;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<VoltaHistoryCell>>(
      voltaStateProvider.select((VoltaState s) => s.history),
      _onHistory,
    );
    final history = ref.watch(voltaStateProvider.select((s) => s.history));
    final homePercent = ref.watch(
      voltaStateProvider.select((s) => s.historyHomePercent),
    );
    final awayPercent = ref.watch(
      voltaStateProvider.select((s) => s.historyAwayPercent),
    );
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: _cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: spec.historySideWidth,
                child: Padding(
                  padding: const EdgeInsets.all(_labelPad),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _SidePercent(
                        label: 'Nhà',
                        percent: homePercent,
                        color: _homeLabel,
                      ),
                      const SizedBox(height: _labelGap),
                      _SidePercent(
                        label: 'Khách',
                        percent: awayPercent,
                        color: _awayLabel,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: _labelPad),
                child: SizedBox(
                  width: 1,
                  child: DecoratedBox(decoration: _dividerDecoration),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _VoltaDotGridPainter(
                      history,
                      pulse: _pulse,
                      shift: _shift,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Color _homeLabel = Color(0xFFDA524D);
  static const Color _awayLabel = Color(0xFFE4BC50);

  static const double _labelPad = 10;
  static const double _labelGap = 7;

  static const BoxDecoration _dividerDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color(0x00CCCCCC),
        Color(0x5CCCCCCC),
        Color(0x00CCCCCC),
      ],
      stops: <double>[0.0, 0.4952, 1.0],
    ),
  );

  static final BoxDecoration _cardDecoration = BoxDecoration(
    color: VoltaColors.surface,
    borderRadius: BorderRadius.circular(VoltaMetrics.historyCardRadius),
  );
}

class _SidePercent extends StatelessWidget {
  const _SidePercent({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  static const double _lineHeightRatio = 1.6;

  @override
  Widget build(BuildContext context) {
    final double font = VoltaLayoutScope.of(context).historyLabelFontSize;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '$label\n($percent%)',
        textAlign: TextAlign.center,
        style: AppTextStyles.inter(
          fontSize: font,
          fontWeight: FontWeight.w700,
          color: color,
          height: _lineHeightRatio,
        ),
      ),
    );
  }
}

class _VoltaDotGridPainter extends CustomPainter {
  _VoltaDotGridPainter(this.cells, {required this.pulse, required this.shift})
    : super(repaint: Listenable.merge(<Listenable>[pulse, shift]));

  final List<VoltaHistoryCell> cells;

  final Animation<double> pulse;

  final Animation<double> shift;

  static const int _columns = VoltaMetrics.historyColumns;
  static const int _rows = VoltaMetrics.historyRows;
  static const int _capacity = _columns * _rows;

  static const double _gapXRatio = 0.70;
  static const double _gapYRatio = 0.48;

  static const double _padX = 12;
  static const double _padY = 5;

  static const double _maxDot = 20;

  static const Color _homeBase = Color(0xFFC22E28);
  static const Color _awayBase = Color(0xFFD6A521);

  static const double _newestMinScale = 1.076;
  static const double _newestMaxScale = 1.404;

  static Paint _ballPaint(Color base, double radius) {
    final HSLColor hsl = HSLColor.fromColor(base);
    Color lift(double d) =>
        hsl.withLightness((hsl.lightness + d).clamp(0.0, 1.0)).toColor();
    return Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.5),
        radius: 0.95,
        colors: <Color>[lift(0.30), base, lift(-0.16)],
        stops: const <double>[0, 0.55, 1],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );
  }

  static final Paint _specular = Paint()
    ..isAntiAlias = true
    ..color = const Color(0xB3FFFFFF);

  static final Paint _emptyPaint = Paint()
    ..isAntiAlias = true
    ..color = const Color(0xFF2A2520);

  static final Paint _trailPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0x8A8A7A63);

  @override
  void paint(Canvas canvas, Size size) {
    final double usableW = size.width - 2 * _padX;
    final double usableH = size.height - 2 * _padY;
    if (usableW <= 0 || usableH <= 0) return;

    final double byWidth =
        usableW / (_columns + (_columns - 1) * _gapXRatio);
    final double byHeight = usableH / (_rows + (_rows - 1) * _gapYRatio);
    final double dot = math.min(math.min(byWidth, byHeight), _maxDot);
    final double radius = dot / 2;
    final double pitchX = math.min(
      math.max(dot * (1 + _gapXRatio), (usableW - dot) / (_columns - 1)),
      dot * 2,
    );
    final double pitchY = dot * (1 + _gapYRatio);

    final double gridW = (_columns - 1) * pitchX + dot;
    final double gridH = (_rows - 1) * pitchY + dot;
    final double left =
        _padX + ((usableW - gridW) / 2).clamp(0.0, double.infinity) + radius;
    final double top = (size.height - gridH) / 2 + radius;

    double arrowTipX(double cx) => cx + radius + dot * 0.45;

    int colFor(int age) {
      final int row = age ~/ _columns;
      final int k = age % _columns;
      return row.isEven ? (_columns - 1 - k) : k;
    }

    Offset centerFor(int age) =>
        Offset(left + colFor(age) * pitchX, top + (age ~/ _columns) * pitchY);

    final int count = cells.length > _capacity ? _capacity : cells.length;

    final double t = shift.value.clamp(0.0, 1.0);

    Offset movingCenter(int age) {
      if (t >= 1 || age == 0) return centerFor(age);
      return Offset.lerp(centerFor(age - 1), centerFor(age), t)!;
    }

    final double breath = 0.5 - 0.5 * math.cos(2 * math.pi * pulse.value);
    final double newestScale =
        _newestMinScale + (_newestMaxScale - _newestMinScale) * breath;

    final Paint homeBall = _ballPaint(_homeBase, radius);
    final Paint awayBall = _ballPaint(_awayBase, radius);

    _paintTrail(canvas, centerFor, colFor, count, arrowTipX);

    for (int age = 0; age < _capacity; age++) {
      final Offset center = movingCenter(age);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      if (age >= count) {
        canvas.drawCircle(Offset.zero, radius * 0.82, _emptyPaint);
      } else {
        final VoltaHistoryCell cell = cells[cells.length - 1 - age];
        final double r = age == 0 ? radius * newestScale * t : radius;
        if (r > 0.3) {
          final Paint? ball = switch (cell.winner) {
            VoltaWinner.home => homeBall,
            VoltaWinner.away => awayBall,
            VoltaWinner.unknown => null,
          };
          if (ball == null) {
            canvas.drawCircle(Offset.zero, r * 0.82, _emptyPaint);
          } else {
            canvas.save();
            canvas.scale(r / radius);
            canvas.drawCircle(Offset.zero, radius, ball);
            canvas.drawOval(
              Rect.fromCenter(
                center: Offset(-radius * 0.18, -radius * 0.52),
                width: radius * 0.62,
                height: radius * 0.40,
              ),
              _specular,
            );
            canvas.restore();
          }
        }
      }
      canvas.restore();
    }

    if (count > 0) _paintArrow(canvas, centerFor(0), radius, arrowTipX);
  }

  void _paintTrail(
    Canvas canvas,
    Offset Function(int age) centerFor,
    int Function(int age) colFor,
    int count,
    double Function(double cx) arrowTipX,
  ) {
    if (count < 1) return;

    final Path path = Path();
    Offset previous = centerFor(count - 1);
    path.moveTo(previous.dx, previous.dy);

    for (int age = count - 2; age >= 0; age--) {
      final Offset current = centerFor(age);
      final bool sameRow = (age ~/ _columns) == ((age + 1) ~/ _columns);
      if (sameRow) {
        path.lineTo(current.dx, current.dy);
      } else {
        final double bulge = (colFor(age) == _columns - 1 ? 1 : -1) *
            (current.dy - previous.dy).abs() *
            0.45;
        path.quadraticBezierTo(
          previous.dx + bulge,
          (previous.dy + current.dy) / 2,
          current.dx,
          current.dy,
        );
      }
      previous = current;
    }

    final Offset newest = centerFor(0);
    path.lineTo(arrowTipX(newest.dx), newest.dy);
    canvas.drawPath(path, _trailPaint);
  }

  void _paintArrow(
    Canvas canvas,
    Offset newest,
    double radius,
    double Function(double cx) arrowTipX,
  ) {
    final double half = radius * 0.55;
    final double tip = arrowTipX(newest.dx);
    final Path arrow = Path()
      ..moveTo(tip - half, newest.dy - half)
      ..lineTo(tip, newest.dy)
      ..lineTo(tip - half, newest.dy + half);
    canvas.drawPath(
      arrow,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xCC8A7A63),
    );
  }

  @override
  bool shouldRepaint(_VoltaDotGridPainter oldDelegate) {
    if (identical(oldDelegate.cells, cells)) return false;
    if (oldDelegate.cells.length != cells.length) return true;
    for (int i = 0; i < cells.length; i++) {
      if (oldDelegate.cells[i] != cells[i]) return true;
    }
    return false;
  }
}

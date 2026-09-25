import 'package:flutter/widgets.dart';

import '../volta_colors.dart';
import '../volta_gradients.dart';

class VoltaGateBackground extends StatelessWidget {
  const VoltaGateBackground({
    required this.home,
    required this.borderRadius,
    this.drawBorder = true,
    super.key,
  });

  final bool home;

  final BorderRadius borderRadius;

  final bool drawBorder;

  static const double _borderWidth = 0.718;

  static const double _rxTop = 0.59;
  static const double _ryTop = 0.18;
  static const double _rxBottom = 0.53;
  static const double _ryBottom = 0.325;

  static const List<double> _kGlowStops = <double>[0, 0.25, 0.5, 0.75, 1];

  static const List<double> _kGlowFalloff = <double>[1, 0.72, 0.35, 0.095, 0];

  static const double _aTopHome = 0.50;
  static const double _aBottomHome = 0.50;
  static const double _aTopAway = 0.43;
  static const double _aBottomAway = 0.60;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _GatePainter(
        home: home,
        borderRadius: borderRadius,
        drawBorder: drawBorder,
      ),
      size: Size.infinite,
    ),
  );
}

class _GatePainter extends CustomPainter {
  const _GatePainter({
    required this.home,
    required this.borderRadius,
    required this.drawBorder,
  });

  final bool home;
  final BorderRadius borderRadius;
  final bool drawBorder;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = (home ? VoltaGradients.homeGate : VoltaGradients.awayGate)
            .createShader(rect),
    );

    _glow(
      canvas,
      size,
      color: home ? VoltaColors.homeGateGlowTop : VoltaColors.awayGateGlowTop,
      rx: VoltaGateBackground._rxTop,
      ry: VoltaGateBackground._ryTop,
      a0: home
          ? VoltaGateBackground._aTopHome
          : VoltaGateBackground._aTopAway,
      atTop: true,
    );
    _glow(
      canvas,
      size,
      color: home
          ? VoltaColors.homeGateGlowBottom
          : VoltaColors.awayGateGlowBottom,
      rx: VoltaGateBackground._rxBottom,
      ry: VoltaGateBackground._ryBottom,
      a0: home
          ? VoltaGateBackground._aBottomHome
          : VoltaGateBackground._aBottomAway,
      atTop: false,
    );

    if (home && drawBorder) {
      const double w = VoltaGateBackground._borderWidth;
      canvas.drawRRect(
        borderRadius.toRRect(rect).deflate(w / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..shader = VoltaGradients.homeGateBorder.createShader(rect),
      );
    }
  }

  void _glow(
    Canvas canvas,
    Size size, {
    required Color color,
    required double rx,
    required double ry,
    required double a0,
    required bool atTop,
  }) {
    final double rxPx = size.width * rx;
    final double ryPx = size.height * ry;
    if (rxPx <= 0 || ryPx <= 0) return;

    final double cx = size.width / 2;
    final double cy = atTop ? 0 : size.height;
    final double k = ryPx / rxPx;

    canvas.save();
    canvas.translate(0, cy);
    canvas.scale(1, k);
    canvas.translate(0, -cy);

    final Rect box = Rect.fromCircle(center: Offset(cx, cy), radius: rxPx);
    canvas.drawRect(
      box,
      Paint()
        ..shader = RadialGradient(
          radius: 0.5,
          colors: <Color>[
            for (final double m in VoltaGateBackground._kGlowFalloff)
              color.withValues(alpha: a0 * m),
          ],
          stops: VoltaGateBackground._kGlowStops,
        ).createShader(box),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GatePainter oldDelegate) =>
      oldDelegate.home != home ||
      oldDelegate.drawBorder != drawBorder ||
      oldDelegate.borderRadius != borderRadius;
}

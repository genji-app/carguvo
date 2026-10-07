import 'package:flutter/material.dart';

import 'volta_colors.dart';
import 'volta_layout_spec.dart';

class VoltaGradients {
  VoltaGradients._();

  static const LinearGradient tabBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.tabBarTop, Color(0xFF000000)],
    stops: [0.0, 0.77327],
  );

  static const LinearGradient tabActiveBase = LinearGradient(
    colors: [Color(0xFF252423), Color(0xFF252423)],
  );

  static const LinearGradient tabActiveSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x52FDE272),
      Color(0x00000000),
      Color(0x52FDE272),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldText = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.goldTextTop, VoltaColors.goldTextBottom],
  );

  static const LinearGradient countdownTitle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      VoltaColors.countdownTitleTop,
      VoltaColors.countdownTitleMid,
      VoltaColors.countdownTitleBottom,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient countdownDigits = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      VoltaColors.countdownDigitsTop,
      VoltaColors.countdownDigitsIvory,
      VoltaColors.countdownDigitsGold,
      VoltaColors.countdownDigitsBottom,
    ],
    stops: [0.0, 0.12, 0.5, 1.0],
  );

  static const LinearGradient homeGate = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[VoltaColors.homeGateTop, VoltaColors.homeGateBottom],
  );

  static const LinearGradient homeGateBorder = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      VoltaColors.homeGateBorder,
      VoltaColors.homeGateBorderBottom,
    ],
  );

  static const LinearGradient awayGate = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[VoltaColors.awayGateTop, VoltaColors.awayGateBottom],
  );

  static const LinearGradient homeStakeBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.homeStakeTop, VoltaColors.homeStakeBottom],
  );

  static const LinearGradient stakeBarBase = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.stakeBarTop, VoltaColors.stakeBarBottom],
  );

  static const RadialGradient stakeBarGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.0204,
    colors: [
      Color(0x80FF7197),
      Color(0x60BF5571),
      Color(0x4080394C),
      Color(0x20401C26),
      Color(0x00000000),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    transform: VoltaStakeGlowTransform(),
  );

  static const LinearGradient rebet = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.rebetTop, VoltaColors.rebetBottom],
  );

  static const LinearGradient doubleUp = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VoltaColors.doubleTop, VoltaColors.doubleBottom],
  );
}

@immutable
class VoltaStakeGlowTransform extends GradientTransform {
  const VoltaStakeGlowTransform();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    if (bounds.height <= 0) return null;
    final double scaleX = 0.5379 * bounds.width / bounds.height;
    final double centerX = bounds.center.dx;
    final double top = bounds.top;
    return Matrix4.identity()
      ..translateByDouble(centerX, top, 0, 1)
      ..scaleByDouble(scaleX, 1.0, 1.0, 1.0)
      ..translateByDouble(-centerX, -top, 0, 1);
  }
}

@immutable
class VoltaEllipseTransform extends GradientTransform {
  const VoltaEllipseTransform({
    required this.rx,
    required this.ry,
    required this.cx,
    required this.cy,
  });

  final double rx;
  final double ry;
  final double cx;
  final double cy;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double shortest = bounds.shortestSide;
    if (shortest <= 0 || ry <= 0) return null;
    final double sx = rx * bounds.width / (ry * shortest);
    final double sy = bounds.height / shortest;
    final double px = bounds.left + cx * bounds.width;
    final double py = bounds.top + cy * bounds.height;
    return Matrix4.identity()
      ..translateByDouble(px, py, 0, 1)
      ..scaleByDouble(sx, sy, 1.0, 1.0)
      ..translateByDouble(-px, -py, 0, 1);
  }
}

final LinearGradient voltaRailBase = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[
    Color(0xFF000000 | kVoltaRailBaseTop),
    Color(0xFF000000 | kVoltaRailBaseBottom),
  ],
);

final RadialGradient voltaRailTopGlow = RadialGradient(
  center: const Alignment(
    2 * kVoltaRailTopGlowCX - 1,
    2 * kVoltaRailTopGlowCY - 1,
  ),
  radius: kVoltaRailTopGlowRY,
  colors: <Color>[
    for (int i = 0; i < kVoltaRailTopGlowColors.length; i++)
      Color(
        ((kVoltaRailTopGlowAlphas[i] * 255).round().clamp(0, 255) << 24) |
            kVoltaRailTopGlowColors[i],
      ),
  ],
  stops: kVoltaRailTopGlowStops,
  transform: const VoltaEllipseTransform(
    rx: kVoltaRailTopGlowRX,
    ry: kVoltaRailTopGlowRY,
    cx: kVoltaRailTopGlowCX,
    cy: kVoltaRailTopGlowCY,
  ),
);

final RadialGradient voltaRailBottomGlow = RadialGradient(
  center: const Alignment(
    2 * kVoltaRailBottomGlowCX - 1,
    2 * kVoltaRailBottomGlowCY - 1,
  ),
  radius: kVoltaRailBottomGlowRY,
  colors: <Color>[
    Color(
      ((kVoltaRailBottomGlowAlpha * 255).round().clamp(0, 255) << 24) |
          0x000000,
    ),
    const Color(0x00000000),
  ],
  stops: const <double>[0, 1],
  transform: const VoltaEllipseTransform(
    rx: kVoltaRailBottomGlowRX,
    ry: kVoltaRailBottomGlowRY,
    cx: kVoltaRailBottomGlowCX,
    cy: kVoltaRailBottomGlowCY,
  ),
);

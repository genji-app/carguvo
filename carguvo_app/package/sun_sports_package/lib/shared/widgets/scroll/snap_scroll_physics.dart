import 'package:flutter/widgets.dart';

class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({required this.itemWidth, super.parent});

  final double itemWidth;

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      itemWidth: itemWidth,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = position.pixels / itemWidth;
    if (velocity < -tolerance.velocity) {
      page = page.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }
    return page * itemWidth;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(
      position,
      tolerance,
      velocity,
    ).clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

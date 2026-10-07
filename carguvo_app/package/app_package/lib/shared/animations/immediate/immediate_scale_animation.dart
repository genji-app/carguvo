// ignore_for_file: always_use_package_imports

import 'package:flutter/widgets.dart';
import 'immediate_animation.dart';

class ImmediateScaleAnimation extends ImmediateImplicitAnimation<double> {
  const ImmediateScaleAnimation({
    required super.child,
    required super.duration,
    super.begin = 0,
    super.end = 1,
    super.curve,
    super.delay,
    super.key,
  });

  @override
  ImmediateImplictAnimationState<ImmediateImplicitAnimation<double>, double>
  createState() => _ImmediateScaleAnimationState();
}

class _ImmediateScaleAnimationState
    extends ImmediateImplictAnimationState<ImmediateScaleAnimation, double> {
  @override
  ImplicitlyAnimatedWidget buildAnimated(Widget child, double value) =>
      AnimatedScale(
        scale: value,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      );
}

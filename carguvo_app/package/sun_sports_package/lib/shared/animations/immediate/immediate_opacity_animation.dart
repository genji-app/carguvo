// ignore_for_file: always_use_package_imports

import 'package:flutter/widgets.dart';
import 'immediate_animation.dart';

class ImmediateOpacityAnimation extends ImmediateImplicitAnimation<double> {
  const ImmediateOpacityAnimation({
    required super.child,
    required super.duration,
    super.begin = 0,
    super.end = 1,
    super.curve,
    super.delay,
    super.key,
  });

  @override
  ImmediateImplictAnimationState<ImmediateOpacityAnimation, double>
  createState() => _ImmediateOpacityAnimationState();
}

class _ImmediateOpacityAnimationState
    extends ImmediateImplictAnimationState<ImmediateOpacityAnimation, double> {
  @override
  ImplicitlyAnimatedWidget buildAnimated(Widget child, double value) =>
      AnimatedOpacity(
        opacity: value,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      );
}

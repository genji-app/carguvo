// ignore_for_file: always_use_package_imports

import 'package:flutter/widgets.dart';
import 'immediate_animation.dart';

class ImmediateSlideAnimation extends ImmediateImplicitAnimation<Offset> {
  const ImmediateSlideAnimation({
    required super.child,
    required super.duration,
    required super.begin,
    super.end = Offset.zero,
    super.curve,
    super.delay,
    super.key,
  });

  @override
  ImmediateImplictAnimationState<ImmediateImplicitAnimation<Offset>, Offset>
  createState() => _ImmediateSlideAnimationState();
}

class _ImmediateSlideAnimationState
    extends ImmediateImplictAnimationState<ImmediateSlideAnimation, Offset> {
  @override
  ImplicitlyAnimatedWidget buildAnimated(Widget child, Offset value) =>
      AnimatedSlide(
        offset: value,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      );
}

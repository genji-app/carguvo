import 'package:flutter/material.dart';

abstract class ImmediateImplicitAnimation<T> extends StatefulWidget {
  const ImmediateImplicitAnimation({
    required this.child,
    required this.duration,
    required this.begin,
    required this.end,
    this.curve = Curves.easeInOut,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final T begin;
  final T end;
  final Curve curve;
  final Duration delay;
}

abstract class ImmediateImplictAnimationState<
  T extends ImmediateImplicitAnimation<S>,
  S
>
    extends State<T> {
  late Widget _child;

  ImplicitlyAnimatedWidget buildAnimated(Widget child, S value);

  @override
  void initState() {
    super.initState();

    _child = buildAnimated(widget.child, widget.begin);

    _update();
  }

  Future<void> _update() async {
    await Future<void>.delayed(widget.delay);

    if (mounted) {
      setState(() => _child = buildAnimated(widget.child, widget.end));
    }
  }

  @override
  Widget build(BuildContext context) => _child;
}

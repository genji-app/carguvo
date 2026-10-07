import 'package:flutter/material.dart';

class AfterRouteTransition extends StatefulWidget {
  const AfterRouteTransition({super.key, required this.builder, this.placeholder});

  final WidgetBuilder builder;

  final Widget? placeholder;

  @override
  State<AfterRouteTransition> createState() => _AfterRouteTransitionState();
}

class _AfterRouteTransitionState extends State<AfterRouteTransition> {
  bool _ready = false;
  Animation<double>? _animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;

    final animation = ModalRoute.of(context)?.animation;
    if (animation == null ||
        animation.status == AnimationStatus.completed ||
        animation.value >= 1.0) {
      _ready = true;
      return;
    }

    if (!identical(_animation, animation)) {
      _animation?.removeStatusListener(_onStatus);
      _animation = animation;
      animation.addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (!_ready && status == AnimationStatus.completed && mounted) {
      setState(() => _ready = true);
      _animation?.removeStatusListener(_onStatus);
    }
  }

  @override
  void dispose() {
    _animation?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.builder(context);
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

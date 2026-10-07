import 'package:flutter/material.dart';

class OverlayVisibilityGate extends StatefulWidget {
  const OverlayVisibilityGate({
    required this.animation,
    required this.isVisible,
    required this.child,
    this.onDismissed,
    super.key,
  });

  final AnimationController animation;

  final bool isVisible;

  final Widget child;

  final VoidCallback? onDismissed;

  @override
  State<OverlayVisibilityGate> createState() => _OverlayVisibilityGateState();
}

class _OverlayVisibilityGateState extends State<OverlayVisibilityGate> {
  bool _isChildMounted = false;

  @override
  void initState() {
    super.initState();
    _isChildMounted = widget.isVisible || !widget.animation.isDismissed;
    widget.animation.addStatusListener(_onAnimationStatus);
  }

  @override
  void didUpdateWidget(covariant OverlayVisibilityGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_onAnimationStatus);
      widget.animation.addStatusListener(_onAnimationStatus);
    }

    if (widget.isVisible && !_isChildMounted) {
      setState(() => _isChildMounted = true);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _isChildMounted) {
      setState(() => _isChildMounted = false);
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onAnimationStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChildMounted) return const SizedBox.shrink();
    return widget.child;
  }
}

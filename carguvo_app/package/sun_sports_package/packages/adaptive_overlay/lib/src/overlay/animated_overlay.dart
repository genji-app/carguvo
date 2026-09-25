import 'package:flutter/material.dart';

import 'overlay_slide_transition.dart';
import 'overlay_visibility_gate.dart';

class AnimatedOverlayController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void open() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}

class AnimatedOverlay extends StatefulWidget {
  const AnimatedOverlay({
    required this.child,
    required this.alignment,
    super.key,
    this.isVisible = false,
    this.controller,
    this.onBackdropTap,
    this.duration = const Duration(milliseconds: 300),
    this.slideBeginOffset = const Offset(1.0, 0.0),
    this.backdropColor = Colors.black54,
    this.constraints,
    this.decoration,
    this.clipBehavior = Clip.none,
    this.onDismissed,
  });

  final Widget child;

  final bool isVisible;

  final AnimatedOverlayController? controller;

  final VoidCallback? onBackdropTap;

  final Duration duration;

  final Offset slideBeginOffset;

  final AlignmentGeometry alignment;

  final Color backdropColor;

  final BoxConstraints? constraints;

  final BoxDecoration? decoration;

  final Clip clipBehavior;

  final VoidCallback? onDismissed;

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool get _shouldBeVisible => widget.controller?.isVisible ?? widget.isVisible;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupAnimations();

    if (_shouldBeVisible) {
      _animationController.value = 1.0;
    }

    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant AnimatedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration ||
        widget.slideBeginOffset != oldWidget.slideBeginOffset) {
      _animationController.duration = widget.duration;
      _setupAnimations();
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }

    if (oldWidget.isVisible != widget.isVisible && widget.controller == null) {
      _updateAnimationState(widget.isVisible);
    }
  }

  void _handleControllerChange() {
    if (widget.controller != null) {
      _updateAnimationState(widget.controller!.isVisible);
    }
  }

  void _updateAnimationState(bool visible) {
    if (visible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _setupAnimations() {
    _slideAnimation =
        Tween<Offset>(begin: widget.slideBeginOffset, end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayVisibilityGate(
      animation: _animationController,
      isVisible: _shouldBeVisible,
      onDismissed: widget.onDismissed,
      child: AnimatedBuilder(
        animation: _animationController,
        child: Container(
          clipBehavior: widget.clipBehavior,
          constraints: widget.constraints,
          decoration: widget.decoration,
          child: widget.child,
        ),
        builder: (context, cachedChild) {
          return OverlaySlideTransition(
            slideAnimation: _slideAnimation,
            fadeAnimation: _fadeAnimation,
            alignment: widget.alignment,
            backdropColor: widget.backdropColor,
            onBackdropTap: widget.onBackdropTap,
            child: cachedChild!,
          );
        },
      ),
    );
  }
}

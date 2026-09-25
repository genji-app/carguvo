import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class AnimatedOverlayTooltipContent extends StatefulWidget {
  const AnimatedOverlayTooltipContent({
    required this.child,
    required this.onClose,
    required this.alignment,
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.allowBackgroundInteraction = false,
  });

  final Widget child;
  final VoidCallback onClose;
  final Alignment alignment;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  final bool allowBackgroundInteraction;

  @override
  State<AnimatedOverlayTooltipContent> createState() =>
      _AnimatedOverlayTooltipContentState();
}

class _AnimatedOverlayTooltipContentState
    extends State<AnimatedOverlayTooltipContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.allowBackgroundInteraction
              ? IgnorePointer(child: Container(color: Colors.transparent))
              : GestureDetector(
                  onTap: SoundTap.wrap(widget.onClose),
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
        ),

        Positioned(
          top: widget.top,
          left: widget.left,
          right: widget.right,
          bottom: widget.bottom,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: widget.alignment,
              child: GestureDetector(
                onTap: SoundTap.wrap(() {}),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class OverlaySlideTransition extends StatelessWidget {
  const OverlaySlideTransition({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.alignment,
    required this.child,
    this.backdropColor = Colors.black54,
    this.onBackdropTap,
    super.key,
  });

  final Animation<Offset> slideAnimation;

  final Animation<double> fadeAnimation;

  final AlignmentGeometry alignment;

  final Widget child;

  final Color backdropColor;

  final VoidCallback? onBackdropTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (backdropColor != Colors.transparent)
          FadeTransition(
            opacity: fadeAnimation,
            child: GestureDetector(
              onTap: onBackdropTap,
              behavior: HitTestBehavior.opaque,
              child: Container(color: backdropColor),
            ),
          )
        else if (onBackdropTap != null)
          GestureDetector(
            onTap: onBackdropTap,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),

        Align(
          alignment: alignment,
          child: SlideTransition(position: slideAnimation, child: child),
        ),
      ],
    );
  }
}

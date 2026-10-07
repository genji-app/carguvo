import 'package:flutter/material.dart';

import 'adaptive_overlay.dart';

class AdaptiveOverlayClose extends StatelessWidget {
  const AdaptiveOverlayClose({
    super.key,
    this.child,
    this.onPressed,
    this.padding,
  });

  final Widget? child;

  final VoidCallback? onPressed;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final controller = AdaptiveOverlay.of(context);

    return IconButton(
      padding: padding,
      icon: child ?? const Icon(Icons.close, color: Colors.white),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          controller.close();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class OverlayTooltipContent extends StatelessWidget {
  const OverlayTooltipContent({
    required this.child,
    required this.onClose,
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.allowBackgroundInteraction = false,
  });

  final Widget child;
  final VoidCallback onClose;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  final bool allowBackgroundInteraction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: allowBackgroundInteraction
              ? IgnorePointer(child: Container(color: Colors.transparent))
              : GestureDetector(
                  onTap: SoundTap.wrap(onClose),
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
        ),

        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: GestureDetector(
            onTap: SoundTap.wrap(() {}),
            child: child,
          ),
        ),
      ],
    );
  }
}

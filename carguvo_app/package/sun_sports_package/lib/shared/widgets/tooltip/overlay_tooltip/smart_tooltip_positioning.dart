import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

class TooltipPositioning {
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final ArrowPosition arrowPosition;

  const TooltipPositioning({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.arrowPosition,
  });

  TooltipPositioning copyWith({
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? offset,
    ArrowPosition? arrowPosition,
  }) {
    return TooltipPositioning(
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      offset: offset ?? this.offset,
      arrowPosition: arrowPosition ?? this.arrowPosition,
    );
  }

  static const TooltipPositioning below = TooltipPositioning(
    targetAnchor: Alignment.bottomRight,
    followerAnchor: Alignment.topRight,
    offset: Offset(8, 4),
    arrowPosition: ArrowPosition.topRight,
  );

  static const TooltipPositioning above = TooltipPositioning(
    targetAnchor: Alignment.topRight,
    followerAnchor: Alignment.bottomRight,
    offset: Offset(8, -4),
    arrowPosition: ArrowPosition.bottomRight,
  );
}

mixin SmartTooltipPositioning {
  TooltipPositioning calculateTooltipPosition(
    BuildContext context, {
    required double tooltipHeight,
    required double bottomThreshold,
    Offset? customOffsetBelow,
    Offset? customOffsetAbove,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return TooltipPositioning.below.copyWith(offset: customOffsetBelow);
    }

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - buttonPosition.dy - renderBox.size.height;

    final shouldShowAbove = spaceBelow < (tooltipHeight + bottomThreshold);

    if (shouldShowAbove) {
      return TooltipPositioning.above.copyWith(offset: customOffsetAbove);
    } else {
      return TooltipPositioning.below.copyWith(offset: customOffsetBelow);
    }
  }
}

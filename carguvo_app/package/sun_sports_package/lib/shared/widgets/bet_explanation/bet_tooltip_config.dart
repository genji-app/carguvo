import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

class BetTooltipConfig {

  final double? tooltipWidth;

  final double? tooltipMaxHeight;

  final BoxConstraints? tooltipConstraints;

  final EdgeInsets? tooltipPadding;

  final bool useSmartPositioning;

  final double bottomThreshold;

  final Alignment? targetAnchor;

  final Alignment? followerAnchor;

  final Offset? offset;

  final ArrowPosition? arrowPosition;

  final double arrowOffset;

  final bool autoCloseOnScroll;

  final bool dismissOnTapOutside;

  final bool rootOverlay;

  final Color? triggerColor;

  final double triggerSize;

  final EdgeInsets triggerPadding;

  final double triggerBorderRadius;

  final Widget? triggerIcon;

  final Color? triggerSplashColor;

  const BetTooltipConfig({
    this.tooltipWidth = 275.0,
    this.tooltipMaxHeight = 440.0,
    this.tooltipConstraints,
    this.tooltipPadding,
    this.useSmartPositioning = true,
    this.bottomThreshold = 100.0,
    this.targetAnchor,
    this.followerAnchor,
    this.offset,
    this.arrowPosition,
    this.arrowOffset = 14.0,
    this.autoCloseOnScroll = true,
    this.dismissOnTapOutside = true,
    this.rootOverlay = false,
    this.triggerColor,
    this.triggerSize = 18.0,
    this.triggerPadding = const EdgeInsets.all(4.0),
    this.triggerBorderRadius = 100.0,
    this.triggerIcon,
    this.triggerSplashColor,
  });

  BetTooltipConfig copyWith({
    double? tooltipWidth,
    double? tooltipMaxHeight,
    BoxConstraints? tooltipConstraints,
    EdgeInsets? tooltipPadding,
    bool? useSmartPositioning,
    double? bottomThreshold,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? offset,
    ArrowPosition? arrowPosition,
    double? arrowOffset,
    bool? autoCloseOnScroll,
    bool? dismissOnTapOutside,
    bool? rootOverlay,
    Color? triggerColor,
    double? triggerSize,
    EdgeInsets? triggerPadding,
    double? triggerBorderRadius,
    Widget? triggerIcon,
    Color? triggerSplashColor,
  }) {
    return BetTooltipConfig(
      tooltipWidth: tooltipWidth ?? this.tooltipWidth,
      tooltipMaxHeight: tooltipMaxHeight ?? this.tooltipMaxHeight,
      tooltipConstraints: tooltipConstraints ?? this.tooltipConstraints,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      useSmartPositioning: useSmartPositioning ?? this.useSmartPositioning,
      bottomThreshold: bottomThreshold ?? this.bottomThreshold,
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      offset: offset ?? this.offset,
      arrowPosition: arrowPosition ?? this.arrowPosition,
      arrowOffset: arrowOffset ?? this.arrowOffset,
      autoCloseOnScroll: autoCloseOnScroll ?? this.autoCloseOnScroll,
      dismissOnTapOutside: dismissOnTapOutside ?? this.dismissOnTapOutside,
      rootOverlay: rootOverlay ?? this.rootOverlay,
      triggerColor: triggerColor ?? this.triggerColor,
      triggerSize: triggerSize ?? this.triggerSize,
      triggerPadding: triggerPadding ?? this.triggerPadding,
      triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
      triggerIcon: triggerIcon ?? this.triggerIcon,
      triggerSplashColor: triggerSplashColor ?? this.triggerSplashColor,
    );
  }

  BoxConstraints getEffectiveConstraints() {
    if (tooltipConstraints != null) {
      return tooltipConstraints!;
    }

    return BoxConstraints(
      maxWidth: tooltipWidth ?? 275.0,
      maxHeight: tooltipMaxHeight ?? 440.0,
    );
  }
}

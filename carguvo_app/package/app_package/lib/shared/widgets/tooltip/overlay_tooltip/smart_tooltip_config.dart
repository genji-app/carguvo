import 'package:flutter/material.dart';
import 'arrow_position.dart';

class SmartTooltipConfig {
  final double? tooltipWidth;

  final double? tooltipMaxHeight;

  final EdgeInsets? tooltipPadding;

  final ArrowPosition? arrowPosition;

  final double? arrowOffset;

  final Widget Function(Widget content)? tooltipContainerBuilder;

  final Alignment alignment;

  final Offset offset;

  final bool autoPosition;

  final BoxConstraints? tooltipConstraints;

  final Alignment targetAnchor;

  final Alignment followerAnchor;

  final Offset compositedOffset;

  final bool autoCloseOnScroll;

  final bool dismissOnTapOutside;

  final bool enableAnimation;

  final bool allowBackgroundInteraction;

  final bool rootOverlay;

  final double triggerSize;

  final EdgeInsets triggerPadding;

  final String? triggerIconPath;

  final Widget? triggerIcon;

  final Color? triggerColor;

  final double triggerBorderRadius;

  final Color? triggerSplashColor;

  const SmartTooltipConfig({
    this.tooltipWidth,
    this.tooltipMaxHeight,
    this.tooltipPadding,
    this.arrowPosition,
    this.arrowOffset,
    this.tooltipContainerBuilder,

    this.alignment = Alignment.bottomRight,
    this.offset = const Offset(-12, 12),
    this.autoPosition = true,
    this.tooltipConstraints,

    this.targetAnchor = Alignment.bottomRight,
    this.followerAnchor = Alignment.topRight,
    this.compositedOffset = const Offset(-12, 12),

    this.autoCloseOnScroll = true,
    this.dismissOnTapOutside = true,
    this.enableAnimation = true,
    this.allowBackgroundInteraction = false,
    this.rootOverlay = true,

    this.triggerSize = 18.0,
    this.triggerPadding = const EdgeInsets.all(4.0),
    this.triggerIconPath,
    this.triggerIcon,
    this.triggerColor,
    this.triggerBorderRadius = 100.0,
    this.triggerSplashColor,
  });

  static const defaults = SmartTooltipConfig();

  static const compact = SmartTooltipConfig(
    tooltipWidth: 250.0,
    triggerSize: 16.0,
    triggerPadding: EdgeInsets.all(2.0),
  );

  static const large = SmartTooltipConfig(
    tooltipWidth: 400.0,
    tooltipMaxHeight: 600.0,
    triggerSize: 24.0,
  );

  static const topAligned = SmartTooltipConfig(
    alignment: Alignment.topRight,
    targetAnchor: Alignment.topRight,
    followerAnchor: Alignment.bottomRight,
    arrowPosition: ArrowPosition.bottomRight,
  );

  static const bottomAligned = SmartTooltipConfig(
    alignment: Alignment.bottomRight,
    targetAnchor: Alignment.bottomRight,
    followerAnchor: Alignment.topRight,
    arrowPosition: ArrowPosition.topRight,
  );

  SmartTooltipConfig copyWith({
    double? tooltipWidth,
    double? tooltipMaxHeight,
    EdgeInsets? tooltipPadding,
    ArrowPosition? arrowPosition,
    double? arrowOffset,
    Widget Function(Widget content)? tooltipContainerBuilder,
    Alignment? alignment,
    Offset? offset,
    bool? autoPosition,
    BoxConstraints? tooltipConstraints,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? compositedOffset,
    bool? autoCloseOnScroll,
    bool? dismissOnTapOutside,
    bool? enableAnimation,
    bool? allowBackgroundInteraction,
    bool? rootOverlay,
    double? triggerSize,
    EdgeInsets? triggerPadding,
    String? triggerIconPath,
    Widget? triggerIcon,
    Color? triggerColor,
    double? triggerBorderRadius,
    Color? triggerSplashColor,
  }) {
    return SmartTooltipConfig(
      tooltipWidth: tooltipWidth ?? this.tooltipWidth,
      tooltipMaxHeight: tooltipMaxHeight ?? this.tooltipMaxHeight,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      arrowPosition: arrowPosition ?? this.arrowPosition,
      arrowOffset: arrowOffset ?? this.arrowOffset,
      tooltipContainerBuilder:
          tooltipContainerBuilder ?? this.tooltipContainerBuilder,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      autoPosition: autoPosition ?? this.autoPosition,
      tooltipConstraints: tooltipConstraints ?? this.tooltipConstraints,
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      compositedOffset: compositedOffset ?? this.compositedOffset,
      autoCloseOnScroll: autoCloseOnScroll ?? this.autoCloseOnScroll,
      dismissOnTapOutside: dismissOnTapOutside ?? this.dismissOnTapOutside,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      allowBackgroundInteraction:
          allowBackgroundInteraction ?? this.allowBackgroundInteraction,
      rootOverlay: rootOverlay ?? this.rootOverlay,
      triggerSize: triggerSize ?? this.triggerSize,
      triggerPadding: triggerPadding ?? this.triggerPadding,
      triggerIconPath: triggerIconPath ?? this.triggerIconPath,
      triggerIcon: triggerIcon ?? this.triggerIcon,
      triggerColor: triggerColor ?? this.triggerColor,
      triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
      triggerSplashColor: triggerSplashColor ?? this.triggerSplashColor,
    );
  }
}

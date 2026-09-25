import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';
import 'bet_tooltip_config.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetExplanationTooltip extends StatefulWidget {
  final HintData hintData;

  final Widget Function(VoidCallback onTap)? triggerBuilder;

  final BetTooltipConfig config;

  final SmartTooltipController? controller;

  final VoidCallback? onShow;

  final VoidCallback? onHide;

  final String? titleOverride;

  const BetExplanationTooltip({
    required this.hintData,
    super.key,
    this.triggerBuilder,
    this.config = const BetTooltipConfig(),
    this.controller,
    this.onShow,
    this.onHide,
    this.titleOverride,
  });

  factory BetExplanationTooltip.icon({
    required HintData hintData,
    Key? key,
    Color? iconColor,
    double iconSize = 18.0,
    BetTooltipConfig config = const BetTooltipConfig(),
    SmartTooltipController? controller,
    VoidCallback? onShow,
    VoidCallback? onHide,
    String? titleOverride,
  }) {
    return BetExplanationTooltip(
      hintData: hintData,
      key: key,
      config: config.copyWith(triggerColor: iconColor, triggerSize: iconSize),
      controller: controller,
      onShow: onShow,
      onHide: onHide,
      titleOverride: titleOverride,
    );
  }

  @override
  State<BetExplanationTooltip> createState() => _BetExplanationTooltipState();
}

class _BetExplanationTooltipState extends State<BetExplanationTooltip>
    with SmartTooltipPositioning {
  late final CompositedTooltipController _tooltipController;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _tooltipController = CompositedTooltipController();
    _attachExternalController();
  }

  @override
  void didUpdateWidget(BetExplanationTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attachExternalController();
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _tooltipController.dispose();
    super.dispose();
  }

  void _attachExternalController() {
    widget.controller?.attach(onShow: _showTooltip, onHide: _hideTooltip);
  }

  void _showTooltip() {
    _tooltipController.remove();
    _isShowing = false;

    final config = widget.config;

    final tooltipContent = _buildTooltipContent();

    if (config.useSmartPositioning) {
      _showWithSmartPositioning(tooltipContent);
    } else {
      _showWithManualPositioning(tooltipContent);
    }

    _isShowing = true;
    widget.controller?.updateState(true);
    widget.onShow?.call();
  }

  void _showWithSmartPositioning(Widget content) {
    final config = widget.config;

    final contentHeight = _measureContentHeight(content, config);

    final triggerRenderBox = context.findRenderObject() as RenderBox?;
    if (triggerRenderBox == null || !triggerRenderBox.hasSize) {
      _showWithManualPositioning(content);
      return;
    }

    final triggerOffset = triggerRenderBox.localToGlobal(Offset.zero);
    final triggerSize = triggerRenderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceAbove = triggerOffset.dy;
    final spaceBelow = screenHeight - (triggerOffset.dy + triggerSize.height);

    final shouldShowAbove = _shouldShowAbove(
      contentHeight: contentHeight,
      spaceAbove: spaceAbove,
      spaceBelow: spaceBelow,
      bottomThreshold: config.bottomThreshold,
    );

    final adjustedContent = _adjustContentConstraints(
      content: content,
      contentHeight: contentHeight,
      availableSpace: shouldShowAbove ? spaceAbove : spaceBelow,
      config: config,
    );

    final positioning = TooltipPositioning(
      targetAnchor:
          config.targetAnchor ??
          (shouldShowAbove ? Alignment.topRight : Alignment.bottomRight),
      followerAnchor:
          config.followerAnchor ??
          (shouldShowAbove ? Alignment.bottomRight : Alignment.topRight),
      offset:
          config.offset ??
          (shouldShowAbove ? const Offset(-12, -12) : const Offset(-12, 12)),
      arrowPosition: shouldShowAbove
          ? ArrowPosition.bottomRight
          : ArrowPosition.topRight,
    ).copyWith(arrowPosition: ArrowPosition.none);

    _tooltipController.show(
      context: context,
      targetAnchor: positioning.targetAnchor,
      followerAnchor: positioning.followerAnchor,
      offset: positioning.offset,
      autoCloseOnScroll: config.autoCloseOnScroll,
      rootOverlay: config.rootOverlay,
      dismissOnTapOutside: config.dismissOnTapOutside,
      builder: (onClose) => TooltipContainer(
        padding: config.tooltipPadding ?? EdgeInsets.zero,
        arrowPosition: config.arrowPosition ?? positioning.arrowPosition,
        arrowOffset: config.arrowOffset,
        child: adjustedContent,
      ),
    );
  }

  double _measureContentHeight(Widget content, BetTooltipConfig config) {
    return config.tooltipMaxHeight ?? 440.0;
  }

  bool _shouldShowAbove({
    required double contentHeight,
    required double spaceAbove,
    required double spaceBelow,
    required double bottomThreshold,
  }) {
    if (spaceBelow >= contentHeight + bottomThreshold) {
      return false;
    }

    if (spaceAbove > spaceBelow) {
      return true;
    }

    return false;
  }

  Widget _adjustContentConstraints({
    required Widget content,
    required double contentHeight,
    required double availableSpace,
    required BetTooltipConfig config,
  }) {
    const safetyPadding = 60.0;
    final maxAllowedHeight = availableSpace - safetyPadding;

    if (contentHeight <= maxAllowedHeight) {
      return content;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: config.tooltipWidth ?? 275.0,
        maxHeight: maxAllowedHeight.clamp(
          200.0,
          config.tooltipMaxHeight ?? 440.0,
        ),
      ),
      child: content,
    );
  }

  void _showWithManualPositioning(Widget content) {
    final config = widget.config;

    _tooltipController.show(
      context: context,
      targetAnchor: config.targetAnchor ?? Alignment.bottomRight,
      followerAnchor: config.followerAnchor ?? Alignment.topRight,
      offset: config.offset ?? const Offset(-12, 12),
      autoCloseOnScroll: config.autoCloseOnScroll,
      rootOverlay: config.rootOverlay,
      dismissOnTapOutside: config.dismissOnTapOutside,
      builder: (onClose) => TooltipContainer(
        padding: config.tooltipPadding ?? EdgeInsets.zero,
        arrowPosition: config.arrowPosition ?? ArrowPosition.topRight,
        arrowOffset: config.arrowOffset,
        child: content,
      ),
    );
  }

  Widget _buildTooltipContent() {
    final constraints = widget.config.getEffectiveConstraints();

    return ConstrainedBox(
      constraints: constraints,
      child: SingleChildScrollView(
        child: HintContentWidget(
          hintData: widget.hintData,
          titleOverride: widget.titleOverride,
        ),
      ),
    );
  }

  void _hideTooltip() {
    if (!_isShowing) return;

    _tooltipController.remove();
    _isShowing = false;
    widget.controller?.updateState(false);
    widget.onHide?.call();
  }

  Widget _buildDefaultTrigger(VoidCallback onTap) {
    final config = widget.config;

    return InkWell(
      borderRadius: BorderRadius.circular(config.triggerBorderRadius),
      onTap: SoundTap.wrap(onTap),
      splashColor: config.triggerSplashColor,
      child: Padding(
        padding: config.triggerPadding,
        child: SizedBox.square(
          dimension: config.triggerSize,
          child:
              config.triggerIcon ??
              ImageHelper.load(
                path: AppIcons.iconInfo,
                color: config.triggerColor,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger =
        widget.triggerBuilder?.call(_showTooltip) ??
        _buildDefaultTrigger(_showTooltip);

    return _tooltipController.wrapTarget(child: trigger);
  }
}

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

import 'odds_style_explanation_content.dart';

class OddsStyleExplanationButton extends StatefulWidget {
  const OddsStyleExplanationButton({required this.odds, super.key});

  final OddsStyle odds;

  @override
  State<OddsStyleExplanationButton> createState() =>
      OddsStyleExplanationButtonState();
}

class OddsStyleExplanationButtonState
    extends State<OddsStyleExplanationButton> {
  late final CompositedTooltipController _tooltipController;

  static const double _tooltipMaxWidth = 299.0;
  static const double _tooltipMaxHeight = 440.0;
  static const double _tooltipArrowOffset = 0.0;
  static const double _tooltipBottomThreshold = 100.0;
  static const double _safetyMargin = 24.0;
  static const double _horizontalMargin = 8.0;

  @override
  void initState() {
    super.initState();
    _tooltipController = CompositedTooltipController();
  }

  @override
  void dispose() {
    _tooltipController.remove();
    super.dispose();
  }

  void _showTooltip(BuildContext context) {
    final (positioning, dynamicMaxHeight, dynamicMaxWidth) =
        _calculateSmartPositioning(context);

    final tooltipContent = _buildTooltipContent(
      dynamicMaxHeight,
      dynamicMaxWidth,
    );

    _tooltipController.show(
      context: context,
      targetAnchor: positioning.targetAnchor,
      followerAnchor: positioning.followerAnchor,
      offset: positioning.offset,
      rootOverlay: true,
      autoCloseOnScroll: true,
      dismissOnTapOutside: true,
      builder: (onClose) => TooltipContainer(
        padding: EdgeInsets.zero,
        arrowPosition: positioning.arrowPosition,
        arrowOffset: _tooltipArrowOffset,
        child: tooltipContent,
      ),
    );
  }

  (TooltipPositioning, double, double) _calculateSmartPositioning(
    BuildContext context,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return (
        TooltipPositioning.below.copyWith(
          offset: const Offset(0, -4),
          arrowPosition: ArrowPosition.none,
        ),
        _tooltipMaxHeight,
        _tooltipMaxWidth,
      );
    }

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final dynamicMaxWidth = (screenWidth - 2 * _horizontalMargin).clamp(
      0.0,
      _tooltipMaxWidth,
    );
    final buttonRight = buttonPosition.dx + renderBox.size.width;
    final tooltipLeft = buttonRight - dynamicMaxWidth;
    var dxShift = 0.0;
    if (tooltipLeft < _horizontalMargin) {
      final maxShift = (screenWidth - _horizontalMargin - buttonRight).clamp(
        0.0,
        double.infinity,
      );
      dxShift = (_horizontalMargin - tooltipLeft).clamp(0.0, maxShift);
    }

    final spaceBelow =
        screenHeight -
        buttonPosition.dy -
        renderBox.size.height -
        mediaQuery.padding.bottom;
    final spaceAbove = buttonPosition.dy - mediaQuery.padding.top;

    bool shouldShowAbove = false;
    if (spaceBelow < (_tooltipMaxHeight + _tooltipBottomThreshold) &&
        spaceAbove > spaceBelow) {
      shouldShowAbove = true;
    }

    double dynamicMaxHeight;
    TooltipPositioning positioning;

    if (shouldShowAbove) {
      dynamicMaxHeight = (spaceAbove - _safetyMargin).clamp(
        0.0,
        _tooltipMaxHeight,
      );
      positioning = TooltipPositioning.above.copyWith(
        offset: Offset(dxShift, 4),
        arrowPosition: ArrowPosition.none,
      );
    } else {
      dynamicMaxHeight = (spaceBelow - _safetyMargin).clamp(
        0.0,
        _tooltipMaxHeight,
      );
      positioning = TooltipPositioning.below.copyWith(
        offset: Offset(dxShift, -4),
        arrowPosition: ArrowPosition.none,
      );
    }

    return (positioning, dynamicMaxHeight, dynamicMaxWidth);
  }

  Widget _buildTooltipContent(double maxHeight, double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: SingleChildScrollView(
        child: OddsStyleExplanationContent(odds: widget.odds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: Builder(
        builder: (iconContext) => SizedBox.square(
          dimension: 44,
          child: InkWell(
            borderRadius: BorderRadius.circular(88),
            onTap: SoundTap.wrap(() => _showTooltip(iconContext)),
            child: Center(
              child: ImageHelper.load(
                path: AppIcons.helpCircle,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

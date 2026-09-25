import 'package:flutter/material.dart';
import 'arrow_position.dart';
import 'internal/animated_overlay_content.dart';
import 'internal/overlay_content.dart';

class OverlayTooltipController {
  OverlayEntry? _overlayEntry;

  void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required Widget Function(VoidCallback onClose, Alignment effectiveAlignment)
    builder,
    Offset offset = Offset.zero,
    Alignment alignment = Alignment.bottomRight,
    bool enableAnimation = true,
    bool rootOverlay = true,
    bool allowBackgroundInteraction = false,
    bool autoPosition = false,
    BoxConstraints tooltipConstraints = const BoxConstraints(
      maxWidth: 326.0,
      maxHeight: 400.0,
    ),
  }) {
    remove();

    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final effectiveAlignment = autoPosition
        ? _detectBestAlignment(
            targetPosition: position,
            targetSize: targetSize,
            screenSize: screenSize,
            tooltipConstraints: tooltipConstraints,
          )
        : alignment;

    final tooltipPosition = _calculatePosition(
      targetPosition: position,
      targetSize: targetSize,
      screenSize: screenSize,
      offset: offset,
      alignment: effectiveAlignment,
    );

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => enableAnimation
          ? AnimatedOverlayTooltipContent(
              top: tooltipPosition.top,
              left: tooltipPosition.left,
              right: tooltipPosition.right,
              bottom: tooltipPosition.bottom,
              alignment: effectiveAlignment,
              onClose: remove,
              allowBackgroundInteraction: allowBackgroundInteraction,
              child: builder(
                remove,
                effectiveAlignment,
              ),
            )
          : OverlayTooltipContent(
              top: tooltipPosition.top,
              left: tooltipPosition.left,
              right: tooltipPosition.right,
              bottom: tooltipPosition.bottom,
              onClose: remove,
              allowBackgroundInteraction: allowBackgroundInteraction,
              child: builder(
                remove,
                effectiveAlignment,
              ),
            ),
    );

    Overlay.of(context, rootOverlay: rootOverlay).insert(_overlayEntry!);
  }

  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool get isShowing => _overlayEntry != null;

  Alignment _detectBestAlignment({
    required Offset targetPosition,
    required Size targetSize,
    required Size screenSize,
    required BoxConstraints tooltipConstraints,
  }) {
    final tooltipWidth = tooltipConstraints.maxWidth;
    final tooltipHeight = tooltipConstraints.maxHeight;
    const minPadding = 16.0;

    final spaceAbove = targetPosition.dy;
    final spaceBelow =
        screenSize.height - (targetPosition.dy + targetSize.height);
    final spaceLeft = targetPosition.dx;
    final spaceRight =
        screenSize.width - (targetPosition.dx + targetSize.width);

    final fitsBelow = spaceBelow >= tooltipHeight + minPadding;

    final fitsAbove = spaceAbove >= tooltipHeight + minPadding;

    bool wouldOverflowRight(Alignment alignment) {
      if (alignment == Alignment.bottomRight ||
          alignment == Alignment.topRight) {
        final tooltipRight = targetPosition.dx + targetSize.width;
        final tooltipLeft = tooltipRight - tooltipWidth;
        return tooltipLeft < minPadding;
      }
      return false;
    }

    bool wouldOverflowLeft(Alignment alignment) {
      if (alignment == Alignment.bottomLeft || alignment == Alignment.topLeft) {
        final tooltipLeft = targetPosition.dx;
        final tooltipRight = tooltipLeft + tooltipWidth;
        return tooltipRight >
            screenSize.width - minPadding;
      }
      return false;
    }

    if (fitsBelow) {
      if (!wouldOverflowRight(Alignment.bottomRight)) {
        return Alignment.bottomRight;
      }
      if (!wouldOverflowLeft(Alignment.bottomLeft)) {
        return Alignment.bottomLeft;
      }
      return Alignment.bottomCenter;
    }

    if (fitsAbove) {
      if (!wouldOverflowRight(Alignment.topRight)) {
        return Alignment.topRight;
      }
      if (!wouldOverflowLeft(Alignment.topLeft)) {
        return Alignment.topLeft;
      }
      return Alignment.topCenter;
    }

    if (spaceBelow >= spaceAbove) {
      return spaceRight >= spaceLeft
          ? Alignment.bottomRight
          : Alignment.bottomLeft;
    } else {
      return spaceRight >= spaceLeft ? Alignment.topRight : Alignment.topLeft;
    }
  }

  _TooltipPosition _calculatePosition({
    required Offset targetPosition,
    required Size targetSize,
    required Size screenSize,
    required Offset offset,
    required Alignment alignment,
  }) {
    double? top, left, right, bottom;

    if (alignment == Alignment.bottomRight) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    } else if (alignment == Alignment.bottomLeft) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      left = targetPosition.dx + offset.dx;
    } else if (alignment == Alignment.topRight) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    } else if (alignment == Alignment.topLeft) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      left = targetPosition.dx + offset.dx;
    } else if (alignment == Alignment.bottomCenter) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      left = targetPosition.dx + (targetSize.width / 2) + offset.dx;
    } else if (alignment == Alignment.topCenter) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      left = targetPosition.dx + (targetSize.width / 2) + offset.dx;
    } else {
      top = targetPosition.dy + targetSize.height + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    }

    return _TooltipPosition(top: top, left: left, right: right, bottom: bottom);
  }

  static double? calculateArrowOffset({
    required GlobalKey targetKey,
    required double tooltipWidth,
    required Alignment alignment,
    required ArrowPosition arrowPosition,
  }) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return null;

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final targetCenterX = targetPosition.dx + (targetSize.width / 2);

    if (arrowPosition == ArrowPosition.topRight ||
        arrowPosition == ArrowPosition.bottomRight) {
      final tooltipRight = targetPosition.dx + targetSize.width;
      final offset = tooltipRight - targetCenterX;
      return offset.clamp(8.0, tooltipWidth - 20.0);
    } else if (arrowPosition == ArrowPosition.topLeft ||
        arrowPosition == ArrowPosition.bottomLeft) {
      final tooltipLeft = targetPosition.dx;
      final offset = targetCenterX - tooltipLeft;
      return offset.clamp(8.0, tooltipWidth - 20.0);
    } else if (arrowPosition == ArrowPosition.top ||
        arrowPosition == ArrowPosition.bottom) {
      return 0.0;
    }

    return null;
  }
}

class _TooltipPosition {
  const _TooltipPosition({this.top, this.left, this.right, this.bottom});

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
}

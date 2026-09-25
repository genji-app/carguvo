import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'arrow_position.dart';
import 'internal/arrow_painter.dart';

class TooltipContainer extends StatelessWidget {
  const TooltipContainer({
    required this.child,
    super.key,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.arrowPosition = ArrowPosition.top,
    this.arrowOffset = 16.0,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final ArrowPosition arrowPosition;
  final double arrowOffset;

  static const double _arrowWidth = 15.0;
  static const double _arrowHeight = 9.0;

  @override
  Widget build(BuildContext context) {
    if (arrowPosition == ArrowPosition.none) {
      return _buildContainer();
    }

    final isHorizontalArrow = _isHorizontalArrow();
    final arrowWidget = _buildArrow();

    if (isHorizontalArrow) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isArrowOnLeft()) ...[
            arrowWidget,
            _buildContainer(),
          ] else ...[
            _buildContainer(),
            arrowWidget,
          ],
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _getColumnCrossAlignment(),
        children: [
          if (_isArrowOnBottom()) ...[
            _buildContainer(),
            arrowWidget,
          ] else ...[
            arrowWidget,
            _buildContainer(),
          ],
        ],
      );
    }
  }

  CrossAxisAlignment _getColumnCrossAlignment() {
    if (arrowPosition == ArrowPosition.topRight ||
        arrowPosition == ArrowPosition.bottomRight) {
      return CrossAxisAlignment.end;
    } else if (arrowPosition == ArrowPosition.top ||
        arrowPosition == ArrowPosition.bottom) {
      return CrossAxisAlignment.center;
    }
    return CrossAxisAlignment.start;
  }

  bool _isHorizontalArrow() {
    return arrowPosition == ArrowPosition.left ||
        arrowPosition == ArrowPosition.leftTop ||
        arrowPosition == ArrowPosition.leftBottom ||
        arrowPosition == ArrowPosition.right ||
        arrowPosition == ArrowPosition.rightTop ||
        arrowPosition == ArrowPosition.rightBottom;
  }

  bool _isArrowOnLeft() {
    return arrowPosition == ArrowPosition.left ||
        arrowPosition == ArrowPosition.leftTop ||
        arrowPosition == ArrowPosition.leftBottom;
  }

  bool _isArrowOnBottom() {
    return arrowPosition == ArrowPosition.bottom ||
        arrowPosition == ArrowPosition.bottomLeft ||
        arrowPosition == ArrowPosition.bottomRight;
  }

  EdgeInsets _getArrowEdgeInsets() {
    switch (arrowPosition) {
      case ArrowPosition.top:
      case ArrowPosition.bottom:
        return EdgeInsets.zero;
      case ArrowPosition.topLeft:
      case ArrowPosition.bottomLeft:
        return EdgeInsets.only(left: arrowOffset);
      case ArrowPosition.topRight:
      case ArrowPosition.bottomRight:
        return EdgeInsets.only(right: arrowOffset);
      case ArrowPosition.left:
      case ArrowPosition.right:
        return EdgeInsets.zero;
      case ArrowPosition.leftTop:
      case ArrowPosition.rightTop:
        return EdgeInsets.only(top: arrowOffset);
      case ArrowPosition.leftBottom:
      case ArrowPosition.rightBottom:
        return EdgeInsets.only(bottom: arrowOffset);
      default:
        return EdgeInsets.zero;
    }
  }

  Widget _buildContainer() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.50),
              offset: Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildArrow() {
    final isHorizontal = _isHorizontalArrow();
    final size = isHorizontal
        ? const Size(_arrowHeight, _arrowWidth)
        : const Size(_arrowWidth, _arrowHeight);

    double rotation = 0.0;

    switch (arrowPosition) {
      case ArrowPosition.top:
      case ArrowPosition.topLeft:
      case ArrowPosition.topRight:
        rotation = 3.14159;
        break;
      case ArrowPosition.bottom:
      case ArrowPosition.bottomLeft:
      case ArrowPosition.bottomRight:
        rotation = 0.0;
        break;
      case ArrowPosition.left:
      case ArrowPosition.leftTop:
      case ArrowPosition.leftBottom:
        rotation = 1.5708;
        break;
      case ArrowPosition.right:
      case ArrowPosition.rightTop:
      case ArrowPosition.rightBottom:
        rotation = -1.5708;
        break;
      default:
        rotation = 0.0;
    }

    return Padding(
      padding: _getArrowEdgeInsets(),
      child: Transform.rotate(
        angle: rotation,
        child: CustomPaint(
          size: size,
          painter: const TooltipArrowPainter(
            color: AppColorStyles.backgroundQuaternary,
          ),
        ),
      ),
    );
  }
}

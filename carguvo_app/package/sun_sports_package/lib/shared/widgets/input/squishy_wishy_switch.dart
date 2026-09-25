import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class SquishyWishySwitch extends StatefulWidget {
  const SquishyWishySwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.activeTrackColor = AppColors.yellow600,
    this.inactiveTrackColor = AppColorStyles.borderPrimary,
    this.activeThumbColor = Colors.white,
    this.inactiveThumbColor = AppColors.gray200,
    this.width = 64.0,
    this.height = 28.0,
    this.thumbWidth = 36.0,
    this.thumbHeight = 24.0,
    this.padding = 2.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.activeThumbChild,
    this.inactiveThumbChild,
    this.activeTrackChild,
    this.inactiveTrackChild,
    this.trackBorderRadius,
    this.thumbBorderRadius,
    this.activeTrackBorder,
    this.inactiveTrackBorder,
    this.enableSquish = true,
    this.squishExtent = 6.0,
    this.squishDuration = const Duration(milliseconds: 120),
    this.squishCurve = Curves.easeOut,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;

  final double width;
  final double height;
  final double thumbWidth;
  final double thumbHeight;
  final double padding;

  final Duration duration;
  final Curve curve;

  final Widget? activeThumbChild;
  final Widget? inactiveThumbChild;
  final Widget? activeTrackChild;
  final Widget? inactiveTrackChild;

  final BorderRadius? trackBorderRadius;
  final BorderRadius? thumbBorderRadius;
  final Border? activeTrackBorder;
  final Border? inactiveTrackBorder;

  final bool enableSquish;
  final double squishExtent;
  final Duration squishDuration;
  final Curve squishCurve;

  @override
  State<SquishyWishySwitch> createState() => _SquishyWishySwitchState();
}

class _SquishyWishySwitchState extends State<SquishyWishySwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _positionController;
  late Animation<double> _positionAnimation;

  bool _isPressed = false;
  double _dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _initAnimation();

    _positionController.value = widget.value ? 1.0 : 0.0;
  }

  void _initAnimation() {
    _positionAnimation = CurvedAnimation(
      parent: _positionController,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(SquishyWishySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) {
      _initAnimation();
    }
    if (oldWidget.duration != widget.duration) {
      _positionController.duration = widget.duration;
    }
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _positionController.forward();
      } else {
        _positionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  double get _maxDragDistance {
    return widget.width - (widget.padding * 2.0) - widget.thumbWidth;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _toggle();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isPressed = true;
    });
    _dragPosition = _positionController.value * _maxDragDistance;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragPosition += details.primaryDelta!;
    final double newValue = (_dragPosition / _maxDragDistance).clamp(0.0, 1.0);
    _positionController.value = newValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isPressed = false;
    });

    final bool isCurrentlyOn = _positionController.value > 0.5;
    if (isCurrentlyOn != widget.value) {
      widget.onChanged(isCurrentlyOn);
    } else {
      if (widget.value) {
        _positionController.forward();
      } else {
        _positionController.reverse();
      }
    }
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  Widget _buildThumbChild() {
    if (widget.activeThumbChild == null && widget.inactiveThumbChild == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.activeThumbChild != null)
          Opacity(
            opacity: _positionAnimation.value,
            child: widget.activeThumbChild,
          ),
        if (widget.inactiveThumbChild != null)
          Opacity(
            opacity: (1.0 - _positionAnimation.value).clamp(0.0, 1.0),
            child: widget.inactiveThumbChild,
          ),
      ],
    );
  }

  Widget _buildTrackBackground(double animationValue) {
    if (widget.activeTrackChild == null && widget.inactiveTrackChild == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(
              opacity: animationValue,
              child: widget.activeTrackChild ?? const SizedBox.shrink(),
            ),
            Opacity(
              opacity: (1.0 - animationValue).clamp(0.0, 1.0),
              child: widget.inactiveTrackChild ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb({
    required double leftOffset,
    required double width,
    required Color color,
  }) {
    return Positioned(
      left: leftOffset,
      top: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: widget.squishDuration,
        curve: widget.squishCurve,
        width: width,
        height: widget.thumbHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                widget.thumbBorderRadius ?? BorderRadius.circular(100),
            color: color,
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _buildThumbChild(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxThumbWidthLimit = widget.width - (widget.padding * 2.0);
    final double currentThumbWidth = widget.enableSquish && _isPressed
        ? (widget.thumbWidth + widget.squishExtent).clamp(
            widget.thumbWidth,
            maxThumbWidthLimit,
          )
        : widget.thumbWidth;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) {
          final double leftOffset =
              _positionAnimation.value *
              (widget.width - (widget.padding * 2.0) - currentThumbWidth);

          final Color trackColor = Color.lerp(
            widget.inactiveTrackColor,
            widget.activeTrackColor,
            _positionAnimation.value,
          )!;

          final Color thumbColor = Color.lerp(
            widget.inactiveThumbColor,
            widget.activeThumbColor,
            _positionAnimation.value,
          )!;

          final Border? trackBorder = Border.lerp(
            widget.inactiveTrackBorder,
            widget.activeTrackBorder,
            _positionAnimation.value,
          );

          return RepaintBoundary(
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius:
                    widget.trackBorderRadius ?? BorderRadius.circular(100),
                color: trackColor,
                border: trackBorder,
              ),
              padding: EdgeInsets.all(widget.padding),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTrackBackground(_positionAnimation.value),
                  _buildThumb(
                    leftOffset: leftOffset,
                    width: currentThumbWidth,
                    color: thumbColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

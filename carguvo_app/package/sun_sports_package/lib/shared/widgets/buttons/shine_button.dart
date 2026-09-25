import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/button_enums.dart';

export 'package:sun_sports/shared/domain/enums/button_enums.dart';

class ShineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final ShineButtonSize size;
  final bool isExpanded;
  final ShineButtonStyle style;
  final double? height;
  final double? width;
  final bool isEnabled;

  final bool autoSizeText;

  final AppSound tapSound;

  final int? maxLines;
  final TextOverflow? overflow;

  final double horizontalPadding;

  const ShineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = ShineButtonSize.xl,
    this.isExpanded = false,
    this.style = ShineButtonStyle.primaryGray,
    this.height = 48,
    this.width,
    this.isEnabled = true,
    this.autoSizeText = false,
    this.tapSound = AppSound.uiTap,
    this.maxLines,
    this.overflow,
    this.horizontalPadding = 24,
  }) : assert(
         maxLines == null || !autoSizeText,
         'maxLines cannot be combined with autoSizeText',
       );

  @override
  State<ShineButton> createState() => _ShineButtonState();
}

class _ShineButtonState extends State<ShineButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();
    final isEnabled = widget.isEnabled && widget.onPressed != null;

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: isEnabled ? (_) => setState(() => _isHovering = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovering = false) : null,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                SoundEffects.instance.play(widget.tapSound);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled
            ? () => setState(() => _isPressed = false)
            : null,
        child: !isEnabled
            ? Container(
                padding: widget.autoSizeText && widget.width != null
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(
                        horizontal: widget.horizontalPadding,
                      ),
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: AppColors.gray700,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: _wrapAutoSize(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leadingIcon != null) ...[
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: widget.leadingIcon,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildLabel(
                          AppTextStyles.buttonMedium(color: AppColors.gray500),
                        ),
                        if (widget.trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: widget.trailingIcon,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: padding,
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      gradient: !_isPressed && !_isHovering
                          ? widget.style.gradient
                          : null,
                      color: _isPressed
                          ? widget.style.pressedColor
                          : _isHovering
                          ? widget.style.hoverColor
                          : (widget.style.gradient == null
                                ? widget.style.defaultColor
                                : null),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Opacity(
                      opacity: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: widget.leadingIcon,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _buildLabel(
                            AppTextStyles.textStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.trailingIcon != null) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: widget.trailingIcon,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _isPressed
                          ? const ShineButtonPressedPainter()
                          : _isHovering
                          ? const ShineButtonHoverPainter()
                          : const ShineButtonDefaultPainter(),
                    ),
                  ),
                  _wrapContent(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leadingIcon != null) ...[
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: widget.leadingIcon,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildLabel(
                          AppTextStyles.buttonMedium(color: Colors.white),
                        ),
                        if (widget.trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: widget.trailingIcon,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );

    return button;
  }

  Widget _buildLabel(TextStyle style) {
    final text = Text(
      widget.text,
      style: style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
    if (widget.maxLines == null) return text;
    return Flexible(child: text);
  }

  Widget _wrapContent(Widget child) {
    if (widget.maxLines == null) return _wrapAutoSize(child);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: child,
    );
  }

  Widget _wrapAutoSize(Widget child) {
    if (!widget.autoSizeText || widget.width == null) return child;
    return SizedBox(
      width: widget.width,
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }

  EdgeInsets _getPadding() =>
      EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: 12);

  double _getFontSize() => 14;

  double _getIconSize() => 20;
}

class ShineButtonDefaultPainter extends CustomPainter {
  const ShineButtonDefaultPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.24),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: [0.0, 0.5523],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
    canvas.restore();

    const strokeWidth = 1.0;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(
          3.7 * 3 / 4,
        ),
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(255, 255, 255, 0.18),
          Color.fromRGBO(255, 255, 255, 0.24),
          Color.fromRGBO(255, 255, 255, 0.18),
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.0),
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShineButtonHoverPainter extends CustomPainter {
  const ShineButtonHoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: [0.0, 0.5523],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
    canvas.restore();

    const strokeWidth = 1.0;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(3.7 * 3 / 4),
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(255, 255, 255, 0.06),
          Color.fromRGBO(255, 255, 255, 0.09),
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(255, 255, 255, 0.09),
          Color.fromRGBO(255, 255, 255, 0.06),
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.0),
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShineButtonPressedPainter extends CustomPainter {
  const ShineButtonPressedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    canvas.restore();

    const strokeWidth = 1.5;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(3.7 * 3 / 4),
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.12),
          Color.fromRGBO(0, 0, 0, 0.18),
          Color.fromRGBO(0, 0, 0, 0.24),
          Color.fromRGBO(0, 0, 0, 0.18),
          Color.fromRGBO(0, 0, 0, 0.12),
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.0),
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

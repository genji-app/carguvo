import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/shared/widgets/buttons/shine_button.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';

class WelcomeBannerArt {
  const WelcomeBannerArt._();

  static const double _designCardWidth = 540;

  static const double sun88Min = 135;
  static const double sun88Max = 190;
  static const double secondMin = 125;
  static const double secondMax = 153;

  static const double sun88Aspect = 610 / 614;
  static const double secondAspect = 576 / 480;

  static double _floor(double designMin, double? cardHeight, double aspect,
          double designMax) =>
      cardHeight == null
          ? designMin
          : math.max(designMin, math.min(cardHeight * aspect, designMax));

  static double sun88(double cardWidth, {double? cardHeight}) =>
      (cardWidth * (sun88Max / _designCardWidth)).clamp(
        _floor(sun88Min, cardHeight, sun88Aspect, sun88Max),
        sun88Max,
      );

  static double second(double cardWidth, {double? cardHeight}) =>
      (cardWidth * (secondMax / _designCardWidth)).clamp(
        _floor(secondMin, cardHeight, secondAspect, secondMax),
        secondMax,
      );

  static const double sun88Width = 122;
  static const double sun88Top = 6;
  static const double sun88Right = 10;

  static const double hoverScale = 1.1;

  static const Alignment hoverArtAnchor = Alignment(0.68, 0.88);

  static const Alignment hoverPatternAnchor = Alignment(0.028, 0.886);
}

class WelcomeBannerCard extends StatefulWidget {
  final String? buttonText;
  final Color color;
  final Color? colorOverlay;
  final Color? borderColor;
  final Widget? childTextContent;
  final Widget Function(bool isHovered)? overlayImageBuilder;
  final VoidCallback? onTap;

  const WelcomeBannerCard({
    required this.color,
    super.key,
    this.buttonText,
    this.colorOverlay,
    this.borderColor,
    this.childTextContent,
    this.overlayImageBuilder,
    this.onTap,
  });

  @override
  State<WelcomeBannerCard> createState() => _WelcomeBannerCardState();
}

class _WelcomeBannerCardState extends State<WelcomeBannerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(widget.onTap),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedScale(
                      scale: _isHovered ? WelcomeBannerArt.hoverScale : 1.0,
                      alignment: WelcomeBannerArt.hoverPatternAnchor,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: ImageHelper.load(
                        path: AppImages.backgroundS,
                        color: widget.colorOverlay,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        cacheHeight: 400,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ImageHelper.load(
                      path: AppImages.backgroundLight,
                      color: Colors.black.withValues(alpha: 0.5),
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      cacheHeight: 400,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child:
                                widget.childTextContent ??
                                const SizedBox.shrink(),
                          ),
                        ),
                        if (widget.buttonText != null &&
                            widget.buttonText!.isNotEmpty)
                          ShineButton(
                            text: widget.buttonText!,
                            height: 30,
                            onPressed: () => widget.onTap?.call(),
                          ),
                      ],
                    ),
                  ),
                ),
        
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(
                      begin: 0.0,
                      end: _isHovered ? 1.0 : 0.0,
                    ),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _PartialBorderPainter(
                          color: widget.borderColor ?? const Color(0xFFFDE272),
                          radius: 16,
                          strokeWidth: 1,
                          progress: value,
                        ),
                      );
                    },
                  ),
                ),
        
                if (widget.overlayImageBuilder != null)
                  widget.overlayImageBuilder!(_isHovered),
              ],
            ),
          ),
        ),
    ),
    );
  }
}

class _PartialBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double progress;

  _PartialBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final inset = strokeWidth / 2;
    final r = radius - inset;

    const solidEnd = 0.88;
    const fadeEnd = 0.94;
    double lerp(double a, double b) => a + (b - a) * progress;

    final transparent = color.withValues(alpha: 0);

    final topEndX = lerp(w * 0.75, w * fadeEnd);
    final topSolidX = lerp(radius, w * solidEnd);

    final topFadePath = Path();
    topFadePath.moveTo(topEndX, inset);
    topFadePath.lineTo(radius, inset);

    final topGradient = LinearGradient(
      colors: [color, color, transparent],
      stops: [0.0, _stop(radius, topSolidX, topEndX), 1.0],
    ).createShader(Rect.fromLTRB(radius, 0, topEndX, strokeWidth * 2));

    paint.shader = topGradient;
    canvas.drawPath(topFadePath, paint);

    final solidPath = Path();
    solidPath.moveTo(radius, inset);
    solidPath.arcTo(
      Rect.fromCircle(center: Offset(radius, radius), radius: r),
      -math.pi / 2,
      -math.pi / 2,
      false,
    );
    solidPath.lineTo(inset, h - radius);
    solidPath.arcTo(
      Rect.fromCircle(center: Offset(radius, h - radius), radius: r),
      math.pi,
      -math.pi / 2,
      false,
    );
    solidPath.lineTo(w * 0.5, h - inset);

    paint.shader = null;
    paint.color = color;
    canvas.drawPath(solidPath, paint);

    final bottomEndX = lerp(w * 0.75, w * fadeEnd);
    final bottomSolidX = lerp(w * 0.5, w * solidEnd);

    final bottomFadePath = Path();
    bottomFadePath.moveTo(w * 0.5, h - inset);
    bottomFadePath.lineTo(bottomEndX, h - inset);

    final bottomGradient = LinearGradient(
      colors: [color, color, transparent],
      stops: [0.0, _stop(w * 0.5, bottomSolidX, bottomEndX), 1.0],
    ).createShader(Rect.fromLTRB(w * 0.5, h - strokeWidth, bottomEndX, h));

    paint.shader = bottomGradient;
    canvas.drawPath(bottomFadePath, paint);

  }

  static double _stop(double start, double solid, double end) {
    final span = end - start;
    if (span <= 0) return 0;
    return ((solid - start) / span).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _PartialBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

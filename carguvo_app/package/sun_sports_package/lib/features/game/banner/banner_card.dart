import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BannerCard extends StatefulWidget {
  const BannerCard({
    required this.color,
    super.key,
    this.colorOverlay,
    this.borderColor,
    this.borderWidth = 2,
    this.inlinePadding = const EdgeInsets.all(20),
    this.childTextContent,
    this.overlayImageBuilder,
    this.inlineContentBuilder,
    this.onTap,
  });

  final Color color;
  final Color? colorOverlay;
  final Color? borderColor;
  final double borderWidth;

  final EdgeInsets inlinePadding;
  final Widget? childTextContent;

  final Widget Function(bool isHovered)? overlayImageBuilder;

  final Widget Function(bool isHovered)? inlineContentBuilder;

  final VoidCallback? onTap;

  @override
  State<BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(widget.onTap),
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
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
                      scale: _isHovered ? 1.05 : 1.0,
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
                if (widget.inlineContentBuilder != null)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0.5,
                    right: 0,
                    child: Padding(
                      padding: widget.inlinePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.childTextContent ?? const SizedBox.shrink(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: widget.inlineContentBuilder!(_isHovered),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
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
                        ],
                      ),
                    ),
                  ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _isHovered ? 1.0 : 0.0,
                      ),
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: _PartialBorderPainter(
                            color:
                                widget.borderColor ?? const Color(0xFFFDE272),
                            radius: 16,
                            strokeWidth: widget.borderWidth,
                            progress: value,
                          ),
                        );
                      },
                    ),
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

    final fadeEndColor = Color.lerp(
      color.withValues(alpha: 0),
      color,
      progress,
    )!;

    final topCurrentEnd = (w * 0.75) + ((w - radius - (w * 0.75)) * progress);
    final topPath = Path()
      ..moveTo(radius, inset)
      ..lineTo(topCurrentEnd, inset);

    final topShader =
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color, fadeEndColor],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromLTWH(radius, inset, topCurrentEnd - radius, strokeWidth),
        );

    paint.shader = topShader;
    canvas.drawPath(topPath, paint);

    paint.shader = null;
    paint.color = color;
    final leftPath = Path()
      ..moveTo(radius, inset)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: r),
        -math.pi / 2,
        -math.pi / 2,
        false,
      )
      ..lineTo(inset, h - radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, h - radius), radius: r),
        math.pi,
        -math.pi / 2,
        false,
      );
    canvas.drawPath(leftPath, paint);

    final bottomCurrentEnd =
        (w * 0.25) + ((w - radius - (w * 0.25)) * progress);
    final bottomPath = Path()
      ..moveTo(radius, h - inset)
      ..lineTo(bottomCurrentEnd, h - inset);

    final bottomShader =
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color, fadeEndColor],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromLTWH(
            radius,
            h - inset,
            bottomCurrentEnd - radius,
            strokeWidth,
          ),
        );

    paint.shader = bottomShader;
    canvas.drawPath(bottomPath, paint);

    if (progress > 0) {
      paint.shader = null;
      paint.color = color.withValues(alpha: progress);
      final rightPath = Path()
        ..moveTo(topCurrentEnd, inset)
        ..arcTo(
          Rect.fromCircle(center: Offset(w - radius, radius), radius: r),
          -math.pi / 2,
          math.pi / 2,
          false,
        )
        ..lineTo(w - inset, h - radius)
        ..arcTo(
          Rect.fromCircle(center: Offset(w - radius, h - radius), radius: r),
          0,
          math.pi / 2,
          false,
        )
        ..lineTo(bottomCurrentEnd, h - inset);
      canvas.drawPath(rightPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PartialBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

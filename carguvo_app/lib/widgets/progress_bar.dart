import 'package:flutter/material.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';

class AppProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showLabel;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final progressColor = color ?? AppColors.primary;
    final percent = (clampedProgress * 100).toInt();

    return Column(
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiến độ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: height,
            backgroundColor:
                backgroundColor ?? progressColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

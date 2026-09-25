import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class SunProgressBar extends StatelessWidget {
  const SunProgressBar({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 6;
    final BorderRadius radius = BorderRadius.circular(1000);

    return Container(
      width: double.infinity,
      height: barHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: radius,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value <= 0 ? 0.0001 : value,
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF644202), AppColors.yellow600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

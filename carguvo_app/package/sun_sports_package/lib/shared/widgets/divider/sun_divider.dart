import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';

class SunDivider extends StatelessWidget {
  const SunDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.white.withValues(alpha: 0.2), Colors.white];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                height: 1,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(colors: colors),
                  shape: const RoundedRectangleBorder(),
                ),
              ),
            ),
          ),
          ImageHelper.load(path: AppImages.logoSun88),
          Expanded(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                height: 1,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(colors: colors.reversed.toList()),
                  shape: const RoundedRectangleBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

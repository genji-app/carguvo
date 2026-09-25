import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeTabletBannerSection extends StatelessWidget {
  const HomeTabletBannerSection({super.key});

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    child: Container(
      height: 142,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            offset: const Offset(0, 0.5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -50,
            top: -20,
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: -50,
            bottom: -30,
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'Banner',
              style: AppTextStyles.headingMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

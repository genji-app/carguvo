import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class VerificationCard extends StatelessWidget {
  const VerificationCard({
    required this.title,
    required this.subtitle,
    required this.form,
    super.key,
  });

  final String title;

  final String subtitle;

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _CardHeader(title: title, subtitle: subtitle),
            form,
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentPrimary,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    );
  }
}

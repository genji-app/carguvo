import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app_package/core/constants/i18n.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/phone_verification/provider/phone_verification_validators.dart';
import 'package:app_package/features/profile/profile.dart';
import 'package:app_package/shared/widgets/cards/inner_shadow_card.dart';

class VerifySuccessBanner extends StatelessWidget {
  const VerifySuccessBanner({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final formattedPhone = formatPhoneForPrivacy(phoneNumber);

    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProfilePhoneVerifiedIcon(size: Size.square(24)),
                const Gap(6),
                Text(
                  I18n.txtVerifiedBadge,
                  style: AppTextStyles.labelSmall(color: AppColors.yellow400),
                ),
              ],
            ),
            const Gap(16),
            Text(
              I18n.txtVerifyByPhoneSuccess,
              style: AppTextStyles.labelLarge(
                color: AppColorStyles.contentPrimary,
              ),
            ),
            const Gap(8),
            Text(
              '${I18n.txtPhoneNumber}: $formattedPhone',
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

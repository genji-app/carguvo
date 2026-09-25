import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

class ProfilePhoneVerificationWarning extends StatelessWidget {
  const ProfilePhoneVerificationWarning({super.key, this.onActivatePressed});

  final VoidCallback? onActivatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.orange300.withValues(alpha: 0.12),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.info_outline, size: 24, color: AppColors.orange500),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  I18n.msgAccountNotActivated,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTextStyles.labelXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
                Text(
                  I18n.msgAccountActivationDescription,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppTextStyles.labelXXSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
          ShineButton(
            text: I18n.txtActivate,
            style: ShineButtonStyle.primaryYellow,
            height: 36,
            onPressed: onActivatePressed,
          ),
        ],
      ),
    );
  }
}

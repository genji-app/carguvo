import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import 'profile_action_button.dart';

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({
    super.key,
    this.onSecurityPressed,
    this.onSettingsPressed,
    this.onPersonalPressed,
    this.onMailboxPressed,
    this.onSupportPressed,
    this.onPromoPressed,
    this.onBetHistoryPressed,
  });

  final VoidCallback? onSecurityPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onPersonalPressed;
  final VoidCallback? onMailboxPressed;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onPromoPressed;
  final VoidCallback? onBetHistoryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.txtAccount,
          style: AppTextStyles.headingXXSmall(
            color: AppColorStyles.contentPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.profileSecurity,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtSecurity),
                onPressed: onSecurityPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.profileSetting,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtSettings),
                onPressed: onSettingsPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.profilePersonal,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtPersonal),
                onPressed: onPersonalPressed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.profileMailBox,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtMailbox),
                onPressed: onMailboxPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.profileSupport,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtSupport),
                onPressed: onSupportPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.icSale,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtPromo),
                onPressed: onPromoPressed,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: ProfileActionButton(
                icon: ImageHelper.load(
                  path: AppIcons.icTicket,
                  width: 24,
                  height: 24,
                ),
                label: const Text(I18n.txtBetHistory),
                onPressed: onBetHistoryPressed,
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }
}

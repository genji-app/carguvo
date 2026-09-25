import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/widgets/input/input.dart';

class ProfilePersonalView extends ConsumerWidget {
  const ProfilePersonalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final username = user?.username;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          StyledTextField(
            enabled: false,
            filled: true,
            fillColor: AppColorStyles.backgroundTertiary,
            hoverColor: AppColorStyles.backgroundTertiary,
            label: const Text(I18n.txtAccount),
            initialValue: username,
          ),

          if (user?.isPhoneVerified == true)
            StyledTextField(
              enabled: false,
              filled: true,
              fillColor: AppColorStyles.backgroundTertiary,
              hoverColor: AppColorStyles.backgroundTertiary,
              initialValue: user?.maskedPhone ?? '-',
              label: const _PhoneTextFieldLabel(),
            )
          else
            ProfilePhoneVerificationWarning(
              onActivatePressed: () => ProfileHub.maybeOf(
                context,
              )?.pushTo<void>(ProfileHub.phoneVerification),
            ),
        ],
      ),
    );
  }
}

class _PhoneTextFieldLabel extends StatelessWidget {
  const _PhoneTextFieldLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(I18n.txtPhoneNumber),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            const ProfilePhoneVerifiedIcon(size: Size.square(20)),
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                I18n.txtActivated,
                style: AppTextStyles.labelXSmall(color: AppColors.yellow300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

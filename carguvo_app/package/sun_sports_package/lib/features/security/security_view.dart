import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/security/security.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class SecurityView extends ConsumerWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const surfaceColor = AppColorStyles.contentPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextStyle(
            style: AppTextStyles.headingXXXSmall(color: surfaceColor),
            child: const Text(I18n.txtPassword),
          ),

          const Gap(16),

          SecondaryButton.yellow(
            size: SecondaryButtonSize.xl,
            label: const Text(I18n.txtChangePassword),
            onPressed: () {
              if (kIsWeb) {
                AppToast.showError(
                  context,
                  message: 'Vui lòng đổi mật khẩu qua App',
                );
              } else {
                ref
                    .read(securityNavigatorProvider)
                    .pushToChangePassword(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

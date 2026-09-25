import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/show_withdraw_flow.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';

class ProfileWalletSection extends ConsumerWidget {
  const ProfileWalletSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Ví',
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
                path: AppIcons.profileAddMoneySelected,
                width: 24,
                height: 24,
              ),
              label: const Text('Nạp'),
              isHighlighted: true,
              onPressed: () => showDepositFlow(context, ref),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileActionButton(
              icon: ImageHelper.load(
                path: AppIcons.profileWithdraw,
                width: 24,
                height: 24,
              ),
              label: const Text('Rút'),
              onPressed: () => showWithdrawFlow(context, ref),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileActionButton(
              icon: ImageHelper.load(
                path: AppIcons.profileHistory,
                width: 24,
                height: 24,
              ),
              label: const Text('Lịch sử'),
              onPressed: () =>
                  ProfileHub.maybeOf(context)?.pushTo<void>(ProfileHub.transactionHistory),
            ),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_menu.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_notifier.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_providers.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';

class MyBetHubToggleButton extends ConsumerWidget {
  const MyBetHubToggleButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBetCount = ref.watch<int>(
      myBetNotifierProvider.select((MyBetState s) => s.betSlipCount),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: SoundTap.wrap(() {
          if (blockedBySbMaintenance(context, ref)) return;
          if (onTap != null) {
            onTap!();
            return;
          }
          ref
              .read(myBetHubControllerProvider)
              .toggle(initialMenu: MyBetMenu.bettingSlip);
        }),
        borderRadius: BorderRadius.circular(1000),
        child: Container(
          height: 44,
          padding: const EdgeInsets.only(
            left: 8,
            right: 12,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0x0FFFFCDB),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageHelper.load(
                path: AppIcons.icBettingSlip,
                width: 22,
                height: 20,
              ),
              const Gap(9),
              Text(
                I18n.txtBettingSlip,
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xB3FFFCDB),
                ),
              ),
              const Gap(9),
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.green300,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Center(
                  child: Text(
                    totalBetCount > 99 ? '99+' : totalBetCount.toString(),
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray950,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

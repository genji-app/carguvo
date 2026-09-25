import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class StakeStatusSlot extends StatelessWidget {
  final num stake;
  final int minStake;
  final int maxStake;
  final bool isCombo;
  final bool disabled;
  final VoidCallback onMinTap;
  final VoidCallback onMaxTap;

  final Widget payout;

  const StakeStatusSlot({
    required this.stake,
    required this.minStake,
    required this.maxStake,
    required this.onMinTap,
    required this.onMaxTap,
    required this.payout,
    this.isCombo = false,
    this.disabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) return payout;

    final limitsKnown = maxStake > 0;

    if (isCombo && limitsKnown && minStake > maxStake) {
      return Text(
        'Vượt quá tỷ lệ kết hợp tối đa, vui lòng bỏ bớt kèo',
        style: AppTextStyles.labelXSmall(color: AppColors.red500),
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (stake <= 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Mức cược',
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentSecondary,
            ),
            textAlign: TextAlign.right,
          ),
          const Gap(4),
          Text(
            '${MoneyFormatter.formatCompact(minStake)} - ${MoneyFormatter.formatCompact(maxStake)}',
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentSecondary,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (limitsKnown && stake < minStake) {
      return _LimitWarning(
        label: 'Mức cược tối thiểu',
        value: minStake,
        onTap: onMinTap,
      );
    }
    if (limitsKnown && stake > maxStake) {
      return _LimitWarning(
        label: 'Mức cược tối đa',
        value: maxStake,
        onTap: onMaxTap,
      );
    }

    return payout;
  }
}

class _LimitWarning extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onTap;

  const _LimitWarning({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(color: AppColors.red500),
          textAlign: TextAlign.right,
        ),
        const Gap(4),
        GestureDetector(
          onTap: SoundTap.wrap(onTap),
          child: Text(
            MoneyFormatter.formatCompact(value),
            style: AppTextStyles.labelMedium(color: AppColors.yellow500)
                .copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.yellow500,
                ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

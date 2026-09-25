import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

class BetSlipCardPaymentFooter extends StatelessWidget {
  const BetSlipCardPaymentFooter({
    required this.payoutAmount,
    required this.stakeAmount,
    required this.isSettled,
    this.isDeclined = false,
    super.key,
  });

  final num stakeAmount;
  final num payoutAmount;
  final bool isSettled;

  final bool isDeclined;

  @override
  Widget build(BuildContext context) {
    final payoutLabel = isDeclined
        ? I18n.txtRefunded
        : isSettled
        ? I18n.txtPaymentHasBeenMade
        : I18n.txtEstimatedPayout;

    final payoutValue = isDeclined ? stakeAmount : payoutAmount;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12, right: 12, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PaymentColumn(
              label: I18n.txtStake,
              amount: stakeAmount,
              alignEnd: false,
            ),
          ),
          const Gap(4),
          Expanded(
            child: _PaymentColumn(
              label: payoutLabel,
              amount: payoutValue,
              prefixText: (!isDeclined && payoutValue > 0) ? '+' : null,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentColumn extends StatelessWidget {
  const _PaymentColumn({
    required this.label,
    required this.amount,
    required this.alignEnd,
    this.prefixText,
  });

  final String label;
  final num amount;
  final String? prefixText;

  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.paragraphSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const Gap(4),
        CurrencyText.fromNumber(
          amount,
          prefixText: prefixText,
          style: AppTextStyles.labelSmall(
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ],
    );
  }
}

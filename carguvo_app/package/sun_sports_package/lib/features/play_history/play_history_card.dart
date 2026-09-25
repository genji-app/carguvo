import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/divider/divider.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class PlayHistoryCard extends StatelessWidget {
  const PlayHistoryCard(this.item, {super.key, this.onPressed});

  final UnifiedTransaction item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColorStyles.backgroundQuaternary,
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: SoundTap.wrap(onPressed),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlayHistoryCardHeadline(betTime: item.sortTime.toLocal()),

            const Gap(8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item is ActivityTransaction
                    ? (item as ActivityTransaction).rawServiceName
                    : '',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            const Gap(12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item.statusDescription,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ),

            const Gap(4),
            const SunDivider(),
            const Gap(4),

            PlayHistoryCardPaymentFooter(
              exchangeValue: item.slipType == TransactionSlipType.deposit
                  ? item.amount
                  : -(item.amount),
              payoutAmount: item.slipType == TransactionSlipType.deposit
                  ? item.amount
                  : 0,
            ),
            const Gap(4),
          ],
        ),
      ),
    );
  }
}

class PlayHistoryCardHeadline extends StatelessWidget {
  const PlayHistoryCardHeadline({required this.betTime, super.key});

  final DateTime betTime;

  static const String dateTimeFormat = 'HH:mm - dd/MM/yyyy';
  static String formatTimeTxt(DateTime time) =>
      DateFormat(dateTimeFormat).format(time);

  @override
  Widget build(BuildContext context) {
    final timeTxt = formatTimeTxt(betTime);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06)),
      child: Row(
        spacing: 8,
        children: [
          Flexible(
            child: DefaultTextStyle(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
              child: Text(timeTxt),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayHistoryCardPaymentFooter extends StatelessWidget {
  const PlayHistoryCardPaymentFooter({
    required this.payoutAmount,
    required this.exchangeValue,
    super.key,
  });

  final num exchangeValue;
  final num payoutAmount;

  static Widget buildrow(
    BuildContext context, {
    required Widget title,
    Widget? value,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: DefaultTextStyle(
          style: AppTextStyles.paragraphMedium(
            color: AppColorStyles.contentSecondary,
          ),
          child: title,
        ),
      ),
      if (value != null) value,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 16),
      child: Column(
        children: [
          buildrow(
            context,
            title: const Text(I18n.txtChange),
            value: CurrencyText.fromNumber(
              exchangeValue,
              prefixText: exchangeValue > 0 ? '+' : null,
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

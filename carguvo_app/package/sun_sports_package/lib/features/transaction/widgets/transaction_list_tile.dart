import 'package:flutter/material.dart' hide CloseButton;
import 'package:intl/intl.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/extensions.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/currency_text.dart';

import 'transaction_status_badge.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    super.key,
    this.onPressed,
  });

  final UnifiedTransaction transaction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.all(12);
    final contentPrimaryColor = AppColorStyles.contentPrimary;
    final contentSecondaryColor = AppColorStyles.contentSecondary;

    final paymentMethod = transaction.paymentMethod;
    final transactionSlipType = transaction.slipType;
    final amountColor = transactionSlipType.amountColor;

    final slipTypeTxt = transactionSlipType.label;
    final paymentMethodTxt = paymentMethod.label;
    final prefixTxt = transaction.amountPrefix;

    final timeTxt = DateFormat(
      'HH:mm - dd/MM/yyyy',
    ).format(transaction.sortTime);

    return Card(
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 52,
        onTap: SoundTap.wrap(onPressed),
        contentPadding: contentPadding,
        leading: SizedBox.square(
          dimension: 32,
          child: TransactionSlipTypeIcon(transaction.slipType),
        ),
        titleTextStyle: AppTextStyles.paragraphSmall(
          color: contentPrimaryColor,
        ),
        title: Row(
          spacing: 24,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints.tightFor(
                  width: double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      slipTypeTxt,
                      maxLines: 1,
                      style: AppTextStyles.paragraphSmall(
                        color: contentPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      paymentMethodTxt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.paragraphXSmall(
                        color: contentSecondaryColor,
                      ),
                    ),

                    Text(
                      timeTxt,
                      style: AppTextStyles.paragraphXSmall(
                        color: contentSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: TransactionStatusBadge(
                statusDescription: transaction.statusDescription,
                status: transaction.status,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CurrencyText.fromNumber(
                transaction.actualAmount,
                prefixText: prefixTxt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(color: amountColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionSlipTypeIcon extends StatelessWidget {
  // ignore: unused_element_parameter
  const TransactionSlipTypeIcon(this.type, {super.key});

  final TransactionSlipType type;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: AppColorStyles.backgroundQuaternary,
    child: SizedBox.square(dimension: 20, child: type.icon),
  );
}

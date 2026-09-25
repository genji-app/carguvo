import 'package:flutter/material.dart' hide CloseButton;
import 'package:intl/intl.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/currency_text.dart';

import 'extensions.dart';

class ActivityLogListTile extends StatelessWidget {
  const ActivityLogListTile({
    required this.transaction,
    super.key,
    this.onPressed,
  });

  final ActivityTransaction transaction;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.all(12);
    final contentPrimaryColor = AppColorStyles.contentPrimary;
    final contentSecondaryColor = AppColorStyles.contentSecondary;

    final amountColor = transaction.amountColor;
    final timeTxt = transaction.displayTime;
    final serviceName = transaction.displayServiceName;
    final iconWidget = transaction.displayIcon;

    return Card(
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 64,
        onTap: SoundTap.wrap(onPressed),
        contentPadding: contentPadding,
        leading: SizedBox.square(
          dimension: 32,
          child: iconWidget != null
              ? CircleAvatar(
                  backgroundColor: AppColorStyles.backgroundQuaternary,
                  child: SizedBox.square(dimension: 20, child: iconWidget),
                )
              : const SizedBox.shrink(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (serviceName.isNotEmpty)
              Text(
                serviceName,
                style: AppTextStyles.labelSmall(color: contentPrimaryColor),
              ),
            Text(
              transaction.statusDescription,
              style: AppTextStyles.paragraphXSmall(
                color: contentSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              timeTxt,
              style: AppTextStyles.paragraphXSmall(
                color: contentSecondaryColor,
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CurrencyText.fromNumber(
              transaction.amount,
              prefixText: transaction.prefixText,
              style: AppTextStyles.labelSmall(color: amountColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Số dư: ${NumberFormat.decimalPattern().format(transaction.closingBalance)}',
              style: AppTextStyles.paragraphXSmall(
                color: contentSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

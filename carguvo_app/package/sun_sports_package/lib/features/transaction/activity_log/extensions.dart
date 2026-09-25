import 'package:flutter/material.dart';
import 'package:transaction_domain/transaction_domain.dart'
    show formatHistoryTime, refundServiceName;
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

extension ActivityGroupX on ActivityGroup {
  Widget? get icon {
    final iconPath = switch (this) {
      ActivityGroup.deposit => AppIcons.transactionDeposit,
      ActivityGroup.cancel => AppIcons.transactionDeposit,
      ActivityGroup.promotion => AppIcons.transactionDeposit,
      ActivityGroup.withdraw => AppIcons.transactionWithdraw,
      ActivityGroup.sport => AppIcons.catSport,
      ActivityGroup.casino => AppIcons.catCard,
    };

    final color = this == ActivityGroup.deposit
        ? AppColorStyles.contentPrimary
        : AppColorStyles.contentSecondary;

    return ImageHelper.load(path: iconPath, color: color);
  }
}

extension ActivityTransactionUiX on ActivityTransaction {
  bool get isPositive => slipType == TransactionSlipType.deposit;

  String get prefixText => isPositive ? '+' : '-';

  Color get amountColor =>
      isPositive ? AppColors.green400 : AppColorStyles.contentPrimary;

  String get displayServiceName => refundServiceName(
        isRefund: isRefund,
        rawServiceName: rawServiceName,
      );

  String get displayTime => formatHistoryTime(sortTime);

  Widget? get displayIcon {
    if (isRefund) {
      return ActivityGroup.deposit.icon;
    }
    return group.icon;
  }

  String get displayDescription => statusDescription;
}

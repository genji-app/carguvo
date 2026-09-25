import 'package:flutter/material.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_confirm_money_transfer_container.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';

class BankConfirmMoneyTransferBottomSheet extends StatelessWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankConfirmMoneyTransferBottomSheet({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
    required this.parentContext,
  });

  static Future<void> show(
    BuildContext context, {
    required BankAccountItem bankAccountItem,
    required PaymentMethod paymentMethod,
  }) => AppBottomSheet.show(
    context,
    builder: (_) => BankConfirmMoneyTransferBottomSheet(
      bankAccountItem: bankAccountItem,
      paymentMethod: paymentMethod,
      parentContext: context,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeight = screenSize.height;

    return Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BankConfirmMoneyTransferContainer(
            bankAccountItem: bankAccountItem,
            paymentMethod: paymentMethod,
            parentContext: parentContext,
          ),
        ),
      ),
    );
  }
}

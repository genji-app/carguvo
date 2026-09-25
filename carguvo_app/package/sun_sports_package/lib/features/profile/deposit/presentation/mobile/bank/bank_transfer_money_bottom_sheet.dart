import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_transfer_container.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';

class BankTransferMoneyBottomSheet extends StatefulWidget {
  final BankAccountItem bankAccountItem;
  final String amount;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankTransferMoneyBottomSheet({
    super.key,
    required this.bankAccountItem,
    required this.amount,
    required this.paymentMethod,
    required this.parentContext,
  });

  static Future<void> show(
    BuildContext context, {
    required BankAccountItem bankAccountItem,
    required String amount,
    required PaymentMethod paymentMethod,
  }) => AppBottomSheet.show(
    context,
    builder: (_) => BankTransferMoneyBottomSheet(
      bankAccountItem: bankAccountItem,
      amount: amount,
      paymentMethod: paymentMethod,
      parentContext: context,
    ),
  );

  @override
  State<BankTransferMoneyBottomSheet> createState() =>
      _BankTransferMoneyBottomSheetState();
}

class _BankTransferMoneyBottomSheetState
    extends State<BankTransferMoneyBottomSheet> {
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
          child: BankTransferContainer(
            bankAccountItem: widget.bankAccountItem,
            paymentMethod: widget.paymentMethod,
            parentContext: context,
          ),
        ),
      ),
    );
  }
}

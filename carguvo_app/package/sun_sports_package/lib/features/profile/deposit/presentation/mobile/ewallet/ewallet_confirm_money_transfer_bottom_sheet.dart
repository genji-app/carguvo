import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/ewallet_confirm_money_transfer_container.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';

class EWalletConfirmMoneyTransferBottomSheet extends StatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;
  final bool hideButtons;

  const EWalletConfirmMoneyTransferBottomSheet({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    required this.parentContext,
    this.hideButtons = false,
  });

  static Future<void> show(
    BuildContext context, {
    required CodepayCreateQrResponse qrResponse,
    required PaymentMethod paymentMethod,
    bool hideButtons = false,
  }) => AppBottomSheet.show(
    context,
    builder: (_) => EWalletConfirmMoneyTransferBottomSheet(
      qrResponse: qrResponse,
      paymentMethod: paymentMethod,
      parentContext: context,
      hideButtons: hideButtons,
    ),
  );

  @override
  State<EWalletConfirmMoneyTransferBottomSheet> createState() =>
      _EWalletConfirmMoneyTransferBottomSheetState();
}

class _EWalletConfirmMoneyTransferBottomSheetState
    extends State<EWalletConfirmMoneyTransferBottomSheet> {
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
          child: EWalletConfirmMoneyTransferContainer(
            qrResponse: widget.qrResponse,
            paymentMethod: widget.paymentMethod,
            hideButtons: widget.hideButtons,
          ),
        ),
      ),
    );
  }
}

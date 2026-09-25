import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/ewallet_confirm_money_transfer_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class EWalletConfirmMoneyTransferOverlay extends ConsumerStatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final bool hideButtons;

  const EWalletConfirmMoneyTransferOverlay({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.hideButtons = false,
  });

  @override
  ConsumerState<EWalletConfirmMoneyTransferOverlay> createState() =>
      _EWalletConfirmMoneyTransferOverlayState();
}

class _EWalletConfirmMoneyTransferOverlayState
    extends ConsumerState<EWalletConfirmMoneyTransferOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: Container(
              width: 640,
              height: 823,
              constraints: BoxConstraints(maxHeight: size.height * 0.9),
              decoration: BoxDecoration(
                color: AppColors.gray950,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(-20, 4),
                    blurRadius: 200,
                  ),
                  BoxShadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ],
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: EWalletConfirmMoneyTransferContainer(
                qrResponse: widget.qrResponse,
                paymentMethod: widget.paymentMethod,
                hideButtons: widget.hideButtons,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

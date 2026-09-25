import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_transfer_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BankTransferOverlay extends ConsumerStatefulWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;

  const BankTransferOverlay({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
  });

  @override
  ConsumerState<BankTransferOverlay> createState() =>
      _BankTransferOverlayState();
}

class _BankTransferOverlayState extends ConsumerState<BankTransferOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() => DepositNavigator().pop<void>(context)),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InnerShadowCard(
                borderRadius: 24,
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
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BankTransferContainer(
                      bankAccountItem: widget.bankAccountItem,
                      paymentMethod: widget.paymentMethod,
                      parentContext: context,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

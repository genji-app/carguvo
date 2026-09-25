import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_card_form_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/withdraw_header.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/withdraw_payment_methods_grid.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/bank_container.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/crypto_container.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/card_container.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';

class WithdrawMobileBottomSheet extends ConsumerStatefulWidget {
  const WithdrawMobileBottomSheet({super.key});

  static Future<void> show(BuildContext context) => AppBottomSheet.show(
    context,
    barrierColor: Colors.transparent,
    builder: (_) => const WithdrawMobileBottomSheet(),
  );

  @override
  ConsumerState<WithdrawMobileBottomSheet> createState() =>
      _WithdrawMobileBottomSheetState();
}

class _WithdrawMobileBottomSheetState
    extends ConsumerState<WithdrawMobileBottomSheet> {
  late final StateController<WithdrawCardFormState> _cardFormController;

  @override
  void initState() {
    super.initState();
    _cardFormController = ref.read(withdrawCardFormProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(withdrawSelectionProvider.notifier)
          .selectPaymentMethod(WithdrawPaymentMethod.bank);
    });
  }

  @override
  void dispose() {
    final controller = _cardFormController;
    Future(() {
      if (controller.mounted) {
        controller.state = const WithdrawCardFormState();
      }
    });
    super.dispose();
  }

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  void _handleClose() {
    _hideKeyboard();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    final statusBarHeight = mq.padding.top;
    final maxHeight = screenSize.height;
    final keyboardInset = mq.viewInsets.bottom;

    return MediaQuery(
      data: mq.copyWith(viewInsets: mq.viewInsets.copyWith(bottom: 0)),
      child: Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: GestureDetector(
        onTap: _hideKeyboard,
        behavior: HitTestBehavior.opaque,
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                WithdrawHeader(onClose: _handleClose),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WithdrawPaymentMethodsGrid(),
                        const SizedBox(height: 40),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final innerMq = MediaQuery.of(context);
                              return MediaQuery(
                                data: innerMq.copyWith(
                                  viewInsets: innerMq.viewInsets.copyWith(
                                    bottom: keyboardInset,
                                  ),
                                ),
                                child: _buildPaymentMethodContainer(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildPaymentMethodContainer() {
    final selectionState = ref.watch(withdrawSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? WithdrawPaymentMethod.bank;

    switch (selectedMethod) {
      case WithdrawPaymentMethod.bank:
        return const WithdrawBankContainer();
      case WithdrawPaymentMethod.crypto:
        return const WithdrawCryptoContainer();
      case WithdrawPaymentMethod.scratchCard:
        return const WithdrawCardContainer();
    }
  }
}

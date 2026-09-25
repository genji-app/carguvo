import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/bank/bank_container.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/codepay/codepay_container.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/ewallet_container.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/crypto_container.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/card_container.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/giftcode_container.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_methods_grid.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositMobileBottomSheet extends ConsumerStatefulWidget {
  const DepositMobileBottomSheet({super.key});

  static Future<void> show(BuildContext context) => AppBottomSheet.show(
    context,
    builder: (_) => const DepositMobileBottomSheet(),
  );

  @override
  ConsumerState<DepositMobileBottomSheet> createState() =>
      _DepositMobileBottomSheetState();
}

class _DepositMobileBottomSheetState
    extends ConsumerState<DepositMobileBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        final currentSelection = ref
            .read(depositSelectionProvider)
            .selectedMethod;
        if (currentSelection == null) {
          ref
              .read(depositSelectionProvider.notifier)
              .selectPaymentMethod(PaymentMethod.codepay);
        }
      });
    });
  }

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  void _handleClose() {
    _hideKeyboard();
    DepositNavigator().closeAll<void>(context);
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
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const DepositPaymentMethodsGrid(),
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

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Nạp tiền',
              style: AppTextStyles.headingXSmall(color: AppColors.gray25),
            ),
          ),
        ),
        InkWell(
          onTap: SoundTap.wrap(_handleClose),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPaymentMethodContainer() {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);
    if (isLoading) {
      return const SizedBox.shrink();
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;

    switch (selectedMethod) {
      case PaymentMethod.codepay:
        return const CodepayContainer();
      case PaymentMethod.bank:
        return const BankContainer();
      case PaymentMethod.eWallet:
        return const EWalletContainer();
      case PaymentMethod.crypto:
        return const CryptoContainer();
      case PaymentMethod.scratchCard:
        return const CardContainer();
      case PaymentMethod.giftcode:
        return const GiftCodeContainer();
    }
  }
}

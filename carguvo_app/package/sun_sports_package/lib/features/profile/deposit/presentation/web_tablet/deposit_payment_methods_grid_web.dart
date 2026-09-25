import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card.dart';

class DepositPaymentMethodsGridWeb extends ConsumerWidget {
  const DepositPaymentMethodsGridWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);
    if (isLoading) {
      return const SizedBox.shrink();
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;
    final showBankTab = ref.watch(hasBankAccountsProvider);
    final showEWalletTab = ref.watch(hasEWalletsProvider);
    final showCryptoTab = ref.watch(hasCryptoOptionsProvider);

    return Row(
      children: [
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.codepay,
            label: 'Codepay',
            isSelected: selectedMethod == PaymentMethod.codepay,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.codepay);
            },
          ),
        ),
        if (showCryptoTab) ...[
          const Gap(12),
          Expanded(
            child: DepositPaymentMethodCard(
              method: PaymentMethod.crypto,
              label: 'Tiền điện tử',
              isSelected: selectedMethod == PaymentMethod.crypto,
              onTap: () {
                ref
                    .read(depositSelectionProvider.notifier)
                    .selectPaymentMethod(PaymentMethod.crypto);
              },
            ),
          ),
        ],
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.scratchCard,
            label: 'Thẻ cào',
            isSelected: selectedMethod == PaymentMethod.scratchCard,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.scratchCard);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.giftcode,
            label: 'Giftcode',
            isSelected: selectedMethod == PaymentMethod.giftcode,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.giftcode);
            },
          ),
        ),
        if (showBankTab) ...[
          const Gap(12),
          Expanded(
            child: DepositPaymentMethodCard(
              method: PaymentMethod.bank,
              label: 'Ngân hàng',
              isSelected: selectedMethod == PaymentMethod.bank,
              onTap: () {
                ref
                    .read(depositSelectionProvider.notifier)
                    .selectPaymentMethod(PaymentMethod.bank);
              },
            ),
          ),
        ],
        if (showEWalletTab) ...[
          const Gap(12),
          Expanded(
            child: DepositPaymentMethodCard(
              method: PaymentMethod.eWallet,
              label: 'Ví điện tử',
              isSelected: selectedMethod == PaymentMethod.eWallet,
              onTap: () {
                ref
                    .read(depositSelectionProvider.notifier)
                    .selectPaymentMethod(PaymentMethod.eWallet);
              },
            ),
          ),
        ],
      ],
    );
  }
}

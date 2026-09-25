import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card_shimmer.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/withdraw_payment_method_card.dart';

class WithdrawPaymentMethodsGrid extends ConsumerWidget {
  const WithdrawPaymentMethodsGrid({super.key});

  static const int _placeholderCount = 3;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);

    if (isLoading) {
      return RepaintBoundary(
        child: Shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.gray700,
          colorOpacity: 0.3,
          child: Row(
            children: List<Widget>.generate(_placeholderCount, (index) {
              final isLast = index == _placeholderCount - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : _spacing),
                  child: const DepositPaymentMethodCardShimmer(),
                ),
              );
            }),
          ),
        ),
      );
    }

    final selectionState = ref.watch(withdrawSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? WithdrawPaymentMethod.bank;
    final showCryptoTab = ref.watch(hasCryptoOptionsProvider);

    return Row(
      children: [
        Expanded(
          child: WithdrawPaymentMethodCard(
            method: WithdrawPaymentMethod.bank,
            label: 'Ngân hàng',
            isSelected: selectedMethod == WithdrawPaymentMethod.bank,
            onTap: () {
              ref
                  .read(withdrawSelectionProvider.notifier)
                  .selectPaymentMethod(WithdrawPaymentMethod.bank);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: WithdrawPaymentMethodCard(
            method: WithdrawPaymentMethod.scratchCard,
            label: 'Thẻ cào',
            isSelected: selectedMethod == WithdrawPaymentMethod.scratchCard,
            onTap: () {
              ref
                  .read(withdrawSelectionProvider.notifier)
                  .selectPaymentMethod(WithdrawPaymentMethod.scratchCard);
            },
          ),
        ),
        if (showCryptoTab) ...[
          const Gap(12),
          Expanded(
            child: WithdrawPaymentMethodCard(
              method: WithdrawPaymentMethod.crypto,
              label: 'Tiền điện tử',
              isSelected: selectedMethod == WithdrawPaymentMethod.crypto,
              onTap: () {
                ref
                    .read(withdrawSelectionProvider.notifier)
                    .selectPaymentMethod(WithdrawPaymentMethod.crypto);
              },
            ),
          ),
        ],
      ],
    );
  }
}

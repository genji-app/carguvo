import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/card_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/crypto_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/ewallet_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/giftcode_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_container_section.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_container_section.dart';

class DepositPaymentMethodContainerWeb extends ConsumerStatefulWidget {
  const DepositPaymentMethodContainerWeb({super.key});

  @override
  ConsumerState<DepositPaymentMethodContainerWeb> createState() =>
      _DepositPaymentMethodContainerWebState();
}

class _DepositPaymentMethodContainerWebState
    extends ConsumerState<DepositPaymentMethodContainerWeb> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);
    if (isLoading) {
      return const SizedBox.shrink();
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;

    return _buildFormContent(selectedMethod);
  }

  Widget _buildFormContent(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.codepay:
        return const CodepayContainerSection();
      case PaymentMethod.bank:
        return const BankContainerSection();
      case PaymentMethod.eWallet:
        return const EWalletOverlay();
      case PaymentMethod.crypto:
        return const CryptoOverlay();
      case PaymentMethod.scratchCard:
        return const CardOverlay();
      case PaymentMethod.giftcode:
        return const GiftCodeOverlay();
    }
  }
}

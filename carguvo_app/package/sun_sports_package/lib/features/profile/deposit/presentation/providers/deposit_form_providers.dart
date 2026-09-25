import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/bank_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/codepay_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/ewallet_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/card_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/crypto_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/giftcode_form_notifier.dart';
import 'package:sun_sports/features/profile/deposit/presentation/notifiers/verify_bank_form_notifier.dart';

final bankFormProvider = StateNotifierProvider<BankFormNotifier, BankFormState>(
  (ref) => BankFormNotifier(),
);

final codepayFormProvider =
    StateNotifierProvider<CodepayFormNotifier, CodepayFormState>(
      (ref) => CodepayFormNotifier(),
    );

final ewalletFormProvider =
    StateNotifierProvider<EWalletFormNotifier, EWalletFormState>(
      (ref) => EWalletFormNotifier(),
    );

final cardFormProvider = StateNotifierProvider<CardFormNotifier, CardFormState>(
  (ref) => CardFormNotifier(),
);

final cryptoFormProvider =
    StateNotifierProvider<CryptoFormNotifier, CryptoFormState>(
      (ref) => CryptoFormNotifier(),
    );

final giftcodeFormProvider =
    StateNotifierProvider<GiftcodeFormNotifier, GiftcodeFormState>(
      (ref) => GiftcodeFormNotifier(),
    );

final verifyBankFormProvider =
    StateNotifierProvider<VerifyBankFormNotifier, VerifyBankFormState>(
      (ref) => VerifyBankFormNotifier(),
    );

void resetDepositForms(WidgetRef ref) {
  ref.read(bankFormProvider.notifier).reset();
  ref.read(codepayFormProvider.notifier).reset();
  ref.read(ewalletFormProvider.notifier).reset();
  ref.read(cardFormProvider.notifier).reset();
  ref.read(cryptoFormProvider.notifier).reset();
  ref.read(giftcodeFormProvider.notifier).reset();
  ref.read(verifyBankFormProvider.notifier).reset();
  ref.read(depositSelectionProvider.notifier).reset();
}

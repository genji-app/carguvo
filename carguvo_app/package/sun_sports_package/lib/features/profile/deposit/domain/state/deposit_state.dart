import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';

part 'deposit_state.freezed.dart';

@freezed
sealed class DepositSelectionState with _$DepositSelectionState {
  const factory DepositSelectionState({
    PaymentMethod? selectedMethod,
    @Default(true) bool isContainerVisible,
  }) = _DepositSelectionState;
}

@freezed
sealed class BankFormState with _$BankFormState {
  const factory BankFormState({
    String? selectedBank,
    @Default('') String accountNumber,
    @Default('') String accountName,
    @Default('') String amount,
    @Default('') String senderName,
    @Default('') String note,
    String? bankError,
    String? accountNumberError,
    String? accountNameError,
    String? amountError,
    String? senderNameError,
    String? noteError,
  }) = _BankFormState;
}

extension BankFormStateX on BankFormState {
  bool get isValid =>
      selectedBank != null &&
      accountNumber.isNotEmpty &&
      accountName.isNotEmpty &&
      amount.isNotEmpty &&
      bankError == null &&
      accountNumberError == null &&
      accountNameError == null &&
      amountError == null;

  bool get isConfirmFormValid =>
      amount.isNotEmpty &&
      senderName.isNotEmpty &&
      note.isNotEmpty &&
      amountError == null &&
      senderNameError == null &&
      noteError == null;
}

@freezed
sealed class BankSubmitState with _$BankSubmitState {
  const factory BankSubmitState.idle() = _Idle;
  const factory BankSubmitState.submitting() = _Submitting;
  const factory BankSubmitState.success() = _Success;
  const factory BankSubmitState.error(String message) = _Error;
}

@freezed
sealed class BankTransactionSlipState with _$BankTransactionSlipState {
  const factory BankTransactionSlipState.idle() = _TransactionSlipIdle;
  const factory BankTransactionSlipState.submitting() =
      _TransactionSlipSubmitting;
  const factory BankTransactionSlipState.success() = _TransactionSlipSuccess;
  const factory BankTransactionSlipState.error(String message) =
      _TransactionSlipError;
}

@freezed
sealed class CodepayFormState with _$CodepayFormState {
  const factory CodepayFormState({
    String? selectedBank,
    @Default('') String amount,
    String? bankError,
    String? amountError,
  }) = _CodepayFormState;
}

extension CodepayFormStateX on CodepayFormState {
  bool get isValid =>
      selectedBank != null &&
      amount.isNotEmpty &&
      bankError == null &&
      amountError == null;
}

@freezed
sealed class EWalletFormState with _$EWalletFormState {
  const factory EWalletFormState({
    String? selectedWallet,
    @Default('') String amount,
    String? walletError,
    String? amountError,
  }) = _EWalletFormState;
}

extension EWalletFormStateX on EWalletFormState {
  bool get isValid =>
      selectedWallet != null &&
      amount.isNotEmpty &&
      walletError == null &&
      amountError == null;
}

@freezed
sealed class CardFormState with _$CardFormState {
  const factory CardFormState({
    String? selectedCardType,
    String? selectedDenomination,
    @Default('') String serialNumber,
    @Default('') String cardCode,
    String? cardTypeError,
    String? denominationError,
    String? serialNumberError,
    String? cardCodeError,
  }) = _CardFormState;
}

extension CardFormStateX on CardFormState {
  bool get isValid =>
      selectedCardType != null &&
      selectedDenomination != null &&
      serialNumber.isNotEmpty &&
      cardCode.isNotEmpty &&
      cardTypeError == null &&
      denominationError == null &&
      serialNumberError == null &&
      cardCodeError == null;
}

@freezed
sealed class CryptoFormState with _$CryptoFormState {
  const factory CryptoFormState({
    String? selectedCrypto,
    String? cryptoError,
  }) = _CryptoFormState;
}

extension CryptoFormStateX on CryptoFormState {
  bool get isValid => selectedCrypto != null && cryptoError == null;
}

@freezed
sealed class GiftcodeFormState with _$GiftcodeFormState {
  const factory GiftcodeFormState({
    @Default('') String giftCode,
    String? giftCodeError,
  }) = _GiftcodeFormState;
}

extension GiftcodeFormStateX on GiftcodeFormState {
  bool get isValid => giftCode.isNotEmpty && giftCodeError == null;
}

@freezed
sealed class CryptoSubmitState with _$CryptoSubmitState {
  const factory CryptoSubmitState.idle() = _CryptoIdle;
  const factory CryptoSubmitState.submitting() = _CryptoSubmitting;
  const factory CryptoSubmitState.success() = _CryptoSuccess;
  const factory CryptoSubmitState.error(String message) = _CryptoError;
}

@freezed
sealed class CodepaySubmitState with _$CodepaySubmitState {
  const factory CodepaySubmitState.idle() = _CodepayIdle;
  const factory CodepaySubmitState.submitting() = _CodepaySubmitting;
  const factory CodepaySubmitState.success() = _CodepaySuccess;
  const factory CodepaySubmitState.error(String message) = _CodepayError;
}

@freezed
sealed class EWalletSubmitState with _$EWalletSubmitState {
  const factory EWalletSubmitState.idle() = _EWalletIdle;
  const factory EWalletSubmitState.submitting() = _EWalletSubmitting;
  const factory EWalletSubmitState.success() = _EWalletSuccess;
  const factory EWalletSubmitState.error(String message) = _EWalletError;
}

@freezed
sealed class CardSubmitState with _$CardSubmitState {
  const factory CardSubmitState.idle() = _CardIdle;
  const factory CardSubmitState.submitting() = _CardSubmitting;
  const factory CardSubmitState.success() = _CardSuccess;
  const factory CardSubmitState.error(String message) = _CardError;
}

@freezed
sealed class GiftcodeSubmitState with _$GiftcodeSubmitState {
  const factory GiftcodeSubmitState.idle() = _GiftcodeIdle;
  const factory GiftcodeSubmitState.submitting() = _GiftcodeSubmitting;
  const factory GiftcodeSubmitState.success({String? message}) =
      _GiftcodeSuccess;
  const factory GiftcodeSubmitState.error(String message) = _GiftcodeError;
}

@freezed
sealed class VerifyBankSubmitState with _$VerifyBankSubmitState {
  const factory VerifyBankSubmitState.idle() = _VerifyBankSubmitIdle;
  const factory VerifyBankSubmitState.submitting() =
      _VerifyBankSubmitSubmitting;
  const factory VerifyBankSubmitState.success() = _VerifyBankSubmitSuccess;
  const factory VerifyBankSubmitState.error(String message) =
      _VerifyBankSubmitError;
}

@freezed
sealed class VerifyBankFormState with _$VerifyBankFormState {
  const factory VerifyBankFormState({
    String? selectedBank,
    @Default('') String accountName,
    @Default('') String accountNumber,
    String? bankError,
    String? accountNameError,
    String? accountNumberError,
  }) = _VerifyBankFormState;
}

extension VerifyBankFormStateX on VerifyBankFormState {
  bool get isValid =>
      selectedBank != null &&
      accountName.isNotEmpty &&
      accountNumber.isNotEmpty &&
      bankError == null &&
      accountNameError == null &&
      accountNumberError == null;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'withdraw_state.freezed.dart';

@freezed
sealed class WithdrawBankFormState with _$WithdrawBankFormState {
  const factory WithdrawBankFormState({
    String? selectedBank,
    @Default('') String accountNumber,
    @Default('') String accountName,
    @Default('') String amount,
    String? bankError,
    String? accountNumberError,
    String? accountNameError,
    String? amountError,
  }) = _WithdrawBankFormState;
}

extension WithdrawBankFormStateX on WithdrawBankFormState {
  bool get isValid =>
      selectedBank != null &&
      accountNumber.isNotEmpty &&
      accountName.isNotEmpty &&
      amount.isNotEmpty &&
      bankError == null &&
      accountNumberError == null &&
      accountNameError == null &&
      amountError == null;
}

@freezed
sealed class CryptoWithdrawSubmitState with _$CryptoWithdrawSubmitState {
  const factory CryptoWithdrawSubmitState.idle() = _CryptoWithdrawIdle;
  const factory CryptoWithdrawSubmitState.submitting() =
      _CryptoWithdrawSubmitting;
  const factory CryptoWithdrawSubmitState.success() = _CryptoWithdrawSuccess;
  const factory CryptoWithdrawSubmitState.error(String message) =
      _CryptoWithdrawError;
}

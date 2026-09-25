import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';

class WithdrawBankFormNotifier extends StateNotifier<WithdrawBankFormState> {
  WithdrawBankFormNotifier() : super(const WithdrawBankFormState());

  void updateBank(String? bank) {
    state = state.copyWith(
      selectedBank: bank,
      bankError: bank == null || bank.isEmpty
          ? 'Vui lòng chọn ngân hàng'
          : null,
    );
  }

  void updateAccountNumber(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập số tài khoản';
    }

    state = state.copyWith(accountNumber: value, accountNumberError: error);
  }

  void updateAccountName(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập tên tài khoản';
    } else if (value.length < 2) {
      error = 'Tên tài khoản phải có ít nhất 2 ký tự';
    }

    state = state.copyWith(accountName: value, accountNameError: error);
  }

  void updateAmount(String amount) {
    final cleanedAmount = amount.replaceAll(',', '').replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);

    String? error;
    if (cleanedAmount.isEmpty) {
      error = 'Vui lòng nhập số tiền';
    } else if (amountValue == null || amountValue <= 0) {
      error = 'Số tiền không hợp lệ';
    } else if (amountValue < 200000) {
      error = 'Số tiền tối thiểu là \$200,000';
    }

    state = state.copyWith(amount: amount, amountError: error);
  }

  bool validate() {
    String? bankError;
    String? accountNumberError;
    String? accountNameError;
    String? amountError;

    if (state.selectedBank == null || state.selectedBank!.isEmpty) {
      bankError = 'Vui lòng chọn ngân hàng';
    }

    if (state.accountNumber.isEmpty) {
      accountNumberError = 'Vui lòng nhập số tài khoản';
    } else if (state.accountNumber.length < 8) {
      accountNumberError = 'Số tài khoản phải có ít nhất 8 ký tự';
    }

    if (state.accountName.isEmpty) {
      accountNameError = 'Vui lòng nhập tên tài khoản';
    } else if (state.accountName.length < 2) {
      accountNameError = 'Tên tài khoản phải có ít nhất 2 ký tự';
    }

    final cleanedAmount = state.amount.replaceAll(',', '').replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);
    if (cleanedAmount.isEmpty) {
      amountError = 'Vui lòng nhập số tiền';
    } else if (amountValue == null || amountValue <= 0) {
      amountError = 'Số tiền không hợp lệ';
    } else if (amountValue < 200000) {
      amountError = 'Số tiền tối thiểu là \$200,000';
    }

    state = state.copyWith(
      bankError: bankError,
      accountNumberError: accountNumberError,
      accountNameError: accountNameError,
      amountError: amountError,
    );

    return bankError == null &&
        accountNumberError == null &&
        accountNameError == null &&
        amountError == null;
  }

  void reset() {
    state = const WithdrawBankFormState();
  }
}

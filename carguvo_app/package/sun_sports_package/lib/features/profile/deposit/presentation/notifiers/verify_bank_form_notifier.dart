import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class VerifyBankFormNotifier extends StateNotifier<VerifyBankFormState> {
  VerifyBankFormNotifier() : super(const VerifyBankFormState());

  void updateBank(String? bank) {
    state = state.copyWith(
      selectedBank: bank,
      bankError: bank == null || bank.isEmpty
          ? 'Vui lòng chọn ngân hàng'
          : null,
    );
  }

  void updateAccountName(String value) {
    String? error;
    if (value.trim().isEmpty) {
      error = 'Vui lòng nhập tên tài khoản';
    } else if (value.trim().length < 2) {
      error = 'Tên tài khoản phải có ít nhất 2 ký tự';
    }

    state = state.copyWith(accountName: value, accountNameError: error);
  }

  void updateAccountNumber(String value) {
    String? error;
    if (value.trim().isEmpty) {
      error = 'Vui lòng nhập số tài khoản';
    } else if (value.trim().length < 8) {
      error = 'Số tài khoản phải có ít nhất 8 ký tự';
    }

    state = state.copyWith(accountNumber: value, accountNumberError: error);
  }

  bool validate() {
    String? bankError;
    String? accountNameError;
    String? accountNumberError;

    if (state.selectedBank == null || state.selectedBank!.isEmpty) {
      bankError = 'Vui lòng chọn ngân hàng';
    }

    if (state.accountName.trim().isEmpty) {
      accountNameError = 'Vui lòng nhập tên tài khoản';
    } else if (state.accountName.trim().length < 2) {
      accountNameError = 'Tên tài khoản phải có ít nhất 2 ký tự';
    }

    if (state.accountNumber.trim().isEmpty) {
      accountNumberError = 'Vui lòng nhập số tài khoản';
    } else if (state.accountNumber.trim().length < 8) {
      accountNumberError = 'Số tài khoản phải có ít nhất 8 ký tự';
    }

    state = state.copyWith(
      bankError: bankError,
      accountNameError: accountNameError,
      accountNumberError: accountNumberError,
    );

    return bankError == null &&
        accountNameError == null &&
        accountNumberError == null;
  }

  void reset() {
    state = const VerifyBankFormState();
  }
}

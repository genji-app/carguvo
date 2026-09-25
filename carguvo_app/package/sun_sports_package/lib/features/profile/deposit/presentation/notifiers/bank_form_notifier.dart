import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class BankFormNotifier extends StateNotifier<BankFormState> {
  BankFormNotifier() : super(const BankFormState());

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
    } else if (amountValue < 10000) {
      error = 'Số tiền tối thiểu là \$10,000';
    }

    state = state.copyWith(amount: amount, amountError: error);
  }

  void updateSenderName(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập tên người gửi';
    } else if (value.length < 2) {
      error = 'Tên người gửi phải có ít nhất 2 ký tự';
    }

    state = state.copyWith(senderName: value, senderNameError: error);
  }

  void updateNote(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập mã giao dịch';
    }

    state = state.copyWith(note: value, noteError: error);
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
    } else if (amountValue < 10000) {
      amountError = 'Số tiền tối thiểu là \$10,000';
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

  bool validateConfirmForm() {
    String? amountError;
    String? senderNameError;
    String? noteError;

    final cleanedAmount = state.amount.replaceAll(',', '').replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);
    if (cleanedAmount.isEmpty) {
      amountError = 'Vui lòng nhập số tiền';
    } else if (amountValue == null || amountValue <= 0) {
      amountError = 'Số tiền không hợp lệ';
    } else if (amountValue < 10000) {
      amountError = 'Số tiền tối thiểu là \$10,000';
    } else if (amountValue > 100000000) {
      amountError = 'Số tiền tối đa là \$100,000,000';
    }

    if (state.senderName.isEmpty) {
      senderNameError = 'Vui lòng nhập tên người gửi';
    } else if (state.senderName.length < 2) {
      senderNameError = 'Tên người gửi phải có ít nhất 2 ký tự';
    }

    if (state.note.isEmpty) {
      noteError = 'Vui lòng nhập mã giao dịch';
    }

    state = state.copyWith(
      amountError: amountError,
      senderNameError: senderNameError,
      noteError: noteError,
    );

    return amountError == null && senderNameError == null && noteError == null;
  }

  void reset() {
    state = const BankFormState();
  }
}

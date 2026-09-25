import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class EWalletFormNotifier extends StateNotifier<EWalletFormState> {
  EWalletFormNotifier() : super(const EWalletFormState());

  void updateWallet(String? wallet) {
    state = state.copyWith(
      selectedWallet: wallet,
      walletError: wallet == null || wallet.isEmpty ? 'Vui lòng chọn ví' : null,
    );
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
    } else if (amountValue > 100000000) {
      error = 'Số tiền tối đa là \$100,000,000';
    }

    state = state.copyWith(amount: amount, amountError: error);
  }

  bool validate() {
    String? walletError;
    String? amountError;

    if (state.selectedWallet == null || state.selectedWallet!.isEmpty) {
      walletError = 'Vui lòng chọn ví';
    }

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

    state = state.copyWith(walletError: walletError, amountError: amountError);

    return walletError == null && amountError == null;
  }

  void reset() {
    state = const EWalletFormState();
  }
}

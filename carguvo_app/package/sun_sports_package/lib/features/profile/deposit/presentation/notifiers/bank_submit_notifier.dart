import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_bank_deposit_usecase.dart';

class BankSubmitNotifier extends StateNotifier<BankSubmitState> {
  final SubmitBankDepositUseCase _submitBankDepositUseCase;
  String? _lastTransactionId;

  BankSubmitNotifier(this._submitBankDepositUseCase)
    : super(const BankSubmitState.idle());

  String? get lastTransactionId => _lastTransactionId;

  Future<void> submit(BankDepositRequest request) async {
    state = const BankSubmitState.submitting();

    final result = await _submitBankDepositUseCase(request);

    result.fold((failure) => state = BankSubmitState.error(failure.message), (
      response,
    ) {
      _lastTransactionId = response.transactionId;
      state = const BankSubmitState.success();
    });
  }

  void reset() {
    state = const BankSubmitState.idle();
    _lastTransactionId = null;
  }
}

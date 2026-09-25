import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/create_transaction_slip_usecase.dart';

class BankTransactionSlipNotifier
    extends StateNotifier<BankTransactionSlipState> {
  final CreateTransactionSlipUseCase _createTransactionSlipUseCase;
  String? _lastTransactionId;

  BankTransactionSlipNotifier(this._createTransactionSlipUseCase)
    : super(const BankTransactionSlipState.idle());

  String? get lastTransactionId => _lastTransactionId;

  Future<void> createTransactionSlip(BankTransactionSlipRequest request) async {
    state = const BankTransactionSlipState.submitting();

    final result = await _createTransactionSlipUseCase(request);

    result.fold(
      (failure) => state = BankTransactionSlipState.error(failure.message),
      (response) {
        _lastTransactionId = response.transactionId;
        state = const BankTransactionSlipState.success();
      },
    );
  }

  void reset() {
    state = const BankTransactionSlipState.idle();
    _lastTransactionId = null;
  }
}

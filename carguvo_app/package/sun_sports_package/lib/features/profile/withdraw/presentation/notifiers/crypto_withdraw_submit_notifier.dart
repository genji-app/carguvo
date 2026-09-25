import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:sun_sports/features/profile/withdraw/domain/usecases/submit_withdraw_crypto_usecase.dart';

class CryptoWithdrawSubmitNotifier
    extends StateNotifier<CryptoWithdrawSubmitState> {
  final SubmitWithdrawCryptoUseCase _submitCryptoWithdrawUseCase;

  CryptoWithdrawSubmitNotifier(this._submitCryptoWithdrawUseCase)
    : super(const CryptoWithdrawSubmitState.idle());

  Future<void> submit(WithdrawCryptoRequest request) async {
    state = const CryptoWithdrawSubmitState.submitting();

    final result = await _submitCryptoWithdrawUseCase(request);

    result.fold(
      (failure) => state = CryptoWithdrawSubmitState.error(failure.message),
      (response) => state = const CryptoWithdrawSubmitState.success(),
    );
  }

  void reset() {
    state = const CryptoWithdrawSubmitState.idle();
  }
}

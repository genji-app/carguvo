import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/verify_bank_account_usecase.dart';

class VerifyBankSubmitNotifier extends StateNotifier<VerifyBankSubmitState> {
  final Ref _ref;
  final VerifyBankAccountUseCase _useCase;

  VerifyBankSubmitNotifier(this._ref, this._useCase)
    : super(const VerifyBankSubmitState.idle());

  Future<bool> submit({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  }) async {
    state = const VerifyBankSubmitState.submitting();

    final result = await _useCase(
      bankId: bankId,
      accountHolder: accountHolder,
      accountNo: accountNo,
    );

    return result.fold(
      (failure) {
        state = VerifyBankSubmitState.error(failure.message);
        return false;
      },
      (message) {
        _ref.read(needVerifyBankAccountOverrideProvider.notifier).state = false;
        state = const VerifyBankSubmitState.success();
        return true;
      },
    );
  }

  void reset() {
    state = const VerifyBankSubmitState.idle();
  }
}

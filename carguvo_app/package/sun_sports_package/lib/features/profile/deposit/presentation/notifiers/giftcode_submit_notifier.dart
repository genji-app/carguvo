import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_giftcode_deposit_usecase.dart';

class GiftcodeSubmitNotifier extends StateNotifier<GiftcodeSubmitState> {
  final SubmitGiftcodeDepositUseCase _submitGiftcodeDepositUseCase;

  GiftcodeSubmitNotifier(this._submitGiftcodeDepositUseCase)
    : super(const GiftcodeSubmitState.idle());

  Future<void> submit(GiftcodeDepositRequest request) async {
    state = const GiftcodeSubmitState.submitting();

    final result = await _submitGiftcodeDepositUseCase(request);

    result.fold(
      (failure) => state = GiftcodeSubmitState.error(failure.message),
      (response) {
        final successMessage =
            response.additionalData?['success_message']?.toString();
        state = GiftcodeSubmitState.success(message: successMessage);
      },
    );
  }

  void reset() {
    state = const GiftcodeSubmitState.idle();
  }
}

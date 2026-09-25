import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_card_deposit_usecase.dart';

class CardSubmitNotifier extends StateNotifier<CardSubmitState> {
  final SubmitCardDepositUseCase _submitCardDepositUseCase;
  DepositResponse? _cardDepositResponse;

  CardSubmitNotifier(this._submitCardDepositUseCase)
    : super(const CardSubmitState.idle());

  DepositResponse? get cardDepositResponse => _cardDepositResponse;

  Future<void> submit(CardDepositRequest request) async {
    state = const CardSubmitState.submitting();

    final result = await _submitCardDepositUseCase(request);

    result.fold((failure) => state = CardSubmitState.error(failure.message), (
      response,
    ) {
      _cardDepositResponse = response;
      state = const CardSubmitState.success();
    });
  }

  void reset() {
    state = const CardSubmitState.idle();
    _cardDepositResponse = null;
  }
}

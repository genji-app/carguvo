import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/get_crypto_address_usecase.dart';
import 'package:sun_sports/features/profile/deposit/domain/usecases/submit_crypto_deposit_usecase.dart';

class CryptoSubmitNotifier extends StateNotifier<CryptoSubmitState> {
  final SubmitCryptoDepositUseCase _submitCryptoDepositUseCase;
  final GetCryptoAddressUseCase _getCryptoAddressUseCase;
  CryptoAddressResponse? _cryptoAddressResponse;

  CryptoSubmitNotifier(
    this._submitCryptoDepositUseCase,
    this._getCryptoAddressUseCase,
  ) : super(const CryptoSubmitState.idle());

  CryptoAddressResponse? get cryptoAddressResponse => _cryptoAddressResponse;

  Future<void> getCryptoAddress(CryptoAddressRequest request) async {
    state = const CryptoSubmitState.submitting();

    final result = await _getCryptoAddressUseCase(request);

    result.fold((failure) => state = CryptoSubmitState.error(failure.message), (
      response,
    ) {
      _cryptoAddressResponse = response;
      state = const CryptoSubmitState.success();
    });
  }

  Future<void> submit(CryptoDepositRequest request) async {
    state = const CryptoSubmitState.submitting();

    final result = await _submitCryptoDepositUseCase(request);

    result.fold(
      (failure) => state = CryptoSubmitState.error(failure.message),
      (response) => state = const CryptoSubmitState.success(),
    );
  }

  void reset() {
    state = const CryptoSubmitState.idle();
    _cryptoAddressResponse = null;
  }
}

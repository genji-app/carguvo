import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class CryptoFormNotifier extends StateNotifier<CryptoFormState> {
  CryptoFormNotifier() : super(const CryptoFormState());

  void updateCrypto(String? cryptoId) {
    state = state.copyWith(
      selectedCrypto: cryptoId,
      cryptoError: cryptoId == null || cryptoId.isEmpty
          ? 'Vui lòng chọn loại tiền'
          : null,
    );
  }

  bool validate() {
    String? cryptoError;

    if (state.selectedCrypto == null || state.selectedCrypto!.isEmpty) {
      cryptoError = 'Vui lòng chọn loại tiền';
    }

    state = state.copyWith(cryptoError: cryptoError);

    return cryptoError == null;
  }

  void reset() {
    state = const CryptoFormState();
  }
}

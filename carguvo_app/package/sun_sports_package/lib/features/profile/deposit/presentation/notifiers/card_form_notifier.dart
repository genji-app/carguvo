import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class CardFormNotifier extends StateNotifier<CardFormState> {
  CardFormNotifier() : super(const CardFormState());

  void updateCardType(String? cardType) {
    state = state.copyWith(
      selectedCardType: cardType,
      cardTypeError: cardType == null || cardType.isEmpty
          ? 'Vui lòng chọn thẻ'
          : null,
    );
  }

  void updateDenomination(String? denomination) {
    state = state.copyWith(
      selectedDenomination: denomination,
      denominationError: denomination == null || denomination.isEmpty
          ? 'Vui lòng chọn mệnh giá'
          : null,
    );
  }

  void updateSerialNumber(String value) {
    state = state.copyWith(serialNumber: value, serialNumberError: null);
  }

  void updateCardCode(String value) {
    state = state.copyWith(cardCode: value, cardCodeError: null);
  }

  bool validate() => state.isValid;

  void reset() {
    state = const CardFormState();
  }

  void clearTextFields() {
    state = state.copyWith(
      serialNumber: '',
      cardCode: '',
      serialNumberError: null,
      cardCodeError: null,
    );
  }
}

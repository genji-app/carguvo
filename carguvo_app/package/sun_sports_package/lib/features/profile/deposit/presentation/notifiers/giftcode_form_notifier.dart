import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class GiftcodeFormNotifier extends StateNotifier<GiftcodeFormState> {
  GiftcodeFormNotifier() : super(const GiftcodeFormState());

  void updateGiftcode(String value) {
    state = state.copyWith(giftCode: value, giftCodeError: null);
  }

  bool validate() => state.isValid;

  void reset() {
    state = const GiftcodeFormState();
  }
}

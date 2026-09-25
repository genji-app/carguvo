import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/state/deposit_state.dart';

class DepositSelectionNotifier extends StateNotifier<DepositSelectionState> {
  DepositSelectionNotifier() : super(const DepositSelectionState());

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method, isContainerVisible: true);
  }

  void reset() {
    state = const DepositSelectionState();
  }

  void setContainerVisible(bool visible) {
    state = state.copyWith(isContainerVisible: visible);
  }
}

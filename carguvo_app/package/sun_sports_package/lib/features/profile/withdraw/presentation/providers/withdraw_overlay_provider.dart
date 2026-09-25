import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/notifiers/withdraw_bank_form_notifier.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_card_form_provider.dart';
import 'package:sun_sports/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:sun_sports/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';

final withdrawOverlayVisibleProvider = StateProvider<bool>((ref) => false);

final withdrawSelectionProvider =
    StateNotifierProvider<WithdrawSelectionNotifier, WithdrawSelectionState>((
      ref,
    ) {
      return WithdrawSelectionNotifier();
    });

final withdrawConfirmationDataProvider =
    StateProvider<WithdrawConfirmationData?>((ref) => null);

final withdrawBankFormProvider =
    StateNotifierProvider<WithdrawBankFormNotifier, WithdrawBankFormState>(
      (ref) => WithdrawBankFormNotifier(),
    );

void resetWithdrawForms(WidgetRef ref) {
  ref.read(withdrawBankFormProvider.notifier).reset();
  ref.invalidate(withdrawCardFormProvider);
  ref.read(withdrawSelectionProvider.notifier).clearSelection();
}

class WithdrawSelectionState {
  final WithdrawPaymentMethod? selectedMethod;

  const WithdrawSelectionState({this.selectedMethod});

  WithdrawSelectionState copyWith({WithdrawPaymentMethod? selectedMethod}) {
    return WithdrawSelectionState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }
}

class WithdrawSelectionNotifier extends StateNotifier<WithdrawSelectionState> {
  WithdrawSelectionNotifier() : super(const WithdrawSelectionState());

  void selectPaymentMethod(WithdrawPaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void clearSelection() {
    state = const WithdrawSelectionState();
  }
}

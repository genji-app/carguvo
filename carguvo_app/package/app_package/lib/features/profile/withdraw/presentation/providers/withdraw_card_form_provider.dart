import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawCardFormState {
  final String? cardType;
  final String? denomination;
  final int quantity;

  const WithdrawCardFormState({
    this.cardType,
    this.denomination,
    this.quantity = 1,
  });

  WithdrawCardFormState copyWith({
    String? cardType,
    bool clearCardType = false,
    String? denomination,
    bool clearDenomination = false,
    int? quantity,
  }) {
    return WithdrawCardFormState(
      cardType: clearCardType ? null : (cardType ?? this.cardType),
      denomination: clearDenomination
          ? null
          : (denomination ?? this.denomination),
      quantity: quantity ?? this.quantity,
    );
  }
}

final withdrawCardFormProvider = StateProvider<WithdrawCardFormState>(
  (ref) => const WithdrawCardFormState(),
);

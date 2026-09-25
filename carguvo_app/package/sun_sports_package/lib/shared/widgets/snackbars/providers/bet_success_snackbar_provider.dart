import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';

class BetSuccessSnackBarState {
  final bool isVisible;
  final SingleBetData? latestBet;

  const BetSuccessSnackBarState({this.isVisible = false, this.latestBet});

  BetSuccessSnackBarState copyWith({
    bool? isVisible,
    SingleBetData? latestBet,
  }) {
    return BetSuccessSnackBarState(
      isVisible: isVisible ?? this.isVisible,
      latestBet: latestBet ?? this.latestBet,
    );
  }
}

class BetSuccessSnackBarNotifier
    extends StateNotifier<BetSuccessSnackBarState> {
  BetSuccessSnackBarNotifier() : super(const BetSuccessSnackBarState());

  void show(SingleBetData bet) {
    debugPrint(
      '[BetSuccessSnackBarNotifier] show() called with bet: ${bet.displayName}',
    );
    state = state.copyWith(isVisible: true, latestBet: bet);
    debugPrint(
      '[BetSuccessSnackBarNotifier] state updated: isVisible=${state.isVisible}, latestBet=${state.latestBet?.displayName}',
    );
  }

  void hide() {
    debugPrint('[BetSuccessSnackBarNotifier] hide() called');
    state = state.copyWith(isVisible: false);
  }
}

final betSuccessSnackBarProvider =
    StateNotifierProvider<BetSuccessSnackBarNotifier, BetSuccessSnackBarState>((
      ref,
    ) {
      return BetSuccessSnackBarNotifier();
    });

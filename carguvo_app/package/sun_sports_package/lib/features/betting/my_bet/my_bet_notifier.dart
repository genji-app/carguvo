import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';

class MyBetState {
  final int betSlipCount;
  final int myBetsCount;

  const MyBetState({this.betSlipCount = 0, this.myBetsCount = 0});

  MyBetState copyWith({int? betSlipCount, int? myBetsCount}) {
    return MyBetState(
      betSlipCount: betSlipCount ?? this.betSlipCount,
      myBetsCount: myBetsCount ?? this.myBetsCount,
    );
  }
}

class MyBetNotifier extends Notifier<MyBetState> {
  @override
  MyBetState build() {
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);

    final parlayState = ref.watch(parlayStateProvider);
    final minMatches = parlayState.minMatches > 0 ? parlayState.minMatches : 2;

    final hasValidCombo = comboBetsCount >= minMatches;
    final betSlipCount = singleBetsCount + (hasValidCombo ? 1 : 0);

    final activeCountAsync = ref.watch(activeBetCountProvider);

    final repo = ref.watch(myBetRepositoryProvider);
    final myBetsCount =
        activeCountAsync.unwrapPrevious().valueOrNull ?? repo.currentActiveCount;

    return MyBetState(betSlipCount: betSlipCount, myBetsCount: myBetsCount);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/websocket/websocket_messages.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

typedef StoreOdds = ({double? styleOdds, double? decimalOdds});
const StoreOdds _emptyStoreOdds = (styleOdds: null, decimalOdds: null);

double resolveEffectiveOdds({
  required SingleBetData singleBet,
  required OddsStyleValues? wsValues,
  required OddsStyle style,
  StoreOdds storeOdds = _emptyStoreOdds,
}) {
  bool isUsable(double v) => v != 0 && v != -100;

  if (wsValues != null) {
    final wsStyleOdds = wsValues.getByStyleIndex(style.index);
    if (isUsable(wsStyleOdds)) return wsStyleOdds;
  }

  final storeStyle = storeOdds.styleOdds;
  if (storeStyle != null && isUsable(storeStyle)) return storeStyle;

  final initialStyleOdds = singleBet.getOddsByStyle(style);
  if (isUsable(initialStyleOdds)) return initialStyleOdds;

  if (wsValues != null && isUsable(wsValues.decimal)) return wsValues.decimal;

  final storeDecimal = storeOdds.decimalOdds;
  if (storeDecimal != null && isUsable(storeDecimal)) return storeDecimal;

  final initialDecimal = singleBet.getOddsByStyle(OddsStyle.decimal);
  if (isUsable(initialDecimal)) return initialDecimal;

  return 0;
}

StoreOdds readStoreOdds(SportSocketAdapter adapter, SingleBetData bet, OddsStyle style) {
  final offerId = bet.offerId;
  if (offerId == null || offerId.isEmpty) return _emptyStoreOdds;

  final socket.OddsData? odds = adapter.getOdds(
    bet.eventData.eventId,
    bet.marketData.marketId,
    offerId,
  );
  if (odds == null) return _emptyStoreOdds;

  double? decimal;
  String? malay;
  String? indo;
  String? hk;
  switch (bet.oddsType) {
    case OddsType.home:
      decimal = odds.oddsHome;
      malay = odds.malayHome;
      indo = odds.indoHome;
      hk = odds.hkHome;
      break;
    case OddsType.away:
      decimal = odds.oddsAway;
      malay = odds.malayAway;
      indo = odds.indoAway;
      hk = odds.hkAway;
      break;
    case OddsType.draw:
      decimal = odds.oddsDraw;
      break;
    default:
      return _emptyStoreOdds;
  }

  final double? styleOdds = switch (style) {
    OddsStyle.malay => double.tryParse(malay ?? ''),
    OddsStyle.indo => double.tryParse(indo ?? ''),
    OddsStyle.hongKong => double.tryParse(hk ?? ''),
    OddsStyle.decimal => decimal,
  };
  return (styleOdds: styleOdds, decimalOdds: decimal);
}

double watchLiveOddsFor(WidgetRef ref, SingleBetData bet) {
  final selectionId = bet.selectionId;
  final wsValues = selectionId != null
      ? ref.watch(
          oddsChangeDataProvider(selectionId).select((d) => d?.oddsValues),
        )
      : null;
  final adapter = ref.read(sportSocketAdapterProvider);
  return resolveEffectiveOdds(
    singleBet: bet,
    wsValues: wsValues,
    style: bet.sendOddsStyle,
    storeOdds: readStoreOdds(adapter, bet, bet.sendOddsStyle),
  );
}

double _watchLiveOddsFor(Ref ref, SingleBetData bet) {
  final selectionId = bet.selectionId;
  final wsValues = selectionId != null
      ? ref.watch(
          oddsChangeDataProvider(selectionId).select((d) => d?.oddsValues),
        )
      : null;
  final adapter = ref.read(sportSocketAdapterProvider);
  return resolveEffectiveOdds(
    singleBet: bet,
    wsValues: wsValues,
    style: bet.sendOddsStyle,
    storeOdds: readStoreOdds(adapter, bet, bet.sendOddsStyle),
  );
}

double watchLivePotentialWinnings(WidgetRef ref, SingleBetData bet) =>
    bet.potentialWinningsWith(watchLiveOddsFor(ref, bet));

final parlayLiveValidTotalBetProvider = Provider.autoDispose<double>((ref) {
  final tab = ref.watch(parlayStateProvider.select((s) => s.tab));
  if (tab != ParlayTab.single) {
    return ref.watch(parlayStateProvider.select((s) => s.validTotalBet));
  }
  final bets = ref.watch(singleBetsProvider);
  return bets.fold<double>(0, (sum, bet) {
    if (!bet.canPlaceBet) return sum;
    return sum + bet.totalCostWith(_watchLiveOddsFor(ref, bet));
  });
});

final parlayValidTicketCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.validTicketCount));
});

final parlayLiveValidPotentialWinProvider = Provider.autoDispose<double>((ref) {
  final tab = ref.watch(parlayStateProvider.select((s) => s.tab));
  if (tab != ParlayTab.single) {
    return ref.watch(parlayStateProvider.select((s) => s.validPotentialWin));
  }
  final bets = ref.watch(singleBetsProvider);
  return bets.fold<double>(0, (sum, bet) {
    if (!bet.canPlaceBet) return sum;
    return sum + bet.potentialWinningsWith(_watchLiveOddsFor(ref, bet));
  });
});

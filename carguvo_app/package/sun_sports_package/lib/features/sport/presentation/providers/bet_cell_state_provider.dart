import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    hide OddsChangeDirection;

@immutable
class BetCellKey {
  final String? selectionId;

  final String? betKey;

  final int? eventId;
  final int? marketId;

  const BetCellKey({
    this.selectionId,
    this.betKey,
    this.eventId,
    this.marketId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BetCellKey &&
        other.selectionId == selectionId &&
        other.betKey == betKey &&
        other.eventId == eventId &&
        other.marketId == marketId;
  }

  @override
  int get hashCode => Object.hash(selectionId, betKey, eventId, marketId);

  @override
  String toString() =>
      'BetCellKey(selectionId: $selectionId, betKey: $betKey, '
      'eventId: $eventId, marketId: $marketId)';
}

@immutable
class BetCellState {
  final String? oddsValue;

  final OddsChangeDirection direction;

  final bool isVibrating;

  final bool isInSlip;

  final bool isMarketSuspended;

  final bool isEventSuspended;

  const BetCellState({
    this.oddsValue,
    this.direction = OddsChangeDirection.none,
    this.isVibrating = false,
    this.isInSlip = false,
    this.isMarketSuspended = false,
    this.isEventSuspended = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BetCellState &&
        other.oddsValue == oddsValue &&
        other.direction == direction &&
        other.isVibrating == isVibrating &&
        other.isInSlip == isInSlip &&
        other.isMarketSuspended == isMarketSuspended &&
        other.isEventSuspended == isEventSuspended;
  }

  @override
  int get hashCode => Object.hash(
        oddsValue,
        direction,
        isVibrating,
        isInSlip,
        isMarketSuspended,
        isEventSuspended,
      );

  @override
  String toString() =>
      'BetCellState(oddsValue: $oddsValue, direction: $direction, '
      'isVibrating: $isVibrating, isInSlip: $isInSlip, '
      'isMarketSuspended: $isMarketSuspended, '
      'isEventSuspended: $isEventSuspended)';
}

final betCellStateProvider =
    Provider.autoDispose.family<BetCellState, BetCellKey>((ref, key) {
  final selectionId = key.selectionId;
  final betKey = key.betKey;
  final eventId = key.eventId;
  final marketId = key.marketId;

  String? oddsValue;
  var direction = OddsChangeDirection.none;
  var isVibrating = false;
  if (selectionId != null) {
    if (selectionId.isNotEmpty) {
      final data = ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
      final oddsStyle = ref.watch(oddsStyleProvider);
      oddsValue = oddsDisplayValueOf(data, oddsStyle);
      direction = oddsDirectionOf(data);
    }
    isVibrating = ref.watch(
      vibratingOddsProvider.select((state) => state.isVibrating(selectionId)),
    );
  }

  final isInSlip = betKey != null &&
      ref.watch(inSlipKeysProvider.select((keys) => keys.contains(betKey)));

  var isMarketSuspended = false;
  var isEventSuspended = false;
  if (eventId != null) {
    isEventSuspended = ref.watch(
      marketStatusProvider.select((state) => state.isEventSuspended(eventId)),
    );
    if (marketId != null) {
      isMarketSuspended = ref.watch(
        marketStatusProvider.select(
          (state) => state.isMarketSuspended(eventId, marketId),
        ),
      );
    }
  }

  return BetCellState(
    oddsValue: oddsValue,
    direction: direction,
    isVibrating: isVibrating,
    isInSlip: isInSlip,
    isMarketSuspended: isMarketSuspended,
    isEventSuspended: isEventSuspended,
  );
});

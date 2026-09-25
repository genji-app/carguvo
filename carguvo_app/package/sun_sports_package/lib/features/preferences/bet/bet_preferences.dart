import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

final betPreferencesProvider =
    StateNotifierProvider.autoDispose<BetPreferencesNotifier, BetPreferences>((
      ref,
    ) {
      final storage = ref.read(sportStorageProvider);
      final oddsStyleNotifier = ref.read(oddsStyleProvider.notifier);
      return BetPreferencesNotifier(
        sportStorage: storage,
        oddsStyleNotifier: oddsStyleNotifier,
      )..loadInitial();
    }, name: 'BetPreferencesProvider');

class BetPreferencesNotifier extends StateNotifier<BetPreferences> {
  BetPreferencesNotifier({
    required this.sportStorage,
    required this.oddsStyleNotifier,
  }) : super(const BetPreferences.initial());

  final SportStorage sportStorage;
  final OddsStyleNotifier oddsStyleNotifier;

  void updateOddsStyle(OddsStyle value) {
    state = state.copyWith(oddsStyle: value);
    oddsStyleNotifier.change(value);
  }

  void loadInitial() {
    final styleName = sportStorage.getOddsStyleSync();
    final style = OddsStyle.fromShortName(styleName);
    state = state.copyWith(oddsStyle: style);
  }
}

@immutable
class BetPreferences {
  const BetPreferences({required this.oddsStyle});

  const BetPreferences.initial({this.oddsStyle = OddsStyle.decimal});

  final OddsStyle oddsStyle;

  @override
  String toString() => 'BetPreferences(oddsStyle: $oddsStyle)';

  @override
  bool operator ==(covariant BetPreferences other) {
    if (identical(this, other)) return true;

    return other.oddsStyle == oddsStyle;
  }

  @override
  int get hashCode => oddsStyle.hashCode;

  BetPreferences copyWith({OddsStyle? oddsStyle}) =>
      BetPreferences(oddsStyle: oddsStyle ?? this.oddsStyle);
}

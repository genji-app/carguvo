import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

class BettingPopupV2State {
  final BettingPopupDataV2? bettingData;
  final String betAmount;
  final int minStake;
  final int maxStake;
  final int maxPayout;
  final bool isCalculating;
  final bool isPlacingBet;
  final String? error;
  final int? errorCode;
  final double? updatedOdds;
  final bool isClosed;

  const BettingPopupV2State({
    this.bettingData,
    this.betAmount = '0',
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
    this.isCalculating = false,
    this.isPlacingBet = false,
    this.error,
    this.errorCode,
    this.updatedOdds,
    this.isClosed = false,
  });

  BettingPopupV2State copyWith({
    BettingPopupDataV2? bettingData,
    String? betAmount,
    int? minStake,
    int? maxStake,
    int? maxPayout,
    bool? isCalculating,
    bool? isPlacingBet,
    String? error,
    int? errorCode,
    double? updatedOdds,
    bool? isClosed,
    bool clearError = false,
  }) {
    return BettingPopupV2State(
      bettingData: bettingData ?? this.bettingData,
      betAmount: betAmount ?? this.betAmount,
      minStake: minStake ?? this.minStake,
      maxStake: maxStake ?? this.maxStake,
      maxPayout: maxPayout ?? this.maxPayout,
      isCalculating: isCalculating ?? this.isCalculating,
      isPlacingBet: isPlacingBet ?? this.isPlacingBet,
      error: clearError ? null : (error ?? this.error),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      updatedOdds: updatedOdds ?? this.updatedOdds,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  double getCurrentOdds() =>
      updatedOdds ?? bettingData?.getSelectedOddsValue() ?? 0.0;

  String getDisplayOdds() {
    final odds = getCurrentOdds();
    if (odds <= 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }
}

class BettingPopupV2Notifier extends StateNotifier<BettingPopupV2State> {
  final Ref _ref;

  BettingPopupV2Notifier(this._ref) : super(const BettingPopupV2State());

  void resetForNewPopup(BettingPopupDataV2 data) {
    state = const BettingPopupV2State().copyWith(
      bettingData: data,
      betAmount: '0',
    );
    final legacyData = _convertToLegacy(data);
    if (legacyData != null) {
      _ref.read(bettingPopupProvider.notifier).resetForNewPopup(legacyData);
    }
  }

  Future<void> initializeAsync() async {
    await _ref.read(bettingPopupProvider.notifier).initializeAsync();

    final legacyState = _ref.read(bettingPopupProvider);
    state = state.copyWith(
      minStake: legacyState.minStake,
      maxStake: legacyState.maxStake,
      maxPayout: legacyState.maxPayout,
      isCalculating: legacyState.isCalculating,
      error: legacyState.error,
      errorCode: legacyState.errorCode,
      updatedOdds: legacyState.updatedOdds,
    );
  }

  Future<void> initialize(BettingPopupDataV2 data) async {
    resetForNewPopup(data);
    await initializeAsync();
  }

  BettingPopupData? _convertToLegacy(BettingPopupDataV2 data) {
    try {
      return BettingPopupData(
        sportId: data.sportId,
        oddsData: data.oddsData.toLegacy(),
        marketData: data.marketData.toLegacy(),
        eventData: data.eventData.toLegacy(),
        oddsType: data.oddsType,
        leagueData: data.leagueData?.toLegacy(),
        oddsStyle: _convertOddsFormat(data.oddsFormat),
        minStake: data.minStake,
        maxStake: data.maxStake,
        maxPayout: data.maxPayout,
      );
    } catch (e) {
      return null;
    }
  }

  OddsStyle _convertOddsFormat(OddsFormatV2 oddsFormat) {
    switch (oddsFormat) {
      case OddsFormatV2.malay:
        return OddsStyle.malay;
      case OddsFormatV2.indo:
        return OddsStyle.indo;
      case OddsFormatV2.hk:
        return OddsStyle.hongKong;
      case OddsFormatV2.decimal:
        return OddsStyle.decimal;
    }
  }

  void updateBetAmount(String amount) {
    state = state.copyWith(betAmount: amount, clearError: true);
    _ref.read(bettingPopupProvider.notifier).updateBetAmount(amount);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
    _ref.read(bettingPopupProvider.notifier).clearError();
  }

  Future<bool> placeBet() async {
    return _ref.read(bettingPopupProvider.notifier).placeBet();
  }
}

final bettingPopupV2Provider =
    StateNotifierProvider<BettingPopupV2Notifier, BettingPopupV2State>((ref) {
      return BettingPopupV2Notifier(ref);
    });

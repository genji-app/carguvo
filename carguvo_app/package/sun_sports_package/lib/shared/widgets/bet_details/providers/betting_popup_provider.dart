import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betting_domain/betting_domain.dart'
    hide bettingApiErrorDisplayMessage;
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/features/betting/data/repositories/betting_repository.dart';
import 'package:sun_sports/core/services/repositories/outright_betting_repository.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class BettingPopupState {
  final BettingPopupData? bettingData;

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

  const BettingPopupState({
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

  BettingPopupState copyWith({
    BettingPopupData? bettingData,
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
    return BettingPopupState(
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
    if (odds == 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }

  int getActualStake() {
    final amount = int.tryParse(betAmount.replaceAll(',', '')) ?? 0;
    if (amount == 0) return 0;

    final oddsStyle = bettingData?.sendOddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if (oddsStyle == OddsStyle.malay && oddsValue < 0) {
      return (amount * oddsValue.abs()).floor();
    }

    if (oddsStyle == OddsStyle.indo && oddsValue < -1) {
      return (amount * oddsValue.abs()).floor();
    }

    return amount;
  }

  int calculateWinnings() {
    final amount = int.tryParse(betAmount.replaceAll(',', '')) ?? 0;
    if (amount == 0) return 0;

    final oddsStyle = bettingData?.sendOddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if (oddsStyle == OddsStyle.malay && oddsValue < 0) {
      final actualStake = (amount * oddsValue.abs()).floor();
      return amount + actualStake;
    }

    if (oddsStyle == OddsStyle.indo && oddsValue < -1) {
      final actualStake = (amount * oddsValue.abs()).floor();
      return amount + actualStake;
    }

    return _calculateNormalWinnings(amount, oddsValue, oddsStyle);
  }

  int _calculateNormalWinnings(int stake, double odds, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return (stake * odds).floor();
      case OddsStyle.malay:
        if (odds >= 0) {
          return (stake * (1 + odds)).floor();
        } else {
          return stake;
        }
      case OddsStyle.indo:
        if (odds >= 0) {
          return (stake * (1 + odds)).floor();
        } else {
          return stake;
        }
      case OddsStyle.hongKong:
        return (stake * (1 + odds)).floor();
    }
  }

  String getInputPlaceholder() {
    final oddsStyle = bettingData?.sendOddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if ((oddsStyle == OddsStyle.malay && oddsValue < 0) ||
        (oddsStyle == OddsStyle.indo && oddsValue < -1)) {
      return 'Nhập mức thắng';
    }

    return 'Nhập tiền cược';
  }

  String getCostLabel() {
    final oddsStyle = bettingData?.sendOddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if ((oddsStyle == OddsStyle.malay && oddsValue < 0) ||
        (oddsStyle == OddsStyle.indo && oddsValue < -1)) {
      return 'Số Tiền Cược';
    }

    return 'Tổng tiền cược';
  }
}

class BettingPopupNotifier extends StateNotifier<BettingPopupState> {
  final Ref _ref;
  final SbHttpManager _httpManager = SbHttpManager.instance;
  final BettingRepository _repository = BettingRepositoryImpl();
  final OutrightBettingRepository _outrightRepository =
      OutrightBettingRepositoryImpl();

  StreamSubscription<socket.OddsChangeData>? _oddsChangeSubscription;
  StreamSubscription<SportSocketUpdate>? _storeUpdateSubscription;
  Timer? _debounceTimer;

  BettingPopupNotifier(this._ref) : super(const BettingPopupState());

  @override
  void dispose() {
    _oddsChangeSubscription?.cancel();
    _storeUpdateSubscription?.cancel();
    _debounceTimer?.cancel();

    super.dispose();
  }

  void resetForNewPopup(BettingPopupData data) {
    _oddsChangeSubscription?.cancel();
    _storeUpdateSubscription?.cancel();
    _debounceTimer?.cancel();

    state = const BettingPopupState().copyWith(
      bettingData: data,
      betAmount: '0',
    );
  }

  Future<void> initializeAsync() async {
    subscribeRealtimeUpdates();

    await calculateBets();
  }

  Future<void> initialize(BettingPopupData data) async {
    resetForNewPopup(data);
    await initializeAsync();
  }

  void subscribeRealtimeUpdates() {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    final adapter = _ref.read(sportSocketAdapterProvider);
    final eventId = bettingData.eventData.eventId;
    final marketId = bettingData.marketData.marketId;

    _oddsChangeSubscription = adapter.onOddsChange.listen((update) {
      if (update.eventId != eventId || update.marketId != marketId) return;
      _handleSocketOddsChange(update);
    });

    _storeUpdateSubscription = adapter.onUpdate.listen((update) {
      final data = state.bettingData;
      if (data == null || state.isClosed) return;

      if (update.removedEventIds.contains(eventId)) {
        _closePopupWithMessage('Trận đấu đã kết thúc!');
        return;
      }

      if (update.updatedMarketKeys.contains('${eventId}_$marketId')) {
        final suspended = _ref
            .read(marketStatusProvider.notifier)
            .freshState
            .isMarketSuspended(eventId, marketId);
        if (suspended) {
          _closePopupWithMessage('Market không khả dụng!');
        }
      }
    });

    _seedFromStore(adapter);
  }

  void _seedFromStore(SportSocketAdapter adapter) {
    final bettingData = state.bettingData;
    if (bettingData == null || state.isClosed) return;

    final offerId = bettingData.getOfferId();
    if (offerId == null || offerId.isEmpty) return;

    final storeOdds = adapter.getOdds(
      bettingData.eventData.eventId,
      bettingData.marketData.marketId,
      offerId,
    );
    if (storeOdds == null) return;

    if (storeOdds.isSuspended) {
      _closePopupWithMessage('Kèo đã thay đổi!');
      return;
    }
    if (_pointsChanged(bettingData.oddsData.points, storeOdds.points)) {
      _closePopupWithMessage('Kèo đã thay đổi!');
      return;
    }

    final seeded = _styledOddsFromStore(
      storeOdds,
      bettingData.oddsType,
      bettingData.sendOddsStyle,
    );
    if (seeded != null) {
      state = state.copyWith(updatedOdds: seeded);
    }
  }

  double? _styledOddsFromStore(
    socket.OddsData odds,
    OddsType oddsType,
    OddsStyle style,
  ) {
    final (double? decimal, String? malay, String? indo, String? hk) =
        switch (oddsType) {
      OddsType.home => (
          odds.oddsHome,
          odds.malayHome,
          odds.indoHome,
          odds.hkHome,
        ),
      OddsType.away => (
          odds.oddsAway,
          odds.malayAway,
          odds.indoAway,
          odds.hkAway,
        ),
      OddsType.draw => (
          odds.oddsDraw,
          odds.malayDraw,
          odds.indoDraw,
          odds.hkDraw,
        ),
      _ => (null, null, null, null),
    };
    double? usable(double? v) =>
        (v == null || v == 0 || v == -100) ? null : v;
    return switch (style) {
      OddsStyle.decimal => usable(decimal),
      OddsStyle.malay => usable(double.tryParse(malay ?? '')),
      OddsStyle.indo => usable(double.tryParse(indo ?? '')),
      OddsStyle.hongKong => usable(double.tryParse(hk ?? '')),
    };
  }

  String? _rawSelectionId(BettingPopupData data) {
    return switch (data.oddsType) {
      OddsType.home => data.oddsData.selectionHomeId,
      OddsType.away => data.oddsData.selectionAwayId,
      OddsType.draw => data.oddsData.selectionDrawId,
      _ => null,
    };
  }

  bool _pointsChanged(String currentPoints, String? newPoints) {
    if (newPoints == null || newPoints.isEmpty || currentPoints.isEmpty) {
      return false;
    }
    final a = double.tryParse(currentPoints);
    final b = double.tryParse(newPoints);
    if (a != null && b != null) return a != b;
    return currentPoints != newPoints;
  }

  void _handleSocketOddsChange(socket.OddsChangeData update) {
    final bettingData = state.bettingData;
    if (bettingData == null || state.isClosed) return;

    final offerId = bettingData.getOfferId();

    if (offerId != null && offerId.isNotEmpty && update.offerId == offerId) {
      final adapter = _ref.read(sportSocketAdapterProvider);
      final storeOdds = adapter.getOdds(
        update.eventId,
        update.marketId,
        offerId,
      );
      if (storeOdds != null) {
        if (storeOdds.isSuspended) {
          _closePopupWithMessage('Kèo đã thay đổi!');
          return;
        }
        if (_pointsChanged(bettingData.oddsData.points, storeOdds.points)) {
          _closePopupWithMessage('Kèo đã thay đổi!');
          return;
        }
      }
    }

    final rawId = _rawSelectionId(bettingData);
    if (rawId == null || rawId.isEmpty || update.selectionId != rawId) return;
    if (offerId != null && offerId.isNotEmpty && update.offerId != offerId) {
      return;
    }

    final newOddsValue = _styledOddsFromStyleValues(
      update.styleValues,
      bettingData.sendOddsStyle,
    );
    if (newOddsValue != null) {
      state = state.copyWith(updatedOdds: newOddsValue);
    }
  }

  double? _styledOddsFromStyleValues(
    socket.OddsStyleValues? values,
    OddsStyle style,
  ) {
    if (values == null) return null;
    double? usable(double? v) =>
        (v == null || v == 0 || v == -100) ? null : v;
    return switch (style) {
      OddsStyle.decimal => usable(values.decimal),
      OddsStyle.malay => usable(double.tryParse(values.malay ?? '')),
      OddsStyle.indo => usable(double.tryParse(values.indo ?? '')),
      OddsStyle.hongKong => usable(double.tryParse(values.hk ?? '')),
    };
  }

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  void _closePopupWithMessage(String message) {
    state = state.copyWith(error: message, isClosed: true);
  }

  void updateBetAmount(String amount) {
    state = state.copyWith(betAmount: amount, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> calculateBets() async {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    state = state.copyWith(isCalculating: true, clearError: true);

    try {
      final Map<String, dynamic> response;
      if (bettingData.isSpecialOutright) {
        response = await _outrightRepository.calculateOutrightBet(
          leagueId: bettingData.getLeagueIdString(),
          displayOdds: bettingData
              .getSelectedOddsValueByStyle(OddsStyle.decimal)
              .toStringAsFixed(2),
          selectionId: bettingData.getSelectionId() ?? '',
        );
      } else {
        final requestBody = _buildCalculateBetsRequest(bettingData);
        response = await _httpManager.calculateBets(
          requestBody,
          sportId: bettingData.sportId,
        );
      }

      final errorCode = response['errorCode'] as int?;
      if (errorCode != null && errorCode != 0) {
        final isStaleOffer = bettingApiPlaceBetOfferStale(errorCode);
        if (bettingApiPlaceBetBasisChanged(errorCode)) {
          _ref.read(betDetailMobileV2Provider.notifier).refreshFullMarkets();
          _ref.read(eventsV2Provider.notifier).refreshOnStaleOffer(
                leagueId: bettingData.leagueData?.leagueId,
              );
        }
        state = state.copyWith(
          isCalculating: false,
          error: isStaleOffer
              ? bettingApiOddsChangedRetryMessage
              : bettingApiErrorDisplayMessage(
                  errorCode,
                  serverMessage: response['message'] as String?,
                  fallback: bettingApiCalculateBetFailureFallback,
                ),
          errorCode: errorCode,
        );
        return;
      }

      final minStake = _parseToInt(response['minStake']) ?? 0;
      final maxStake = _parseToInt(response['maxStake']) ?? 0;
      final maxPayout = _parseToInt(response['maxPayout']) ?? 0;
      final displayOdds = response['displayOdds'] as String?;

      double? updatedOdds;
      if (displayOdds != null) {
        updatedOdds = double.tryParse(displayOdds);
      }

      state = state.copyWith(
        isCalculating: false,
        minStake: minStake,
        maxStake: maxStake,
        maxPayout: maxPayout,
        updatedOdds: updatedOdds,
      );
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        error: logAndGenericError('calculateBets', e),
      );
    }
  }

  Map<String, dynamic> _buildCalculateBetsRequest(BettingPopupData data) {
    return {
      'leagueId': data.getLeagueIdString(),
      'matchTime': data.getMatchTimeISO(),
      'isLive': data.isLive,
      'offerId': data.getOfferId(),
      'selectionId': data.getSelectionId(),
      'displayOdds': data.getDisplayOdds(),
      'oddsStyle': _getOddsStyleCode(data.sendOddsStyle),
    };
  }

  String _getOddsStyleCode(OddsStyle style) =>
      BettingRestRules.oddsStyleApiCode(style);

  int _winningsForSend(int stake, double odds, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return (stake * odds).round();
      case OddsStyle.malay:
        if (odds < 0) return stake + (stake * odds.abs()).floor();
        return (stake * (1 + odds)).floor();
      case OddsStyle.indo:
        if (odds < -1) return stake + (stake * odds.abs()).floor();
        if (odds < 0) return stake;
        return (stake * (1 + odds)).floor();
      case OddsStyle.hongKong:
        return (stake * (1 + odds)).floor();
    }
  }

  static const int clientValidationErrorCode = -1;

  void _setValidationError(String message) {
    state = state
        .copyWith(clearError: true)
        .copyWith(error: message, errorCode: clientValidationErrorCode);
  }

  Future<bool> placeBet() async {
    final bettingData = state.bettingData;
    if (bettingData == null) return false;

    final enteredStake = MoneyFormatter.floorToThousand(
      int.tryParse(state.betAmount.replaceAll(',', '')) ?? 0,
    );

    final minStakeAmount = state.minStake * 1000;
    final maxStakeAmount = state.maxStake * 1000;

    if (enteredStake <= 0 || enteredStake < minStakeAmount) {
      _setValidationError(
        'Số tiền cược tối thiểu: '
        '${MoneyFormatter.formatCompact(minStakeAmount > 0 ? minStakeAmount : 1000)}',
      );
      return false;
    }

    if (maxStakeAmount > 0 && enteredStake > maxStakeAmount) {
      _setValidationError(
        'Số tiền cược tối đa: ${MoneyFormatter.formatCompact(maxStakeAmount)}',
      );
      return false;
    }

    final effectiveOddsStyleEnum = bettingData.sendOddsStyle;
    final isDecimalSend = effectiveOddsStyleEnum == OddsStyle.decimal;
    final effectiveOddsValue =
        state.updatedOdds ??
        bettingData.getSelectedOddsValueByStyle(effectiveOddsStyleEnum);
    final sendOddsValue = double.parse(effectiveOddsValue.toStringAsFixed(2));
    final effectiveWinnings = isDecimalSend
        ? (enteredStake * sendOddsValue).round()
        : _winningsForSend(
            enteredStake,
            sendOddsValue,
            effectiveOddsStyleEnum,
          );

    state = state.copyWith(isPlacingBet: true, clearError: true);

    try {
      final PlaceBetResponse response;

      if (bettingData.isSpecialOutright) {
        final outrightOdds =
            state.updatedOdds ??
            bettingData.getSelectedOddsValueByStyle(OddsStyle.decimal);
        final outrightWinnings = (enteredStake * outrightOdds).round();

        response = await _outrightRepository.placeOutrightBet(
          cls: _getCls(bettingData),
          displayOdds: outrightOdds,
          selectionId: bettingData.getSelectionId() ?? '',
          selectionName: bettingData.getSelectionName(),
          stake: enteredStake,
          winnings: outrightWinnings,
        );
      } else {
        final eventName =
            '${bettingData.getHomeName()} vs ${bettingData.getAwayName()}';

        final betMarketId = bettingData.marketData.marketId;
        final int betHomeScore;
        final int betAwayScore;
        if (MarketHelper.isCornerMarket(betMarketId)) {
          betHomeScore = bettingData.eventData.cornersHome;
          betAwayScore = bettingData.eventData.cornersAway;
        } else if (MarketHelper.isExtraTime(betMarketId)) {
          betHomeScore = bettingData.eventData.homeScoreOT;
          betAwayScore = bettingData.eventData.awayScoreOT;
        } else {
          betHomeScore = bettingData.eventData.homeScore;
          betAwayScore = bettingData.eventData.awayScore;
        }

        final selection = BetSelectionModel(
          eventId: bettingData.eventData.eventId,
          eventName: eventName,
          selectionId: bettingData.getSelectionId() ?? '',
          selectionName: bettingData.getSelectionName(),
          offerId: bettingData.getOfferId() ?? '',
          displayOdds: sendOddsValue.toStringAsFixed(2),
          oddsStyle: _getOddsStyleCode(effectiveOddsStyleEnum),
          cls: _getCls(bettingData),
          leagueId: bettingData.getLeagueIdString(),
          matchTime: bettingData.getMatchTimeISO(),
          isLive: bettingData.isLive,
          sportId: bettingData.sportId,
          homeScore: betHomeScore,
          awayScore: betAwayScore,
          stake: enteredStake.toDouble(),
          winnings: effectiveWinnings.toDouble(),
        );

        final request = PlaceBetRequest(
          matchId: bettingData.eventData.eventId,
          selections: [selection],
          singleBet: true,
        );

        response = await _repository.placeBet(request);
      }

      if (response.isSuccess) {
        state = state.copyWith(isPlacingBet: false, isClosed: true);
        _ref.read(myBetRepositoryProvider).notifyBetPlaced();
        return true;
      } else {
        final isStaleOffer = bettingApiPlaceBetOfferStale(response.errorCode);
        state = state.copyWith(
          isPlacingBet: false,
          error: isStaleOffer
              ? bettingApiOddsChangedRetryMessage
              : bettingApiErrorDisplayMessage(
                  response.errorCode,
                  serverMessage: response.message,
                  fallback: bettingApiPlaceBetFailureFallback,
                ),
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isPlacingBet: false,
        error: bettingApiErrorDisplayMessage(
          null,
          fallback: bettingApiPlaceBetFailureFallback,
        ),
      );
      return false;
    }
  }

  String _getCls(BettingPopupData data) {
    if (data.marketData.marketId == 0) {
      final selectionCode = data.oddsData.points;
      return selectionCode.isNotEmpty ? selectionCode : '';
    }

    final points = data.oddsData.points;
    final marketId = data.marketData.marketId;

    if (MarketHelper.isCorrectScore(marketId) || double.tryParse(points) == null) {
      return points;
    }

    if (MarketLayoutHelper.isHalfTimeFullTime(marketId) ||
        MarketLayoutHelper.isCombo(marketId)) {
      return points;
    }

    if (marketId == 147 || marketId == 1003) {
      return '${data.eventData.homeScore}:${data.eventData.awayScore}';
    }

    final oddsType = data.oddsType;
    final pointsNumber = double.tryParse(points) ?? 0;
    final pointsAbs = pointsNumber.abs();

    double clsValue = pointsAbs;

    if (MarketHelper.isHandicap(marketId)) {
      if (pointsNumber > 0) {
        if (oddsType == OddsType.away) {
          clsValue = -pointsAbs;
        }
      } else {
        if (oddsType == OddsType.home) {
          clsValue = -pointsAbs;
        }
      }
    }

    String clsStr = clsValue.toString();
    if (clsValue == clsValue.floor()) {
      clsStr = '${clsValue.toInt()}.0';
    }

    return clsStr;
  }

  static bool isMoneyRelatedError(int? errorCode) {
    return bettingApiErrorIsMoneyRelated(errorCode);
  }
}

final bettingPopupProvider =
    StateNotifierProvider<BettingPopupNotifier, BettingPopupState>((ref) {
      return BettingPopupNotifier(ref);
    });

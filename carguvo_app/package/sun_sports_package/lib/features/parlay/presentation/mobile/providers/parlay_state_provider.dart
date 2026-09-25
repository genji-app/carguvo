import 'dart:async';

import 'package:betting_domain/betting_domain.dart'
    show
        BettingRestRules,
        kMaxComboMatches,
        kMaxSingleBets,
        kMinComboMatches;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/datasources/event_detail_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/betting/data/repositories/betting_repository.dart';
import 'package:sun_sports/features/parlay/data/storage/parlay_storage.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/services/websocket/betslip_subscription_manager.dart';
import 'package:sun_sports/core/services/websocket/subscription_manager.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/features/parlay/domain/utils/missing_offer_tracker.dart';
import 'package:sun_sports/features/parlay/domain/utils/stake_limits_cache.dart';

enum ParlayTab { single, combo, multi }

class ParlayState {
  final ParlayTab tab;
  final int stake;
  final double price;
  final double totalOdds;
  final int minStake;
  final int maxStake;
  final int comboCount;
  final List<ParlayMultiBet> multiBets;

  final List<SingleBetData> singleBets;

  final List<SingleBetData> comboBets;

  final int minMatches;
  final int maxMatches;

  final bool isCalculatingCombo;

  final bool isPlacingBet;

  final PlaceBetResponse? lastPlaceBetResult;

  final String? error;

  final int changedOddsCount;

  final bool showOddsChangedNotification;

  const ParlayState({
    this.tab = ParlayTab.single,
    this.stake = 0,
    this.price = 0.95,
    this.totalOdds = 1.0,
    this.minStake = 0,
    this.maxStake = 0,
    this.comboCount = 5,
    this.multiBets = ParlayMultiBet.defaultBets,
    this.singleBets = const [],
    this.comboBets = const [],
    this.minMatches = kMinComboMatches,
    this.maxMatches = kMaxComboMatches,
    this.isCalculatingCombo = false,
    this.isPlacingBet = false,
    this.lastPlaceBetResult,
    this.error,
    this.changedOddsCount = 0,
    this.showOddsChangedNotification = false,
  });

  double get totalBet {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => bet.isDisabled ? sum : sum + bet.stake.toDouble(),
        );
      case ParlayTab.multi:
        return multiBets.fold<double>(
          0,
          (sum, bet) => sum + bet.stake.toDouble(),
        );
      case ParlayTab.combo:
        return stake.toDouble();
    }
  }

  double get validTotalBet {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => bet.canPlaceBet ? sum + bet.totalCost : sum,
        );
      case ParlayTab.multi:
        return totalBet;
      case ParlayTab.combo:
        return isComboValid ? totalBet : 0;
    }
  }

  int get validTicketCount {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.where((bet) => bet.canPlaceBet).length;
      case ParlayTab.multi:
        return multiBets.where((bet) => bet.stake > 0).length;
      case ParlayTab.combo:
        return validTotalBet > 0 ? 1 : 0;
    }
  }

  double get validPotentialWin {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => bet.canPlaceBet ? sum + bet.potentialWinnings : sum,
        );
      case ParlayTab.multi:
        return potentialWin;
      case ParlayTab.combo:
        return isComboValid ? potentialWin : 0;
    }
  }

  double get potentialWin {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => sum + bet.potentialWinnings,
        );
      case ParlayTab.multi:
        return multiBets.fold<double>(
          0,
          (sum, bet) => sum + (bet.stake * bet.odd),
        );
      case ParlayTab.combo:
        return stake * totalOdds;
    }
  }

  bool get canPlaceBet {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.any((bet) => bet.canPlaceBet);
      case ParlayTab.multi:
        return multiBets.any((bet) => bet.stake > 0);
      case ParlayTab.combo:
        return isComboValid &&
            validComboBetsCount <= maxMatches &&
            stake > 0 &&
            stake >= minStake &&
            stake <= maxStake &&
            !isCalculatingCombo;
    }
  }

  int get validComboBetsCount =>
      comboBets.where((bet) => !bet.isDisabled).length;

  bool get hasEnoughMatches => validComboBetsCount >= minMatches;

  int get comboBetsCount => comboBets.length;

  Map<int, int> get activeComboLegCountByEvent {
    final map = <int, int>{};
    for (final bet in comboBets) {
      if (bet.isDisabled) continue;
      map.update(
        bet.eventData.eventId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return map;
  }

  int get activeComboEventCount => activeComboLegCountByEvent.length;

  bool get comboHasMultiActiveLegEvent =>
      activeComboLegCountByEvent.values.any((count) => count > 1);

  int get validComboMatchCount =>
      activeComboLegCountByEvent.values.where((count) => count == 1).length;

  bool get comboHasUnsupportedSoleLegEvent {
    final activeLegsByEvent = <int, List<SingleBetData>>{};
    for (final bet in comboBets) {
      if (bet.isDisabled) continue;
      activeLegsByEvent
          .putIfAbsent(bet.eventData.eventId, () => [])
          .add(bet);
    }
    return activeLegsByEvent.values.any(
      (legs) => legs.length == 1 && !legs.first.marketData.isParlay,
    );
  }

  bool get isComboValid =>
      activeComboEventCount >= minMatches &&
      !comboHasMultiActiveLegEvent &&
      !comboHasUnsupportedSoleLegEvent;

  bool isBetInCombo(int eventId) => comboBets.any(
    (bet) => !bet.isDisabled && bet.eventData.eventId == eventId,
  );

  bool isSelectionInCombo(String? selectionId) {
    if (selectionId == null) return false;
    return comboBets.any(
      (bet) => !bet.isDisabled && bet.selectionId == selectionId,
    );
  }

  bool hasOtherSelectionInCombo(int eventId, String? selectionId) {
    return comboBets.any(
      (bet) =>
          !bet.isDisabled &&
          bet.eventData.eventId == eventId &&
          bet.selectionId != selectionId,
    );
  }

  int get currentMinStake {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.isNotEmpty
            ? singleBets.first.minStakeActual
            : minStake;
      default:
        return minStake;
    }
  }

  int get currentMaxStake {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.isNotEmpty
            ? singleBets.first.maxStakeActual
            : maxStake;
      default:
        return maxStake;
    }
  }

  bool get hasSingleBets => singleBets.isNotEmpty;

  int get singleBetsCount => singleBets.length;

  ParlayState copyWith({
    ParlayTab? tab,
    int? stake,
    double? price,
    double? totalOdds,
    int? minStake,
    int? maxStake,
    int? comboCount,
    List<ParlayMultiBet>? multiBets,
    List<SingleBetData>? singleBets,
    List<SingleBetData>? comboBets,
    int? minMatches,
    int? maxMatches,
    bool? isCalculatingCombo,
    bool? isPlacingBet,
    PlaceBetResponse? lastPlaceBetResult,
    String? error,
    bool clearError = false,
    int? changedOddsCount,
    bool? showOddsChangedNotification,
  }) => ParlayState(
    tab: tab ?? this.tab,
    stake: stake ?? this.stake,
    price: price ?? this.price,
    totalOdds: totalOdds ?? this.totalOdds,
    minStake: minStake ?? this.minStake,
    maxStake: maxStake ?? this.maxStake,
    comboCount: comboCount ?? this.comboCount,
    multiBets: multiBets ?? this.multiBets,
    singleBets: singleBets ?? this.singleBets,
    comboBets: comboBets ?? this.comboBets,
    minMatches: minMatches ?? this.minMatches,
    maxMatches: maxMatches ?? this.maxMatches,
    isCalculatingCombo: isCalculatingCombo ?? this.isCalculatingCombo,
    isPlacingBet: isPlacingBet ?? this.isPlacingBet,
    lastPlaceBetResult: lastPlaceBetResult ?? this.lastPlaceBetResult,
    error: clearError ? null : error,
    changedOddsCount: changedOddsCount ?? this.changedOddsCount,
    showOddsChangedNotification:
        showOddsChangedNotification ?? this.showOddsChangedNotification,
  );
}

class ParlayStateNotifier extends StateNotifier<ParlayState> {
  final BettingRepository _repository;
  final Ref _ref;
  final ParlayStorage _storage = ParlayStorage.instance;
  final AppLogger _logger = AppLogger(tag: 'Parlay');

  StreamSubscription<socket.OddsUpdateData>? _oddsSubscription;
  StreamSubscription<socket.ScoreUpdateData>? _scoreSubscription;

  StreamSubscription<socket.EventStatusData>? _eventStatusSubscription;

  StreamSubscription<socket.DataChangeEvent>? _storeChangeSubscription;

  static const int maxSingleBets = kMaxSingleBets;

  Timer? _oddsChangedDebounceTimer;

  final MissingOfferTracker _missingOfferTracker = MissingOfferTracker();
  Timer? _missingOfferRecheckTimer;

  final Set<String> _pendingChangedBetIds = {};

  DateTime? _lastReconcileAt;
  static const Duration _reconcileThrottle = Duration(seconds: 15);

  ParlayStateNotifier(this._repository, this._ref)
    : super(const ParlayState()) {
    _subscribeToLibrary();
    _loadFromStorage();
    _ref.listen<OddsStyle>(oddsStyleProvider, (prev, next) {
      if (prev == next) return;
      _applyGlobalOddsStyle(next);
    });
  }

  @override
  void dispose() {
    _oddsSubscription?.cancel();
    _scoreSubscription?.cancel();
    _eventStatusSubscription?.cancel();
    _storeChangeSubscription?.cancel();
    _oddsChangedDebounceTimer?.cancel();
    _missingOfferRecheckTimer?.cancel();
    super.dispose();
  }

  Set<int> _extractBetSlipSportIds() {
    final sportIds = <int>{};
    for (final bet in state.singleBets) {
      sportIds.add(bet.sportId);
    }
    for (final bet in state.comboBets) {
      sportIds.add(bet.sportId);
    }
    return sportIds;
  }

  void _notifySubscriptionManager() {
    final sportIds = _extractBetSlipSportIds();
    SubscriptionManager.instance?.syncBetSlipSports(sportIds);
  }

  Future<void> _loadFromStorage() async {
    try {
      final savedBets = await _storage.loadSingleBets();
      if (savedBets.isNotEmpty) {
        final betsWithCalculating = savedBets
            .map((bet) => bet.copyWith(isCalculating: true))
            .toList();
        state = state.copyWith(singleBets: betsWithCalculating);
        debugPrint(
          '[ParlayState] Loaded ${savedBets.length} single bets from storage (waiting for betting ready)',
        );
      }

      final savedComboBets = await _storage.loadComboBets();
      if (savedComboBets.isNotEmpty) {
        final combineOdds = _calculateCombineOdds(savedComboBets);
        state = state.copyWith(
          comboBets: savedComboBets,
          totalOdds: combineOdds,
          isCalculatingCombo: true,
        );
        debugPrint(
          '[ParlayState] Loaded ${savedComboBets.length} combo bets from storage (waiting for betting ready)',
        );
      }

      _notifySubscriptionManager();

      final eventIds = <int>[];
      for (final bet in savedBets) {
        eventIds.add(bet.eventData.eventId);
      }
      for (final bet in savedComboBets) {
        eventIds.add(bet.eventData.eventId);
      }
      if (eventIds.isNotEmpty) {
        BetslipSubscriptionManager.instance?.restoreSubscriptions(eventIds);
        debugPrint(
          '[ParlayState] Restored ${eventIds.length} event subscriptions',
        );
      }
    } catch (e) {
      debugPrint('[ParlayState] Error loading from storage: $e');
    }
  }

  void _applyGlobalOddsStyle(OddsStyle style) {
    if (state.singleBets.isEmpty) return;
    final updated = state.singleBets
        .map((b) => b.copyWith(oddsStyle: style, isCalculating: true))
        .toList();
    state = state.copyWith(singleBets: updated);
    for (int i = 0; i < state.singleBets.length; i++) {
      calculateSingleBetAt(i);
    }
  }

  Future<void> recalculateAllBets() async {
    debugPrint('[ParlayState] recalculateAllBets called - betting is ready');

    final globalStyle = _ref.read(oddsStyleProvider);
    if (state.singleBets.any((b) => b.oddsStyle != globalStyle)) {
      state = state.copyWith(
        singleBets: state.singleBets
            .map((b) => b.copyWith(oddsStyle: globalStyle))
            .toList(),
      );
    }

    for (int i = 0; i < state.singleBets.length; i++) {
      calculateSingleBetAt(i);
    }

    for (int i = 0; i < state.comboBets.length; i++) {
      calculateComboBetAt(i);
    }

    if (state.tab == ParlayTab.combo) {
      if (state.hasEnoughMatches) {
        calculateComboParlay();
      } else if (state.comboBets.isNotEmpty) {
        state = state.copyWith(isCalculatingCombo: false);
      }
    } else {
      if (state.isCalculatingCombo) {
        state = state.copyWith(isCalculatingCombo: false);
      }
    }

    unawaited(reconcileBetslipEvents());
  }

  Future<void> reconcileBetslipEvents({bool force = false}) async {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    final now = DateTime.now();
    if (!force &&
        _lastReconcileAt != null &&
        now.difference(_lastReconcileAt!) < _reconcileThrottle) {
      return;
    }
    _lastReconcileAt = now;

    final adapter = _ref.read(sportSocketAdapterProvider);
    final nowMs = now.millisecondsSinceEpoch;

    final eventIds = <int>{};
    for (final bet in [...state.singleBets, ...state.comboBets]) {
      if (bet.isDisabled) continue;
      final ev = bet.eventData;
      if (ev.eventId == 0) continue;
      if (!force) {
        if (nowMs <= ev.startTime) continue;
        if (adapter.getEventData(ev.eventId) != null) continue;
      }
      eventIds.add(ev.eventId);
    }
    if (eventIds.isEmpty) return;

    _logger.d(
      '[ParlayState] Reconciling ${eventIds.length} betslip event(s): $eventIds',
    );

    final dataSource = _ref.read(eventDetailV2RemoteDataSourceProvider);
    await Future.wait(
      eventIds.map((eventId) async {
        try {
          final response = await dataSource.getEventDetail(eventId);
          _applyEventReconcile(eventId, response);
        } catch (e) {
          _logger.d('[ParlayState] Reconcile event $eventId failed: $e');
        }
      }),
    );
  }

  void _applyEventReconcile(int eventId, EventDetailResponseV2 response) {
    if (response.eventId == 0 || response.isHidden) {
      _disableBetsWhere(
        (bet) => bet.eventData.eventId == eventId,
        reason:
            'reconcile event $eventId gone/hidden '
            '(respEventId=${response.eventId}, hidden=${response.isHidden})',
      );
      return;
    }

    final score = ScoreModelV2.fromJson(response.scoreRaw);
    final parsedHome = int.tryParse(score?.homeScore ?? '');
    final parsedAway = int.tryParse(score?.awayScore ?? '');

    LeagueEventData merge(LeagueEventData ev) => ev.copyWith(
      homeScore: parsedHome ?? ev.homeScore,
      awayScore: parsedAway ?? ev.awayScore,
      isLive: response.isLive,
      isSuspended: response.isSuspended,
      gamePart: response.gamePart,
      gameTime: response.gameTime,
      stoppageTime: response.stoppageTime,
    );

    SingleBetData apply(SingleBetData bet) => bet.eventData.eventId == eventId
        ? bet.copyWith(eventData: merge(bet.eventData))
        : bet;

    state = state.copyWith(
      singleBets: state.singleBets.map(apply).toList(),
      comboBets: state.comboBets.map(apply).toList(),
    );
  }

  void syncScoresFromCache(Map<int, ({int home, int away})> scoresMap) {
    if (scoresMap.isEmpty) return;

    var hasChanges = false;

    final updatedSingleBets = state.singleBets.map((bet) {
      final eventId = bet.eventData.eventId;
      final cachedScore = scoresMap[eventId];
      if (cachedScore != null) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;
        if (currentHome != cachedScore.home ||
            currentAway != cachedScore.away) {
          debugPrint(
            '[ParlayState] Syncing score for event $eventId: $currentHome-$currentAway -> ${cachedScore.home}-${cachedScore.away}',
          );
          hasChanges = true;
          final updatedEventData = bet.eventData.copyWith(
            homeScore: cachedScore.home,
            awayScore: cachedScore.away,
          );
          return bet.copyWith(eventData: updatedEventData);
        }
      }
      return bet;
    }).toList();

    final updatedComboBets = state.comboBets.map((bet) {
      final eventId = bet.eventData.eventId;
      final cachedScore = scoresMap[eventId];
      if (cachedScore != null) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;
        if (currentHome != cachedScore.home ||
            currentAway != cachedScore.away) {
          debugPrint(
            '[ParlayState] Syncing combo score for event $eventId: $currentHome-$currentAway -> ${cachedScore.home}-${cachedScore.away}',
          );
          hasChanges = true;
          final updatedEventData = bet.eventData.copyWith(
            homeScore: cachedScore.home,
            awayScore: cachedScore.away,
          );
          return bet.copyWith(eventData: updatedEventData);
        }
      }
      return bet;
    }).toList();

    if (hasChanges) {
      state = state.copyWith(
        singleBets: updatedSingleBets,
        comboBets: updatedComboBets,
      );
    }
  }

  Future<void> _saveToStorage([List<SingleBetData>? bets]) async {
    try {
      await _storage.saveSingleBets(bets ?? state.singleBets);
    } catch (e) {
      debugPrint('[ParlayState] Error saving to storage: $e');
    }
  }

  Future<void> _saveComboToStorage([List<SingleBetData>? bets]) async {
    try {
      await _storage.saveComboBets(bets ?? state.comboBets);
    } catch (e) {
      debugPrint('[ParlayState] Error saving combo bets to storage: $e');
    }
  }

  Future<void> saveAllToStorage() async {
    debugPrint('[ParlayState] saveAllToStorage called');
    await Future.wait([_saveToStorage(), _saveComboToStorage()]);
  }

  void resetPlacingState() {
    if (!state.isPlacingBet) return;
    state = state.copyWith(isPlacingBet: false, clearError: true);
  }

  void _subscribeToLibrary() {
    final adapter = _ref.read(sportSocketAdapterProvider);

    _oddsSubscription = adapter.onOddsUpdate.listen(
      _handleOddsUpdateFromLibrary,
    );

    _scoreSubscription = adapter.onScoreUpdate.listen(
      _handleScoreUpdateFromLibrary,
    );

    _eventStatusSubscription = adapter.onEventStatusUpdate.listen(
      _handleEventStatusUpdate,
    );

    _storeChangeSubscription = adapter.onStoreChanged.listen(
      _handleStoreChanged,
    );
  }

  bool _isDisablingStatus(String? status) {
    final s = status?.toUpperCase();
    return s == 'FINISHED' || s == 'AUTOHIDDEN' || s == 'HIDDEN';
  }

  void _handleEventStatusUpdate(socket.EventStatusData data) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;
    if (!_isDisablingStatus(data.status)) return;

    _disableBetsWhere(
      (bet) => bet.eventData.eventId == data.eventId,
      reason: 'event ${data.eventId} status=${data.status}',
    );
  }

  void _handleStoreChanged(socket.DataChangeEvent event) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    final removed = event.removedEventIds.toSet();
    final updated = event.updatedEventIds;
    if (removed.isEmpty && updated.isEmpty) return;

    final adapter = _ref.read(sportSocketAdapterProvider);

    _disableBetsWhere(
      (bet) {
        final eventId = bet.eventData.eventId;

        if (removed.contains(eventId)) return true;

        if (updated.contains(eventId)) {
          return _isBetOfferMissingStably(bet, adapter);
        }

        return false;
      },
      reason: 'store change (removed=$removed, updated=$updated)',
    );

    _scheduleMissingOfferRecheck();
  }

  bool _isBetOfferMissingStably(SingleBetData bet, SportSocketAdapter adapter) {
    final eventId = bet.eventData.eventId;
    if (adapter.getEventData(eventId) == null) return false;
    final offerId = bet.offerId;
    if (offerId == null || offerId.isEmpty) return false;
    final odds = adapter.getOdds(eventId, bet.marketData.marketId, offerId);
    return _missingOfferTracker.shouldDisable(
      '${eventId}_${bet.marketData.marketId}_$offerId',
      isMissing: odds == null,
    );
  }

  void _scheduleMissingOfferRecheck() {
    _missingOfferRecheckTimer?.cancel();
    _missingOfferRecheckTimer = null;
    final delay = _missingOfferTracker.nextDeadlineIn();
    if (delay == null) return;
    _missingOfferRecheckTimer =
        Timer(delay + const Duration(milliseconds: 200), () {
      if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;
      final adapter = _ref.read(sportSocketAdapterProvider);
      _disableBetsWhere(
        (bet) => _isBetOfferMissingStably(bet, adapter),
        reason: 'missing-offer grace expired',
      );
      _scheduleMissingOfferRecheck();
    });
  }

  void _disableBetsWhere(
    bool Function(SingleBetData bet) test, {
    required String reason,
  }) {
    var changed = false;

    final updatedSingle = state.singleBets.map((bet) {
      if (!bet.isDisabled && test(bet)) {
        changed = true;
        return bet.copyWith(isDisabled: true, stake: 0);
      }
      return bet;
    }).toList();

    final updatedCombo = state.comboBets.map((bet) {
      if (!bet.isDisabled && test(bet)) {
        changed = true;
        return bet.copyWith(isDisabled: true);
      }
      return bet;
    }).toList();

    if (!changed) return;

    final combineOdds = _calculateCombineOdds(updatedCombo);
    state = state.copyWith(
      singleBets: updatedSingle,
      comboBets: updatedCombo,
      totalOdds: combineOdds,
    );

    _saveToStorage(updatedSingle);
    _saveComboToStorage(updatedCombo);

    _logger.d('[ParlayState] Disabled bets ($reason)');

    if (state.tab == ParlayTab.combo && state.hasEnoughMatches) {
      calculateComboParlay();
    }
  }

  void _handleScoreUpdateFromLibrary(socket.ScoreUpdateData data) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    _updateSingleBetsScore(data.eventId, data.homeScore, data.awayScore);

    _updateComboBetsScore(data.eventId, data.homeScore, data.awayScore);
  }

  void _updateSingleBetsScore(int eventId, int homeScore, int awayScore) {
    if (state.singleBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    var hasChanges = false;

    for (final bet in state.singleBets) {
      if (bet.eventData.eventId == eventId) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;

        if (currentHome != homeScore || currentAway != awayScore) {
          debugPrint(
            '[ParlayState] Updating single bet score for event $eventId: $currentHome-$currentAway -> $homeScore-$awayScore',
          );
          final updatedEventData = bet.eventData.copyWith(
            homeScore: homeScore,
            awayScore: awayScore,
          );
          updatedBets.add(bet.copyWith(eventData: updatedEventData));
          hasChanges = true;
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (hasChanges) {
      state = state.copyWith(singleBets: updatedBets);
    }
  }

  void _updateComboBetsScore(int eventId, int homeScore, int awayScore) {
    if (state.comboBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    var hasChanges = false;

    for (final bet in state.comboBets) {
      if (bet.eventData.eventId == eventId) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;

        if (currentHome != homeScore || currentAway != awayScore) {
          debugPrint(
            '[ParlayState] Updating combo bet score for event $eventId: $currentHome-$currentAway -> $homeScore-$awayScore',
          );
          final updatedEventData = bet.eventData.copyWith(
            homeScore: homeScore,
            awayScore: awayScore,
          );
          updatedBets.add(bet.copyWith(eventData: updatedEventData));
          hasChanges = true;
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (hasChanges) {
      state = state.copyWith(comboBets: updatedBets);
    }
  }

  void _handleOddsUpdateFromLibrary(socket.OddsUpdateData update) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    final eventId = update.eventId;
    final marketId = update.marketId;
    final offerId = update.offerId;
    final odds = update.odds;

    _updateSingleBetsOddsFromLibrary(eventId, marketId, offerId, odds);

    _updateComboBetsOddsFromLibrary(eventId, marketId, offerId, odds);
  }

  bool _matchesBySelection(SingleBetData bet, socket.OddsData odds) {
    final selectionId = bet.selectionId;
    if (selectionId == null) return false;

    return selectionId == odds.selectionIdHome ||
        selectionId == odds.selectionIdAway ||
        selectionId == odds.selectionIdDraw;
  }

  void _updateComboBetsOddsFromLibrary(
    int eventId,
    int marketId,
    String offerId,
    socket.OddsData odds,
  ) {
    if (state.comboBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    final changedSelectionIds = <String>[];

    for (final bet in state.comboBets) {
      if (bet.isDisabled) {
        updatedBets.add(bet);
        continue;
      }

      final matchesOffer = bet.offerId != null
          ? bet.offerId == offerId
          : _matchesBySelection(bet, odds);

      if (bet.eventData.eventId == eventId &&
          bet.marketData.marketId == marketId &&
          matchesOffer) {
        final newOddsValue = _getOddsValueFromLibrary(
          odds,
          bet.oddsType,
          bet.sendOddsStyle,
        );

        if (newOddsValue != null && newOddsValue != bet.displayOdds) {
          debugPrint(
            '[ParlayState] Updating combo bet odds: ${bet.selectionName} from ${bet.displayOdds} to $newOddsValue (style: ${bet.oddsStyle})',
          );
          updatedBets.add(
            bet.copyWith(
              oddsData: _applyStoreOddsToBet(bet, odds),
              updatedOdds: newOddsValue,
            ),
          );
          if (bet.selectionId != null) {
            changedSelectionIds.add(bet.selectionId!);
          }
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (changedSelectionIds.isNotEmpty) {
      final combineOdds = _calculateCombineOdds(updatedBets);
      state = state.copyWith(comboBets: updatedBets, totalOdds: combineOdds);

      _onOddsChanged(changedSelectionIds);

      calculateComboParlay();
    }
  }

  void _updateSingleBetsOddsFromLibrary(
    int eventId,
    int marketId,
    String offerId,
    socket.OddsData odds,
  ) {
    final updatedBets = <SingleBetData>[];
    final changedIndices = <int>[];
    final changedSelectionIds = <String>[];

    for (int i = 0; i < state.singleBets.length; i++) {
      final bet = state.singleBets[i];

      if (bet.isDisabled) {
        updatedBets.add(bet);
        continue;
      }

      final matchesOffer = bet.offerId != null
          ? bet.offerId == offerId
          : _matchesBySelection(bet, odds);

      if (bet.eventData.eventId == eventId &&
          bet.marketData.marketId == marketId &&
          matchesOffer) {
        final newOddsValue = _getOddsValueFromLibrary(
          odds,
          bet.oddsType,
          bet.sendOddsStyle,
        );

        if (newOddsValue != null && newOddsValue != bet.displayOdds) {
          debugPrint(
            '[ParlayState] Updating odds for bet: ${bet.selectionName} from ${bet.displayOdds} to $newOddsValue (style: ${bet.oddsStyle})',
          );
          updatedBets.add(bet.copyWith(updatedOdds: newOddsValue));
          changedIndices.add(i);
          if (bet.selectionId != null) {
            changedSelectionIds.add(bet.selectionId!);
          }
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (changedIndices.isNotEmpty) {
      state = state.copyWith(singleBets: updatedBets);

      _onOddsChanged(changedSelectionIds);

      for (final index in changedIndices) {
        debugPrint(
          '[ParlayState] Recalculating stake limits for bet at index $index',
        );
        calculateSingleBetAt(index);
      }
    }
  }

  double? _getOddsValueFromLibrary(
    socket.OddsData odds,
    OddsType oddsType,
    OddsStyle oddsStyle,
  ) {
    double? decimal;
    String? malay;
    String? indo;
    String? hk;

    switch (oddsType) {
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
        malay = null;
        indo = null;
        hk = null;
        break;
      default:
        return null;
    }

    switch (oddsStyle) {
      case OddsStyle.malay:
        if (malay != null) return double.tryParse(malay);
        return decimal;
      case OddsStyle.indo:
        if (indo != null) return double.tryParse(indo);
        return decimal;
      case OddsStyle.hongKong:
        if (hk != null) return double.tryParse(hk);
        return decimal;
      case OddsStyle.decimal:
        return decimal;
    }
  }

  void selectTab(ParlayTab tab) {
    final previousTab = state.tab;
    state = state.copyWith(tab: tab);

    if (tab == ParlayTab.combo && previousTab != ParlayTab.combo) {
      final needsCalculation = state.minStake == 0 && state.maxStake == 0;

      if (state.hasEnoughMatches && needsCalculation) {
        debugPrint(
          '[ParlayState] Lazy loading calculateComboParlay on tab switch',
        );
        calculateComboParlay();
      }
    }
  }

  ParlayTab get _tabAfterAdd =>
      state.tab == ParlayTab.combo ? ParlayTab.combo : ParlayTab.single;

  final StakeLimitsCache _stakeLimitsCache = StakeLimitsCache();

  Future<AddBetResult> addSingleBetFromPopupData(
    BettingPopupData popupData,
  ) async {
    final selectedEvent = _ref.read(selectedEventV2Provider);
    final scoreV2 =
        (selectedEvent != null &&
            selectedEvent.eventId == popupData.eventData.eventId)
        ? selectedEvent.score
        : null;
    final newBet = SingleBetData.fromBettingPopupData(popupData).copyWith(
      scoreV2: scoreV2,
      oddsStyle: _ref.read(oddsStyleProvider),
    );

    final existingIndex = state.singleBets.indexWhere(
      (bet) =>
          bet.eventData.eventId == newBet.eventData.eventId &&
          bet.selectionId == newBet.selectionId,
    );

    if (existingIndex >= 0) {
      if (state.singleBets[existingIndex].isDisabled) {
        await removeSingleBetAt(existingIndex, cascade: false);
      } else {
        state = state.copyWith(tab: _tabAfterAdd);
        return const AddBetResult.success();
      }
    }

    if (state.singleBets.length >= maxSingleBets) {
      return const AddBetResult.failure(
        errorMessage: 'Phiếu cược chỉ cho phép tối đa $maxSingleBets kèo',
      );
    }

    final syncedBet = _syncBetToLiveOdds(newBet);
    if (syncedBet.isDisabled) {
      return const AddBetResult.failure(
        errorMessage: 'Kèo đã tạm khóa, vui lòng thử lại',
      );
    }

    final cachedLimits = _stakeLimitsCache.lookup(
      syncedBet.offerId ?? '',
      syncedBet.selectionId ?? '',
      syncedBet.displayOddsString,
    );
    if (cachedLimits != null) {
      final betWithLimits = syncedBet.copyWith(
        minStake: cachedLimits.minStake,
        maxStake: cachedLimits.maxStake,
        maxPayout: cachedLimits.maxPayout,
        isCalculating: false,
      );
      state = state.copyWith(
        singleBets: [...state.singleBets, betWithLimits],
        tab: _tabAfterAdd,
        clearError: true,
      );
      _saveToStorage();
      _notifySubscriptionManager();
      BetslipSubscriptionManager.instance?.onBetAdded(
        popupData.eventData.eventId,
      );
      _autoAddToCombo(betWithLimits);
      debugPrint('[ParlayState] addSingleBet: cache-hit stake limits');
      return const AddBetResult.success();
    }

    try {
      final request = CalculateBetRequest(
        leagueId: syncedBet.leagueIdString,
        matchTime: syncedBet.matchTimeISO,
        isLive: syncedBet.isLive,
        offerId: syncedBet.offerId ?? '',
        selectionId: syncedBet.selectionId ?? '',
        displayOdds: syncedBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(syncedBet.sendOddsStyle),
      );

      debugPrint(
        '[ParlayState] addSingleBetFromPopupData: Calling calculateBet API...',
      );
      final response = await _repository.calculateBet(request, sportId: syncedBet.sportId);
      debugPrint(
        '[ParlayState] calculateBet response: errorCode=${response.errorCode}',
      );

      if (response.errorCode != 0) {
        if (bettingApiPlaceBetBasisChanged(response.errorCode)) {
          _stakeLimitsCache.clearOnStaleOffer();
          _ref.read(betDetailMobileV2Provider.notifier).refreshFullMarkets();
          final healBus = _ref.read(staleOfferHealBusProvider.notifier);
          healBus.state = (
            seq: healBus.state.seq + 1,
            leagueId: syncedBet.leagueData?.leagueId,
          );
        }
        final errorMessage = bettingApiErrorDisplayMessage(
          response.errorCode,
          serverMessage: response.message,
          fallback: bettingApiCalculateBetFailureFallback,
        );
        debugPrint('[ParlayState] calculateBet ERROR: $errorMessage');
        return AddBetResult.failure(
          errorMessage: errorMessage,
          errorCode: response.errorCode,
        );
      }

      _stakeLimitsCache.store(
        syncedBet.offerId ?? '',
        syncedBet.selectionId ?? '',
        syncedBet.displayOddsString,
        minStake: response.minStake,
        maxStake: response.maxStake,
        maxPayout: response.maxPayout,
      );

      final betWithLimits = syncedBet.copyWith(
        minStake: response.minStake,
        maxStake: response.maxStake,
        maxPayout: response.maxPayout,
        isCalculating: false,
      );

      state = state.copyWith(
        singleBets: [...state.singleBets, betWithLimits],
        tab: _tabAfterAdd,
        clearError: true,
      );

      _saveToStorage();

      _notifySubscriptionManager();

      BetslipSubscriptionManager.instance?.onBetAdded(
        popupData.eventData.eventId,
      );

      _autoAddToCombo(betWithLimits);

      debugPrint(
        '[ParlayState] addSingleBetFromPopupData: SUCCESS - bet added',
      );
      return const AddBetResult.success();
    } catch (e, stackTrace) {
      _logger.e(
        'addSingleBetFromPopupData failed',
        error: e,
        stackTrace: stackTrace,
      );
      return const AddBetResult.failure(
        errorMessage: 'Không thể thêm cược. Vui lòng thử lại!',
      );
    }
  }

  Future<AddBetResult> setSingleBetFromPopupData(BettingPopupData popupData) {
    return addSingleBetFromPopupData(popupData);
  }

  Future<AddBetResult> addSingleBetFromPopupDataV2(
    BettingPopupDataV2 popupDataV2,
  ) async {
    final legacyData = BettingPopupData(
      sportId: popupDataV2.sportId,
      oddsData: popupDataV2.oddsData.toLegacy(),
      marketData: popupDataV2.marketData.toLegacy(),
      eventData: popupDataV2.eventData.toLegacy(),
      oddsType: popupDataV2.oddsType,
      leagueData: popupDataV2.leagueData?.toLegacy(),
      oddsStyle: _convertOddsFormatToStyle(popupDataV2.oddsFormat),
      minStake: popupDataV2.minStake,
      maxStake: popupDataV2.maxStake,
      maxPayout: popupDataV2.maxPayout,
    );

    return addSingleBetFromPopupData(legacyData);
  }

  SingleBetData _syncBetToLiveOdds(SingleBetData bet) {
    final offerId = bet.offerId;
    if (offerId == null || offerId.isEmpty) return bet;
    if (bet.isDisabled) return bet;

    final adapter = _ref.read(sportSocketAdapterProvider);
    final odds = adapter.getOdds(
      bet.eventData.eventId,
      bet.marketData.marketId,
      offerId,
    );
    if (odds == null) {
      debugPrint(
        '[ParlayState] _syncBetToLiveOdds: store chưa có odds cho '
        '${bet.eventData.eventId}/${bet.marketData.marketId}/$offerId',
      );
      return bet;
    }

    if (odds.isSuspended) {
      return bet.copyWith(isDisabled: true);
    }

    final newValue = _getOddsValueFromLibrary(odds, bet.oddsType, bet.sendOddsStyle);

    debugPrint(
      '[ParlayState] _syncBetToLiveOdds: sel=${bet.selectionId} '
      'offer=$offerId type=${bet.oddsType} | '
      'bet.displayOdds=${bet.displayOdds} -> store=$newValue | '
      'store raw: home=${odds.oddsHome} away=${odds.oddsAway} '
      'draw=${odds.oddsDraw} suspended=${odds.isSuspended}',
    );

    if (newValue == null || newValue == 0 || newValue == -100) return bet;

    if ((newValue - bet.displayOdds).abs() < 0.001) return bet;

    return bet.copyWith(oddsData: _applyStoreOddsToBet(bet, odds));
  }

  LeagueOddsData _applyStoreOddsToBet(SingleBetData bet, socket.OddsData odds) {
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
        return bet.oddsData;
    }
    if (decimal == null) return bet.oddsData;

    OddsValue merge(OddsValue original) => OddsValue(
      decimal: decimal!,
      malay: double.tryParse(malay ?? '') ?? original.malay,
      indo: double.tryParse(indo ?? '') ?? original.indo,
      hongKong: double.tryParse(hk ?? '') ?? original.hongKong,
    );

    switch (bet.oddsType) {
      case OddsType.home:
        return bet.oddsData.copyWith(oddsHome: merge(bet.oddsData.oddsHome));
      case OddsType.away:
        return bet.oddsData.copyWith(oddsAway: merge(bet.oddsData.oddsAway));
      case OddsType.draw:
        return bet.oddsData.copyWith(oddsDraw: merge(bet.oddsData.oddsDraw));
      default:
        return bet.oddsData;
    }
  }

  OddsStyle _convertOddsFormatToStyle(dynamic oddsFormat) {
    final formatStr = oddsFormat.toString();
    if (formatStr.contains('malay')) return OddsStyle.malay;
    if (formatStr.contains('indo')) return OddsStyle.indo;
    if (formatStr.contains('hk')) return OddsStyle.hongKong;
    return OddsStyle.decimal;
  }

  void setSingleBetStakeAt(int index, int value) {
    if (index < 0 || index >= state.singleBets.length) return;

    final bet = state.singleBets[index];
    final clamped = value.clamp(0, bet.maxStakeActual);
    final updatedBets = [...state.singleBets];
    updatedBets[index] = bet.copyWith(stake: clamped);

    state = state.copyWith(singleBets: updatedBets);
  }

  void addSingleBetStakeAt(int index, int delta) {
    if (index < 0 || index >= state.singleBets.length) return;
    setSingleBetStakeAt(index, state.singleBets[index].stake + delta);
  }

  void setSingleBetStakeMaxAt(int index) {
    if (index < 0 || index >= state.singleBets.length) return;
    setSingleBetStakeAt(index, state.singleBets[index].maxStakeActual);
  }

  void clearSingleBetStakeAt(int index) {
    if (index < 0 || index >= state.singleBets.length) return;
    final updatedBets = [...state.singleBets];
    updatedBets[index] = state.singleBets[index].copyWith(stake: 0);
    state = state.copyWith(singleBets: updatedBets);
  }

  Future<void> removeSingleBetAt(int index, {bool cascade = true}) async {
    if (index < 0 || index >= state.singleBets.length) return;

    final eventId = state.singleBets[index].eventData.eventId;
    final selectionId = state.singleBets[index].selectionId;

    final updatedBets = [...state.singleBets]..removeAt(index);

    final newChangedCount = _countBetsWithChangedOdds(
      updatedBets,
      state.comboBets,
    );

    state = state.copyWith(
      singleBets: updatedBets,
      changedOddsCount: newChangedCount,
    );

    await _saveToStorage(updatedBets);

    _notifySubscriptionManager();

    BetslipSubscriptionManager.instance?.onBetRemoved(eventId);

    if (cascade) {
      removeFromComboBySelectionId(selectionId, cascade: false);
    }
  }

  void addSingleBetDirect(SingleBetData bet) {
    final exists = state.singleBets.any(
      (b) => b.selectionId == bet.selectionId,
    );
    if (exists) {
      debugPrint('[ParlayState] Bet already exists in single bets list');
      return;
    }

    final updatedBets = [...state.singleBets, bet];
    state = state.copyWith(singleBets: updatedBets);
    _saveToStorage(updatedBets);

    BetslipSubscriptionManager.instance?.onBetAdded(bet.eventData.eventId);
  }

  void addComboBetDirect(SingleBetData bet) {
    final exists = state.comboBets.any(
      (b) => b.eventData.eventId == bet.eventData.eventId,
    );
    if (exists) {
      debugPrint('[ParlayState] Event already exists in combo bets list');
      return;
    }

    final updatedComboBets = [...state.comboBets, bet];
    final combineOdds = _calculateCombineOdds(updatedComboBets);
    state = state.copyWith(comboBets: updatedComboBets, totalOdds: combineOdds);
    _saveComboToStorage(updatedComboBets);

    _notifySubscriptionManager();

    BetslipSubscriptionManager.instance?.onBetAdded(bet.eventData.eventId);
  }

  void clearAllSingleBets() {
    final eventIds = state.singleBets
        .map((bet) => bet.eventData.eventId)
        .toList();

    final newChangedCount = _countBetsWithChangedOdds([], state.comboBets);

    state = state.copyWith(
      singleBets: [],
      changedOddsCount: newChangedCount,
    );

    _saveToStorage([]);

    _notifySubscriptionManager();

    for (final eventId in eventIds) {
      BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
    }
  }

  Future<void> calculateSingleBetAt(int index) async {
    if (index < 0 || index >= state.singleBets.length) {
      debugPrint('[ParlayState] calculateSingleBetAt: invalid index $index');
      return;
    }

    final singleBet = state.singleBets[index];

    if (singleBet.isDisabled) {
      debugPrint(
        '[ParlayState] calculateSingleBetAt[$index]: Skipping disabled bet',
      );
      return;
    }

    debugPrint('[ParlayState] calculateSingleBetAt[$index]: Starting...');
    debugPrint('[ParlayState] leagueId: ${singleBet.leagueIdString}');
    debugPrint('[ParlayState] offerId: ${singleBet.offerId}');
    debugPrint('[ParlayState] selectionId: ${singleBet.selectionId}');
    debugPrint('[ParlayState] displayOdds: ${singleBet.displayOddsString}');
    debugPrint('[ParlayState] isLive: ${singleBet.isLive}');

    final loadingBets = [...state.singleBets];
    loadingBets[index] = singleBet.copyWith(isCalculating: true);
    state = state.copyWith(singleBets: loadingBets);

    try {
      final request = CalculateBetRequest(
        leagueId: singleBet.leagueIdString,
        matchTime: singleBet.matchTimeISO,
        isLive: singleBet.isLive,
        offerId: singleBet.offerId ?? '',
        selectionId: singleBet.selectionId ?? '',
        displayOdds: singleBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(singleBet.sendOddsStyle),
      );

      debugPrint('[ParlayState] Calling calculateBet API...');
      final response = await _repository.calculateBet(request, sportId: singleBet.sportId);
      debugPrint('[ParlayState] Response errorCode: ${response.errorCode}');
      debugPrint('[ParlayState] Response minStake: ${response.minStake}');
      debugPrint('[ParlayState] Response maxStake: ${response.maxStake}');

      if (index >= state.singleBets.length) {
        debugPrint('[ParlayState] Bet was removed while calculating');
        return;
      }

      final currentBet = state.singleBets[index];
      final updatedBets = [...state.singleBets];

      if (response.errorCode == 0) {
        debugPrint('[ParlayState] calculateBet SUCCESS');
        debugPrint(
          '[ParlayState] minStake: ${response.minStake}, maxStake: ${response.maxStake}',
        );

        updatedBets[index] = currentBet.copyWith(
          minStake: response.minStake,
          maxStake: response.maxStake,
          maxPayout: response.maxPayout,
          isCalculating: false,
        );
        state = state.copyWith(singleBets: updatedBets, clearError: true);
      } else {
        debugPrint('[ParlayState] calculateBet ERROR: ${response.errorCode}');

        final shouldDisable = response.errorCode == 607;
        if (shouldDisable) {
          debugPrint(
            '[ParlayState] Disabling bet due to error 607 (odds not found)',
          );
        }

        final calcErr = bettingApiErrorDisplayMessage(
          response.errorCode,
          serverMessage: response.message,
          fallback: bettingApiCalculateBetFailureFallback,
        );
        updatedBets[index] = currentBet.copyWith(
          isCalculating: false,
          errorMessage: calcErr,
          isDisabled: shouldDisable,
          stake: shouldDisable
              ? 0
              : null,
        );

        state = state.copyWith(
          singleBets: updatedBets,
          error: shouldDisable ? null : calcErr,
        );

        if (shouldDisable) {
          _saveToStorage();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('calculateBet failed', error: e, stackTrace: stackTrace);

      if (index >= state.singleBets.length) {
        debugPrint('[ParlayState] Bet was removed while calculating');
        return;
      }

      final currentBet = state.singleBets[index];
      final updatedBets = [...state.singleBets];
      updatedBets[index] = currentBet.copyWith(
        isCalculating: false,
        errorMessage: bettingApiCalculateBetFailureFallback,
      );
      state = state.copyWith(
        singleBets: updatedBets,
        error: bettingApiCalculateBetFailureFallback,
      );
    }
  }

  BetSelectionModel _buildPlaceSelection(
    SingleBetData bet, {
    double? overrideOdds,
  }) {
    if (bet.stake % 1000 != 0) {
      bet = bet.copyWith(stake: MoneyFormatter.floorToThousand(bet.stake));
    }

    final placeOdds = double.parse(
      (overrideOdds ?? bet.displayOdds).toStringAsFixed(2),
    );
    return BetSelectionModel(
      eventId: bet.eventData.eventId,
      eventName: '${bet.homeName} vs ${bet.awayName}',
      selectionId: bet.selectionId ?? '',
      selectionName: bet.selectionName,
      offerId: bet.offerId ?? '',
      displayOdds: placeOdds.toStringAsFixed(2),
      oddsStyle: _getOddsStyleCode(bet.sendOddsStyle),
      cls: bet.cls,
      leagueId: bet.leagueIdString,
      matchTime: bet.matchTimeISO,
      isLive: bet.isLive,
      sportId: bet.sportId,
      homeScore: bet.eventData.homeScore,
      awayScore: bet.eventData.awayScore,
      stake: bet.stake.toDouble(),
      winnings: bet.potentialWinningsWith(placeOdds),
    );
  }

  Future<bool> placeSingleBetAt(int index) async {
    if (index < 0 || index >= state.singleBets.length) return false;
    if (!state.singleBets[index].canPlaceBet) return false;

    final selectionId = state.singleBets[index].selectionId;
    if (selectionId == null || selectionId.isEmpty) return false;

    state = state.copyWith(isPlacingBet: true, clearError: true);
    return _placeSingleBetInternal(selectionId);
  }

  Future<bool> _placeSingleBetInternal(
    String selectionId, {
    double? overrideOdds,
    int retriesLeft = 1,
  }) async {
    final index = state.singleBets.indexWhere(
      (b) => b.selectionId == selectionId,
    );
    if (index < 0) {
      state = state.copyWith(isPlacingBet: false);
      return false;
    }

    var singleBet = state.singleBets[index];

    if (overrideOdds == null) {
      singleBet = _syncBetToLiveOdds(singleBet);

      if (singleBet.isDisabled) {
        final updated = [...state.singleBets];
        updated[index] = singleBet;
        state = state.copyWith(
          singleBets: updated,
          isPlacingBet: false,
          error: 'Kèo đã tạm khóa, vui lòng thử lại',
        );
        return false;
      }

      if (singleBet.displayOdds != state.singleBets[index].displayOdds) {
        final synced = [...state.singleBets];
        synced[index] = singleBet;
        state = state.copyWith(singleBets: synced);
      }
    }

    final oddsToSend =
        overrideOdds?.toStringAsFixed(2) ?? singleBet.displayOddsString;
    debugPrint(
      '[ParlayState] Place attempt: sel=$selectionId odds=$oddsToSend '
      '(override=${overrideOdds != null})',
    );

    try {
      final request = PlaceBetRequest(
        matchId: singleBet.eventData.eventId,
        selections: [
          _buildPlaceSelection(singleBet, overrideOdds: overrideOdds),
        ],
        singleBet: true,
      );

      final response = await _repository.placeBet(request);

      if (response.errorCode == 603 && retriesLeft > 0) {
        final serverOdds = response.serverCurrentOdds;
        if (serverOdds != null) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (!mounted) return false;
          return _placeSingleBetInternal(
            selectionId,
            overrideOdds: serverOdds,
            retriesLeft: retriesLeft - 1,
          );
        }
        debugPrint(
          '[ParlayState] WARN: 603 without parseable values: ${response.values}',
        );
      }

      state = state.copyWith(isPlacingBet: false, lastPlaceBetResult: response);

      if (response.isSuccess) {
        removeSingleBetAt(index, cascade: false);
        _ref.read(userProvider.notifier).refreshBalance();
        return true;
      } else {
        state = state.copyWith(
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiPlaceBetFailureFallback,
          ),
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

  Future<int> placeAllSingleBets() async {
    int successCount = 0;
    for (int i = state.singleBets.length - 1; i >= 0; i--) {
      if (state.singleBets[i].canPlaceBet) {
        final success = await placeSingleBetAt(i);
        if (success) successCount++;
      }
    }
    return successCount;
  }

  PlaceMultipleBetsResult? _lastPlaceMultipleResult;

  PlaceMultipleBetsResult? get lastPlaceMultipleResult =>
      _lastPlaceMultipleResult;

  Future<PlaceMultipleBetsResult> placeAllSingleBetsParallel() async {
    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      return const PlaceMultipleBetsResult(
        successfulBets: [],
        failedBets: [],
        totalStake: 0,
      );
    }

    state = state.copyWith(isPlacingBet: true, clearError: true);

    final futures = betsToPlace.map((rawBet) async {
      final singleBet = _syncBetToLiveOdds(rawBet);

      if (singleBet.isDisabled) {
        return _SingleBetPlaceResult(
          bet: singleBet,
          success: false,
          error: 'Kèo đã tạm khóa, vui lòng thử lại',
        );
      }

      PlaceBetResponse? response;
      double? overrideOdds;

      for (var attempt = 0; attempt < 2; attempt++) {
        if (attempt == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (!mounted) {
            return _SingleBetPlaceResult(
              bet: singleBet,
              success: false,
              error: 'disposed',
            );
          }
        }

        final oddsToSend =
            overrideOdds?.toStringAsFixed(2) ?? singleBet.displayOddsString;
        debugPrint(
          '[ParlayState] Place attempt: sel=${singleBet.selectionId} '
          'odds=$oddsToSend (override=${overrideOdds != null})',
        );

        try {
          final request = PlaceBetRequest(
            matchId: singleBet.eventData.eventId,
            selections: [
              _buildPlaceSelection(singleBet, overrideOdds: overrideOdds),
            ],
            singleBet: true,
          );

          response = await _repository.placeBet(request);

          debugPrint(
            '[ParlayState] placeBet response: status=${response.status}, errorCode=${response.errorCode}, message=${response.message}, ticketId=${response.ticketId}',
          );
        } catch (e) {
          debugPrint(
            '[ParlayState] placeBet error for ${singleBet.selectionName}: $e',
          );
          return _SingleBetPlaceResult(
            bet: singleBet,
            success: false,
            error: e.toString(),
          );
        }

        if (response.errorCode != 603) break;
        final serverOdds = response.serverCurrentOdds;
        if (serverOdds == null) {
          debugPrint(
            '[ParlayState] WARN: 603 without parseable values: ${response.values}',
          );
          break;
        }
        overrideOdds = serverOdds;
      }

      return _SingleBetPlaceResult(
        bet: singleBet,
        success: response!.isSuccess,
        response: response,
      );
    }).toList();

    final results = await Future.wait(futures);

    final successfulBets = <SingleBetData>[];
    final failedBets = <SingleBetData>[];
    final betsToRemove =
        <SingleBetData>[];
    final betsToKeep = <SingleBetData>[];
    final errorMessages = <String>[];
    int totalStake = 0;

    for (final result in results) {
      if (result.success) {
        successfulBets.add(result.bet);
        totalStake += result.bet.stake;
      } else {
        failedBets.add(result.bet);
        final errorCode = result.response?.errorCode;
        if (result.response != null) {
          errorMessages.add(
            bettingApiErrorDisplayMessage(
              errorCode,
              serverMessage: result.response!.message,
              fallback: bettingApiPlaceBetFailureFallback,
            ),
          );
        } else if (result.error != null) {
          errorMessages.add('Lỗi kết nối máy chủ!');
        }

        if (bettingApiErrorIsMoneyRelated(errorCode)) {
          betsToKeep.add(result.bet);
        } else {
          betsToRemove.add(result.bet);
        }
      }
    }

    debugPrint(
      '[ParlayState] Place bets result: ${successfulBets.length} success, ${failedBets.length} failed (${betsToRemove.length} to remove, ${betsToKeep.length} to keep)',
    );

    final betsToRemoveFromState = [...successfulBets, ...betsToRemove];
    if (betsToRemoveFromState.isNotEmpty) {
      final selectionIdsToRemove = betsToRemoveFromState
          .map((b) => b.selectionId)
          .toSet();
      final remainingBets = state.singleBets
          .where((bet) => !selectionIdsToRemove.contains(bet.selectionId))
          .toList();

      state = state.copyWith(singleBets: remainingBets, isPlacingBet: false);

      _saveToStorage();

      if (successfulBets.isNotEmpty) {
        _ref.read(userProvider.notifier).refreshBalance();
      }
    } else {
      state = state.copyWith(isPlacingBet: false);
    }

    final result = PlaceMultipleBetsResult(
      successfulBets: successfulBets,
      failedBets: failedBets,
      totalStake: totalStake,
      errorMessages: errorMessages,
      betsToRemove: betsToRemove,
      betsToKeep: betsToKeep,
    );

    if (result.betsToRemove.isNotEmpty) {
      unawaited(reconcileBetslipEvents(force: true));
    }

    _lastPlaceMultipleResult = result;
    return result;
  }

  Future<bool> addToComboParlay(int singleBetIndex) async {
    if (singleBetIndex < 0 || singleBetIndex >= state.singleBets.length) {
      return false;
    }

    final singleBet = state.singleBets[singleBetIndex];

    if (state.isBetInCombo(singleBet.eventData.eventId)) {
      debugPrint('[ParlayState] Event already exists in combo parlay');
      return false;
    }

    final maxMatches = state.maxMatches > 0 ? state.maxMatches : 20;
    if (state.comboBets.length >= maxMatches) {
      debugPrint('[ParlayState] Max matches reached: $maxMatches');
      state = state.copyWith(
        error: 'Đã đạt số trận tối đa ($maxMatches trận) cho cược xiên',
      );
      return false;
    }

    if (!singleBet.marketData.isParlay) {
      debugPrint('[ParlayState] Market does not support parlay');
      state = state.copyWith(error: 'Kèo này không hỗ trợ cược xiên');
      return false;
    }

    final updatedComboBets = [...state.comboBets, singleBet];

    final combineOdds = _calculateCombineOdds(updatedComboBets);

    state = state.copyWith(
      comboBets: updatedComboBets,
      totalOdds: combineOdds,
      clearError: true,
    );

    _saveComboToStorage();

    if (state.isComboValid) {
      await calculateComboParlay();

      if (state.maxStake > 0 && state.minStake > state.maxStake) {
        final rolledBack = [...state.comboBets]..removeWhere(
          (b) => b.eventData.eventId == singleBet.eventData.eventId,
        );
        state = state.copyWith(
          comboBets: rolledBack,
          totalOdds: _calculateCombineOdds(rolledBack),
          minStake: 0,
          maxStake: 0,
          error: 'Vượt quá tỷ lệ kết hợp tối đa, vui lòng chọn kèo khác',
        );
        _saveComboToStorage();
        return false;
      }
    } else {
      debugPrint(
        '[ParlayState] Skip calculateComboParlay: not enough matches '
        '(hasEnoughMatches=${state.hasEnoughMatches})',
      );
    }

    BetslipSubscriptionManager.instance?.onBetAdded(
      singleBet.eventData.eventId,
    );

    return true;
  }

  void _autoAddToCombo(SingleBetData bet) {
    if (state.isSelectionInCombo(bet.selectionId)) return;
    final maxMatches = state.maxMatches > 0 ? state.maxMatches : 20;
    if (state.comboBets.length >= maxMatches) return;

    final updatedComboBets = [...state.comboBets, bet];
    state = state.copyWith(
      comboBets: updatedComboBets,
      totalOdds: _calculateCombineOdds(updatedComboBets),
    );
    _saveComboToStorage();
    _notifySubscriptionManager();
    BetslipSubscriptionManager.instance?.onBetAdded(bet.eventData.eventId);

    if (state.isComboValid) {
      unawaited(
        _validateAutoCombo(bet.selectionId, bet.eventData.eventId),
      );
    }
  }

  Future<void> _validateAutoCombo(String? selectionId, int eventId) async {
    await calculateComboParlay();
    if (state.maxStake > 0 && state.minStake > state.maxStake) {
      final rolledBack = [...state.comboBets]
        ..removeWhere((b) => b.selectionId == selectionId);
      state = state.copyWith(
        comboBets: rolledBack,
        totalOdds: _calculateCombineOdds(rolledBack),
        minStake: 0,
        maxStake: 0,
      );
      _saveComboToStorage();
      BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
    }
  }

  Future<void> calculateComboBetAt(int index) async {
    if (index < 0 || index >= state.comboBets.length) {
      debugPrint('[ParlayState] calculateComboBetAt: invalid index $index');
      return;
    }

    final comboBet = state.comboBets[index];

    if (comboBet.isDisabled) {
      debugPrint(
        '[ParlayState] calculateComboBetAt[$index]: Skipping disabled bet',
      );
      return;
    }

    debugPrint(
      '[ParlayState] calculateComboBetAt[$index]: Checking validity...',
    );

    try {
      final request = CalculateBetRequest(
        leagueId: comboBet.leagueIdString,
        matchTime: comboBet.matchTimeISO,
        isLive: comboBet.isLive,
        offerId: comboBet.offerId ?? '',
        selectionId: comboBet.selectionId ?? '',
        displayOdds: comboBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(comboBet.sendOddsStyle),
      );

      final response = await _repository.calculateBet(request, sportId: comboBet.sportId);

      if (index >= state.comboBets.length) {
        debugPrint('[ParlayState] Combo bet was removed while calculating');
        return;
      }

      final currentBet = state.comboBets[index];
      final updatedBets = [...state.comboBets];

      if (response.errorCode == 0) {
        debugPrint('[ParlayState] calculateComboBetAt[$index] SUCCESS');
      } else {
        debugPrint(
          '[ParlayState] calculateComboBetAt[$index] ERROR: ${response.errorCode}',
        );

        final shouldDisable = response.errorCode == 607;
        if (shouldDisable) {
          debugPrint('[ParlayState] Disabling combo bet due to error 607');
          updatedBets[index] = currentBet.copyWith(isDisabled: true);
          final combineOdds = _calculateCombineOdds(updatedBets);
          state = state.copyWith(
            comboBets: updatedBets,
            totalOdds: combineOdds,
          );
          _saveComboToStorage();
        }
      }
    } catch (e) {
      _logger.e('calculateComboBetAt[$index] failed', error: e);
    }
  }

  void removeFromComboParlay(int index, {bool cascade = true}) {
    if (index < 0 || index >= state.comboBets.length) return;

    final eventId = state.comboBets[index].eventData.eventId;
    final selectionId = state.comboBets[index].selectionId;

    final updatedComboBets = [...state.comboBets]..removeAt(index);
    final combineOdds = _calculateCombineOdds(updatedComboBets);

    final newChangedCount = _countBetsWithChangedOdds(
      state.singleBets,
      updatedComboBets,
    );

    state = state.copyWith(
      comboBets: updatedComboBets,
      totalOdds: combineOdds,
      minStake: updatedComboBets.isEmpty ? 0 : state.minStake,
      maxStake: updatedComboBets.isEmpty ? 0 : state.maxStake,
      changedOddsCount: newChangedCount,
      clearError: true,
    );

    _saveComboToStorage(updatedComboBets);

    _notifySubscriptionManager();

    BetslipSubscriptionManager.instance?.onBetRemoved(eventId);

    if (state.tab == ParlayTab.combo && state.hasEnoughMatches) {
      calculateComboParlay();
    }

    if (cascade) {
      removeSingleBetBySelectionId(selectionId, cascade: false);
    }
  }

  void removeFromComboBySelectionId(String? selectionId, {bool cascade = true}) {
    if (selectionId == null) return;

    final index = state.comboBets.indexWhere(
      (bet) => bet.selectionId == selectionId,
    );
    if (index >= 0) {
      removeFromComboParlay(index, cascade: cascade);
    }
  }

  void removeSingleBetBySelectionId(String? selectionId, {bool cascade = true}) {
    if (selectionId == null) return;

    final index = state.singleBets.indexWhere(
      (bet) => bet.selectionId == selectionId,
    );
    if (index >= 0) {
      removeSingleBetAt(index, cascade: cascade);
    }
  }

  void clearAllComboBets() {
    final eventIds = state.comboBets
        .map((bet) => bet.eventData.eventId)
        .toList();

    final newChangedCount = _countBetsWithChangedOdds(state.singleBets, []);

    state = state.copyWith(
      comboBets: [],
      totalOdds: 1.0,
      minStake: 0,
      maxStake: 0,
      stake: 0,
      changedOddsCount: newChangedCount,
      clearError: true,
    );

    _saveComboToStorage([]);

    _notifySubscriptionManager();

    for (final eventId in eventIds) {
      BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
    }
  }

  double _calculateCombineOdds(List<SingleBetData> comboBets) {
    return comboBets.where((bet) => !bet.isDisabled).fold(
      1.0,
      (total, bet) => total * bet.getOddsByStyle(OddsStyle.decimal),
    );
  }

  Future<void> calculateComboParlay() async {
    if (state.comboBets.isEmpty) return;

    if (!state.isComboValid) {
      if (state.isCalculatingCombo) {
        state = state.copyWith(isCalculatingCombo: false);
      }
      return;
    }

    state = state.copyWith(isCalculatingCombo: true);

    try {
      const oddsStyle = 'de';

      final activeLegs = state.comboBets.where((b) => !b.isDisabled).toList();

      debugPrint('[ParlayState] calculateComboParlay request:');
      debugPrint(
        '  legs: ${activeLegs.length} active / ${state.comboBets.length} total',
      );
      for (final bet in activeLegs) {
        debugPrint('  - selectionId: ${bet.selectionId}');
        debugPrint('    offerId: ${bet.offerId}');
        debugPrint('    displayOdds: ${bet.displayOddsString}');
        debugPrint('    leagueId: ${bet.leagueIdString}');
        debugPrint('    matchTime: ${bet.matchTimeISO}');
        debugPrint('    isLive: ${bet.isLive}');
      }
      debugPrint('  oddsStyle: $oddsStyle');

      final response = await _repository.calculateParlayBet(
        activeLegs,
        oddsStyle,
      );

      debugPrint('[ParlayState] calculateComboParlay response:');
      debugPrint('  minStake: ${response.minStake}');
      debugPrint('  maxStake: ${response.maxStake}');
      debugPrint('  minMatches: ${response.minMatches}');
      debugPrint('  maxMatches: ${response.maxMatches}');

      if (response.errorCode == 0) {

        final combineOdds = _calculateCombineOdds(state.comboBets);

        final minStakeVnd = response.minStake * 1000;
        final maxStakeVnd = response.maxStake * 1000;

        state = state.copyWith(
          minStake: minStakeVnd,
          maxStake: maxStakeVnd,
          minMatches: response.minMatches,
          maxMatches: response.maxMatches,
          totalOdds: combineOdds,
          isCalculatingCombo: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isCalculatingCombo: false,
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiCalculateParlayFailureFallback,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('calculateComboParlay failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isCalculatingCombo: false,
        error: bettingApiCalculateParlayFailureFallback,
      );
    }
  }

  Future<bool> placeComboParlay() async {
    if (!state.canPlaceBet || state.tab != ParlayTab.combo) return false;

    state = state.copyWith(isPlacingBet: true, clearError: true);

    try {
      const oddsStyle = 'de';

      final activeLegs = state.comboBets.where((b) => !b.isDisabled).toList();

      final response = await _repository.placeParlayBet(
        activeLegs,
        MoneyFormatter.floorToThousand(state.stake),
        oddsStyle,
      );

      state = state.copyWith(isPlacingBet: false, lastPlaceBetResult: response);

      if (response.isSuccess) {
        clearAllComboBets();
        _ref.read(userProvider.notifier).refreshBalance();
        _ref.read(myBetRepositoryProvider).notifyBetPlaced();
        return true;
      } else {
        state = state.copyWith(
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiParlayComboFailureFallback,
          ),
        );
        if (!bettingApiErrorIsMoneyRelated(response.errorCode)) {
          unawaited(reconcileBetslipEvents(force: true));
        }
        return false;
      }
    } catch (e) {
      _logger.e('placeComboParlay failed', error: e);
      state = state.copyWith(
        isPlacingBet: false,
        error: bettingApiErrorDisplayMessage(
          null,
          fallback: bettingApiParlayComboFailureFallback,
        ),
      );
      return false;
    }
  }

  void setStake(int value) {
    final maxStake = state.maxStake > 0 ? state.maxStake : 750000000;
    state = state.copyWith(stake: value.clamp(0, maxStake));
  }

  void addStake(int delta) => setStake(state.stake + delta);

  void setStakeFromInput(String rawValue) {
    final numeric = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      state = state.copyWith(stake: 0);
      return;
    }
    setStake(int.parse(numeric));
  }

  void clearStake() => state = state.copyWith(stake: 0);

  void setMultiStake(int index, int value) {
    if (index < 0 || index >= state.multiBets.length) {
      return;
    }
    final bet = state.multiBets[index];
    final clamped = value.clamp(bet.minStake, bet.maxStake);
    final updated = [...state.multiBets]
      ..[index] = bet.copyWith(stake: clamped);
    state = state.copyWith(multiBets: updated);
  }

  void clearMultiStake(int index) {
    if (index < 0 || index >= state.multiBets.length) {
      return;
    }
    final bet = state.multiBets[index];
    final updated = [...state.multiBets]..[index] = bet.copyWith(stake: 0);
    state = state.copyWith(multiBets: updated);
  }

  void _onOddsChanged(List<String> changedSelectionIds) {
    if (changedSelectionIds.isEmpty) return;

    if (state.showOddsChangedNotification) {
      _pendingChangedBetIds.clear();
      _pendingChangedBetIds.addAll(changedSelectionIds);

      _oddsChangedDebounceTimer?.cancel();

      _oddsChangedDebounceTimer = Timer(const Duration(seconds: 3), () {
        if (_pendingChangedBetIds.isNotEmpty) {
          state = state.copyWith(
            changedOddsCount: _pendingChangedBetIds.length,
          );
          _pendingChangedBetIds.clear();
        }
      });
      return;
    }

    _pendingChangedBetIds.addAll(changedSelectionIds);

    _oddsChangedDebounceTimer?.cancel();

    _oddsChangedDebounceTimer = Timer(const Duration(seconds: 3), () {
      if (_pendingChangedBetIds.isNotEmpty) {
        state = state.copyWith(
          changedOddsCount: _pendingChangedBetIds.length,
          showOddsChangedNotification: true,
        );
        _pendingChangedBetIds.clear();
      }
    });
  }

  int _countBetsWithChangedOdds(
    List<SingleBetData> singleBets,
    List<SingleBetData> comboBets,
  ) {
    int count = 0;
    for (final bet in singleBets) {
      if (bet.updatedOdds != null) count++;
    }
    for (final bet in comboBets) {
      if (bet.updatedOdds != null) count++;
    }
    return count;
  }

  void acceptOddsChanges() {
    _pendingChangedBetIds.clear();
    _oddsChangedDebounceTimer?.cancel();

    final updatedSingleBets = state.singleBets.map((bet) {
      if (bet.updatedOdds != null) {
        return bet.copyWith(updatedOdds: null);
      }
      return bet;
    }).toList();

    final updatedComboBets = state.comboBets.map((bet) {
      if (bet.updatedOdds != null) {
        return bet.copyWith(updatedOdds: null);
      }
      return bet;
    }).toList();

    state = state.copyWith(
      singleBets: updatedSingleBets,
      comboBets: updatedComboBets,
      changedOddsCount: 0,
      showOddsChangedNotification: false,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _getOddsStyleCode(OddsStyle style) =>
      BettingRestRules.oddsStyleApiCode(style);
}

final parlayStateProvider =
    StateNotifierProvider<ParlayStateNotifier, ParlayState>((ref) {
      final repository = BettingRepositoryImpl();
      return ParlayStateNotifier(repository, ref);
    });

final singleBetsProvider = Provider<List<SingleBetData>>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.singleBets));
});

final isSingleBetCalculatingProvider = Provider<bool>((ref) {
  return ref.watch(
    parlayStateProvider.select(
      (s) => s.singleBets.any((bet) => bet.isCalculating),
    ),
  );
});

final singleBetsCountProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.singleBets.length));
});

final isPlacingBetProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.isPlacingBet));
});

final parlayErrorProvider = Provider<String?>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.error));
});

final inSlipKeysProvider = Provider<Set<String>>((ref) {
  final singleBets = ref.watch(singleBetsProvider);
  return {
    for (final bet in singleBets)
      if (!bet.isDisabled) '${bet.eventData.eventId}_${bet.selectionId}',
  };
});

final isBetInSlipProvider = Provider.autoDispose.family<bool, String>((
  ref,
  key,
) {
  return ref.watch(inSlipKeysProvider).contains(key);
});

final betIndexInSlipProvider = Provider.autoDispose.family<int, String>((
  ref,
  key,
) {
  final singleBets = ref.watch(singleBetsProvider);
  final parts = key.split('_');
  if (parts.length != 2) return -1;

  final eventId = int.tryParse(parts[0]);
  final selectionId = parts[1];

  return singleBets.indexWhere(
    (bet) =>
        !bet.isDisabled &&
        bet.eventData.eventId == eventId &&
        bet.selectionId == selectionId,
  );
});

final multiBetsProvider = Provider<List<ParlayMultiBet>>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.multiBets));
});

final comboBetsProvider = Provider<List<SingleBetData>>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.comboBets));
});

final comboBetsCountProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.comboBetsCount));
});

final isCalculatingComboProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.isCalculatingCombo));
});

final comboTotalOddsProvider = Provider<double>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.totalOdds));
});

final comboMinStakeProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.minStake));
});

final comboMaxStakeProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.maxStake));
});

final minMatchesProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.minMatches));
});

final maxMatchesProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.maxMatches));
});

final hasEnoughMatchesProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.hasEnoughMatches));
});

final isBetInComboProvider = Provider.autoDispose.family<bool, int>((
  ref,
  eventId,
) {
  return ref.watch(
    parlayStateProvider.select((state) => state.isBetInCombo(eventId)),
  );
});

final isSelectionInComboProvider = Provider.autoDispose.family<bool, String?>((
  ref,
  selectionId,
) {
  if (selectionId == null) return false;
  return ref.watch(
    parlayStateProvider.select(
      (state) => state.isSelectionInCombo(selectionId),
    ),
  );
});

final hasOtherSelectionInComboProvider = Provider.autoDispose
    .family<bool, (int, String?)>((ref, params) {
      final (eventId, selectionId) = params;
      return ref.watch(
        parlayStateProvider.select(
          (state) => state.hasOtherSelectionInCombo(eventId, selectionId),
        ),
      );
    });

final changedOddsCountProvider = Provider<int>((ref) {
  final state = ref.watch(parlayStateProvider);

  switch (state.tab) {
    case ParlayTab.single:
      return state.singleBets.where((bet) => bet.updatedOdds != null).length;
    case ParlayTab.combo:
      return state.comboBets.where((bet) => bet.updatedOdds != null).length;
    case ParlayTab.multi:
      return 0;
  }
});

final totalBetCountProvider = Provider<int>((ref) {
  final singleBetsCount = ref.watch(
    parlayStateProvider.select((state) => state.singleBets.length),
  );
  final comboBetsCount = ref.watch(
    parlayStateProvider.select((state) => state.comboBetsCount),
  );
  final minMatches = ref.watch(
    parlayStateProvider.select((state) => state.minMatches),
  );

  final hasValidCombo = comboBetsCount >= minMatches;
  return singleBetsCount + (hasValidCombo ? 1 : 0);
});

final showOddsChangedNotificationProvider = Provider<bool>((ref) {
  final state = ref.watch(parlayStateProvider);

  if (!state.showOddsChangedNotification) return false;

  switch (state.tab) {
    case ParlayTab.single:
      return state.singleBets.any((bet) => bet.updatedOdds != null);
    case ParlayTab.combo:
      return state.comboBets.any((bet) => bet.updatedOdds != null);
    case ParlayTab.multi:
      return false;
  }
});

final isBettingReadyProvider = Provider<bool>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  ref.watch(socketConnectionStateProvider);
  final adapter = ref.read(sportSocketAdapterProvider);
  return isAuthenticated && adapter.isInitialized && adapter.isConnected;
});

class ParlayMultiBet {
  final String status;
  final String title;
  final String market;
  final String pick;
  final double odd;
  final bool isLive;
  final int stake;
  final int minStake;
  final int maxStake;

  const ParlayMultiBet({
    required this.status,
    required this.title,
    required this.market,
    required this.pick,
    required this.odd,
    this.isLive = false,
    this.stake = 0,
    this.minStake = 50000,
    this.maxStake = 750000000,
  });

  ParlayMultiBet copyWith({
    String? status,
    String? title,
    String? market,
    String? pick,
    double? odd,
    bool? isLive,
    int? stake,
    int? minStake,
    int? maxStake,
  }) => ParlayMultiBet(
    status: status ?? this.status,
    title: title ?? this.title,
    market: market ?? this.market,
    pick: pick ?? this.pick,
    odd: odd ?? this.odd,
    isLive: isLive ?? this.isLive,
    stake: stake ?? this.stake,
    minStake: minStake ?? this.minStake,
    maxStake: maxStake ?? this.maxStake,
  );

  static const defaultBets = [
    ParlayMultiBet(
      status: '24" Hiệp 1',
      title: 'Bayern Munich 2 - 0 Paris Saint-Germain',
      market: 'Hiệp 1 - Chấp',
      pick: 'PSG (0.5)',
      odd: 0.95,
      isLive: true,
      stake: 10000000,
    ),
    ParlayMultiBet(
      status: '2:00PM - Thứ 6, 24 Th 12, 2025',
      title: 'Bayern Munich - Paris Saint-Germain',
      market: 'Toàn trận - 1x2',
      pick: 'Bayern',
      odd: 0.95,
      stake: 500000,
    ),
    ParlayMultiBet(
      status: '2:00PM - Thứ 6, 24 Th 12, 2025',
      title: 'Bayern Munich - Paris Saint-Germain',
      market: 'Toàn trận - 1x2',
      pick: 'Bayern',
      odd: 0.95,
    ),
  ];
}

class PlaceMultipleBetsResult {
  final List<SingleBetData> successfulBets;
  final List<SingleBetData> failedBets;
  final int totalStake;
  final List<String> errorMessages;

  final List<SingleBetData> betsToRemove;

  final List<SingleBetData> betsToKeep;

  const PlaceMultipleBetsResult({
    required this.successfulBets,
    required this.failedBets,
    required this.totalStake,
    this.errorMessages = const [],
    this.betsToRemove = const [],
    this.betsToKeep = const [],
  });

  bool get hasSuccessfulBets => successfulBets.isNotEmpty;
  bool get hasFailedBets => failedBets.isNotEmpty;
  int get successCount => successfulBets.length;
  int get failedCount => failedBets.length;

  String? get firstErrorMessage =>
      errorMessages.isNotEmpty ? errorMessages.first : null;
}

class _SingleBetPlaceResult {
  final SingleBetData bet;
  final bool success;
  final PlaceBetResponse? response;
  final String? error;

  const _SingleBetPlaceResult({
    required this.bet,
    required this.success,
    this.response,
    this.error,
  });
}

class AddBetResult {
  final bool success;
  final String? errorMessage;
  final int? errorCode;

  const AddBetResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  const AddBetResult.success()
    : success = true,
      errorMessage = null,
      errorCode = null;

  const AddBetResult.failure({this.errorMessage, this.errorCode})
    : success = false;
}

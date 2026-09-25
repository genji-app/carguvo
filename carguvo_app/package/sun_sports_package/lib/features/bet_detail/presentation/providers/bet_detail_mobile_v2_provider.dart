import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/services/datasources/event_detail_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/core/services/repositories/events_v2_repository.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/enums/market_filter.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart' show GamePart;
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data_v2.dart';

class BetTabData {
  final String label;
  final MarketFilter filter;

  const BetTabData({required this.label, required this.filter});
}

enum MarketGroup {
  oneXTwo,
  handicap,
  overUnder,
  oddEven,
  doubleChance,
  drawNoBet,
  cleanSheet,
  correctScore,
  totalScore,
  homeTeam,
  awayTeam,
  player,
  other,
}

class MarketGroupChip {
  final String? key;
  final String label;

  const MarketGroupChip({required this.key, required this.label});
}

const Object _noChange = Object();

class BetDetailMobileV2State {
  final bool isLoading;
  final String? error;
  final LeagueEventData? eventData;
  final LeagueData? leagueData;
  final List<MarketDrawerDataV2> drawers;
  final MarketFilter currentFilter;

  final String? marketGroupKey;

  final bool allExpanded;
  final Map<String, OddsChangeInfoV2> oddsChanges;

  final bool isLoadingFullMarkets;

  final bool hasFullMarkets;

  final String? fullMarketsError;

  final int sportId;

  final bool eventMissing;

  final bool isResolvingLiveTwin;

  const BetDetailMobileV2State({
    this.isLoading = true,
    this.error,
    this.eventData,
    this.leagueData,
    this.drawers = const [],
    this.currentFilter = MarketFilter.main,
    this.marketGroupKey,
    this.allExpanded = true,
    this.oddsChanges = const {},
    this.isLoadingFullMarkets = false,
    this.hasFullMarkets = false,
    this.fullMarketsError,
    this.sportId = 1,
    this.eventMissing = false,
    this.isResolvingLiveTwin = false,
  });

  bool get isEmptyMarketsBusy =>
      !hasFullMarkets && (isLoadingFullMarkets || isResolvingLiveTwin);

  String get emptyMarketsText {
    if (hasFullMarkets) return 'Không có kèo cược nào';
    if (eventMissing) return 'Trận đã kết thúc hoặc không còn kèo cho phiên này';
    if (fullMarketsError != null) {
      return 'Không tải được kèo cược. Vui lòng thử lại.';
    }
    return 'Kèo tạm khóa — sẽ hiển thị lại trong giây lát';
  }

  Set<int> get _mainMarketIds {
    switch (sportId) {
      case 2:
        return const {200, 201, 202, 203, 204, 205};
      case 3:
        return const {300, 301, 304, 305, 306, 307, 308, 309, 310};
      case 4:
        return const {400, 401, 402, 403};
      case 5:
        return const {500, 509, 510};
      case 6:
        return const {600, 609, 610};
      case 7:
        return const {700, 701, 702, 704, 705, 709, 710, 711, 712};
      default:
        return const {1, 2, 3, 4, 5, 6, 80, 85, 89, 23, 24, 25, 26, 27, 28, 1008, 1009, 1010, 1013};
    }
  }

  Map<MarketFilter, String> get _setTabLabels {
    switch (sportId) {
      case 2:
        return const {
          MarketFilter.set1: 'Q1',
          MarketFilter.set2: 'Q2',
          MarketFilter.set3: 'Q3',
          MarketFilter.set4: 'Q4',
        };
      case 4:
        return const {
          MarketFilter.set1: 'Set 1',
          MarketFilter.set2: 'Set 2',
          MarketFilter.set3: 'Set 3',
          MarketFilter.set4: 'Set 4',
        };
      case 5:
        return const {
          MarketFilter.set1: 'Set 1',
          MarketFilter.set2: 'Set 2',
          MarketFilter.set3: 'Set 3',
          MarketFilter.set4: 'Set 4',
          MarketFilter.set5: 'Set 5',
        };
      case 6:
        return const {
          MarketFilter.set1: 'Ván 1',
          MarketFilter.set2: 'Ván 2',
          MarketFilter.set3: 'Ván 3',
          MarketFilter.set4: 'Ván 4',
          MarketFilter.set5: 'Ván 5',
        };
      case 7:
        return const {};
      default:
        return const {};
    }
  }

  List<BetTabData> get availableTabs {
    final tabs = <BetTabData>[];

    tabs.add(const BetTabData(label: 'Chính', filter: MarketFilter.main));

    if (hasMarketsForFilter(MarketFilter.fullTime)) {
      tabs.add(
        const BetTabData(label: 'Toàn trận', filter: MarketFilter.fullTime),
      );
    }
    if (hasMarketsForFilter(MarketFilter.firstHalf)) {
      tabs.add(
        const BetTabData(label: 'Hiệp 1', filter: MarketFilter.firstHalf),
      );
    }

    if (sportId == 1) {
      if (hasMarketsForFilter(MarketFilter.secondHalf)) {
        tabs.add(
          const BetTabData(label: 'Hiệp 2', filter: MarketFilter.secondHalf),
        );
      }
      if (hasMarketsForFilter(MarketFilter.extraTime)) {
        tabs.add(
          const BetTabData(label: 'Hiệp phụ', filter: MarketFilter.extraTime),
        );
      }
      if (hasMarketsForFilter(MarketFilter.corner)) {
        tabs.add(
          const BetTabData(label: 'Phạt góc', filter: MarketFilter.corner),
        );
      }
      if (hasMarketsForFilter(MarketFilter.score)) {
        tabs.add(
          const BetTabData(label: 'Tỷ số', filter: MarketFilter.score),
        );
      }
      if (hasMarketsForFilter(MarketFilter.booking)) {
        tabs.add(
          const BetTabData(label: 'Thẻ phạt', filter: MarketFilter.booking),
        );
      }
      if (hasMarketsForFilter(MarketFilter.player)) {
        tabs.add(
          const BetTabData(label: 'Cầu thủ', filter: MarketFilter.player),
        );
      }
      if (hasMarketsForFilter(MarketFilter.keoRung5)) {
        tabs.add(
          const BetTabData(label: 'Kèo rung 5 phút', filter: MarketFilter.keoRung5),
        );
      }
      if (hasMarketsForFilter(MarketFilter.keoRung10)) {
        tabs.add(
          const BetTabData(label: 'Kèo rung 10 phút', filter: MarketFilter.keoRung10),
        );
      }
      if (hasMarketsForFilter(MarketFilter.keoRung15)) {
        tabs.add(
          const BetTabData(label: 'Kèo rung 15 phút', filter: MarketFilter.keoRung15),
        );
      }
    }

    final tabLabels = _setTabLabels;
    for (final entry in tabLabels.entries) {
      if (hasMarketsForFilter(entry.key)) {
        tabs.add(BetTabData(label: entry.value, filter: entry.key));
      }
    }

    return tabs;
  }

  static const Set<MarketFilter> _setFilters = {
    MarketFilter.set1,
    MarketFilter.set2,
    MarketFilter.set3,
    MarketFilter.set4,
    MarketFilter.set5,
  };

  List<MarketDrawerDataV2> get _periodDrawers => periodDrawersFor(currentFilter);

  List<MarketDrawerDataV2> periodDrawersFor(MarketFilter filter) {
    if (filter == MarketFilter.all) {
      return drawers;
    }

    if (filter == MarketFilter.main) {
      return drawers.where((d) {
        final marketId = d.marketId;
        if (_mainMarketIds.contains(marketId) ||
            (d.market != null &&
                _mainMarketIds.contains(d.market!.marketId))) {
          return true;
        }
        if (sportId != 1 && _setFilters.contains(d.filter)) {
          return true;
        }
        return false;
      }).toList();
    }

    return drawers.where((d) => d.filter == filter).toList();
  }

  List<MarketDrawerDataV2> get filteredDrawers {
    final periodDrawers = _periodDrawers;
    final key = marketGroupKey;
    if (key == null) return periodDrawers;
    return periodDrawers
        .where((d) => _marketGroupOf(d).name == key)
        .toList();
  }

  static MarketGroup _marketGroupOf(MarketDrawerDataV2 d) {
    final lower = d.name.toLowerCase();
    if (lower.contains('đội nhà')) return MarketGroup.homeTeam;
    if (lower.contains('đội khách')) return MarketGroup.awayTeam;
    switch (d.layoutType) {
      case MarketLayoutTypeV2.oneXTwo:
        return MarketGroup.oneXTwo;
      case MarketLayoutTypeV2.handicap:
      case MarketLayoutTypeV2.europeanHandicap:
        return MarketGroup.handicap;
      case MarketLayoutTypeV2.overUnder:
      case MarketLayoutTypeV2.teamOverUnder:
      case MarketLayoutTypeV2.overExactlyUnder:
        return MarketGroup.overUnder;
      case MarketLayoutTypeV2.oddEven:
        return MarketGroup.oddEven;
      case MarketLayoutTypeV2.doubleChance:
        return MarketGroup.doubleChance;
      case MarketLayoutTypeV2.drawNoBet:
        return MarketGroup.drawNoBet;
      case MarketLayoutTypeV2.cleanSheet:
        return MarketGroup.cleanSheet;
      case MarketLayoutTypeV2.correctScore:
        return MarketGroup.correctScore;
      case MarketLayoutTypeV2.totalScore:
        return MarketGroup.totalScore;
      case MarketLayoutTypeV2.playerGoalscorer:
        return MarketGroup.player;
      case MarketLayoutTypeV2.teamWinner:
      case MarketLayoutTypeV2.nextLastGoal:
      case MarketLayoutTypeV2.whichTeamToScore:
      case MarketLayoutTypeV2.halfTimeFullTime:
      case MarketLayoutTypeV2.combo:
        return MarketGroup.other;
    }
  }

  String _groupLabel(MarketGroup g) {
    switch (g) {
      case MarketGroup.oneXTwo:
        return '1X2';
      case MarketGroup.handicap:
        return 'Chấp';
      case MarketGroup.overUnder:
        return 'Tài/Xỉu';
      case MarketGroup.oddEven:
        return 'Lẻ/Chẵn';
      case MarketGroup.doubleChance:
        return 'Cơ hội kép';
      case MarketGroup.drawNoBet:
        return 'Hòa hoàn tiền';
      case MarketGroup.cleanSheet:
        return 'Giữ sạch lưới';
      case MarketGroup.correctScore:
        return 'Tỷ số chính xác';
      case MarketGroup.totalScore:
        return currentFilter == MarketFilter.corner
            ? 'Tổng phạt góc'
            : 'Tổng bàn thắng';
      case MarketGroup.player:
        return 'Cầu thủ';
      case MarketGroup.other:
        return 'Khác';
      case MarketGroup.homeTeam:
        final n = eventData?.homeName ?? '';
        return n.isNotEmpty ? n : 'Đội nhà';
      case MarketGroup.awayTeam:
        final n = eventData?.awayName ?? '';
        return n.isNotEmpty ? n : 'Đội khách';
    }
  }

  static const List<MarketGroup> _groupOrder = [
    MarketGroup.oneXTwo,
    MarketGroup.handicap,
    MarketGroup.overUnder,
    MarketGroup.oddEven,
    MarketGroup.doubleChance,
    MarketGroup.drawNoBet,
    MarketGroup.cleanSheet,
    MarketGroup.homeTeam,
    MarketGroup.awayTeam,
    MarketGroup.correctScore,
    MarketGroup.totalScore,
    MarketGroup.player,
    MarketGroup.other,
  ];

  List<MarketGroupChip> get availableGroups {
    final present = <MarketGroup>{};
    for (final d in _periodDrawers) {
      present.add(_marketGroupOf(d));
    }
    if (present.isEmpty) return const [];
    final chips = <MarketGroupChip>[
      const MarketGroupChip(key: null, label: 'Tất cả'),
    ];
    for (final g in _groupOrder) {
      if (present.contains(g)) {
        chips.add(MarketGroupChip(key: g.name, label: _groupLabel(g)));
      }
    }
    return chips;
  }

  String get groupFilterSignature =>
      availableGroups.map((c) => c.label).join('|');

  bool hasMarketsForFilter(MarketFilter filter) {
    if (filter == MarketFilter.all) {
      return drawers.isNotEmpty;
    }

    if (filter == MarketFilter.main) {
      return drawers.any((d) {
        if (_mainMarketIds.contains(d.marketId) ||
            (d.market != null &&
                _mainMarketIds.contains(d.market!.marketId))) {
          return true;
        }
        if (sportId != 1 && _setFilters.contains(d.filter)) {
          return true;
        }
        return false;
      });
    }

    return drawers.any((d) => d.filter == filter && !d.isEmpty);
  }

  BetDetailMobileV2State copyWith({
    bool? isLoading,
    String? error,
    LeagueEventData? eventData,
    LeagueData? leagueData,
    List<MarketDrawerDataV2>? drawers,
    MarketFilter? currentFilter,
    Object? marketGroupKey = _noChange,
    bool? allExpanded,
    Map<String, OddsChangeInfoV2>? oddsChanges,
    bool? isLoadingFullMarkets,
    bool? hasFullMarkets,
    String? fullMarketsError,
    int? sportId,
    bool? eventMissing,
    bool? isResolvingLiveTwin,
  }) {
    return BetDetailMobileV2State(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      eventData: eventData ?? this.eventData,
      leagueData: leagueData ?? this.leagueData,
      drawers: drawers ?? this.drawers,
      currentFilter: currentFilter ?? this.currentFilter,
      marketGroupKey: identical(marketGroupKey, _noChange)
          ? this.marketGroupKey
          : marketGroupKey as String?,
      allExpanded: allExpanded ?? this.allExpanded,
      oddsChanges: oddsChanges ?? this.oddsChanges,
      isLoadingFullMarkets: isLoadingFullMarkets ?? this.isLoadingFullMarkets,
      hasFullMarkets: hasFullMarkets ?? this.hasFullMarkets,
      fullMarketsError: fullMarketsError,
      sportId: sportId ?? this.sportId,
      eventMissing: eventMissing ?? this.eventMissing,
      isResolvingLiveTwin: isResolvingLiveTwin ?? this.isResolvingLiveTwin,
    );
  }
}

class OddsChangeInfoV2 {
  final double previousValue;
  final double currentValue;
  final OddsChangeDirectionV2 direction;
  final DateTime changeTime;

  const OddsChangeInfoV2({
    required this.previousValue,
    required this.currentValue,
    required this.direction,
    required this.changeTime,
  });
}

enum OddsChangeDirectionV2 { up, down, none }

class BetDetailMobileV2Notifier extends StateNotifier<BetDetailMobileV2State> {
  final Ref _ref;
  StreamSubscription<socket.OddsUpdateData>? _oddsSubscription;
  StreamSubscription<socket.EventStatusData>? _eventUpdateSubscription;
  Timer? _cleanupTimer;
  int? _currentEventId;
  int _currentSet = 1;
  CancelToken? _fullMarketsCancelToken;

  DateTime? _lastFullMarketsRefreshAt;
  static const Duration _refreshFullMarketsCooldown = Duration(seconds: 2);

  bool _twinLookupDone = false;

  int? _twinTargetEventId;

  CancelToken? _liveTwinCancelToken;

  int _oddsBufferDepth = 0;
  final List<socket.OddsUpdateData> _pendingOddsDuringFetch = [];

  DateTime? _lastStructureCheckAt;
  static const _structureCheckThrottle = Duration(seconds: 5);

  void _maybeRefetchOnStructureDrift() {
    final eventId = _currentEventId;
    if (eventId == null) return;
    final now = DateTime.now();
    if (_lastStructureCheckAt != null &&
        now.difference(_lastStructureCheckAt!) < _structureCheckThrottle) {
      return;
    }
    _lastStructureCheckAt = now;

    final restCount = state.eventData?.markets.length ?? 0;
    final storeCount =
        _ref.read(sportSocketAdapterProvider).marketCountOf(eventId);
    if (storeCount > restCount) {
      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] Structure drift: store=$storeCount > '
        'rest=$restCount — refetch để mọc drawer kèo mở-muộn',
      );
      unawaited(refreshFullMarkets());
    }
  }

  bool _awaitingMarketsReopen = false;

  static const _maxPendingOdds = 1000;

  void _replayBufferedOddsIfIdle() {
    if (!mounted) {
      _pendingOddsDuringFetch.clear();
      return;
    }
    if (_oddsBufferDepth > 0) return;
    if (_pendingOddsDuringFetch.isEmpty) return;
    final pending =
        List<socket.OddsUpdateData>.from(_pendingOddsDuringFetch);
    _pendingOddsDuringFetch.clear();
    for (final d in pending) {
      _handleOddsUpdate(d);
    }
  }

  late final bool _useStoreDetail = _ref.read(useStoreDetailProvider);
  StreamSubscription<socket.DataChangeEvent>? _storeSignalSubscription;

  Timer? _storeWatchdog;
  late final Duration _storeWatchdogGap = _readWatchdogGap();
  static final _log = AppLogger(tag: 'BetDetailStoreMode');

  static final _twinLog = AppLogger(tag: 'BetDetailLiveTwin');

  static Duration _readWatchdogGap() {
    final raw = SbConfig.instance.mainConfig['store_detail_watchdog_secs'];
    if (raw is int && raw >= 10) return Duration(seconds: raw);
    return const Duration(seconds: 60);
  }

  void _subscribeToStoreSignal(int eventId) {
    _storeSignalSubscription?.cancel();
    final adapter = _ref.read(sportSocketAdapterProvider);
    _storeSignalSubscription = adapter.onStoreChanged.listen((e) {
      if (!mounted || _currentEventId != eventId) return;
      if (!_affectsDetailEvent(e, eventId)) return;
      _armStoreWatchdog(eventId);
      _rebuildFromStore(eventId);
    });
    _armStoreWatchdog(eventId);
  }

  bool _affectsDetailEvent(socket.DataChangeEvent e, int eventId) {
    if (e.affectsEvent(eventId)) return true;
    final prefix = '${eventId}_';
    bool any(Iterable<String> keys) => keys.any((k) => k.startsWith(prefix));
    return any(e.updatedMarketKeys) ||
        any(e.addedMarketKeys) ||
        any(e.removedMarketKeys) ||
        any(e.updatedOddsKeys) ||
        any(e.addedOddsKeys) ||
        any(e.removedOddsKeys);
  }

  void _rebuildFromStore(int eventId) {
    if (!mounted || _currentEventId != eventId) return;
    final v2 =
        _ref.read(sportSocketAdapterProvider).buildDetailEventV2(eventId);
    if (v2 == null) return;
    final fullEventData = v2.toLegacy();

    if (fullEventData.markets.isEmpty) {
      state = state.copyWith(drawers: const [], hasFullMarkets: false);
      return;
    }

    final currentEventData = state.eventData;
    final mergedEventData =
        currentEventData?.copyWith(
          markets: fullEventData.markets,
          totalMarketsCount: fullEventData.totalMarketsCount,
          eventStatsId: currentEventData.eventStatsId > 0
              ? currentEventData.eventStatsId
              : fullEventData.eventStatsId,
          homeLogoFirst: _backfillLogo(
            currentEventData.homeLogoFirst,
            fullEventData.homeLogoFirst ?? '',
          ),
          awayLogoFirst: _backfillLogo(
            currentEventData.awayLogoFirst,
            fullEventData.awayLogoFirst ?? '',
          ),
        ) ??
        fullEventData;

    var drawers = MarketDrawerV2Builder.buildDrawers(
      mergedEventData.markets,
      sportId: state.sportId,
      currentSet: _currentSet,
      currentMinute: mergedEventData.continuousMatchMinute,
    );
    final oldExpanded = <int, bool>{
      for (final d in state.drawers) d.marketId: d.isExpanded,
    };
    drawers = drawers
        .map(
          (d) => oldExpanded.containsKey(d.marketId)
              ? d.copyWith(isExpanded: oldExpanded[d.marketId])
              : d,
        )
        .toList();

    state = state.copyWith(
      eventData: mergedEventData,
      drawers: drawers,
      hasFullMarkets: true,
      fullMarketsError: null,
    );
  }

  void _armStoreWatchdog(int eventId) {
    _storeWatchdog?.cancel();
    if (!_useStoreDetail) return;
    _storeWatchdog = Timer(_storeWatchdogGap, () {
      if (!mounted || _currentEventId != eventId) return;
      if (state.eventData?.isLive != true) {
        _armStoreWatchdog(eventId);
        return;
      }
      _log.w(
        'Watchdog: detail-channel im ${_storeWatchdogGap.inSeconds}s cho '
        'event LIVE $eventId — re-SUBSCRIBE + REST reconcile',
      );
      _ref.read(sportSocketAdapterProvider).resubscribeDetail(eventId);
      unawaited(refreshFullMarkets());
      _armStoreWatchdog(eventId);
    });
  }

  void _trackOddsDirections(socket.OddsUpdateData update) {
    final odds = update.odds;
    final newOddsChanges = Map<String, OddsChangeInfoV2>.from(
      state.oddsChanges,
    );
    var changed = false;

    if (odds.selectionIdHome != null &&
        odds.homeDirection != socket.OddsDirection.none &&
        odds.oddsHome != null &&
        odds.previousHome != null) {
      newOddsChanges[odds.selectionIdHome!] = OddsChangeInfoV2(
        previousValue: odds.previousHome!,
        currentValue: odds.oddsHome!,
        direction: _mapDirection(odds.homeDirection),
        changeTime: DateTime.now(),
      );
      changed = true;
    }
    if (odds.selectionIdAway != null &&
        odds.awayDirection != socket.OddsDirection.none &&
        odds.oddsAway != null &&
        odds.previousAway != null) {
      newOddsChanges[odds.selectionIdAway!] = OddsChangeInfoV2(
        previousValue: odds.previousAway!,
        currentValue: odds.oddsAway!,
        direction: _mapDirection(odds.awayDirection),
        changeTime: DateTime.now(),
      );
      changed = true;
    }
    if (odds.selectionIdDraw != null &&
        odds.drawDirection != socket.OddsDirection.none &&
        odds.oddsDraw != null &&
        odds.previousDraw != null) {
      newOddsChanges[odds.selectionIdDraw!] = OddsChangeInfoV2(
        previousValue: odds.previousDraw!,
        currentValue: odds.oddsDraw!,
        direction: _mapDirection(odds.drawDirection),
        changeTime: DateTime.now(),
      );
      changed = true;
    }

    if (changed) {
      state = state.copyWith(oddsChanges: newOddsChanges);
    }
  }

  BetDetailMobileV2Notifier(this._ref) : super(const BetDetailMobileV2State());

  void init({
    required LeagueEventData eventData,
    required LeagueData leagueData,
    int sportId = 1,
    int currentSet = 1,
  }) {
    if (_currentEventId == eventData.eventId &&
        state.eventData != null &&
        (state.hasFullMarkets || state.isLoadingFullMarkets)) {
      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] Already initialized (full) for event ${eventData.eventId}, skipping',
      );
      return;
    }

    // ignore: avoid_debugPrint
    debugPrint(
      '[BetDetailMobileV2Provider] init() called for event ${eventData.eventId}',
    );
    // ignore: avoid_debugPrint
    debugPrint(
      '[BetDetailMobileV2Provider] Partial markets count: ${eventData.markets.length}',
    );

    final drawers = MarketDrawerV2Builder.buildDrawers(
      eventData.markets,
      sportId: sportId,
      currentSet: currentSet,
      currentMinute: eventData.continuousMatchMinute,
    );
    _currentEventId = eventData.eventId;
    _currentSet = currentSet;

    final isTwinTarget = eventData.eventId == _twinTargetEventId;
    _twinTargetEventId = null;
    _twinLookupDone = isTwinTarget;
    _liveTwinCancelToken?.cancel();
    _liveTwinCancelToken = null;

    state = state.copyWith(
      eventData: eventData,
      leagueData: leagueData,
      drawers: drawers,
      isLoading: false,
      isLoadingFullMarkets: true,
      hasFullMarkets: false,
      error: null,
      sportId: sportId,
      currentFilter: MarketFilter.main,
      marketGroupKey: null,
      eventMissing: false,
      isResolvingLiveTwin: false,
    );

    _subscribeToOddsUpdates(eventData.eventId);
    _subscribeToEventUpdates(eventData.eventId);
    if (_useStoreDetail) _subscribeToStoreSignal(eventData.eventId);
    _startCleanupTimer();

    // ignore: avoid_debugPrint
    debugPrint(
      '[BetDetailMobileV2Provider] Starting _loadFullMarkets for event ${eventData.eventId}',
    );
    _loadFullMarkets(eventData.eventId);
  }

  int _resolveDetailStatsId(EventDetailResponseV2 response) {
    if (response.eventStatsId > 0) return response.eventStatsId;
    for (final child in response.children) {
      final fromChild = _resolveDetailStatsId(child);
      if (fromChild > 0) return fromChild;
    }
    return 0;
  }

  (String, String) _resolveDetailLogos(EventDetailResponseV2 response) {
    if (response.homeLogo.isNotEmpty || response.awayLogo.isNotEmpty) {
      return (response.homeLogo, response.awayLogo);
    }
    for (final child in response.children) {
      final fromChild = _resolveDetailLogos(child);
      if (fromChild.$1.isNotEmpty || fromChild.$2.isNotEmpty) return fromChild;
    }
    return ('', '');
  }

  String? _backfillLogo(String? current, String detail) {
    if (current != null && current.isNotEmpty) return current;
    return detail.isNotEmpty ? detail : current;
  }

  Future<void> refreshFullMarkets() async {
    final eventId = _currentEventId;
    if (eventId == null) return;
    if (state.isLoadingFullMarkets) return;
    final last = _lastFullMarketsRefreshAt;
    if (last != null &&
        DateTime.now().difference(last) < _refreshFullMarketsCooldown) {
      return;
    }
    try {
      await _loadFullMarkets(eventId, preserveExpanded: true);
    } finally {
      _lastFullMarketsRefreshAt = DateTime.now();
    }
  }

  Future<void> _loadFullMarkets(int eventId, {bool preserveExpanded = false}) async {
    // ignore: avoid_debugPrint
    debugPrint(
      '[BetDetailMobileV2Provider] _loadFullMarkets() START for event $eventId',
    );
    _oddsBufferDepth++;

    try {
      _fullMarketsCancelToken?.cancel();
      _fullMarketsCancelToken = CancelToken();

      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] Calling API getEventDetailWithCancel...',
      );

      final dataSource = _ref.read(eventDetailV2RemoteDataSourceProvider);
      final response = await dataSource.getEventDetailWithCancel(
        eventId,
        _fullMarketsCancelToken!,
      );

      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] API response received: ${response.markets.length} markets, ${response.children.length} children',
      );

      if (!_responseHasEvent(response, eventId)) {
        final willResolve = !_twinLookupDone;
        state = state.copyWith(
          isLoadingFullMarkets: false,
          hasFullMarkets: false,
          fullMarketsError: null,
          eventMissing: true,
          isResolvingLiveTwin: willResolve,
        );
        if (willResolve) {
          _twinLookupDone = true;
          unawaited(_resolveLiveTwin(eventId));
        }
        _twinLog.w(
          'Event $eventId absent from /events/{id} response — retired id, '
          'live-twin lookup ${willResolve ? 'started' : 'already spent'}',
        );
        return;
      }

      final fullEventData = response.toLeagueEventData();

      final detailStatsId = _resolveDetailStatsId(response);

      final (detailHomeLogo, detailAwayLogo) = _resolveDetailLogos(response);

      if (fullEventData.markets.isEmpty) {
        _awaitingMarketsReopen = true;
        final cur = state.eventData;
        final eventDataWithStats = cur?.copyWith(
          eventStatsId: (cur.eventStatsId <= 0 && detailStatsId > 0)
              ? detailStatsId
              : cur.eventStatsId,
          homeLogoFirst: _backfillLogo(cur.homeLogoFirst, detailHomeLogo),
          awayLogoFirst: _backfillLogo(cur.awayLogoFirst, detailAwayLogo),
        );
        state = state.copyWith(
          eventData: eventDataWithStats,
          isLoadingFullMarkets: false,
          hasFullMarkets: false,
          fullMarketsError: null,
          eventMissing: false,
          isResolvingLiveTwin: false,
        );
        // ignore: avoid_debugPrint
        debugPrint(
          '[BetDetailMobileV2Provider] Full markets EMPTY (cửa sổ goal?) — '
          'giữ ${state.drawers.length} drawers, chờ socket-evidence để refetch',
        );
        return;
      }
      _awaitingMarketsReopen = false;

      final currentEventData = state.eventData;
      final mergedEventData =
          currentEventData?.copyWith(
            markets: fullEventData.markets,
            totalMarketsCount: fullEventData.totalMarketsCount,
            eventStatsId: currentEventData.eventStatsId > 0
                ? currentEventData.eventStatsId
                : detailStatsId,
            homeLogoFirst: _backfillLogo(
              currentEventData.homeLogoFirst,
              detailHomeLogo,
            ),
            awayLogoFirst: _backfillLogo(
              currentEventData.awayLogoFirst,
              detailAwayLogo,
            ),
          ) ??
          fullEventData;

      var fullDrawers = MarketDrawerV2Builder.buildDrawers(
        mergedEventData.markets,
        sportId: state.sportId,
        currentSet: _currentSet,
        currentMinute: mergedEventData.continuousMatchMinute,
      );

      if (preserveExpanded) {
        final oldExpanded = <int, bool>{
          for (final d in state.drawers) d.marketId: d.isExpanded,
        };
        fullDrawers = fullDrawers
            .map(
              (d) => oldExpanded.containsKey(d.marketId)
                  ? d.copyWith(isExpanded: oldExpanded[d.marketId])
                  : d,
            )
            .toList();
      }

      state = state.copyWith(
        eventData: mergedEventData,
        drawers: fullDrawers,
        isLoadingFullMarkets: false,
        hasFullMarkets: true,
        fullMarketsError: null,
        eventMissing: false,
        isResolvingLiveTwin: false,
      );

      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] Full markets loaded: ${fullEventData.markets.length} markets',
      );

      if (_useStoreDetail) _rebuildFromStore(eventId);
    } on CancelledException {
      // ignore: avoid_debugPrint
      debugPrint('[BetDetailMobileV2Provider] Full markets request cancelled');
      return;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: e.message,
      );

      // ignore: avoid_debugPrint
      debugPrint('[BetDetailMobileV2Provider] API error loading full markets: $e');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // ignore: avoid_debugPrint
        debugPrint(
          '[BetDetailMobileV2Provider] Full markets request cancelled (DioException)',
        );
        return;
      }

      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: e.message ?? 'Failed to load full markets',
      );

      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] DioException loading full markets: $e',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: 'Failed to load full markets: $e',
      );

      // ignore: avoid_debugPrint
      debugPrint(
        '[BetDetailMobileV2Provider] Unknown error loading full markets: $e',
      );
    } finally {
      _oddsBufferDepth--;
      _replayBufferedOddsIfIdle();
    }
  }

  bool _responseHasEvent(EventDetailResponseV2 response, int eventId) {
    if (response.eventId == eventId) return true;
    for (final child in response.children) {
      if (_responseHasEvent(child, eventId)) return true;
    }
    return false;
  }

  Future<void> _resolveLiveTwin(int deadEventId) async {
    final seed = _ref.read(selectedEventV2Provider);
    if (seed == null || seed.eventId != deadEventId) {
      _finishTwinLookup(deadEventId);
      return;
    }
    final homeId = seed.homeId;
    final awayId = seed.awayId;
    final sportId = seed.sportId > 0 ? seed.sportId : state.sportId;
    if (homeId <= 0 || awayId <= 0) {
      _twinLog.w(
        'Dead event $deadEventId has no team ids on the seed — cannot look up '
        'a live twin',
      );
      _finishTwinLookup(deadEventId);
      return;
    }
    final startAt = _startInstant(seed);

    final adapter = _ref.read(sportSocketAdapterProvider);
    var hit = adapter.lastPopulateSportId == sportId &&
            adapter.lastPopulateTimeRange == socket.TimeRange.live
        ? _findTwin(
            adapter.buildV2Leagues(sportId),
            deadEventId: deadEventId,
            homeId: homeId,
            awayId: awayId,
            startAt: startAt,
          )
        : null;

    if (hit == null) {
      final token = CancelToken();
      _liveTwinCancelToken?.cancel();
      _liveTwinCancelToken = token;
      List<LeagueModelV2> leagues;
      try {
        leagues = await _ref
            .read(eventsV2RepositoryProvider)
            .getEventsWithCancel(EventsRequestModel.live(sportId), token);
      } on CancelledException {
        return;
      } catch (e) {
        _twinLog.w('Live-twin lookup failed for dead event $deadEventId: $e');
        _finishTwinLookup(deadEventId, error: 'live twin lookup failed: $e');
        return;
      }
      if (!mounted || _currentEventId != deadEventId) return;
      hit = _findTwin(
        leagues,
        deadEventId: deadEventId,
        homeId: homeId,
        awayId: awayId,
        startAt: startAt,
      );
    }

    if (hit == null) {
      _twinLog.w(
        'No live twin for dead event $deadEventId '
        '(sport=$sportId home=$homeId away=$awayId)',
      );
      _finishTwinLookup(deadEventId);
      return;
    }
    final (twin, twinLeague) = hit;
    if (!mounted || _currentEventId != deadEventId) return;
    _twinLog.i('Dead event $deadEventId -> live twin ${twin.eventId}');

    state = state.copyWith(eventMissing: false, isResolvingLiveTwin: true);
    _twinTargetEventId = twin.eventId;
    _ref.read(selectedEventV2Provider.notifier).state = twin;
    _ref.read(selectedLeagueV2Provider.notifier).state = twinLeague.copyWith(
      events: const [],
      sportId: sportId,
    );
  }

  void _finishTwinLookup(int deadEventId, {String? error}) {
    if (!mounted || _currentEventId != deadEventId) return;
    state = state.copyWith(
      isResolvingLiveTwin: false,
      eventMissing: error == null,
      fullMarketsError: error,
    );
  }

  (EventModelV2, LeagueModelV2)? _findTwin(
    List<LeagueModelV2> leagues, {
    required int deadEventId,
    required int homeId,
    required int awayId,
    DateTime? startAt,
  }) {
    final hits = <(EventModelV2, LeagueModelV2)>[];
    for (final league in leagues) {
      for (final event in league.events) {
        if (event.eventId <= 0 || event.eventId == deadEventId) continue;
        if (event.homeId == homeId && event.awayId == awayId) {
          hits.add((event, league));
        }
      }
    }
    if (hits.isEmpty) return null;
    if (hits.length == 1) return hits.first;
    if (startAt == null) return null;
    hits.sort(
      (a, b) => _startGap(a.$1, startAt).compareTo(_startGap(b.$1, startAt)),
    );
    final best = _startGap(hits.first.$1, startAt);
    if (best == _unknownStartGap) return null;
    if (_startGap(hits[1].$1, startAt) == best) return null;
    return hits.first;
  }

  static const int _unknownStartGap = 1 << 40;

  int _startGap(EventModelV2 event, DateTime target) {
    final start = _startInstant(event);
    if (start == null) return _unknownStartGap;
    return start.difference(target).inSeconds.abs();
  }

  DateTime? _startInstant(EventModelV2 event) {
    if (event.startTime > 0) {
      return DateTime.fromMillisecondsSinceEpoch(event.startTime, isUtc: true);
    }
    if (event.startDate.isNotEmpty) {
      return DateTime.tryParse(event.startDate)?.toUtc();
    }
    return null;
  }

  void changeFilter(MarketFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter, marketGroupKey: null);
    }
  }

  void changeMarketGroup(String? key) {
    if (state.marketGroupKey != key) {
      state = state.copyWith(marketGroupKey: key);
    }
  }

  void toggleAllExpanded() {
    final newExpanded = !state.allExpanded;
    final updatedDrawers = state.drawers
        .map((d) => d.copyWith(isExpanded: newExpanded))
        .toList();
    state = state.copyWith(allExpanded: newExpanded, drawers: updatedDrawers);
  }

  void toggleDrawer(int filteredIndex) {
    final filtered = state.filteredDrawers;
    if (filteredIndex < 0 || filteredIndex >= filtered.length) return;

    final targetDrawer = filtered[filteredIndex];
    final actualIndex = state.drawers.indexOf(targetDrawer);
    if (actualIndex == -1) return;

    final updatedDrawers = List<MarketDrawerDataV2>.from(state.drawers);
    updatedDrawers[actualIndex] = updatedDrawers[actualIndex].copyWith(
      isExpanded: !updatedDrawers[actualIndex].isExpanded,
    );
    state = state.copyWith(drawers: updatedDrawers);
  }

  void _subscribeToOddsUpdates(int eventId) {
    _oddsSubscription?.cancel();
    _currentEventId = eventId;

    try {
      final adapter = _ref.read(sportSocketAdapterProvider);

      _oddsSubscription = adapter.onOddsUpdate.listen((data) {
        if (data.eventId == eventId) {
          if (_useStoreDetail) {
            _trackOddsDirections(data);
            return;
          }
          if (_awaitingMarketsReopen) {
            _awaitingMarketsReopen = false;
            unawaited(refreshFullMarkets());
          }
          _maybeRefetchOnStructureDrift();
          if (_oddsBufferDepth > 0) {
            if (_pendingOddsDuringFetch.length >= _maxPendingOdds) {
              _pendingOddsDuringFetch.removeAt(0);
            }
            _pendingOddsDuringFetch.add(data);
            return;
          }
          _handleOddsUpdate(data);
        }
      });

    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileV2Provider] Error subscribing to odds updates: $e',
        );
      }
    }
  }

  void _subscribeToEventUpdates(int eventId) {
    _eventUpdateSubscription?.cancel();

    try {
      final adapter = _ref.read(sportSocketAdapterProvider);

      _eventUpdateSubscription = adapter.onEventStatusUpdate.listen((data) {
        if (data.eventId == eventId) {
          if (!_useStoreDetail) {
            if (_awaitingMarketsReopen) {
              _awaitingMarketsReopen = false;
              unawaited(refreshFullMarkets());
            }
            _maybeRefetchOnStructureDrift();
          }
          _handleEventStatusUpdate(data);
        }
      });

    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileV2Provider] Error subscribing to event updates: $e',
        );
      }
    }
  }

  void _handleEventStatusUpdate(socket.EventStatusData data) {
    final eventData = state.eventData;
    if (eventData == null) return;
    if (data.eventId != eventData.eventId) return;

    final gamePart = data.gamePart ?? eventData.gamePart;
    final effectiveSuspended = data.isSuspended &&
        (gamePart < GamePart.finished.value ||
            !eventData.markets.any(
              (m) => m.odds.any((o) => !o.isSuspended),
            ));

    final updatedEventData = eventData.copyWith(
      gameTime: data.gameTime ?? eventData.gameTime,
      gamePart: data.gamePart ?? eventData.gamePart,
      stoppageTime: data.stoppageTime ?? eventData.stoppageTime,
      homeScore: data.homeScore ?? eventData.homeScore,
      awayScore: data.awayScore ?? eventData.awayScore,
      isLive: data.isLive ?? eventData.isLive,
      yellowCardsHome: data.yellowCardsHome ?? eventData.yellowCardsHome,
      yellowCardsAway: data.yellowCardsAway ?? eventData.yellowCardsAway,
      redCardsHome: data.redCardsHome ?? eventData.redCardsHome,
      redCardsAway: data.redCardsAway ?? eventData.redCardsAway,
      cornersHome: data.cornersHome ?? eventData.cornersHome,
      cornersAway: data.cornersAway ?? eventData.cornersAway,
      isSuspended: effectiveSuspended,
      isLivestream: data.isLivestream ?? eventData.isLivestream,
      eventStatus: data.eventStatus ?? eventData.eventStatus,
    );

    state = state.copyWith(eventData: updatedEventData);

    if (state.sportId == 7 &&
        data.gamePart != null &&
        data.gamePart != eventData.gamePart) {
      _loadFullMarkets(eventData.eventId);
    }
  }

  void _handleOddsUpdate(socket.OddsUpdateData update) {
    final eventData = state.eventData;
    if (eventData == null) return;
    if (update.eventId != eventData.eventId) return;

    final updatedDrawers = _updateOddsInDrawers(state.drawers, update);

    if (updatedDrawers != null) {
      final newOddsChanges = Map<String, OddsChangeInfoV2>.from(
        state.oddsChanges,
      );
      final odds = update.odds;

      if (odds.selectionIdHome != null &&
          odds.homeDirection != socket.OddsDirection.none &&
          odds.oddsHome != null &&
          odds.previousHome != null) {
        newOddsChanges[odds.selectionIdHome!] = OddsChangeInfoV2(
          previousValue: odds.previousHome!,
          currentValue: odds.oddsHome!,
          direction: _mapDirection(odds.homeDirection),
          changeTime: DateTime.now(),
        );
      }

      if (odds.selectionIdAway != null &&
          odds.awayDirection != socket.OddsDirection.none &&
          odds.oddsAway != null &&
          odds.previousAway != null) {
        newOddsChanges[odds.selectionIdAway!] = OddsChangeInfoV2(
          previousValue: odds.previousAway!,
          currentValue: odds.oddsAway!,
          direction: _mapDirection(odds.awayDirection),
          changeTime: DateTime.now(),
        );
      }

      if (odds.selectionIdDraw != null &&
          odds.drawDirection != socket.OddsDirection.none &&
          odds.oddsDraw != null &&
          odds.previousDraw != null) {
        newOddsChanges[odds.selectionIdDraw!] = OddsChangeInfoV2(
          previousValue: odds.previousDraw!,
          currentValue: odds.oddsDraw!,
          direction: _mapDirection(odds.drawDirection),
          changeTime: DateTime.now(),
        );
      }

      state = state.copyWith(
        drawers: updatedDrawers,
        oddsChanges: newOddsChanges,
      );
    }
  }

  OddsChangeDirectionV2 _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirectionV2.up;
      case socket.OddsDirection.down:
        return OddsChangeDirectionV2.down;
      case socket.OddsDirection.none:
        return OddsChangeDirectionV2.none;
    }
  }

  List<MarketDrawerDataV2>? _updateOddsInDrawers(
    List<MarketDrawerDataV2> drawers,
    socket.OddsUpdateData update,
  ) {
    final marketId = update.marketId;
    final odds = update.odds;
    bool updated = false;

    final updatedDrawers = drawers.map((drawer) {
      if (drawer.market != null && drawer.market!.marketId == marketId) {
        final updatedOdds = drawer.market!.odds.map((drawerOdds) {
          if (drawerOdds.offerId == update.offerId) {
            updated = true;
            return _updateOddsDataFromLibrary(drawerOdds, odds);
          }
          return drawerOdds;
        }).toList();

        return drawer.copyWith(
          market: LeagueMarketData(
            marketId: drawer.market!.marketId,
            marketName: drawer.market!.marketName,
            marketType: drawer.market!.marketType,
            isParlay: drawer.market!.isParlay,
            odds: updatedOdds,
          ),
        );
      }

      if (drawer.markets.isNotEmpty) {
        final updatedMarkets = drawer.markets.map((market) {
          if (market.marketId != marketId) return market;

          final updatedOdds = market.odds.map((drawerOdds) {
            if (drawerOdds.offerId == update.offerId) {
              updated = true;
              return _updateOddsDataFromLibrary(drawerOdds, odds);
            }
            return drawerOdds;
          }).toList();

          return LeagueMarketData(
            marketId: market.marketId,
            marketName: market.marketName,
            marketType: market.marketType,
            isParlay: market.isParlay,
            odds: updatedOdds,
          );
        }).toList();

        return drawer.copyWith(markets: updatedMarkets);
      }

      return drawer;
    }).toList();

    return updated ? updatedDrawers : null;
  }

  LeagueOddsData _updateOddsDataFromLibrary(
    LeagueOddsData drawerOdds,
    socket.OddsData libraryOdds,
  ) {
    OddsValue? createOddsValue(
      double? decimal,
      String? malay,
      String? indo,
      String? hk,
    ) {
      if (decimal == null) return null;
      return OddsValue(
        decimal: decimal,
        malay: double.tryParse(malay ?? '') ?? 0,
        indo: double.tryParse(indo ?? '') ?? 0,
        hongKong: double.tryParse(hk ?? '') ?? 0,
      );
    }

    return LeagueOddsData(
      points: drawerOdds.points,
      isMainLine: drawerOdds.isMainLine,
      selectionHomeId: drawerOdds.selectionHomeId,
      selectionAwayId: drawerOdds.selectionAwayId,
      selectionDrawId: drawerOdds.selectionDrawId,
      offerId: drawerOdds.offerId,
      isSuspended: libraryOdds.isSuspended,
      playerName: drawerOdds.playerName,
      playerId: drawerOdds.playerId,
      oddsHome:
          createOddsValue(
            libraryOdds.oddsHome,
            libraryOdds.malayHome,
            libraryOdds.indoHome,
            libraryOdds.hkHome,
          ) ??
          drawerOdds.oddsHome,
      oddsAway:
          createOddsValue(
            libraryOdds.oddsAway,
            libraryOdds.malayAway,
            libraryOdds.indoAway,
            libraryOdds.hkAway,
          ) ??
          drawerOdds.oddsAway,
      oddsDraw: libraryOdds.oddsDraw != null
          ? OddsValue(
              decimal: libraryOdds.oddsDraw!,
              malay: 0,
              indo: 0,
              hongKong: 0,
            )
          : drawerOdds.oddsDraw,
    );
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final expiredKeys = state.oddsChanges.entries
          .where((e) => now.difference(e.value.changeTime).inSeconds >= 5)
          .map((e) => e.key)
          .toList();

      if (expiredKeys.isNotEmpty) {
        final newChanges = Map<String, OddsChangeInfoV2>.from(
          state.oddsChanges,
        );
        for (final key in expiredKeys) {
          newChanges.remove(key);
        }
        state = state.copyWith(oddsChanges: newChanges);
      }
    });
  }

  void clear() {
    _oddsSubscription?.cancel();
    _eventUpdateSubscription?.cancel();
    _storeSignalSubscription?.cancel();
    _storeWatchdog?.cancel();
    _cleanupTimer?.cancel();
    _fullMarketsCancelToken?.cancel();
    _liveTwinCancelToken?.cancel();
    _currentEventId = null;

    if (!mounted) return;
    state = const BetDetailMobileV2State();
  }

  @override
  void dispose() {
    _oddsSubscription?.cancel();
    _eventUpdateSubscription?.cancel();
    _storeSignalSubscription?.cancel();
    _storeWatchdog?.cancel();
    _cleanupTimer?.cancel();
    _fullMarketsCancelToken?.cancel();
    _liveTwinCancelToken?.cancel();
    super.dispose();
  }
}

final useStoreDetailProvider = StateProvider<bool>(
  (ref) => SbConfig.instance.mainConfig['use_store_detail'] == true,
);

final betDetailMobileV2Provider =
    StateNotifierProvider.autoDispose<
      BetDetailMobileV2Notifier,
      BetDetailMobileV2State
    >((ref) {
      return BetDetailMobileV2Notifier(ref);
    });

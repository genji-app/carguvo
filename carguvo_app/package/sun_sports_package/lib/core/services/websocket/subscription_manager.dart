import 'dart:async';
import 'package:sport_socket/sport_socket.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

import 'socket_sub_mode.dart';

class SubscriptionManager {
  static final AppLogger _log = AppLogger(tag: 'SubscriptionManager');

  static SubscriptionManager? _instance;
  static SubscriptionManager? get instance => _instance;

  static const String _listSource = 'sport_list';

  final SportSocketClient _client;

  late final SubscriptionRegistry registry;

  final bool _useV2Protocol;

  int _activeSportId;
  int _activeTimeRange;
  final Set<int> _betSlipSportIds = {};

  Set<MatchListKey> _managedListKeys = {};

  int? _leagueModeStructuralSportId;

  void Function()? onListContextChanged;

  void Function(int timeRange)? onTimeRangeCommitted;

  bool _initialized = false;
  bool _isConnected = false;
  Set<int>? _pendingBetSlipSports;

  final _activeSportController = StreamController<int>.broadcast();
  Stream<int> get onActiveSportChanged => _activeSportController.stream;

  Timer? _timeRangeDebounceTimer;
  static const _debounceDelay = Duration(milliseconds: 200);

  static const String _detailSource = 'detail_swap';

  static const _detailSwapDelay = Duration(milliseconds: 300);
  Timer? _detailDebounce;
  int? _activeDetailEventId;
  bool _listSuspendedForDetail = false;

  bool get isListSuspendedForDetail => _listSuspendedForDetail;

  SubscriptionManager({
    required SportSocketClient client,
    int initialSportId = 1,
    int initialTimeRange = V2TimeRange.live,
    String language = V2SubscriptionHelper.defaultLanguage,
    bool useV2Protocol = false,
  }) : _client = client,
       _useV2Protocol = useV2Protocol,
       _activeSportId = initialSportId,
       _activeTimeRange = initialTimeRange {
    registry = SubscriptionRegistry(send: _client.sendRaw, language: language);
    _instance = this;
  }

  int get activeSportId => _activeSportId;
  int get activeTimeRange => _activeTimeRange;
  String get language => registry.language;
  Set<int> get betSlipSportIds => Set.unmodifiable(_betSlipSportIds);
  Set<int> get subscribedSportIds => _client.subscribedSports;
  Set<String> get subscribedChannels => registry.activeChannels;
  bool get isInitialized => _initialized;

  void init() {
    if (_initialized) return;
    _initialized = true;
    _isConnected = true;

    if (_pendingBetSlipSports != null) {
      _betSlipSportIds.addAll(_pendingBetSlipSports!);
      _pendingBetSlipSports = null;
    }

    if (_useV2Protocol) {
      registry.onConnected();
      _syncSubscriptions();
      _log.d(
        '[SubscriptionManager] ✅ V2 Init complete - '
        'channels: ${registry.activeChannels}',
      );
    } else {
      _client.subscribeSport(1);
      _client.setPrimarySport(_activeSportId);

      final others = {_activeSportId, ..._betSlipSportIds}..remove(1);
      for (final sportId in others) {
        _client.subscribeSport(sportId);
      }
      _log.d('[SubscriptionManager] ✅ V1 Init complete');
    }
  }

  void enterDetail(int eventId) {
    _detailDebounce?.cancel();

    if (_activeDetailEventId != null && _activeDetailEventId != eventId) {
      registry.unsubscribe(
        MatchDetailKey(_activeDetailEventId!),
        source: _detailSource,
      );
    }
    _activeDetailEventId = eventId;
    registry.subscribe(MatchDetailKey(eventId), source: _detailSource);

    if (_listSuspendedForDetail) return;
    _detailDebounce = Timer(_detailSwapDelay, _suspendListForDetail);

    _log.d('[SubscriptionManager] 🔬 Detail SWAP enter: event $eventId');
  }

  void _suspendListForDetail() {
    if (_activeDetailEventId == null) return;
    for (final key in _managedListKeys) {
      if (_betSlipSportIds.contains(key.sportId)) continue;
      registry.unsubscribe(key, source: _listSource);
    }
    _listSuspendedForDetail = true;
    _log.d('[SubscriptionManager] 🔬 Detail SWAP: list suspended');
  }

  bool exitDetail() {
    _detailDebounce?.cancel();
    _detailDebounce = null;

    final detailEventId = _activeDetailEventId;
    _activeDetailEventId = null;
    if (detailEventId != null) {
      registry.unsubscribe(
        MatchDetailKey(detailEventId),
        source: _detailSource,
      );
    }

    if (!_listSuspendedForDetail) {
      _log.d('[SubscriptionManager] 🔬 Detail SWAP exit (nhanh, no-op list)');
      return false;
    }

    for (final key in _managedListKeys) {
      if (_betSlipSportIds.contains(key.sportId)) continue;
      registry.subscribe(key, source: _listSource);
    }
    _listSuspendedForDetail = false;
    _log.d('[SubscriptionManager] 🔬 Detail SWAP exit: list re-subscribed '
        '(caller PHẢI reconcile + guard)');
    return true;
  }

  void resubscribeDetail(int eventId) {
    if (_activeDetailEventId != eventId) return;
    registry.unsubscribe(MatchDetailKey(eventId), source: _detailSource);
    registry.subscribe(MatchDetailKey(eventId), source: _detailSource);
    _log.w('[SubscriptionManager] 🐶 Watchdog re-SUBSCRIBE detail $eventId');
  }

  void setActiveSport(int sportId) {
    if (sportId == _activeSportId) return;

    final oldSportId = _activeSportId;
    _activeSportId = sportId;

    _client.setPrimarySport(sportId);

    if (_useV2Protocol || _isConnected) {
      _syncSubscriptions();
    }

    onListContextChanged?.call();

    _activeSportController.add(sportId);

    _log.d(
      '[SubscriptionManager] 🔄 Active sport changed: $oldSportId → $sportId',
    );
  }

  void syncBetSlipSports(Set<int> sportIds) {
    _betSlipSportIds
      ..clear()
      ..addAll(sportIds);

    if (_useV2Protocol || _isConnected) {
      _syncSubscriptions();
    } else {
      _pendingBetSlipSports = Set.from(sportIds);
    }

    _log.d('[SubscriptionManager] 🎫 BetSlip sports synced: $sportIds');
  }

  void onReconnected() {
    _isConnected = true;

    if (_useV2Protocol) {
      registry.onConnected();
      _log.d(
        '[SubscriptionManager] 🔄 V2 Reconnected - replayed '
        '${registry.channelCount} channels',
      );
    } else {
      _client.subscribeSport(1);

      final others = {_activeSportId, ..._betSlipSportIds}..remove(1);
      for (final sportId in others) {
        _client.subscribeSport(sportId);
      }

      _client.setPrimarySport(_activeSportId);
      _log.d('[SubscriptionManager] 🔄 V1 Reconnected - subscriptions restored');
    }
  }

  void onDisconnected() {
    _isConnected = false;
    registry.onDisconnected();
    _log.d('[SubscriptionManager] 🔌 Disconnected');
  }

  void _syncSubscriptions() {
    if (_useV2Protocol) {
      final Set<int> matchListSports = SocketSubMode.current.isLeague
          ? const <int>{}
          : {_activeSportId, ..._betSlipSportIds};

      final required = <MatchListKey>{
        for (final sportId in matchListSports)
          MatchListKey(sportId, _activeTimeRange),
      };

      for (final key in required.difference(_managedListKeys)) {
        registry.subscribe(key, source: _listSource);
      }
      for (final key in _managedListKeys.difference(required)) {
        registry.unsubscribe(key, source: _listSource);
      }
      _managedListKeys = required;

      if (SocketSubMode.current.isLeague) {
        _syncLeagueModeStructural();
      }

      _log.d(
        '[SubscriptionManager] 📊 V2 Synced: ${registry.channelCount} channels',
      );
    } else {
      final required = {_activeSportId, ..._betSlipSportIds};
      final current = _client.subscribedSports;

      final toSubscribe = required.difference(current);
      if (toSubscribe.contains(1)) {
        _client.subscribeSport(1);
        toSubscribe.remove(1);
      }
      for (final sportId in toSubscribe) {
        _client.subscribeSport(sportId);
      }

      for (final sportId in current.difference(required)) {
        _client.unsubscribeSport(sportId);
      }

      _log.d(
        '[SubscriptionManager] 📊 V1 Synced: required=$required, current=$current',
      );
    }
  }

  void _syncLeagueModeStructural() {
    final target = _activeSportId;
    if (_leagueModeStructuralSportId == target) return;

    if (_leagueModeStructuralSportId != null) {
      registry.unsubscribe(
        LeagueListKey(_leagueModeStructuralSportId!),
        source: _listSource,
      );
    }
    registry.subscribe(LeagueListKey(target), source: _listSource);
    _leagueModeStructuralSportId = target;
  }

  void subscribeMatchList(
    int sportId,
    int timeRange, {
    int? sportTypeId,
    String source = 'manual',
  }) {
    registry.subscribe(
      MatchListKey(sportId, timeRange, sportTypeId: sportTypeId),
      source: source,
    );
  }

  void unsubscribeMatchList(
    int sportId,
    int timeRange, {
    int? sportTypeId,
    String source = 'manual',
  }) {
    registry.unsubscribe(
      MatchListKey(sportId, timeRange, sportTypeId: sportTypeId),
      source: source,
    );
  }

  void subscribeMatchDetail(int eventId, {required String source}) {
    registry.subscribe(MatchDetailKey(eventId), source: source);
  }

  void unsubscribeMatchDetail(int eventId, {required String source}) {
    registry.unsubscribe(MatchDetailKey(eventId), source: source);
  }

  void setLanguage(String newLanguage) {
    registry.setLanguage(newLanguage);
  }

  @Deprecated(
    'Language giờ là state của registry — gọi setLanguage(newLang) MỘT lần '
    'thay vì unsub từng event theo lang cũ. Method này chỉ forward.',
  )
  void unsubscribeMatchDetailWithLang(
    int eventId, {
    required String lang,
    required String source,
  }) {
    unsubscribeMatchDetail(eventId, source: source);
  }

  void setActiveTimeRange(int timeRange) {
    _timeRangeDebounceTimer?.cancel();

    if (timeRange == _activeTimeRange) return;

    _timeRangeDebounceTimer = Timer(_debounceDelay, () {
      _executeTimeRangeSwitch(timeRange);
    });
  }

  void _executeTimeRangeSwitch(int timeRange) {
    final oldTimeRange = _activeTimeRange;
    _activeTimeRange = timeRange;

    if (_useV2Protocol || _isConnected) {
      _syncSubscriptions();
    }

    onListContextChanged?.call();

    onTimeRangeCommitted?.call(timeRange);

    _log.d(
      '[SubscriptionManager] ⏰ Time range changed: '
      '${V2TimeRange.toStringValue(oldTimeRange)} → ${V2TimeRange.toStringValue(timeRange)}',
    );
  }

  void setTimeRangeFromString(String timeRange) {
    setActiveTimeRange(V2TimeRange.fromString(timeRange));
  }

  void dispose() {
    _timeRangeDebounceTimer?.cancel();
    _activeSportController.close();
    _managedListKeys = {};
    _leagueModeStructuralSportId = null;
    registry.clear();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;

import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/websocket/subscription_manager.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';

enum ListBettingGuard { open, locked, failed }

class DetailSwapGuardNotifier extends StateNotifier<ListBettingGuard> {
  DetailSwapGuardNotifier({
    required SubscriptionManager subscriptionManager,
    required SportSocketAdapter adapter,
    required EventTimeRange Function() readTimeRange,
  })  : _subs = subscriptionManager,
        _adapter = adapter,
        _readTimeRange = readTimeRange,
        super(ListBettingGuard.open) {
    _connSub = _adapter.onConnectionChanged.listen((event) {
      if (event.currentState != socket.ConnectionState.connected) return;
      if (state == ListBettingGuard.open) return;
      unawaited(_reconcileWithRetry());
    });
  }

  final SubscriptionManager _subs;
  final SportSocketAdapter _adapter;
  final EventTimeRange Function() _readTimeRange;

  StreamSubscription<dynamic>? _healSub;
  Timer? _healPollTimer;
  StreamSubscription<socket.ConnectionStateEvent>? _connSub;
  int _stampAtFail = -1;

  static const _healPollInterval = Duration(seconds: 2);

  static const retryBackoff = [Duration(seconds: 1), Duration(seconds: 2)];

  Object? _inFlight;

  void enterDetail(int eventId) => _subs.enterDetail(eventId);

  Future<void> exitDetail() async {
    final mustReconcile = _subs.exitDetail();
    if (!mustReconcile) return;
    await Future<void>.microtask(() {});
    await _reconcileWithRetry();
  }

  Future<void> retry() => _reconcileWithRetry();

  void _armHealListener() {
    _stampAtFail = _adapter.lastPopulateStamp;
    _healSub?.cancel();
    _healSub = _adapter.onLeaguesChanged.listen((_) => _tryHealFromEvidence());
    _healPollTimer?.cancel();
    _healPollTimer =
        Timer.periodic(_healPollInterval, (_) => _tryHealFromEvidence());
  }

  void _tryHealFromEvidence() {
    if (!mounted) return;
    if (state != ListBettingGuard.failed) return;
    if (_adapter.lastPopulateStamp <= _stampAtFail) return;
    if (_adapter.lastPopulateSportId != _adapter.currentSportId) return;
    if (_adapter.lastPopulateTimeRange != _currentTabSocketRange) return;
    state = ListBettingGuard.open;
    _disarmHeal();
    debugPrint('[DetailSwapGuard] ✅ heal-theo-bằng-chứng: '
        'populateGeneration tiến (đúng sport/tab) → mở khóa');
  }

  String get _currentTabSocketRange {
    switch (_readTimeRange()) {
      case EventTimeRange.live:
        return socket.TimeRange.live;
      case EventTimeRange.today:
        return socket.TimeRange.today;
      case EventTimeRange.early:
      case EventTimeRange.todayAndEarly:
        return socket.TimeRange.early;
    }
  }

  void _disarmHeal() {
    _healSub?.cancel();
    _healSub = null;
    _healPollTimer?.cancel();
    _healPollTimer = null;
  }

  @override
  void dispose() {
    _disarmHeal();
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _reconcileWithRetry() async {
    if (!mounted) return;
    final token = Object();
    _inFlight = token;
    _disarmHeal();
    state = ListBettingGuard.locked;

    for (var attempt = 0; ; attempt++) {
      try {
        await _reconcileCurrentTab();
        if (!mounted || !identical(_inFlight, token)) return;
        state = ListBettingGuard.open;
        return;
      } catch (e) {
        if (!mounted || !identical(_inFlight, token)) return;
        if (attempt >= retryBackoff.length) {
          state = ListBettingGuard.failed;
          _armHealListener();
          debugPrint('[DetailSwapGuard] ❌ reconcile fail sau '
              '${attempt + 1} lần — giữ khóa betting, chờ CTA/heal: $e');
          return;
        }
        await Future<void>.delayed(retryBackoff[attempt]);
        if (!mounted || !identical(_inFlight, token)) return;
      }
    }
  }

  Future<void> _reconcileCurrentTab() async {
    final before = _adapter.lastPopulateStamp;
    switch (_readTimeRange()) {
      case EventTimeRange.live:
        await _adapter.fetchLiveAndPopulate(background: true);
        break;
      case EventTimeRange.today:
        await _adapter.fetchTodayAndPopulate(background: true);
        break;
      case EventTimeRange.early:
      case EventTimeRange.todayAndEarly:
        await _adapter.fetchEarlyAndPopulate(background: true);
        break;
    }
    if (_adapter.lastPopulateStamp == before) {
      throw const _PopulateFailed();
    }
    if (_adapter.lastPopulateSportId != _adapter.currentSportId ||
        _adapter.lastPopulateTimeRange != _currentTabSocketRange) {
      throw const _PopulateFailed();
    }
  }
}

class _PopulateFailed implements Exception {
  const _PopulateFailed();
  @override
  String toString() =>
      'PopulateFailed: store marker không tiến lên sau reconcile';
}

final detailSwapGuardProvider =
    StateNotifierProvider<DetailSwapGuardNotifier, ListBettingGuard>((ref) {
  final adapter = ref.watch(sportSocketAdapterProvider);
  final subs = adapter.subscriptionManager;
  return DetailSwapGuardNotifier(
    subscriptionManager: subs,
    adapter: adapter,
    readTimeRange: () => ref.read(selectedTimeRangeV2Provider),
  );
});

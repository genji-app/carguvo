import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart';
import 'package:sun_sports/core/perf/stall_monitor.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

import 'subscription_manager.dart';

class VisibleLeagueSubscriptionManager {
  static const String _source = 'visible_list';

  static const Duration _settleDelay = Duration(milliseconds: 400);

  static const Duration _graceDelay = Duration(seconds: 3);

  final SubscriptionManager _subscriptionManager;

  static final AppLogger _log = AppLogger(tag: 'VisibleLeagueSubManager');

  static VisibleLeagueSubscriptionManager? _instance;
  static VisibleLeagueSubscriptionManager? get instance => _instance;

  final Map<LeagueEventsKey, int> _retain = {};

  final Set<LeagueEventsKey> _subscribed = {};

  final Map<LeagueEventsKey, Timer> _graceTimers = {};

  Timer? _settleTimer;

  DateTime? _firstPendingAt;

  static const Duration _maxSettleDelay = Duration(milliseconds: 1500);

  bool _disposed = false;

  VisibleLeagueSubscriptionManager({
    required SubscriptionManager subscriptionManager,
  }) : _subscriptionManager = subscriptionManager {
    _instance = this;
  }

  int get subscribedLeagueCount => _subscribed.length;

  Set<LeagueEventsKey> get subscribedKeys => _subscribed.toSet();

  Set<LeagueEventsKey> get retainedKeys => _retain.keys.toSet();

  Set<int> get subscribedLeagueIds =>
      _subscribed.map((k) => k.leagueId).toSet();

  Set<int> get retainedLeagueIds =>
      _retain.keys.map((k) => k.leagueId).toSet();

  void retain(int leagueId, {required int timeRange}) {
    if (_disposed) return;
    final key = LeagueEventsKey(leagueId, timeRange);
    _retain[key] = (_retain[key] ?? 0) + 1;
    _graceTimers.remove(key)?.cancel();
    _scheduleSettle();
  }

  void release(int leagueId, {required int timeRange}) {
    if (_disposed) return;
    final key = LeagueEventsKey(leagueId, timeRange);
    final count = _retain[key];
    if (count == null) return;
    if (count <= 1) {
      _retain.remove(key);
    } else {
      _retain[key] = count - 1;
    }
    _scheduleSettle();
  }

  void _scheduleSettle() {
    _firstPendingAt ??= DateTime.now();
    if (DateTime.now().difference(_firstPendingAt!) >= _maxSettleDelay) {
      _settleTimer?.cancel();
      _settle();
      return;
    }
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDelay, _settle);
  }

  void _settle() => PerfWork.time('sub.settle', _settleNow);

  void _settleNow() {
    if (_disposed) return;
    _firstPendingAt = null;

    for (final key in _retain.keys) {
      _graceTimers.remove(key)?.cancel();
      if (_subscribed.contains(key)) continue;
      PerfWork.time(
        'sub.send',
        () => _subscriptionManager.registry.subscribe(key, source: _source),
      );
      _subscribed.add(key);
    }

    for (final key in _subscribed.toList()) {
      if (_retain.containsKey(key)) continue;
      if (_graceTimers.containsKey(key)) continue;
      _graceTimers[key] = Timer(_graceDelay, () => _graceUnsub(key));
    }

    _logState('settle');
  }

  void _graceUnsub(LeagueEventsKey key) {
    _graceTimers.remove(key);
    if (_disposed) return;
    if (_retain.containsKey(key)) return;
    if (_subscribed.remove(key)) {
      PerfWork.time(
        'sub.unsub',
        () => _subscriptionManager.registry.unsubscribe(key, source: _source),
      );
      _logState('grace-unsub $key');
    }
  }

  void onContextChanged() {
    if (_disposed) return;
    for (final key in _subscribed) {
      _subscriptionManager.registry.unsubscribe(key, source: _source);
    }
    _subscribed.clear();
    for (final t in _graceTimers.values) {
      t.cancel();
    }
    _graceTimers.clear();
    _scheduleSettle();
    _logState('context-changed');
  }

  void _logState(String reason) {
    if (!kDebugMode) return;
    _log.d(
      '[$reason] subscribed=${_subscribed.length} '
      'retained=${_retain.length} '
      'channels=${_subscribed.toList()}',
    );
  }

  void dispose() {
    _disposed = true;
    _settleTimer?.cancel();
    for (final t in _graceTimers.values) {
      t.cancel();
    }
    _graceTimers.clear();
    for (final key in _subscribed) {
      _subscriptionManager.registry.unsubscribe(key, source: _source);
    }
    _subscribed.clear();
    _retain.clear();
    if (_instance == this) {
      _instance = null;
    }
    _log.d('🗑️ Disposed');
  }
}

import 'dart:async';

import 'package:sun_sports/core/utils/app_logger.dart';

import 'subscription_manager.dart';

class BetslipSubscriptionManager {
  static BetslipSubscriptionManager? _instance;
  static BetslipSubscriptionManager? get instance => _instance;
  static const _source = 'betslip';
  static const _debounceDelay = Duration(milliseconds: 300);
  static const _maxSubscriptions = 50;

  final SubscriptionManager _subscriptionManager;
  String _language;

  final Map<int, int> _eventRefCount = {};
  final Set<int> _subscribedEvents = {};

  bool _slipVisible = false;

  Timer? _debounceTimer;
  final Set<int> _pendingSubscribe = {};
  final Set<int> _pendingUnsubscribe = {};

  bool _isDisposed = false;

  BetslipSubscriptionManager({
    required SubscriptionManager subscriptionManager,
    required String language,
  }) : _subscriptionManager = subscriptionManager,
       _language = language {
    _instance = this;
  }

  int get subscribedEventCount => _subscribedEvents.length;

  bool holdsEvent(int eventId) => _eventRefCount.containsKey(eventId);

  String get language => _language;

  bool get slipVisible => _slipVisible;

  void setSlipVisible(bool visible) {
    if (_isDisposed || _slipVisible == visible) return;
    _slipVisible = visible;

    if (visible) {
      _pendingUnsubscribe.clear();
      for (final eventId in _eventRefCount.keys) {
        if (_subscribedEvents.contains(eventId)) continue;
        if (_subscribedEvents.length + _pendingSubscribe.length >=
            _maxSubscriptions) {
          _logDebug(
            '⚠️ Max subscriptions reached ($_maxSubscriptions) on slip open',
          );
          break;
        }
        _pendingSubscribe.add(eventId);
      }
      _debounceTimer?.cancel();
      _flush();
      _logDebug('👁️ Slip visible → ${_subscribedEvents.length} events subbed');
    } else {
      _pendingSubscribe.clear();
      _pendingUnsubscribe.addAll(_subscribedEvents);
      _scheduleFlush();
      _logDebug('🙈 Slip hidden → unsub ${_pendingUnsubscribe.length} events '
          '(sau debounce)');
    }
  }

  void onBetAdded(int eventId) {
    if (_isDisposed) return;

    _eventRefCount[eventId] = (_eventRefCount[eventId] ?? 0) + 1;

    if (!_slipVisible) return;

    _pendingUnsubscribe.remove(eventId);

    if (!_subscribedEvents.contains(eventId)) {
      if (_subscribedEvents.length >= _maxSubscriptions) {
        _logDebug(
          '⚠️ Max subscriptions reached ($_maxSubscriptions), skipping $eventId',
        );
        return;
      }
      _pendingSubscribe.add(eventId);
    }

    _scheduleFlush();
  }

  void onBetRemoved(int eventId) {
    if (_isDisposed) return;

    final count = _eventRefCount[eventId] ?? 0;
    if (count <= 1) {
      _eventRefCount.remove(eventId);
      _pendingSubscribe.remove(eventId);
      if (_subscribedEvents.contains(eventId)) {
        _pendingUnsubscribe.add(eventId);
      }
    } else {
      _eventRefCount[eventId] = count - 1;
    }

    _scheduleFlush();
  }

  void onBetsCleared() {
    if (_isDisposed) return;

    _pendingSubscribe.clear();
    _pendingUnsubscribe.addAll(_subscribedEvents);
    _eventRefCount.clear();

    _scheduleFlush();
  }

  void restoreSubscriptions(List<int> eventIds) {
    if (_isDisposed) return;

    for (final eventId in eventIds) {
      _eventRefCount[eventId] = (_eventRefCount[eventId] ?? 0) + 1;
      if (_slipVisible && !_subscribedEvents.contains(eventId)) {
        _pendingSubscribe.add(eventId);
      }
    }

    if (_slipVisible) _flush();
  }

  void onReconnected() {
    _logDebug(
      '🔄 Reconnected, ${_subscribedEvents.length} betslip events tracked',
    );
  }

  void _scheduleFlush() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, _flush);
  }

  void _flush() {
    if (_isDisposed) return;

    for (final eventId in _pendingSubscribe.toList()) {
      _subscribeEvent(eventId);
    }
    _pendingSubscribe.clear();

    for (final eventId in _pendingUnsubscribe.toList()) {
      _unsubscribeEvent(eventId);
    }
    _pendingUnsubscribe.clear();
  }

  void _subscribeEvent(int eventId) {
    _subscribedEvents.add(eventId);
    _subscriptionManager.subscribeMatchDetail(eventId, source: _source);
    _logDebug(
      '📺 Subscribed event $eventId (total: ${_subscribedEvents.length})',
    );
  }

  void _unsubscribeEvent(int eventId) {
    _subscribedEvents.remove(eventId);
    _subscriptionManager.unsubscribeMatchDetail(eventId, source: _source);
    _logDebug(
      '📴 Unsubscribed event $eventId (total: ${_subscribedEvents.length})',
    );
  }

  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();

    for (final eventId in _subscribedEvents.toList()) {
      _subscriptionManager.unsubscribeMatchDetail(eventId, source: _source);
    }

    _eventRefCount.clear();
    _subscribedEvents.clear();
    _pendingSubscribe.clear();
    _pendingUnsubscribe.clear();

    if (_instance == this) {
      _instance = null;
    }

    _logDebug('🗑️ Disposed');
  }

  static final AppLogger _log = AppLogger(tag: 'BetslipSubManager');

  void _logDebug(String message) {
    _log.d(message);
  }
}

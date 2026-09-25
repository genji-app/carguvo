import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart'
    as socket
    show MarketStatus, MarketStatusData;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart'
    show SportSocketUpdate;
import 'package:sun_sports/core/perf/frame_monitor.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/utils/microtask_burst_coalescer.dart';
import 'package:sun_sports/core/utils/scroll_hold.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/vibrating_odds/vibrating_odds_checker.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';

typedef MarketStatus = socket.MarketStatus;

typedef MarketKey = String;

MarketKey createMarketKey(int eventId, int marketId) => '${eventId}_$marketId';

(int, int)? parseMarketKey(MarketKey key) {
  final parts = key.split('_');
  if (parts.length != 2) return null;
  final eventId = int.tryParse(parts[0]);
  final marketId = int.tryParse(parts[1]);
  if (eventId == null || marketId == null) return null;
  return (eventId, marketId);
}

@immutable
class MarketStatusInfo {
  final int eventId;
  final int marketId;
  final DateTime lastUpdated;

  final MarketStatus status;

  const MarketStatusInfo({
    required this.eventId,
    required this.marketId,
    required this.lastUpdated,
    this.status = MarketStatus.active,
  });

  MarketKey get key => createMarketKey(eventId, marketId);

  MarketStatusInfo copyWith({DateTime? lastUpdated, MarketStatus? status}) {
    return MarketStatusInfo(
      eventId: eventId,
      marketId: marketId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }

  int get statusCode => status.code;

  bool get isSuspended => status.isSuspended;

  bool get isActive => status == MarketStatus.active;

  bool get isHidden => !status.isVisible;

  bool get isAvailable => status.canBet;

  bool get isVisible => status.isVisible;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketStatusInfo &&
        other.eventId == eventId &&
        other.marketId == marketId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(eventId, marketId, status);
  }
}

@immutable
class MarketStatusState {
  final Map<MarketKey, MarketStatusInfo> markets;

  final Set<int> suspendedEvents;

  const MarketStatusState({
    this.markets = const {},
    this.suspendedEvents = const {},
  });

  MarketStatusState copyWith({
    Map<MarketKey, MarketStatusInfo>? markets,
    Set<int>? suspendedEvents,
  }) {
    return MarketStatusState(
      markets: markets ?? this.markets,
      suspendedEvents: suspendedEvents ?? this.suspendedEvents,
    );
  }

  bool isMarketSuspended(int eventId, int marketId) {
    if (suspendedEvents.contains(eventId)) return true;

    final key = createMarketKey(eventId, marketId);
    return markets[key]?.isSuspended ?? false;
  }

  bool isMarketAvailable(int eventId, int marketId) {
    if (suspendedEvents.contains(eventId)) return false;

    final key = createMarketKey(eventId, marketId);
    return markets[key]?.isAvailable ?? true;
  }

  bool isEventSuspended(int eventId) {
    return suspendedEvents.contains(eventId);
  }

  MarketStatusInfo? getMarketStatus(int eventId, int marketId) {
    final key = createMarketKey(eventId, marketId);
    return markets[key];
  }
}

class MarketStatusNotifier extends StateNotifier<MarketStatusState> {
  final Ref _ref;
  StreamSubscription<socket.MarketStatusData>? _marketSubscription;
  StreamSubscription<SportSocketUpdate>? _updateSubscription;

  final Map<MarketKey, MarketStatusInfo> _pendingMarkets = {};
  late final MicrotaskBurstCoalescer _coalescer = MicrotaskBurstCoalescer(
    _onBurstEnd,
  );

  bool _heldByScroll = false;

  MarketStatusNotifier(this._ref) : super(const MarketStatusState()) {
    _listenToMarketUpdates();
    _listenToEventRemovals();
  }

  void _listenToEventRemovals() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _updateSubscription = adapter.onUpdate.listen((update) {
      for (final eventId in update.removedEventIds) {
        removeEvent(eventId);
      }
    });
  }

  void _listenToMarketUpdates() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _marketSubscription = adapter.onMarketStatusChange.listen(
      _handleMarketUpdate,
    );
  }

  void _handleMarketUpdate(socket.MarketStatusData data) {
    _coalescer.noteMessage();
    if (data.eventId == 0) return;
    if (PerfFlags.trace) {
      PerfCounters.hit('m.mkt');
      if (ScrollHold.instance.active) PerfCounters.hit('hold.msg');
    }

    final key = createMarketKey(data.eventId, data.marketId);
    final existing = _pendingMarkets[key] ?? state.markets[key];
    final now = DateTime.now();

    final newData = MarketStatusInfo(
      eventId: data.eventId,
      marketId: data.marketId,
      lastUpdated: now,
      status: data.status,
    );

    if (existing == null || existing.status != newData.status) {
      _queueMarket(key, newData);

      if (data.isSuspended &&
          VibratingOddsChecker.overUnderMarketIds.contains(data.marketId)) {
        _ref
            .read(vibratingOddsProvider.notifier)
            .removeVibratingByEvent(data.eventId);
      }
    }
  }

  void setMarketSuspended(int eventId, int marketId, bool suspended) {
    _flushPendingMarkets();
    final key = createMarketKey(eventId, marketId);
    final existing = state.markets[key];
    final now = DateTime.now();

    final newStatus = suspended ? MarketStatus.suspended : MarketStatus.active;

    final newData =
        existing?.copyWith(status: newStatus, lastUpdated: now) ??
        MarketStatusInfo(
          eventId: eventId,
          marketId: marketId,
          status: newStatus,
          lastUpdated: now,
        );

    if (existing?.status != newStatus) {
      final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets);
      newMarkets[key] = newData;
      state = state.copyWith(markets: newMarkets);
    }
  }

  void removeEvent(int eventId) {
    _flushPendingMarkets();
    if (!state.suspendedEvents.contains(eventId) &&
        !state.markets.keys.any((key) => parseMarketKey(key)?.$1 == eventId)) {
      return;
    }
    final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets);
    newMarkets.removeWhere((key, _) {
      final parsed = parseMarketKey(key);
      return parsed?.$1 == eventId;
    });

    final newSuspended = Set<int>.from(state.suspendedEvents)..remove(eventId);

    state = state.copyWith(markets: newMarkets, suspendedEvents: newSuspended);
  }

  void clear() {
    _pendingMarkets.clear();
    _heldByScroll = false;
    state = const MarketStatusState();
  }

  MarketStatusState get freshState {
    ScrollHold.instance.force();
    _flushPendingMarkets();
    return state;
  }

  void _queueMarket(MarketKey key, MarketStatusInfo info) {
    _pendingMarkets[key] = info;
    _coalescer.requestFlush();
  }

  void _onBurstEnd() {
    if (ScrollHold.instance.active && _pendingMarkets.isNotEmpty) {
      _heldByScroll = true;
      ScrollHold.instance.onRelease(_flushPendingMarkets);
      return;
    }
    _flushPendingMarkets();
  }

  void _flushPendingMarkets() {
    _coalescer.cancel();
    if (_pendingMarkets.isEmpty) {
      _heldByScroll = false;
      return;
    }
    if (!mounted) {
      _pendingMarkets.clear();
      _heldByScroll = false;
      return;
    }
    final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets)
      ..addAll(_pendingMarkets);
    _pendingMarkets.clear();
    if (PerfFlags.trace) {
      PerfCounters.hit('w.mkt');
      if (_heldByScroll) PerfCounters.hit('hold.flush');
    }
    _heldByScroll = false;
    state = state.copyWith(markets: newMarkets);
  }

  @override
  void dispose() {
    _marketSubscription?.cancel();
    _updateSubscription?.cancel();
    _pendingMarkets.clear();
    ScrollHold.instance.cancel(_flushPendingMarkets);
    super.dispose();
  }
}

final marketStatusProvider =
    StateNotifierProvider<MarketStatusNotifier, MarketStatusState>((ref) {
      return MarketStatusNotifier(ref);
    });

final isMarketSuspendedProvider = Provider.autoDispose.family<bool, (int, int)>(
  (ref, params) {
    final (eventId, marketId) = params;
    return ref.watch(
      marketStatusProvider.select(
        (state) => state.isMarketSuspended(eventId, marketId),
      ),
    );
  },
);

final isMarketAvailableProvider = Provider.autoDispose.family<bool, (int, int)>(
  (ref, params) {
    final (eventId, marketId) = params;
    return ref.watch(
      marketStatusProvider.select(
        (state) => state.isMarketAvailable(eventId, marketId),
      ),
    );
  },
);

final isEventSuspendedProvider = Provider.autoDispose.family<bool, int>((
  ref,
  eventId,
) {
  return ref.watch(
    marketStatusProvider.select((state) => state.isEventSuspended(eventId)),
  );
});

final marketStatusDataProvider = Provider.autoDispose
    .family<MarketStatusInfo?, (int, int)>((ref, params) {
      final (eventId, marketId) = params;
      return ref.watch(
        marketStatusProvider.select(
          (state) => state.getMarketStatus(eventId, marketId),
        ),
      );
    });

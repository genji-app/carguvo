import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/perf/frame_monitor.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/utils/microtask_burst_coalescer.dart';
import 'package:sun_sports/core/utils/scroll_hold.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/services/websocket/websocket_messages.dart';
import 'package:sun_sports/core/utils/vibrating_odds/vibrating_odds_checker.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:betting_domain/betting_domain.dart' as betting;

const Duration kIndicatorDisplayDuration = betting.kOddsIndicatorDisplayDuration;
const double kDefaultOddsValue = betting.kOddsDefaultValue;

typedef OddsChangeDirection = betting.OddsDirection;

class OddsChangeData {
  const OddsChangeData({
    required this.selectionId,
    this.previousValue = kDefaultOddsValue,
    this.currentValue = kDefaultOddsValue,
    this.direction = OddsChangeDirection.none,
    this.lastChangeTime,
    this.oddsValues,
  });

  final String selectionId;
  final double previousValue;
  final double currentValue;
  final OddsChangeDirection direction;
  final DateTime? lastChangeTime;

  final OddsStyleValues? oddsValues;

  bool get isFirstTime => previousValue == kDefaultOddsValue;

  bool get isIndicatorActive => betting.isOddsIndicatorActive(lastChangeTime);

  bool get shouldSkip => selectionId.isEmpty || currentValue == 0;

  double getValueByStyleIndex(int styleIndex) {
    if (oddsValues != null && oddsValues!.isValid) {
      return oddsValues!.getByStyleIndex(styleIndex);
    }
    return currentValue;
  }

  OddsChangeData copyWith({
    String? selectionId,
    double? previousValue,
    double? currentValue,
    OddsChangeDirection? direction,
    DateTime? lastChangeTime,
    OddsStyleValues? oddsValues,
    bool clearLastChangeTime = false,
  }) {
    return OddsChangeData(
      selectionId: selectionId ?? this.selectionId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      direction: direction ?? this.direction,
      lastChangeTime:
          clearLastChangeTime ? null : (lastChangeTime ?? this.lastChangeTime),
      oddsValues: oddsValues ?? this.oddsValues,
    );
  }
}

class OddsChangeState {
  final Map<String, OddsChangeData> changes;

  const OddsChangeState({this.changes = const {}});

  OddsChangeState copyWith({Map<String, OddsChangeData>? changes}) {
    return OddsChangeState(changes: changes ?? this.changes);
  }

  OddsChangeDirection getDirection(String selectionId) {
    final data = changes[selectionId];
    if (data == null || !data.isIndicatorActive) {
      return OddsChangeDirection.none;
    }
    return data.direction;
  }

  bool isShowingIndicator(String selectionId) {
    final data = changes[selectionId];
    return data != null && data.isIndicatorActive;
  }
}

class OddsChangeNotifier extends StateNotifier<OddsChangeState> {
  final Ref _ref;
  StreamSubscription<socket.OddsChangeData>? _oddsSubscription;
  StreamSubscription<SportSocketUpdate>? _updateSubscription;
  StreamSubscription<socket.ScoreUpdateData>? _scoreSubscription;

  final Map<String, _ResetGroup> _resetGroupOf = {};
  _ResetGroup? _openResetGroup;

  final Set<_ResetGroup> _liveResetGroups = {};

  final Map<String, OddsChangeData> _pendingChanges = {};
  late final MicrotaskBurstCoalescer _coalescer = MicrotaskBurstCoalescer(
    _onBurstEnd,
  );

  bool _heldByScroll = false;

  final Map<int, Set<String>> _eventToSelections = {};

  @visibleForTesting
  bool hasSelectionIndexFor(int eventId) =>
      _eventToSelections.containsKey(eventId);

  Timer? _cleanupTimer;

  static const Duration _cleanupInterval = Duration(seconds: 30);

  static const Duration _maxEntryAge = Duration(seconds: 15);

  OddsChangeNotifier(this._ref) : super(const OddsChangeState()) {
    _listenToOddsUpdates();
    _listenToEventRemovals();
    _listenToScoreChanges();
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(
      _cleanupInterval,
      (_) => _cleanupStaleEntries(),
    );
  }

  void _cleanupStaleEntries() {
    if (ScrollHold.instance.active) return;
    _flushPendingChanges();
    final changes = state.changes;

    if (changes.length < 100) return;

    final now = DateTime.now();

    final keysToRemove = <String>[];
    for (final entry in changes.entries) {
      final data = entry.value;

      final hasActiveIndicator =
          data.direction != OddsChangeDirection.none && data.isIndicatorActive;
      final isRecent =
          data.lastChangeTime != null &&
          now.difference(data.lastChangeTime!) < _maxEntryAge;

      if (!hasActiveIndicator && !isRecent) {
        keysToRemove.add(entry.key);
      }
    }

    if (keysToRemove.isNotEmpty) {
      final newChanges = Map<String, OddsChangeData>.from(changes);
      for (final key in keysToRemove) {
        newChanges.remove(key);
        _cancelReset(key);
      }
      state = state.copyWith(changes: newChanges);

      if (kDebugMode) {
      }
    }
  }

  void _listenToEventRemovals() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _updateSubscription = adapter.onUpdate.listen((update) {
      if (update.removedEventIds.isEmpty) return;
      _flushPendingChanges();

      final notifier = _ref.read(vibratingOddsProvider.notifier);
      final removedSelectionKeys = <String>{};
      for (final eventId in update.removedEventIds) {
        notifier.removeVibratingByEvent(eventId);
        final selections = _eventToSelections.remove(eventId);
        if (selections != null) removedSelectionKeys.addAll(selections);
      }

      if (removedSelectionKeys.isEmpty) return;
      final newChanges = Map<String, OddsChangeData>.from(state.changes);
      var changed = false;
      for (final key in removedSelectionKeys) {
        changed = newChanges.remove(key) != null || changed;
        _cancelReset(key);
      }
      if (changed) state = state.copyWith(changes: newChanges);
    });
  }

  void _listenToScoreChanges() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _scoreSubscription = adapter.onScoreUpdate.listen((scoreUpdate) {
      _ref
          .read(vibratingOddsProvider.notifier)
          .removeVibratingByEvent(scoreUpdate.eventId);
    });
  }

  void _listenToOddsUpdates() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _oddsSubscription = adapter.onOddsChange.listen(
      _handleOddsUpdate,
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('[OddsChangeProvider] Stream error: $error');
        }
      },
    );
  }

  void _handleOddsUpdate(socket.OddsChangeData update) {
    _coalescer.noteMessage();
    final selectionId = update.selectionId;

    if (selectionId.isEmpty) {
      return;
    }

    final newValue = update.currentValue;
    if (newValue == 0.0) {
      return;
    }

    _eventToSelections
        .putIfAbsent(update.eventId, () => <String>{})
        .add(selectionId);

    if (PerfFlags.trace) {
      PerfCounters.hit('m.odds');
      if (ScrollHold.instance.active) PerfCounters.hit('hold.msg');
    }

    final existingData =
        _pendingChanges[selectionId] ?? state.changes[selectionId];

    final direction = _mapDirection(update.direction);

    OddsChangeDirection finalDirection;
    DateTime? finalLastChangeTime;

    if (direction != OddsChangeDirection.none) {
      finalDirection = direction;
      finalLastChangeTime = DateTime.now();
    } else if (existingData != null && existingData.isIndicatorActive) {
      finalDirection = existingData.direction;
      finalLastChangeTime = existingData.lastChangeTime;
    } else {
      finalDirection = OddsChangeDirection.none;
      finalLastChangeTime = null;
    }

    final localOddsValues = _convertStyleValues(update.styleValues);

    final newData = OddsChangeData(
      selectionId: selectionId,
      previousValue: update.previousValue,
      currentValue: newValue,
      direction: finalDirection,
      lastChangeTime: finalLastChangeTime,
      oddsValues: localOddsValues,
    );

    _queueChange(newData);

    if (direction != OddsChangeDirection.none) {
      _scheduleReset(selectionId);
    }

    _checkVibratingOdds(update);
  }

  void _checkVibratingOdds(socket.OddsChangeData update) {
    final marketId = update.marketId;
    final selectionId = update.selectionId;

    if (!VibratingOddsChecker.overUnderMarketIds.contains(marketId)) return;

    if (selectionId.isEmpty) return;

    final adapter = _ref.read(sportSocketAdapterProvider);
    final event = adapter.getEventData(update.eventId);
    if (event == null) return;

    final oddsData = adapter.getOdds(update.eventId, marketId, update.offerId);
    final points = oddsData?.points ?? '';
    final isSuspended = oddsData?.isSuspended ?? false;

    if (isSuspended) {
      _ref.read(vibratingOddsProvider.notifier).removeVibrating(selectionId);
      return;
    }

    final currentFormat = _ref.read(oddsStyleProvider);

    final oddsValue = _getOddsValueByFormat(update.styleValues, currentFormat);
    if (oddsValue == null) return;

    final isVibrating = VibratingOddsChecker.isVibrating(
      sportId: event.sportId,
      isLive: event.isLive,
      marketId: marketId,
      points: points,
      oddsValue: oddsValue,
      oddsFormat: currentFormat,
      homeScore: event.homeScore ?? 0,
      awayScore: event.awayScore ?? 0,
      cornersHome: event.cornersHome ?? 0,
      cornersAway: event.cornersAway ?? 0,
    );

    final notifier = _ref.read(vibratingOddsProvider.notifier);
    if (isVibrating) {
      notifier.setVibrating(
        selectionId,
        leagueId: event.leagueId,
        eventId: event.eventId,
      );
    } else {
      notifier.removeVibrating(selectionId);
    }
  }

  double? _getOddsValueByFormat(
    socket.OddsStyleValues? styleValues,
    OddsStyle format,
  ) {
    if (styleValues == null) return null;

    return switch (format) {
      OddsStyle.malay => double.tryParse(styleValues.malay ?? ''),
      OddsStyle.decimal => styleValues.decimal,
      OddsStyle.indo => double.tryParse(styleValues.indo ?? ''),
      OddsStyle.hongKong => double.tryParse(styleValues.hk ?? ''),
    };
  }

  OddsChangeDirection _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirection.up;
      case socket.OddsDirection.down:
        return OddsChangeDirection.down;
      case socket.OddsDirection.none:
        return OddsChangeDirection.none;
    }
  }

  OddsStyleValues? _convertStyleValues(socket.OddsStyleValues? styleValues) {
    if (styleValues == null) return null;
    return OddsStyleValues(
      decimal: styleValues.decimal,
      malay: double.tryParse(styleValues.malay ?? '') ?? 0,
      indo: double.tryParse(styleValues.indo ?? '') ?? 0,
      hk: double.tryParse(styleValues.hk ?? '') ?? 0,
    );
  }

  void _scheduleReset(String selectionId) {
    _cancelReset(selectionId);
    var group = _openResetGroup;
    if (group == null) {
      final created = _ResetGroup();
      created.timer = Timer(
        kIndicatorDisplayDuration,
        () => _fireResetGroup(created),
      );
      _liveResetGroups.add(created);
      _openResetGroup = group = created;
    }
    group.ids.add(selectionId);
    _resetGroupOf[selectionId] = group;
  }

  void _fireResetGroup(_ResetGroup group) {
    _liveResetGroups.remove(group);
    if (!mounted) return;
    for (final id in group.ids) {
      if (identical(_resetGroupOf[id], group)) {
        _resetGroupOf.remove(id);
        _resetIndicator(id);
      }
    }
    group.ids.clear();
  }

  void _cancelReset(String selectionId) {
    final group = _resetGroupOf.remove(selectionId);
    if (group == null) return;
    group.ids.remove(selectionId);
    if (group.ids.isEmpty && !identical(group, _openResetGroup)) {
      _dropResetGroup(group);
    }
  }

  void _dropResetGroup(_ResetGroup group) {
    group.timer?.cancel();
    _liveResetGroups.remove(group);
  }

  void _cancelAllResets() {
    for (final group in _liveResetGroups) {
      group.timer?.cancel();
    }
    _liveResetGroups.clear();
    _openResetGroup = null;
    _resetGroupOf.clear();
  }

  void _resetIndicator(String selectionId) {
    final existingData =
        _pendingChanges[selectionId] ?? state.changes[selectionId];
    if (existingData == null) return;
    _queueChange(
      existingData.copyWith(
        direction: OddsChangeDirection.none,
        lastChangeTime: null,
      ),
    );
  }

  void _queueChange(OddsChangeData data) {
    _pendingChanges[data.selectionId] = data;
    _coalescer.requestFlush();
  }

  void _onBurstEnd() {
    _closeOpenResetGroup();
    if (ScrollHold.instance.active && _pendingChanges.isNotEmpty) {
      _heldByScroll = true;
      ScrollHold.instance.onRelease(_flushPendingChanges);
      return;
    }
    _flushPendingChanges();
  }

  void _closeOpenResetGroup() {
    final openGroup = _openResetGroup;
    if (openGroup != null) {
      _openResetGroup = null;
      if (openGroup.ids.isEmpty) _dropResetGroup(openGroup);
    }
  }

  void _flushPendingChanges() {
    _coalescer.cancel();
    _closeOpenResetGroup();
    if (_pendingChanges.isEmpty) {
      _heldByScroll = false;
      return;
    }
    if (!mounted) {
      _pendingChanges.clear();
      _heldByScroll = false;
      return;
    }
    final newChanges = Map<String, OddsChangeData>.from(state.changes)
      ..addAll(_pendingChanges);
    _pendingChanges.clear();
    if (PerfFlags.trace) {
      PerfCounters.hit('w.odds');
      if (_heldByScroll) PerfCounters.hit('hold.flush');
    }
    _heldByScroll = false;
    state = state.copyWith(changes: newChanges);
  }

  void initializeOdds(String selectionId, double value) {
    _flushPendingChanges();
    final existingData = state.changes[selectionId];

    if (existingData != null) return;

    final newChanges = Map<String, OddsChangeData>.from(state.changes);
    newChanges[selectionId] = OddsChangeData(
      selectionId: selectionId,
      previousValue: kDefaultOddsValue,
      currentValue: value,
      direction: OddsChangeDirection.none,
    );
    state = state.copyWith(changes: newChanges);
  }

  OddsChangeDirection getDirection(String selectionId) {
    final data = _pendingChanges[selectionId] ?? state.changes[selectionId];
    if (data == null || !data.isIndicatorActive) {
      return OddsChangeDirection.none;
    }
    return data.direction;
  }

  void clearAll() {
    _cancelAllResets();
    _pendingChanges.clear();
    _heldByScroll = false;
    if (state.changes.isNotEmpty) {
      state = state.copyWith(changes: {});
    }
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _oddsSubscription?.cancel();
    _updateSubscription?.cancel();
    _scoreSubscription?.cancel();
    _cancelAllResets();
    _pendingChanges.clear();
    _eventToSelections.clear();
    ScrollHold.instance.cancel(_flushPendingChanges);
    super.dispose();
  }
}

OddsChangeDirection oddsDirectionOf(OddsChangeData? data) {
  if (data == null || !data.isIndicatorActive) {
    return OddsChangeDirection.none;
  }
  return data.direction;
}

String? oddsDisplayValueOf(OddsChangeData? data, OddsStyle style) {
  if (data == null || data.currentValue == kDefaultOddsValue) {
    return null;
  }

  final value = data.getValueByStyleIndex(style.index);

  if (value != 0) {
    return value.toStringAsFixed(2);
  }

  return data.currentValue.toStringAsFixed(2);
}

final oddsChangeProvider =
    StateNotifierProvider<OddsChangeNotifier, OddsChangeState>(
      (ref) => OddsChangeNotifier(ref),
    );

final oddsDirectionProvider = Provider.autoDispose
    .family<OddsChangeDirection, String>((ref, selectionId) {
      if (selectionId.isEmpty) return OddsChangeDirection.none;

      final data = ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
      return oddsDirectionOf(data);
    });

final isShowingOddsIndicatorProvider = Provider.autoDispose
    .family<bool, String>((ref, selectionId) {
      if (selectionId.isEmpty) return false;

      final data = ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
      return data != null && data.isIndicatorActive;
    });

final oddsValueProvider = Provider.autoDispose.family<String?, String>((
  ref,
  selectionId,
) {
  if (selectionId.isEmpty) return null;

  final data = ref.watch(
    oddsChangeProvider.select((state) => state.changes[selectionId]),
  );
  final oddsStyle = ref.watch(oddsStyleProvider);
  return oddsDisplayValueOf(data, oddsStyle);
});

final oddsValueDecimalProvider = Provider.autoDispose.family<String?, String>((
  ref,
  selectionId,
) {
  if (selectionId.isEmpty) return null;

  final data = ref.watch(
    oddsChangeProvider.select((state) => state.changes[selectionId]),
  );
  if (data == null || data.currentValue == kDefaultOddsValue) {
    return null;
  }

  final value = data.getValueByStyleIndex(2);
  if (value != 0) return value.toStringAsFixed(2);
  return data.currentValue.toStringAsFixed(2);
});

final oddsChangeDataProvider = Provider.autoDispose
    .family<OddsChangeData?, String>((ref, selectionId) {
      if (selectionId.isEmpty) return null;
      return ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
    });

class _ResetGroup {
  final Set<String> ids = {};
  Timer? timer;
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/perf/frame_monitor.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/utils/microtask_burst_coalescer.dart';
import 'package:sun_sports/core/utils/scroll_hold.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

@immutable
class EventLiveData {
  final int eventId;
  final int homeScore;
  final int awayScore;

  final int gameTime;

  final int gameTimeMs;

  final int gamePart;

  final int stoppageTime;

  final String? status;

  final int sportId;

  final int? cornersHome;
  final int? cornersAway;
  final int? yellowCardsHome;
  final int? yellowCardsAway;
  final int? redCardsHome;
  final int? redCardsAway;

  final int? homeScoreOT;
  final int? awayScoreOT;

  final int? regHomeScore;
  final int? regAwayScore;

  final DateTime lastUpdated;

  const EventLiveData({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
    this.gameTime = 0,
    this.gameTimeMs = 0,
    this.gamePart = 0,
    this.stoppageTime = 0,
    this.status,
    this.sportId = 0,
    this.cornersHome,
    this.cornersAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.redCardsHome,
    this.redCardsAway,
    this.homeScoreOT,
    this.awayScoreOT,
    this.regHomeScore,
    this.regAwayScore,
    required this.lastUpdated,
  });

  EventLiveData copyWith({
    int? homeScore,
    int? awayScore,
    int? gameTime,
    int? gameTimeMs,
    int? gamePart,
    int? stoppageTime,
    String? status,
    int? sportId,
    int? cornersHome,
    int? cornersAway,
    int? yellowCardsHome,
    int? yellowCardsAway,
    int? redCardsHome,
    int? redCardsAway,
    int? homeScoreOT,
    int? awayScoreOT,
    int? regHomeScore,
    int? regAwayScore,
    DateTime? lastUpdated,
  }) {
    return EventLiveData(
      eventId: eventId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      gameTime: gameTime ?? this.gameTime,
      gameTimeMs: gameTimeMs ?? this.gameTimeMs,
      gamePart: gamePart ?? this.gamePart,
      stoppageTime: stoppageTime ?? this.stoppageTime,
      status: status ?? this.status,
      sportId: sportId ?? this.sportId,
      cornersHome: cornersHome ?? this.cornersHome,
      cornersAway: cornersAway ?? this.cornersAway,
      yellowCardsHome: yellowCardsHome ?? this.yellowCardsHome,
      yellowCardsAway: yellowCardsAway ?? this.yellowCardsAway,
      redCardsHome: redCardsHome ?? this.redCardsHome,
      redCardsAway: redCardsAway ?? this.redCardsAway,
      homeScoreOT: homeScoreOT ?? this.homeScoreOT,
      awayScoreOT: awayScoreOT ?? this.awayScoreOT,
      regHomeScore: regHomeScore ?? this.regHomeScore,
      regAwayScore: regAwayScore ?? this.regAwayScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isOvertimePhase => gamePart > GamePart.regulaTimeFinished.value;

  String get gameTimeDisplay {
    if (gameTime <= 0) return '';
    return "$gameTime'";
  }

  String get liveStatusDisplay {
    final part = GamePart.resolveLive(gamePart, gameTimeMinutes: gameTime);
    final code = part.shortCode;
    if (part.isPlaying && gameTime > 0) return "$code $gameTime'";
    return code;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventLiveData &&
        other.eventId == eventId &&
        other.homeScore == homeScore &&
        other.awayScore == awayScore &&
        other.gameTime == gameTime &&
        other.gameTimeMs == gameTimeMs &&
        other.gamePart == gamePart &&
        other.stoppageTime == stoppageTime &&
        other.status == status &&
        other.sportId == sportId &&
        other.cornersHome == cornersHome &&
        other.cornersAway == cornersAway &&
        other.yellowCardsHome == yellowCardsHome &&
        other.yellowCardsAway == yellowCardsAway &&
        other.redCardsHome == redCardsHome &&
        other.redCardsAway == redCardsAway &&
        other.homeScoreOT == homeScoreOT &&
        other.awayScoreOT == awayScoreOT &&
        other.regHomeScore == regHomeScore &&
        other.regAwayScore == regAwayScore;
  }

  @override
  int get hashCode {
    return Object.hash(
      eventId,
      homeScore,
      awayScore,
      gameTime,
      gameTimeMs,
      gamePart,
      stoppageTime,
      status,
      sportId,
      Object.hash(
        cornersHome,
        cornersAway,
        yellowCardsHome,
        yellowCardsAway,
        redCardsHome,
        redCardsAway,
        homeScoreOT,
        awayScoreOT,
        regHomeScore,
        regAwayScore,
      ),
    );
  }
}

@immutable
class EventLiveState {
  final Map<int, EventLiveData> events;

  const EventLiveState({this.events = const {}});

  EventLiveState copyWith({Map<int, EventLiveData>? events}) {
    return EventLiveState(events: events ?? this.events);
  }

  EventLiveData? getEvent(int eventId) => events[eventId];

  (int, int)? getScore(int eventId) {
    final event = events[eventId];
    if (event == null) return null;
    if (event.isOvertimePhase) {
      return (
        (event.regHomeScore ?? event.homeScore) + (event.homeScoreOT ?? 0),
        (event.regAwayScore ?? event.awayScore) + (event.awayScoreOT ?? 0),
      );
    }
    return (event.homeScore, event.awayScore);
  }

  String? getGameTime(int eventId) {
    final event = events[eventId];
    return event?.gameTimeDisplay;
  }

  String? getLiveStatus(int eventId) {
    final event = events[eventId];
    return event?.liveStatusDisplay;
  }

  int? getGameTimeMs(int eventId) {
    final event = events[eventId];
    return event?.gameTimeMs;
  }

  int? getSportId(int eventId) {
    final event = events[eventId];
    return event?.sportId;
  }
}

class EventLiveNotifier extends StateNotifier<EventLiveState> {
  final Ref _ref;
  StreamSubscription<socket.EventStatusData>? _eventStatusSubscription;

  final Map<int, EventLiveData> _pendingEvents = {};
  late final MicrotaskBurstCoalescer _coalescer = MicrotaskBurstCoalescer(
    _onBurstEnd,
  );

  bool _heldByScroll = false;

  EventLiveNotifier(this._ref) : super(const EventLiveState()) {
    _listenToEventStatusUpdates();
  }

  void _listenToEventStatusUpdates() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _eventStatusSubscription = adapter.onEventStatusUpdate.listen((data) {
      _handleEventStatusUpdate(data);
    });
  }

  void _handleEventStatusUpdate(socket.EventStatusData data) {
    _coalescer.noteMessage();
    if (data.eventId == 0) return;
    if (PerfFlags.trace) {
      PerfCounters.hit('m.live');
      if (ScrollHold.instance.active) PerfCounters.hit('hold.msg');
    }

    final existing = _pendingEvents[data.eventId] ?? state.events[data.eventId];
    final now = DateTime.now();

    final gameTimeMinutes = data.gameTime != null
        ? (data.gameTime! ~/ 60000)
        : existing?.gameTime ?? 0;

    final gameTimeMs = data.gameTime ?? existing?.gameTimeMs ?? 0;

    final stoppageTime = data.stoppageTime ?? existing?.stoppageTime ?? 0;

    final gamePart = data.gamePart ?? existing?.gamePart ?? 0;
    final baseHome = data.homeScore ?? existing?.homeScore;
    final baseAway = data.awayScore ?? existing?.awayScore;
    int? regHome = existing?.regHomeScore;
    int? regAway = existing?.regAwayScore;
    if (gamePart <= GamePart.regulaTimeFinished.value) {
      regHome = baseHome ?? regHome;
      regAway = baseAway ?? regAway;
    } else {
      if (baseHome != null) {
        regHome = regHome == null
            ? baseHome
            : (baseHome < regHome ? baseHome : regHome);
      }
      if (baseAway != null) {
        regAway = regAway == null
            ? baseAway
            : (baseAway < regAway ? baseAway : regAway);
      }
    }

    final newData =
        existing?.copyWith(
          homeScore: data.homeScore ?? existing.homeScore,
          awayScore: data.awayScore ?? existing.awayScore,
          gameTime: gameTimeMinutes,
          gameTimeMs: gameTimeMs,
          gamePart: data.gamePart ?? existing.gamePart,
          stoppageTime: stoppageTime,
          status: data.status ?? existing.status,
          sportId: data.sportId,
          cornersHome: data.cornersHome ?? existing.cornersHome,
          cornersAway: data.cornersAway ?? existing.cornersAway,
          yellowCardsHome: data.yellowCardsHome ?? existing.yellowCardsHome,
          yellowCardsAway: data.yellowCardsAway ?? existing.yellowCardsAway,
          redCardsHome: data.redCardsHome ?? existing.redCardsHome,
          redCardsAway: data.redCardsAway ?? existing.redCardsAway,
          homeScoreOT: data.homeScoreOT ?? existing.homeScoreOT,
          awayScoreOT: data.awayScoreOT ?? existing.awayScoreOT,
          regHomeScore: regHome,
          regAwayScore: regAway,
          lastUpdated: now,
        ) ??
        EventLiveData(
          eventId: data.eventId,
          homeScore: data.homeScore ?? 0,
          awayScore: data.awayScore ?? 0,
          gameTime: gameTimeMinutes,
          gameTimeMs: gameTimeMs,
          gamePart: data.gamePart ?? 0,
          stoppageTime: stoppageTime,
          status: data.status,
          sportId: data.sportId,
          cornersHome: data.cornersHome,
          cornersAway: data.cornersAway,
          yellowCardsHome: data.yellowCardsHome,
          yellowCardsAway: data.yellowCardsAway,
          redCardsHome: data.redCardsHome,
          redCardsAway: data.redCardsAway,
          homeScoreOT: data.homeScoreOT,
          awayScoreOT: data.awayScoreOT,
          regHomeScore: regHome,
          regAwayScore: regAway,
          lastUpdated: now,
        );

    if (existing == null ||
        existing.homeScore != newData.homeScore ||
        existing.awayScore != newData.awayScore ||
        existing.gameTime != newData.gameTime ||
        existing.gameTimeMs != newData.gameTimeMs ||
        existing.gamePart != newData.gamePart ||
        existing.stoppageTime != newData.stoppageTime ||
        existing.status != newData.status ||
        existing.cornersHome != newData.cornersHome ||
        existing.cornersAway != newData.cornersAway ||
        existing.yellowCardsHome != newData.yellowCardsHome ||
        existing.yellowCardsAway != newData.yellowCardsAway ||
        existing.redCardsHome != newData.redCardsHome ||
        existing.redCardsAway != newData.redCardsAway ||
        existing.homeScoreOT != newData.homeScoreOT ||
        existing.awayScoreOT != newData.awayScoreOT ||
        existing.regHomeScore != newData.regHomeScore ||
        existing.regAwayScore != newData.regAwayScore) {
      _queueEvent(newData);
    } else {
    }
  }

  void updateEventStatus({
    required int eventId,
    int? gameTime,
    int? gamePart,
    String? status,
    int? homeScore,
    int? awayScore,
  }) {
    _flushPendingEvents();
    final existing = state.events[eventId];
    final now = DateTime.now();

    final newData =
        existing?.copyWith(
          gameTime: gameTime,
          gamePart: gamePart,
          status: status,
          homeScore: homeScore,
          awayScore: awayScore,
          lastUpdated: now,
        ) ??
        EventLiveData(
          eventId: eventId,
          homeScore: homeScore ?? 0,
          awayScore: awayScore ?? 0,
          gameTime: gameTime ?? 0,
          gamePart: gamePart ?? 0,
          status: status,
          lastUpdated: now,
        );

    if (existing != newData) {
      final newEvents = Map<int, EventLiveData>.from(state.events);
      newEvents[eventId] = newData;
      state = state.copyWith(events: newEvents);
    }
  }

  void initializeFromEvent({
    required int eventId,
    required int homeScore,
    required int awayScore,
    int gameTime = 0,
    int gamePart = 0,
    String? status,
  }) {
    _flushPendingEvents();
    if (state.events.containsKey(eventId)) return;

    final newData = EventLiveData(
      eventId: eventId,
      homeScore: homeScore,
      awayScore: awayScore,
      gameTime: gameTime,
      gamePart: gamePart,
      status: status,
      lastUpdated: DateTime.now(),
    );

    final newEvents = Map<int, EventLiveData>.from(state.events);
    newEvents[eventId] = newData;
    state = state.copyWith(events: newEvents);
  }

  void removeEvent(int eventId) {
    _flushPendingEvents();
    if (!state.events.containsKey(eventId)) return;

    final newEvents = Map<int, EventLiveData>.from(state.events);
    newEvents.remove(eventId);
    state = state.copyWith(events: newEvents);
  }

  void clear() {
    _pendingEvents.clear();
    _heldByScroll = false;
    state = const EventLiveState();
  }

  void _queueEvent(EventLiveData data) {
    _pendingEvents[data.eventId] = data;
    _coalescer.requestFlush();
  }

  void _onBurstEnd() {
    if (ScrollHold.instance.active && _pendingEvents.isNotEmpty) {
      _heldByScroll = true;
      ScrollHold.instance.onRelease(_flushPendingEvents);
      return;
    }
    _flushPendingEvents();
  }

  void _flushPendingEvents() {
    _coalescer.cancel();
    if (_pendingEvents.isEmpty) {
      _heldByScroll = false;
      return;
    }
    if (!mounted) {
      _pendingEvents.clear();
      _heldByScroll = false;
      return;
    }
    final newEvents = Map<int, EventLiveData>.from(state.events)
      ..addAll(_pendingEvents);
    _pendingEvents.clear();
    if (PerfFlags.trace) {
      PerfCounters.hit('w.live');
      if (_heldByScroll) PerfCounters.hit('hold.flush');
    }
    _heldByScroll = false;
    state = state.copyWith(events: newEvents);
  }

  @override
  void dispose() {
    _eventStatusSubscription?.cancel();
    _pendingEvents.clear();
    ScrollHold.instance.cancel(_flushPendingEvents);
    super.dispose();
  }
}

final eventLiveProvider =
    StateNotifierProvider<EventLiveNotifier, EventLiveState>((ref) {
      return EventLiveNotifier(ref);
    });

final eventScoreProvider = Provider.autoDispose.family<(int, int)?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getScore(eventId)),
  );
});

final eventGameTimeProvider = Provider.autoDispose.family<String?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getGameTime(eventId)),
  );
});

final eventLiveStatusProvider = Provider.autoDispose.family<String?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
  );
});

final eventGameTimeMsProvider = Provider.autoDispose.family<int?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getGameTimeMs(eventId)),
  );
});

final eventLiveDataProvider = Provider.autoDispose.family<EventLiveData?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getEvent(eventId)),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/events_repository.dart';
import 'package:sun_sports/core/services/models/event_model.dart';
import 'package:sun_sports/core/services/models/market_model.dart';

class EventsState {
  final List<EventModel> events;
  final List<EventModel> liveEvents;
  final List<EventModel> upcomingEvents;
  final List<EventModel> featuredEvents;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;
  final Map<int, EventModel> eventCache;

  const EventsState({
    this.events = const [],
    this.liveEvents = const [],
    this.upcomingEvents = const [],
    this.featuredEvents = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
    this.eventCache = const {},
  });

  EventsState copyWith({
    List<EventModel>? events,
    List<EventModel>? liveEvents,
    List<EventModel>? upcomingEvents,
    List<EventModel>? featuredEvents,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastUpdated,
    Map<int, EventModel>? eventCache,
  }) => EventsState(
    events: events ?? this.events,
    liveEvents: liveEvents ?? this.liveEvents,
    upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    featuredEvents: featuredEvents ?? this.featuredEvents,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    eventCache: eventCache ?? this.eventCache,
  );
}

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository _repository;

  EventsNotifier(this._repository) : super(const EventsState());

  Future<void> fetchEvents({int? leagueId, bool isLive = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final events = await _repository.getEvents(
        leagueId: leagueId,
        isLive: isLive,
      );

      final liveEvents = events.where((e) => e.isLive).toList();
      final upcomingEvents = events.where((e) => !e.isLive).toList();
      final featuredEvents = events.where((e) => e.featured).toList();

      final newCache = Map<int, EventModel>.from(state.eventCache);
      for (final event in events) {
        newCache[event.id] = event;
      }

      state = state.copyWith(
        events: events,
        liveEvents: liveEvents,
        upcomingEvents: upcomingEvents,
        featuredEvents: featuredEvents,
        isLoading: false,
        lastUpdated: DateTime.now(),
        eventCache: newCache,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchLiveEvents() async => fetchEvents(isLive: true);

  Future<void> fetchHotMatches() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final events = await _repository.getHotMatches();

      state = state.copyWith(
        featuredEvents: events,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    try {
      await fetchEvents();
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  EventModel? getEventById(int eventId) => state.eventCache[eventId];

  MarketModel? getMarket(int eventId, String marketClass) {
    final event = state.eventCache[eventId];
    return event?.getMarketByClass(marketClass);
  }

  void clear() {
    state = const EventsState();
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepositoryImpl(),
);

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((
  ref,
) {
  final repository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(repository);
});

final liveEventsProvider = Provider<List<EventModel>>(
  (ref) => ref.watch(eventsProvider).liveEvents,
);

final upcomingEventsProvider = Provider<List<EventModel>>(
  (ref) => ref.watch(eventsProvider).upcomingEvents,
);

final featuredEventsProvider = Provider<List<EventModel>>(
  (ref) => ref.watch(eventsProvider).featuredEvents,
);

final eventsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(eventsProvider).isLoading,
);

final eventByIdProvider = Provider.family<EventModel?, int>(
  (ref, eventId) => ref.watch(eventsProvider).eventCache[eventId],
);

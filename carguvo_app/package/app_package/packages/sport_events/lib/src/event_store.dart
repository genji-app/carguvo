enum EventSortOrder {
  startTimeAsc,

  startTimeDesc,

  eventId,
}

class EventFilter {
  const EventFilter({
    this.sportId,
    this.leagueId,
    this.isLive,
    this.searchQuery,
  });

  final int? sportId;
  final int? leagueId;
  final bool? isLive;
  final String? searchQuery;

  EventFilter copyWith({
    int? sportId,
    int? leagueId,
    bool? isLive,
    String? searchQuery,
  }) {
    return EventFilter(
      sportId: sportId ?? this.sportId,
      leagueId: leagueId ?? this.leagueId,
      isLive: isLive ?? this.isLive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventFilter &&
          runtimeType == other.runtimeType &&
          sportId == other.sportId &&
          leagueId == other.leagueId &&
          isLive == other.isLive &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      sportId.hashCode ^
      leagueId.hashCode ^
      isLive.hashCode ^
      searchQuery.hashCode;
}

class SportEvent {
  const SportEvent({
    required this.eventId,
    this.sportId = 1,
    this.leagueId,
    this.startTime = 0,
    this.isLive = false,
    this.homeName = '',
    this.awayName = '',
  });

  final int eventId;
  final int sportId;
  final int? leagueId;
  final int startTime;
  final bool isLive;
  final String homeName;
  final String awayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;
}

class EventStore {
  final List<SportEvent> _events = [];
  EventFilter _filter = const EventFilter();
  EventSortOrder _sortOrder = EventSortOrder.startTimeAsc;

  EventFilter get filter => _filter;

  EventSortOrder get sortOrder => _sortOrder;

  List<SportEvent> get allEvents => List.unmodifiable(_events);

  List<SportEvent> get events {
    var filtered = _events.where(_matchesFilter).toList();
    _sortEvents(filtered);
    return filtered;
  }

  void setFilter(EventFilter filter) {
    _filter = filter;
  }

  void setSortOrder(EventSortOrder order) {
    _sortOrder = order;
  }

  void addEvent(SportEvent event) {
    _events.removeWhere((e) => e.eventId == event.eventId);
    _events.add(event);
  }

  void addEvents(List<SportEvent> events) {
    for (final event in events) {
      addEvent(event);
    }
  }

  void removeEvent(int eventId) {
    _events.removeWhere((e) => e.eventId == eventId);
  }

  void clear() {
    _events.clear();
  }

  SportEvent? getEvent(int eventId) {
    try {
      return _events.firstWhere((e) => e.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  int get count => _events.length;

  bool _matchesFilter(SportEvent event) {
    if (_filter.sportId != null && event.sportId != _filter.sportId) {
      return false;
    }
    if (_filter.leagueId != null && event.leagueId != _filter.leagueId) {
      return false;
    }
    if (_filter.isLive != null && event.isLive != _filter.isLive) {
      return false;
    }
    if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
      final query = _filter.searchQuery!.toLowerCase();
      final homeName = event.homeName.toLowerCase();
      final awayName = event.awayName.toLowerCase();
      if (!homeName.contains(query) && !awayName.contains(query)) {
        return false;
      }
    }
    return true;
  }

  void _sortEvents(List<SportEvent> events) {
    switch (_sortOrder) {
      case EventSortOrder.startTimeAsc:
        events.sort((a, b) => a.startTime.compareTo(b.startTime));
      case EventSortOrder.startTimeDesc:
        events.sort((a, b) => b.startTime.compareTo(a.startTime));
      case EventSortOrder.eventId:
        events.sort((a, b) => a.eventId.compareTo(b.eventId));
    }
  }
}

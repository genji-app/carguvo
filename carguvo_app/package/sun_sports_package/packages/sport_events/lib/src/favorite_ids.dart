library;

class FavoriteIds {
  const FavoriteIds({
    this.leagueIds = const [],
    this.eventIds = const [],
  });

  final List<int> leagueIds;

  final List<int> eventIds;

  bool get isEmpty => leagueIds.isEmpty && eventIds.isEmpty;

  int get totalCount => leagueIds.length + eventIds.length;

  bool isLeagueFavorite(int leagueId) => leagueIds.contains(leagueId);

  bool isEventFavorite(int eventId) => eventIds.contains(eventId);

  static FavoriteIds parseNode(dynamic node) {
    if (node is! Map) return const FavoriteIds();
    return FavoriteIds(
      leagueIds: _ids(node['0']),
      eventIds: _ids(node['1']),
    );
  }

  static FavoriteIds parseResponse(Map<dynamic, dynamic> decoded, int sportId) {
    final sport = decoded[sportId.toString()];
    if (sport is! Map) return const FavoriteIds();
    return parseNode(sport);
  }

  static List<int> _ids(dynamic value) {
    if (value is! List) return const <int>[];
    final out = <int>[];
    for (final x in value) {
      if (x is num) {
        out.add(x.toInt());
      } else if (x is String) {
        final parsed = int.tryParse(x.trim());
        if (parsed != null) out.add(parsed);
      }
    }
    return out;
  }

  @override
  String toString() =>
      'FavoriteIds(leagueIds: $leagueIds, eventIds: $eventIds)';
}

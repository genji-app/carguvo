library;

const int topLeagueFallbackLimit = 20;

const int topLeagueEventsTimeRange = 4;

List<T> topLeaguesFromPopular<T>(
  List<T> popular, {
  required int sportId,
  required int Function(T) sportIdOf,
  int limit = topLeagueFallbackLimit,
}) =>
    popular.where((l) => sportIdOf(l) == sportId).take(limit).toList();

class TopLeagueMergePlan<T> {
  const TopLeagueMergePlan({required this.ordered, required this.missing});

  final List<T> ordered;

  final List<T> missing;
}

TopLeagueMergePlan<T> topLeagueMergePlan<T>({
  required List<T> pins,
  required int Function(T) leagueIdOf,
  required Iterable<int> eventLeagueIds,
}) {
  final withEvents = eventLeagueIds.toSet();
  final missing = <T>[];
  for (final pin in pins) {
    if (!withEvents.contains(leagueIdOf(pin))) missing.add(pin);
  }
  return TopLeagueMergePlan(ordered: pins, missing: missing);
}

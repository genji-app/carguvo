library;

const Duration eventsDataOnlyThrottleLive = Duration(seconds: 3);

const Duration eventsDataOnlyThrottlePrematch = Duration(seconds: 10);

Duration eventsDataOnlyThrottle({required bool isLive}) =>
    isLive ? eventsDataOnlyThrottleLive : eventsDataOnlyThrottlePrematch;

bool isStructuralChange({
  required List<int> addedLeagueIds,
  required List<int> addedEventIds,
  required List<int> removedLeagueIds,
  required List<int> removedEventIds,
}) =>
    addedLeagueIds.isNotEmpty ||
    addedEventIds.isNotEmpty ||
    removedLeagueIds.isNotEmpty ||
    removedEventIds.isNotEmpty;

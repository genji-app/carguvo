import 'package:meta/meta.dart';

@immutable
class DataChangeEvent {

  final Set<int> updatedLeagueIds;

  final Set<int> updatedEventIds;

  final Set<String> updatedMarketKeys;

  final Set<String> updatedOddsKeys;

  final List<int> addedLeagueIds;

  final List<int> addedEventIds;

  final List<String> addedMarketKeys;

  final List<String> addedOddsKeys;

  final List<int> removedLeagueIds;

  final List<int> removedEventIds;

  final List<String> removedMarketKeys;

  final List<String> removedOddsKeys;

  final DateTime timestamp;

  final int batchSize;

  final Duration processingTime;

  const DataChangeEvent({
    this.updatedLeagueIds = const {},
    this.updatedEventIds = const {},
    this.updatedMarketKeys = const {},
    this.updatedOddsKeys = const {},
    this.addedLeagueIds = const [],
    this.addedEventIds = const [],
    this.addedMarketKeys = const [],
    this.addedOddsKeys = const [],
    this.removedLeagueIds = const [],
    this.removedEventIds = const [],
    this.removedMarketKeys = const [],
    this.removedOddsKeys = const [],
    required this.timestamp,
    this.batchSize = 0,
    this.processingTime = Duration.zero,
  });

  factory DataChangeEvent.empty() => DataChangeEvent(
        timestamp: DateTime.now(),
      );

  bool get isEmpty =>
      updatedLeagueIds.isEmpty &&
      updatedEventIds.isEmpty &&
      updatedMarketKeys.isEmpty &&
      updatedOddsKeys.isEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      addedMarketKeys.isEmpty &&
      addedOddsKeys.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty &&
      removedMarketKeys.isEmpty &&
      removedOddsKeys.isEmpty;

  bool get isNotEmpty => !isEmpty;

  int get totalChanges =>
      updatedLeagueIds.length +
      updatedEventIds.length +
      updatedMarketKeys.length +
      updatedOddsKeys.length +
      addedLeagueIds.length +
      addedEventIds.length +
      addedMarketKeys.length +
      addedOddsKeys.length +
      removedLeagueIds.length +
      removedEventIds.length +
      removedMarketKeys.length +
      removedOddsKeys.length;

  bool affectsEvent(int eventId) =>
      updatedEventIds.contains(eventId) ||
      addedEventIds.contains(eventId) ||
      removedEventIds.contains(eventId);

  bool affectsLeague(int leagueId) =>
      updatedLeagueIds.contains(leagueId) ||
      addedLeagueIds.contains(leagueId) ||
      removedLeagueIds.contains(leagueId);

  bool affectsMarket(int eventId, int marketId) {
    final key = '${eventId}_$marketId';
    return updatedMarketKeys.contains(key) || addedMarketKeys.contains(key);
  }

  bool affectsAnyEventInLeague(int leagueId, Set<int> eventIdsInLeague) {
    for (final eventId in eventIdsInLeague) {
      if (affectsEvent(eventId)) return true;
    }
    return false;
  }

  Set<int> get allAffectedEventIds => {
        ...updatedEventIds,
        ...addedEventIds,
        ...removedEventIds,
      };

  Set<int> get allAffectedLeagueIds => {
        ...updatedLeagueIds,
        ...addedLeagueIds,
        ...removedLeagueIds,
      };

  bool get isOddsOnlyUpdate =>
      updatedOddsKeys.isNotEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty &&
      updatedLeagueIds.isEmpty &&
      addedMarketKeys.isEmpty;

  bool get hasStructuralChanges =>
      addedLeagueIds.isNotEmpty ||
      addedEventIds.isNotEmpty ||
      removedLeagueIds.isNotEmpty ||
      removedEventIds.isNotEmpty;

  @override
  String toString() {
    final parts = <String>[];

    if (addedLeagueIds.isNotEmpty) {
      parts.add('leagues+${addedLeagueIds.length}');
    }
    if (updatedLeagueIds.isNotEmpty) {
      parts.add('leagues~${updatedLeagueIds.length}');
    }
    if (removedLeagueIds.isNotEmpty) {
      parts.add('leagues-${removedLeagueIds.length}');
    }
    if (addedEventIds.isNotEmpty) {
      parts.add('events+${addedEventIds.length}');
    }
    if (updatedEventIds.isNotEmpty) {
      parts.add('events~${updatedEventIds.length}');
    }
    if (removedEventIds.isNotEmpty) {
      parts.add('events-${removedEventIds.length}');
    }
    if (updatedMarketKeys.isNotEmpty || addedMarketKeys.isNotEmpty) {
      parts.add('markets=${updatedMarketKeys.length + addedMarketKeys.length}');
    }
    if (updatedOddsKeys.isNotEmpty || addedOddsKeys.isNotEmpty) {
      parts.add('odds=${updatedOddsKeys.length + addedOddsKeys.length}');
    }

    if (parts.isEmpty) {
      return 'DataChangeEvent(empty)';
    }

    return 'DataChangeEvent(${parts.join(", ")})';
  }

  Map<String, dynamic> toJson() {
    return {
      'updatedLeagueIds': updatedLeagueIds.toList(),
      'updatedEventIds': updatedEventIds.toList(),
      'updatedMarketKeys': updatedMarketKeys.toList(),
      'updatedOddsKeys': updatedOddsKeys.toList(),
      'addedLeagueIds': addedLeagueIds,
      'addedEventIds': addedEventIds,
      'addedMarketKeys': addedMarketKeys,
      'addedOddsKeys': addedOddsKeys,
      'removedLeagueIds': removedLeagueIds,
      'removedEventIds': removedEventIds,
      'timestamp': timestamp.toIso8601String(),
      'batchSize': batchSize,
      'processingTimeMs': processingTime.inMilliseconds,
      'totalChanges': totalChanges,
    };
  }
}

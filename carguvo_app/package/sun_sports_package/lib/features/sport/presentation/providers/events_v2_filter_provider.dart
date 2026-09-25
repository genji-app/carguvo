import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';

final selectedSportV2Provider = StateProvider<SportType>((ref) {
  return SportType.soccer;
});

final selectedTimeRangeV2Provider = StateProvider<EventTimeRange>((ref) {
  return EventTimeRange.live;
});

final selectedBoxingTypeV2Provider = StateProvider<BoxingType?>((ref) {
  return null;
});

final eventFilterV2Provider = Provider<EventFilterV2>((ref) {
  final sport = ref.watch(selectedSportV2Provider);
  final timeRange = ref.watch(selectedTimeRangeV2Provider);
  final boxingType = ref.watch(selectedBoxingTypeV2Provider);

  return EventFilterV2(
    sportType: sport,
    timeRange: timeRange,
    boxingType: sport == SportType.boxing ? boxingType : null,
  );
});

class EventFilterV2 {
  final SportType sportType;
  final EventTimeRange timeRange;
  final BoxingType? boxingType;

  const EventFilterV2({
    required this.sportType,
    required this.timeRange,
    this.boxingType,
  });

  int get sportId => sportType.id;
  int get timeRangeValue => timeRange.value;
  int? get sportTypeId => boxingType?.id;

  EventFilterV2 copyWith({
    SportType? sportType,
    EventTimeRange? timeRange,
    BoxingType? boxingType,
  }) {
    return EventFilterV2(
      sportType: sportType ?? this.sportType,
      timeRange: timeRange ?? this.timeRange,
      boxingType: boxingType ?? this.boxingType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventFilterV2 &&
        other.sportType == sportType &&
        other.timeRange == timeRange &&
        other.boxingType == boxingType;
  }

  @override
  int get hashCode =>
      sportType.hashCode ^ timeRange.hashCode ^ boxingType.hashCode;

  @override
  String toString() =>
      'EventFilterV2(sport: $sportType, timeRange: $timeRange, boxingType: $boxingType)';
}

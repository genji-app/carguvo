import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/repositories/events_v2_repository.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';

const int kEventDatesDays = 30;

const int kEventDatesTzOffset = -420;

final eventDatesProvider = FutureProvider.family<List<String>, int>((
  ref,
  sportId,
) async {
  final repository = ref.watch(eventsV2RepositoryProvider);
  return repository.getEventDates(
    sportId,
    days: kEventDatesDays,
    tzOffset: kEventDatesTzOffset,
  );
});

final sportDetailSelectedDateProvider = StateProvider<String?>((ref) {
  ref.watch(selectedSportV2Provider.select((s) => s.id));
  return null;
});

typedef EventsByDateKey = ({int sportId, String date});

final eventsByDateProvider =
    FutureProvider.family<List<LeagueModelV2>, EventsByDateKey>((
  ref,
  key,
) async {
  final repository = ref.watch(eventsV2RepositoryProvider);
  final leagues = await repository.getEvents(
    EventsRequestModel(
      sportId: key.sportId,
      timeRange: 3,
      date: key.date.toApiDate(),
      sortByTime: true,
      tzOffset: kEventDatesTzOffset,
    ),
  );
  return leagues.mergeDuplicateLeagues();
});

const List<String> _tabWeekdays = [
  'Thứ 2',
  'Thứ 3',
  'Thứ 4',
  'Thứ 5',
  'Thứ 6',
  'Thứ 7',
  'CN',
];

extension EventDateFormatX on String {
  String toTabLabel() {
    final parts = split('-');
    if (parts.length != 3) return this;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (month == null || day == null) return this;
    if (year == null) return '$day/$month';
    final weekday = DateTime(year, month, day).weekday;
    return '${_tabWeekdays[weekday - 1]} ($day/$month)';
  }

  String toApiDate() {
    final parts = split('-');
    if (parts.length != 3) return this;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return this;
    return '$year-$month-$day';
  }
}

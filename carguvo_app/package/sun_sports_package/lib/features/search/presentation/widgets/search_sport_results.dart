import 'package:flutter/material.dart';
import 'package:sun_sports/features/search/data/models/search_league_item.dart';
import 'package:sun_sports/features/search/data/models/search_result_item.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_result_list.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';

class SearchSportResults extends StatelessWidget {
  const SearchSportResults({
    super.key,
    required this.events,
    this.leagues = const [],
    this.query = '',
    this.emptyMessage = 'Không tìm thấy kết quả',
    this.onSearchResultTap,
    this.onLeagueTap,
  });

  final List<SearchResultItem> events;

  final String query;

  final List<SearchLeagueItem> leagues;

  final String emptyMessage;

  final void Function(SearchResultItem item)? onSearchResultTap;

  final void Function(SearchLeagueItem item)? onLeagueTap;

  @override
  Widget build(BuildContext context) {
    if (leagues.isEmpty && events.isEmpty) {
      return const SportEmptyPage(message: 'Không tìm thấy kết quả.');
    }

    return SearchResultList(
      leagues: leagues,
      events: events,
      query: query,
      emptyMessage: emptyMessage,
      onSearchResultTap: onSearchResultTap,
      onLeagueTap: onLeagueTap,
    );
  }
}

import 'package:sun_sports/features/search/data/models/search_league_item.dart';
import 'package:sun_sports/features/search/data/models/search_result_item.dart';

class SearchResponseModel {
  const SearchResponseModel({this.leagues = const [], this.events = const []});

  final List<SearchLeagueItem> leagues;
  final List<SearchResultItem> events;

  bool get isEmpty => leagues.isEmpty && events.isEmpty;

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final raw0 = json['0'];
    final raw1 = json['1'];

    final leaguesList = <SearchLeagueItem>[];
    if (raw0 is List) {
      for (final item in raw0) {
        if (item is Map) {
          final league = SearchLeagueItem.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (league.leagueId > 0 && league.leagueName.isNotEmpty) {
            leaguesList.add(league);
          }
        }
      }
    }

    final eventsList = <SearchResultItem>[];
    if (raw1 is List) {
      for (final item in raw1) {
        if (item is Map) {
          eventsList.add(
            SearchResultItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return SearchResponseModel(leagues: leaguesList, events: eventsList);
  }
}

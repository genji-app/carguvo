import 'package:sport_events/sport_events.dart' show SearchLeagueHit;

class SearchLeagueItem {
  const SearchLeagueItem({
    required this.sportId,
    required this.leagueId,
    required this.leagueName,
    this.leagueLogoUrl = '',
  });

  final int sportId;
  final int leagueId;
  final String leagueName;

  final String leagueLogoUrl;

  factory SearchLeagueItem.fromJson(Map<String, dynamic> json) {
    final hit = SearchLeagueHit.fromApi(json);
    return SearchLeagueItem(
      sportId: hit.sportId,
      leagueId: hit.leagueId,
      leagueName: hit.name.trim(),
      leagueLogoUrl: hit.logo.trim(),
    );
  }
}

import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sport_events/sport_events.dart' show SearchEventHit;

class SearchResultItem {
  const SearchResultItem({
    required this.sportId,
    required this.eventId,
    required this.leagueName,
    required this.leagueId,
    required this.eventName,
    required this.startTimeIso,
    required this.startTimeMs,
    required this.isLive,
    required this.status,
    this.leagueIconUrl = '',
    this.homeTeamLogoUrl = '',
    this.awayTeamLogoUrl = '',
  });

  final int sportId;
  final int eventId;
  final String leagueName;
  final int leagueId;
  final String eventName;
  final String startTimeIso;
  final int startTimeMs;
  final bool isLive;
  final int status;

  final String leagueIconUrl;

  final String homeTeamLogoUrl;

  final String awayTeamLogoUrl;

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    final hit = SearchEventHit.fromApi(json);
    return SearchResultItem(
      sportId: hit.sportId,
      leagueId: hit.leagueId,
      leagueName: hit.leagueName.trim(),
      eventId: hit.eventId,
      eventName: hit.eventName.trim(),
      startTimeIso: hit.startTimeIso,
      startTimeMs: hit.startTimeMs,
      isLive: hit.isLive,
      status: hit.status,
      leagueIconUrl: hit.leagueIcon.trim(),
      homeTeamLogoUrl: hit.homeLogo.trim(),
      awayTeamLogoUrl: hit.awayLogo.trim(),
    );
  }

  (String homeName, String awayName) get teamNames {
    final parts = eventName.split(' vs ');
    final homeName = parts.isNotEmpty ? parts[0].trim() : '';
    final awayName = parts.length > 1 ? parts[1].trim() : '';
    return (homeName, awayName);
  }

  EventModelV2 toEventModelV2() {
    final (homeName, awayName) = teamNames;
    return EventModelV2(
      sportId: sportId > 0 ? sportId : 1,
      leagueId: leagueId,
      eventId: eventId,
      startDate: startTimeIso,
      startTime: startTimeMs,
      type: status,
      homeName: homeName,
      awayName: awayName,
      homeLogo: homeTeamLogoUrl,
      awayLogo: awayTeamLogoUrl,
      isLive: isLive,
      markets: [],
    );
  }

  LeagueModelV2 toLeagueModelV2() {
    return LeagueModelV2(
      sportId: sportId > 0 ? sportId : 1,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueNameEn: leagueName,
      leagueLogo: leagueIconUrl,
      events: [toEventModelV2()],
    );
  }
}

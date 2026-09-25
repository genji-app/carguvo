library;

import 'match_summary_stats.dart';

class MatchSummaryParser {
  MatchSummaryParser._();

  static MatchSummaryStats parse(Map<String, dynamic> data) {
    var homeName = '';
    var awayName = '';
    var homeLogoUrl = '';
    var awayLogoUrl = '';
    final competitors = data['competitor'] as List<dynamic>? ?? const [];
    for (final c in competitors) {
      if (c is! Map) continue;
      final name = c['name'] as String? ?? c['name']?.toString() ?? '';
      final logo = c['logoUrl'] as String? ?? c['logoUrl']?.toString() ?? '';
      if (c['qualifier'] == 'home') {
        homeName = name;
        homeLogoUrl = logo;
      } else if (c['qualifier'] == 'away') {
        awayName = name;
        awayLogoUrl = logo;
      }
    }

    var cornersHome = 0;
    var cornersAway = 0;
    var yellowHome = 0;
    var yellowAway = 0;
    var redHome = 0;
    var redAway = 0;
    var totalHome = 0;
    var totalAway = 0;
    int? h1HomeFromPeriodScore;
    int? h1AwayFromPeriodScore;
    var h1HomeFromScoreChange = 0;
    var h1AwayFromScoreChange = 0;

    final timeline = data['timeline'] as List<dynamic>? ?? const [];
    for (final raw in timeline) {
      if (raw is! Map) continue;
      final type = raw['type']?.toString();
      final competitor = raw['competitor']?.toString();
      final isHome = competitor == 'home';
      final isAway = competitor == 'away';

      switch (type) {
        case 'corner_kick':
          if (isHome) cornersHome++;
          if (isAway) cornersAway++;
        case 'yellow_card':
          if (isHome) yellowHome++;
          if (isAway) yellowAway++;
        case 'red_card':
          if (isHome) redHome++;
          if (isAway) redAway++;
        case 'yellow_red_card':
          if (isHome) {
            yellowHome++;
            redHome++;
          }
          if (isAway) {
            yellowAway++;
            redAway++;
          }
        case 'score_change':
          final home = (raw['homeScore'] as num?)?.toInt();
          final away = (raw['awayScore'] as num?)?.toInt();
          if (home == null || away == null) break;
          totalHome = home;
          totalAway = away;
          if ((raw['period'] as num?)?.toInt() == 1) {
            h1HomeFromScoreChange = home;
            h1AwayFromScoreChange = away;
          }
        case 'period_score':
          if ((raw['period'] as num?)?.toInt() == 1) {
            h1HomeFromPeriodScore = (raw['homeScore'] as num?)?.toInt();
            h1AwayFromPeriodScore = (raw['awayScore'] as num?)?.toInt();
          }
        default:
          break;
      }
    }

    final h1Home = h1HomeFromPeriodScore ?? h1HomeFromScoreChange;
    final h1Away = h1AwayFromPeriodScore ?? h1AwayFromScoreChange;

    return MatchSummaryStats(
      matchStatus: data['matchStatus']?.toString() ?? '',
      homeName: homeName,
      awayName: awayName,
      homeLogoUrl: homeLogoUrl,
      awayLogoUrl: awayLogoUrl,
      cornersHome: cornersHome,
      cornersAway: cornersAway,
      yellowCardsHome: yellowHome,
      yellowCardsAway: yellowAway,
      redCardsHome: redHome,
      redCardsAway: redAway,
      secondHalfGoalsHome: (totalHome - h1Home) < 0 ? 0 : totalHome - h1Home,
      secondHalfGoalsAway: (totalAway - h1Away) < 0 ? 0 : totalAway - h1Away,
      totalGoalsHome: totalHome,
      totalGoalsAway: totalAway,
    );
  }
}

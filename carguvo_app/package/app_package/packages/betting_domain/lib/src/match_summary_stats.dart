library;

class MatchSummaryStats {
  const MatchSummaryStats({
    required this.matchStatus,
    this.homeName = '',
    this.awayName = '',
    this.homeLogoUrl = '',
    this.awayLogoUrl = '',
    this.cornersHome = 0,
    this.cornersAway = 0,
    this.yellowCardsHome = 0,
    this.yellowCardsAway = 0,
    this.redCardsHome = 0,
    this.redCardsAway = 0,
    this.secondHalfGoalsHome = 0,
    this.secondHalfGoalsAway = 0,
    this.totalGoalsHome = 0,
    this.totalGoalsAway = 0,
  });

  final String matchStatus;
  final String homeName;
  final String awayName;
  final String homeLogoUrl;
  final String awayLogoUrl;
  final int cornersHome;
  final int cornersAway;
  final int yellowCardsHome;
  final int yellowCardsAway;
  final int redCardsHome;
  final int redCardsAway;

  final int secondHalfGoalsHome;
  final int secondHalfGoalsAway;

  final int totalGoalsHome;
  final int totalGoalsAway;
}

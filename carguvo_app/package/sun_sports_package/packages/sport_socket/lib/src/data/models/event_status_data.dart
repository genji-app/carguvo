class EventStatusData {
  final int eventId;

  final int sportId;

  final String? status;

  final bool isSuspended;

  final bool? isLive;

  final bool? isLivestream;

  final String? eventStatus;

  final int? gameTime;

  final int? gamePart;

  final int? stoppageTime;

  final int? cornersHome;

  final int? cornersAway;

  final int? yellowCardsHome;

  final int? yellowCardsAway;

  final int? redCardsHome;

  final int? redCardsAway;

  final int? homeScore;

  final int? awayScore;

  final int? homeScoreOT;

  final int? awayScoreOT;

  final DateTime timestamp;

  const EventStatusData({
    required this.eventId,
    required this.sportId,
    this.status,
    this.isSuspended = false,
    this.isLive,
    this.isLivestream,
    this.eventStatus,
    this.gameTime,
    this.gamePart,
    this.stoppageTime,
    this.cornersHome,
    this.cornersAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.redCardsHome,
    this.redCardsAway,
    this.homeScore,
    this.awayScore,
    this.homeScoreOT,
    this.awayScoreOT,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'EventStatusData(eventId: $eventId, status: $status, '
        'gameTime: $gameTime, gamePart: $gamePart)';
  }
}

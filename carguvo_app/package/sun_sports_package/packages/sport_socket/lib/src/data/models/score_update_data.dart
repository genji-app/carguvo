class ScoreUpdateData {
  final int eventId;

  final int sportId;

  final int homeScore;

  final int awayScore;

  final DateTime timestamp;

  const ScoreUpdateData({
    required this.eventId,
    required this.sportId,
    required this.homeScore,
    required this.awayScore,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ScoreUpdateData(eventId: $eventId, score: $homeScore-$awayScore)';
  }
}

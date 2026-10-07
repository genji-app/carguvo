class NoticeStats {
  const NoticeStats({
    required this.homeGoals,
    required this.awayGoals,
    required this.homeYellow,
    required this.awayYellow,
    required this.homeRed,
    required this.awayRed,
    required this.homeCorner,
    required this.awayCorner,
  });

  final int homeGoals;
  final int awayGoals;
  final int homeYellow;
  final int awayYellow;
  final int homeRed;
  final int awayRed;
  final int homeCorner;
  final int awayCorner;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeStats &&
          homeGoals == other.homeGoals &&
          awayGoals == other.awayGoals &&
          homeYellow == other.homeYellow &&
          awayYellow == other.awayYellow &&
          homeRed == other.homeRed &&
          awayRed == other.awayRed &&
          homeCorner == other.homeCorner &&
          awayCorner == other.awayCorner;

  @override
  int get hashCode => Object.hash(
        homeGoals,
        awayGoals,
        homeYellow,
        awayYellow,
        homeRed,
        awayRed,
        homeCorner,
        awayCorner,
      );
}

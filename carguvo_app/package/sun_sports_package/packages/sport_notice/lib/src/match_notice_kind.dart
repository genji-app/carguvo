enum MatchNoticeKind {
  goal,

  redCard,

  yellowCard,

  corner;

  int get priority => switch (this) {
        MatchNoticeKind.corner => 0,
        MatchNoticeKind.yellowCard => 1,
        MatchNoticeKind.redCard => 2,
        MatchNoticeKind.goal => 3,
      };
}

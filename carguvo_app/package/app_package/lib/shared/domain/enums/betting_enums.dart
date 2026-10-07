enum BettingTab { all, mine, bigWin }

enum OddsChangeDirection {
  none,

  up,

  down,
}

enum BetColumnType {
  handicap,
  overUnder,
  matchResult,
  handicapH1,
  overUnderH1,
  matchResultH1,
}

extension BetColumnTypeX on BetColumnType {
  String get title {
    switch (this) {
      case BetColumnType.handicap:
        return 'Kèo chấp';
      case BetColumnType.overUnder:
        return 'Tài xỉu';
      case BetColumnType.matchResult:
        return '1X2';
      case BetColumnType.handicapH1:
        return 'Kèo chấp H1';
      case BetColumnType.overUnderH1:
        return 'Tài xỉu H1';
      case BetColumnType.matchResultH1:
        return '1X2 H1';
    }
  }
}

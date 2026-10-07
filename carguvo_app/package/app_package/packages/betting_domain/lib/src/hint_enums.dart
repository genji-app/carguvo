library;

enum MarketCategory {
  unknown,
  asianHandicap,
  overUnder,
  market1X2,
  oddEven,
  correctScore,
  totalScore,
  totalGoalsExactly,
  doubleChance,
  cornerHandicap,
  cornerOverUnder,
  corner1X2,
  cornerOddEven,
  cornerRange,
  nextCorner,
  europeanHandicapCorner,
  cornerOverExactlyUnder,
  bookingsHandicap,
  bookingsOverUnder,
  bookings1X2,
  yellowCards1X2,
  yellowCardsOverUnder,
  yellowCardsDoubleChance,
  toQualify,
  penaltyWinner,
  penaltyTotal,
  nextGoal,
  lastGoal,
  drawNoBet,
  lastCorner,
  homeOddEven,
  awayOddEven,
  homeCleanSheet,
  awayCleanSheet,
  homeOverUnder,
  awayOverUnder,
  whichTeamKickOff,
  whichTeamToScore,
  playerGoalscorer,
  outright,
  moneyLine,
  halfTimeFullTime,
  restOfMatchWinner,
  europeanNextGoal,
  europeanHandicapGoal,
  winToNil,
  highestScoringHalf,
  exactCorner,
  nextCorner3Way,
  nextPenaltyScored,
  combo,
}

enum Period {
  fullTime,
  halfTime,
  secondHalf,
  extraFT,
  extraHT,
  penalty,
}

enum HintTeamType { none, home, away, draw, over, under, odd, even }

enum HintType {
  asianHandicapRound,
  asianHandicapHalf,
  asianHandicapQuarterOver,
  asianHandicapQuarterUnder,
  asianHandicap3QuarterOver,
  asianHandicap3QuarterUnder,
  overUnderRound,
  overUnderHalf,
  overUnderQuarter,
  overUnder3Quarter,

  cornerHandicapRound,
  cornerHandicapHalf,
  cornerHandicapQuarter,
  cornerHandicap3Quarter,
  cornerOverUnderRound,
  cornerOverUnderHalf,
  cornerOverUnderQuarter,
  cornerOverUnder3Quarter,

  bookingsHandicapRound,
  bookingsHandicapHalf,
  bookingsOverUnderRound,
  bookingsOverUnderHalf,

  market1X2,
  oddEven,
  doubleChance,
  correctScore,
  totalScore,
  drawNoBet,
  nextGoal,
  lastGoal,
  moneyLine,
  outright,

  unknown,
}

extension PeriodExtension on Period {
  String get text {
    switch (this) {
      case Period.fullTime:
        return 'toàn trận';
      case Period.halfTime:
        return 'hiệp 1';
      case Period.secondHalf:
        return 'hiệp 2';
      case Period.extraFT:
        return '2 hiệp phụ';
      case Period.extraHT:
        return 'hiệp phụ 1';
      case Period.penalty:
        return 'loạt đá luân lưu';
    }
  }

  String get code {
    switch (this) {
      case Period.fullTime:
        return 'FT';
      case Period.halfTime:
        return 'HT';
      case Period.secondHalf:
        return '2H';
      case Period.extraFT:
        return 'ET';
      case Period.extraHT:
        return 'ET1';
      case Period.penalty:
        return 'PEN';
    }
  }
}

extension MarketCategoryExtension on MarketCategory {
  String get name {
    switch (this) {
      case MarketCategory.asianHandicap:
        return 'Kèo Châu Á';
      case MarketCategory.overUnder:
        return 'Tài Xỉu';
      case MarketCategory.market1X2:
        return 'Kèo 1X2';
      case MarketCategory.oddEven:
        return 'Lẻ/Chẵn';
      case MarketCategory.correctScore:
        return 'Tỷ số chính xác';
      case MarketCategory.totalScore:
        return 'Tổng bàn thắng';
      case MarketCategory.totalGoalsExactly:
        return 'Tổng bàn thắng chính xác';
      case MarketCategory.doubleChance:
        return 'Cơ hội kép';
      case MarketCategory.cornerHandicap:
        return 'Phạt góc chấp';
      case MarketCategory.cornerOverUnder:
        return 'Phạt góc Tài Xỉu';
      case MarketCategory.corner1X2:
        return 'Phạt góc 1X2';
      case MarketCategory.cornerOddEven:
        return 'Phạt góc Lẻ/Chẵn';
      case MarketCategory.cornerRange:
        return 'Tổng phạt góc';
      case MarketCategory.nextCorner:
        return 'Phạt góc tiếp theo';
      case MarketCategory.europeanHandicapCorner:
        return 'Chấp phạt góc châu Âu';
      case MarketCategory.cornerOverExactlyUnder:
        return 'Phạt góc Tài/Chính xác/Xỉu';
      case MarketCategory.bookingsHandicap:
        return 'Thẻ phạt chấp';
      case MarketCategory.bookingsOverUnder:
        return 'Thẻ phạt Tài Xỉu';
      case MarketCategory.bookings1X2:
        return 'Thẻ phạt 1X2';
      case MarketCategory.yellowCards1X2:
        return 'Thẻ vàng 1X2';
      case MarketCategory.yellowCardsOverUnder:
        return 'Thẻ vàng Tài Xỉu';
      case MarketCategory.yellowCardsDoubleChance:
        return 'Thẻ vàng cơ hội kép';
      case MarketCategory.toQualify:
        return 'Đội vào vòng trong';
      case MarketCategory.penaltyWinner:
        return 'Đội thắng Penalty';
      case MarketCategory.penaltyTotal:
        return 'Tài Xỉu Penalty';
      case MarketCategory.drawNoBet:
        return 'Hòa hoàn tiền';
      case MarketCategory.nextGoal:
        return 'Bàn thắng kế tiếp';
      case MarketCategory.lastGoal:
        return 'Bàn thắng cuối';
      case MarketCategory.lastCorner:
        return 'Phạt góc cuối cùng';
      case MarketCategory.homeOddEven:
        return 'Đội nhà Lẻ/Chẵn';
      case MarketCategory.awayOddEven:
        return 'Đội khách Lẻ/Chẵn';
      case MarketCategory.homeCleanSheet:
        return 'Đội nhà giữ sạch lưới';
      case MarketCategory.awayCleanSheet:
        return 'Đội khách giữ sạch lưới';
      case MarketCategory.homeOverUnder:
        return 'Tài Xỉu Đội nhà';
      case MarketCategory.awayOverUnder:
        return 'Tài Xỉu Đội khách';
      case MarketCategory.whichTeamKickOff:
        return 'Đội giao bóng trước';
      case MarketCategory.whichTeamToScore:
        return 'Đội ghi bàn';
      case MarketCategory.playerGoalscorer:
        return 'Cầu thủ ghi bàn';
      case MarketCategory.outright:
        return 'Vô địch giải đấu';
      case MarketCategory.moneyLine:
        return 'Money Line';
      case MarketCategory.halfTimeFullTime:
        return 'Hiệp 1/Toàn trận';
      case MarketCategory.restOfMatchWinner:
        return 'Đội thắng thời gian còn lại';
      case MarketCategory.europeanNextGoal:
        return 'Đội tiếp theo ghi bàn (Châu Âu)';
      case MarketCategory.europeanHandicapGoal:
        return 'Kèo chấp châu Âu';
      case MarketCategory.winToNil:
        return 'Thắng giữ sạch lưới';
      case MarketCategory.highestScoringHalf:
        return 'Hiệp nhiều bàn thắng nhất';
      case MarketCategory.exactCorner:
        return 'Số phạt góc chính xác';
      case MarketCategory.nextCorner3Way:
        return 'Phạt góc tiếp theo (3 cửa)';
      case MarketCategory.nextPenaltyScored:
        return 'Quả phạt đền tiếp theo ghi bàn';
      case MarketCategory.combo:
        return 'Kèo tổ hợp';
      case MarketCategory.unknown:
        return 'Unknown';
    }
  }
}

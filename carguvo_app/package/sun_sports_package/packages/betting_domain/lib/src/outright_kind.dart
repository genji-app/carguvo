library;

enum OutrightKind {
  champion,
  groupWinner,
  player,
  team,
  goalscorerAnytime,
  goalscorerFirst,
  goalscorerLast,
  hatTrick,
  matchSpecial,
}

OutrightKind outrightKindFromName(String lineName) {
  final n = lineName.toLowerCase();
  if (n.contains('golden ball') ||
      n.contains('golden boot') ||
      n.contains('golden glove') ||
      n.contains('top scorer') ||
      n.contains('top goalscorer') ||
      n.contains('quả bóng vàng') ||
      n.contains('chiếc giày vàng') ||
      n.contains('găng tay vàng') ||
      n.contains('thủ môn') ||
      n.contains('vua phá lưới')) {
    return OutrightKind.player;
  }
  if (n.contains('reach the final') ||
      n.contains('reach final') ||
      n.contains('chung kết')) {
    return OutrightKind.team;
  }
  if (n.contains('group') ||
      n.contains('nhất bảng') ||
      n.contains('đầu bảng') ||
      n.contains('vô địch bảng')) {
    return OutrightKind.groupWinner;
  }
  if (n.contains('anytime goalscorer') ||
      (n.contains('ghi bàn') && n.contains('bất kỳ'))) {
    return OutrightKind.goalscorerAnytime;
  }
  if (n.contains('first goalscorer') ||
      (n.contains('ghi bàn') && n.contains('đầu tiên'))) {
    return OutrightKind.goalscorerFirst;
  }
  if (n.contains('last goalscorer') ||
      (n.contains('ghi bàn') && n.contains('cuối cùng'))) {
    return OutrightKind.goalscorerLast;
  }
  if (n.contains('hat-trick') || n.contains('hat trick')) {
    return OutrightKind.hatTrick;
  }
  if (n.contains('goalscorer') || n.contains('to score')) {
    return OutrightKind.matchSpecial;
  }
  if (n.contains('cầu thủ')) {
    return OutrightKind.player;
  }
  if (n.contains('special market') || n.contains('kèo đặc biệt')) {
    return OutrightKind.matchSpecial;
  }
  return OutrightKind.champion;
}


abstract class BasketballGamePart {
  static const int rtPause = 4;
  static const int secondHalf = 8;
  static const int finished = 16;
  static const int finishRt = 32;
  static const int timeout = 157;
  static const int quarterBreak = 2000;
  static const int firstQuarter = 2001;
  static const int secondQuarter = 2002;
  static const int thirdQuarter = 2003;
  static const int fourthQuarter = 2004;
  static const int overtime = 2005;
  static const int overtimeBreak = 2006;
  static const int halfTimeBreak = 2008;
}

abstract class TennisGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int set6 = 6;
  static const int set7 = 7;
  static const int game = 60;
  static const int tieBreak = 61;
  static const int breakTime = 80;
  static const int fullTime = 100;
}

abstract class VolleyballGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int totalPoints = 8;
  static const int goldenSet = 50;
  static const int fullTime = 100;
}

abstract class TableTennisGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int set6 = 6;
  static const int set7 = 7;
  static const int totalPoints = 9;
  static const int fullTime = 100;
}

String resolveLivePeriodLabel({
  required int sportId,
  required int gamePart,
  int? currentSet,
}) {
  switch (sportId) {
    case 2:
      return _basketball(gamePart);
    case 4:
      return _tennis(gamePart);
    case 5:
      return _volleyball(gamePart, currentSet);
    case 6:
      return _tableTennis(gamePart);
    case 7:
      return _badminton(currentSet);
    default:
      return '';
  }
}

String _basketball(int gamePart) {
  return switch (gamePart) {
    BasketballGamePart.firstQuarter => 'Hiệp 1',
    BasketballGamePart.secondQuarter => 'Hiệp 2',
    BasketballGamePart.thirdQuarter => 'Hiệp 3',
    BasketballGamePart.fourthQuarter => 'Hiệp 4',
    BasketballGamePart.overtime => 'Hiệp phụ',
    BasketballGamePart.overtimeBreak => 'Nghỉ hiệp phụ',
    BasketballGamePart.rtPause => 'Nghỉ giữa hiệp',
    BasketballGamePart.halfTimeBreak => 'Nghỉ giữa hiệp',
    BasketballGamePart.quarterBreak => 'Thời gian nghỉ',
    BasketballGamePart.secondHalf => 'Giữa hiệp 2',
    BasketballGamePart.finished => 'Kết thúc',
    BasketballGamePart.finishRt => 'Finish RT',
    BasketballGamePart.timeout => 'Hết giờ',
    _ => '',
  };
}

String _tennis(int gamePart) {
  return switch (gamePart) {
    TennisGamePart.set1 => 'Set 1',
    TennisGamePart.set2 => 'Set 2',
    TennisGamePart.set3 => 'Set 3',
    TennisGamePart.set4 => 'Set 4',
    TennisGamePart.set5 => 'Set 5',
    TennisGamePart.set6 => 'Set 6',
    TennisGamePart.set7 => 'Set 7',
    TennisGamePart.game => 'Toàn trận',
    TennisGamePart.tieBreak => 'Tie-break',
    TennisGamePart.breakTime => 'Nghỉ',
    TennisGamePart.fullTime => 'Hết trận',
    _ => '',
  };
}

String _volleyball(int gamePart, int? currentSet) {
  if (gamePart == VolleyballGamePart.goldenSet) return 'Set vàng';
  if (gamePart == VolleyballGamePart.fullTime) return 'Hết trận';
  if (currentSet != null && currentSet > 0) return 'Set $currentSet';
  return '';
}

String _tableTennis(int gamePart) {
  return switch (gamePart) {
    TableTennisGamePart.set1 => 'Set 1',
    TableTennisGamePart.set2 => 'Set 2',
    TableTennisGamePart.set3 => 'Set 3',
    TableTennisGamePart.set4 => 'Set 4',
    TableTennisGamePart.set5 => 'Set 5',
    TableTennisGamePart.set6 => 'Set 6',
    TableTennisGamePart.set7 => 'Set 7',
    TableTennisGamePart.fullTime => 'Hết trận',
    _ => '',
  };
}

String _badminton(int? currentSet) {
  if (currentSet != null && currentSet > 0) return 'Game $currentSet';
  return '';
}

class LiveTimeDisplay {
  const LiveTimeDisplay({
    this.left,
    this.right,
    this.clockMs,
  });

  final String? left;
  final String? right;
  final int? clockMs;

  bool get hasContent => left != null || right != null;

  bool get hasRight => right != null;

  bool get hasLeft => left != null;

  bool get hasClock => clockMs != null;
}

LiveTimeDisplay resolveLiveTimeDisplay({
  required int sportId,
  required int gamePart,
  int? gameTime,
  int? currentSet,
  int? homeScore,
  int? awayScore,
}) {
  switch (sportId) {
    case 1:
      return _soccerTimeDisplay(gamePart, gameTime);
    case 2:
      return _basketballTimeDisplay(gamePart, gameTime);
    case 4:
      return _tennisTimeDisplay(gamePart);
    case 5:
      return _volleyballTimeDisplay(gamePart, currentSet, homeScore, awayScore);
    case 6:
      return _tableTennisTimeDisplay(gamePart);
    case 7:
      return _badmintonTimeDisplay(currentSet, homeScore, awayScore);
    default:
      return const LiveTimeDisplay();
  }
}

LiveTimeDisplay _soccerTimeDisplay(int gamePart, int? gameTime) {
  final period = resolveLivePeriodLabel(sportId: 1, gamePart: gameTime != null && gameTime >= 60000 ? 2 : gamePart);

  final minute = gameTime != null && gameTime >= 60000 ? (gameTime ~/ 60000).toString() : null;

  final stoppageLabel = _soccerStoppageLabel(gamePart);

  return LiveTimeDisplay(
    left: minute,
    right: stoppageLabel ?? period,
  );
}

String? _soccerStoppageLabel(int? gamePart) => switch (gamePart) {
  2 => 'Bù giờ H1',
  8 => 'Bù giờ H2',
  64 => 'Bù giờ HP1',
  256 => 'Bù giờ HP2',
  _ => null,
};

LiveTimeDisplay _basketballTimeDisplay(int gamePart, int? gameTime) {
  final label = resolveLivePeriodLabel(sportId: 2, gamePart: gamePart);
  return LiveTimeDisplay(
    left: label.isEmpty ? null : label,
    clockMs: gameTime,
  );
}

LiveTimeDisplay _tennisTimeDisplay(int gamePart) {
  final label = resolveLivePeriodLabel(sportId: 4, gamePart: gamePart);
  return LiveTimeDisplay(
    left: label.isEmpty ? null : label,
  );
}

LiveTimeDisplay _volleyballTimeDisplay(
  int gamePart,
  int? currentSet,
  int? homeScore,
  int? awayScore,
) {
  final label = resolveLivePeriodLabel(sportId: 5, gamePart: gamePart, currentSet: currentSet);
  final scoreText = (homeScore != null && awayScore != null) ? '$homeScore-$awayScore' : null;
  return LiveTimeDisplay(
    left: label.isEmpty ? null : label,
    right: scoreText,
  );
}

LiveTimeDisplay _tableTennisTimeDisplay(int gamePart) {
  final label = resolveLivePeriodLabel(sportId: 6, gamePart: gamePart);
  return LiveTimeDisplay(
    left: label.isEmpty ? null : label,
  );
}

LiveTimeDisplay _badmintonTimeDisplay(int? currentSet, int? homeScore, int? awayScore) {
  final label = resolveLivePeriodLabel(sportId: 7, gamePart: 0, currentSet: currentSet);
  final scoreText = (homeScore != null && awayScore != null) ? '$homeScore-$awayScore' : null;
  return LiveTimeDisplay(
    left: label.isEmpty ? null : label,
    right: scoreText,
  );
}

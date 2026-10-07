library;

enum OddsStyle {
  malay(0, 'MY'),
  indo(1, 'ID'),
  decimal(2, 'DE'),
  hongKong(3, 'HK');

  final int value;
  final String shortName;
  const OddsStyle(this.value, this.shortName);

  static OddsStyle fromInt(int value) {
    return OddsStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OddsStyle.malay,
    );
  }

  static OddsStyle fromShortName(String? name) {
    if (name == null) return OddsStyle.decimal;

    for (final style in OddsStyle.values) {
      if (style.shortName == name) return style;
    }

    switch (name.toLowerCase()) {
      case 'malay':
        return OddsStyle.malay;
      case 'indo':
        return OddsStyle.indo;
      case 'decimal':
        return OddsStyle.decimal;
      case 'hongkong':
        return OddsStyle.hongKong;
      default:
        return OddsStyle.decimal;
    }
  }
}

enum OddsType {
  none(0),
  home(1),
  away(2),
  draw(3);

  final int value;
  const OddsType(this.value);
}

enum GamePart {
  notStarted(0),
  firstHalf(2),
  halfTime(4),
  secondHalf(8),
  finished(16),
  regulaTimeFinished(32),
  firstHalfExtraTime(64),
  halfTimeOfExtraTime(128),
  secondHalfExtraTime(256),
  extraTimeFinished(512),
  penalties(1024);

  final int value;
  const GamePart(this.value);

  static GamePart fromInt(int? value) {
    if (value == null || value == 0) return GamePart.notStarted;

    try {
      return GamePart.values.firstWhere(
        (e) => e.value == value,
        orElse: () => GamePart.notStarted,
      );
    } catch (_) {
      return GamePart.notStarted;
    }
  }

  String get displayName {
    switch (this) {
      case GamePart.notStarted:
        return 'Not Started';
      case GamePart.firstHalf:
        return 'Hiệp 1';
      case GamePart.halfTime:
        return 'HT';
      case GamePart.secondHalf:
        return 'Hiệp 2';
      case GamePart.finished:
        return 'FT';
      case GamePart.regulaTimeFinished:
        return "90'";
      case GamePart.firstHalfExtraTime:
        return 'ET1';
      case GamePart.halfTimeOfExtraTime:
        return 'ET-HT';
      case GamePart.secondHalfExtraTime:
        return 'ET2';
      case GamePart.extraTimeFinished:
        return 'AET';
      case GamePart.penalties:
        return 'PEN';
    }
  }

  static GamePart resolveLive(int? gamePart, {int gameTimeMinutes = 0}) {
    final exact = GamePart.fromInt(gamePart);
    if (exact != GamePart.notStarted) return exact;

    if (gameTimeMinutes > 0) {
      if (gameTimeMinutes <= 45) return GamePart.firstHalf;
      if (gameTimeMinutes <= 90) return GamePart.secondHalf;
      return GamePart.firstHalfExtraTime;
    }
    return GamePart.notStarted;
  }

  bool get isPlaying =>
      this == GamePart.firstHalf ||
      this == GamePart.secondHalf ||
      this == GamePart.firstHalfExtraTime ||
      this == GamePart.secondHalfExtraTime;

  String get shortCode {
    switch (this) {
      case GamePart.notStarted:
        return '';
      case GamePart.firstHalf:
        return '1H';
      case GamePart.halfTime:
        return 'HT';
      case GamePart.secondHalf:
        return '2H';
      case GamePart.finished:
        return 'FT';
      case GamePart.regulaTimeFinished:
        return "90'";
      case GamePart.firstHalfExtraTime:
        return 'ET1';
      case GamePart.halfTimeOfExtraTime:
        return 'ET-HT';
      case GamePart.secondHalfExtraTime:
        return 'ET2';
      case GamePart.extraTimeFinished:
        return 'AET';
      case GamePart.penalties:
        return 'PEN';
    }
  }

  String get viPeriodLabel {
    switch (this) {
      case GamePart.notStarted:
        return '';
      case GamePart.firstHalf:
        return 'Hiệp 1';
      case GamePart.halfTime:
        return 'Hết hiệp 1';
      case GamePart.secondHalf:
        return 'Hiệp 2';
      case GamePart.finished:
        return 'Trận đấu kết thúc';
      case GamePart.regulaTimeFinished:
        return 'Hết hiệp chính';
      case GamePart.firstHalfExtraTime:
        return 'Hiệp phụ 1';
      case GamePart.halfTimeOfExtraTime:
        return 'Hết hiệp phụ 1';
      case GamePart.secondHalfExtraTime:
        return 'Hiệp phụ 2';
      case GamePart.extraTimeFinished:
        return 'Hết hiệp phụ';
      case GamePart.penalties:
        return 'Penalty';
    }
  }

  String? get stoppageLabel {
    switch (this) {
      case GamePart.firstHalf:
        return 'Bù giờ H1';
      case GamePart.secondHalf:
        return 'Bù giờ H2';
      case GamePart.firstHalfExtraTime:
        return 'Bù giờ HP1';
      case GamePart.secondHalfExtraTime:
        return 'Bù giờ HP2';
      default:
        return null;
    }
  }
}

enum EventStatus {
  active('ACTIVE'),

  suspended('SUSPENDED'),

  hidden('HIDDEN'),

  autoHidden('AUTO_HIDDEN'),

  finished('FINISHED');

  final String value;
  const EventStatus(this.value);

  static EventStatus fromString(String? value) {
    if (value == null) return EventStatus.active;
    final upperValue = value.toUpperCase();
    return EventStatus.values.firstWhere(
      (s) => s.value == upperValue,
      orElse: () => EventStatus.active,
    );
  }

  bool get canBet => this == EventStatus.active;

  bool get isVisible =>
      this != EventStatus.hidden && this != EventStatus.autoHidden;

  bool get isLocked => this != EventStatus.active;

  bool get isSuspendedStatus => this == EventStatus.suspended;

  bool get isHiddenStatus =>
      this == EventStatus.hidden || this == EventStatus.autoHidden;
}

class EventData {
  final int eventId;

  final int leagueId;

  final int sportId;

  String homeName;

  String awayName;

  int homeId;

  int awayId;

  String? homeLogo;

  String? awayLogo;

  String status;

  EventStatus get statusEnum => EventStatus.fromString(status);

  bool get canBet => statusEnum.canBet;

  bool get isLocked => statusEnum.isLocked;

  bool isLive;

  bool isGoingLive;

  bool isLiveStream;

  bool isHot;

  bool isSuspended;

  DateTime? startDate;

  int? eventStatsId;

  int? homeScore;

  int? awayScore;

  int? previousHomeScore;

  int? previousAwayScore;

  int? gameTime;

  int? gamePart;

  int? stoppageTime;

  int? currentSet;

  List<(String, String)>? liveScores;

  int? homeTotalPoint;

  int? awayTotalPoint;

  String? homeCurrentPoint;

  String? awayCurrentPoint;

  int? redCardsHome;

  int? redCardsAway;

  int? yellowCardsHome;

  int? yellowCardsAway;

  int? cornersHome;

  int? cornersAway;

  String? homeScoreH1;

  String? awayScoreH1;

  int? homeScoreOT;

  int? awayScoreOT;

  int? regHomeScore;

  int? regAwayScore;

  int totalMarketsCount;

  bool isParlay;

  bool isCashOut;

  int type;

  int _version = 0;

  int get version => _version;

  int lastSocketTouchMs = 0;

  static int compareByStartThenId(EventData a, EventData b) {
    final aTime = a.startDate?.millisecondsSinceEpoch ?? 0;
    final bTime = b.startDate?.millisecondsSinceEpoch ?? 0;
    final t = aTime.compareTo(bTime);
    if (t != 0) return t;
    return a.eventId.compareTo(b.eventId);
  }

  EventData({
    required this.eventId,
    required this.leagueId,
    required this.sportId,
    required this.homeName,
    required this.awayName,
    this.homeId = 0,
    this.awayId = 0,
    this.homeLogo,
    this.awayLogo,
    this.status = 'ACTIVE',
    this.isLive = false,
    this.isGoingLive = false,
    this.isLiveStream = false,
    this.isHot = false,
    this.isSuspended = false,
    this.startDate,
    this.eventStatsId,
    this.homeScore,
    this.awayScore,
    this.gameTime,
    this.gamePart,
    this.stoppageTime,
    this.currentSet,
    this.liveScores,
    this.homeTotalPoint,
    this.awayTotalPoint,
    this.homeCurrentPoint,
    this.awayCurrentPoint,
    this.redCardsHome,
    this.redCardsAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.cornersHome,
    this.cornersAway,
    this.homeScoreH1,
    this.awayScoreH1,
    this.homeScoreOT,
    this.awayScoreOT,
    this.totalMarketsCount = 0,
    this.isParlay = false,
    this.isCashOut = false,
    this.type = 0,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    final eventId = _parseInt(json['eventId'] ?? json['ei']) ?? 0;
    final leagueId = _parseInt(json['leagueId'] ?? json['li']) ?? 0;
    final sportId = _parseInt(json['sportId'] ?? json['s']) ?? 0;

    final event = EventData(
      eventId: eventId,
      leagueId: leagueId,
      sportId: sportId,
      homeName: json['homeName']?.toString() ?? json['hn']?.toString() ?? '',
      awayName: json['awayName']?.toString() ?? json['an']?.toString() ?? '',
    );

    event._applyJson(json);
    return event;
  }

  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    if (data.containsKey('homeName') || data.containsKey('hn')) {
      homeName =
          data['homeName']?.toString() ?? data['hn']?.toString() ?? homeName;
    }
    if (data.containsKey('awayName') || data.containsKey('an')) {
      awayName =
          data['awayName']?.toString() ?? data['an']?.toString() ?? awayName;
    }
    if (data.containsKey('homeId') || data.containsKey('hi')) {
      homeId = _parseInt(data['homeId'] ?? data['hi']) ?? homeId;
    }
    if (data.containsKey('awayId') || data.containsKey('ai')) {
      awayId = _parseInt(data['awayId'] ?? data['ai']) ?? awayId;
    }

    if (data.containsKey('hf') || data.containsKey('hl')) {
      homeLogo = data['hf']?.toString() ?? data['hl']?.toString();
    }
    if (data.containsKey('af') || data.containsKey('al')) {
      awayLogo = data['af']?.toString() ?? data['al']?.toString();
    }

    if (data.containsKey('status') || data.containsKey('es')) {
      status = data['status']?.toString() ?? data['es']?.toString() ?? status;
    }
    if (data.containsKey('isLive') || data.containsKey('l')) {
      isLive = _parseBool(data['isLive'] ?? data['l']);
    }
    if (data.containsKey('isGoingLive') || data.containsKey('gl')) {
      isGoingLive = _parseBool(data['isGoingLive'] ?? data['gl']);
    }
    if (data.containsKey('isLiveStream') || data.containsKey('ls')) {
      isLiveStream = _parseBool(data['isLiveStream'] ?? data['ls']);
    }
    if (data.containsKey('isSuspended') || data.containsKey('s')) {
      isSuspended = _parseBool(data['isSuspended'] ?? data['s']);
    }

    if (data.containsKey('startDate') ||
        data.containsKey('st') ||
        data.containsKey('et')) {
      final dateValue = data['startDate'] ?? data['st'] ?? data['et'];
      startDate = _parseDateTime(dateValue);
    }

    if (data.containsKey('eventStatsId') || data.containsKey('esi')) {
      eventStatsId = _parseInt(data['eventStatsId'] ?? data['esi']);
    }

    if (data.containsKey('homeScore') || data.containsKey('hs')) {
      homeScore = _parseInt(data['homeScore'] ?? data['hs']);
    }
    if (data.containsKey('awayScore') || data.containsKey('as')) {
      awayScore = _parseInt(data['awayScore'] ?? data['as']);
    }
    if (data.containsKey('gameTime') || data.containsKey('gt')) {
      gameTime = _parseInt(data['gameTime'] ?? data['gt']);
    }
    if (data.containsKey('gamePart') || data.containsKey('gp')) {
      gamePart = _parseInt(data['gamePart'] ?? data['gp']);
    }
    if (data.containsKey('stoppageTime') || data.containsKey('stm')) {
      stoppageTime = _parseInt(data['stoppageTime'] ?? data['stm']);
    }
    if (data.containsKey('currentSet')) {
      currentSet = _parseInt(data['currentSet']);
    }
    if (data.containsKey('liveScores')) {
      liveScores = _parseLiveScores(data['liveScores']);
    }
    if (data.containsKey('homeTotalPoint')) {
      homeTotalPoint = _parseInt(data['homeTotalPoint']);
    }
    if (data.containsKey('awayTotalPoint')) {
      awayTotalPoint = _parseInt(data['awayTotalPoint']);
    }
    if (data.containsKey('homeCurrentPoint')) {
      homeCurrentPoint = data['homeCurrentPoint']?.toString();
    }
    if (data.containsKey('awayCurrentPoint')) {
      awayCurrentPoint = data['awayCurrentPoint']?.toString();
    }

    if (data.containsKey('redCardsHome') || data.containsKey('rch')) {
      redCardsHome = _parseInt(data['redCardsHome'] ?? data['rch']);
    }
    if (data.containsKey('redCardsAway') || data.containsKey('rca')) {
      redCardsAway = _parseInt(data['redCardsAway'] ?? data['rca']);
    }
    if (data.containsKey('yellowCardsHome') || data.containsKey('ych')) {
      yellowCardsHome = _parseInt(data['yellowCardsHome'] ?? data['ych']);
    }
    if (data.containsKey('yellowCardsAway') || data.containsKey('yca')) {
      yellowCardsAway = _parseInt(data['yellowCardsAway'] ?? data['yca']);
    }

    if (data.containsKey('cornersHome') || data.containsKey('hc')) {
      cornersHome = _parseInt(data['cornersHome'] ?? data['hc']);
    }
    if (data.containsKey('cornersAway') || data.containsKey('ac')) {
      cornersAway = _parseInt(data['cornersAway'] ?? data['ac']);
    }

    if (data.containsKey('homeScoreH1')) {
      homeScoreH1 = data['homeScoreH1']?.toString();
    }
    if (data.containsKey('awayScoreH1')) {
      awayScoreH1 = data['awayScoreH1']?.toString();
    }

    if (data.containsKey('homeScoreOT') || data.containsKey('hso')) {
      homeScoreOT = _parseInt(data['homeScoreOT'] ?? data['hso']);
    }
    if (data.containsKey('awayScoreOT') || data.containsKey('aso')) {
      awayScoreOT = _parseInt(data['awayScoreOT'] ?? data['aso']);
    }

    if (data.containsKey('totalMarketsCount') || data.containsKey('mc')) {
      totalMarketsCount = _parseInt(data['totalMarketsCount'] ?? data['mc']) ??
          totalMarketsCount;
    }
    if (data.containsKey('isParlay') || data.containsKey('ip')) {
      isParlay = _parseBool(data['isParlay'] ?? data['ip']);
    }
    if (data.containsKey('isCashOut') || data.containsKey('ico')) {
      isCashOut = _parseBool(data['isCashOut'] ?? data['ico']);
    }
    if (data.containsKey('type')) {
      type = _parseInt(data['type']) ?? type;
    }

    trackRegulationBaseline();
  }

  void trackRegulationBaseline() {
    if (sportId != 1) return;
    final h = homeScore;
    final a = awayScore;
    if ((gamePart ?? 0) <= 32) {
      if (h != null) regHomeScore = h;
      if (a != null) regAwayScore = a;
    } else {
      if (h != null && (regHomeScore == null || h < regHomeScore!)) {
        regHomeScore = h;
      }
      if (a != null && (regAwayScore == null || a < regAwayScore!)) {
        regAwayScore = a;
      }
    }
  }

  int? get displayHomeScore {
    if (sportId == 1 && (gamePart ?? 0) > 32) {
      final base = regHomeScore ?? homeScore;
      if (base == null && homeScoreOT == null) return null;
      return (base ?? 0) + (homeScoreOT ?? 0);
    }
    return homeScore;
  }

  int? get displayAwayScore {
    if (sportId == 1 && (gamePart ?? 0) > 32) {
      final base = regAwayScore ?? awayScore;
      if (base == null && awayScoreOT == null) return null;
      return (base ?? 0) + (awayScoreOT ?? 0);
    }
    return awayScore;
  }

  String get scoreDisplay {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore - $awayScore';
  }

  String get timeDisplay {
    if (gameTime == null) return '';
    final minutes = (gameTime! / 60000).floor();
    if (stoppageTime != null && stoppageTime! > 0) {
      return "$minutes'+${stoppageTime!}";
    }
    return "$minutes'";
  }

  String get periodDisplay {
    switch (gamePart) {
      case 2:
        return '1H';
      case 4:
        return 'HT';
      case 8:
        return '2H';
      case 16:
        return 'FT';
      case 32:
        return "90'";
      case 64:
        return 'ET1';
      case 128:
        return 'ET-HT';
      case 256:
        return 'ET2';
      case 512:
        return 'AET';
      case 1024:
        return 'PEN';
      default:
        return '';
    }
  }

  String get fullName => '$homeName vs $awayName';

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static List<(String, String)>? _parseLiveScores(dynamic value) {
    if (value is! List) return null;
    return [
      for (final item in value)
        if (item is Map)
          (
            (item['0'] ?? item['homeScore'])?.toString() ?? '',
            (item['1'] ?? item['awayScore'])?.toString() ?? '',
          )
        else if (item is List && item.length >= 2)
          (item[0]?.toString() ?? '', item[1]?.toString() ?? '')
        else
          ('', ''),
    ];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'EventData(eventId: $eventId, $homeName vs $awayName, '
        'isLive: $isLive, score: $scoreDisplay)';
  }
}

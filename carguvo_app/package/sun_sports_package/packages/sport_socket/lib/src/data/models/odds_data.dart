enum OddsDirection {
  none,

  up,

  down,
}

class OddsData {
  final String offerId;

  final int eventId;

  final int marketId;

  final String timeRange;

  String? points;

  bool isMainLine;

  bool isSuspended;

  int promotionType;

  double? oddsHome;

  double? oddsAway;

  double? oddsDraw;

  double? previousHome;

  double? previousAway;

  double? previousDraw;

  String? malayHome;

  String? malayAway;

  String? hkHome;

  String? hkAway;

  String? indoHome;

  String? indoAway;

  String? malayDraw;

  String? hkDraw;

  String? indoDraw;

  String? selectionIdHome;

  String? selectionIdAway;

  String? selectionIdDraw;

  String? playerName;

  String? playerId;

  int _version = 0;

  int get version => _version;

  OddsData({
    required this.offerId,
    required this.eventId,
    required this.marketId,
    this.timeRange = 'LIVE',
    this.points,
    this.isMainLine = false,
    this.isSuspended = false,
    this.promotionType = 0,
    this.oddsHome,
    this.oddsAway,
    this.oddsDraw,
    this.malayHome,
    this.malayAway,
    this.hkHome,
    this.hkAway,
    this.indoHome,
    this.indoAway,
    this.malayDraw,
    this.hkDraw,
    this.indoDraw,
    this.selectionIdHome,
    this.selectionIdAway,
    this.selectionIdDraw,
    this.playerName,
    this.playerId,
  });

  factory OddsData.fromJson(
    Map<String, dynamic> json, {
    required int eventId,
    required int marketId,
    String timeRange = 'LIVE',
  }) {
    final offerId = json['strOfferId']?.toString() ??
        json['offerId']?.toString() ??
        '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final odds = OddsData(
      offerId: offerId,
      eventId: eventId,
      marketId: marketId,
      timeRange: timeRange,
    );

    odds._applyJson(json);
    return odds;
  }

  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    if (data.containsKey('points')) {
      points = data['points']?.toString();
    }

    if (data.containsKey('isMainLine')) {
      isMainLine = data['isMainLine'] == true;
    }
    if (data.containsKey('isSuspended')) {
      isSuspended = data['isSuspended'] == true;
    }
    if (data.containsKey('promotionType')) {
      promotionType = _parseInt(data['promotionType']) ?? 0;
    }

    final oddsMap = data['odds'] as Map<String, dynamic>?;
    if (oddsMap != null) {
      _updateOddsFromMap(oddsMap);
    } else {
      _updateOddsFromMap(data);
    }

    if (data.containsKey('malayHome')) {
      malayHome = data['malayHome']?.toString();
    }
    if (data.containsKey('malayAway')) {
      malayAway = data['malayAway']?.toString();
    }
    if (data.containsKey('hkHome')) {
      hkHome = data['hkHome']?.toString();
    }
    if (data.containsKey('hkAway')) {
      hkAway = data['hkAway']?.toString();
    }
    if (data.containsKey('indoHome')) {
      indoHome = data['indoHome']?.toString();
    }
    if (data.containsKey('indoAway')) {
      indoAway = data['indoAway']?.toString();
    }
    if (data.containsKey('malayDraw')) {
      malayDraw = data['malayDraw']?.toString();
    }
    if (data.containsKey('hkDraw')) {
      hkDraw = data['hkDraw']?.toString();
    }
    if (data.containsKey('indoDraw')) {
      indoDraw = data['indoDraw']?.toString();
    }

    if (data.containsKey('selectionIdHome')) {
      selectionIdHome = data['selectionIdHome']?.toString();
    }
    if (data.containsKey('selectionIdAway')) {
      selectionIdAway = data['selectionIdAway']?.toString();
    }
    if (data.containsKey('selectionIdDraw')) {
      selectionIdDraw = data['selectionIdDraw']?.toString();
    }

    if (data.containsKey('playerName')) {
      playerName = data['playerName']?.toString();
    }
    if (data.containsKey('playerId')) {
      playerId = data['playerId']?.toString();
    }
  }

  void _updateOddsFromMap(Map<String, dynamic> data) {
    final homeData = data['oddsHome'];
    if (homeData != null) {
      previousHome = oddsHome;
      oddsHome = _parseOddsValue(homeData);
    }

    final awayData = data['oddsAway'];
    if (awayData != null) {
      previousAway = oddsAway;
      oddsAway = _parseOddsValue(awayData);
    }

    final drawData = data['oddsDraw'];
    if (drawData != null) {
      previousDraw = oddsDraw;
      oddsDraw = _parseOddsValue(drawData);
    }
  }

  double? _parseOddsValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map) {
      final decimal = value['decimal'];
      if (decimal != null) {
        return _parseOddsValue(decimal);
      }
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  OddsDirection get homeDirection {
    if (previousHome == null || oddsHome == null) return OddsDirection.none;
    if (oddsHome! > previousHome!) return OddsDirection.up;
    if (oddsHome! < previousHome!) return OddsDirection.down;
    return OddsDirection.none;
  }

  OddsDirection get awayDirection {
    if (previousAway == null || oddsAway == null) return OddsDirection.none;
    if (oddsAway! > previousAway!) return OddsDirection.up;
    if (oddsAway! < previousAway!) return OddsDirection.down;
    return OddsDirection.none;
  }

  OddsDirection get drawDirection {
    if (previousDraw == null || oddsDraw == null) return OddsDirection.none;
    if (oddsDraw! > previousDraw!) return OddsDirection.up;
    if (oddsDraw! < previousDraw!) return OddsDirection.down;
    return OddsDirection.none;
  }

  void clearPreviousValues() {
    previousHome = null;
    previousAway = null;
    previousDraw = null;
  }

  String get oddsKey => '${eventId}_${marketId}_$offerId';

  String get marketKey => '${eventId}_$marketId';

  @override
  String toString() {
    return 'OddsData(offerId: $offerId, eventId: $eventId, marketId: $marketId, '
        'home: $oddsHome, away: $oddsAway, draw: $oddsDraw)';
  }
}

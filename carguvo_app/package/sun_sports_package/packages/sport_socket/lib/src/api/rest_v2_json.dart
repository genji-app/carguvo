class RestV2Json {
  RestV2Json._();

  static Map<String, dynamic> leagueJsonV2(
      Map<String, dynamic> json, int sportId) {
    final leagueId = _int(json['3']);
    final rawEvents = json['0'];
    return {
      'leagueId': leagueId,
      'sportId': sportId,
      'leagueName': json['4']?.toString() ?? '',
      'leagueNameEn': json['5']?.toString() ?? '',
      'priorityOrder': _int(json['8']),
      if (json.containsKey('7')) 'leagueOrder': _int(json['7']),
      'leagueLogo': json['6']?.toString() ?? '',
      'events': [
        if (rawEvents is List)
          for (final e in rawEvents)
            if (e is Map)
              _eventJson(Map<String, dynamic>.from(e), leagueId, sportId),
      ],
    };
  }

  static Map<String, dynamic> _eventJson(
      Map<String, dynamic> json, int leagueId, int sportId) {
    final eventId = _int(json['4']);
    final rawMarkets = json['1'];
    final markets = <Map<String, dynamic>>[
      if (rawMarkets is List)
        for (final m in rawMarkets)
          if (m is Map) _marketJson(Map<String, dynamic>.from(m)),
    ];

    Map<String, dynamic>? statusChild;
    final rawChildren = json['0'];
    if (rawChildren is List) {
      for (final item in rawChildren) {
        if (item is! Map) continue;
        final child = Map<String, dynamic>.from(item);
        if (child['34'] == null) continue;
        final childSuspended = child['7'] == true;
        final childMarkets = child['1'];
        if (childMarkets is List) {
          for (final m in childMarkets) {
            if (m is! Map) continue;
            final parsed = _marketJson(Map<String, dynamic>.from(m));
            if (childSuspended) parsed['isSuspended'] = true;
            markets.add(parsed);
          }
        }
        if (_int(child['4']) == eventId &&
            (child.containsKey('30') ||
                child.containsKey('31') ||
                child.containsKey('33'))) {
          statusChild = child;
        }
      }
    }
    final status = statusChild;
    dynamic liveField(String key) =>
        (status != null && status.containsKey(key)) ? status[key] : json[key];

    final rawScore = liveField('33');
    final score = rawScore is Map ? Map<String, dynamic>.from(rawScore) : null;
    final gamePart = _int(liveField('30'));
    final afterRegularTime = gamePart >= 16;
    final anyMarketAvailable = markets
        .any((m) => m['isSuspended'] != true && (m['odds'] as List).isNotEmpty);
    final isSuspended =
        json['7'] == true && (!afterRegularTime || !anyMarketAvailable);

    return {
      'eventId': eventId,
      'leagueId': leagueId,
      'sportId': sportId,
      'homeName': json['19']?.toString() ?? '',
      'awayName': json['20']?.toString() ?? '',
      'homeId': _int(json['17']),
      'awayId': _int(json['18']),
      'homeLogo': json['21']?.toString() ?? '',
      'awayLogo': json['22']?.toString() ?? '',
      'isLive': liveField('28') == true,
      'isGoingLive': liveField('27') == true,
      'isLivestream': liveField('29') == true,
      'isSuspended': isSuspended,
      'startDate': json['5']?.toString() ?? '',
      'totalMarketsCount': _int(json['23']),
      'isParlay': json['9'] == true,
      'isCashOut': json['10'] == true,
      'type': _int(json['11']),
      'eventStatsId': _int(json['14']),
      'gamePart': gamePart,
      'gameTime': _int(liveField('31')),
      'stoppageTime': _int(liveField('32')),
      if (score != null) ..._scoreJson(score),
      'markets': markets,
    };
  }

  static Map<String, dynamic> _scoreJson(Map<String, dynamic> score) {
    const mainScoreKeys = [
      ('100', '101'),
      ('201', '202'),
      ('401', '402'),
      ('501', '502'),
      ('601', '602'),
      ('701', '702')
    ];
    const totalPointKeys = [('503', '504'), ('603', '604'), ('703', '704')];
    const liveScoreListKeys = ['200', '400', '500', '600', '700'];
    const currentSetKeys = ['408', '506', '606', '706'];

    final main = mainScoreKeys
        .where((p) => score.containsKey(p.$1) || score.containsKey(p.$2))
        .firstOrNull;
    final total = totalPointKeys
        .where((p) => score.containsKey(p.$1) || score.containsKey(p.$2))
        .firstOrNull;
    final liveKey = liveScoreListKeys.where(score.containsKey).firstOrNull;
    final setKey = currentSetKeys.where(score.containsKey).firstOrNull;

    return {
      if (main != null) ...{
        'homeScore': _int(score[main.$1]),
        'awayScore': _int(score[main.$2]),
      },
      if (total != null) ...{
        'homeTotalPoint': _int(score[total.$1]),
        'awayTotalPoint': _int(score[total.$2]),
      },
      if (liveKey != null) 'liveScores': score[liveKey],
      if (setKey != null) 'currentSet': _int(score[setKey]),
      if (score.containsKey('405'))
        'homeCurrentPoint': score['405']?.toString(),
      if (score.containsKey('406'))
        'awayCurrentPoint': score['406']?.toString(),
      if (score.containsKey('112')) 'redCardsHome': _int(score['112']),
      if (score.containsKey('113')) 'redCardsAway': _int(score['113']),
      if (score.containsKey('110')) 'yellowCardsHome': _int(score['110']),
      if (score.containsKey('111')) 'yellowCardsAway': _int(score['111']),
      if (score.containsKey('104')) 'cornersHome': _int(score['104']),
      if (score.containsKey('105')) 'cornersAway': _int(score['105']),
      if (score.containsKey('106')) 'homeScoreOT': _int(score['106']),
      if (score.containsKey('107')) 'awayScoreOT': _int(score['107']),
    };
  }

  static Map<String, dynamic> _marketJson(Map<String, dynamic> json) {
    final rawOdds = json['0'];
    return {
      'marketId': _int(json['4']),
      'isSuspended': json['5'] == true,
      'isParlay': json['6'] == true,
      'isCashOut': json['7'] == true,
      'promotionType': _int(json['8']),
      'groupId': _int(json['9']),
      'odds': [
        if (rawOdds is List)
          for (final o in rawOdds)
            if (o is Map) _oddsJson(Map<String, dynamic>.from(o)),
      ],
    };
  }

  static Map<String, dynamic> _oddsJson(Map<String, dynamic> json) {
    return {
      'strOfferId': json['7']?.toString(),
      'points': json['3']?.toString(),
      'isMainLine': json['8'] == true,
      'isSuspended': json['9'] == true,
      'selectionHomeId': json['0']?.toString(),
      'selectionAwayId': json['1']?.toString(),
      'selectionDrawId': json['2']?.toString(),
      'oddsHome': _styleJson(json['4']),
      'oddsAway': _styleJson(json['5']),
      'oddsDraw': _styleJson(json['6']),
      'playerName': json['11']?.toString(),
      'playerId': json['12']?.toString(),
    };
  }

  static Map<String, dynamic>? _styleJson(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    return {
      'de': map['0']?.toString(),
      'ma': map['1']?.toString(),
      'in': map['2']?.toString(),
      'hk': map['3']?.toString(),
    };
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

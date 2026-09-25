import '../data/models/league_data.dart';
import '../data/models/event_data.dart';
import '../data/models/market_data.dart';
import '../data/models/odds_data.dart';
import '../data/sport_data_store.dart';
import '../utils/perf_hooks.dart';

class ModelConverter {
  ModelConverter._();

  static LeagueData fromFreezedLeague(
    Map<String, dynamic> freezed, {
    required int sportId,
  }) {
    return LeagueData(
      leagueId: _parseInt(freezed['li'] ?? freezed['leagueId']) ?? 0,
      sportId: sportId,
      name:
          freezed['ln']?.toString() ?? freezed['leagueName']?.toString() ?? '',
      priorityOrder: _parseInt(freezed['lpo'] ?? freezed['priorityOrder']) ?? 0,
      logoUrl: freezed['lg']?.toString() ?? freezed['leagueLogo']?.toString(),
      cashout: true,
    );
  }

  static EventData fromFreezedEvent(
    Map<String, dynamic> freezed, {
    required int leagueId,
    required int sportId,
  }) {
    return EventData(
      eventId: _parseInt(freezed['ei'] ?? freezed['eventId']) ?? 0,
      leagueId: leagueId,
      sportId: sportId,
      homeName:
          freezed['hn']?.toString() ?? freezed['homeName']?.toString() ?? '',
      awayName:
          freezed['an']?.toString() ?? freezed['awayName']?.toString() ?? '',
      homeId: _parseInt(freezed['hi'] ?? freezed['homeId']) ?? 0,
      awayId: _parseInt(freezed['ai'] ?? freezed['awayId']) ?? 0,
      homeLogo: freezed['hf']?.toString() ??
          freezed['hl']?.toString() ??
          freezed['homeLogoFirst']?.toString() ??
          freezed['homeLogoLast']?.toString(),
      awayLogo: freezed['af']?.toString() ??
          freezed['al']?.toString() ??
          freezed['awayLogoFirst']?.toString() ??
          freezed['awayLogoLast']?.toString(),
      status: freezed['es']?.toString() ??
          freezed['eventStatus']?.toString() ??
          'ACTIVE',
      isLive: _parseBool(freezed['l'] ?? freezed['isLive']),
      isGoingLive: _parseBool(freezed['gl'] ?? freezed['isGoingLive']),
      isLiveStream: _parseBool(freezed['ls'] ?? freezed['isLivestream']),
      isSuspended: _parseBool(freezed['s'] ?? freezed['isSuspended']),
      startDate: _parseDateTime(
          freezed['st'] ?? freezed['et'] ?? freezed['startTime']),
      eventStatsId: _parseInt(freezed['esi'] ?? freezed['eventStatsId']),
      homeScore: _parseInt(freezed['hs'] ?? freezed['homeScore']),
      awayScore: _parseInt(freezed['as'] ?? freezed['awayScore']),
      gameTime: _parseInt(freezed['gt'] ?? freezed['gameTime']),
      gamePart: _parseInt(freezed['gp'] ?? freezed['gamePart']),
      stoppageTime: _parseInt(freezed['stm'] ?? freezed['stoppageTime']),
      redCardsHome: _parseInt(freezed['rch'] ?? freezed['redCardsHome']),
      redCardsAway: _parseInt(freezed['rca'] ?? freezed['redCardsAway']),
      yellowCardsHome: _parseInt(freezed['ych'] ?? freezed['yellowCardsHome']),
      yellowCardsAway: _parseInt(freezed['yca'] ?? freezed['yellowCardsAway']),
      cornersHome: _parseInt(freezed['hc'] ?? freezed['cornersHome']),
      cornersAway: _parseInt(freezed['ac'] ?? freezed['cornersAway']),
      totalMarketsCount:
          _parseInt(freezed['mc'] ?? freezed['totalMarketsCount']) ?? 0,
      isParlay: _parseBool(freezed['ip'] ?? freezed['isParlay']),
    );
  }

  static MarketData fromFreezedMarket(
    Map<String, dynamic> freezed, {
    required int eventId,
  }) {
    return MarketData(
      marketId: _parseInt(freezed['mi'] ?? freezed['marketId']) ?? 0,
      eventId: eventId,
      name: freezed['mn']?.toString() ?? freezed['marketName']?.toString(),
      marketType:
          freezed['mt']?.toString() ?? freezed['marketType']?.toString(),
      status: MarketStatus.active,
    );
  }

  static OddsData fromFreezedOdds(
    Map<String, dynamic> freezed, {
    required int eventId,
    required int marketId,
    required String timeRange,
  }) {
    final points =
        freezed['p']?.toString() ?? freezed['points']?.toString() ?? '';
    final offerId = freezed['soi']?.toString() ??
        freezed['offerId']?.toString() ??
        '${eventId}_${marketId}_$points';

    final oddsHome = _parseOddsValue(freezed['oh'] ?? freezed['oddsHome']);
    final oddsAway = _parseOddsValue(freezed['oa'] ?? freezed['oddsAway']);
    final oddsDraw = _parseOddsValue(freezed['od'] ?? freezed['oddsDraw']);

    return OddsData(
      offerId: offerId,
      eventId: eventId,
      marketId: marketId,
      timeRange: timeRange,
      points: points,
      isMainLine: _parseBool(freezed['ml'] ?? freezed['isMainLine']),
      isSuspended: false,
      promotionType: 0,
      oddsHome: oddsHome?['decimal'],
      oddsAway: oddsAway?['decimal'],
      oddsDraw: oddsDraw?['decimal'],
      malayHome: oddsHome?['malay']?.toString(),
      malayAway: oddsAway?['malay']?.toString(),
      hkHome: oddsHome?['hongKong']?.toString(),
      hkAway: oddsAway?['hongKong']?.toString(),
      indoHome: oddsHome?['indo']?.toString(),
      indoAway: oddsAway?['indo']?.toString(),
      selectionIdHome:
          freezed['shi']?.toString() ?? freezed['selectionHomeId']?.toString(),
      selectionIdAway:
          freezed['sai']?.toString() ?? freezed['selectionAwayId']?.toString(),
      selectionIdDraw:
          freezed['sdi']?.toString() ?? freezed['selectionDrawId']?.toString(),
    );
  }

  static void populateDataStore(
    List<Map<String, dynamic>> freezedLeagues,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
  }) {
    for (final leagueJson in freezedLeagues) {
      final league = fromFreezedLeague(leagueJson, sportId: sportId);
      store.insertLeague(league);

      final events = leagueJson['e'] as List<dynamic>? ??
          leagueJson['events'] as List<dynamic>? ??
          [];
      for (final eventJson in events) {
        if (eventJson is! Map<String, dynamic>) continue;

        final event = fromFreezedEvent(
          eventJson,
          leagueId: league.leagueId,
          sportId: sportId,
        );
        store.insertEvent(event);

        final markets = eventJson['m'] as List<dynamic>? ??
            eventJson['markets'] as List<dynamic>? ??
            [];
        for (final marketJson in markets) {
          if (marketJson is! Map<String, dynamic>) continue;

          final marketId =
              _parseInt(marketJson['mi'] ?? marketJson['marketId']) ?? 0;

          store.upsertMarketFromJson(event.eventId, {
            'marketId': marketId,
            'marketName': marketJson['mn'] ?? marketJson['marketName'],
            'marketType': marketJson['mt'] ?? marketJson['marketType'],
          });

          final odds = marketJson['o'] as List<dynamic>? ??
              marketJson['odds'] as List<dynamic>? ??
              [];
          for (final oddsJson in odds) {
            if (oddsJson is! Map<String, dynamic>) continue;

            final oddsHomeValue =
                _parseOddsValue(oddsJson['oh'] ?? oddsJson['oddsHome']);
            final oddsAwayValue =
                _parseOddsValue(oddsJson['oa'] ?? oddsJson['oddsAway']);
            final oddsDrawValue =
                _parseOddsValue(oddsJson['od'] ?? oddsJson['oddsDraw']);

            store.upsertOddsFromJson(
              event.eventId,
              marketId,
              {
                'strOfferId': oddsJson['soi'] ??
                    oddsJson['offerId'] ??
                    oddsJson['strOfferId'],
                'points': oddsJson['p'] ?? oddsJson['points'],
                'isMainLine': oddsJson['ml'] ?? oddsJson['isMainLine'],
                'selectionIdHome':
                    oddsJson['shi'] ?? oddsJson['selectionHomeId'],
                'selectionIdAway':
                    oddsJson['sai'] ?? oddsJson['selectionAwayId'],
                'selectionIdDraw':
                    oddsJson['sdi'] ?? oddsJson['selectionDrawId'],
                'oddsHome': oddsHomeValue?['decimal'],
                'oddsAway': oddsAwayValue?['decimal'],
                'oddsDraw': oddsDrawValue?['decimal'],
                'malayHome': oddsHomeValue?['malay']?.toString(),
                'malayAway': oddsAwayValue?['malay']?.toString(),
                'hkHome': oddsHomeValue?['hongKong']?.toString(),
                'hkAway': oddsAwayValue?['hongKong']?.toString(),
                'indoHome': oddsHomeValue?['indo']?.toString(),
                'indoAway': oddsAwayValue?['indo']?.toString(),
                'malayDraw': oddsDrawValue?['malay']?.toString(),
                'hkDraw': oddsDrawValue?['hongKong']?.toString(),
                'indoDraw': oddsDrawValue?['indo']?.toString(),
                'playerName': oddsJson['playerName'],
                'playerId': oddsJson['playerId'],
              },
              timeRange: timeRange,
            );
          }
        }
      }
    }
  }

  static PruneStats upsertPopulateDataStore(
    List<Map<String, dynamic>> jsonLeagues,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
    bool prune = false,
    bool markSnapshot = true,
    Set<int>? pruneLeagueScope,
    int protectSocketTouchAfterMs = 0,
  }) {
    assert(
      markSnapshot || !prune || pruneLeagueScope != null,
      'Partial refresh (markSnapshot=false) chỉ được prune khi có '
      'pruneLeagueScope — payload không phải full snapshot của sport, prune '
      'không-scope sẽ xóa sạch phần còn lại.',
    );
    final validEventIds = <int>{};
    final validMarketIdsByEvent = <int, Set<int>>{};
    final validOfferIdsByMarket = <String, Set<String>>{};

    for (final leagueJson in jsonLeagues) {
      _upsertOneLeague(
        leagueJson,
        store,
        sportId: sportId,
        timeRange: timeRange,
        prune: prune,
        validEventIds: validEventIds,
        validMarketIdsByEvent: validMarketIdsByEvent,
        validOfferIdsByMarket: validOfferIdsByMarket,
      );
    }

    if (markSnapshot) {
      store.lastPopulateTimeRange = timeRange;
      store.lastPopulateSportId = sportId;
      store
          .populateGeneration++;
    }

    if (!prune) return PruneStats();

    return store.pruneSportToSnapshot(
      sportId: sportId,
      validEventIds: validEventIds,
      validMarketIdsByEvent: validMarketIdsByEvent,
      validOfferIdsByMarket: validOfferIdsByMarket,
      protectSocketTouchAfterMs: protectSocketTouchAfterMs,
      onlyLeagueIds: pruneLeagueScope,
    );
  }

  static Future<PruneStats> upsertPopulateDataStoreChunked(
    List<Map<String, dynamic>> jsonLeagues,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
    bool prune = false,
    bool markSnapshot = true,
    Set<int>? pruneLeagueScope,
    int protectSocketTouchAfterMs = 0,
    int yieldEvery = 8,
    Duration sliceBudget = const Duration(milliseconds: 4),
    bool Function()? shouldContinue,
  }) async {
    assert(
      markSnapshot || !prune || pruneLeagueScope != null,
      'Partial refresh (markSnapshot=false) chỉ được prune khi có '
      'pruneLeagueScope — payload không phải full snapshot của sport, prune '
      'không-scope sẽ xóa sạch phần còn lại.',
    );
    final validEventIds = <int>{};
    final validMarketIdsByEvent = <int, Set<int>>{};
    final validOfferIdsByMarket = <String, Set<String>>{};

    final wrap = SportSocketPerfHooks.wrap;
    final slice = Stopwatch()..start();
    var sinceYield = 0;
    for (final leagueJson in jsonLeagues) {
      void body() => _upsertOneLeague(
            leagueJson,
            store,
            sportId: sportId,
            timeRange: timeRange,
            prune: prune,
            validEventIds: validEventIds,
            validMarketIdsByEvent: validMarketIdsByEvent,
            validOfferIdsByMarket: validOfferIdsByMarket,
          );
      if (wrap == null) {
        body();
      } else {
        wrap<void>('populate.league', body);
      }
      if (++sinceYield >= yieldEvery || slice.elapsed >= sliceBudget) {
        await Future<void>.delayed(Duration.zero);
        slice.reset();
        sinceYield = 0;
        if (shouldContinue != null && !shouldContinue()) return PruneStats();
      }
    }

    void writeMarker() {
      if (!markSnapshot) return;
      store.lastPopulateTimeRange = timeRange;
      store.lastPopulateSportId = sportId;
      store
          .populateGeneration++;
    }

    if (!prune) {
      writeMarker();
      return PruneStats();
    }

    final stats = await store.pruneSportToSnapshotChunked(
      sportId: sportId,
      validEventIds: validEventIds,
      validMarketIdsByEvent: validMarketIdsByEvent,
      validOfferIdsByMarket: validOfferIdsByMarket,
      protectSocketTouchAfterMs: protectSocketTouchAfterMs,
      onlyLeagueIds: pruneLeagueScope,
      sliceBudget: sliceBudget,
      yieldEvery: yieldEvery,
      shouldContinue: shouldContinue,
    );
    if (shouldContinue != null && !shouldContinue()) return stats;

    writeMarker();
    return stats;
  }

  static void _upsertOneLeague(
    Map<String, dynamic> leagueJson,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
    required bool prune,
    required Set<int> validEventIds,
    required Map<int, Set<int>> validMarketIdsByEvent,
    required Map<String, Set<String>> validOfferIdsByMarket,
  }) {
    final leagueId = _parseInt(leagueJson['li'] ?? leagueJson['leagueId']) ?? 0;
    if (leagueId == 0) return;

    store.upsertLeagueFromJson({
      'leagueId': leagueId,
      'sportId': sportId,
      'leagueName': leagueJson['ln'] ?? leagueJson['leagueName'],
      'leagueNameEn': leagueJson['lne'] ?? leagueJson['leagueNameEn'],
      'leaguePriorityOrder': leagueJson['lpo'] ?? leagueJson['priorityOrder'],
      if (leagueJson.containsKey('leagueOrder') || leagueJson.containsKey('lo'))
        'leagueOrder': leagueJson['lo'] ?? leagueJson['leagueOrder'],
      'leagueLogo': leagueJson['lg'] ?? leagueJson['leagueLogo'],
    });

    final events = leagueJson['e'] as List<dynamic>? ??
        leagueJson['events'] as List<dynamic>? ??
        [];

    for (final eventJson in events) {
      if (eventJson is! Map<String, dynamic>) continue;

      final eventId = _parseInt(eventJson['ei'] ?? eventJson['eventId']) ?? 0;
      if (eventId == 0) continue;
      if (prune) validEventIds.add(eventId);

      store.upsertEventFromJson({
        'eventId': eventId,
        'leagueId': leagueId,
        'sportId': sportId,
        'homeName': eventJson['hn'] ?? eventJson['homeName'] ?? '',
        'awayName': eventJson['an'] ?? eventJson['awayName'] ?? '',
        'homeId': eventJson['hi'] ?? eventJson['homeId'] ?? 0,
        'awayId': eventJson['ai'] ?? eventJson['awayId'] ?? 0,
        'hf': eventJson['hf'] ??
            eventJson['hl'] ??
            eventJson['homeLogoFirst'] ??
            eventJson['homeLogo'],
        'af': eventJson['af'] ??
            eventJson['al'] ??
            eventJson['awayLogoFirst'] ??
            eventJson['awayLogo'],
        'status': eventJson['es'] ?? eventJson['eventStatus'] ?? 'ACTIVE',
        'isLive': eventJson['l'] ?? eventJson['isLive'] ?? false,
        'isGoingLive': eventJson['gl'] ?? eventJson['isGoingLive'] ?? false,
        'isLiveStream': eventJson['ls'] ?? eventJson['isLivestream'] ?? false,
        'isSuspended': eventJson['s'] ?? eventJson['isSuspended'] ?? false,
        'startDate': eventJson['st'] ??
            eventJson['et'] ??
            eventJson['startTime'] ??
            eventJson['startDate'],
        if (eventJson.containsKey('hs') || eventJson.containsKey('homeScore'))
          'homeScore': eventJson['hs'] ?? eventJson['homeScore'],
        if (eventJson.containsKey('as') || eventJson.containsKey('awayScore'))
          'awayScore': eventJson['as'] ?? eventJson['awayScore'],
        if (eventJson.containsKey('gt') || eventJson.containsKey('gameTime'))
          'gameTime': eventJson['gt'] ?? eventJson['gameTime'],
        if (eventJson.containsKey('gp') || eventJson.containsKey('gamePart'))
          'gamePart': eventJson['gp'] ?? eventJson['gamePart'],
        if (eventJson.containsKey('stm') ||
            eventJson.containsKey('stoppageTime'))
          'stoppageTime': eventJson['stm'] ?? eventJson['stoppageTime'],
        if (eventJson.containsKey('currentSet'))
          'currentSet': eventJson['currentSet'],
        if (eventJson.containsKey('liveScores'))
          'liveScores': eventJson['liveScores'],
        if (eventJson.containsKey('homeTotalPoint'))
          'homeTotalPoint': eventJson['homeTotalPoint'],
        if (eventJson.containsKey('awayTotalPoint'))
          'awayTotalPoint': eventJson['awayTotalPoint'],
        if (eventJson.containsKey('homeCurrentPoint'))
          'homeCurrentPoint': eventJson['homeCurrentPoint'],
        if (eventJson.containsKey('awayCurrentPoint'))
          'awayCurrentPoint': eventJson['awayCurrentPoint'],
        if (eventJson.containsKey('rch') ||
            eventJson.containsKey('redCardsHome'))
          'redCardsHome': eventJson['rch'] ?? eventJson['redCardsHome'],
        if (eventJson.containsKey('rca') ||
            eventJson.containsKey('redCardsAway'))
          'redCardsAway': eventJson['rca'] ?? eventJson['redCardsAway'],
        if (eventJson.containsKey('ych') ||
            eventJson.containsKey('yellowCardsHome'))
          'yellowCardsHome': eventJson['ych'] ?? eventJson['yellowCardsHome'],
        if (eventJson.containsKey('yca') ||
            eventJson.containsKey('yellowCardsAway'))
          'yellowCardsAway': eventJson['yca'] ?? eventJson['yellowCardsAway'],
        if (eventJson.containsKey('hc') || eventJson.containsKey('cornersHome'))
          'cornersHome': eventJson['hc'] ?? eventJson['cornersHome'],
        if (eventJson.containsKey('ac') || eventJson.containsKey('cornersAway'))
          'cornersAway': eventJson['ac'] ?? eventJson['cornersAway'],
        'totalMarketsCount':
            eventJson['mc'] ?? eventJson['totalMarketsCount'] ?? 0,
        'isParlay': eventJson['ip'] ?? eventJson['isParlay'] ?? false,
        'isCashOut': eventJson['ico'] ?? eventJson['isCashOut'] ?? false,
        'type': eventJson['type'] ?? 0,
        'eventStatsId': eventJson['esi'] ?? eventJson['eventStatsId'],
      });

      store.markListMember(eventId, sportId);

      final markets = eventJson['m'] as List<dynamic>? ??
          eventJson['markets'] as List<dynamic>? ??
          [];

      for (final marketJson in markets) {
        if (marketJson is! Map<String, dynamic>) continue;

        final marketId =
            _parseInt(marketJson['mi'] ?? marketJson['marketId']) ?? 0;
        if (marketId == 0) continue;
        if (prune) {
          validMarketIdsByEvent.putIfAbsent(eventId, () => {}).add(marketId);
        }

        store.upsertMarketFromJson(eventId, {
          'marketId': marketId,
          'marketName': marketJson['mn'] ?? marketJson['marketName'],
          'marketType': marketJson['mt'] ?? marketJson['marketType'],
          'isSuspended': marketJson['isSuspended'],
          'isParlay': marketJson['isParlay'],
          'isCashOut': marketJson['isCashOut'],
          'promotionType': marketJson['promotionType'],
          'groupId': marketJson['groupId'],
        });

        final odds = marketJson['o'] as List<dynamic>? ??
            marketJson['odds'] as List<dynamic>? ??
            [];

        for (final oddsJson in odds) {
          if (oddsJson is! Map<String, dynamic>) continue;

          if (prune) {
            final offerId = (oddsJson['soi'] ??
                    oddsJson['offerId'] ??
                    oddsJson['strOfferId'])
                ?.toString();
            if (offerId != null) {
              validOfferIdsByMarket
                  .putIfAbsent('${eventId}_$marketId', () => {})
                  .add(offerId);
            }
          }

          final oddsHomeValue =
              _parseOddsValue(oddsJson['oh'] ?? oddsJson['oddsHome']);
          final oddsAwayValue =
              _parseOddsValue(oddsJson['oa'] ?? oddsJson['oddsAway']);
          final oddsDrawValue =
              _parseOddsValue(oddsJson['od'] ?? oddsJson['oddsDraw']);

          store.upsertOddsFromJson(
            eventId,
            marketId,
            {
              'strOfferId': oddsJson['soi'] ??
                  oddsJson['offerId'] ??
                  oddsJson['strOfferId'],
              'isSuspended': oddsJson['isSuspended'],
              'points': oddsJson['p'] ?? oddsJson['points'],
              'isMainLine': oddsJson['ml'] ?? oddsJson['isMainLine'],
              'selectionIdHome': oddsJson['shi'] ?? oddsJson['selectionHomeId'],
              'selectionIdAway': oddsJson['sai'] ?? oddsJson['selectionAwayId'],
              'selectionIdDraw': oddsJson['sdi'] ?? oddsJson['selectionDrawId'],
              'oddsHome': oddsHomeValue?['decimal'],
              'oddsAway': oddsAwayValue?['decimal'],
              'oddsDraw': oddsDrawValue?['decimal'],
              'malayHome': oddsHomeValue?['malay']?.toString(),
              'malayAway': oddsAwayValue?['malay']?.toString(),
              'hkHome': oddsHomeValue?['hongKong']?.toString(),
              'hkAway': oddsAwayValue?['hongKong']?.toString(),
              'indoHome': oddsHomeValue?['indo']?.toString(),
              'indoAway': oddsAwayValue?['indo']?.toString(),
              'malayDraw': oddsDrawValue?['malay']?.toString(),
              'hkDraw': oddsDrawValue?['hongKong']?.toString(),
              'indoDraw': oddsDrawValue?['indo']?.toString(),
              'playerName': oddsJson['playerName'],
              'playerId': oddsJson['playerId'],
            },
            timeRange: timeRange,
          );
        }
      }
    }
  }

  static Map<String, dynamic> toFreezedLeague(
    LeagueData library,
    SportDataStore store,
  ) {
    final events = store.getEventsByLeague(library.leagueId);

    return {
      'li': library.leagueId,
      'ln': library.name,
      'lg': library.logoUrl ?? '',
      'lpo': library.priorityOrder,
      'e': events.map((e) => toFreezedEvent(e, store)).toList(),
    };
  }

  static Map<String, dynamic> toFreezedEvent(
    EventData library,
    SportDataStore store,
  ) {
    final markets = store.getMarketsByEvent(library.eventId);

    return {
      'ei': library.eventId,
      'hn': library.homeName,
      'an': library.awayName,
      'hi': library.homeId,
      'ai': library.awayId,
      'hf': library.homeLogo,
      'af': library.awayLogo,
      'st': library.startDate?.millisecondsSinceEpoch ?? 0,
      'hs': library.homeScore ?? 0,
      'as': library.awayScore ?? 0,
      'l': library.isLive,
      'gl': library.isGoingLive,
      'ls': library.isLiveStream,
      's': library.isSuspended,
      'es': library.status,
      'esi': library.eventStatsId ?? 0,
      'gt': library.gameTime ?? 0,
      'gp': library.gamePart ?? 0,
      'stm': library.stoppageTime ?? 0,
      'hc': library.cornersHome ?? 0,
      'ac': library.cornersAway ?? 0,
      'rch': library.redCardsHome ?? 0,
      'rca': library.redCardsAway ?? 0,
      'ych': library.yellowCardsHome ?? 0,
      'yca': library.yellowCardsAway ?? 0,
      'mc': library.totalMarketsCount,
      'ip': library.isParlay,
      'm': markets
          .map((m) => toFreezedMarket(m, library.eventId, store))
          .toList(),
    };
  }

  static Map<String, dynamic> toFreezedMarket(
    MarketData library,
    int eventId,
    SportDataStore store,
  ) {
    final odds = store.getOddsByMarket(eventId, library.marketId);

    return {
      'mi': library.marketId,
      'mn': library.name ?? '',
      'mt': library.marketType,
      'ip': false,
      'o': odds.map((o) => toFreezedOdds(o)).toList(),
    };
  }

  static Map<String, dynamic> toFreezedOdds(OddsData library) {
    return {
      'p': library.points ?? '',
      'ml': library.isMainLine,
      'shi': library.selectionIdHome,
      'sai': library.selectionIdAway,
      'sdi': library.selectionIdDraw,
      'soi': library.offerId,
      'oh': _buildOddsValueJson(
        decimal: library.oddsHome,
        malay: library.malayHome,
        indo: library.indoHome,
        hongKong: library.hkHome,
      ),
      'oa': _buildOddsValueJson(
        decimal: library.oddsAway,
        malay: library.malayAway,
        indo: library.indoAway,
        hongKong: library.hkAway,
      ),
      'od': library.oddsDraw != null
          ? _buildOddsValueJson(decimal: library.oddsDraw)
          : null,
    };
  }

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

  static Map<String, double?>? _parseOddsValue(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;

    final map = value as Map<String, dynamic>;
    return {
      'decimal': _parseDouble(map['de'] ?? map['decimal']),
      'malay': _parseDouble(map['ma'] ?? map['malay']),
      'indo': _parseDouble(map['in'] ?? map['indo']),
      'hongKong': _parseDouble(map['hk'] ?? map['hongKong']),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _buildOddsValueJson({
    double? decimal,
    String? malay,
    String? indo,
    String? hongKong,
  }) {
    return {
      'de': decimal ?? -100,
      'ma': double.tryParse(malay ?? '') ?? -100,
      'in': double.tryParse(indo ?? '') ?? -100,
      'hk': double.tryParse(hongKong ?? '') ?? -100,
    };
  }
}

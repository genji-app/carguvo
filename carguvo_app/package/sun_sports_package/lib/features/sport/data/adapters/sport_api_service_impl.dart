import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart' as freezed;
import 'package:sun_sports/features/sport/domain/repositories/sport_repository.dart';

Map<String, dynamic>? _setSportScoreJson(ScoreModelV2? score) {
  List<Map<String, String>> scores(List<HomeAwayScoreV2> list) => [
    for (final p in list) {'homeScore': p.homeScore, 'awayScore': p.awayScore},
  ];
  return switch (score) {
    final VolleyballScoreModelV2 s => {
      if (s.currentSet > 0) 'currentSet': s.currentSet,
      if (s.liveScores.isNotEmpty) 'liveScores': scores(s.liveScores),
      if (s.homeTotalPoint > 0) 'homeTotalPoint': s.homeTotalPoint,
      if (s.awayTotalPoint > 0) 'awayTotalPoint': s.awayTotalPoint,
    },
    final TableTennisScoreModelV2 s => {
      if (s.currentSet > 0) 'currentSet': s.currentSet,
      if (s.liveScores.isNotEmpty) 'liveScores': scores(s.liveScores),
      if (s.homeTotalPoint > 0) 'homeTotalPoint': s.homeTotalPoint,
      if (s.awayTotalPoint > 0) 'awayTotalPoint': s.awayTotalPoint,
    },
    final BadmintonScoreModelV2 s => {
      if (s.currentSet > 0) 'currentSet': s.currentSet,
      if (s.liveScores.isNotEmpty) 'liveScores': scores(s.liveScores),
      if (s.homeTotalPoint > 0) 'homeTotalPoint': s.homeTotalPoint,
      if (s.awayTotalPoint > 0) 'awayTotalPoint': s.awayTotalPoint,
    },
    final TennisScoreModelV2 s => {
      if (s.currentSet > 0) 'currentSet': s.currentSet,
      if (s.liveScores.isNotEmpty) 'liveScores': scores(s.liveScores),
      if (s.homeCurrentPoint != null) 'homeCurrentPoint': s.homeCurrentPoint,
      if (s.awayCurrentPoint != null) 'awayCurrentPoint': s.awayCurrentPoint,
    },
    final BasketballScoreModelV2 s => {
      if (s.liveScores.isNotEmpty) 'liveScores': scores(s.liveScores),
    },
    _ => null,
  };
}

List<Map<String, dynamic>> jsonLeaguesFromV2(
  List<LeagueModelV2> leagues,
  int sportId,
) {
  Map<String, dynamic>? style(OddsStyleModelV2? s) => s == null
      ? null
      : {'de': s.decimal, 'ma': s.malay, 'in': s.indo, 'hk': s.hk};

  Map<String, dynamic> oddsJson(OddsModelV2 o) => {
    'strOfferId': o.strOfferId,
    'points': o.points,
    'isMainLine': o.isMainLine,
    'isSuspended': o.isSuspended,
    'selectionHomeId': o.selectionHomeId,
    'selectionAwayId': o.selectionAwayId,
    'selectionDrawId': o.selectionDrawId,
    'oddsHome': style(o.homeOdds),
    'oddsAway': style(o.awayOdds),
    'oddsDraw': style(o.drawOdds),
    'playerName': o.playerName,
    'playerId': o.playerId,
  };

  Map<String, dynamic> marketJson(MarketModelV2 m) => {
    'marketId': m.marketId,
    'isSuspended': m.isSuspended,
    'isParlay': m.isParlay,
    'isCashOut': m.isCashOut,
    'promotionType': m.promotionType,
    'groupId': m.groupId,
    'odds': [for (final o in m.oddsList) oddsJson(o)],
  };

  Map<String, dynamic> eventJson(EventModelV2 e, int leagueId) => {
    'eventId': e.eventId,
    'leagueId': leagueId,
    'sportId': sportId,
    'homeName': e.homeName,
    'awayName': e.awayName,
    'homeId': e.homeId,
    'awayId': e.awayId,
    'homeLogo': e.homeLogo,
    'awayLogo': e.awayLogo,
    'isLive': e.isLive,
    'isGoingLive': e.isGoingLive,
    'isLivestream': e.isLiveStream,
    'isSuspended': e.isSuspended,
    'startDate': e.startDate,
    'totalMarketsCount': e.marketCount,
    'isParlay': e.isParlay,
    'isCashOut': e.isCashOut,
    'type': e.type,
    'eventStatsId': e.eventStatsId,
    'gamePart': e.gamePart,
    'gameTime': e.gameTime,
    if (e.score != null) ...{
      'homeScore': e.homeScoreInt,
      'awayScore': e.awayScoreInt,
      'redCardsHome': e.redCardsHome,
      'redCardsAway': e.redCardsAway,
      'yellowCardsHome': e.yellowCardsHome,
      'yellowCardsAway': e.yellowCardsAway,
      'cornersHome': e.cornersHome,
      'cornersAway': e.cornersAway,
      'homeScoreOT': e.homeScoreOT,
      'awayScoreOT': e.awayScoreOT,
      ...?_setSportScoreJson(e.score),
    },
    'markets': [for (final m in e.markets) marketJson(m)],
  };

  return [
    for (final l in leagues)
      {
        'leagueId': l.leagueId,
        'sportId': sportId,
        'leagueName': l.leagueName,
        'leagueNameEn': l.leagueNameEn,
        'priorityOrder': l.priorityOrder,
        if (l.leagueOrder != null) 'leagueOrder': l.leagueOrder,
        'leagueLogo': l.leagueLogo,
        'events': [for (final e in l.events) eventJson(e, l.leagueId)],
      },
  ];
}

Future<List<Map<String, dynamic>>> jsonLeaguesFromV2Chunked(
  List<LeagueModelV2> leagues,
  int sportId, {
  int yieldEvery = 8,
  Duration sliceBudget = const Duration(milliseconds: 4),
}) async {
  final out = <Map<String, dynamic>>[];
  final slice = Stopwatch()..start();
  var sinceYield = 0;
  for (final league in leagues) {
    out.addAll(jsonLeaguesFromV2([league], sportId));
    if (++sinceYield >= yieldEvery || slice.elapsed >= sliceBudget) {
      await Future<void>.delayed(Duration.zero);
      slice.reset();
      sinceYield = 0;
    }
  }
  return out;
}

enum PopulateOutcome {
  applied,

  skipped,

  superseded,

  failed,
}

class SportApiServiceImpl implements socket.ISportApiService {
  final SportRepository _repository;
  final EventsV2RemoteDataSource _v2DataSource;

  static const _tag = '[SportApiServiceV2]';

  CancelToken? _inFlightPopulateToken;

  CancelToken _freshPopulateToken() {
    _inFlightPopulateToken?.cancel('Superseded by newer populate');
    return _inFlightPopulateToken = CancelToken();
  }

  SportApiServiceImpl({
    required SportRepository repository,
    required EventsV2RemoteDataSource v2DataSource,
  }) : _repository = repository,
       _v2DataSource = v2DataSource;

  @override
  Future<List<socket.LeagueData>> fetchEarlyLeagues({
    required int sportId,
    int? days,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      '$_tag 📡 FETCH EARLY/TODAY - sportId: $sportId, days: ${days ?? 0}',
    );

    final result = await _repository.getLeagues(
      sportId: sportId,
      days: days ?? 0,
      isLive: false,
    );

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ EARLY/TODAY FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        SentryService.captureBackendError(
          'fetch-leagues-failed:EARLY',
          failure.toString(),
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ EARLY/TODAY SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  @override
  Future<List<socket.LeagueData>> fetchLiveLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH LIVE - sportId: $sportId');

    if (_repository.currentSportId != sportId) {
      await _repository.changeSport(sportId);
    }

    final result = await _repository.getLiveLeagues();

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ LIVE FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        SentryService.captureBackendError(
          'fetch-leagues-failed:LIVE',
          failure.toString(),
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ LIVE SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  @override
  Future<List<socket.LeagueData>> fetchHotLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH HOT - sportId: $sportId');

    if (_repository.currentSportId != sportId) {
      await _repository.changeSport(sportId);
    }

    final result = await _repository.getHotLeagues();

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ HOT FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ HOT SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  List<socket.LeagueData> _convertLeagues(
    List<freezed.LeagueData> freezedLeagues,
    int sportId,
  ) {
    return freezedLeagues.map((l) => _convertLeague(l, sportId)).toList();
  }

  socket.LeagueData _convertLeague(freezed.LeagueData freezed, int sportId) {
    return socket.ModelConverter.fromFreezedLeague(
      freezed.toJson(),
      sportId: sportId,
    );
  }

  @override
  Future<void> fetchLiveAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
    bool background = false,
  }) =>
      _populate(
        sportId: sportId,
        store: store,
        timeRange: socket.TimeRange.live,
        request: EventsRequestModel.live(sportId),
        tag: 'LIVE',
        background: background,
      );

  @override
  Future<void> fetchTodayAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
    bool background = false,
  }) =>
      _populate(
        sportId: sportId,
        store: store,
        timeRange: socket.TimeRange.today,
        request: EventsRequestModel.today(sportId),
        tag: 'TODAY',
        background: background,
      );

  @override
  Future<void> fetchEarlyAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
    bool background = false,
  }) =>
      _populate(
        sportId: sportId,
        store: store,
        timeRange: socket.TimeRange.early,
        request: EventsRequestModel.early(sportId),
        tag: 'EARLY',
        background: background,
      );

  @override
  Future<void> fetchTodayEarlyAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
    bool background = false,
  }) =>
      _populate(
        sportId: sportId,
        store: store,
        timeRange: socket.TimeRange.todayEarly,
        request: EventsRequestModel.all(sportId),
        tag: 'TODAY_EARLY',
        background: background,
      );

  int _populatesInFlight = 0;
  Completer<void>? _idle;

  final Map<String, PopulateOutcome> _lastOutcome = {};

  static String _outcomeKey(int sportId, String timeRange) =>
      '$sportId:$timeRange';

  PopulateOutcome? lastOutcome(int sportId, String timeRange) =>
      _lastOutcome[_outcomeKey(sportId, timeRange)];

  bool get populateInFlight => _populatesInFlight > 0;

  Future<void> get inFlightDone => _populatesInFlight == 0
      ? Future<void>.value()
      : (_idle ??= Completer<void>()).future;

  Future<void> _populate({
    required int sportId,
    required socket.SportDataStore store,
    required String timeRange,
    required EventsRequestModel request,
    required String tag,
    required bool background,
  }) async {
    final key = _outcomeKey(sportId, timeRange);
    if (background && _populatesInFlight > 0) {
      debugPrint('$_tag ⏭️ $tag populate skipped, populate in flight');
      _lastOutcome[key] = PopulateOutcome.skipped;
      return;
    }
    _populatesInFlight++;
    try {
      _lastOutcome[key] = await _runPopulate(
        sportId: sportId,
        store: store,
        timeRange: timeRange,
        request: request,
        tag: tag,
      );
    } finally {
      _populatesInFlight--;
      if (_populatesInFlight == 0) {
        _idle?.complete();
        _idle = null;
      }
    }
  }

  Future<PopulateOutcome> _runPopulate({
    required int sportId,
    required socket.SportDataStore store,
    required String timeRange,
    required EventsRequestModel request,
    required String tag,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH $tag & POPULATE (V2 API) - sportId: $sportId');

    try {
      final token = _freshPopulateToken();
      final fetchStartMs = DateTime.now().millisecondsSinceEpoch;

      final v2Leagues = await _v2DataSource.getEventsWithCancel(request, token);

      if (!identical(token, _inFlightPopulateToken)) {
        return PopulateOutcome.superseded;
      }

      stopwatch.stop();

      final jsonLeagues = await DartStress.timedAsync(
        'populate.map',
        () => jsonLeaguesFromV2Chunked(v2Leagues, sportId),
      );

      final pruned = await DartStress.timedAsync(
        'populate.store',
        () => socket.ModelConverter.upsertPopulateDataStoreChunked(
          jsonLeagues,
          store,
          sportId: sportId,
          timeRange: timeRange,
          prune: true,
          protectSocketTouchAfterMs: fetchStartMs,
          shouldContinue: () => identical(token, _inFlightPopulateToken),
        ),
      );
      if (!identical(token, _inFlightPopulateToken)) {
        return PopulateOutcome.superseded;
      }

      DartStress.timed('populate.emit', store.emitBatchChanges);
      if (!pruned.isEmpty) {
        debugPrint('$_tag $tag prune: $pruned');
      }

      final storeLeagues = store.getLeaguesBySport(sportId);
      int eventCount = 0;
      for (final league in storeLeagues) {
        eventCount += store.getEventsByLeague(league.leagueId).length;
      }
      debugPrint(
        '$_tag ✅ $tag POPULATE DONE\n'
        '   └─ API: ${v2Leagues.length} leagues\n'
        '   └─ Store: ${storeLeagues.length} leagues, $eventCount events\n'
        '   └─ Duration: ${stopwatch.elapsedMilliseconds}ms',
      );
      return PopulateOutcome.applied;
    } catch (e, stack) {
      stopwatch.stop();
      return _handlePopulateError(tag, e, stack);
    }
  }

  @override
  Future<void> fetchLeaguesAndMerge({
    required int sportId,
    required List<int> leagueIds,
    required String timeRange,
    required socket.SportDataStore store,
  }) async {
    if (leagueIds.isEmpty) return;
    debugPrint(
      '$_tag 📡 FETCH LEAGUES & MERGE - sportId: $sportId, '
      'leagues: $leagueIds, tr: $timeRange',
    );

    try {
      final token = CancelToken();
      final generationBefore = store.populateGeneration;
      final fetchStartMs = DateTime.now().millisecondsSinceEpoch;

      final v2Leagues = await _v2DataSource.getEventsWithCancel(
        EventsRequestModel(
          sportId: sportId,
          timeRange: _restTimeRangeOf(timeRange),
          leagueIds: leagueIds,
        ),
        token,
      );

      if (store.lastPopulateSportId != null &&
          (store.lastPopulateSportId != sportId ||
              store.lastPopulateTimeRange != timeRange)) {
        return;
      }
      if (store.populateGeneration != generationBefore) {
        return;
      }

      final jsonLeagues = await DartStress.timedAsync(
        'populate.map',
        () => jsonLeaguesFromV2Chunked(v2Leagues, sportId),
      );

      DartStress.timed(
        'populate.store',
        () => socket.ModelConverter.upsertPopulateDataStore(
          jsonLeagues,
          store,
          sportId: sportId,
          timeRange: timeRange,
          prune: true,
          markSnapshot: false,
          pruneLeagueScope: leagueIds.toSet(),
          protectSocketTouchAfterMs: fetchStartMs,
        ),
      );
      DartStress.timed('populate.emit', store.emitBatchChanges);

      debugPrint('$_tag ✅ LEAGUES MERGE DONE - ${v2Leagues.length} leagues');
    } catch (e, stack) {
      _handlePopulateError('LEAGUES_MERGE', e, stack);
    }
  }

  int _restTimeRangeOf(String timeRange) {
    switch (timeRange) {
      case socket.TimeRange.live:
        return 0;
      case socket.TimeRange.today:
        return 1;
      case socket.TimeRange.early:
        return 2;
      case socket.TimeRange.todayEarly:
        return 3;
      default:
        return 0;
    }
  }

  PopulateOutcome _handlePopulateError(String tab, Object e, StackTrace stack) {
    if (e is CancelledException ||
        (e is DioException && e.type == DioExceptionType.cancel)) {
      debugPrint('$_tag ⏭️ $tab populate cancelled (superseded)');
      return PopulateOutcome.superseded;
    }
    debugPrint('$_tag ❌ $tab POPULATE FAILED: $e');
    debugPrint('Stack: $stack');
    SentryService.captureBackendError('populate-failed:$tab', e.toString());
    return PopulateOutcome.failed;
  }
}

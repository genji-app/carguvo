import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/misc/semaphore.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/features/home/data/datasources/hot_match_remote_datasource.dart';
import 'package:sun_sports/features/home/data/repositories/hot_betting_trend.dart';
import 'package:sun_sports/features/home/domain/entities/bet_statistics_entity.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/domain/repositories/hot_match_repository.dart';

class _MatchStatisticsResult {
  final HotBettingTrend? bettingTrend;
  final int? totalUsers;

  const _MatchStatisticsResult({this.bettingTrend, this.totalUsers});
}

class HotMatchRepositoryImpl implements HotMatchRepository {
  final HotMatchRemoteDataSource _remoteDataSource;

  HotMatchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<LeagueModelV2>>> getHotMatches() async {
    try {
      final leagues = await _remoteDataSource.getHotMatches();
      return Right(leagues);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Map<int, HotMatchEventStatistics>> getBetStatisticsForEvents(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    if (matches.isEmpty) return {};
    try {
      final enriched = await _enrichHotMatchesWithStatistics(matches, sportId);
      final result = <int, HotMatchEventStatistics>{};
      for (final m in enriched) {
        result[m.eventId] = HotMatchEventStatistics(
          bettingTrend: m.bettingTrend,
          totalUsers: m.totalUsers,
        );
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  @override
  Stream<MapEntry<int, HotMatchEventStatistics>> streamBetStatistics(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  }) {
    final controller =
        StreamController<MapEntry<int, HotMatchEventStatistics>>();

    _runStreamedStatistics(matches, sportId, maxConcurrent, controller);

    return controller.stream;
  }

  Future<void> _runStreamedStatistics(
    List<HotMatchEventV2> matches,
    int sportId,
    int maxConcurrent,
    StreamController<MapEntry<int, HotMatchEventStatistics>> controller,
  ) async {
    if (matches.isEmpty) {
      await controller.close();
      return;
    }

    final semaphore = Semaphore(maxConcurrent);

    try {
      await Future.wait(
        matches.map((match) async {
          await semaphore.acquire();
          try {
            final stats = await _callStatisticsApis(match, sportId);
            if (!controller.isClosed) {
              controller.add(
                MapEntry(
                  match.eventId,
                  HotMatchEventStatistics(
                    bettingTrend: stats.bettingTrend,
                    totalUsers: stats.totalUsers,
                  ),
                ),
              );
            }
          } catch (_) {
          } finally {
            semaphore.release();
          }
        }),
        eagerError: false,
      );
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }

  Future<List<HotMatchEventV2>> _enrichHotMatchesWithStatistics(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    const concurrencyLimit = 5;
    final enriched = <HotMatchEventV2>[];
    for (var i = 0; i < matches.length; i += concurrencyLimit) {
      final batch = matches.skip(i).take(concurrencyLimit).toList();
      final futures = batch.map((m) async {
        final stats = await _callStatisticsApis(m, sportId);
        return m.copyWith(
          bettingTrend: stats.bettingTrend,
          totalUsers: stats.totalUsers,
        );
      }).toList();
      enriched.addAll(await Future.wait(futures));
    }
    return enriched;
  }

  Future<_MatchStatisticsResult> _callStatisticsApis(
    HotMatchEventV2 match,
    int sportId,
  ) async {
    try {
      final eventId = match.eventId;
      final leagueId = match.leagueId;
      final agentId = SbConfig.agentId;
      final httpManager = SbHttpManager.instance;

      if (httpManager.userTokenSb.isEmpty) {
        return const _MatchStatisticsResult();
      }

      await httpManager.userInfoReady.timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );

      final futures = <Future<dynamic>>[];

      final urlBettingStatisticsSimple =
          '${SbHttpManager.instance.sbApiBaseUrl}/bet/statistics/simple'
          '?agentId=$agentId'
          '&eventId=$eventId';
      futures.add(
        httpManager
            .send(urlBettingStatisticsSimple, json: true, headerToken: true)
            .catchError((Object e) => null),
      );

      final urlUserDetailsReponse =
          '${SbHttpManager.instance.sbApiBaseUrl}/bet/statistics/users'
          '?agentId=$agentId'
          '&leagueId=$leagueId'
          '&eventId=$eventId'
          '&marketId=0'
          '&filter=latest'
          '&page=0'
          '&size=50';
      futures.add(
        httpManager
            .send(urlUserDetailsReponse, json: true, headerToken: true)
            .catchError((Object e) => null),
      );

      final results = await Future.wait(futures);
      final response1 = results[0];
      final response2 = results[1];

      HotBettingTrend? bettingTrend;
      if (response1 is Map<String, dynamic>) {
        try {
          bettingTrend = resolveHotBettingTrend(
            response1,
            mainLinePoints: match
                .getHandicapMarket(sportId)
                ?.mainLineOdds
                ?.points,
            homeName: match.homeName,
            awayName: match.awayName,
          );
        } catch (e) {
        }
      }

      int? totalUsers;
      if (response2 is Map<String, dynamic>) {
        try {
          final statisticsUserDetails = BetStatisticsUserDetails.fromJson(
            response2,
          );
          totalUsers = statisticsUserDetails.totalCount;
        } catch (e) {
        }
      }

      return _MatchStatisticsResult(
        bettingTrend: bettingTrend,
        totalUsers: totalUsers,
      );
    } catch (e) {
      return const _MatchStatisticsResult();
    }
  }
}

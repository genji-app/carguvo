import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';

abstract class HotMatchRepository {
  Future<Either<Failure, List<LeagueModelV2>>> getHotMatches();

  Future<Map<int, HotMatchEventStatistics>> getBetStatisticsForEvents(
    List<HotMatchEventV2> matches,
    int sportId,
  );

  Stream<MapEntry<int, HotMatchEventStatistics>> streamBetStatistics(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  });
}

import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';

abstract class SportRepository {
  Future<Either<Failure, List<LeagueData>>> getLeagues({
    int? sportId,
    int? days,
    bool? isLive,
  });

  Future<Either<Failure, List<LeagueData>>> getLiveLeagues();

  Future<Either<Failure, List<LeagueData>>> getTodayLeagues();

  Future<Either<Failure, List<LeagueData>>> getHotLeagues();

  Future<Either<Failure, List<LeagueData>>> getOutrightLeagues();

  Future<Either<Failure, List<SpecialOutrightModel>>> getSpecialOutright(
    int sportId,
  );

  Future<void> changeSport(int sportId);

  int get currentSportId;
}

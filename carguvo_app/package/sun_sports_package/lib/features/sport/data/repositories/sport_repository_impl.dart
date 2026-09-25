import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/sport/data/datasources/sport_remote_datasource.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';
import 'package:sun_sports/features/sport/domain/repositories/sport_repository.dart';

class SportRepositoryImpl implements SportRepository {
  final SportRemoteDataSource _remoteDataSource;

  SportRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<LeagueData>>> getLeagues({
    int? sportId,
    int? days,
    bool? isLive,
  }) async {
    try {
      final leagues = await _remoteDataSource.getLeagues(
        days: days,
        isLive: isLive,
      );
      return Right(leagues);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeagueData>>> getLiveLeagues() async {
    return getLeagues(isLive: true);
  }

  @override
  Future<Either<Failure, List<LeagueData>>> getTodayLeagues() async {
    return getLeagues(days: 0);
  }

  @override
  Future<Either<Failure, List<LeagueData>>> getHotLeagues() async {
    try {
      final leagues = await _remoteDataSource.getHotLeagues();
      return Right(leagues);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeagueData>>> getOutrightLeagues() async {
    try {
      final leagues = await _remoteDataSource.getOutrightLeagues();
      return Right(leagues);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpecialOutrightModel>>> getSpecialOutright(
    int sportId,
  ) async {
    try {
      final specialOutrights = await _remoteDataSource.getSpecialOutright(
        sportId,
      );
      return Right(specialOutrights);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> changeSport(int sportId) async {
    await _remoteDataSource.changeSport(sportId);
  }

  @override
  int get currentSportId => _remoteDataSource.currentSportId;
}

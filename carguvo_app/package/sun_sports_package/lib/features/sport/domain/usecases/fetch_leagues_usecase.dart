import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';
import 'package:sun_sports/features/sport/domain/repositories/sport_repository.dart';

class FetchLeaguesUseCase {
  final SportRepository _repository;

  FetchLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call({
    int? sportId,
    int? days,
    bool? isLive,
  }) async {
    return await _repository.getLeagues(
      sportId: sportId,
      days: days,
      isLive: isLive,
    );
  }
}

class FetchLiveLeaguesUseCase {
  final SportRepository _repository;

  FetchLiveLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getLiveLeagues();
  }
}

class FetchTodayLeaguesUseCase {
  final SportRepository _repository;

  FetchTodayLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getTodayLeagues();
  }
}

class FetchHotLeaguesUseCase {
  final SportRepository _repository;

  FetchHotLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getHotLeagues();
  }
}

class FetchOutrightLeaguesUseCase {
  final SportRepository _repository;

  FetchOutrightLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getOutrightLeagues();
  }
}

class FetchSpecialOutrightUseCase {
  final SportRepository _repository;

  FetchSpecialOutrightUseCase(this._repository);

  Future<Either<Failure, List<SpecialOutrightModel>>> call(int sportId) async {
    return await _repository.getSpecialOutright(sportId);
  }
}

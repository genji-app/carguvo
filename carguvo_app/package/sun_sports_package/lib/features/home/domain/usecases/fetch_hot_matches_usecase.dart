import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/home/domain/repositories/hot_match_repository.dart';

class FetchHotMatchesUseCase {
  final HotMatchRepository _repository;

  FetchHotMatchesUseCase(this._repository);

  Future<Either<Failure, List<LeagueModelV2>>> call() async {
    return _repository.getHotMatches();
  }
}

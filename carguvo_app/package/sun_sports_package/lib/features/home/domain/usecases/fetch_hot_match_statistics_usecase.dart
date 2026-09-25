import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/domain/repositories/hot_match_repository.dart';

class FetchHotMatchStatisticsUseCase {
  final HotMatchRepository _repository;

  FetchHotMatchStatisticsUseCase(this._repository);

  Future<Map<int, HotMatchEventStatistics>> call(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    return _repository.getBetStatisticsForEvents(matches, sportId);
  }
}

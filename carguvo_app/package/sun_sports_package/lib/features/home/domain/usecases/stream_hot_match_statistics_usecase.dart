import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/domain/repositories/hot_match_repository.dart';

class StreamHotMatchStatisticsUseCase {
  final HotMatchRepository _repository;

  StreamHotMatchStatisticsUseCase(this._repository);

  Stream<MapEntry<int, HotMatchEventStatistics>> call(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  }) {
    return _repository.streamBetStatistics(
      matches,
      sportId,
      maxConcurrent: maxConcurrent,
    );
  }
}

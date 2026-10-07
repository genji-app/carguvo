import 'package:app_package/features/sport/domain/repositories/sport_repository.dart';

class ChangeSportUseCase {
  final SportRepository _repository;

  ChangeSportUseCase(this._repository);

  Future<void> call(int sportId) async {
    await _repository.changeSport(sportId);
  }

  int get currentSportId => _repository.currentSportId;
}

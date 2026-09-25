import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';
import 'package:sun_sports/features/sport/domain/usecases/change_sport_usecase.dart';
import 'package:sun_sports/features/sport/domain/usecases/fetch_leagues_usecase.dart';

final fetchLeaguesUseCaseProvider = Provider<FetchLeaguesUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchLeaguesUseCase(repository);
});

final fetchLiveLeaguesUseCaseProvider = Provider<FetchLiveLeaguesUseCase>((
  ref,
) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchLiveLeaguesUseCase(repository);
});

final fetchTodayLeaguesUseCaseProvider = Provider<FetchTodayLeaguesUseCase>((
  ref,
) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchTodayLeaguesUseCase(repository);
});

final fetchHotLeaguesUseCaseProvider = Provider<FetchHotLeaguesUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return FetchHotLeaguesUseCase(repository);
});

final fetchOutrightLeaguesUseCaseProvider =
    Provider<FetchOutrightLeaguesUseCase>((ref) {
      final repository = ref.read(sportRepositoryProvider);
      return FetchOutrightLeaguesUseCase(repository);
    });

final fetchSpecialOutrightUseCaseProvider =
    Provider<FetchSpecialOutrightUseCase>((ref) {
      final repository = ref.read(sportRepositoryProvider);
      return FetchSpecialOutrightUseCase(repository);
    });

final specialOutrightProvider = FutureProvider.autoDispose
    .family<List<SpecialOutrightModel>, int>((ref, sportId) async {
      final useCase = ref.read(fetchSpecialOutrightUseCaseProvider);
      final result = await useCase(sportId);
      return result.fold((failure) => throw failure, (data) => data);
    });

final changeSportUseCaseProvider = Provider<ChangeSportUseCase>((ref) {
  final repository = ref.read(sportRepositoryProvider);
  return ChangeSportUseCase(repository);
});

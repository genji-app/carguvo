import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/search/data/datasources/search_remote_datasource.dart';
import 'package:sun_sports/features/search/data/datasources/search_remote_datasource_impl.dart';
import 'package:sun_sports/features/search/data/models/search_response_model.dart';
import 'package:sun_sports/features/search/data/models/search_result_item.dart';
import 'package:sun_sports/features/search/data/repositories/search_repository_impl.dart';
import 'package:sun_sports/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/features/search/domain/repositories/search_repository.dart';
import 'package:sun_sports/features/search/domain/usecases/search_usecase.dart';
import 'package:sun_sports/providers/infra_provider.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSourceImpl(SbHttpManager.instance);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dataSource = ref.read(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(dataSource);
});

final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  final repository = ref.read(searchRepositoryProvider);
  return SearchUseCase(repository);
});

final searchDebouncedQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final searchRecentSportProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchRecentStorage.getRecentSport();
});

final searchRecentCasinoProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchRecentStorage.getRecentCasino();
});

final searchPopularLeaguesProvider =
    FutureProvider.autoDispose<List<SearchResultItem>>((ref) async {
      final leagues = await SbHttpManager.instance.getPopularLeagues();
      final candidates = <({LeagueModelV2 league, EventModelV2 event})>[];
      for (final league in leagues) {
        for (final event in league.events) {
          candidates.add((league: league, event: event));
        }
      }
      candidates.sort(
        (a, b) => (b.event.marketCount).compareTo(a.event.marketCount),
      );
      final top5 = candidates.take(5).toList();
      return top5
          .map(
            (e) => SearchResultItem(
              sportId: e.event.sportId,
              eventId: e.event.eventId,
              leagueName: e.league.leagueName,
              leagueId: e.league.leagueId,
              eventName: '${e.event.homeName} vs ${e.event.awayName}',
              startTimeIso: e.event.startDate,
              startTimeMs: e.event.startTime,
              isLive: e.event.isLive,
              status: e.event.type,
              leagueIconUrl: e.league.leagueLogo,
              homeTeamLogoUrl: e.event.homeLogo,
              awayTeamLogoUrl: e.event.awayLogo,
            ),
          )
          .toList();
    });

final searchResultProvider = FutureProvider.autoDispose
    .family<SearchResponseModel, String>((ref, query) async {
      if (query.isEmpty) return const SearchResponseModel();

      final token = CancelToken();
      ref.onDispose(token.cancel);

      final useCase = ref.read(searchUseCaseProvider);
      final result = await useCase.call(query, cancelToken: token);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (model) => model,
      );
    });

const int _kLeagueIdsPerRequest = 25;

List<List<T>> _chunked<T>(List<T> list, int size) => [
  for (var i = 0; i < list.length; i += size)
    list.sublist(i, i + size > list.length ? list.length : i + size),
];

String searchLeagueCountKey(int sportId, int leagueId) => '$sportId:$leagueId';

final searchLeagueEventCountsProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, query) async {
      if (query.isEmpty) return const <String, int>{};

      final token = CancelToken();
      ref.onDispose(token.cancel);
      final http = ref.read(sbHttpManagerProvider);

      final model = await ref.watch(searchResultProvider(query).future);
      final leagues = model.leagues;
      if (leagues.isEmpty) return const <String, int>{};

      final bySport = <int, List<int>>{};
      for (final league in leagues) {
        if (league.leagueId <= 0 || league.sportId <= 0) continue;
        (bySport[league.sportId] ??= <int>[]).add(league.leagueId);
      }
      if (bySport.isEmpty) return const <String, int>{};

      final counts = <String, int>{};
      for (final entry in bySport.entries) {
        final sportId = entry.key;
        for (final chunk in _chunked(entry.value, _kLeagueIdsPerRequest)) {
          try {
            final chunkCounts = await http.getLeagueEventCounts(
              sportId,
              chunk,
              cancelToken: token,
            );
            for (final id in chunk) {
              counts[searchLeagueCountKey(sportId, id)] = chunkCounts[id] ?? 0;
            }
          } catch (_) {
          }
        }
      }
      return counts;
    });

final casinoSearchResultsProvider = Provider.autoDispose<List<LobbyGame>>((
  ref,
) {
  final query = ref.watch(searchDebouncedQueryProvider).trim();
  if (query.isEmpty) return ref.watch(allLobbyGamesProvider);
  return ref.watch(searchLobbyGamesProvider(query));
});

final casinoRecentKeysProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return CasinoRecentGamesStorage.getKeys();
});

final casinoRecentGameBlocksProvider = Provider.autoDispose<List<LobbyGame>>((
  ref,
) {
  final allGames = ref.watch(allLobbyGamesProvider);
  final keysAsync = ref.watch(casinoRecentKeysProvider);

  return keysAsync.maybeWhen(
    data: (keys) {
      final list = <LobbyGame>[];
      for (final key in keys.take(5)) {
        final parts = key.split('|');
        if (parts.length != 3) continue;
        final providerId = parts[0];
        final productId = parts[1];
        final gameCode = parts[2];
        LobbyGame? block;
        for (final b in allGames) {
          if (b.providerId == providerId &&
              b.productId == productId &&
              b.gameCode == gameCode) {
            block = b;
            break;
          }
        }
        if (block != null) list.add(block);
      }
      return list;
    },
    orElse: () => [],
  );
});

final casinoPopularGamesProvider = Provider.autoDispose<List<LobbyGame>>((
  ref,
) {
  return ref.watch(popularGamesProvider);
});

import '../data/models/league_data.dart';
import '../data/sport_data_store.dart';

abstract class ISportApiService {
  Future<List<LeagueData>> fetchEarlyLeagues({
    required int sportId,
    int? days,
  });

  Future<List<LeagueData>> fetchLiveLeagues({
    required int sportId,
  });

  Future<List<LeagueData>> fetchHotLeagues({
    required int sportId,
  });

  Future<void> fetchLiveAndPopulate({
    required int sportId,
    required SportDataStore store,
    bool background = false,
  });

  Future<void> fetchTodayAndPopulate({
    required int sportId,
    required SportDataStore store,
    bool background = false,
  });

  Future<void> fetchEarlyAndPopulate({
    required int sportId,
    required SportDataStore store,
    bool background = false,
  });

  Future<void> fetchTodayEarlyAndPopulate({
    required int sportId,
    required SportDataStore store,
    bool background = false,
  });

  Future<void> fetchLeaguesAndMerge({
    required int sportId,
    required List<int> leagueIds,
    required String timeRange,
    required SportDataStore store,
  });
}

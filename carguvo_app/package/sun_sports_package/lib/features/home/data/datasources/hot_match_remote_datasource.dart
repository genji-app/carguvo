import 'package:sun_sports/core/network/api_endpoints.dart';
import 'package:sun_sports/core/network/sb_api_client.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/features/home/domain/entities/bet_statistics_entity.dart';

abstract class HotMatchRemoteDataSource {
  Future<List<LeagueModelV2>> getHotMatches();

  Future<Map<int, BetStatisticsSimple>> getBetStatisticsSimple(
    List<int> eventIds,
  );

  Future<BetStatisticsUserDetails?> getBetStatisticsUserDetails(
    List<int> eventIds,
    Map<int, int> eventIdToLeagueId,
  );
}

class HotMatchRemoteDataSourceImpl implements HotMatchRemoteDataSource {
  final SbHttpManager _httpManager;

  HotMatchRemoteDataSourceImpl(this._httpManager);

  @override
  Future<List<LeagueModelV2>> getHotMatches() async {
    return await _httpManager.getHotLeagues();
  }

  @override
  Future<Map<int, BetStatisticsSimple>> getBetStatisticsSimple(
    List<int> eventIds,
  ) async {
    if (eventIds.isEmpty || _httpManager.sbApiBaseUrl.isEmpty) {
      return {};
    }
    final baseUrl = _httpManager.sbApiBaseUrl;
    final agentId = SbConfig.agentId;
    final map = <int, BetStatisticsSimple>{};
    for (final eventId in eventIds) {
      try {
        final url = SbApiEndpoints.buildBetStatisticsSimpleUrl(
          baseUrl,
          agentId,
          eventId,
        );
        final response = await SbApiClient.instance.send(
          url,
          json: true,
          headerToken: true,
        );
        final stat = _parseBetStatisticsSimpleSingleResponse(response);
        if (stat != null && stat.eventId != null) {
          map[stat.eventId!] = stat;
        }
      } catch (_) {
      }
    }
    return map;
  }

  @override
  Future<BetStatisticsUserDetails?> getBetStatisticsUserDetails(
    List<int> eventIds,
    Map<int, int> eventIdToLeagueId,
  ) async {
    if (eventIds.isEmpty || _httpManager.sbApiBaseUrl.isEmpty) {
      return null;
    }
    final baseUrl = _httpManager.sbApiBaseUrl;
    final agentId = SbConfig.agentId;
    final allUserBets = <BetStatisticsUserBetDetail>[];
    int? totalCount;
    final marketTypes = <String>{};

    for (final eventId in eventIds) {
      final leagueId = eventIdToLeagueId[eventId] ?? 0;
      try {
        final url = SbApiEndpoints.buildBetStatisticsUserDetailsUrl(
          baseUrl,
          agentId,
          leagueId,
          eventId,
        );
        final response = await SbApiClient.instance.send(
          url,
          json: true,
          headerToken: true,
        );
        final details = _parseBetStatisticsUserDetailsResponse(response);
        if (details != null) {
          allUserBets.addAll(details.userBets);
          totalCount = details.totalCount;
          marketTypes.addAll(details.marketTypes);
        }
      } catch (_) {
      }
    }

    if (allUserBets.isEmpty && totalCount == null) return null;
    return BetStatisticsUserDetails(
      userBets: allUserBets,
      totalCount: totalCount ?? allUserBets.length,
      marketTypes: marketTypes.toList(),
    );
  }

  static BetStatisticsSimple? _parseBetStatisticsSimpleSingleResponse(
    dynamic response,
  ) {
    dynamic data = response;
    if (response is Map && response.containsKey('data')) {
      data = response['data'];
    }
    if (data is Map<String, dynamic>) {
      return BetStatisticsSimple.fromJson(data);
    }
    if (data is Map) {
      return BetStatisticsSimple.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  static BetStatisticsUserDetails? _parseBetStatisticsUserDetailsResponse(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      return BetStatisticsUserDetails.fromJson(response);
    }
    if (response is Map) {
      return BetStatisticsUserDetails.fromJson(
        Map<String, dynamic>.from(response),
      );
    }
    return null;
  }
}

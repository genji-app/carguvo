import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/perf/dart_stress.dart';
import 'package:sun_sports/core/network/api_endpoints.dart';
import 'package:sun_sports/core/network/sb_api_client.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_pin_item.dart';
import 'package:sun_sports/core/services/models/favorite_data.dart';

class SbSportService {
  SbSportService._internal();
  static final SbSportService _instance = SbSportService._internal();
  static SbSportService get instance => _instance;

  String Function() getSbApiBaseUrl = () => '';
  String Function() getUserTokenSb = () => '';
  int Function() getSportTypeId = () => 1;

  String get _baseUrl => getSbApiBaseUrl();
  String get _token => getUserTokenSb();
  int get _sportTypeId => getSportTypeId();

  Future<Map<String, dynamic>> getEventMarket(String info, int agentId) async {
    final url = SbApiEndpoints.buildEventMarketUrl(
      _baseUrl,
      agentId,
      _token,
      _sportTypeId,
      info,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEventHotMatch(int agentId) async {
    final url = SbApiEndpoints.buildEventHotUrl(
      _baseUrl,
      agentId,
      _sportTypeId,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEventOutright(
    String info,
    int agentId,
  ) async {
    final url = SbApiEndpoints.buildEventOutrightUrl(
      _baseUrl,
      agentId,
      _token,
      _sportTypeId,
      info,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  Future<List<LeagueData>> getLeagues({
    int? days,
    bool? isLive,
    int? leagueId,
    int? sportId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final queryParams = StringBuffer();
    if (days != null) queryParams.write('&days=$days');
    if (isLive != null) queryParams.write('&isLive=$isLive');
    if (leagueId != null) queryParams.write('&leagueId=$leagueId');

    final effectiveSportId = sportId ?? _sportTypeId;
    final url = SbApiEndpoints.buildEventMarketUrl(
      _baseUrl,
      SbConfig.agentId,
      _token,
      effectiveSportId,
      queryParams.toString(),
    );

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseLeagueResponse(response);
  }

  Future<List<LeagueData>> getOutrightLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventOutrightUrl(
      _baseUrl,
      SbConfig.agentId,
      _token,
      _sportTypeId,
    );
    final response = await SbApiClient.instance.send(url, json: true);

    return _parseLeagueResponse(response);
  }

  Future<List<LeagueModelV2>> getHotLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventHotUrl(
      _baseUrl,
      SbConfig.agentId,
      _sportTypeId,
    );
    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
    );
    return _parseHotLeagueV2Response(response);
  }

  Future<List<LeagueModelV2>> getPopularLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventsPopularUrl(
      _baseUrl,
      SbConfig.agentId,
    );
    final raw = await SbApiClient.instance.send(url, headerToken: true);
    return _parseLeagueV2Text(raw);
  }

  List<LeagueModelV2> _parseHotLeagueV2Response(dynamic response) {
    if (response is List) {
      return response
          .map(
            (item) =>
                LeagueModelV2.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['leagues'] ?? response['0'];
      if (data is List) {
        return data
            .map(
              (item) => LeagueModelV2.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    }
    return [];
  }

  List<LeagueData> _parseLeagueResponse(dynamic response) {
    if (response is List) {
      return response
          .map((json) => LeagueData.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['leagues'] ?? <dynamic>[];
      if (data is List) {
        return data
            .map((json) => LeagueData.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  Future<List<LeagueModelV2>> getEventsV2(
    EventsRequestModel request, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final queryParams = request.toQueryParameters();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final url = SbApiEndpoints.buildEventsV2Url(_baseUrl, queryString);

    if (kDebugMode) {
      debugPrint('[SbSport] getEventsV2 URL: $url');
    }

    final raw = await SbApiClient.instance.send(
      url,
      headerToken: true,
      cancelToken: cancelToken,
    );
    return _parseLeagueV2Text(raw);
  }

  Future<Map<int, int>> getLeagueEventCounts(
    int sportId,
    List<int> leagueIds, {
    CancelToken? cancelToken,
  }) async {
    if (leagueIds.isEmpty) return const <int, int>{};
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final request = EventsRequestModel(
      sportId: sportId,
      timeRange: 4,
      leagueIds: leagueIds,
    );
    final queryString = request
        .toQueryParameters()
        .entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    final url = SbApiEndpoints.buildEventsV2Url(_baseUrl, queryString);

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );
    if (response is! List) return const <int, int>{};

    final counts = <int, int>{};
    for (final raw in response) {
      if (raw is! Map) continue;
      final league = Map<String, dynamic>.from(raw);
      final isAlternate = league['2'] is String && league['4'] is num;
      final leagueId = _intOrZero(isAlternate ? league['1'] : league['3']);
      if (leagueId <= 0) continue;
      final events = league['0'];
      final length = events is List ? events.length : (events is Map ? 1 : 0);
      counts[leagueId] = (counts[leagueId] ?? 0) + length;
    }
    return counts;
  }

  static int _intOrZero(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<List<LeagueModelV2>> getLiveEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.live(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getTodayEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.today(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getEarlyEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.early(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  Future<EventDetailResponseV2> getEventDetailV2(
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventDetailV2Url(
      _baseUrl,
      eventId,
      isMobile: isMobile,
      onlyParlay: onlyParlay,
    );

    if (kDebugMode) {
      debugPrint('[SbSport] getEventDetailV2 URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    if (response is Map<String, dynamic>) {
      return EventDetailResponseV2.fromJson(response);
    } else if (response is Map) {
      return EventDetailResponseV2.fromJson(
        Map<String, dynamic>.from(response),
      );
    }

    throw const FormatException('Invalid event detail response format');
  }

  Future<List<String>> getEventDates(
    int sportId, {
    int days = 30,
    int tzOffset = -420,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventsDatesUrl(
      _baseUrl,
      sportId,
      days: days,
      tzOffset: tzOffset,
    );

    if (kDebugMode) {
      debugPrint('[SbSport] getEventDates URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    if (response is List) {
      return response
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return const [];
  }

  Future<List<LeaguePinItem>> getLeaguesPin(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildLeaguesPinUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getLeaguesPin URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    return _parseLeaguesPinResponse(response);
  }

  Future<Map<String, dynamic>> getSearch(
    String txtSearch, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }
    final url = SbApiEndpoints.buildSearchUrl(_baseUrl, txtSearch);
    if (kDebugMode) {
      debugPrint('[SbSport] getSearch URL: $url');
    }
    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );
    if (response is Map<String, dynamic>) return response;
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return <String, dynamic>{};
  }

  List<LeaguePinItem> _parseLeaguesPinResponse(dynamic response) {
    dynamic list = response;
    if (response is Map<String, dynamic>) {
      list = response['data'] ?? response['leagues'] ?? response['0'];
    } else if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      list = map['data'] ?? map['leagues'] ?? map['0'];
    }
    if (list is! List) return [];
    final result = <LeaguePinItem>[];
    for (final item in list) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final id = map['1'];
        final leagueId = id is int ? id : (id is num ? id.toInt() : 0);
        if (leagueId == 0) continue;
        final name = map['2']?.toString().trim() ?? '';
        final logoUrl = map['3']?.toString() ?? '';
        final order = map['4'];
        final sortOrder = order is int
            ? order
            : (order is num ? order.toInt() : 0);
        result.add(
          LeaguePinItem(
            leagueId: leagueId,
            name: name,
            logoUrl: logoUrl,
            sortOrder: sortOrder,
          ),
        );
      }
    }
    return result;
  }

  List<LeagueModelV2> _parseLeagueV2Response(dynamic response) =>
      parseLeagueV2Response(response);

  Future<List<LeagueModelV2>> _parseLeagueV2Text(dynamic raw) async {
    if (raw is! String || raw.isEmpty) return [];
    if (!kIsWeb) {
      try {
        return await DartStress.timedAsync(
          'parse.iso',
          () => Isolate.run(() => parseLeagueV2Payload(raw)),
        );
      } on FormatException {
        rethrow;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[SbSport] background parse unavailable, parsing inline: $e',
          );
        }
      }
    }
    return DartStress.timed('parse', () => parseLeagueV2Payload(raw));
  }

  Future<FavoriteData> getFavorites(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoritesUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getFavorites URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
    );

    if (response is Map<String, dynamic>) {
      return FavoriteData.fromJson(response, sportId);
    }

    return FavoriteData(sportId: sportId, leagueIds: [], eventIds: []);
  }

  Future<List<LeagueModelV2>> getFavoriteEvents(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventsUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getFavoriteEvents URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    debugPrint('[SbSport] getFavoriteEvents response: $response');

    final leagues = _parseFavoriteEventsResponse(response, sportId);

    return leagues
        .map(
          (l) => l.copyWith(
            isFavorited: true,
            events: l.events.map((e) => e.copyWith(isFavorited: true)).toList(),
          ),
        )
        .toList();
  }

  List<LeagueModelV2> _parseFavoriteEventsResponse(
    dynamic response,
    int sportId,
  ) {
    if (response is List) {
      return DartStress.timed('parse', () => _parseLeagueV2Response(response));
    }

    if (response is Map<String, dynamic>) {
      final sportKey = sportId.toString();
      final data =
          response[sportKey] ??
          response['data'] ??
          response['leagues'] ??
          response['1'];
      if (data is! List) return [];

      final flattened = <dynamic>[];
      for (final item in data) {
        if (item is List) {
          flattened.addAll(item);
        } else if (item is Map) {
          flattened.add(item);
        }
      }
      return _parseLeagueV2Response(flattened);
    }

    return [];
  }

  Future<Map<String, dynamic>> addFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteLeagueUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'leagueId': leagueId});

    if (kDebugMode) debugPrint('[SbSport] addFavoriteLeague: $url');

    final response = await SbApiClient.instance.send(
      url,
      post: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteLeagueUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'leagueId': leagueId});

    if (kDebugMode) debugPrint('[SbSport] removeFavoriteLeague: $url');

    final response = await SbApiClient.instance.send(
      url,
      delete: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> addFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'eventId': eventId});

    if (kDebugMode) debugPrint('[SbSport] addFavoriteEvent: $url');

    final response = await SbApiClient.instance.send(
      url,
      post: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> removeFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'eventId': eventId});

    if (kDebugMode) debugPrint('[SbSport] removeFavoriteEvent: $url');

    final response = await SbApiClient.instance.send(
      url,
      delete: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  Map<String, dynamic> _parseMapResponse(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }
}

List<LeagueModelV2> parseLeagueV2Payload(String raw) =>
    parseLeagueV2Response(jsonDecode(raw));

List<LeagueModelV2> parseLeagueV2Response(dynamic response) {
  if (response is List) {
    return response.map((json) {
      if (json is Map<String, dynamic>) {
        return LeagueModelV2.fromJson(json);
      } else if (json is Map) {
        return LeagueModelV2.fromJson(Map<String, dynamic>.from(json));
      }
      throw const FormatException('Invalid league data format');
    }).toList();
  }
  if (response is Map<String, dynamic>) {
    final data = response['data'] ?? response['leagues'] ?? <dynamic>[];
    if (data is List) {
      return data.map((json) {
        if (json is Map<String, dynamic>) {
          return LeagueModelV2.fromJson(json);
        } else if (json is Map) {
          return LeagueModelV2.fromJson(Map<String, dynamic>.from(json));
        }
        throw const FormatException('Invalid league data format');
      }).toList();
    }
  }
  return [];
}

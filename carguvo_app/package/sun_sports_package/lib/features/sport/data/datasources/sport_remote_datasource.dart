import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';

abstract class SportRemoteDataSource {
  Future<List<LeagueData>> getLeagues({int? days, bool? isLive});

  Future<List<LeagueData>> getHotLeagues();

  Future<List<LeagueData>> getOutrightLeagues();

  Future<List<SpecialOutrightModel>> getSpecialOutright(int sportId);

  Future<void> changeSport(int sportId);

  int get currentSportId;
}

class SportRemoteDataSourceImpl implements SportRemoteDataSource {
  final SbHttpManager _httpManager;
  final SportStorage _storage;

  SportRemoteDataSourceImpl(this._httpManager, this._storage);

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Future<List<LeagueData>> getLeagues({int? days, bool? isLive}) async {
    return await _httpManager.getLeagues(days: days, isLive: isLive);
  }

  @override
  Future<List<LeagueData>> getHotLeagues() async {
    final leaguesV2 = await _httpManager.getHotLeagues();
    return leaguesV2.toLegacy();
  }

  @override
  Future<List<LeagueData>> getOutrightLeagues() async {
    return await _httpManager.getOutrightLeagues();
  }

  @override
  Future<List<SpecialOutrightModel>> getSpecialOutright(int sportId) async {
    if (_httpManager.sbApiBaseUrl.isEmpty) {
      throw Exception('SB API base URL not set. Load sbConfig (sport_domain) first.');
    }

    final url =
        '${_httpManager.sbApiBaseUrl}/outright/events'
        '?sportId=$sportId';

    final response = await _httpManager.send(url, json: true);
    List<dynamic> rawList;
    if (response is List) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      final data = response['data'] ?? <dynamic>[];
      rawList = data is List ? data : <dynamic>[];
    } else {
      return [];
    }

    final cards = <SpecialOutrightModel>[];
    for (final leagueRaw in rawList) {
      if (leagueRaw is! Map<String, dynamic>) continue;
      final leagueId = _safeParseInt(leagueRaw['2']);
      final leagueLogo = leagueRaw['3']?.toString() ?? '';
      final leagueName = leagueRaw['4']?.toString() ?? '';
      final events = leagueRaw['0'];
      if (events is! List) continue;

      for (final eventRaw in events) {
        if (eventRaw is! Map<String, dynamic>) continue;
        final eventId = _safeParseInt(eventRaw['3']);
        final eventName = eventRaw['4']?.toString() ?? '';
        final endDate = eventRaw['6']?.toString() ?? '';
        final endTime = _safeParseInt(eventRaw['7']);
        final lines = eventRaw['0'];
        if (lines is! List) continue;

        var lineIndex = 0;
        for (final lineRaw in lines) {
          if (lineRaw is! Map<String, dynamic>) continue;
          final i = lineIndex++;
          final lineName = lineRaw['1']?.toString() ?? '';

          final lineOrder = _safeParseInt(lineRaw['2']);
          final oddsRaw = lineRaw['0'];
          final selections = oddsRaw is List
              ? oddsRaw
                  .whereType<Map<String, dynamic>>()
                  .map(SpecialOutrightSelection.fromJson)
                  .toList()
              : <SpecialOutrightSelection>[];
          if (selections.isEmpty) continue;

          cards.add(SpecialOutrightModel(
            outrightId: eventId * 1000 + i,
            eventId: eventId,
            outrightName: lineName,
            eventName: eventName,
            lineOrder: lineOrder,
            endDate: endDate,
            startTime: endTime,
            leagueId: leagueId,
            leagueLogo: leagueLogo,
            leagueName: leagueName,
            selections: selections,
          ));
        }
      }
    }
    return cards;
  }

  @override
  Future<void> changeSport(int sportId) async {
    await _storage.saveSportId(sportId);
    _httpManager.sportTypeId = sportId;
  }

  @override
  int get currentSportId => _httpManager.sportTypeId;
}

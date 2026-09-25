import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/event_model.dart';
import 'package:sun_sports/core/services/models/api_v2/livestream_response.dart';

abstract class EventsRepository {
  Future<List<EventModel>> getEvents({int? leagueId, bool isLive = false});
  Future<List<EventModel>> getHotMatches();
  Future<List<EventModel>> getOutrightEvents({int? leagueId});
  Future<LivestreamResponse> getLiveStreamLink(String eventId, String brand);
  Future<Map<String, dynamic>> getHighlights();
}

class EventsRepositoryImpl implements EventsRepository {
  final SbHttpManager _http;

  EventsRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<List<EventModel>> getEvents({
    int? leagueId,
    bool isLive = false,
  }) async {
    try {
      String info = '';
      if (leagueId != null) {
        info += '&leagueId=$leagueId';
      }
      if (isLive) {
        info += '&isLive=true';
      }

      final response = await _http.getEventMarket(info, SbConfig.agentId);
      return _parseEvents(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EventModel>> getHotMatches() async {
    try {
      final response = await _http.getEventHotMatch(SbConfig.agentId);
      return _parseEvents(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EventModel>> getOutrightEvents({int? leagueId}) async {
    try {
      String info = '';
      if (leagueId != null) {
        info += '&leagueId=$leagueId';
      }

      final response = await _http.getEventOutright(info, SbConfig.agentId);
      return _parseEvents(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<LivestreamResponse> getLiveStreamLink(
    String eventId,
    String brand,
  ) async {
    try {
      return await _http.getLiveLink(eventId, brand);
    } catch (e) {
      return const LivestreamResponse();
    }
  }

  @override
  Future<Map<String, dynamic>> getHighlights() async {
    try {
      return await _http.getHighlight();
    } catch (e) {
      return {};
    }
  }

  List<EventModel> _parseEvents(Map<String, dynamic> response) {
    if (response['events'] == null) return [];

    final eventsData = response['events'] as List<dynamic>;
    return eventsData
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

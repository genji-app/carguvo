import 'dart:convert';
import 'package:sun_sports/core/network/api_endpoints.dart';
import 'package:sun_sports/core/network/sb_api_client.dart';

class SbBettingService {
  SbBettingService._internal();
  static final SbBettingService _instance = SbBettingService._internal();
  static SbBettingService get instance => _instance;

  String Function() getSbApiBaseUrl = () => '';
  String Function() getUserTokenSb = () => '';
  int Function() getSportTypeId = () => 1;
  String Function() getCustId = () => '';
  String Function() getCustLogin = () => '';

  String get _baseUrl => getSbApiBaseUrl();
  String get _token => getUserTokenSb();
  int get _sportTypeId => getSportTypeId();
  String get _custId => getCustId();
  String get _custLogin => getCustLogin();

  Future<Map<String, dynamic>> calculateBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
    int? sportId,
  }) async {
    final url = SbApiEndpoints.buildCalculateBetsUrl(_baseUrl, sportId ?? _sportTypeId);
    final requestBody = {...body, 'token': _token, 'userId': _custId};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          authorization: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calculateOutrightBets(
    Map<String, dynamic> body,
  ) async {
    final url = SbApiEndpoints.buildCalculateOutrightBetsUrl(_baseUrl);
    final requestBody = {...body, 'token': _token, 'userId': _custId};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          authorization: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calculateBetsParlay(
    Map<String, dynamic> body, {
    int? sportId,
  }) async {
    final url = SbApiEndpoints.buildCalculateBetsV2Url(
      _baseUrl,
      sportId ?? _sportTypeId,
    );
    final requestBody = {...body, 'token': _token, 'userId': _custId};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          authorization: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> placeBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
    int? sportId,
  }) async {
    final effectiveSportId = sportId ?? _sportTypeId;
    final url = SbApiEndpoints.buildPlaceBetsUrl(_baseUrl, effectiveSportId);
    final requestBody = effectiveSportId == 1
        ? {...body, 'token': _token, 'userName': _custLogin, 'userId': ''}
        : {...body};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
          lng: 'vi',
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> placeOutrightBets(
    Map<String, dynamic> body,
  ) async {
    final url = SbApiEndpoints.buildPlaceOutrightBetsUrl(_baseUrl);
    final requestBody = {
      ...body,
      'token': _token,
      'userName': _custLogin,
      'userId': '',
    };

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
          lng: 'vi',
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> placeBetsParlay(
    Map<String, dynamic> body, {
    int? sportId,
  }) async {
    final effectiveSportId = sportId ?? _sportTypeId;
    final url = SbApiEndpoints.buildPlaceBetsV2Url(_baseUrl, effectiveSportId);
    final requestBody = {
      ...body,
      'token': _token,
      'userName': _custLogin,
      'userId': '',
    };

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
          lng: 'vi',
        )
        as Map<String, dynamic>;
  }

  Future<dynamic> betsReporting(
    String status, {
    int sportId = 1,
    String? token,
  }) async {
    final url = SbApiEndpoints.buildBetsReportingUrl(
      _baseUrl,
      _sportTypeId,
      status,
      _custId,
      token ?? _token,
    );
    final response = await SbApiClient.instance.send(
      url,
      headerToken: true,
      json: true,
    );

    if (response is List) {
      return response;
    } else if (response is Map<String, dynamic>) {
      if (response.containsKey('bets')) {
        return response['bets'];
      }
      return response;
    }
    return [];
  }

  Future<dynamic> getBetSlipByStatus(
    String status, {
    int sportId = 1,
    String? token,
  }) async {
    final url = SbApiEndpoints.buildBetSlipByStatusUrl(
      _baseUrl,
      _sportTypeId,
      status,
      _custId,
      token ?? _token,
    );
    return await SbApiClient.instance.send(url, headerToken: true, json: true);
  }

  Future<Map<String, dynamic>> getStatusByTicketId(String ticketId) async {
    final url = SbApiEndpoints.buildTicketStatusUrl(
      _baseUrl,
      ticketId,
      _token,
      _sportTypeId,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCashOut(Map<String, dynamic> body) async {
    final url = SbApiEndpoints.buildGetCashOutUrl(_baseUrl, _sportTypeId);
    final requestBody = {'userId': _custId, ...body, 'token': _token};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cashOut(Map<String, dynamic> body) async {
    final url = SbApiEndpoints.buildCashOutUrl(_baseUrl, _sportTypeId);
    final requestBody = {'userId': _custId, ...body, 'token': _token};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
        )
        as Map<String, dynamic>;
  }
}

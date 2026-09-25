import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/network/api_endpoints.dart';
import 'package:sun_sports/core/network/sb_api_client.dart';
import 'package:sun_sports/core/network/sb_betting_service.dart';
import 'package:sun_sports/core/network/sb_config_loader.dart';
import 'package:sun_sports/core/network/sb_sport_service.dart';
import 'package:sun_sports/core/network/sb_user_service.dart';
import 'package:sun_sports/core/services/auth/session_superseded_exception.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_pin_item.dart';
import 'package:sun_sports/core/services/models/api_v2/livestream_response.dart';
import 'package:sun_sports/core/services/models/favorite_data.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/sun_api_response.dart';
import 'package:sun_sports/core/services/models/transaction/payment_slip_dto.dart';
import 'package:sun_sports/core/services/models/transaction/play_history_dto.dart';

import 'sun_extension.dart';

class SbHttpManager {
  static final SbHttpManager _instance = SbHttpManager._internal();
  factory SbHttpManager() => _instance;
  SbHttpManager._internal() {
    _initServices();
  }

  static SbHttpManager get instance => _instance;

  void _initServices() {
    SbSportService.instance.getSbApiBaseUrl = () => sbApiBaseUrl;
    SbSportService.instance.getUserTokenSb = () => _userTokenSb;
    SbSportService.instance.getSportTypeId = () => sportTypeId;

    SbBettingService.instance.getSbApiBaseUrl = () => sbApiBaseUrl;
    SbBettingService.instance.getUserTokenSb = () => _userTokenSb;
    SbBettingService.instance.getSportTypeId = () => sportTypeId;
    SbBettingService.instance.getCustId = () => custId;
    SbBettingService.instance.getCustLogin = () => custLogin;

    SbApiClient.instance.sbTokenProbeUrlBuilder = () =>
        sbApiBaseUrl.isEmpty ? '' : SbUserService.buildUserInfoUrl(sbApiBaseUrl);
  }

  String get _userToken => SbApiClient.instance.userToken;
  set _userToken(String value) => SbApiClient.instance.userToken = value;

  String get _userTokenSb => SbApiClient.instance.userTokenSb;
  set _userTokenSb(String value) => SbApiClient.instance.userTokenSb = value;

  String get _chatToken => SbApiClient.instance.chatToken;
  set _chatToken(String value) => SbApiClient.instance.chatToken = value;

  final Map<String, String> _domains = {
    'urlHomeWebsocket': '',
    'urlStatistics': '',
  };

  String sbApiBaseUrl = '';

  String videoDomain = '';
  String virtualVideoDomain = '';

  String urlHs = '';

  final Map<String, dynamic> _user = {
    'uid': '',
    'displayName': '',
    'cust_login': '',
    'cust_id': '',
    'balance': 0.0,
    'currency': '',
    'status': 'Active',
  };

  Completer<void> _userInfoReadyCompleter = Completer<void>();

  Future<void> get userInfoReady => _userInfoReadyCompleter.future;

  int sportTypeId = 1;

  String get userToken => _userToken;
  String get userTokenSb => _userTokenSb;
  String get chatToken => _chatToken;
  String get custLogin => _user['cust_login'] as String;
  String get custId => _user['cust_id'] as String;
  String get uid => _user['uid'] as String;
  String get displayName => _user['displayName'] as String;
  double get userBalance => (_user['balance'] as num).toDouble();
  String get currency => _user['currency'] as String;
  String get status => _user['status'] as String;
  Map<String, dynamic> get user => Map.from(_user);

  double get userBalanceX1k => userBalance;

  String get urlHomeWebsocket => _domains['urlHomeWebsocket'] ?? '';
  String get urlStatistics => _domains['urlStatistics'] ?? '';

  String get hostDomain => SbConfig.instance.hostDomain ?? '';

  String get apiDomain =>
      SbConfig.instance.mainConfig['api_domain'] as String? ?? '';

  void setUserBalance(double value) {
    _user['balance'] = value;
  }
  set userToken(String value) => _userToken = value;
  set userTokenSb(String value) => _userTokenSb = value;
  set chatToken(String value) => _chatToken = value;

  void updateUserData(String key, dynamic value) {
    if (_user.containsKey(key)) {
      _user[key] = value;
    }
  }

  Future<dynamic> send(
    String url, {
    bool post = false,
    bool delete = false,
    String? body,
    bool contentJson = false,
    bool headerToken = false,
    bool base64 = false,
    bool json = false,
    bool authorization = false,
    String? token,
    String? lng,
    CancelToken? cancelToken,
  }) async {
    return SbApiClient.instance.send(
      url,
      post: post,
      delete: delete,
      body: body,
      contentJson: contentJson,
      headerToken: headerToken,
      base64: base64,
      json: json,
      authorization: authorization,
      token: token,
      lng: lng,
      cancelToken: cancelToken,
    );
  }

  static Future<Map<String, dynamic>> getConfig(String url) =>
      SbConfigLoader.getConfig(url);

  Future<String> getSbToken() async {
    final config = SbConfig.instance;
    final sportDomain = config.mainConfig['sport_domain'];
    if (sportDomain == null || sportDomain.toString().isEmpty) {
      throw Exception('Sport token URL not configured. Load mainConfig first.');
    }
    final tokenUrl = config.sportTokenUrl;

    if (_userToken.isEmpty) {
      throw Exception('User token not set. Call refreshToken first.');
    }

    final tokenUsed = _userToken;
    final res =
        await send(tokenUrl, json: true, authorization: true, token: tokenUsed)
            as Map<String, dynamic>;
    if (_userToken != tokenUsed) {
      throw const SessionSupersededException('get-token');
    }

    if (res['data'] == null || res['data']['token'] == null) {
      throw Exception('Invalid token response');
    }

    _userTokenSb = res['data']['token'] as String;
    return _userTokenSb;
  }

  Future<void> getSetting(String urlSetting, int agentId) async {
    final Map<String, dynamic> setting;
    try {
      setting =
          await send(urlSetting + agentId.toString(), json: true)
              as Map<String, dynamic>;
    } on HttpException catch (e) {
      if (MaintenanceService.isUnavailableStatus(e.statusCode)) {
        MaintenanceService.instance.trigger();
      }
      rethrow;
    }

    if (setting.isEmpty) {
      MaintenanceService.instance.trigger();
      throw HttpException(502, 'Empty setting response (502/504)');
    }

    if (setting['errorCode']?.toString() ==
        '${MaintenanceService.maintenanceCode}') {
      MaintenanceService.instance.trigger();
      throw HttpException(
        MaintenanceService.maintenanceCode,
        MaintenanceService.defaultMessage,
      );
    }

    if (setting['0'] != null) {
      final domains = setting['0'] as Map<String, dynamic>;
      _domains['urlHomeWebsocket'] = domains['3'] as String? ?? '';
      _domains['urlStatistics'] = domains['6'] as String? ?? '';
    }
  }

  Future<bool> waitForConfigReady({
    Duration maxWaitTime = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) {
    return SbConfigLoader.waitForReady(
      isReady: () => sbApiBaseUrl.isNotEmpty,
      maxWaitTime: maxWaitTime,
      checkInterval: checkInterval,
    );
  }

  Future<bool> getUserByToken() async {
    return await getUserInfo();
  }

  Future<bool> getUserInfo() async {
    if (sbApiBaseUrl.isEmpty) {
      throw Exception('SB API base URL not set. Load sbConfig (sport_domain) first.');
    }

    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }

    final url = SbUserService.buildUserInfoUrl(sbApiBaseUrl);
    final tokenUsed = _userTokenSb;
    final info =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;
    if (_userTokenSb != tokenUsed) {
      throw const SessionSupersededException('users/info');
    }

    final parsed = SbUserService.parseUserInfo(info);
    _user.addAll(parsed);

    if (!_userInfoReadyCompleter.isCompleted) {
      _userInfoReadyCompleter.complete();
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (sbApiBaseUrl.isEmpty) {
      throw Exception('SB API base URL not set. Load sbConfig (sport_domain) first.');
    }
    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }
    final url = SbUserService.buildNotificationUrl(sbApiBaseUrl);
    final data = await send(url, json: true, headerToken: true);
    if (data is! Map<String, dynamic>) return [];
    final raw = data['0'];
    if (raw is! List) return [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
        .toList();
  }

  Future<bool> getUserBalance() async {
    if (sbApiBaseUrl.isEmpty) {
      throw Exception('SB API base URL not set. Load sbConfig (sport_domain) first.');
    }

    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }

    final url = SbUserService.buildUserBalanceUrl(sbApiBaseUrl);
    final info =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;

    final parsed = SbUserService.parseUserInfo(info);
    _user.addAll(parsed);

    return true;
  }

  @Deprecated('Use getUserInfo() or getUserBalance() instead')
  Future<bool> getInfo({String cmd = 'getBalanceUser'}) async {
    if (cmd == 'getUserByToken') {
      return getUserInfo();
    }
    return getUserBalance();
  }

  Future<Map<String, dynamic>> getEventMarket(String info, int agentId) =>
      SbSportService.instance.getEventMarket(info, agentId);

  Future<Map<String, dynamic>> getEventHotMatch(int agentId) =>
      SbSportService.instance.getEventHotMatch(agentId);

  Future<Map<String, dynamic>> getEventOutright(String info, int agentId) =>
      SbSportService.instance.getEventOutright(info, agentId);

  Future<List<LeagueData>> getLeagues({
    int? days,
    bool? isLive,
    int? leagueId,
    int? sportId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getLeagues(
    days: days,
    isLive: isLive,
    leagueId: leagueId,
    sportId: sportId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueData>> getOutrightLeagues() =>
      SbSportService.instance.getOutrightLeagues();

  Future<List<LeagueModelV2>> getHotLeagues() =>
      SbSportService.instance.getHotLeagues();

  Future<List<LeagueModelV2>> getPopularLeagues() =>
      SbSportService.instance.getPopularLeagues();

  Future<List<LeagueModelV2>> getEventsV2(
    EventsRequestModel request, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEventsV2(request, cancelToken: cancelToken);

  Future<Map<int, int>> getLeagueEventCounts(
    int sportId,
    List<int> leagueIds, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getLeagueEventCounts(
    sportId,
    leagueIds,
    cancelToken: cancelToken,
  );

  Future<List<String>> getEventDates(
    int sportId, {
    int days = 30,
    int tzOffset = -420,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEventDates(
    sportId,
    days: days,
    tzOffset: tzOffset,
    cancelToken: cancelToken,
  );

  Future<List<LeaguePinItem>> getLeaguesPin(
    int sportId, {
    CancelToken? cancelToken,
  }) =>
      SbSportService.instance.getLeaguesPin(sportId, cancelToken: cancelToken);

  Future<Map<String, dynamic>> getSearch(
    String txtSearch, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getSearch(txtSearch, cancelToken: cancelToken);

  Future<List<LeagueModelV2>> getLiveEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getLiveEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getTodayEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getTodayEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getEarlyEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEarlyEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<EventDetailResponseV2> getEventDetailV2(
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEventDetailV2(
    eventId,
    isMobile: isMobile,
    onlyParlay: onlyParlay,
    cancelToken: cancelToken,
  );

  Future<FavoriteData> getFavorites(int sportId, {CancelToken? cancelToken}) =>
      SbSportService.instance.getFavorites(sportId, cancelToken: cancelToken);

  Future<List<LeagueModelV2>> getFavoriteEvents(
    int sportId, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getFavoriteEvents(
    sportId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> addFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.addFavoriteLeague(
    sportId: sportId,
    leagueId: leagueId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.removeFavoriteLeague(
    sportId: sportId,
    leagueId: leagueId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> addFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.addFavoriteEvent(
    sportId: sportId,
    eventId: eventId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> removeFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.removeFavoriteEvent(
    sportId: sportId,
    eventId: eventId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> calculateBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
    int? sportId,
  }) => SbBettingService.instance.calculateBets(
    body,
    isV2: isV2,
    sportId: sportId,
  );

  Future<Map<String, dynamic>> calculateBetsParlay(
    Map<String, dynamic> body, {
    int? sportId,
  }) => SbBettingService.instance.calculateBetsParlay(body, sportId: sportId);

  Future<Map<String, dynamic>> calculateOutrightBets(
    Map<String, dynamic> body,
  ) => SbBettingService.instance.calculateOutrightBets(body);

  Future<Map<String, dynamic>> placeOutrightBets(Map<String, dynamic> body) =>
      SbBettingService.instance.placeOutrightBets(body);

  Future<Map<String, dynamic>> placeBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
    int? sportId,
  }) => SbBettingService.instance.placeBets(body, isV2: isV2, sportId: sportId);

  Future<Map<String, dynamic>> placeBetsParlay(
    Map<String, dynamic> body, {
    int? sportId,
  }) => SbBettingService.instance.placeBetsParlay(body, sportId: sportId);

  Future<dynamic> betsReporting(
    String status, {
    int sportId = 1,
    String? token,
  }) => SbBettingService.instance.betsReporting(
    status,
    sportId: sportId,
    token: token,
  );

  Future<dynamic> getBetSlipByStatus(
    String status, {
    int sportId = 1,
    String? token,
  }) => SbBettingService.instance.getBetSlipByStatus(
    status,
    sportId: sportId,
    token: token,
  );

  Future<SunApiResponse<dynamic>> getOTPCode(String phoneNumber) async {
    final paygateUrl = SbConfig.instance.paygateDomainUrl;
    final queryParameters = {
      'command': 'getOTPCode',
      'type': '1',
      'phone': phoneNumber,
    };
    final url = Uri.parse(
      paygateUrl,
    ).replace(queryParameters: queryParameters).toString();
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    return SunApiResponse.fromJson(response, (json) => json);
  }

  Future<dynamic> activePhone(String otp) async {
    final paygateUrl = SbConfig.instance.paygateDomainUrl;
    final queryParameters = {'command': 'activePhone', 'otp': otp};
    final url = Uri.parse(
      paygateUrl,
    ).replace(queryParameters: queryParameters).toString();
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<dynamic>.fromJson(
      response,
      (json) => json,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = SbConfig.instance.changePasswordUrl;
    final response =
        await send(
              url,
              json: true,
              post: true,
              authorization: true,
              token: _userToken,
              body: jsonEncode({
                'oldPassword': oldPassword,
                'newPassword': newPassword,
              }),
            )
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<dynamic>.fromJson(
      response,
      (json) => json,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<List<Map<String, dynamic>>> getAvatars() async {
    final url = SbConfig.instance.getAvatarsUrl;
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;
    debugPrint('getAvatars response: $url -----> $response');
    List<dynamic>? rawItems = response['items'] as List<dynamic>?;
    if (rawItems == null) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        rawItems = data['items'] as List<dynamic>?;
      }
    }

    if (rawItems == null) return const [];

    return rawItems
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<String> updateAvatar(int avatarId) async {
    final url = SbConfig.instance.buildUpdateAvatarUrl(avatarId);
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<Map<String, dynamic>>.fromJsonMap(
      response,
      (json) => json,
    );

    final data = parsedResponse.dataOrThrow;
    return data['message']?.toString() ?? 'Thành công';
  }

  Future<PaymentSlipResponseDto> getTransactionSlipHistory({
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) async {
    final url = SbUserService.buildTransactionHistoryUrl(
      apiDomain,
      slipType: slipType,
      skip: skip,
      limit: limit,
    );
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<PaymentSlipResponseDto>.fromJsonMap(
      response,
      PaymentSlipResponseDto.fromJson,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<(int, List<Map<String, dynamic>>)> fetchDepositComplainsHistory({
    int skip = 0,
    int limit = 10,
  }) async {
    final url = SbUserService.buildDepositComplainsHistoryUrl(
      apiDomain,
      skip: skip,
      limit: limit,
    );
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<Map<String, dynamic>>.fromJsonMap(
      response,
      (json) => json,
    );
    final data = parsedResponse.dataOrThrow;

    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final count = data['count'] as int? ?? items.length;
    return (count, items);
  }

  Future<(int, List<Map<String, dynamic>>)> fetchCardDepositHistory({
    int skip = 0,
    int limit = 10,
  }) async {
    final url = SbUserService.buildCardDepositHistoryUrl(
      apiDomain,
      skip: skip,
      limit: limit,
    );
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<Map<String, dynamic>>.fromJsonMap(
      response,
      (json) => json,
    );
    final data = parsedResponse.dataOrThrow;

    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final count = data['count'] as int? ?? items.length;
    return (count, items);
  }

  Future<(int, List<Map<String, dynamic>>)> fetchCardWithdrawHistory({
    int skip = 0,
    int limit = 10,
  }) async {
    final url = SbUserService.buildCardWithdrawHistoryUrl(
      apiDomain,
      skip: skip,
      limit: limit,
    );
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<Map<String, dynamic>>.fromJsonMap(
      response,
      (json) => json,
    );
    final data = parsedResponse.dataOrThrow;

    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final count = data['count'] as int? ?? items.length;
    return (count, items);
  }

  Future<dynamic> fetchBankAccounts() async {
    final url = SbUserService.buildBankAccountsUrl(apiDomain);
    return await send(url, json: true, authorization: true, token: _userToken);
  }

  Future<PlayHistoryResponseDto> fetchPlayHistory({
    int skip = 0,
    int limit = 5,
    String? assetName = 'gold',
  }) async {
    final url = SbUserService.buildPlayHistoryUrl(
      apiDomain,
      skip: skip,
      limit: limit,
      assetName: assetName,
    );

    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<PlayHistoryResponseDto>.fromJsonMap(
      response,
      PlayHistoryResponseDto.fromJson,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<dynamic> cleanupPlayHistory() async {
    final url = SbUserService.buildCleanupPlayHistoryUrl(apiDomain);

    final response =
        await send(
              url,
              json: true,
              post: false,
              authorization: true,
              token: _userToken,
            )
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<dynamic>.fromJson(
      response,
      (json) => json,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<Map<String, dynamic>> getStatusByTicketId(String ticketId) =>
      SbBettingService.instance.getStatusByTicketId(ticketId);

  Future<Map<String, dynamic>> getCashOut(Map<String, dynamic> body) =>
      SbBettingService.instance.getCashOut(body);

  Future<Map<String, dynamic>> cashOut(Map<String, dynamic> body) =>
      SbBettingService.instance.cashOut(body);

  Future<LivestreamResponse> getLiveLink(String eventId, String brand) async {
    final url = SbApiEndpoints.buildLiveStreamUrl(
      sbApiBaseUrl,
      eventId,
      brand,
    );
    final response =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;
    return LivestreamResponse.fromJson(response).wrapWithPlayerDomain(
      videoDomain: videoDomain,
      virtualVideoDomain: virtualVideoDomain,
    );
  }

  Future<Map<String, dynamic>> getMatchSummary(int summaryEventId) async {
    if (urlHs.isEmpty) {
      throw Exception('url_hs not set. sbConfig missing `url_hs` key.');
    }
    final url = SbApiEndpoints.buildMatchSummaryUrl(
      urlHs,
      summaryEventId,
    );
    return await send(url, json: true, headerToken: true)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHighlight() async {
    final url = SbApiEndpoints.buildHighlightsUrl(
      sbApiBaseUrl,
      sportTypeId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStatsLink(String eventId) async {
    final url = SbApiEndpoints.buildStatsUrl(
      urlStatistics,
      eventId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTrackerLink(String eventId) async {
    final url = SbApiEndpoints.buildTrackerUrl(
      urlStatistics,
      eventId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  void reset() {
    _userTokenSb = '';
    _chatToken = '';
    _domains.clear();
    SbUserService.resetUserData(_user);
    _rearmUserInfoReady();
  }

  void resetForLogout() {
    _userToken = '';
    _userTokenSb = '';
    _chatToken = '';
    SbUserService.resetUserData(_user);
    _rearmUserInfoReady();
  }

  void _rearmUserInfoReady() {
    if (_userInfoReadyCompleter.isCompleted) {
      _userInfoReadyCompleter = Completer<void>();
    }
  }

  @override
  String toString() =>
      'SbHttpManager(userToken: ${_userToken.isNotEmpty}, userTokenSb: ${_userTokenSb.isNotEmpty}, custLogin: $custLogin, balance: $userBalance)';
}

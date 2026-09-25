class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.example.com';

  static const String apiVersion = '/api/v1';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String profile = '$apiVersion/auth/profile';

  static const String userInfoByToken = '/api/v1/users/info';
  static const String userBalanceByToken = '/api/v1/users/balance';
  static const String users = '$apiVersion/users';
  static String user(String id) => '$users/$id';

  static const String games = '$apiVersion/games';
  static String game(String id) => '$games/$id';

  static const String casinos = '$apiVersion/casinos';
  static String casino(String id) => '$casinos/$id';

  static const String sports = '$apiVersion/sports';
  static String sport(String id) => '$sports/$id';
}

class SbApiEndpoints {
  SbApiEndpoints._();

  static const String eventMarket = '/event/get-event-market';

  static const String eventHot = '/events/hot';

  static const String eventOutright = '/event/outright';

  static const String eventsV2 = '/events';

  static String eventDetailV2(int eventId) => '$eventsV2/$eventId';

  static const String eventsDates = '$eventsV2/dates';

  static const String leaguesPin = '/leagues/pin';

  static const String search = '/search';

  static const String favorites = '/favorite';

  static const String favoriteEvents = '/favorite/events';

  static const String favoriteLeague = '/favorite/league';

  static const String favoriteEvent = '/favorite/event';

  static const String userInfo = '/users/info';

  static const String userBalance = '/users/balance';

  static const String notification = '/notification';

  static const String betsReporting = '/bet/betslips/history';

  static const String betSlipByStatus = '/bet/betslips';

  static const String ticketStatus = '/bet/getStatusByTicketId';

  static String liveStreamLink(String eventId) => '/streaming/$eventId';

  static const String highlights = '/streaming/game/highlight';

  static String matchSummary(int summaryEventId) =>
      '/api/v1/sport-events/sr:sport_event:$summaryEventId/summary';

  static const String calculateBets = '/bet/single/calculate-bet';

  static const String calculateBetsV2 = '/bet/parlay/calculate-bet';

  static const String calculateOutrightBets =
      '/bet/outright/calculate-bet';

  static const String placeBets = '/bet/single/place-bet';

  static const String placeBetsV2 = '/bet/parlay/place-bet';

  static const String placeOutrightBets = '/bet/outright/place-bet';

  static const String getCashOut = '/bet/cash-out/get';

  static const String cashOut = '/bet/cash-out';

  static String stats(String eventId) => '/stats/$eventId';

  static String tracker(String eventId) => '/tracker/$eventId';

  static const String eventsPopular = '/events/popular';

  static const String betStatisticsSimple = '/bet/statistics/simple';

  static const String betStatisticsUserDetails = '/bet/statistics/users';

  static const String paygateGetOTP = 'getOTPCode';
  static const String paygateActivePhone = 'activePhone';
  static const String paygateTransactionHistory = 'fetchTransactionSlipHistory';
  static const String paygateDepositComplains = 'fetchDepositComplains';
  static const String paygateCardHistory = 'fetchCardHistory';
  static const String paygateCardWithdraw = 'lichsudt';
  static const String paygateBankAccounts = 'fetchBankAccounts';
  static const String fetchUserTransaction2 = 'fetch-user-transaction2';

  static String buildEventMarketUrl(
    String baseUrl,
    int agentId,
    String token,
    int sportId, [
    String? extraParams,
  ]) {
    return '$baseUrl$eventMarket?agentId=$agentId&token=$token&sportId=$sportId${extraParams ?? ''}';
  }

  static String buildEventHotUrl(String baseUrl, int agentId, int sportId) {
    return '$baseUrl$eventHot?agentId=$agentId&sportId=$sportId';
  }

  static String buildEventOutrightUrl(
    String baseUrl,
    int agentId,
    String token,
    int sportId, [
    String? extraParams,
  ]) {
    return '$baseUrl$eventOutright?agentId=$agentId&token=$token&sportId=$sportId${extraParams ?? ''}';
  }

  static String buildEventsV2Url(String baseUrl, String queryString) {
    return '$baseUrl$eventsV2?$queryString';
  }

  static String buildEventsDatesUrl(
    String baseUrl,
    int sportId, {
    int days = 30,
    int tzOffset = -420,
  }) {
    return '$baseUrl$eventsDates?sportId=$sportId&days=$days&tzOffset=$tzOffset';
  }

  static String buildEventDetailV2Url(
    String baseUrl,
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
  }) {
    return '$baseUrl${eventDetailV2(eventId)}?isMobile=$isMobile&onlyParlay=$onlyParlay';
  }

  static String buildLeaguesPinUrl(String baseUrl, int sportId) {
    return '$baseUrl$leaguesPin?sportId=$sportId';
  }

  static String buildSearchUrl(String baseUrl, String txtSearch) {
    return '$baseUrl$search?txtSearch=${Uri.encodeComponent(txtSearch)}';
  }

  static String buildFavoritesUrl(String baseUrl, int sportId) {
    return '$baseUrl$favorites?sportId=$sportId';
  }

  static String buildFavoriteEventsUrl(String baseUrl, int sportId) {
    return '$baseUrl$favoriteEvents?sportId=$sportId';
  }

  static String buildFavoriteLeagueUrl(String baseUrl) {
    return '$baseUrl$favoriteLeague';
  }

  static String buildFavoriteEventUrl(String baseUrl) {
    return '$baseUrl$favoriteEvent';
  }

  static String buildUserInfoUrl(String baseUrl) {
    return '$baseUrl$userInfo';
  }

  static String buildUserBalanceUrl(String baseUrl) {
    return '$baseUrl$userBalance';
  }

  static String buildNotificationUrl(String baseUrl) {
    return '$baseUrl$notification';
  }

  static String buildBetsReportingUrl(
    String baseUrl,
    int sportId,
    String status,
    String userId,
    String token,
  ) {
    return '$baseUrl$betsReporting?sportId=$sportId&status=$status&userId=$userId&token=$token';
  }

  static String buildBetSlipByStatusUrl(
    String baseUrl,
    int sportId,
    String status,
    String userId,
    String token,
  ) {
    return '$baseUrl$betSlipByStatus?sportId=$sportId&status=$status&userId=$userId&token=$token';
  }

  static String buildTicketStatusUrl(
    String baseUrl,
    String ticketId,
    String token,
    int sportId,
  ) {
    return '$baseUrl$ticketStatus?ticketId=$ticketId&token=$token&sportId=$sportId';
  }

  static String buildLiveStreamUrl(
    String baseUrl,
    String eventId,
    String brand,
  ) {
    return '$baseUrl${liveStreamLink(eventId)}?brand=$brand';
  }

  static String buildHighlightsUrl(String baseUrl, int sportId, String token) {
    return '$baseUrl$highlights?sportId=$sportId&token=$token';
  }

  static String buildMatchSummaryUrl(String baseUrl, int summaryEventId) {
    return '$baseUrl${matchSummary(summaryEventId)}';
  }

  static String buildCalculateBetsUrl(String baseUrl, int sportId) {
    return '$baseUrl$calculateBets?sportId=$sportId';
  }

  static String buildCalculateBetsV2Url(String baseUrl, int sportId) {
    if (sportId == 1) return '$baseUrl$calculateBetsV2?sportId=$sportId';
    return '$baseUrl$calculateBetsV2';
  }

  static String buildCalculateOutrightBetsUrl(String baseUrl) {
    return '$baseUrl$calculateOutrightBets';
  }

  static String buildPlaceBetsUrl(String baseUrl, int sportId) {
    if (sportId == 1) return '$baseUrl$placeBets?sportId=$sportId';
    return '$baseUrl$placeBets/sport/$sportId';
  }

  static String buildPlaceBetsV2Url(String baseUrl, int sportId) {
    if (sportId == 1) return '$baseUrl$placeBetsV2?sportId=$sportId';
    return '$baseUrl$placeBetsV2';
  }

  static String buildPlaceOutrightBetsUrl(String baseUrl) {
    return '$baseUrl$placeOutrightBets';
  }

  static String buildGetCashOutUrl(String baseUrl, int sportId) {
    return '$baseUrl$getCashOut';
  }

  static String buildCashOutUrl(String baseUrl, int sportId) {
    return '$baseUrl$cashOut';
  }

  static String buildStatsUrl(String baseUrl, String eventId, String token) {
    return '$baseUrl${stats(eventId)}?token=$token';
  }

  static String buildTrackerUrl(String baseUrl, String eventId, String token) {
    return '$baseUrl${tracker(eventId)}?token=$token';
  }

  static String buildEventsPopularUrl(String baseUrl, int agentId) {
    return '$baseUrl$eventsPopular?agentId=$agentId';
  }

  static String buildBetStatisticsSimpleUrl(
    String baseUrl,
    int agentId,
    int eventId,
  ) {
    return '$baseUrl$betStatisticsSimple?agentId=$agentId&eventId=$eventId';
  }

  static String buildBetStatisticsUserDetailsUrl(
    String baseUrl,
    int agentId,
    int leagueId,
    int eventId, {
    int marketId = 0,
    String filter = 'latest',
  }) {
    return '$baseUrl$betStatisticsUserDetails?agentId=$agentId&leagueId=$leagueId&eventId=$eventId&marketId=$marketId&filter=${Uri.encodeComponent(filter)}';
  }

  static String _normalizeDomain(String apiDomain) {
    return apiDomain.endsWith('/')
        ? apiDomain.substring(0, apiDomain.length - 1)
        : apiDomain;
  }

  static String buildTransactionHistoryUrl(
    String apiDomain, {
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) {
    final base = _normalizeDomain(apiDomain);
    return '$base/paygate?command=$paygateTransactionHistory&limit=$limit&skip=$skip&slipType=$slipType';
  }

  static String buildDepositComplainsHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) {
    final base = _normalizeDomain(apiDomain);
    return '$base/paygate?command=$paygateDepositComplains&limit=$limit&skip=$skip';
  }

  static String buildCardDepositHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) {
    final base = _normalizeDomain(apiDomain);
    return '$base/paygate?command=$paygateCardHistory&limit=$limit&skip=$skip';
  }

  static String buildCardWithdrawHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) {
    final base = _normalizeDomain(apiDomain);
    return '$base/paygate?command=$paygateCardWithdraw&limit=$limit&skip=$skip';
  }

  static String buildBankAccountsUrl(String apiDomain) {
    final base = _normalizeDomain(apiDomain);
    return '$base/paygate?command=$paygateBankAccounts';
  }

  static String buildPlayHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 5,
    String? assetName,
  }) {
    final base = _normalizeDomain(apiDomain);
    if (assetName == null || assetName.isEmpty) {
      return '$base/sa?command=$fetchUserTransaction2&limit=$limit&skip=$skip';
    }
    return '$base/sa?command=$fetchUserTransaction2&limit=$limit&skip=$skip&assetName=$assetName';
  }

  static String buildCleanupPlayHistoryUrl(String apiDomain) {
    final baseUrl = _normalizeDomain(apiDomain);
    return '$baseUrl/gameapi/public/history/cleanup';
  }
}

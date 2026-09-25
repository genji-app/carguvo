import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:brand_config/brand_config.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/services/config/domain_override.dart';

class SbConfig {
  static final SbConfig _instance = SbConfig._internal();
  factory SbConfig() => _instance;
  SbConfig._internal();

  static SbConfig get instance => _instance;

  static const String mainConfigUrl =
      'https://cdn.jsdelivr.net/gh/jamesgreenmango/configs@master/creator_s_prod.json';

  static String get sbConfigUrl => AppEnv.sbConfigUrl;

  static const String authConfigUrl =
      'https://cdn.jsdelivr.net/gh/dev-itto/configs@main/sun/config/sappv363.json';

  static String get sun88BrandConfigUrl => AppEnv.brandConfigUrl;

  static int agentId = 0;
  static String agentCode = '';
  static String clientId = '';
  static String brandId = '';
  static String chatZone = '';
  static String chatRoom = '';

  static String brand = '';
  static String bundleId = '';
  static String appName = '';
  static String hsk = '';

  static String secretKey = '';

  static String authBrand = '';

  static String rsDomain = '';
  static String gameApiUrl = '';

  static String lodeApiUrl = '';

  static String lodeWsUrl = '';

  static String gamesUrl = '';
  static String livechatLicense = '';

  static String miniGameWsUrl = '';

  static String get livechatUrl => livechatLicense;

  static String sentryDsnWeb = '';

  static String sentryDsnMobile = '';

  static bool sentryEnabled = true;

  static double sentryTracesSampleRate = 0.0;

  static String sentryEnvironment = '';

  static bool sentryAllowDebug = false;

  static String get sentryDsn => kIsWeb ? sentryDsnWeb : sentryDsnMobile;

  Map<String, dynamic> brandConfig = {};

  DomainOverride _domainOverride = const DomainOverride();
  DomainOverride get domainOverride => _domainOverride;

  static final _brandConfigLoadedController = StreamController<void>.broadcast();
  static Stream<void> get onBrandConfigLoaded => _brandConfigLoadedController.stream;

  void applyBrandConfig(Map<String, dynamic> config) {
    brandConfig = config;

    final bc = BrandConfig(config);

    if (bc.intOf('agentId') != null) agentId = bc.intOf('agentId')!;
    if (bc.str('agentCode') != null) agentCode = bc.str('agentCode')!;
    if (bc.str('clientId') != null) clientId = bc.str('clientId')!;
    if (bc.str('brandId') != null) brandId = bc.str('brandId')!;
    if (bc.str('chatZone') != null) chatZone = bc.str('chatZone')!;
    if (bc.str('chatRoom') != null) chatRoom = bc.str('chatRoom')!;
    if (bc.str('brand') != null) brand = bc.str('brand')!;
    if (bc.str('bundleId') != null) bundleId = bc.str('bundleId')!;
    if (bc.str('appName') != null) appName = bc.str('appName')!;
    if (bc.str('authBrand') != null) authBrand = bc.str('authBrand')!;
    if (bc.str('rs_domain') != null) {
      rsDomain = AppEnv.withPathSegment(
        bc.str('rs_domain')!,
        AppEnv.resourcePathSegment,
      );
    }
    
    if (bc.str('game_api_url') != null) gameApiUrl = bc.str('game_api_url')!;
    if (bc.str('lode_api_url') != null) lodeApiUrl = bc.str('lode_api_url')!;
    if (bc.str('lode_ws_url') != null) lodeWsUrl = bc.str('lode_ws_url')!;
    if (bc.str('games_url') != null) gamesUrl = bc.str('games_url')!;
    if (bc.str('ws_mini_game') != null) miniGameWsUrl = bc.str('ws_mini_game')!;
    if (bc.str('livechat_license') != null) {
      livechatLicense = bc.str('livechat_license')!;
    }

    final assembled = bc.secretKey;
    if (assembled != null) secretKey = assembled;

    if (bc.str('sentry_dsn_web') != null) {
      sentryDsnWeb = bc.str('sentry_dsn_web')!;
    }
    if (bc.str('sentry_dsn_mobile') != null) {
      sentryDsnMobile = bc.str('sentry_dsn_mobile')!;
    }
    if (bc.boolOf('sentry_enabled') != null) {
      sentryEnabled = kReleaseMode && bc.boolOf('sentry_enabled')!;
    }
    if (bc.doubleOf('sentry_traces_sample_rate') != null) {
      sentryTracesSampleRate = bc.doubleOf('sentry_traces_sample_rate')!;
    }
    if (bc.str('sentry_environment') != null) {
      sentryEnvironment = bc.str('sentry_environment')!;
    }
    if (bc.boolOf('sentry_allow_debug') != null) {
      sentryAllowDebug = bc.boolOf('sentry_allow_debug')!;
    }

    _domainOverride = DomainOverride.fromBrandConfig(config);

    _brandConfigLoadedController.add(null);
  }

  static int get platformId => AppDevice.platformId;

  static int get versionId => AppDevice.versionId;

  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String wsTokenKey = 'ws_token';
  static const String deviceIdKey = 'device_id';
  static const String usernameKey = 'LOGGED_USER_NAME';
  static const String passwordKey = 'LOGGED_PASSWORD';

  static const String sportIdKey = 'sbSportID';
  static const String oddsStyleKey = 'sbOddsStyle';

  static const int defaultSportId = 1;

  bool isDebugMode = false;

  bool useMockData = false;

  Map<String, dynamic> mainConfig = {};

  Map<String, dynamic> authConfig = {};

  String? hostDomain;

  String? distId;

  String? appId;

  String? idServiceUrl;

  String? paygateUrl;

  String wsToken = '';

  String? mainWsLoginInfo;

  String? mainWsLoginSignature;

  String? mainWsUsername;

  String? mainWsPassword;

  String get loginUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=loginAccessToken';
  }

  String get refreshUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=refreshToken&refreshToken=';
  }

  String get changePasswordUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=changePass';
  }

  String get getAvatarsUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=getAvatars';
  }

  String buildUpdateAvatarUrl(int avatarId) {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=updateAvatar&id=$avatarId';
  }

  String get sportTokenUrl {
    final sportDomain = mainConfig['sport_domain'] ?? '';
    return '$sportDomain?command=get-token';
  }

  String get mainWs {
    final mainWsUrl = mainConfig['main_ws_url'] as String? ?? '';
    if (mainWsUrl.isEmpty) return '';
    return '$mainWsUrl?token=$wsToken';
  }

  String get chatWs {
    final wsSportDomain = mainConfig['ws_sport_domain'] as String? ?? '';
    if (wsSportDomain.isEmpty) return '';
    return '$wsSportDomain?token=$wsToken';
  }

  String get sportDomainTop => (mainConfig['sport_domain_top'] ?? '') as String;

  String get avatarUrl => (mainConfig['avatarUrl'] ?? '') as String;

  String get logo => (mainConfig['logo'] ?? '') as String;

  String get serverTimeUrl {
    if (idServiceUrl == null) return '';
    return '$idServiceUrl?command=getTime';
  }

  String get distributorUrl {
    if (hostDomain == null) return '';
    return '${hostDomain}distributor?command=regdis&bundle=$bundleId&appName=$appName';
  }

  String get acsConfigUrl {
    if (hostDomain == null || distId == null || appId == null) return '';
    return '${hostDomain}acs?command=get-bid&distId=$distId&versionId=$versionId&platformId=$platformId&appId=$appId';
  }

  String get paygateDomainUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '$apiDomain/paygate';
  }

  void reset() {
    mainConfig = {};
    authConfig = {};
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  void resetAuth() {
    authConfig = {};
    hostDomain = null;
    distId = null;
    appId = null;
    idServiceUrl = null;
    paygateUrl = null;
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  void resetForLogout() {
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  bool get isConfigLoaded => mainConfig.isNotEmpty;

  bool get isAuthConfigReady =>
      hostDomain != null &&
      distId != null &&
      appId != null &&
      idServiceUrl != null;

  String getAvatarUrl(String avatarId) =>
      (avatarUrl.isEmpty || avatarId.isEmpty) ? '' : '$avatarUrl$avatarId';

  @override
  String toString() =>
      'SbConfig(isConfigLoaded: $isConfigLoaded, isAuthConfigReady: $isAuthConfigReady, wsToken: ${wsToken.isNotEmpty}, useMockData: $useMockData)';
}

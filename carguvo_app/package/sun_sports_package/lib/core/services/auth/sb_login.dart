import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart' show SentryLevel;
import 'package:sun_sports/core/services/monitoring/login_timing.dart';
import 'package:sun_sports/core/network/sb_api_client.dart' show HttpException;
import 'package:sun_sports/core/network/sb_config_cache.dart';
import 'package:sun_sports/core/network/sb_config_loader.dart';
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import '../config/sb_config.dart';
import '../network/sb_http_manager.dart';
import 'package:sport_events/sport_events.dart' show LeagueAliasStore;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import '../websocket/websocket_manager.dart';
import 'package:sun_sports/core/services/auth/auth_config_service.dart';
import 'package:sun_sports/core/services/auth/session_superseded_exception.dart';

class SbLogin {
  static final AppLogger _logger = AppLogger();
  static final SbConfig _config = SbConfig.instance;
  static final SbHttpManager _http = SbHttpManager.instance;

  static final StreamController<String> _forceLogoutController =
      StreamController<String>.broadcast();

  static Stream<String> get forceLogoutStream => _forceLogoutController.stream;

  static final StreamController<void> _sessionReadyController =
      StreamController<void>.broadcast();

  static Stream<void> get sessionReadyStream => _sessionReadyController.stream;

  static Timer? _sbTokenRetryTimer;

  static int _sbTokenRetryAttempt = 0;

  static const int _sbTokenMaxRetries = 5;

  static bool _isAuthError(Object e) =>
      e is HttpException && (e.statusCode == 401 || e.statusCode == 403);

  static const Duration _socketDisconnectTimeout = Duration(milliseconds: 800);

  static const Duration _loginStepTimeout = Duration(seconds: 8);

  static Future<T> _boundedOnLogin<T>(Future<T> future) =>
      LoginTiming.current == null ? future : future.timeout(_loginStepTimeout);

  static int _sessionGeneration = 0;
  static int get sessionGeneration => _sessionGeneration;

  static void _bumpSessionGeneration(String reason) {
    _sessionGeneration++;
    _logger.i('Session generation → $_sessionGeneration ($reason)');
  }

  static void _throwIfSuperseded(int generation, String step) {
    if (generation == _sessionGeneration) return;
    throw SessionSupersededException(
      step,
      started: generation,
      current: _sessionGeneration,
    );
  }

  static void _resetSbTokenRetry() {
    _sbTokenRetryTimer?.cancel();
    _sbTokenRetryTimer = null;
    _sbTokenRetryAttempt = 0;
  }

  static void _scheduleSbTokenRetry() {
    _sbTokenRetryTimer?.cancel();
    if (_sbTokenRetryAttempt >= _sbTokenMaxRetries) {
      _logger.w(
        'Sb token: đã retry $_sbTokenMaxRetries lần vẫn lỗi, dừng background '
        'retry (giữ phiên, user vẫn xem được sport book như guest)',
      );
      return;
    }
    final int rawDelay = 2 << _sbTokenRetryAttempt;
    final int delaySec = rawDelay > 30 ? 30 : rawDelay;
    _logger.i('Sb token: lên lịch background retry sau ${delaySec}s');
    _sbTokenRetryTimer = Timer(Duration(seconds: delaySec), _runSbTokenRetry);
  }

  static Future<void> _runSbTokenRetry() async {
    _sbTokenRetryAttempt++;
    try {
      _logger.i('Sb token background retry #$_sbTokenRetryAttempt...');
      await _http.getSbToken();
      await _http.getUserByToken();
      _logger.i('Sb token background retry thành công — session đã đầy đủ');
      _resetSbTokenRetry();
      _sessionReadyController.add(null);
    } catch (e, stackTrace) {
      if (_isAuthError(e)) {
        _logger.e(
          'Sb token retry: lỗi auth (token bị từ chối) → force logout',
          error: e,
          stackTrace: stackTrace,
        );
        _resetSbTokenRetry();
        _forceLogoutController.add('sb_token_auth_error');
      } else {
        _logger.w(
          'Sb token retry #$_sbTokenRetryAttempt lỗi transient, sẽ thử lại',
          e,
          stackTrace,
        );
        _scheduleSbTokenRetry();
      }
    }
  }

  static Future<bool> connect({
    bool isReconnect = false,
    bool hideLoading = false,
    bool freshLogin = false,
  }) async {
    try {
      _logger.i('SbLogin.connect() starting...');
      if (!isReconnect) _bumpSessionGeneration('login');

      await _init(!isReconnect, freshLogin: freshLogin);

      unawaited(_connectToServer());

      final v2Adapter = SportSocketAdapter.instance;
      if (v2Adapter != null &&
          v2Adapter.isInitialized &&
          !v2Adapter.isConnected) {
        _logger.i('Reconnecting V2 sport socket after login (background)...');
        unawaited(
          v2Adapter.connect().catchError((Object e, StackTrace st) {
            _logger.w('V2 sport socket reconnect after login failed', e, st);
          }),
        );
      }

      _logger.i('SbLogin.connect() completed successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e('SbLogin.connect() failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<bool> _init(bool getConfig, {bool freshLogin = false}) async {
    try {
      LoginTiming.current?.step('config');
      if (getConfig) {
        await loadBrandConfigOnly();
      }

      if (getConfig) {
        if (AuthConfigService.instance.isReady) {
          _logger.i('Auth config already loaded, skipping');
        } else {
          _logger.i('Initializing auth config...');
          final authConfigReady = await AuthConfigService.instance
              .initializeConfig();
          if (authConfigReady) {
            _logger.i('Auth config initialized successfully');
          } else {
            _logger.w('Auth config initialization failed, continuing anyway...');
          }
        }
      }

      if (getConfig && _config.isConfigLoaded) {
        _logger.i('mainConfig already loaded, skipping');
      } else if (getConfig && SbConfig.mainConfigUrl.isNotEmpty) {
        _logger.i('Loading mainConfig from GitHub...');
        final mainConfig = await SbHttpManager.getConfig(
          SbConfig.mainConfigUrl,
        );
        _config.mainConfig = {..._config.mainConfig, ...mainConfig};

        final patch = _config.domainOverride.toMainConfigPatch();
        if (patch.isNotEmpty) {
          _config.mainConfig = {..._config.mainConfig, ...patch};
          _logger.i('Domain overrides applied: ${patch.keys.toList()}');
        }
      }

      final serverSettingsReady = _http.sbApiBaseUrl.isNotEmpty &&
          (_http.urlHomeWebsocket.isNotEmpty ||
              MaintenanceService.instance.isUnderMaintenance);
      if (getConfig && serverSettingsReady) {
        _logger.i('sbConfig + server settings already loaded, skipping');
      } else if (getConfig && SbConfig.sbConfigUrl.isNotEmpty) {
        _logger.i('Loading sbConfig from GitHub...');
        final sbConfig =
            await SbConfigLoader.getConfigJson(SbConfig.sbConfigUrl);

        final urlSetting = sbConfig['urlSetting'] as String?;
        if (urlSetting == null) {
          throw Exception('sbConfig does not contain urlSetting');
        }

        _applySbConfig(sbConfig);
        if (_http.sbApiBaseUrl.isEmpty) {
          throw Exception('sbConfig does not contain sport_domain');
        }

        _logger.i('Loading server settings from: $urlSetting');
        await _getSettingIgnoringMaintenance(urlSetting);

      }

      if (getConfig || _http.userTokenSb.isEmpty) {
        _logger.i('Refreshing access token...');
        LoginTiming.current?.step('session');
        await refreshToken(reuseStoredAccessToken: freshLogin);
      }

      if (MaintenanceService.instance.isUnderMaintenance) {
        _logger.w('Bỏ qua getUserByToken: SB đang bảo trì');
      } else if (_http.userTokenSb.isEmpty) {
        _logger.w(
          'Bỏ qua getUserByToken: sb token chưa sẵn sàng (đang background retry)',
        );
      } else if (freshLogin) {
        _logger.i('Fresh login: loading user info in the background');
        unawaited(_loadUserInfoInBackground(_sessionGeneration));
      } else {
        _logger.i('Validating user token...');
        LoginTiming.current?.step('user');
        try {
          await _boundedOnLogin(_http.getUserByToken());
          _logger.i(
            'User info loaded: ${_http.displayName} (${_http.custLogin})',
          );
        } catch (e, stackTrace) {
          if (e is SessionSupersededException) rethrow;
          if (_isAuthError(e)) rethrow;
          _logger.w(
            'getUserByToken lỗi transient — chuyển sang background retry',
            e,
            stackTrace,
          );
          _scheduleSbTokenRetry();
        }
      }

      _flushConfigDiagnostics();

      return true;
    } catch (e, stackTrace) {
      _logger.e('SbLogin._init() failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static void _flushConfigDiagnostics() {
    try {
      final events = SbConfigCache.takeDiagnostics();
      if (events.isEmpty) return;
      SentryService.captureLog(
        'sb_config_cache diagnostics (${events.length} events): '
        '${jsonEncode(events)}',
        level: SentryLevel.warning,
        category: 'config-cache',
      );
    } catch (_) {
    }
  }

  static Future<void> refreshToken({bool reuseStoredAccessToken = false}) async {
    try {
      final generation = _sessionGeneration;
      final prefs = await SharedPreferences.getInstance();

      final String newAccessToken;
      final storedAccessToken = prefs.getString(SbConfig.userTokenKey) ?? '';
      if (reuseStoredAccessToken && storedAccessToken.isNotEmpty) {
        _logger.i('Fresh login: reusing the access token just minted, skipping refreshToken');
        newAccessToken = storedAccessToken;
      } else {
        newAccessToken = await _exchangeRefreshToken(prefs, generation);
      }

      if (reuseStoredAccessToken && storedAccessToken.isNotEmpty) {
        _http.userToken = newAccessToken;
        _startWsLoginInfoFetch(newAccessToken, generation);
      } else {
        final loginResponse =
            await _http.send(
                  _config.loginUrl,
                  authorization: true,
                  token: newAccessToken,
                  json: true,
                )
                as Map<String, dynamic>;
        _throwIfSuperseded(generation, 'loginAccessToken');
        _applyLoginAccessToken(loginResponse);

        _http.userToken = newAccessToken;
      }

      _logger.i('Getting sportbook token...');
      LoginTiming.current?.step('sb');
      _resetSbTokenRetry();
      try {
        await _boundedOnLogin(_http.getSbToken());
        _logger.i('Sportbook token obtained');
      } catch (e, stackTrace) {
        if (e is SessionSupersededException) rethrow;
        if (_isAuthError(e)) {
          _logger.e(
            'getSbToken: token bị từ chối (auth error) → rethrow',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
        _logger.w(
          'getSbToken lỗi transient (vd timeout) — vào app bằng access/wsToken, '
          'lấy sb token ở background. KHÔNG logout.',
          e,
          stackTrace,
        );
        _scheduleSbTokenRetry();
      }

      _logger.i('Token refresh completed (access + wsToken sẵn sàng)');
    } catch (e, stackTrace) {
      _logger.e('Failed to refresh token', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static void _applyLoginAccessToken(Map<String, dynamic> loginResponse) {
    if (loginResponse['data'] == null) return;
    final data = loginResponse['data'] as Map<String, dynamic>;

    if (data['wsToken'] != null) {
      _config.wsToken = data['wsToken'] as String;
      _logger.i('wsToken obtained');
    }

    if (data['info'] != null) {
      _config.mainWsLoginInfo = jsonEncode(data['info']);
      _logger.i('mainWsLoginInfo obtained');
    }

    if (data['signature'] != null) {
      _config.mainWsLoginSignature = data['signature'] as String;
      _logger.i('mainWsLoginSignature obtained');
    }
  }

  static Future<void>? _wsLoginInfoInFlight;

  static void _startWsLoginInfoFetch(String accessToken, int generation) {
    final future = _fetchWsLoginInfo(accessToken, generation);
    _wsLoginInfoInFlight = future;
    unawaited(
      future.whenComplete(() {
        if (identical(_wsLoginInfoInFlight, future)) _wsLoginInfoInFlight = null;
      }),
    );
  }

  static Future<void> _fetchWsLoginInfo(
    String accessToken,
    int generation,
  ) async {
    try {
      final loginResponse =
          await _http.send(
                _config.loginUrl,
                authorization: true,
                token: accessToken,
                json: true,
              )
              as Map<String, dynamic>;
      _throwIfSuperseded(generation, 'loginAccessToken (background)');
      _applyLoginAccessToken(loginResponse);
    } catch (e, stackTrace) {
      _logger.w(
        'Background loginAccessToken failed — mini socket will refresh on demand',
        e,
        stackTrace,
      );
    }
  }

  static Future<void> ensureWsLoginCredentials() async {
    final inFlight = _wsLoginInfoInFlight;
    if (inFlight != null) await inFlight;
    final info = _config.mainWsLoginInfo;
    final signature = _config.mainWsLoginSignature;
    if (info != null &&
        info.isNotEmpty &&
        signature != null &&
        signature.isNotEmpty &&
        _config.wsToken.isNotEmpty) {
      return;
    }
    await refreshToken();
  }

  static Future<void> _loadUserInfoInBackground(int generation) async {
    try {
      await _http.getUserByToken();
      if (generation != _sessionGeneration) return;
      _logger.i(
        'User info loaded (background): ${_http.displayName} (${_http.custLogin})',
      );
      _sessionReadyController.add(null);
    } on SessionSupersededException catch (e) {
      _logger.w('Background user info dropped — $e');
    } catch (e, stackTrace) {
      if (generation != _sessionGeneration) return;
      if (_isAuthError(e)) {
        _logger.e(
          'users/info rejected the session minted seconds ago → force logout',
          error: e,
          stackTrace: stackTrace,
        );
        _forceLogoutController.add('user_info_auth_error');
        return;
      }
      _logger.w(
        'users/info transient failure after login — background retry',
        e,
        stackTrace,
      );
      _scheduleSbTokenRetry();
    }
  }

  static Future<String> _exchangeRefreshToken(
    SharedPreferences prefs,
    int generation,
  ) async {
    final storedRefreshToken = prefs.getString(SbConfig.refreshTokenKey);
    final actualToken = storedRefreshToken ?? '';

    if (actualToken.isEmpty) {
      _logger.e('No refresh token found in localStorage');
      throw Exception('No refresh token available');
    }

    _logger.i('Refresh token loaded from localStorage');

    final refreshResponse =
        await _http.send('${_config.refreshUrl}$actualToken', json: true)
            as Map<String, dynamic>;
    _throwIfSuperseded(generation, 'refreshToken');

    final data = refreshResponse['data'] as Map<String, dynamic>?;
    final newAccessToken = data?['accessToken'] as String?;

    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      await prefs.setString(SbConfig.userTokenKey, newAccessToken);
      _logger.i('New access token obtained and saved');
      return newAccessToken;
    }
    if (data != null) {
      final message =
          data['message'] as String? ?? 'Refresh token expired or invalid';
      _logger.e('Refresh token rejected by server: $message');
      throw HttpException(401, message);
    }
    throw HttpException(0, 'Empty refresh response (transient)');
  }

  static Future<void> _connectToServer() async {
    try {
      _logger.i('Connecting to WebSocket servers...');

      final wsManager = WebSocketManager.instance;

      final chatConnected = await wsManager.connectChat();
      if (chatConnected) {
        _logger.i('Chat WebSocket connected successfully');
      } else {
        _logger.w('Chat WebSocket connection failed');
      }

      _logger.i(
        'V1 Sportbook WebSocket DISABLED - using V2 SportSocketClient instead',
      );

      _logger.i('WebSocket connections initiated');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to connect WebSockets',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static bool _isReconnecting = false;

  static Future<void> reconnect() async {
    if (_isReconnecting) return;
    _isReconnecting = true;
    try {
      _logger.i('Reconnecting...');

      WebSocketManager.instance.killAll();

      _http.reset();

      await refreshToken();

      await connect(isReconnect: true, hideLoading: true);

      _logger.i('Reconnect completed');
    } on SessionSupersededException catch (e) {
      _logger.w('Reconnect abandoned — $e');
    } catch (e, stackTrace) {
      _logger.e('Reconnect failed', error: e, stackTrace: stackTrace);
      await closeCreatorGame(
        555,
        withPopup: true,
        info: 'Reconnect failed after maximum retries',
      );
    } finally {
      _isReconnecting = false;
    }
  }

  static Future<void> closeCreatorGame(
    int errorCode, {
    bool withPopup = true,
    String info = 'Mất kết nối đến máy chủ!',
  }) async {
    try {
      _logger.e('Closing game with error code: $errorCode - $info');
      _bumpSessionGeneration('closeCreatorGame($errorCode)');

      WebSocketManager.instance.killAll();

      _config.reset();
      _http.reset();

      _forceLogoutController.add('$info ($errorCode)');

      if (withPopup) {
        _logger.w('Show error popup: $info ($errorCode)');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error during closeCreatorGame',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> logout() async {
    try {
      _logger.i('SbLogin.logout() starting...');
      _bumpSessionGeneration('logout');

      _resetSbTokenRetry();

      _logger.i('Disconnecting all WebSockets...');
      WebSocketManager.instance.killAll();

      try {
        await SportSocketAdapter.instance?.disconnect().timeout(
          _socketDisconnectTimeout,
        );
      } on TimeoutException {
        _logger.w(
          'SportSocketAdapter.disconnect() quá '
          '${_socketDisconnectTimeout.inMilliseconds}ms → bỏ qua, tiếp tục dọn',
        );
      }
      _logger.i('All WebSockets disconnected (V1 + V2 sport socket)');

      _logger.i('Resetting SbConfig session (keep config)...');
      _config.resetForLogout();

      _logger.i('Resetting SbHttpManager (keep public domains)...');
      _http.resetForLogout();

      _logger.i('SbLogin.logout() completed');
    } catch (e, stackTrace) {
      _logger.e('SbLogin.logout() failed', error: e, stackTrace: stackTrace);
      _config.resetForLogout();
      _http.resetForLogout();
    }
  }

  static Future<void> loadBrandConfigOnly() {
    if (SbConfig.sun88BrandConfigUrl.isEmpty) return Future<void>.value();
    if (_config.brandConfig.isNotEmpty) {
      _logger.i('Brand config already loaded, skipping');
      return Future<void>.value();
    }
    final running = _brandConfigInFlight;
    if (running != null) {
      _logger.i('Brand config already in flight, reusing');
      return running;
    }
    final future = _doLoadBrandConfigOnly();
    _brandConfigInFlight = future;
    return future.whenComplete(() {
      if (identical(_brandConfigInFlight, future)) _brandConfigInFlight = null;
    });
  }

  static Future<void>? _brandConfigInFlight;

  static Future<void> _doLoadBrandConfigOnly() async {
    _logger.i('Loading brand config from GitHub...');
    final brandConfig = await SbHttpManager.getConfig(
      SbConfig.sun88BrandConfigUrl
    );
    _config.applyBrandConfig(brandConfig);
    _logger.i('Brand config applied');
  }

  static Future<bool> initConfigOnly() async {
    try {
      _logger.i('SbLogin.initConfigOnly() starting...');

      await loadBrandConfigOnly();

      _logger.i('Initializing auth config...');
      final authConfigReady = await AuthConfigService.instance
          .initializeConfig();
      if (authConfigReady) {
        _logger.i('Auth config initialized successfully');
      } else {
        _logger.w('Auth config initialization failed');
        return false;
      }

      if (SbConfig.mainConfigUrl.isNotEmpty) {
        _logger.i('Loading mainConfig from GitHub...');
        final mainConfig = await SbHttpManager.getConfig(
          SbConfig.mainConfigUrl,
        );
        _config.mainConfig = {..._config.mainConfig, ...mainConfig};

        final patch = _config.domainOverride.toMainConfigPatch();
        if (patch.isNotEmpty) {
          _config.mainConfig = {..._config.mainConfig, ...patch};
          _logger.i('Domain overrides applied: ${patch.keys.toList()}');
        }
      }

      if (SbConfig.sbConfigUrl.isNotEmpty) {
        _logger.i('Loading sbConfig from GitHub...');
        final sbConfig =
            await SbConfigLoader.getConfigJson(SbConfig.sbConfigUrl);

        _applySbConfig(sbConfig);

        final urlSetting = sbConfig['urlSetting'] as String?;
        if (urlSetting != null) {
          _logger.i('Loading server settings from: $urlSetting');
          await _getSettingIgnoringMaintenance(urlSetting);
        }
      }

      _logger.i('SbLogin.initConfigOnly() completed successfully');
      _flushConfigDiagnostics();
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'SbLogin.initConfigOnly() failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static void _applySbConfig(Map<String, dynamic> sbConfig) {
    LeagueAliasStore.instance.onSbConfig(sbConfig);
    _http.urlHs = sbConfig['url_hs'] as String? ?? '';
    final sportDomain = (sbConfig['sport_domain'] as String? ?? '').trim();
    if (sportDomain.isEmpty) {
      _logger.e('sbConfig missing `sport_domain` — SB REST base unavailable');
    }
    _http.sbApiBaseUrl = sportDomain.endsWith('/')
        ? sportDomain.substring(0, sportDomain.length - 1)
        : sportDomain;

    _http.videoDomain = (sbConfig['video_domain'] as String? ?? '').trim();
    _http.virtualVideoDomain =
        (sbConfig['virtual_video_domain'] as String? ?? '').trim();
    if (_http.videoDomain.isEmpty || _http.virtualVideoDomain.isEmpty) {
      _logger.w(
        'sbConfig missing `video_domain`/`virtual_video_domain` — virtual & '
        'replay livestreams will not be wrapped with the player page',
      );
    }
  }

  static Future<void> _getSettingIgnoringMaintenance(String urlSetting) async {
    try {
      await _http.getSetting(urlSetting, SbConfig.agentId);
      _logger.i('Server settings loaded');
    } on HttpException catch (e) {
      if (!MaintenanceService.isUnavailableStatus(e.statusCode)) rethrow;
      _logger.w(
        'SB unavailable (HTTP ${e.statusCode}) → skipping server settings, '
        'app continues without sport book',
      );
    }
  }

  static Future<bool> ensureServerSettings() async {
    try {
      final ready = _http.sbApiBaseUrl.isNotEmpty &&
          (_http.urlHomeWebsocket.isNotEmpty ||
              MaintenanceService.instance.isUnderMaintenance);
      if (ready) return true;
      if (SbConfig.sbConfigUrl.isEmpty) return false;

      _logger.i('ensureServerSettings: SB config chưa đủ → nạp lại sbConfig + getSetting...');
      final sbConfig =
          await SbConfigLoader.getConfigJson(SbConfig.sbConfigUrl);
      _applySbConfig(sbConfig);

      final urlSetting = sbConfig['urlSetting'] as String?;
      if (urlSetting == null) {
        _logger.w('ensureServerSettings: sbConfig thiếu urlSetting');
        return false;
      }
      await _getSettingIgnoringMaintenance(urlSetting);
      final ok = _http.sbApiBaseUrl.isNotEmpty;
      _logger.i('ensureServerSettings: SB API base ${ok ? "OK" : "vẫn rỗng"}');
      return ok;
    } catch (e, stackTrace) {
      _logger.e(
        'ensureServerSettings failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> hasValidTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(SbConfig.refreshTokenKey);
      final accessToken = prefs.getString(SbConfig.userTokenKey);

      final hasTokens =
          refreshToken != null &&
          refreshToken.isNotEmpty &&
          accessToken != null &&
          accessToken.isNotEmpty;

      _logger.i(
        'hasValidTokens: $hasTokens (refreshToken: ${refreshToken != null && refreshToken.isNotEmpty}, accessToken: ${accessToken != null && accessToken.isNotEmpty})',
      );
      return hasTokens;
    } catch (e) {
      _logger.e('Error checking tokens', error: e);
      return false;
    }
  }

  static bool get isInitialized =>
      _config.isConfigLoaded && _http.userTokenSb.isNotEmpty;

  static bool get isConfigReady =>
      _config.isConfigLoaded && _config.isAuthConfigReady;

  static String get displayName => _http.displayName;

  static double get userBalance => _http.userBalance;
}

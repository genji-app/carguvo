import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/network/logged_http.dart';
import 'package:sun_sports/core/network/sb_config_loader.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class AuthConfigService {
  AuthConfigService._();

  static final AuthConfigService _instance = AuthConfigService._();
  static AuthConfigService get instance => _instance;

  final SbConfig _config = SbConfig.instance;

  Future<bool> initializeConfig() => ensureReady();

  Future<bool> ensureReady() async {
    if (isReady) {
      if (_fromCache) _refreshInBackground();
      return true;
    }
    final chain = _chainInFlight ??= _loadMissing().whenComplete(
      () => _chainInFlight = null,
    );
    final cached = await _readCache();
    if (cached == null) return chain;
    return chain.timeout(
      _cacheGrace,
      onTimeout: () {
        if (isReady) return true;
        AppLoggers.auth.w(
          '[AuthConfigService] chain still pending after '
          '${_cacheGrace.inSeconds}s — applying the cached auth config',
        );
        _applyCache(cached);
        return isReady;
      },
    );
  }

  Future<bool> _loadMissing() async {
    try {
      if (_config.hostDomain == null) {
        await _getConfigDomain();
      }
      if (_config.distId == null || _config.appId == null) {
        await _getDistributorId();
      }
      if (_config.idServiceUrl == null) {
        await _getAcsConfig();
      }
      if (_config.isAuthConfigReady) {
        _fromCache = false;
        await _writeCache();
      }
      return _config.isAuthConfigReady;
    } catch (e) {
      AppLoggers.auth.w('[AuthConfigService] ensureReady failed: $e');
      if (_config.isAuthConfigReady) return true;
      final cached = await _readCache();
      if (cached == null) return false;
      AppLoggers.auth.w(
        '[AuthConfigService] serving the cached auth config from the last '
        'successful resolve',
      );
      _applyCache(cached);
      return _config.isAuthConfigReady;
    }
  }

  Future<bool>? _chainInFlight;

  bool _fromCache = false;

  static const Duration _cacheGrace = Duration(seconds: 3);

  static String get _cacheKey => AppEnv.isProdLike
      ? 'auth_config_cache_prod'
      : 'auth_config_cache_staging';

  Future<void> _writeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'hostDomain': _config.hostDomain,
          'distId': _config.distId,
          'appId': _config.appId,
          'idServiceUrl': _config.idServiceUrl,
          'paygateUrl': _config.paygateUrl,
        }),
      );
    } catch (_) {
    }
  }

  Future<Map<String, String>?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final out = <String, String>{};
      for (final key in const [
        'hostDomain',
        'distId',
        'appId',
        'idServiceUrl',
        'paygateUrl',
      ]) {
        final value = map[key];
        if (value is String && value.isNotEmpty) out[key] = value;
      }
      if (!out.containsKey('idServiceUrl') ||
          !out.containsKey('distId') ||
          !out.containsKey('appId') ||
          !out.containsKey('hostDomain')) {
        await prefs.remove(_cacheKey);
        return null;
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  void _applyCache(Map<String, String> cached) {
    _config.hostDomain ??= cached['hostDomain'];
    _config.distId ??= cached['distId'];
    _config.appId ??= cached['appId'];
    _config.idServiceUrl ??= cached['idServiceUrl'];
    _config.paygateUrl ??= cached['paygateUrl'];
    _fromCache = true;
  }

  void _refreshInBackground() {
    if (_chainInFlight != null) return;
    _chainInFlight = _refreshFromNetwork().whenComplete(
      () => _chainInFlight = null,
    );
  }

  Future<bool> _refreshFromNetwork() async {
    try {
      await _getConfigDomain();
      await _getDistributorId();
      await _getAcsConfig();
      if (!_config.isAuthConfigReady) return false;
      _fromCache = false;
      await _writeCache();
      AppLoggers.auth.i(
        '[AuthConfigService] background refresh replaced the cached auth config',
      );
      return true;
    } catch (e) {
      AppLoggers.auth.w('[AuthConfigService] background refresh failed: $e');
      return false;
    }
  }

  Future<void> _getConfigDomain() async {
    final data = await SbConfigLoader.getConfig(SbConfig.authConfigUrl);

    _config.authConfig = data;
    _config.hostDomain = data['host_domain'] as String?;

    final domainOverride = SbConfig.instance.domainOverride;
    if (domainOverride.hasHostDomainOverride) {
      _config.hostDomain = domainOverride.hostDomain;
    }

    debugPrint(
      '[AuthConfigService] Config loaded - hostDomain: ${_config.hostDomain}',
    );
  }

  Future<void> _getDistributorId() async {
    if (_config.hostDomain == null) {
      throw Exception('hostDomain is not set');
    }

    final url = _config.distributorUrl;
    final response = await LoggedHttp.get(Uri.parse(url), action: 'regdis');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] == 0) {
      final responseData = data['data'] as Map<String, dynamic>;
      _config.distId = responseData['distId'] as String?;
      _config.appId = responseData['applicationId'] as String?;

      debugPrint(
        '[AuthConfigService] Distributor loaded - distId: ${_config.distId}',
      );
    } else {
      throw Exception(
        'Failed to get distributor: status=${data['status']} '
        'message=${data['message']}',
      );
    }
  }

  Future<void> _getAcsConfig() async {
    if (_config.hostDomain == null ||
        _config.distId == null ||
        _config.appId == null) {
      throw Exception('Required config not set for ACS');
    }

    final url = _config.acsConfigUrl;
    final response = await LoggedHttp.get(Uri.parse(url), action: 'get-bid');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] == 0) {
      final dataMap = data['data'] as Map<String, dynamic>?;
      final responseData = dataMap?['config'] as Map<String, dynamic>?;
      final services = responseData?['services'] as Map<String, dynamic>?;

      if (services != null) {
        _config.idServiceUrl = services['id'] as String?;
        _config.paygateUrl = services['paygate'] as String?;

        debugPrint(
          '[AuthConfigService] ACS loaded - idServiceUrl: ${_config.idServiceUrl}',
        );
      }
    } else {
      throw Exception(
        'Failed to get ACS config: status=${data['status']} '
        'message=${data['message']}',
      );
    }
  }

  Future<String> getServerTime() async {
    if (_config.idServiceUrl == null) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    try {
      final url = _config.serverTimeUrl;
      final response = await LoggedHttp.get(Uri.parse(url), action: 'getTime');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 0) {
        final responseData = data['data'] as Map<String, dynamic>;
        return responseData['message'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (e) {
      debugPrint('[AuthConfigService] Error getting server time: $e');
    }

    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool get isReady => _config.isAuthConfigReady;

  String? get idServiceUrl => _config.idServiceUrl;
}

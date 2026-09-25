import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sun_sports/core/network/logged_http.dart';
import 'package:sun_sports/core/services/auth/auth_config_service.dart';
import 'package:sun_sports/core/services/auth/device_info_service.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/core/utils/hash_utils.dart';
import 'package:sun_sports/features/auth/data/models/auth_model.dart';
import 'package:sun_sports/features/auth/domain/entities/username_check_result.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> submitOtp(OtpRequestModel request);
  Future<UsernameCheckResult> checkUsernameAvailable(String username);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthConfigService _configService = AuthConfigService.instance;
  final DeviceInfoService _deviceService = DeviceInfoService.instance;
  final SbConfig _config = SbConfig.instance;

  AuthRemoteDataSourceImpl();

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    if (!await _configService.ensureReady()) {
      throw Exception('Auth config not initialized');
    }

    final deviceId = kIsWeb ? '' : await _deviceService.getDeviceId();
    final osVersion = await _deviceService.getOsVersion();
    final platformId = SbConfig.platformId;

    final usernameLC = request.username.toLowerCase();
    const displayName = '';

    final hash = HashUtils.createAuthHashSS(
      username: usernameLC,
      password: request.password,
      displayName: displayName,
      platformId: platformId,
      advId: '',
      deviceId: deviceId,
      osVersion: osVersion,
      bundleId: SbConfig.bundleId,
      brand: SbConfig.authBrand,
      secretKey: SbConfig.secretKey,
    );

    final body = <String, dynamic>{
      'command': 'loginHashSS',
      'username': usernameLC,
      'password': request.password,
      'displayName': displayName,
      'platformId': platformId,
      'advId': '',
      'deviceId': deviceId,
      'os': osVersion,
      'alsoLogin': true,
      'hash': hash,
      'bundle': SbConfig.bundleId,
      'brand': SbConfig.authBrand,
    };

    final response = await LoggedHttp.post(
      Uri.parse(_config.idServiceUrl!),
      action: 'loginHashSS',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    if (!await _configService.ensureReady()) {
      throw Exception('Auth config not initialized');
    }

    final deviceId = kIsWeb ? '' : await _deviceService.getDeviceId();
    final osVersion = await _deviceService.getOsVersion();
    final platformId = SbConfig.platformId;

    final usernameLC = request.username.toLowerCase();
    final displayNameLC = request.displayName.toLowerCase();

    final hash = HashUtils.createAuthHashSS(
      username: usernameLC,
      password: request.password,
      displayName: displayNameLC,
      platformId: platformId,
      advId: '',
      deviceId: deviceId,
      osVersion: osVersion,
      bundleId: SbConfig.bundleId,
      brand: SbConfig.authBrand,
      secretKey: SbConfig.secretKey,
    );

    final body = <String, dynamic>{
      'command': 'registerHashSS',
      'username': usernameLC,
      'password': request.password,
      'displayName': displayNameLC,
      'platformId': platformId,
      'advId': '',
      'deviceId': deviceId,
      'os': osVersion,
      'alsoLogin': true,
      'hash': hash,
      'bundle': SbConfig.bundleId,
      'brand': SbConfig.authBrand,
    };

    final requestAffId = request.affId?.trim();
    final affId = requestAffId != null && requestAffId.isNotEmpty
        ? requestAffId
        : await _deviceService.getPackageName();
    if (affId.isNotEmpty) body['affId'] = affId;

    void putIfSet(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) body[key] = trimmed;
    }

    putIfSet('utmSource', request.utmSource);
    putIfSet('utmMedium', request.utmMedium);
    putIfSet('utmCampaign', request.utmCampaign);
    putIfSet('utmContent', request.utmContent);
    putIfSet('utmTerm', request.utmTerm);

    final response = await LoggedHttp.post(
      Uri.parse(_config.idServiceUrl!),
      action: 'registerHashSS',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<AuthResponseModel> submitOtp(OtpRequestModel request) async {
    if (!await _configService.ensureReady()) {
      throw Exception('Auth config not initialized');
    }

    final hash = HashUtils.createOtpHash(
      sessionId: request.sessionId,
      otp: request.otp,
      hsk: SbConfig.hsk,
    );

    final body = {
      'command': 'submitOTP',
      'sessionId': request.sessionId,
      'otp': request.otp,
      'hash': hash,
    };

    final response = await LoggedHttp.post(
      Uri.parse(_config.idServiceUrl!),
      action: 'submitOTP',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<UsernameCheckResult> checkUsernameAvailable(String username) async {
    if (!await _configService.ensureReady()) {
      throw Exception('Auth config not initialized');
    }

    final usernameLC = username.toLowerCase();
    final hash = HashUtils.createCheckUsernameHash(
      username: usernameLC,
      brand: SbConfig.authBrand,
      secretKey: SbConfig.secretKey,
    );

    final body = {
      'command': 'checkUserByUsernameOnWeb',
      'username': usernameLC,
      'brand': SbConfig.authBrand,
      'hash': hash,
    };

    final response = await LoggedHttp.post(
      Uri.parse(_config.idServiceUrl!),
      action: 'checkUserByUsernameOnWeb',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final status = (data['status'] as num?)?.toInt();
    final result = usernameCheckResultForStatus(status);
    if (result == null) {
      throw Exception('checkUserByUsernameOnWeb status=$status');
    }
    return result;
  }

  static UsernameCheckResult? usernameCheckResultForStatus(int? status) {
    switch (status) {
      case 0:
        return UsernameCheckResult.available;
      case 202:
        return UsernameCheckResult.taken;
      case 309:
        return UsernameCheckResult.existsOnOtherBrand;
      default:
        return null;
    }
  }

  @override
  Future<void> logout() async {
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    if (!await _configService.ensureReady()) {
      throw Exception('Auth config not initialized');
    }

    final url =
        '${_config.idServiceUrl}?command=refreshToken&refreshToken=$refreshToken';

    final response = await LoggedHttp.get(
      Uri.parse(url),
      action: 'refreshToken',
    );

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }
}

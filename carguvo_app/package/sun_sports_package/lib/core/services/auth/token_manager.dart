import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

class TokenManager {
  TokenManager._();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String wsToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(SbConfig.userTokenKey, accessToken);
    await prefs.setString(SbConfig.refreshTokenKey, refreshToken);
    await prefs.setString(SbConfig.wsTokenKey, wsToken);

    SbConfig.instance.wsToken = wsToken;
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.userTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.refreshTokenKey);
  }

  static Future<String?> getWsToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.wsTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SbConfig.userTokenKey);
    await prefs.remove(SbConfig.refreshTokenKey);
    await prefs.remove(SbConfig.wsTokenKey);

    SbConfig.instance.wsToken = '';
  }

  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}

class UserManager {
  UserManager._();

  static Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanUsername = username
        .replaceAll('SC_', '')
        .replaceAll('NV_', '')
        .replaceAll('Z8_', '')
        .replaceAll('sc_', '')
        .replaceAll('nv_', '')
        .replaceAll('z8_', '');

    await prefs.setString(
      SbConfig.usernameKey,
      base64.encode(utf8.encode(cleanUsername)),
    );
    await prefs.setString(
      SbConfig.passwordKey,
      base64.encode(utf8.encode(password)),
    );
  }

  static Future<(String?, String?)> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedUsername = prefs.getString(SbConfig.usernameKey);
    final encodedPassword = prefs.getString(SbConfig.passwordKey);

    if (encodedUsername == null || encodedPassword == null) {
      return (null, null);
    }

    try {
      final username = utf8.decode(base64.decode(encodedUsername));
      final password = utf8.decode(base64.decode(encodedPassword));
      return (username, password);
    } catch (e) {
      return (null, null);
    }
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SbConfig.usernameKey);
    await prefs.remove(SbConfig.passwordKey);
  }

  static Future<bool> hasSavedCredentials() async {
    final (username, password) = await getSavedCredentials();
    return username != null && password != null;
  }
}

import 'package:auth_domain/auth_domain.dart' show JwtClaims;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_package/core/services/config/sb_config.dart';

abstract final class DisplayNameStatus {
  static const String _settledKey = 'display_name_settled';

  static bool _settled = false;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _settled = prefs.getBool(_settledKey) ?? false;
  }

  static Future<void> markSettled() async {
    _settled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_settledKey, true);
  }

  static Future<void> clear() async {
    _settled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settledKey);
  }

  static bool get hasDisplayNameClaim {
    final token = SbConfig.instance.wsToken;
    if (token.isEmpty) return false;
    final claim = JwtClaims.decode(token)?['displayName']?.toString();
    return claim != null && claim.trim().isNotEmpty;
  }

  static bool needsDisplayName({required bool isLoggedIn}) {
    if (!isLoggedIn) return false;
    if (_settled) return false;
    if (SbConfig.instance.wsToken.isEmpty) return false;
    return !hasDisplayNameClaim;
  }
}

import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  AppVersion._();

  static const String _fallback = '1.0.1';

  static String _code = _fallback;

  static String get code => _code;

  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      if (version.isNotEmpty) _code = version;
    } catch (_) {
    }
  }
}

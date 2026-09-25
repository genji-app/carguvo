library;

export 'src/app_device.dart';
export 'src/app_http.dart';
export 'src/app_session.dart';
export 'src/app_storage.dart';
export 'src/store_rules.dart';
export 'src/maintenance_rules.dart';
export 'src/sound_registry.dart';

enum AppEnvironment { staging, preRelease, prod }

class AppEnv {
  AppEnv._();

  static const String _raw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static const String _rawSub = String.fromEnvironment(
    'APP_ENV_SUB',
    defaultValue: '',
  );

  static String get appEnvSub {
    final v = _rawSub.trim().toLowerCase();
    if (v.startsWith('dev')) {
      final n = int.tryParse(v.substring(3));
      if (n != null && n >= 1 && n <= 10) return 'dev$n';
    }
    return '';
  }

  static final AppEnvironment current = _raw == 'prod'
      ? AppEnvironment.prod
      : (_raw == 'pre-release' || _raw == 'pre')
          ? AppEnvironment.preRelease
          : AppEnvironment.staging;

  static bool get isProd => current == AppEnvironment.prod;
  static bool get isPreRelease => current == AppEnvironment.preRelease;
  static bool get isStaging => current == AppEnvironment.staging;

  static const bool isStagingBuild =
      _raw != 'prod' && _raw != 'pre-release' && _raw != 'pre';

  static bool get isProdLike => isProd || isPreRelease;

  static String get label => isProd
      ? 'Production'
      : isPreRelease
          ? 'Pre-release'
          : 'Staging';

  static String get brandConfigUrl => isProdLike
      ? 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88.json'
      : 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88_staging.json';

  static String get brandConfigFallbackUrl => isProdLike
      ? 'https://cdn.jsdelivr.net/gh/Vulcan-dev-25/configs@main/s88.json'
      : 'https://cdn.jsdelivr.net/gh/Vulcan-dev-25/configs@main/s88_staging.json';

  static const String sbConfigUrl =
      'https://cdn.jsdelivr.net/gh/Vulcan-dev-25/configs@main/sb_config.json';

  static const String sbConfigFallbackUrl =
      'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/sb_config.json';

  static String get rsBaseUrl {
    if (isProdLike) return 'https://rs.static607zgn.com';
    return withPathSegment('https://common-s88.sandboxg1.win', appEnvSub);
  }

  static String get resourcePathSegment => isPreRelease
      ? 'pre'
      : isStaging
          ? appEnvSub
          : '';

  static String withPathSegment(String baseUrl, String segment) {
    final seg = segment.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    if (seg.isEmpty || baseUrl.isEmpty) return baseUrl;
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (base.isEmpty) return baseUrl;
    if (base.endsWith('/$seg')) return base;
    return '$base/$seg';
  }

  static String get gameResourceUrl => rsBaseUrl;

  static String get loadingGifUrl => '$rsBaseUrl/assets/gif/loading.gif';

  static String get downloadAppUrl =>
      isProdLike ? 'https://sun88.win' : 'https://ldp-s88.sandboxg1.win';

  static String injectPreReleasePath(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final path = uri.path;
    final trimmed = path.replaceAll(RegExp(r'/+$'), '');
    var newPath = '/pre$trimmed';
    if (path.endsWith('/') || trimmed.isEmpty) newPath = '$newPath/';
    return uri.replace(path: newPath).toString();
  }
}

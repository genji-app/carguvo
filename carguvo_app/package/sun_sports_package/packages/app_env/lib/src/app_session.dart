import 'app_storage.dart';

class AppSession {
  AppSession._();

  static const String languageKey = 'app.language';

  static const String defaultLanguage = 'vi';

  static String Function()? _accessToken;
  static bool Function()? _isLoggedIn;
  static int Function()? _gold;

  static String? _languageCache;

  static bool get isConfigured => _accessToken != null;

  static void configure({
    required String Function() accessToken,
    bool Function()? isLoggedIn,
    int Function()? gold,
  }) {
    _accessToken = accessToken;
    _isLoggedIn = isLoggedIn;
    _gold = gold;
  }

  static void bindGold(int Function() gold) => _gold = gold;

  static void resetForTesting() {
    _accessToken = null;
    _isLoggedIn = null;
    _gold = null;
    _languageCache = null;
  }

  static String get accessToken {
    final fn = _accessToken;
    if (fn == null) return '';
    try {
      return fn();
    } catch (_) {
      return '';
    }
  }

  static bool get isLoggedIn {
    final fn = _isLoggedIn;
    if (fn == null) return accessToken.isNotEmpty;
    try {
      return fn();
    } catch (_) {
      return false;
    }
  }

  static int get gold {
    final fn = _gold;
    if (fn == null) return 0;
    try {
      return fn();
    } catch (_) {
      return 0;
    }
  }

  static String get language {
    final cached = _languageCache;
    if (cached != null) return cached;
    final stored = AppStorage.get(languageKey)?.trim();
    final value = (stored == null || stored.isEmpty) ? defaultLanguage : stored;
    _languageCache = value;
    return value;
  }

  static void setLanguage(String code) {
    final value = code.trim().isEmpty ? defaultLanguage : code.trim();
    _languageCache = value;
    AppStorage.set(languageKey, value);
  }
}

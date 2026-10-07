import 'package:shared_preferences/shared_preferences.dart';

class SearchOnboardingStorage {
  static const String _pendingKey = 'sbSearchOnboardingPending';

  static const bool _defaultPending = false;

  static SearchOnboardingStorage? _instance;
  static SearchOnboardingStorage get instance =>
      _instance ??= SearchOnboardingStorage._();
  SearchOnboardingStorage._();

  SharedPreferences? _prefs;

  bool _pending = _defaultPending;

  bool get isPending => _pending;

  bool _initialized = false;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await _preferences;
      _pending = prefs.getBool(_pendingKey) ?? _defaultPending;
    } catch (_) {
      _pending = _defaultPending;
    }
  }

  Future<void> setPending(bool value) async {
    if (_pending == value) return;
    _pending = value;
    try {
      final prefs = await _preferences;
      await prefs.setBool(_pendingKey, value);
    } catch (_) {
    }
  }
}

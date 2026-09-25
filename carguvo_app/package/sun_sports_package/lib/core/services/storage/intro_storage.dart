import 'package:shared_preferences/shared_preferences.dart';

class IntroStorage {
  static const String _lastShownDateKey = 'sbIntroLastShownDate';

  static IntroStorage? _instance;
  static IntroStorage get instance => _instance ??= IntroStorage._();
  IntroStorage._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> shouldShowIntroToday() async {
    final prefs = await _preferences;
    final stored = prefs.getString(_lastShownDateKey);
    if (stored == null) return true;
    return stored != _todayKey();
  }

  Future<void> markShownToday() async {
    final prefs = await _preferences;
    await prefs.setString(_lastShownDateKey, _todayKey());
  }

  Future<void> reset() async {
    final prefs = await _preferences;
    await prefs.remove(_lastShownDateKey);
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}

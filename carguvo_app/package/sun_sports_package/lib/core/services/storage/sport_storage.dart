import 'package:shared_preferences/shared_preferences.dart';

class SportStorage {
  static const String _sportIdKey = 'sbSportID';
  static const String _oddsStyleKey = 'sbOddsStyle';
  static const String _lastLeagueIdKey = 'sbLastLeagueId';

  static const int defaultSportId = 1;
  static const String defaultOddsStyle = 'MY';

  static SportStorage? _instance;
  static SportStorage get instance => _instance ??= SportStorage._();
  SportStorage._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveSportId(int sportId) async {
    final prefs = await _preferences;
    await prefs.setInt(_sportIdKey, sportId);
  }

  Future<int> getSportId() async {
    final prefs = await _preferences;
    return prefs.getInt(_sportIdKey) ?? defaultSportId;
  }

  int getSportIdSync() {
    return _prefs?.getInt(_sportIdKey) ?? defaultSportId;
  }

  Future<void> saveOddsStyle(String style) async {
    final prefs = await _preferences;
    await prefs.setString(_oddsStyleKey, style);
  }

  Future<String> getOddsStyle() async {
    final prefs = await _preferences;
    return prefs.getString(_oddsStyleKey) ?? defaultOddsStyle;
  }

  String getOddsStyleSync() {
    return _prefs?.getString(_oddsStyleKey) ?? defaultOddsStyle;
  }

  Future<void> saveLastLeagueId(int leagueId) async {
    final prefs = await _preferences;
    await prefs.setInt(_lastLeagueIdKey, leagueId);
  }

  Future<int?> getLastLeagueId() async {
    final prefs = await _preferences;
    return prefs.getInt(_lastLeagueIdKey);
  }

  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_sportIdKey);
    await prefs.remove(_oddsStyleKey);
    await prefs.remove(_lastLeagueIdKey);
  }

  @override
  String toString() {
    return 'SportStorage(sportId: ${getSportIdSync()}, oddsStyle: ${getOddsStyleSync()})';
  }
}

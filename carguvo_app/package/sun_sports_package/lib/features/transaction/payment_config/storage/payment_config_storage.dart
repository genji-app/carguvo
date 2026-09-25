import 'package:shared_preferences/shared_preferences.dart';

class PaymentConfigStorage {
  static const String _configKey = 'paymentConfig';
  static const String _timestampKey = 'paymentConfigTimestamp';

  static const Duration cacheExpiry = Duration(hours: 1);

  static PaymentConfigStorage? _instance;
  static PaymentConfigStorage get instance =>
      _instance ??= PaymentConfigStorage._();
  PaymentConfigStorage._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> save(String jsonString) async {
    final prefs = await _preferences;
    await prefs.setString(_configKey, jsonString);
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> get() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_configKey);
    if (jsonString == null) return null;

    if (!await isValid()) {
      await clear();
      return null;
    }

    return jsonString;
  }

  Future<bool> isValid() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    return now.difference(cachedTime) <= cacheExpiry;
  }

  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_configKey);
    await prefs.remove(_timestampKey);
  }
}

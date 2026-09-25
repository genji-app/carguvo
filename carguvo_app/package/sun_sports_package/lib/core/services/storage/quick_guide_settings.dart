import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickGuideSettings {
  static const String _enabledKey = 'sbQuickGuideEnabled';

  static const bool _defaultEnabled = false;

  static QuickGuideSettings? _instance;
  static QuickGuideSettings get instance =>
      _instance ??= QuickGuideSettings._();
  QuickGuideSettings._();

  SharedPreferences? _prefs;

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(_defaultEnabled);

  bool get isEnabled => enabled.value;

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
      enabled.value = prefs.getBool(_enabledKey) ?? _defaultEnabled;
    } catch (_) {
      enabled.value = _defaultEnabled;
    }
  }

  Future<void> setEnabled(bool value) async {
    if (enabled.value == value) return;
    enabled.value = value;
    try {
      final prefs = await _preferences;
      await prefs.setBool(_enabledKey, value);
    } catch (_) {
    }
  }

  Future<void> toggle() => setEnabled(!enabled.value);
}

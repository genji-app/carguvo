import 'package:app_env/app_env.dart'
    show kSoundEnabledDefault, kSoundEnabledRawKey;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  static const String _enabledKey = kSoundEnabledRawKey;

  static const bool _defaultEnabled = kSoundEnabledDefault;

  static SoundSettings? _instance;
  static SoundSettings get instance => _instance ??= SoundSettings._();
  SoundSettings._();

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

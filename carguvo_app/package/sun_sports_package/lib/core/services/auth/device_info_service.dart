import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

import 'device_info_service_stub.dart'
    if (dart.library.io) 'device_info_service_io.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoService _instance = DeviceInfoService._();
  static DeviceInfoService get instance => _instance;

  String? _deviceId;
  String? _osVersion;
  String? _packageName;

  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(SbConfig.deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4().replaceAll('-', '').substring(0, 20);
      await prefs.setString(SbConfig.deviceIdKey, deviceId);
    }

    _deviceId = deviceId;
    return deviceId;
  }

  Future<String> getOsVersion() async {
    if (_osVersion != null) return _osVersion!;

    if (kIsWeb) {
      _osVersion = 'Web';
      return _osVersion!;
    }

    _osVersion = await getDeviceOsVersion();
    return _osVersion!;
  }

  Future<String> getPackageName() async {
    if (_packageName != null) return _packageName!;
    if (kIsWeb) return _packageName = '';

    try {
      final info = await PackageInfo.fromPlatform();
      _packageName = info.packageName.trim();
    } catch (_) {
      _packageName = '';
    }
    return _packageName!;
  }

  void reset() {
    _deviceId = null;
    _osVersion = null;
    _packageName = null;
  }
}

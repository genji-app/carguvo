import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

Future<String> getDeviceOsVersion() async {
  final deviceInfo = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return 'Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return 'iOS ${info.systemVersion}';
    }
  } catch (e) {
    Logger().e('[DeviceInfoService] Error getting OS version: $e');
  }

  return 'Unknown';
}

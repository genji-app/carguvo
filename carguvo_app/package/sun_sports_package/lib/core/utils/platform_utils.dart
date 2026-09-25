library;

import 'package:app_env/app_env.dart';

class PlatformUtils {
  static bool get isWeb => AppDevice.isBrowser;

  static bool get isMobile =>
      !AppDevice.isBrowser && AppDevice.platform.isNativeMobile;

  static bool get isDesktop => AppDevice.isNativeDesktop;

  static bool get isAndroid => AppDevice.platform == HostPlatform.android;
  static bool get isIOS => AppDevice.platform == HostPlatform.ios;
  static bool get isWindows => AppDevice.platform == HostPlatform.windows;
  static bool get isMacOS => AppDevice.platform == HostPlatform.macos;
  static bool get isLinux => AppDevice.platform == HostPlatform.linux;
}

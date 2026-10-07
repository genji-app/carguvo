import 'package:flutter/services.dart';

import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

class PlatformUiControllerNative implements PlatformUiController {
  PlatformUiControllerNative();

  PlatformUiConfig? _currentConfig;

  @override
  PlatformUiConfig? get currentConfig => _currentConfig;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    try {
      if (config.systemUiMode != null) {
        final mode = _mapMode(config.systemUiMode!);
        if (mode == SystemUiMode.manual) {
          await SystemChrome.setEnabledSystemUIMode(mode, overlays: []);
        } else if (mode == SystemUiMode.edgeToEdge) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        } else {
          await SystemChrome.setEnabledSystemUIMode(mode);
        }
      }

      if (config.hasOverlayStyle) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: config.statusBarColor,
            statusBarIconBrightness: config.statusBarIconBrightness,
            statusBarBrightness: config.statusBarBrightness,
            systemNavigationBarColor: config.navigationBarColor,
            systemNavigationBarIconBrightness: config.navigationBarIconBrightness,
          ),
        );
      }

      _currentConfig = config;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> restore() async {
    await apply(const PlatformUiConfig.systemDefault());
    _currentConfig = null;
  }

  @override
  void dispose() {}

  SystemUiMode _mapMode(PlatformSystemUiMode mode) => switch (mode) {
        PlatformSystemUiMode.edgeToEdge => SystemUiMode.edgeToEdge,
        PlatformSystemUiMode.immersive => SystemUiMode.immersive,
        PlatformSystemUiMode.immersiveSticky => SystemUiMode.immersiveSticky,
        PlatformSystemUiMode.manual => SystemUiMode.manual,
      };
}

PlatformUiController createPlatformUiController() => PlatformUiControllerNative();

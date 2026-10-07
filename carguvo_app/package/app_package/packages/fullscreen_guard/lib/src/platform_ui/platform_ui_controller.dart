import 'platform_ui_config.dart';

abstract class PlatformUiController {
  PlatformUiConfig? get currentConfig;

  Future<void> apply(PlatformUiConfig config);

  Future<void> restore();

  void dispose();
}

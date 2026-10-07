import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

class PlatformUiControllerWeb implements PlatformUiController {
  PlatformUiControllerWeb();

  PlatformUiConfig? _currentConfig;

  @override
  PlatformUiConfig? get currentConfig => _currentConfig;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    _currentConfig = config;
  }

  @override
  Future<void> restore() async {
    _currentConfig = null;
  }

  @override
  void dispose() {}
}

PlatformUiController createPlatformUiController() => PlatformUiControllerWeb();

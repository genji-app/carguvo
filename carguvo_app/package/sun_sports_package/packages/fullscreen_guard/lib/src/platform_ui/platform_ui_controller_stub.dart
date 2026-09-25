import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

class PlatformUiControllerStub implements PlatformUiController {
  PlatformUiControllerStub();

  @override
  PlatformUiConfig? get currentConfig => null;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    throw UnsupportedError(
      'fullscreen_guard is not supported on this platform',
    );
  }

  @override
  Future<void> restore() async {
    throw UnsupportedError(
      'fullscreen_guard is not supported on this platform',
    );
  }

  @override
  void dispose() {}
}

PlatformUiController createPlatformUiController() => PlatformUiControllerStub();

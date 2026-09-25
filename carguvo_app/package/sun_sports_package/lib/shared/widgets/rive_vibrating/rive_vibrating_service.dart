import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class RiveVibratingService {
  rive.File? _riveFile;
  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    try {
      _riveFile = await RiveHelper.getFile(AppRive.animCardNho);
      _isInitialized = _riveFile != null;
    } catch (e) {
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  rive.RiveWidgetController? createController() {
    if (!_isInitialized || _riveFile == null) return null;
    return rive.RiveWidgetController(_riveFile!);
  }

  void dispose() {
    _riveFile = null;
    _isInitialized = false;
  }
}

final riveVibratingServiceProvider = Provider<RiveVibratingService>((ref) {
  final service = RiveVibratingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final riveVibratingInitializedProvider = StateProvider<bool>((ref) => false);

final riveVibratingInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(riveVibratingServiceProvider);
  await service.initialize();
  ref.read(riveVibratingInitializedProvider.notifier).state = true;
});

import 'package:flutter/foundation.dart';

import '../platform_ui/platform_ui.dart';
import 'strategies/strategies.dart';

@immutable
class FullscreenGateRequest {
  const FullscreenGateRequest({
    required this.tag,
    this.isRequired = true,
    this.requiresGestureOnIosSafari = false,
  });

  final String tag;

  final bool isRequired;

  final bool requiresGestureOnIosSafari;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullscreenGateRequest &&
          runtimeType == other.runtimeType &&
          tag == other.tag &&
          isRequired == other.isRequired &&
          requiresGestureOnIosSafari == other.requiresGestureOnIosSafari;

  @override
  int get hashCode => tag.hashCode ^ isRequired.hashCode ^ requiresGestureOnIosSafari.hashCode;

  @override
  String toString() => 'FullscreenGateRequest(tag: $tag, '
      'isRequired: $isRequired, '
      'requiresGestureOnIosSafari: $requiresGestureOnIosSafari)';
}

class FullscreenGuardController extends ChangeNotifier {
  FullscreenGuardController({
    PlatformUiController? platformUiController,
    FullscreenStrategy? strategy,
  })  : _platformUiController = platformUiController ?? createPlatformUiController(),
        _ownsController = platformUiController == null {
    _strategy = strategy ?? createFullscreenStrategy(_platformUiController);
    _strategy.isFullscreen.addListener(_onFullscreenStateChanged);
  }

  final PlatformUiController _platformUiController;
  final bool _ownsController;
  late final FullscreenStrategy _strategy;

  FullscreenGateRequest? _activeRequest;
  bool _isSatisfied = false;

  FullscreenGateRequest? get activeRequest => _activeRequest;

  bool get isSatisfied => _isSatisfied;

  bool get shouldShowGate => _activeRequest != null && !_isSatisfied;

  bool get isBlocking => shouldShowGate && (_activeRequest?.isRequired ?? false);

  PlatformUiController get platformUiController => _platformUiController;

  FullscreenStrategy get strategy => _strategy;

  ValueListenable<bool> get isFullscreen => _strategy.isFullscreen;

  Future<void> request(FullscreenGateRequest req) async {
    _activeRequest = req;
    _isSatisfied = false;

    if (!_strategy.needsUserGesture) {
      await _strategy.enter();
      _isSatisfied = true;
    }

    notifyListeners();
  }

  Future<void> satisfy() async {
    final success = await _strategy.enter();
    if (success) {
      _isSatisfied = true;
      notifyListeners();
    }
  }

  Future<void> clear({bool restoreSystemUi = true}) async {
    _activeRequest = null;
    _isSatisfied = false;

    _strategy.teardownGate();

    if (restoreSystemUi) {
      await _strategy.exit();
      await _platformUiController.restore();
    }

    notifyListeners();
  }

  void _onFullscreenStateChanged() {
    if (!_strategy.isFullscreen.value &&
        _activeRequest != null &&
        _activeRequest!.isRequired &&
        _isSatisfied) {
      _isSatisfied = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _strategy.isFullscreen.removeListener(_onFullscreenStateChanged);
    _strategy.dispose();
    if (_ownsController) {
      _platformUiController.dispose();
    }
    super.dispose();
  }
}

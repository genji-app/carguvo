import 'package:flutter/material.dart';

import '../platform_ui/platform_ui.dart';
import 'fullscreen_guard_controller.dart';
import 'fullscreen_gate_view.dart';
import 'strategies/strategies.dart';

export 'fullscreen_guard_controller.dart';
export 'fullscreen_gate_view.dart';

typedef FullscreenGateBuilder = Widget Function(
  BuildContext context,
  VoidCallback onProceed,
  VoidCallback onCancel,
);

class FullscreenGuard extends StatefulWidget {
  const FullscreenGuard({
    required this.child,
    this.gateBuilder,
    this.platformUiController,
    this.strategy,
    super.key,
  });

  final Widget child;

  final FullscreenGateBuilder? gateBuilder;

  final PlatformUiController? platformUiController;

  final FullscreenStrategy? strategy;

  static FullscreenGuardController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<_FullscreenGuardScope>();
    if (widget == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'FullscreenGuard.of() called with a context that does not '
          'contain a FullscreenGuard widget.',
        ),
      ]);
    }
    return widget.controller;
  }

  static PlatformUiController controllerOf(BuildContext context) =>
      FullscreenGuard.of(context).platformUiController;

  @override
  State<FullscreenGuard> createState() => _FullscreenGuardState();
}

class _FullscreenGuardState extends State<FullscreenGuard> {
  late final FullscreenGuardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FullscreenGuardController(
      platformUiController: widget.platformUiController,
      strategy: widget.strategy,
    )..addListener(_onControllerChanged);

    _controller.strategy.isFullscreen.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.strategy.isFullscreen.removeListener(_onControllerChanged);
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FullscreenGuardScope(
      controller: _controller,
      isSatisfied: _controller.isSatisfied,
      isFullscreen: _controller.strategy.isFullscreen.value,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            widget.child,
            if (_controller.shouldShowGate)
              Positioned.fill(
                child: (widget.gateBuilder ?? _defaultGateBuilder).call(
                  context,
                  _onProceed,
                  _onCancel,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _defaultGateBuilder(
    BuildContext context,
    VoidCallback onProceed,
    VoidCallback onCancel,
  ) =>
      FullscreenGateView(
        onProceed: onProceed,
        onCancel: onCancel,
      );

  Future<void> _onProceed() async {
    await _controller.satisfy();
  }

  void _onCancel() {
    _controller.clear();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _FullscreenGuardScope extends InheritedWidget {
  const _FullscreenGuardScope({
    required this.controller,
    required this.isSatisfied,
    required this.isFullscreen,
    required super.child,
  });

  final FullscreenGuardController controller;
  final bool isSatisfied;
  final bool isFullscreen;

  @override
  bool updateShouldNotify(_FullscreenGuardScope oldWidget) =>
      controller != oldWidget.controller ||
      isSatisfied != oldWidget.isSatisfied ||
      isFullscreen != oldWidget.isFullscreen;
}

import 'package:flutter/widgets.dart';

import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';
import 'platform_ui_controller_factory.dart';

class PlatformUiGuard extends StatefulWidget {
  const PlatformUiGuard({
    required this.child,
    this.initialConfig,
    this.controller,
    super.key,
  });

  final Widget child;

  final PlatformUiConfig? initialConfig;

  final PlatformUiController? controller;

  static PlatformUiController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PlatformUiScope>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'PlatformUiGuard.of() called with a context that does not '
          'contain a PlatformUiGuard widget.',
        ),
      ]);
    }
    return scope.controller;
  }

  @override
  State<PlatformUiGuard> createState() => _PlatformUiGuardState();
}

class _PlatformUiGuardState extends State<PlatformUiGuard> with WidgetsBindingObserver {
  late final PlatformUiController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? createPlatformUiController();

    _applyInitialConfig();
  }

  @override
  void didUpdateWidget(PlatformUiGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialConfig != null && widget.initialConfig != oldWidget.initialConfig) {
      _applyInitialConfig();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyInitialConfig();
    }
  }

  void _applyInitialConfig() {
    if (widget.initialConfig != null) {
      _controller.apply(widget.initialConfig!).ignore();
    }
  }

  void restoreBaseConfig() => _applyInitialConfig();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PlatformUiScope(
      controller: _controller,
      guardState: this,
      child: widget.child,
    );
  }
}

class _PlatformUiScope extends InheritedWidget {
  const _PlatformUiScope({
    required this.controller,
    required this.guardState,
    required super.child,
  });

  final PlatformUiController controller;
  final _PlatformUiGuardState guardState;

  @override
  bool updateShouldNotify(_PlatformUiScope oldWidget) =>
      controller != oldWidget.controller || guardState != oldWidget.guardState;
}

import 'package:flutter/widgets.dart';

import '../controllers/controller_dispatcher.dart';
import '../controllers/orientation_controller.dart';
import '../controllers/platform_orientation_controller.dart';
import '../models/orientation_guard_config.dart';
import '../models/orientation_policy.dart';
import 'orientation_guard.dart';

class OrientationScope extends StatefulWidget {
  const OrientationScope({
    super.key,
    this.controller,
    this.currentPolicy,
    this.config = const OrientationGuardConfig(),
    required this.child,
  });

  static Widget root({
    Key? key,
    OrientationController? controller,
    OrientationPolicy defaultPolicy = OrientationPolicy.portrait,
    OrientationGuardConfig config = const OrientationGuardConfig(),
    WidgetBuilder? mismatchBuilder,
    bool blockOnMismatch = false,
    required Widget child,
  }) {
    return OrientationScope(
      key: key,
      controller: controller,
      currentPolicy: defaultPolicy,
      config: config,
      child: OrientationGuard(
        policy: defaultPolicy,
        mismatchBuilder: mismatchBuilder,
        blockOnMismatch: blockOnMismatch,
        child: child,
      ),
    );
  }

  final OrientationController? controller;

  final OrientationPolicy? currentPolicy;

  final OrientationGuardConfig config;

  final Widget child;

  static OrientationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>();
    if (scope == null) {
      throw FlutterError(
          'OrientationScope.of() called with a context that does not contain an OrientationScope.');
    }
    return scope.controller;
  }

  static OrientationController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>()?.controller;
  }

  static OrientationPolicy? maybePolicyOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>()?.currentPolicy;
  }

  static OrientationGuardConfig configOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>();
    return scope?.config ?? const OrientationGuardConfig();
  }

  @override
  State<OrientationScope> createState() => _OrientationScopeState();
}

class _OrientationScopeState extends State<OrientationScope> {
  OrientationController? _internalController;

  OrientationController get _controller {
    if (widget.controller != null) return widget.controller!;
    _internalController ??= createOrientationControllerV1(config: widget.config);
    return _internalController!;
  }

  @override
  void didUpdateWidget(OrientationScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller || widget.config != oldWidget.config) {
      if (widget.controller == null && widget.config != oldWidget.config) {
        _internalController = createOrientationControllerV1(config: widget.config);
      }
    }
  }

  @override
  void dispose() {
    if (_internalController is PlatformOrientationController) {
      (_internalController as PlatformOrientationController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OrientationScopeProvider(
      controller: _controller,
      currentPolicy: widget.currentPolicy,
      config: widget.config,
      child: widget.child,
    );
  }
}

class _OrientationScopeProvider extends InheritedWidget {
  const _OrientationScopeProvider({
    required this.controller,
    this.currentPolicy,
    required this.config,
    required super.child,
  });

  final OrientationController controller;
  final OrientationPolicy? currentPolicy;
  final OrientationGuardConfig config;

  @override
  bool updateShouldNotify(_OrientationScopeProvider oldWidget) {
    return controller != oldWidget.controller ||
        currentPolicy != oldWidget.currentPolicy ||
        config != oldWidget.config;
  }
}

import 'package:flutter/foundation.dart' show kIsWeb, ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_block.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final RouteObserver<ModalRoute<dynamic>> backToTopRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

void _scrollToTop(ScrollController controller) {
  if (!controller.hasClients) return;
  final position = controller.position;
  final viewport = position.viewportDimension;
  final offset = position.pixels;
  if (viewport <= 0) return;
  if (offset > 4 * viewport) {
    position.jumpTo(0);
    return;
  }
  position.animateTo(
    0,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
  );
}

void _scrollToTopPosition(ScrollPosition position) {
  final viewport = position.viewportDimension;
  final offset = position.pixels;
  if (viewport <= 0) return;
  if (offset > 4 * viewport) {
    position.jumpTo(0);
    return;
  }
  position.animateTo(
    0,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
  );
}

class BackToTopWrapper extends ConsumerStatefulWidget {
  const BackToTopWrapper({super.key, required this.builder});

  final Widget Function(ScrollController scrollController) builder;

  @override
  ConsumerState<BackToTopWrapper> createState() => _BackToTopWrapperState();
}

class _BackToTopWrapperState extends ConsumerState<BackToTopWrapper> {
  late final ScrollController _scrollController;

  final ValueNotifier<double> _canvasGap = ValueNotifier<double>(0);
  final GlobalKey _stackKey = GlobalKey();
  bool _measureScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleMeasureCanvasGap();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _canvasGap.dispose();
    super.dispose();
  }

  void _scheduleMeasureCanvasGap() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted) return;
      final renderObject = _stackKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        return;
      }
      final stackBottomY = renderObject
          .localToGlobal(Offset(0, renderObject.size.height))
          .dy;
      final canvasHeight = MediaQuery.sizeOf(context).height;
      final gap = (canvasHeight - stackBottomY).clamp(
        -canvasHeight,
        canvasHeight,
      );
      if ((gap - _canvasGap.value).abs() > 0.5) _canvasGap.value = gap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasNav = ShellBottomMetrics.hasBottomNav(context);
    if (hasNav) _scheduleMeasureCanvasGap();
    return Stack(
      key: _stackKey,
      children: [
        !hasNav
            ? widget.builder(_scrollController)
            : NotificationListener<ScrollNotification>(
                onNotification: (_) {
                  _scheduleMeasureCanvasGap();
                  return false;
                },
                child: widget.builder(_scrollController),
              ),
        Positioned(
          right: BackToTopFloatingButton.margin,
          bottom: hasNav
              ? _BackToTopCanvasAnchor.minBottom
              : BackToTopFloatingButton.bottomDesktopTablet,
          child: RepaintBoundary(
            child: !hasNav
                ? BackToTopFloatingButton(controller: _scrollController)
                : _BackToTopCanvasAnchor(
                    canvasGap: _canvasGap,
                    progress: ref.read(scrollHideProvider).progress,
                    child: BackToTopFloatingButton(
                      controller: _scrollController,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _BackToTopCanvasAnchor extends StatelessWidget {
  const _BackToTopCanvasAnchor({
    required this.canvasGap,
    required this.progress,
    required this.child,
  });

  static const double minBottom = 8;

  final ValueListenable<double> canvasGap;
  final ValueListenable<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        canvasGap,
        progress,
        ShellBottomMetrics.navHeight,
        ShellBottomMetrics.navTopFromCanvasBottom,
      ]),
      builder: (context, c) {
        final desiredFromCanvas = _desiredFromCanvasBottom(progress.value);
        final lift = (desiredFromCanvas - canvasGap.value - minBottom).clamp(
          0.0,
          double.infinity,
        );
        return Padding(padding: EdgeInsets.only(bottom: lift), child: c);
      },
      child: child,
    );
  }
}

double _desiredFromCanvasBottom(double hideProgress) {
  return ShellBottomMetrics.floatingGap +
      ShellBottomMetrics.navTopFromCanvasBottom.value -
      ShellBottomMetrics.navHeight.value * hideProgress.clamp(0.0, 0.5);
}

class BackToTopFloatingButton extends StatefulWidget {
  const BackToTopFloatingButton({super.key, required this.controller});

  final ScrollController controller;

  static const double margin = 8;
  static const double iconSize = 40;

  static const double bottomDesktopTablet = 24;

  static const double bottomMobileWithNav = 40;

  static const double mobileBottomNavHeight =
      ShellBottomMetrics.navHeightFallback;

  @override
  State<BackToTopFloatingButton> createState() =>
      _BackToTopFloatingButtonState();
}

class BackToTopNavInset extends StatelessWidget {
  const BackToTopNavInset({
    super.key,
    required this.progress,
    required this.child,
  });

  final ValueListenable<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ShellBottomMetrics.hasBottomNav(context)) return child;
    return AnimatedBuilder(
      animation: Listenable.merge([progress, ShellBottomMetrics.navHeight]),
      builder: (context, c) => Padding(
        padding: EdgeInsets.only(
          bottom:
              ShellBottomMetrics.navHeight.value *
              (1.0 - progress.value.clamp(0.0, 0.5)),
        ),
        child: c,
      ),
      child: child,
    );
  }
}

class _BackToTopFloatingButtonState extends State<BackToTopFloatingButton> {
  bool _visible = false;
  bool _pendingCheck = false;
  static const _throttleMs = 100;
  int _lastCheckTime = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runVisibilityCheck();
    });
  }

  @override
  void didUpdateWidget(BackToTopFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients || _pendingCheck) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCheckTime < _throttleMs) return;
    _pendingCheck = true;
    _lastCheckTime = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingCheck = false;
      if (mounted) _runVisibilityCheck();
    });
  }

  void _runVisibilityCheck() {
    if (!widget.controller.hasClients || !mounted) return;
    final position = widget.controller.position;
    if (!position.hasPixels || position.viewportDimension <= 0) return;
    final offset = position.pixels;
    final viewportHeight = position.viewportDimension;
    final shouldShow = offset > 1.5 * viewportHeight;
    if (shouldShow != _visible && mounted) {
      setState(() => _visible = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: SoundTap.wrap(() => _scrollToTop(widget.controller)),
        child: ImageHelper.load(
          path: AppIcons.iconBackToTop,
          width: BackToTopFloatingButton.iconSize,
          height: BackToTopFloatingButton.iconSize,
        ),
      ),
    );
  }
}

class BackToTopOverlay extends StatefulWidget {
  const BackToTopOverlay({super.key});

  @override
  State<BackToTopOverlay> createState() => _BackToTopOverlayState();
}

class _BackToTopOverlayState extends State<BackToTopOverlay> with RouteAware {
  ScrollPosition? _position;
  OverlayEntry? _overlayEntry;
  OverlayState? _overlayState;
  bool _show = false;
  bool _entryInserted = false;
  bool _routeCovered = false;
  ModalRoute<dynamic>? _subscribedRoute;
  ValueListenable<double>? _navProgress;

  static const double _margin = 8;
  static const double _iconSize = 40;
  static const double _bottomDesktopTablet = 24;

  void _removeEntry() {
    if (!_entryInserted || _overlayEntry == null) return;
    _overlayEntry!.remove();
    _entryInserted = false;
    _overlayEntry = null;
  }

  void _onScroll() {
    final position = _position;
    if (position == null) return;
    if (!position.hasPixels || position.viewportDimension <= 0) return;
    final shouldShow = position.pixels > 1.5 * position.viewportDimension;
    if (shouldShow == _show) return;
    _show = shouldShow;
    _applyVisibility();
  }

  void _applyVisibility() {
    if (_overlayState == null) return;
    if (_show && !_routeCovered) {
      _ensureOverlayEntry();
      if (_overlayEntry != null && !_entryInserted) {
        _overlayState!.insert(_overlayEntry!);
        _entryInserted = true;
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _removeEntry();
    }
  }

  @override
  void didPushNext() {
    _routeCovered = true;
    _applyVisibility();
  }

  @override
  void didPopNext() {
    _routeCovered = false;
    _applyVisibility();
  }

  void _ensureOverlayEntry() {
    if (_overlayEntry != null || _position == null || _overlayState == null) {
      return;
    }
    final position = _position!;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final hasNav = ShellBottomMetrics.hasBottomNav(context);
        final Widget button = Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: SoundTap.wrap(() => _scrollToTopPosition(position)),
            child: ImageHelper.load(
              path: AppIcons.iconBackToTop,
              width: _iconSize,
              height: _iconSize,
            ),
          ),
        );
        final navProgress = _navProgress;
        return Positioned(
          right: _margin,
          bottom: 0,
          child: (hasNav && navProgress != null)
              ? _BackToTopCanvasInset(progress: navProgress, child: button)
              : Padding(
                  padding: const EdgeInsets.only(bottom: _bottomDesktopTablet),
                  child: button,
                ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute<dynamic>? route = ModalRoute.of<dynamic>(context);
    if (route != null && route != _subscribedRoute) {
      if (_subscribedRoute != null) backToTopRouteObserver.unsubscribe(this);
      _subscribedRoute = route;
      backToTopRouteObserver.subscribe(this, route);
    }

    _navProgress ??= ProviderScope.containerOf(context, listen: false)
        .read(scrollHideProvider)
        .progress;

    final scrollable = Scrollable.maybeOf(context);
    ScrollPosition? position = scrollable?.position;
    if (position == null) {
      final primary = PrimaryScrollController.maybeOf(context);
      position = primary?.position;
    }
    OverlayState? overlayState = kIsWeb
        ? Overlay.maybeOf(context, rootOverlay: false)
        : Overlay.maybeOf(context, rootOverlay: true);
    overlayState ??= Overlay.maybeOf(context, rootOverlay: true);

    if (position != _position) {
      _position?.removeListener(_onScroll);
      _removeEntry();
      _position = position;
      _position?.addListener(_onScroll);
    }
    _overlayState = overlayState;
    _ensureOverlayEntry();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onScroll();
      if (_position != null && !_position!.hasPixels) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onScroll();
        });
      }
    });
  }

  @override
  void deactivate() {
    _removeEntry();
    super.deactivate();
  }

  @override
  void dispose() {
    if (_subscribedRoute != null) {
      backToTopRouteObserver.unsubscribe(this);
      _subscribedRoute = null;
    }
    _position?.removeListener(_onScroll);
    _position = null;
    _removeEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BackToTopCanvasInset extends StatelessWidget {
  const _BackToTopCanvasInset({required this.progress, required this.child});

  final ValueListenable<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        progress,
        ShellBottomMetrics.navHeight,
        ShellBottomMetrics.navTopFromCanvasBottom,
      ]),
      builder: (context, c) => Padding(
        padding: EdgeInsets.only(
          bottom: _desiredFromCanvasBottom(progress.value),
        ),
        child: c,
      ),
      child: child,
    );
  }
}

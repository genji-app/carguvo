import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expanded_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expand_request.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_freeze.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_hit_reporter.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';
import 'package:sun_sports/mini/component/mini_empty_zone_pan_recognizer.dart';
import 'package:sun_sports/mini/dragon_ball/state/dragon_ball_sub_view_provider.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_nohu.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_panel.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/dragon_ball_landscape_panel.dart';
import 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class DragonBallScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const DragonBallScreen({super.key, this.onClose});

  @override
  ConsumerState<DragonBallScreen> createState() => _DragonBallScreenState();
}

class _DragonBallScreenState extends ConsumerState<DragonBallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final CurvedAnimation _curve;

  static const double _kDialogMaxWidth = 440;

  static const double _minimizedScale = 0.7;

  static const double _kLandscapeUpscale = 1.25;

  bool _minimized = false;

  bool _landscape = false;

  bool _subOpen = false;

  double get _panelDesignH =>
      _subOpen ? DragonBallPanel.subViewHeight : DragonBallPanel.panelHeight;

  double get _designW =>
      _landscape ? kDragonBallLandscapeDesignWidth : _kDialogMaxWidth;

  double get _designH =>
      _landscape ? kDragonBallLandscapeDesignHeight : _panelDesignH;

  Offset? _pos;

  Offset? _expandedPos;

  Size? _lastSize;

  final GlobalKey _panelKey = GlobalKey();

  final GlobalKey _panelBoundsKey = GlobalKey();

  Offset? _lastExpandedTopLeft;

  Size? _lastExpandedSize;

  Rect? _lastMinRect;

  Offset? _lastInset;

  StreamSubscription<DragonBallToast>? _toastSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = _controller.drive(Tween(begin: 0.0, end: 1.0));
    _controller.forward();

    _toastSub = ref.read(dragonBallStateProvider.notifier).toastMessages.listen(
      (toast) {
        if (!mounted) return;
        switch (toast.kind) {
          case DragonBallToastKind.success:
            AppToast.showSuccess(context, message: toast.message);
          case DragonBallToastKind.error:
            AppToast.showError(context, message: toast.message);
          case DragonBallToastKind.info:
            AppToast.showGeneric(context, message: toast.message);
        }
      },
    );
  }

  @override
  void dispose() {
    _toastSub?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_controller.isAnimating && _controller.velocity < 0) return;
    _controller.reverse().whenComplete(() => widget.onClose?.call());
  }

  void _minimize() {
    if (_minimized) return;
    final box = _panelBoundsKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.attached && box.hasSize) {
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final local = _lastExpandedTopLeft;
      if (local != null) _lastInset = rect.topLeft - local;

      final screen = MediaQuery.sizeOf(context);
      final minW = _designW * _minimizedScale;
      final minH = _designH * _minimizedScale;
      final maxX = (screen.width - minW).clamp(0.0, double.infinity);
      final maxY = (screen.height - minH).clamp(0.0, double.infinity);
      _pos = Offset(
        (rect.center.dx - minW / 2).clamp(0.0, maxX),
        (rect.center.dy - minH / 2).clamp(0.0, maxY),
      );
    }
    setState(() => _minimized = true);
    ref.setMiniGameExpanded(MiniGameSelection.dragonBall, expanded: false);
  }

  void _expand() {
    if (!_minimized) return;
    final minR = _lastMinRect;
    final size = _lastExpandedSize;
    final inset = _lastInset;
    if (minR != null && size != null && inset != null) {
      final screen = MediaQuery.sizeOf(context);
      final maxX = (screen.width - size.width).clamp(0.0, double.infinity);
      final maxY = (screen.height - size.height).clamp(0.0, double.infinity);
      final globalTopLeft = Offset(
        (minR.center.dx - size.width / 2).clamp(0.0, maxX),
        (minR.center.dy - size.height / 2).clamp(0.0, maxY),
      );
      _expandedPos = globalTopLeft - inset;
    }
    setState(() => _minimized = false);
    ref.setMiniGameExpanded(MiniGameSelection.dragonBall, expanded: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      miniGameExpandRequestProvider(MiniGameSelection.dragonBall),
      (prev, next) {
        if (prev != next) _expand();
      },
    );

    ref.listen<int>(
      miniGameMinimizeRequestProvider(MiniGameSelection.dragonBall),
      (prev, next) {
        if (prev != next) _minimize();
      },
    );

    ref.listen(dragonBallHistoryDetailItemProvider, (_, __) {});

    _subOpen = ref.watch(dragonBallSubViewProvider) != DragonBallSubView.none;

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          final prevSize = _lastSize;
          _lastSize = newSize;
          final flipped =
              prevSize != null &&
              (prevSize.width > prevSize.height) !=
                  (newSize.width > newSize.height);
          if (flipped && (_minimized || _pos != null || _expandedPos != null)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _minimized = false;
                _pos = null;
                _expandedPos = null;
                _lastExpandedTopLeft = null;
                _lastExpandedSize = null;
                _lastMinRect = null;
                _lastInset = null;
                ref.setMiniGameExpanded(
                  MiniGameSelection.dragonBall,
                  expanded: true,
                );
              });
            });
          }
          _landscape = constraints.maxWidth > constraints.maxHeight;
          return Stack(
            children: [
              if (_minimized && !flipped)
                _buildMinimized(constraints)
              else
                _buildExpanded(),
              _buildNoHu(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoHu() {
    final win = ref.watch(dragonBallStateProvider.select((s) => s.jackpotWin));
    if (win <= 0) return const SizedBox.shrink();
    final auto = ref.watch(dragonBallStateProvider.select((s) => s.autoSpin));
    return Positioned.fill(
      child: DragonBallNoHu(
        amount: win,
        auto: auto,
        onClose: () =>
            ref.read(dragonBallStateProvider.notifier).dismissJackpot(),
      ),
    );
  }

  Widget _buildExpanded() {
    return Stack(
      children: [
        Positioned.fill(
          child: IframeSafeScrim(
            color: const Color(0x99000000),
            onTap: _minimize,
            fade: _fade,
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  !_landscape && constraints.maxWidth < Breakpoints.mobile;
              final double w;
              final double h;
              if (_landscape) {
                final availH = (constraints.maxHeight - 16).clamp(
                  240.0,
                  double.infinity,
                );
                final scale = _landscapeScale(constraints.maxWidth, availH);
                w = kDragonBallLandscapeDesignWidth * scale;
                h = kDragonBallLandscapeDesignHeight * scale;
              } else {
                h = _panelDesignH;
                w = isMobile
                    ? constraints.maxWidth
                    : (constraints.maxWidth < _kDialogMaxWidth
                          ? constraints.maxWidth
                          : _kDialogMaxWidth);
              }
              final maxX = (constraints.maxWidth - w).clamp(
                0.0,
                double.infinity,
              );
              final maxY = (constraints.maxHeight - h).clamp(
                0.0,
                double.infinity,
              );
              final rest = isMobile
                  ? Offset((constraints.maxWidth - w) / 2, maxY - 8)
                  : Offset(
                      (constraints.maxWidth - w) / 2,
                      (constraints.maxHeight - h) / 2,
                    );
              final pos = _expandedPos ?? rest;
              final clamped = Offset(
                pos.dx.clamp(0.0, maxX),
                pos.dy.clamp(0.0, maxY),
              );
              _lastExpandedTopLeft = clamped;
              _lastExpandedSize = Size(w, h);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: clamped.dx,
                    top: clamped.dy,
                    width: w,
                    height: _landscape ? h : null,
                    child: _expandedPanel(
                      clamped,
                      maxX,
                      maxY,
                      isMobile,
                      _expandedContent(w, h),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _expandedContent(double w, double h) {
    if (!_landscape) return _panel();
    return SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: kDragonBallLandscapeDesignWidth,
          height: kDragonBallLandscapeDesignHeight,
          child: _panel(),
        ),
      ),
    );
  }

  Widget _expandedPanel(
    Offset clamped,
    double maxX,
    double maxY,
    bool isMobile,
    Widget content,
  ) {
    final Widget panel = PointerInterceptor(
      intercepting: kIsWeb,
      child: RawGestureDetector(
        key: _panelBoundsKey,
        behavior: HitTestBehavior.opaque,
        gestures: {
          MiniEmptyZonePanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                MiniEmptyZonePanGestureRecognizer
              >(
                () => MiniEmptyZonePanGestureRecognizer(
                  contentBox: () =>
                      _panelKey.currentContext?.findRenderObject()
                          as RenderBox?,
                ),
                (instance) {
                  instance.onUpdate = (details) {
                    final p = _expandedPos ?? clamped;
                    setState(() {
                      _expandedPos = Offset(
                        (p.dx + details.delta.dx).clamp(0.0, maxX),
                        (p.dy + details.delta.dy).clamp(0.0, maxY),
                      );
                    });
                  };
                },
              ),
        },
        child: content,
      ),
    );

    if (isMobile) {
      return SlideTransition(
        position: _curve.drive(
          Tween(begin: const Offset(0, 1), end: Offset.zero),
        ),
        child: FadeTransition(opacity: _fade, child: panel),
      );
    }
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _curve.drive(Tween(begin: 0.92, end: 1.0)),
        child: panel,
      ),
    );
  }

  Widget _buildMinimized(BoxConstraints constraints) {
    final designW = _designW;
    final designH = _designH;
    final w = designW * _minimizedScale;
    final h = designH * _minimizedScale;

    final maxX = (constraints.maxWidth - w).clamp(0.0, double.infinity);
    final maxY = (constraints.maxHeight - h).clamp(0.0, double.infinity);
    final pos =
        _pos ??
        Offset((constraints.maxWidth - w) / 2, (constraints.maxHeight - h) / 2);
    final clamped = Offset(pos.dx.clamp(0.0, maxX), pos.dy.clamp(0.0, maxY));
    _lastMinRect = clamped & Size(w, h);

    return Stack(
      children: [
        Positioned(
          left: clamped.dx,
          top: clamped.dy,
          child: MiniGameMinimizedHitReporter(
            id: 'dragonball',
            game: MiniGameSelection.dragonBall,
            active: true,
          child: PointerInterceptor(
            intercepting: kIsWeb,
            child: GestureDetector(
              onTap: _expand,
              onPanUpdate: (details) {
                final base = _pos ?? clamped;
                setState(() {
                  _pos = Offset(
                    (base.dx + details.delta.dx).clamp(0.0, maxX),
                    (base.dy + details.delta.dy).clamp(0.0, maxY),
                  );
                });
              },
              child: SizedBox(
                key: _panelBoundsKey,
                width: w,
                height: h,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: designW,
                    height: designH,
                    child: MiniGameMinimizedFreeze(
                      busy: ref.watch(
                        dragonBallStateProvider.select((s) => s.isSpinning),
                      ),
                      child: _panel(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }

  double _landscapeScale(double availW, double availH) {
    final byWidth = availW / kDragonBallLandscapeDesignWidth;
    final byHeight = availH / kDragonBallLandscapeDesignHeight;
    final fit = byWidth < byHeight ? byWidth : byHeight;
    return fit > _kLandscapeUpscale ? _kLandscapeUpscale : fit;
  }

  Widget _panel() => _landscape
      ? DragonBallLandscapePanel(
          key: _panelKey,
          onClose: _dismiss,
          borderRadius: BorderRadius.circular(20),
        )
      : DragonBallPanel(
          key: _panelKey,
          onClose: _dismiss,
          borderRadius: BorderRadius.circular(20),
        );
}

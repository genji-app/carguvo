import 'package:flutter/foundation.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expanded_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expand_request.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_freeze.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_hit_reporter.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';
import 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_nohu.dart';
import 'package:sun_sports/mini/diamond/state/diamond_sub_view_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_panel.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_panel.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

class DiamondScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const DiamondScreen({super.key, this.onClose});

  @override
  ConsumerState<DiamondScreen> createState() => _DiamondScreenState();
}

class _DiamondScreenState extends ConsumerState<DiamondScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  late final AnimationController _zoomController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final CurvedAnimation _zoom = CurvedAnimation(
    parent: _zoomController,
    curve: Curves.easeInOutCubic,
  );

  final GlobalKey _panelBoundsKey = GlobalKey();

  final GlobalKey _panelContentKey = GlobalKey();

  bool _floatingActive = false;

  bool _minimized = false;

  Rect? _expandedRect;

  Offset? _floatPos;

  final ValueNotifier<Offset> _popupOffset = ValueNotifier<Offset>(Offset.zero);

  Offset? _popupDragBase;
  Rect? _popupDragStartRect;
  Rect? _lastMinRect;
  Size? _lastSize;

  bool get _zoomInFlight => _zoomController.isAnimating;

  Size? _panelFrameSize;

  bool _assetsReady = false;

  static const Duration _kPopupDragHold = Duration(milliseconds: 150);
  static const double _kMinScale = 0.7;
  static const double _kDialogMaxWidth = 440;

  static const double _kPanelDesignHeight = 620;
  static const Color _kScrimColor = Color(0xB3000000);

  static const double _kPopupHPad = 30;

  static const double _kMinScrimGap = 72;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _preload();
  }

  Future<void> _preload() async {
    try {
      
    } catch (_) {
    }
    if (mounted) setState(() => _assetsReady = true);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    _zoom.dispose();
    _zoomController.dispose();
    _popupOffset.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_controller.isAnimating && _controller.velocity < 0) return;
    _controller.reverse().whenComplete(() => widget.onClose?.call());
  }

  void _minimize() {
    if (_minimized || _floatingActive) return;
    final box = _panelBoundsKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    _expandedRect = rect;

    final size = _lastSize ?? MediaQuery.sizeOf(context);
    final minW = rect.width * _kMinScale;
    final minH = rect.height * _kMinScale;
    final maxX = (size.width - minW).clamp(0.0, double.infinity);
    final maxY = (size.height - minH).clamp(0.0, double.infinity);
    _floatPos = Offset(
      (rect.center.dx - minW / 2).clamp(0.0, maxX),
      (rect.center.dy - minH / 2).clamp(0.0, maxY),
    );

    setState(() {
      _floatingActive = true;
      _minimized = true;
      ref.setMiniGameExpanded(MiniGameSelection.kimCuong, expanded: false);
    });
    _zoomController.forward().whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  void _expand() {
    if (!_minimized) return;
    final expanded = _expandedRect;
    final minR = _lastMinRect;
    final size = _lastSize;
    if (expanded != null && minR != null && size != null) {
      final w = expanded.width;
      final h = expanded.height;
      final maxX = (size.width - w).clamp(0.0, double.infinity);
      final maxY = (size.height - h).clamp(0.0, double.infinity);
      final newTopLeft = Offset(
        (minR.center.dx - w / 2).clamp(0.0, maxX),
        (minR.center.dy - h / 2).clamp(0.0, maxY),
      );
      final defaultTopLeft = expanded.topLeft - _popupOffset.value;
      _popupOffset.value = newTopLeft - defaultTopLeft;
      _expandedRect = newTopLeft & Size(w, h);
    }
    setState(() => _minimized = false);
    ref.setMiniGameExpanded(MiniGameSelection.kimCuong, expanded: true);
    _zoomController.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _floatingActive = false);
    });
  }

  void _startPopupDrag() {
    _popupDragBase = _popupOffset.value;
    _popupDragStartRect = _panelGlobalRect();
  }

  void _updatePopupDrag(
    LongPressMoveUpdateDetails details,
    BoxConstraints constraints,
  ) {
    final startRect = _popupDragStartRect;
    final base = _popupDragBase;
    if (startRect == null || base == null) return;
    final maxX =
        (constraints.maxWidth - startRect.width).clamp(0.0, double.infinity);
    final maxY =
        (constraints.maxHeight - startRect.height).clamp(0.0, double.infinity);
    final target = startRect.topLeft + details.offsetFromOrigin;
    final clamped = Offset(
      target.dx.clamp(0.0, maxX),
      target.dy.clamp(0.0, maxY),
    );
    final newOffset = base + (clamped - startRect.topLeft);
    if (newOffset == _popupOffset.value) return;
    _popupOffset.value = newOffset;
  }

  Widget _draggablePopup(BoxConstraints constraints, Widget child) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(duration: _kPopupDragHold),
          (instance) {
            instance.onLongPressStart = (_) => _startPopupDrag();
            instance.onLongPressMoveUpdate =
                (d) => _updatePopupDrag(d, constraints);
          },
        ),
      },
      child: child,
    );
  }

  Rect? _panelGlobalRect() {
    final box = _panelBoundsKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget _panelChild(BorderRadius borderRadius) => PointerInterceptor(
        intercepting: kIsWeb,
        child: _assetsReady ? _panel(borderRadius) : const _Loading(),
      );

  Widget _panel(BorderRadius borderRadius) => _landscape
      ? DiamondLandscapePanel(
          key: _panelContentKey,
          onClose: _dismiss,
          borderRadius: borderRadius,
        )
      : DiamondPanel(
          key: _panelContentKey,
          onClose: _dismiss,
          borderRadius: borderRadius,
        );

  bool _landscape = false;

  double get _designWidth =>
      _landscape ? kDiamondLandscapeDesignWidth : _kDialogMaxWidth;

  double get _designHeight =>
      _landscape ? kDiamondLandscapeDesignHeight : _kPanelDesignHeight;

  static const double _kLandscapeUpscale = 1.25;

  double _landscapeScale(double availW, double availH) {
    final byWidth = availW / _designWidth;
    final byHeight = availH / _designHeight;
    final fit = byWidth < byHeight ? byWidth : byHeight;
    return fit > _kLandscapeUpscale ? _kLandscapeUpscale : fit;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(diamondStateProvider, (_, __) {});

    ref.listen(diamondSubViewProvider, (_, __) {});

    ref.listen<int>(
      miniGameExpandRequestProvider(MiniGameSelection.kimCuong),
      (prev, next) {
        if (prev != next) _expand();
      },
    );

    ref.listen<int>(
      miniGameMinimizeRequestProvider(MiniGameSelection.kimCuong),
      (prev, next) {
        if (prev != next) _minimize();
      },
    );

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          final prevSize = _lastSize;
          _lastSize = newSize;
          final flipped = prevSize != null &&
              (prevSize.width > prevSize.height) !=
                  (newSize.width > newSize.height);
          if (flipped &&
              (_floatingActive || _popupOffset.value != Offset.zero)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _floatingActive = false;
                _minimized = false;
                ref.setMiniGameExpanded(MiniGameSelection.kimCuong, expanded: true);
                _expandedRect = null;
                _floatPos = null;
                _lastMinRect = null;
                _zoomController.value = 0;
                _popupOffset.value = Offset.zero;
              });
            });
          }
          _landscape = constraints.maxWidth > constraints.maxHeight;
          final isMobile =
              !_landscape && constraints.maxWidth < Breakpoints.mobile;
          return Stack(
            children: [
              if (_floatingActive && !flipped)
                _buildFloating(constraints)
              else
                _buildExpanded(constraints, isMobile),
              _buildJackpot(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJackpot() {
    final win = ref.watch(diamondStateProvider.select((s) => s.jackpotWin));
    if (win <= 0) return const SizedBox.shrink();
    final auto = ref.watch(diamondStateProvider.select((s) => s.autoSpin));
    return Positioned.fill(
      child: DiamondNoHu(
        amount: win,
        auto: auto,
        borderRadius: BorderRadius.zero,
        onClose: () =>
            ref.read(diamondStateProvider.notifier).dismissJackpot(),
      ),
    );
  }

  Widget _buildExpanded(BoxConstraints constraints, bool isMobile) {
    return Stack(
      children: [
        Positioned.fill(
          child: IframeSafeScrim(
            color: _kScrimColor,
            fade: _curve,
            onTapUp: (details) {
              final rect = _panelGlobalRect();
              if (rect == null || !rect.contains(details.globalPosition)) {
                _minimize();
              }
            },
          ),
        ),
        if (isMobile)
          _buildBottomSheet(constraints)
        else
          _buildDialog(constraints),
      ],
    );
  }

  Widget _buildBottomSheet(BoxConstraints constraints) {
    _panelFrameSize = null;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final maxPanelH = (constraints.maxHeight - bottomInset - 8 - _kMinScrimGap)
        .clamp(240.0, double.infinity);
    return ValueListenableBuilder<Offset>(
      valueListenable: _popupOffset,
      builder: (context, offset, child) =>
          Transform.translate(offset: offset, child: child),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _curve.drive(
            Tween(begin: const Offset(0, 1), end: Offset.zero),
          ),
          child: FadeTransition(
            opacity: _curve,
            child: Padding(
              padding: EdgeInsets.only(
                left: _kPopupHPad,
                right: _kPopupHPad,
                bottom: bottomInset + 8,
              ),
              child: _draggablePopup(
                constraints,
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxPanelH),
                  child: SizedBox(
                    key: _panelBoundsKey,
                    width: (constraints.maxWidth - _kPopupHPad * 2)
                        .clamp(0.0, double.infinity),
                    child: _panelChild(
                      const BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialog(BoxConstraints constraints) {
    if (_landscape) return _buildLandscapeDialog(constraints);
    final width = constraints.maxWidth < _kDialogMaxWidth
        ? constraints.maxWidth
        : _kDialogMaxWidth;
    final maxPanelH = (constraints.maxHeight - _kMinScrimGap * 2)
        .clamp(240.0, double.infinity);
    final tightPanelH =
        (constraints.maxHeight - 16).clamp(240.0, double.infinity);
    _panelFrameSize = maxPanelH >= _kPanelDesignHeight
        ? null
        : Size(width, _kPanelDesignHeight);
    return ValueListenableBuilder<Offset>(
      valueListenable: _popupOffset,
      builder: (context, offset, child) =>
          Transform.translate(offset: offset, child: child),
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _curve,
            child: ScaleTransition(
              scale: _curve.drive(Tween(begin: 0.92, end: 1.0)),
              child: _draggablePopup(
                constraints,
                maxPanelH >= _kPanelDesignHeight
                    ? ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxPanelH),
                        child: SizedBox(
                          key: _panelBoundsKey,
                          width: width,
                          child: _panelChild(
                            const BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: width,
                          maxHeight: tightPanelH,
                        ),
                        child: FittedBox(
                          key: _panelBoundsKey,
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: width,
                            height: _kPanelDesignHeight,
                            child: _panelChild(
                              const BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeDialog(BoxConstraints constraints) {
    final designW = _designWidth;
    final designH = _designHeight;
    final availW = constraints.maxWidth;
    final availH =
        (constraints.maxHeight - 16).clamp(240.0, double.infinity);
    final scale = _landscapeScale(availW, availH);
    _panelFrameSize = Size(designW, designH);
    return ValueListenableBuilder<Offset>(
      valueListenable: _popupOffset,
      builder: (context, offset, child) =>
          Transform.translate(offset: offset, child: child),
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _curve,
            child: ScaleTransition(
              scale: _curve.drive(Tween(begin: 0.92, end: 1.0)),
              child: _draggablePopup(
                constraints,
                SizedBox(
                  key: _panelBoundsKey,
                  width: designW * scale,
                  height: designH * scale,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: designW,
                      height: designH,
                      child: _panelChild(
                        const BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloating(BoxConstraints constraints) {
    final expanded = _expandedRect;
    if (expanded == null) return const SizedBox.shrink();

    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;
    final minW = expanded.width * _kMinScale;
    final minH = expanded.height * _kMinScale;
    final maxX = (maxW - minW).clamp(0.0, double.infinity);
    final maxY = (maxH - minH).clamp(0.0, double.infinity);
    final defaultPos = Offset(maxX / 2, maxY / 2);
    final floatPos = _floatPos ?? defaultPos;
    final clampedFloat = Offset(
      floatPos.dx.clamp(0.0, maxX),
      floatPos.dy.clamp(0.0, maxY),
    );
    final minRect = clampedFloat & Size(minW, minH);
    _lastMinRect = minRect;

    final child = FadeTransition(
      opacity: _curve,
      child: MiniGameMinimizedHitReporter(
        id: 'kimcuong',
        game: MiniGameSelection.kimCuong,
        active: _minimized,
        child: PointerInterceptor(
          intercepting: kIsWeb && !_zoomInFlight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _minimized ? _expand : null,
            onPanUpdate: _minimized
                ? (details) {
                    final base = _floatPos ?? clampedFloat;
                    setState(() {
                      _floatPos = Offset(
                        (base.dx + details.delta.dx).clamp(0.0, maxX),
                        (base.dy + details.delta.dy).clamp(0.0, maxY),
                      );
                    });
                  }
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FittedBox(
                key: _panelBoundsKey,
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _panelFrameSize?.width ?? expanded.width,
                  height: _panelFrameSize?.height ?? expanded.height,
                  child: MiniGameMinimizedFreeze(
                    busy:
                        (!_minimized && !_zoomInFlight) ||
                        ref.watch(
                          diamondStateProvider.select(
                            (s) => s.spinning || s.animating,
                          ),
                        ),
                    child: _panel(BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _zoom,
      child: child,
      builder: (context, cached) {
        final rect = Rect.lerp(expanded, minRect, _zoom.value)!;
        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: cached!,
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: kDiamondPanelBg,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      alignment: Alignment.center,
      child: const S88Loading(
        indicatorSize: 72,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

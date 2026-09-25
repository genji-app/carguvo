import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expanded_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expand_request.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_freeze.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_minimized_hit_reporter.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';
import 'package:sun_sports/mini/component/mini_empty_zone_pan_recognizer.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim.dart';

import 'widgets/tai_xiu_chat_mini_button.dart';

class _PanelGeom {
  Offset? floatingPos;

  Offset? expandedPos;

  final GlobalKey contentKey = GlobalKey();

  final GlobalKey boundsKey = GlobalKey();

  Offset? lastExpandedTopLeft;

  Size? lastExpandedSize;

  Rect? lastMinRect;

  Offset? lastInset;
}

class TaiXiuFloatingPanels extends ConsumerStatefulWidget {
  const TaiXiuFloatingPanels({
    required this.logLabel,
    required this.gameDesignSize,
    required this.chatDesignSize,
    required this.layoutBounds,
    required this.gameDefaultOffset,
    required this.chatDefaultOffset,
    required this.chatButtonAlignment,
    required this.gameBuilder,
    required this.chatBuilder,
    this.baseScale,
    this.minimizedScaleOf,
    super.key,
  });

  final String logLabel;

  final Size gameDesignSize;
  final Size chatDesignSize;

  final Size layoutBounds;

  final Offset gameDefaultOffset;
  final Offset chatDefaultOffset;

  final Alignment chatButtonAlignment;

  final WidgetBuilder gameBuilder;

  final Widget Function(BuildContext context, VoidCallback closeChat)
  chatBuilder;

  final double Function(BoxConstraints constraints)? baseScale;

  static const double minimizedScale = 0.7;

  final double Function(BoxConstraints constraints)? minimizedScaleOf;

  static const Size _chatButtonSize = Size(170, 49);

  static const double _chatButtonMargin = 16;

  @override
  ConsumerState<TaiXiuFloatingPanels> createState() =>
      _TaiXiuFloatingPanelsState();
}

class _TaiXiuFloatingPanelsState extends ConsumerState<TaiXiuFloatingPanels> {
  bool _minimized = false;

  bool _chatVisible = true;

  bool _chatOnTop = true;

  final _game = _PanelGeom();
  final _chat = _PanelGeom();

  Offset? _chatButtonPos;

  double _fitScale(BoxConstraints c) => [
    widget.baseScale?.call(c) ?? 1.0,
    c.maxWidth / widget.layoutBounds.width,
    c.maxHeight / widget.layoutBounds.height,
  ].reduce((a, b) => a < b ? a : b);

  double _minimizedScale(BoxConstraints c) {
    final factor =
        widget.minimizedScaleOf?.call(c) ?? TaiXiuFloatingPanels.minimizedScale;
    if (kIsWeb) return _fitScale(c) * factor;
    final base = widget.baseScale?.call(c) ?? 1.0;
    final clamp = math.min(1.0, _fitScale(c) / base);
    return factor * clamp;
  }

  BoxConstraints get _screenConstraints {
    final s = MediaQuery.sizeOf(context);
    return BoxConstraints(maxWidth: s.width, maxHeight: s.height);
  }

  Size get _gameMinSize =>
      widget.gameDesignSize * _minimizedScale(_screenConstraints);
  Size get _chatMinSize =>
      widget.chatDesignSize * _minimizedScale(_screenConstraints);

  void _minimize() {
    if (_minimized) return;
    _captureFloatingPos(_game, _gameMinSize);
    if (_chatVisible) _captureFloatingPos(_chat, _chatMinSize);
    setState(() => _minimized = true);
    ref.setMiniGameExpanded(MiniGameSelection.taiXiu, expanded: false);
  }

  void _captureFloatingPos(_PanelGeom p, Size minSize) {
    final box = p.boundsKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final local = p.lastExpandedTopLeft;
    if (local != null) p.lastInset = rect.topLeft - local;

    final screen = MediaQuery.sizeOf(context);
    final maxX = (screen.width - minSize.width).clamp(0.0, double.infinity);
    final maxY = (screen.height - minSize.height).clamp(0.0, double.infinity);
    p.floatingPos = Offset(
      (rect.center.dx - minSize.width / 2).clamp(0.0, maxX),
      (rect.center.dy - minSize.height / 2).clamp(0.0, maxY),
    );
  }

  void _expand() {
    if (!_minimized) return;
    _restoreExpandedPos(_game);
    if (_chatVisible) _restoreExpandedPos(_chat);
    setState(() => _minimized = false);
    ref.setMiniGameExpanded(MiniGameSelection.taiXiu, expanded: true);
  }

  void _restoreExpandedPos(_PanelGeom p) {
    final minR = p.lastMinRect;
    final size = p.lastExpandedSize;
    final inset = p.lastInset;
    if (minR == null || size == null || inset == null) return;
    final screen = MediaQuery.sizeOf(context);
    final maxX = (screen.width - size.width).clamp(0.0, double.infinity);
    final maxY = (screen.height - size.height).clamp(0.0, double.infinity);
    final globalTopLeft = Offset(
      (minR.center.dx - size.width / 2).clamp(0.0, maxX),
      (minR.center.dy - size.height / 2).clamp(0.0, maxY),
    );
    p.expandedPos = globalTopLeft - inset;
  }

  void _closeChat() => setState(() => _chatVisible = false);

  void _openChat() => setState(() => _chatVisible = true);

  @override
  void dispose() {
    AppLoggers.ui.i('[MiniGameStack] ${widget.logLabel} DISPOSED');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(miniGameExpandRequestProvider(MiniGameSelection.taiXiu), (
      prev,
      next,
    ) {
      if (prev != next) _expand();
    });

    ref.listen<int>(miniGameMinimizeRequestProvider(MiniGameSelection.taiXiu), (
      prev,
      next,
    ) {
      if (prev != next) _minimize();
    });

    return Material(
      type: MaterialType.transparency,
      child: _minimized ? _buildMinimized() : _buildExpanded(),
    );
  }

  Widget _gameContent() =>
      KeyedSubtree(key: _game.contentKey, child: widget.gameBuilder(context));

  Widget _chatContent() => KeyedSubtree(
    key: _chat.contentKey,
    child: widget.chatBuilder(context, _closeChat),
  );

  List<Widget> _stackChildren({
    required Widget gamePanel,
    required Widget? chatPanel,
    required Widget? chatButton,
  }) => [
    if (_chatOnTop) ...[
      gamePanel,
      if (chatPanel != null) chatPanel,
    ] else ...[
      if (chatPanel != null) chatPanel,
      gamePanel,
    ],
    if (chatButton != null) chatButton,
  ];

  Widget _buildExpanded() {
    return Stack(
      children: [
        Positioned.fill(
          child: IframeSafeScrim(
            color: const Color(0x99000000),
            onTap: _minimize,
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = _fitScale(constraints);

              final gameSize = widget.gameDesignSize * scale;
              final chatSize = widget.chatDesignSize * scale;

              final base = Offset(
                (constraints.maxWidth - widget.layoutBounds.width * scale) / 2,
                (constraints.maxHeight - widget.layoutBounds.height * scale) /
                    2,
              );
              final gameDefault = base + widget.gameDefaultOffset * scale;
              final chatDefault = base + widget.chatDefaultOffset * scale;

              final gamePanel = _expandedPanel(
                key: const ValueKey('tx_panel_game'),
                p: _game,
                defaultPos: gameDefault,
                size: gameSize,
                constraints: constraints,
                designSize: widget.gameDesignSize,
                onDragStart: () => setState(() => _chatOnTop = false),
                child: _gameContent(),
              );
              final chatPanel = _chatVisible
                  ? _expandedPanel(
                      key: const ValueKey('tx_panel_chat'),
                      p: _chat,
                      defaultPos: chatDefault,
                      size: chatSize,
                      constraints: constraints,
                      designSize: widget.chatDesignSize,
                      onDragStart: () => setState(() => _chatOnTop = true),
                      child: _chatContent(),
                    )
                  : null;

              return Stack(
                children: _stackChildren(
                  gamePanel: gamePanel,
                  chatPanel: chatPanel,
                  chatButton: _chatVisible ? null : _chatButton(constraints),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _expandedPanel({
    required Key key,
    required _PanelGeom p,
    required Offset defaultPos,
    required Size size,
    required BoxConstraints constraints,
    required Size designSize,
    required VoidCallback onDragStart,
    required Widget child,
  }) {
    final maxX = (constraints.maxWidth - size.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (constraints.maxHeight - size.height).clamp(
      0.0,
      double.infinity,
    );
    final pos = p.expandedPos ?? defaultPos;
    final clamped = Offset(pos.dx.clamp(0.0, maxX), pos.dy.clamp(0.0, maxY));
    p.lastExpandedTopLeft = clamped;
    p.lastExpandedSize = size;

    return Positioned(
      key: key,
      left: clamped.dx,
      top: clamped.dy,
      width: size.width,
      height: size.height,
      child: PointerInterceptor(
        intercepting: kIsWeb,
        child: RawGestureDetector(
          key: p.boundsKey,
          behavior: HitTestBehavior.opaque,
          gestures: {
            MiniEmptyZonePanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  MiniEmptyZonePanGestureRecognizer
                >(
                  () => MiniEmptyZonePanGestureRecognizer(
                    contentBox: () =>
                        p.contentKey.currentContext?.findRenderObject()
                            as RenderBox?,
                  ),
                  (instance) {
                    instance.onStart = (_) => onDragStart();
                    instance.onUpdate = (details) {
                      final base = p.expandedPos ?? clamped;
                      setState(() {
                        p.expandedPos = Offset(
                          (base.dx + details.delta.dx).clamp(0.0, maxX),
                          (base.dy + details.delta.dy).clamp(0.0, maxY),
                        );
                      });
                    };
                  },
                ),
          },
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: designSize.width,
              height: designSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimized() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = _minimizedScale(constraints);
        final base = Offset(
          (constraints.maxWidth - widget.layoutBounds.width * s) / 2,
          (constraints.maxHeight - widget.layoutBounds.height * s) / 2,
        );
        final gameDefault = base + widget.gameDefaultOffset * s;
        final chatDefault = base + widget.chatDefaultOffset * s;

        final gamePanel = _floatingPanel(
          key: const ValueKey('tx_panel_game'),
          hitId: 'taixiu_game',
          p: _game,
          defaultPos: gameDefault,
          minSize: _gameMinSize,
          constraints: constraints,
          designSize: widget.gameDesignSize,
          onDragStart: () => setState(() => _chatOnTop = false),
          child: MiniGameMinimizedFreeze(
            busy: ref.watch(
              taiXiuSocketStateProvider.select((s) => s.remainingTimeSec == 0),
            ),
            child: _gameContent(),
          ),
        );
        final chatPanel = _chatVisible
            ? _floatingPanel(
                key: const ValueKey('tx_panel_chat'),
                hitId: 'taixiu_chat',
                p: _chat,
                defaultPos: chatDefault,
                minSize: _chatMinSize,
                constraints: constraints,
                designSize: widget.chatDesignSize,
                onDragStart: () => setState(() => _chatOnTop = true),
                child: _chatContent(),
              )
            : null;

        return Stack(
          children: _stackChildren(
            gamePanel: gamePanel,
            chatPanel: chatPanel,
            chatButton: _chatVisible ? null : _chatButton(constraints),
          ),
        );
      },
    );
  }

  Widget _floatingPanel({
    required Key key,
    required String hitId,
    required _PanelGeom p,
    required Offset defaultPos,
    required Size minSize,
    required BoxConstraints constraints,
    required Size designSize,
    required VoidCallback onDragStart,
    required Widget child,
  }) {
    final maxX = (constraints.maxWidth - minSize.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (constraints.maxHeight - minSize.height).clamp(
      0.0,
      double.infinity,
    );
    final pos = p.floatingPos ?? defaultPos;
    final clamped = Offset(pos.dx.clamp(0.0, maxX), pos.dy.clamp(0.0, maxY));
    p.lastMinRect = clamped & minSize;

    return Positioned(
      key: key,
      left: clamped.dx,
      top: clamped.dy,
      child: MiniGameMinimizedHitReporter(
        id: hitId,
        game: MiniGameSelection.taiXiu,
        active: true,
      child: PointerInterceptor(
        intercepting: kIsWeb,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _expand,
          onPanStart: (_) => onDragStart(),
          onPanUpdate: (details) {
            final base = p.floatingPos ?? clamped;
            setState(() {
              p.floatingPos = Offset(
                (base.dx + details.delta.dx).clamp(0.0, maxX),
                (base.dy + details.delta.dy).clamp(0.0, maxY),
              );
            });
          },
          child: SizedBox(
            key: p.boundsKey,
            width: minSize.width,
            height: minSize.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: designSize.width,
                    height: designSize.height,
                    child: child,
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

  Widget _chatButton(BoxConstraints constraints) {
    const size = TaiXiuFloatingPanels._chatButtonSize;
    const margin = TaiXiuFloatingPanels._chatButtonMargin;
    final maxX = (constraints.maxWidth - size.width).clamp(0.0, double.infinity);
    final maxY = (constraints.maxHeight - size.height).clamp(
      0.0,
      double.infinity,
    );
    final area = (Offset.zero & constraints.biggest).deflate(margin);
    final defaultPos = widget.chatButtonAlignment.inscribe(size, area).topLeft;
    final pos = _chatButtonPos ?? defaultPos;
    final clamped = Offset(pos.dx.clamp(0.0, maxX), pos.dy.clamp(0.0, maxY));

    return Positioned(
      key: const ValueKey('tx_chat_mini_button'),
      left: clamped.dx,
      top: clamped.dy,
      child: PointerInterceptor(
        intercepting: kIsWeb,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(_openChat),
            onPanUpdate: (details) {
              final base = _chatButtonPos ?? clamped;
              setState(() {
                _chatButtonPos = Offset(
                  (base.dx + details.delta.dx).clamp(0.0, maxX),
                  (base.dy + details.delta.dy).clamp(0.0, maxY),
                );
              });
            },
            child: const TaiXiuChatMiniButton(),
          ),
        ),
      ),
    );
  }
}

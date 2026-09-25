import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_header.dart';
import 'package:sun_sports/shared/layouts/shell_tablet_header.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/core/services/providers/websocket_provider.dart';
import 'package:sun_sports/shared/widgets/authenticated_widget.dart';
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expanded_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart';

import '../common/domain/volta_bet_rules.dart';
import '../common/volta_feedback.dart';
import '../common/volta_layout_spec.dart';
import '../common/volta_music.dart';
import '../common/state/volta_models.dart';
import '../common/state/volta_state.dart';
import '../common/state/volta_state_provider.dart';
import '../common/volta_metrics.dart';
import '../common/volta_rules.dart';
import 'sub_views/volta_bet_history_sheet.dart';
import 'sub_views/volta_guide_sheet.dart';
import 'sub_views/volta_rank_sheet.dart';
import 'volta_mobile_layout.dart';
import 'volta_tablet_layout.dart';

class VoltaScreen extends ConsumerWidget {
  const VoltaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool tablet = VoltaMetrics.isTablet(context);

    return VoltaLayoutScope(
      spec: tablet ? VoltaLayoutSpec.tablet : VoltaLayoutSpec.mobile,
      child: _VoltaMusicHook(
        child: ColoredBox(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            if (tablet)
              ShellTabletHeader(
                onBackPressed: () => Navigator.of(context).maybePop(),
                showOddsStyle: false,
              )
            else
              SportDetailMobileHeader(
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
            if (tablet)
              Expanded(
                child: VoltaTabletLayout(
                  onOpenBetHistory: () => _openBetHistory(context),
                  onOpenRanking: () => _openRanking(context),
                  onOpenGuide: () => _openGuide(context),
                ),
              )
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) => Column(
                    children: <Widget>[
                      _ChatStrip(available: c.maxHeight, width: c.maxWidth),
                      Expanded(
                        child: VoltaMobileLayout(
                          onOpenBetHistory: () => _openBetHistory(context),
                          onOpenRanking: () => _openRanking(context),
                          onOpenGuide: () => _openGuide(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  static void _openBetHistory(BuildContext context) =>
      _openSheet(context, const VoltaBetHistorySheet());

  static void _openRanking(BuildContext context) =>
      _openSheet(context, const VoltaRankSheet(), fitContent: true);

  static void _openGuide(BuildContext context) =>
      _openSheet(context, const VoltaGuideSheet());

  static void _openSheet(
    BuildContext context,
    Widget child, {
    double heightFactor = 0.8,
    bool fitContent = false,
  }) {
    if (!VoltaMetrics.isTablet(context)) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (BuildContext sheetContext) => fitContent
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.sizeOf(sheetContext).height * heightFactor,
                ),
                child: child,
              )
            : FractionallySizedBox(heightFactor: heightFactor, child: child),
      );
      return;
    }

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: const Color(0xB3000000),
      builder: (BuildContext dialogContext) {
        final Size screen = MediaQuery.sizeOf(dialogContext);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: math.min(640, screen.height * 0.8),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        );
      },
    );
  }
}

class _ChatStrip extends ConsumerWidget {
  const _ChatStrip({required this.available, required this.width});

  final double available;

  final double width;

  static double _chatHeight(WidgetRef ref, int lines) {
    final double shell = ShellTopMetrics.chat(ref);
    return shell == ShellTopMetrics.chatCollapsed
        ? ChatLineMetrics.voltaCollapsedFor(lines)
        : shell;
  }

  static const double _chatTopGap = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int lines = voltaChatVisibleLines(
      available: available,
      designHeight: VoltaMobileLayout.designHeightAt(
        VoltaLayoutSpec.mobile,
        width,
      ),
      lineHeight: ChatLineMetrics.chatLine,
      listPadding: ChatLineMetrics.listPadding,
      topGap: _chatTopGap,
    );
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) => true,
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) => true,
        child: Padding(
          padding: const EdgeInsets.only(top: _chatTopGap),
          child: SizedBox(
            height: _chatHeight(ref, lines),
            child: const AuthenticatedWidget(
              fallback: ChatLoginOverlay(isMobile: true),
              child: RepaintBoundary(child: SportLiveChat(isMobile: true)),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoltaMusicHook extends ConsumerStatefulWidget {
  const _VoltaMusicHook({required this.child});

  final Widget child;

  @override
  ConsumerState<_VoltaMusicHook> createState() => _VoltaMusicHookState();
}

class _VoltaMusicHookState extends ConsumerState<_VoltaMusicHook>
    with WidgetsBindingObserver {
  StreamSubscription<VoltaBetOutcome>? _noticeSub;

  WebSocketNotifier? _chatSocket;

  Timer? _betClosedTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        VoltaMusic.instance.applyCue(ref.read(voltaStateProvider).musicCue),
      );
      _noticeSub = ref
          .read(voltaStateProvider.notifier)
          .notices
          .listen((VoltaBetOutcome outcome) {
            if (!mounted) return;
            VoltaBetFeedback.show(context, outcome);
          });

      final WebSocketNotifier socket = ref.read(websocketProvider.notifier);
      final String room = VoltaRules.chatRoom;
      if (socket.pushChatRoom(room)) {
        _chatSocket = socket;
        if (kDebugMode) debugPrint('Volta: chat chuyển sang phòng "$room"');
      }
    });
  }

  bool _appResumed = true;

  bool _coveredByMiniGame = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    ref.read(voltaStateProvider.notifier).setFocused(_appResumed);
    _applyMusic();
  }

  void _applyMusic() {
    VoltaMusic.instance.setPaused(!_appResumed || _coveredByMiniGame);
  }

  bool _hasExpandedGame() => ref.read(miniGameExpandedProvider).isNotEmpty;

  void _setCovered(bool covered) {
    if (_coveredByMiniGame == covered) return;
    _coveredByMiniGame = covered;
    if (kDebugMode) {
      debugPrint(
        covered
            ? 'Volta: mini game đè lên — nhường NHẠC, ván vẫn chạy.'
            : 'Volta: hiện lại — nhạc trở lại.',
      );
    }
    _applyMusic();
  }

  @override
  void dispose() {
    unawaited(_noticeSub?.cancel());
    _noticeSub = null;
    final WebSocketNotifier? socket = _chatSocket;
    _chatSocket = null;
    if (socket != null) {
      final String room = VoltaRules.chatRoom;
      unawaited(Future<void>(() => socket.popChatRoom(room)));
    }
    _betClosedTimer?.cancel();
    _betClosedTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPhaseChanged(VoltaRoundPhase? previous, VoltaRoundPhase next) {
    if (previous != VoltaRoundPhase.betting) return;
    if (next != VoltaRoundPhase.playing && next != VoltaRoundPhase.settling) {
      return;
    }
    _betClosedTimer?.cancel();
    _betClosedTimer = Timer(VoltaRules.betClosedNoticeDelay, () {
      if (!mounted) return;
      VoltaFeedback.info(
        context,
        VoltaRules.betClosedNotice,
        duration: VoltaRules.betClosedNoticeDuration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VoltaMusicCue>(
      voltaStateProvider.select((VoltaState s) => s.musicCue),
      (_, VoltaMusicCue cue) => unawaited(VoltaMusic.instance.applyCue(cue)),
    );

    ref.listen<bool>(
      miniGameMenuOpenProvider,
      (_, bool open) => _setCovered(open || _hasExpandedGame()),
    );
    ref.listen<Set<MiniGameSelection>>(
      miniGameExpandedProvider,
      (_, Set<MiniGameSelection> games) =>
          _setCovered(games.isNotEmpty || ref.read(miniGameMenuOpenProvider)),
    );

    ref.listen<VoltaRoundPhase>(
      voltaStateProvider.select((VoltaState s) => s.phase),
      _onPhaseChanged,
    );
    return widget.child;
  }
}

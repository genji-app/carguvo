import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/mini_poker_state_provider.dart';
import 'package:sun_sports/mini/minipoker/state/minipoker_sub_view_provider.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_bet_history_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_guide_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_ranking_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_action_row.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_header.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_play_area.dart';

class MinipokerPanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const MinipokerPanel({
    required this.borderRadius,
    this.onClose,
    super.key,
  });

  static const double subViewHeight = 600;

  static const double panelHeight = _kLogoOverhang + _kInterfaceHeight;

  static const double logoOverflowTop = 27;

  static const double _kLogoOverhang = 40;

  static const double _kInterfaceHeight =
      56 + kMinipokerPlayAreaHeight + 150 + 2;

  Widget? _buildSubView(MinipokerSubView? sub, VoidCallback back) {
    switch (sub) {
      case null:
        return null;
      case MinipokerSubView.betHistory:
        return MinipokerBetHistoryView(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose ?? () {},
        );
      case MinipokerSubView.ranking:
        return MinipokerRankingView(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose ?? () {},
        );
      case MinipokerSubView.guide:
        return MinipokerGuideView(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose ?? () {},
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(minipokerSubViewProvider);
    void open(MinipokerSubView? v) =>
        ref.read(minipokerSubViewProvider.notifier).state = v;
    final sub = _buildSubView(current, () => open(null));
    if (sub != null) {
      return SizedBox(
        height: subViewHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: sub,
        ),
      );
    }
    return SizedBox(
      height: panelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _kLogoOverhang),
            child: MinipokerInterface(
              onClose: onClose,
              borderRadius: borderRadius,
              onGuide: () => open(MinipokerSubView.guide),
              onRanking: () => open(MinipokerSubView.ranking),
              onHistory: () => open(MinipokerSubView.betHistory),
            ),
          ),
          Positioned(
            top: -logoOverflowTop,
            left: 0,
            right: 0,
            child: Center(
              child: ImageHelper.load(
                path: MiniGameIcons.mpHeader,
                width: 200,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MinipokerInterface extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onGuide;
  final VoidCallback? onRanking;
  final VoidCallback? onHistory;
  final BorderRadius borderRadius;

  const MinipokerInterface({
    required this.borderRadius,
    this.onClose,
    this.onGuide,
    this.onRanking,
    this.onHistory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 30, right: 30),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColorStyles.backgroundQuaternary,
        border: Border.all(color: const Color(0xFF2A2826)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final jackpot =
                  ref.watch(miniPokerStateProvider.select((s) => s.jackpot));
              return MinipokerHeader(
                jackpot: jackpot,
                onClose: onClose,
                onGuide: onGuide,
                onRanking: onRanking,
                onHistory: onHistory,
              );
            },
          ),
          const MinipokerConnectedPlayArea(),
          const MinipokerActionRow(),
        ],
      ),
    );
  }
}

class MinipokerConnectedPlayArea extends ConsumerWidget {
  final double height;

  final bool showBrand;

  const MinipokerConnectedPlayArea({
    this.height = kMinipokerPlayAreaHeight,
    this.showBrand = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spinStartToken = ref.watch(
      miniPokerStateProvider.select((s) => s.spinStartToken),
    );
    final resultToken = ref.watch(
      miniPokerStateProvider.select((s) => s.resultToken),
    );
    final winToken = ref.watch(
      miniPokerStateProvider.select((s) => s.winToken),
    );
    final jackpotToken = ref.watch(
      miniPokerStateProvider.select((s) => s.jackpotToken),
    );
    final turbo = ref.watch(miniPokerStateProvider.select((s) => s.turbo));
    final isSpinning = ref.watch(
      miniPokerStateProvider.select((s) => s.isSpinning),
    );
    final st = ref.read(miniPokerStateProvider);
    return MinipokerPlayArea(
      entryCards: st.entryCards,
      resultCards: st.resultCards,
      turbo: turbo,
      spinStartToken: spinStartToken,
      resultToken: resultToken,
      winToken: winToken,
      winHand: st.winHand,
      winAmount: st.winAmount,
      roundInProgress: isSpinning,
      onRoundDone: () =>
          ref.read(miniPokerStateProvider.notifier).onRoundDone(),
      jackpotToken: jackpotToken,
      height: height,
      showBrand: showBrand,
    );
  }
}

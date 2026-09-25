import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/mini_game/presentation/state/mini_poker_state_provider.dart';
import 'package:sun_sports/mini/minipoker/state/minipoker_sub_view_provider.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_bet_history_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_guide_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_ranking_view.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_action_row.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_header.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_panel.dart';

const double kMinipokerLandscapeGameWidth = 338;
const double kMinipokerLandscapeGameHeight = 300;

const double kMinipokerLandscapeSubViewWidth = 477;
const double kMinipokerLandscapeSubViewHeight = 364;

const double _kHeaderHeight = 48;
const double _kPlayAreaHeight =
    kMinipokerLandscapeGameHeight - 2 - _kHeaderHeight - _kChipRowHeight -
        _kButtonRowHeight;
const double _kChipRowHeight = 60;
const double _kButtonRowHeight = 96;

class MinipokerLandscapePanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const MinipokerLandscapePanel({
    required this.borderRadius,
    this.onClose,
    super.key,
  });

  Widget? _buildSubView(MinipokerSubView? current, VoidCallback back) {
    switch (current) {
      case null:
        return null;
      case MinipokerSubView.betHistory:
        return MinipokerBetHistoryView(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose ?? () {},
          landscape: true,
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: sub != null
          ? SizedBox(
              width: kMinipokerLandscapeSubViewWidth,
              height: kMinipokerLandscapeSubViewHeight,
              child: sub,
            )
          : SizedBox(
              width: kMinipokerLandscapeGameWidth,
              height: kMinipokerLandscapeGameHeight,
              child: _Interface(
                onClose: onClose,
                borderRadius: borderRadius,
                onGuide: () => open(MinipokerSubView.guide),
                onRanking: () => open(MinipokerSubView.ranking),
                onHistory: () => open(MinipokerSubView.betHistory),
              ),
            ),
    );
  }
}

class _Interface extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onGuide;
  final VoidCallback? onRanking;
  final VoidCallback? onHistory;
  final BorderRadius borderRadius;

  const _Interface({
    required this.borderRadius,
    this.onClose,
    this.onGuide,
    this.onRanking,
    this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColorStyles.backgroundQuaternary,
        border: Border.all(color: const Color(0xFF2A2826)),
      ),
      child: Column(
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
                height: _kHeaderHeight,
                bannerWidth: 170,
              );
            },
          ),
          const MinipokerConnectedPlayArea(
            height: _kPlayAreaHeight,
            showBrand: false,
          ),
          const SizedBox(
            height: _kChipRowHeight,
            child: Center(
              child: MinipokerBetUnitRow(
                chipWidth: 80,
                chipHeight: 36,
                gap: 12,
              ),
            ),
          ),
          const SizedBox(
            height: _kButtonRowHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: MinipokerCircleButtonsRow(sideSize: 64, spinSize: 80),
            ),
          ),
        ],
      ),
    );
  }
}

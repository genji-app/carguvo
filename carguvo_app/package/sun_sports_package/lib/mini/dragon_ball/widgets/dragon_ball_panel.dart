import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/dragon_ball/state/dragon_ball_sub_view_provider.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_bet_history_view.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_guide_view.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_history_detail_view.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_ranking_view.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_action_row.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_header.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_play_area.dart';

class DragonBallPanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DragonBallPanel({required this.borderRadius, this.onClose, super.key});

  static const double subViewHeight = 600;

  static const double _kActionRowHeight = 174;

  static const double _kLogoOverhang = 40;

  static const double _kInterfaceHeight =
      56 + kDragonBallPlayAreaHeight + _kActionRowHeight + 2;

  static const double panelHeight = _kLogoOverhang + _kInterfaceHeight;

  Widget? _buildSubView(WidgetRef ref, DragonBallSubView current) {
    void open(DragonBallSubView v) =>
        ref.read(dragonBallSubViewProvider.notifier).state = v;
    void backToPlay() => open(DragonBallSubView.none);

    Widget history() => DragonBallBetHistoryView(
      borderRadius: borderRadius,
      onBack: backToPlay,
      onClose: onClose ?? () {},
      onItemTap: (item) {
        ref.read(dragonBallHistoryDetailItemProvider.notifier).state = item;
        open(DragonBallSubView.historyDetail);
      },
    );

    switch (current) {
      case DragonBallSubView.none:
        return null;
      case DragonBallSubView.history:
        return history();
      case DragonBallSubView.historyDetail:
        final item = ref.watch(dragonBallHistoryDetailItemProvider);
        if (item == null) return history();
        return DragonBallHistoryDetailView(
          item: item,
          borderRadius: borderRadius,
          onBack: () => open(DragonBallSubView.history),
          onClose: onClose ?? () {},
        );
      case DragonBallSubView.ranking:
        return DragonBallRankingView(
          borderRadius: borderRadius,
          onBack: backToPlay,
          onClose: onClose ?? () {},
        );
      case DragonBallSubView.guide:
        return DragonBallGuideView(
          borderRadius: borderRadius,
          onBack: backToPlay,
          onClose: onClose ?? () {},
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DragonBallState>(dragonBallStateProvider, (_, __) {});

    final current = ref.watch(dragonBallSubViewProvider);
    final sub = _buildSubView(ref, current);
    if (sub != null) {
      return SizedBox(
        height: DragonBallPanel.subViewHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: sub,
        ),
      );
    }
    return SizedBox(
      height: DragonBallPanel.panelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: DragonBallPanel._kLogoOverhang),
            child: _Interface(
              onClose: onClose,
              borderRadius: borderRadius,
              onGuide: () =>
                  ref.read(dragonBallSubViewProvider.notifier).state =
                      DragonBallSubView.guide,
              onRanking: () =>
                  ref.read(dragonBallSubViewProvider.notifier).state =
                      DragonBallSubView.ranking,
              onHistory: () =>
                  ref.read(dragonBallSubViewProvider.notifier).state =
                      DragonBallSubView.history,
            ),
          ),
          Positioned(
            top: -17,
            left: 0,
            right: 0,
            child: Center(
              child: ImageHelper.load(
                path: MiniGameIcons.dbHeaderBg,
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
              final jackpot = ref.watch(
                dragonBallStateProvider.select((s) => s.jackpot),
              );
              return DragonBallHeader(
                jackpot: jackpot,
                onClose: onClose,
                onGuide: onGuide,
                onRanking: onRanking,
                onHistory: onHistory,
              );
            },
          ),
          const DragonBallPlayArea(),
          const DragonBallActionRow(),
        ],
      ),
    );
  }
}

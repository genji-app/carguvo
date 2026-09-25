import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/dragon_ball/state/dragon_ball_sub_view_provider.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_play_area.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_bet_history_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_guide_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_history_detail_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_ranking_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/widgets/dragon_ball_landscape_action_column.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/widgets/dragon_ball_landscape_header.dart';

const double kDragonBallLandscapeDesignWidth = 578;
const double kDragonBallLandscapeDesignHeight = 364;

const double kDragonBallLandscapeSubViewWidth = 477;

const double _kInterfaceHeight = 285;

const double _kLogoWidth = 200;
const double _kLogoHeight = 80;
const double _kLogoOverhang = 40;

class DragonBallLandscapePanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DragonBallLandscapePanel({
    required this.borderRadius,
    this.onClose,
    super.key,
  });

  Widget? _buildSubView(WidgetRef ref, DragonBallSubView current) {
    void open(DragonBallSubView v) =>
        ref.read(dragonBallSubViewProvider.notifier).state = v;
    void backToPlay() => open(DragonBallSubView.none);

    Widget history() => DragonBallLandscapeBetHistoryView(
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
        return DragonBallLandscapeHistoryDetailView(
          item: item,
          borderRadius: borderRadius,
          onBack: () => open(DragonBallSubView.history),
          onClose: onClose ?? () {},
        );
      case DragonBallSubView.ranking:
        return DragonBallLandscapeRankingView(
          borderRadius: borderRadius,
          onBack: backToPlay,
          onClose: onClose ?? () {},
        );
      case DragonBallSubView.guide:
        return DragonBallLandscapeGuideView(
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: kDragonBallLandscapeDesignWidth,
        height: kDragonBallLandscapeDesignHeight,
        child: Center(
          child: sub != null
              ? SizedBox(
                  width: kDragonBallLandscapeSubViewWidth,
                  height: kDragonBallLandscapeDesignHeight,
                  child: sub,
                )
              : SizedBox(
                  width: kDragonBallLandscapeDesignWidth,
                  height: _kLogoOverhang + _kInterfaceHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: _kLogoOverhang),
                        child: _Interface(
                          onClose: onClose,
                          borderRadius: borderRadius,
                          onGuide: () =>
                              ref
                                      .read(dragonBallSubViewProvider.notifier)
                                      .state =
                                  DragonBallSubView.guide,
                          onRanking: () =>
                              ref
                                      .read(dragonBallSubViewProvider.notifier)
                                      .state =
                                  DragonBallSubView.ranking,
                          onHistory: () =>
                              ref
                                      .read(dragonBallSubViewProvider.notifier)
                                      .state =
                                  DragonBallSubView.history,
                        ),
                      ),
                      Positioned(
                        top: _kLogoOverhang - 57,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ImageHelper.load(
                            path: MiniGameIcons.dbHeaderBg,
                            width: _kLogoWidth,
                            height: _kLogoHeight,
                            fit: BoxFit.contain,
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
      height: _kInterfaceHeight,
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
              final jackpot = ref.watch(
                dragonBallStateProvider.select((s) => s.jackpot),
              );
              return DragonBallLandscapeHeader(
                jackpot: jackpot,
                onClose: onClose,
                onGuide: onGuide,
                onRanking: onRanking,
                onHistory: onHistory,
              );
            },
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DragonBallPlayArea(
                      height: null,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  SizedBox(
                    width: kDragonBallLandscapeActionWidth,
                    child: DragonBallLandscapeActionColumn(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

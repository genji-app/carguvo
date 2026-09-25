import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_sub_view_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_panel.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_guide.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_history.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_line_selection.dart';
import 'package:sun_sports/mini/diamond_landscape/diamond_landscape_rank.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_control_column.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_header.dart';

const double kDiamondLandscapeDesignWidth = 536;
const double kDiamondLandscapeDesignHeight = 364;

const double kDiamondLandscapeSubViewWidth = 477;

const double _kInterfaceHeight = 300;

const double _kReelBlockWidth = 268;

const double _kReelAspect = 244 / 236;

const double _kLogoWidth = 160;
const double _kLogoHeight = 69;
const double _kLogoOverlap = 14;

class DiamondLandscapePanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLandscapePanel({
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  Widget? _buildSubView(
    DiamondSubView current,
    VoidCallback back,
  ) {
    switch (current) {
      case DiamondSubView.none:
        return null;
      case DiamondSubView.lines:
        return DiamondLandscapeLineSelection(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.rank:
        return DiamondLandscapeRank(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.history:
        return DiamondLandscapeHistory(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.guide:
        return DiamondLandscapeGuide(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(diamondSubViewProvider);
    void open(DiamondSubView v) =>
        ref.read(diamondSubViewProvider.notifier).state = v;
    final sub = _buildSubView(current, () => open(DiamondSubView.none));
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: kDiamondLandscapeDesignWidth,
        height: kDiamondLandscapeDesignHeight,
        child: Center(
          child: sub != null
              ? SizedBox(
                  width: kDiamondLandscapeSubViewWidth,
                  height: kDiamondLandscapeDesignHeight,
                  child: sub,
                )
              : SizedBox(
                  width: kDiamondLandscapeDesignWidth,
                  height: _kInterfaceHeight + _kLogoHeight - _kLogoOverlap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: _kLogoHeight - _kLogoOverlap,
                        ),
                        child: _Interface(
                          borderRadius: borderRadius,
                          onClose: onClose,
                          onRank: () => open(DiamondSubView.rank),
                          onHistory: () => open(DiamondSubView.history),
                          onGuide: () => open(DiamondSubView.guide),
                          onLines: () => open(DiamondSubView.lines),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ImageHelper.load(
                            path: MiniGameIcons.diamondLogo,
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
  final BorderRadius borderRadius;
  final VoidCallback? onClose;
  final VoidCallback onRank;
  final VoidCallback onHistory;
  final VoidCallback onGuide;
  final VoidCallback onLines;

  const _Interface({
    required this.borderRadius,
    required this.onClose,
    required this.onRank,
    required this.onHistory,
    required this.onGuide,
    required this.onLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _kInterfaceHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [
          DiamondLandscapeHeader(
            onRank: onRank,
            onHistory: onHistory,
            onGuide: onGuide,
            onClose: onClose,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  width: _kReelBlockWidth,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Center(
                      child: DiamondReelsWithResult(
                        aspectRatio: _kReelAspect,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DiamondLandscapeControlColumn(onOpenLines: onLines),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

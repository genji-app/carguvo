import 'package:flutter/material.dart';

import '../common/volta_layout_spec.dart';
import '../common/widgets/volta_fit_box.dart';
import 'widgets/volta_bet_bar.dart';
import 'widgets/volta_bet_gates.dart';
import 'widgets/volta_md5_bar.dart';
import 'widgets/volta_stage.dart';
import 'widgets/volta_tab_bar.dart';
import 'widgets/volta_tab_content.dart';

class VoltaMobileLayout extends StatelessWidget {
  const VoltaMobileLayout({
    required this.onOpenBetHistory,
    required this.onOpenRanking,
    required this.onOpenGuide,
    super.key,
  });

  final VoidCallback onOpenBetHistory;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenGuide;

  static double fixedDesignHeight(VoltaLayoutSpec spec) =>
      spec.designHeight -
      spec.stageHeight -
      stageAspect * 2 * VoltaStage.horizontalPadding;

  static double designHeightAt(VoltaLayoutSpec spec, double width) =>
      fixedDesignHeight(spec) + stageAspect * width;

  @override
  Widget build(BuildContext context) {
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return VoltaFitBox(
      designHeight: fixedDesignHeight(spec),
      aspectBlockRatio: stageAspect,
      minScale: VoltaFitBox.noScroll,
      child: Column(
        children: <Widget>[
          const VoltaTabBar(),
          const VoltaTabContent(),
          SizedBox(height: spec.md5TopGap),
          VoltaMd5Bar(
            onOpenBetHistory: onOpenBetHistory,
            onOpenRanking: onOpenRanking,
            onOpenGuide: onOpenGuide,
          ),
          SizedBox(height: spec.md5ToStageGap),
          const VoltaStage(widthDriven: true),
          SizedBox(height: spec.stageToGatesGap),
          const VoltaBetGates(),
          const Spacer(),
          const VoltaBetBar(),
        ],
      ),
    );
  }
}

const double stageAspect = 9 / 16;

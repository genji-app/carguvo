import 'package:flutter/material.dart';

import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/widgets/authenticated_widget.dart';
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';

import '../common/volta_layout_spec.dart';
import '../common/widgets/volta_fit_box.dart';
import 'widgets/volta_bet_bar.dart';
import 'widgets/volta_bet_gates.dart';
import 'widgets/volta_md5_bar.dart';
import 'widgets/volta_stage.dart';
import 'widgets/volta_tab_bar.dart';
import 'widgets/volta_tab_content.dart';

class VoltaTabletLayout extends StatelessWidget {
  const VoltaTabletLayout({
    required this.onOpenBetHistory,
    required this.onOpenRanking,
    required this.onOpenGuide,
    super.key,
  });

  final VoidCallback onOpenBetHistory;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenGuide;

  static const double _chatInsetY = 17;

  @override
  Widget build(BuildContext context) {
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return VoltaFitBox(
      designHeight: spec.designHeight,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: spec.topBlockHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: _chatInsetY),
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7),
                          child: VoltaTabBar(),
                        ),
                        const VoltaTabContent(tablet: true),
                        VoltaMd5Bar(
                          onOpenBetHistory: onOpenBetHistory,
                          onOpenRanking: onOpenRanking,
                          onOpenGuide: onOpenGuide,
                        ),
                        if (spec.md5ToStageGap > 0)
                          SizedBox(height: spec.md5ToStageGap),
                        const Expanded(child: VoltaStage()),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    _chatInsetY,
                    spec.gutter,
                    _chatInsetY,
                  ),
                  child: SizedBox(
                    width: spec.chatColumnWidth,
                    child: const AuthenticatedWidget(
                      fallback: ChatLoginOverlay(),
                      child: SportLiveChat(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VoltaBetGates(),
          const VoltaBetBar(),
        ],
      ),
    );
  }
}

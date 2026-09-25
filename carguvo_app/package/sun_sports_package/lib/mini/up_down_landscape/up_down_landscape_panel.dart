import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/state/up_down_sub_view_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_card_history.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_interface_actions.dart';
import 'package:sun_sports/mini/up_down_landscape/up_down_landscape_bet_history.dart';
import 'package:sun_sports/mini/up_down_landscape/up_down_landscape_guide.dart';
import 'package:sun_sports/mini/up_down_landscape/up_down_landscape_rank.dart';
import 'package:sun_sports/mini/up_down_landscape/widgets/up_down_landscape_action_column.dart';
import 'package:sun_sports/mini/up_down_landscape/widgets/up_down_landscape_header.dart';
import 'package:sun_sports/mini/up_down_landscape/widgets/up_down_landscape_play_area.dart';

const double kUpDownLandscapeDesignWidth = 546;
const double kUpDownLandscapeDesignHeight = 364;

const double kUpDownLandscapeSubViewWidth = 477;

const double _kInterfaceHeight = 300;

const double _kLogoWidth = 142;
const double _kLogoHeight = 64;
const double _kLogoOverlap = 11;

class UpDownLandscapePanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownLandscapePanel({
    required this.borderRadius,
    this.onClose,
    super.key,
  });

  Widget? _buildSubView(UpDownSubView current, VoidCallback back) {
    switch (current) {
      case UpDownSubView.none:
        return null;
      case UpDownSubView.guide:
        return UpDownLandscapeGuide(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case UpDownSubView.rank:
        return UpDownLandscapeRank(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case UpDownSubView.history:
        return UpDownLandscapeBetHistory(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(upDownSubViewProvider);
    void open(UpDownSubView v) =>
        ref.read(upDownSubViewProvider.notifier).state = v;
    final sub = _buildSubView(current, () => open(UpDownSubView.none));
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: kUpDownLandscapeDesignWidth,
        height: kUpDownLandscapeDesignHeight,
        child: Center(
          child: sub != null
              ? SizedBox(
                  width: kUpDownLandscapeSubViewWidth,
                  height: kUpDownLandscapeDesignHeight,
                  child: sub,
                )
              : SizedBox(
                  width: kUpDownLandscapeDesignWidth,
                  height: _kInterfaceHeight + _kLogoHeight - _kLogoOverlap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: _kLogoHeight - _kLogoOverlap,
                        ),
                        child: _Interface(
                          onClose: onClose,
                          borderRadius: borderRadius,
                          onHelp: () => open(UpDownSubView.guide),
                          onRank: () => open(UpDownSubView.rank),
                          onHistory: () => open(UpDownSubView.history),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ImageHelper.load(
                            path: MiniGameIcons.upDownTitle,
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

class _Interface extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onHelp;
  final VoidCallback? onRank;
  final VoidCallback? onHistory;
  final BorderRadius borderRadius;

  const _Interface({
    required this.borderRadius,
    this.onClose,
    this.onHelp,
    this.onRank,
    this.onHistory,
  });

  @override
  ConsumerState<_Interface> createState() => _InterfaceState();
}

class _InterfaceState extends ConsumerState<_Interface>
    with UpDownInterfaceActions {
  @override
  Widget build(BuildContext context) {
    final showBet = ref.watch(
      upDownStateProvider.select((s) => s.spinning || s.sessionId != 0),
    );
    final selectedBet =
        ref.watch(upDownStateProvider.select((s) => s.selectedBet));
    final betIndex = betIndexOf(selectedBet);
    return Container(
      width: double.infinity,
      height: _kInterfaceHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: AppColorStyles.backgroundQuaternary,
        border: Border.all(color: const Color(0xFF2A2826)),
      ),
      child: Column(
        children: [
          UpDownLandscapeHeader(
            onClose: widget.onClose,
            onHelp: widget.onHelp,
            onRank: widget.onRank,
            onHistory: widget.onHistory,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: UpDownLandscapePlayArea(
                    selectedBetIndex: betIndex,
                    onSelectBet: selectBet,
                  ),
                ),
                SizedBox(
                  width: kUpDownLandscapeActionWidth,
                  child: showBet
                      ? UpDownLandscapeBetColumn(
                          cashoutKey: cashoutKey,
                          onNewRound: cashout,
                          onPickUp: pickUp,
                          onPickDown: pickDown,
                        )
                      : UpDownLandscapeStartColumn(
                          onStart: start,
                          canStart: canStart,
                        ),
                ),
              ],
            ),
          ),
          const UpDownCardHistoryBar(),
        ],
      ),
    );
  }
}

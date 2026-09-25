import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/state/up_down_sub_view_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_bet_area.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_card_history.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_header.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_interface_actions.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_play_area.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_start_area.dart';
import 'package:sun_sports/mini/up_down/up_down_guide.dart';
import 'package:sun_sports/mini/up_down/up_down_rank.dart';
import 'package:sun_sports/mini/up_down/up_down_bet_history.dart';

export 'package:sun_sports/mini/up_down/widgets/up_down_interface_actions.dart'
    show kUpDownBetValues;

class UpDownPanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownPanel({required this.borderRadius, this.onClose, super.key});

  static const double _kPanelHeight = 565;

  double _subViewHeight(UpDownSubView sub) {
    switch (sub) {
      case UpDownSubView.rank:
        return UpDownRank.kPanelHeight;
      case UpDownSubView.history:
        return UpDownBetHistory.kPanelHeight;
      case UpDownSubView.guide:
      case UpDownSubView.none:
        return _kPanelHeight;
    }
  }

  Widget? _buildSubView(UpDownSubView current, VoidCallback back) {
    switch (current) {
      case UpDownSubView.none:
        return null;
      case UpDownSubView.guide:
        return UpDownGuide(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case UpDownSubView.rank:
        return UpDownRank(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case UpDownSubView.history:
        return UpDownBetHistory(
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
    if (sub != null) {
      return SizedBox(
        height: _subViewHeight(current),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: sub,
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 67),
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
              width: 177,
              height: 79,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
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
      margin: const EdgeInsets.only(left: 30, right: 30),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: AppColorStyles.backgroundQuaternary,
        border: Border.all(color: const Color(0xFF2A2826)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UpDownHeader(
            onClose: widget.onClose,
            onHelp: widget.onHelp,
            onRank: widget.onRank,
            onHistory: widget.onHistory,
          ),
          UpDownPlayArea(
            selectedBetIndex: betIndex,
            onSelectBet: selectBet,
          ),
          if (!showBet) ...[
            const UpDownHintBar(),
            UpDownStartArea(onStart: start, canStart: canStart),
          ] else ...[
            const UpDownCardHistoryBar(),
            UpDownBetArea(
              cashoutKey: cashoutKey,
              onNewRound: cashout,
              onPickUp: pickUp,
              onPickDown: pickDown,
            ),
          ],
        ],
      ),
    );
  }
}

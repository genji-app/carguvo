import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/dashed_divider_widget.dart';
import 'package:sun_sports/shared/widgets/divider/divider.dart';

import '../bet_slip_match_navigation.dart';
import '../bet_slip_ui_extensions.dart';
import 'bet_slip_card_footer.dart';
import 'bet_slip_card_match.dart';
import 'bet_slip_card_match_stats.dart';
import 'bet_slip_card_outright_match.dart';
import 'bet_slip_card_payment_footer.dart';
import 'bet_slip_card_status_badge.dart';

export 'bet_slip_card.dart';
export 'bet_slip_card_footer.dart';
export 'bet_slip_card_match.dart';
export 'bet_slip_card_match_stats.dart';
export 'bet_slip_card_outright_match.dart';
export 'bet_slip_card_payment_footer.dart';
export 'bet_slip_card_status_badge.dart';

class BetSlipCard extends ConsumerWidget {
  const BetSlipCard({
    required this.bet,
    super.key,
    this.onPressed,
    this.actionButton,
  });

  const BetSlipCard.details(
    this.bet, {
    super.key,
    this.onPressed,
    this.actionButton,
  });

  final BetSlip bet;
  final VoidCallback? onPressed;

  final Widget? actionButton;

  int? _statsEventId(int? summaryEventId) =>
      bet.isSettled ? summaryEventId : null;

  Widget _buildSingleMatchContent() {
    if (bet.isOutright) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 406 / 44,
              child: ImageHelper.load(
                path: AppIcons.ticketOutrightHeader,
                fit: BoxFit.fill,
              ),
            ),
          ),
          BetSlipCardOutrightMatch(bet: bet),
        ],
      );
    }
    return BetSlipCardMatchWithStats(
      betData: BetCardMatchData.fromBetSlip(bet),
      hintData: bet.toHintData(),
      summaryEventId: _statsEventId(bet.summaryEventId),
    );
  }

  Widget _buildComboMatchContent() {
    final legs = <({DateTime startDate, Widget widget})>[
      (
        startDate: bet.startDate,
        widget: BetSlipCardMatchWithStats(
          betData: BetCardMatchData.fromBetSlip(bet, asComboLeg: true),
          hintData: bet.toHintData(),
          summaryEventId: _statsEventId(bet.summaryEventId),
          showSportIcon: true,
        ),
      ),
      for (final childBet in bet.childBets)
        (
          startDate: childBet.startDate,
          widget: BetSlipCardMatchWithStats(
            betData: BetCardMatchData.fromChildBet(childBet),
            hintData: childBet.toHintData(),
            summaryEventId: _statsEventId(childBet.summaryEventId),
            showSportIcon: true,
          ),
        ),
    ]..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Column(
      children: [
        for (var i = 0; i < legs.length; i++) ...[
          if (i > 0) const _DashDivider(),
          legs[i].widget,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchContent = bet.isComboBet
        ? _buildComboMatchContent()
        : _buildSingleMatchContent();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColorStyles.backgroundQuaternary,
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: SoundTap.wrap(onPressed),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (bet.isComboBet) _ParlayHeader(bet: bet),

            matchContent,

            const SunDivider(),
            const Gap(8),
            BetSlipCardPaymentFooter(
              stakeAmount: bet.totalStake,
              payoutAmount: bet.totalWinning,
              isSettled: bet.isSettled,
              isDeclined:
                  bet.settlementStatusEnum == SettlementStatusEnum.declined,
            ),

            if (actionButton != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: actionButton,
              ),

            BetSlipCardFooter(
              betTime: bet.betTime,
              sport: bet.sport,
              onViewMatchTap: bet.canViewMatch
                  ? () => openMatchDetailFromBetSlip(ref, bet)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParlayHeader extends StatelessWidget {
  const _ParlayHeader({required this.bet});

  final BetSlip bet;

  @override
  Widget build(BuildContext context) {
    final legCount = 1 + bet.childBets.length;
    final combinedOdds = bet.comboOddsValue;
    final status = bet.settlementStatusEnum;

    return Stack(
      children: [
        Positioned.fill(
          child: ImageHelper.load(
            path: AppIcons.betslipComboHeader,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                'Xiên $legCount',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
              const Gap(8),
              if (combinedOdds > 0)
                Text(
                  combinedOdds.toStringAsFixed(2),
                  style: AppTextStyles.labelMedium(
                    color: const Color(0xFFACDC79),
                  ),
                ),
              const Spacer(),
              if (status.isSettled)
                BetSlipCardStatusBadge(status, isParlay: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashDivider extends StatelessWidget {
  const _DashDivider();

  @override
  Widget build(BuildContext context) {
    return const DashedDivider.horizontal(
      height: 20,
      thickness: 4,
      dashGap: 6,
      color: AppColorStyles.backgroundTertiary,
    );
  }
}

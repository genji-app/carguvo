import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';

import 'bet_slip_card_match.dart';
import 'bet_slip_card_selection.dart';

class BetSlipCardOutrightMatch extends StatelessWidget {
  const BetSlipCardOutrightMatch({required this.bet, super.key});

  final BetSlip bet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BetSlipLegHeader(
          marketName: _outrightTypeLabel(bet.cls),
          selectionSpans: [
            TextSpan(
              text: BetSlipSelectionText.translate(
                bet.oddsName,
                bet.homeName ?? '',
                bet.awayName ?? '',
              ),
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ],
          displayOdds: bet.displayOdds,
          settlementStatus: bet.settlementStatusEnum,
          hintData: bet.toHintData(),
          tooltipTitle: _outrightTypeLabel(bet.cls),
        ),
        _buildLeagueRow(),
        const Gap(12),
      ],
    );
  }

  Widget _buildLeagueRow() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildSportIcon(bet.sport ?? SportType.soccer),
          const Gap(4),
          Expanded(
            child: Text(
              bet.leagueName,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  static String _outrightTypeLabel(String? cls) {
    final name = cls?.trim() ?? '';
    return name.isNotEmpty ? name : 'Đội vô địch';
  }

  Widget _buildSportIcon(SportType sport) {
    final path = switch (sport) {
      SportType.soccer => AppIcons.iconFootballSelected,
      SportType.basketball => AppIcons.iconBasketballSelected,
      SportType.tennis => AppIcons.iconTennisSelected,
      SportType.volleyball => AppIcons.iconVolleyballSelected,
      SportType.tableTennis => AppIcons.iconTableTennisSelected,
      SportType.badminton => AppIcons.iconBadmintonSelected,
      _ => AppIcons.iconFootballSelected,
    };
    return SizedBox.square(
      dimension: 20,
      child: ImageHelper.load(
        path: path,
        color: AppColorStyles.contentSecondary,
      ),
    );
  }
}

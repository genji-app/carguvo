import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success_footer.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/combo_success_ticket_item.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_header.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ComboBetSuccessData {
  final List<SingleBetData> selections;
  final double totalOdds;
  final int stake;
  final double potentialWin;

  const ComboBetSuccessData({
    required this.selections,
    required this.totalOdds,
    required this.stake,
    required this.potentialWin,
  });
}

class ComboSuccessView extends StatelessWidget {
  final ComboBetSuccessData comboBetData;
  final VoidCallback onClose;
  final VoidCallback onViewMyBets;
  final VoidCallback? onReuseBet;
  final VoidCallback? onClearAll;

  const ComboSuccessView({
    super.key,
    required this.comboBetData,
    required this.onClose,
    required this.onViewMyBets,
    this.onReuseBet,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: _buildContent()),
      BetSuccessFooter(
        onViewMyBets: onViewMyBets,
      ),
    ],
  );

  Widget _buildActionBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: SoundTap.wrap(onReuseBet),
            child: Text(
              'Dùng lại phiếu',
              style:
                  AppTextStyles.labelSmall(
                    color: AppColorStyles.contentPrimary,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColorStyles.contentPrimary,
                  ),
            ),
          ),
        ),
        GestureDetector(
          onTap: SoundTap.wrap(onClearAll),
          child: Text(
            'Xóa hết',
            style:
                AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColorStyles.contentPrimary,
                ),
          ),
        ),
      ],
    ),
  );

  Widget _buildContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        ComboSuccessTicketItem(
          selections: comboBetData.selections,
          totalOdds: comboBetData.totalOdds,
          stake: comboBetData.stake,
          potentialWin: comboBetData.potentialWin,
        ),
        const Gap(32),
      ],
    ),
  );
}

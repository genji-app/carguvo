import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success_footer.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success_ticket_item.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_header.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetSuccessView extends StatelessWidget {
  final List<SingleBetData> successfulBets;
  final VoidCallback onClose;
  final VoidCallback onViewMyBets;
  final void Function(int index)? onRemoveBet;
  final VoidCallback? onReuseBets;
  final VoidCallback? onClearAll;

  const BetSuccessView({
    super.key,
    required this.successfulBets,
    required this.onClose,
    required this.onViewMyBets,
    this.onRemoveBet,
    this.onReuseBets,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: _buildTicketsList()),
      SafeArea(
        bottom: true,
        child: BetSuccessFooter(
          onViewMyBets: onViewMyBets,
        ),
      ),
    ],
  );

  Widget _buildActionBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: SoundTap.wrap(onReuseBets),
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

  Widget _buildTicketsList() => SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        ...successfulBets.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < successfulBets.length - 1 ? 12 : 0,
            ),
            child: BetSuccessTicketItem(
              bet: entry.value,
              onRemove: onRemoveBet != null
                  ? () => onRemoveBet!(entry.key)
                  : null,
            ),
          ),
        ),
        const Gap(32),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BetSuccessTicketItem extends StatelessWidget {
  final SingleBetData bet;
  final VoidCallback? onRemove;

  const BetSuccessTicketItem({required this.bet, super.key, this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [_buildHeader(), _buildMarketInfo(), _buildTotals()],
    ),
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuccessIcon(),
              const Gap(4),
              Expanded(
                child: Text(
                  '${bet.homeName} ${bet.eventData.homeScore} - ${bet.eventData.awayScore} ${bet.awayName}',
                  style: AppTextStyles.labelSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null)
          GestureDetector(
            onTap: SoundTap.wrap(onRemove),
            child: Icon(
              Icons.close,
              size: 20,
              color: AppColorStyles.contentSecondary,
            ),
          ),
      ],
    ),
  );

  Widget _buildSuccessIcon() => Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: const Icon(Icons.check_circle, size: 20, color: AppColors.green400),
  );

  Widget _buildMarketInfo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: AppColorStyles.backgroundQuaternary,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bet.marketName,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
              const Gap(4),
              Text(
                bet.displayName,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Gap(8),
            Text(
              bet.displayOddsString,
              style: AppTextStyles.labelMedium(color: AppColors.yellow300),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTotals() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    color: AppColorStyles.backgroundQuaternary,
    child: Row(
      children: [
        Expanded(
          child: _buildTotalColumn(
            label: 'Tổng cược',
            value: bet.stake.toDouble(),
            alignment: CrossAxisAlignment.start,
            alignmentRow: MainAxisAlignment.start
          ),
        ),
        Expanded(
          child: _buildTotalColumn(
            label: 'Thanh toán dự kiến',
            value: bet.potentialWinnings,
            alignment: CrossAxisAlignment.end,
            alignmentRow: MainAxisAlignment.end
          ),
        ),
      ],
    ),
  );

  Widget _buildTotalColumn({
    required String label,
    required double value,
    required CrossAxisAlignment alignment,
    required MainAxisAlignment alignmentRow
  }) => Column(
    crossAxisAlignment: alignment,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentSecondary),
      ),
      const Gap(4),
      Row(
        mainAxisAlignment: alignmentRow,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentSecondary,
              ),
              children: [TextSpan(text: _formatCurrency(value))],
            ),
          ),
          const SCoinIcon(),
        ],
      ),
    ],
  );

  String _formatCurrency(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

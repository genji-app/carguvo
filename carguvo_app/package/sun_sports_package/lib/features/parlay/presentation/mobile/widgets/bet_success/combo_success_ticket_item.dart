import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class ComboSuccessTicketItem extends StatelessWidget {
  final List<SingleBetData> selections;
  final double totalOdds;
  final int stake;
  final double potentialWin;

  const ComboSuccessTicketItem({
    super.key,
    required this.selections,
    required this.totalOdds,
    required this.stake,
    required this.potentialWin,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSummaryCard(),
        for (var i = 0; i < selections.length; i++)
          _ComboLegTileSuccess(bet: selections[i]),
        _buildBottomPadding(),
      ],
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        const Icon(Icons.check, size: 20, color: AppColors.green400),
        const Gap(8),
        Expanded(
          child: Row(
            children: [
              ImageHelper.load(
                path: AppIcons.iconParlay,
                width: 20,
                height: 20,
                color: AppColorStyles.contentSecondary,
              ),
              const Gap(4),
              Text(
                'Xiên ${selections.length} chân',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSummaryCard() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
    ),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tổng tỷ lệ',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            Text(
              totalOdds.toStringAsFixed(2),
              style: AppTextStyles.labelMedium(color: const Color(0xFFFDE272)),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildTotalColumn(
                label: 'Tổng cược',
                value: stake.toDouble(),
                alignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
            Expanded(
              child: _buildTotalColumn(
                label: 'Thanh toán dự kiến',
                value: potentialWin,
                alignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTotalColumn({
    required String label,
    required double value,
    required CrossAxisAlignment alignment,
    required MainAxisAlignment mainAxisAlignment,
  }) => Column(
    crossAxisAlignment: alignment,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentSecondary),
      ),
      const Gap(4),
      Row(
        mainAxisAlignment: mainAxisAlignment,
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

  Widget _buildBottomPadding() => Container(
    width: double.infinity,
    height: 12,
    decoration: const BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
    ),
  );

  String _formatCurrency(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _ComboLegTileSuccess extends StatelessWidget {
  final SingleBetData bet;

  const _ComboLegTileSuccess({required this.bet});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColorStyles.backgroundQuaternary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        _buildDivider(),
        const Gap(12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox.square(
                    dimension: 18,
                    child: ImageHelper.load(
                      path: SportType.fromId(bet.sportId)?.iconPath ?? '',
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      '${bet.eventData.homeName} - ${bet.eventData.awayName}',
                      style: AppTextStyles.paragraphSmall(
                        color: AppColorStyles.contentTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColorStyles.backgroundTertiary,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bet.marketName,
                            style: AppTextStyles.labelSmall(
                              color: AppColorStyles.contentTertiary,
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
                      children: [
                        ImageHelper.load(
                          path: AppIcons.iconInfo,
                          width: 18,
                          height: 18,
                          color: AppColorStyles.contentSecondary,
                        ),
                        const Gap(6),
                        Text(
                          bet.displayOddsString,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.green300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SuccessDot extends StatelessWidget {
  static const _successColor = AppColors.green400;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _successColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDivider() => Container(
  width: double.infinity,
  height: 1,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(0.06),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  ),
);

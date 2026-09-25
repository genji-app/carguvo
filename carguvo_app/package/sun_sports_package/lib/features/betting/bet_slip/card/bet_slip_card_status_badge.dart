import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/features/betting/betting.dart';

class BetSlipCardStatusBadge extends StatelessWidget {
  const BetSlipCardStatusBadge(this.status, {super.key, this.isParlay = false});

  final SettlementStatusEnum status;

  final bool isParlay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      color: status.color,
    ),
    child: Text(
      isParlay ? status.parlayLabel : status.label,
      style: AppTextStyles.labelXSmall(
        color: AppColors.gray950,
      ).copyWith(fontWeight: FontWeight.w600, height: 1.50),
    ),
  );
}

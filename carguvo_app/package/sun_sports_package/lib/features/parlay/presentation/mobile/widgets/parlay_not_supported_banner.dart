import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class ParlayNotSupportedBanner extends StatelessWidget {
  const ParlayNotSupportedBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x1FEF6820),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.orange500, size: 24),
        const Gap(12),
        Expanded(
          child: Text(
            'Vé này không hỗ trợ cược xiên',
            style: AppTextStyles.labelMedium(color: AppColors.orange200),
          ),
        ),
      ],
    ),
  );
}

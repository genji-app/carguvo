import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.message,
    this.minHeight = 320,
  });

  final String message;

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacingStyles.space600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_rounded,
                size: 48,
                color: AppColorStyles.contentQuaternary,
              ),
              const Gap(AppSpacingStyles.space300),
              Text(
                message,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class GameFilterEmptyState extends StatelessWidget {
  const GameFilterEmptyState({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveBuilder.isMobile(context)
              ? AppSpacingStyles.space600
              : AppSpacingStyles.space1600,
        );

    return Padding(
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 186),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacingStyles.space400,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(height: 178),
                child: ImageHelper.load(
                  path: AppImages.imgGameNotFound,
                  fit: BoxFit.contain,
                ),
              ),

              Text(
                I18n.msgNoResultFound,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

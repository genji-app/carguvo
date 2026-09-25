import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/animations/animations.dart';

class InfoMessage extends StatelessWidget {
  const InfoMessage({
    super.key,
    this.image,
    this.primaryMessage,
    this.secondaryMessage,
  }) : assert(primaryMessage != null || secondaryMessage != null);

  final Widget? image;
  final Widget? primaryMessage;
  final Widget? secondaryMessage;

  @override
  Widget build(BuildContext context) {
    return ImmediateOpacityAnimation(
      duration: Durations.short4,
      child: Container(
        alignment: AlignmentDirectional.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[image!, const Gap(8)],
            if (primaryMessage != null)
              DefaultTextStyle(
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                textAlign: TextAlign.center,
                child: primaryMessage!,
              ),
            if (primaryMessage != null && secondaryMessage != null)
              const Gap(8),
            if (secondaryMessage != null)
              DefaultTextStyle(
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentSecondary,
                ),
                textAlign: TextAlign.center,
                child: secondaryMessage!,
              ),
          ],
        ),
      ),
    );
  }
}

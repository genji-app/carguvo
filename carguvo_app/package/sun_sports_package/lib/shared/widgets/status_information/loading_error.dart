import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/animations/animations.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

class LoadingError extends StatelessWidget {
  const LoadingError({
    required this.message,
    this.onRetry,
    this.onChangeFilter,
    super.key,
  });

  final Widget message;
  final VoidCallback? onRetry;
  final VoidCallback? onChangeFilter;

  @override
  Widget build(BuildContext context) {
    return ImmediateOpacityAnimation(
      duration: Durations.medium1,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: AlignmentDirectional.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
              textAlign: TextAlign.center,
              child: message,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SecondaryButton.yellow(
                size: SecondaryButtonSize.xl,
                onPressed: onRetry,
                label: const Text('Retry'),
              ),
            ],
            if (onChangeFilter != null) ...[
              const SizedBox(height: 16),
              SecondaryButton.yellow(
                size: SecondaryButtonSize.xl,
                onPressed: onChangeFilter,
                label: const Text('Change filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

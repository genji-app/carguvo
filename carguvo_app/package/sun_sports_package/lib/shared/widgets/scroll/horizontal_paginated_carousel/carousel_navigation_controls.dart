part of 'horizontal_paginated_carousel.dart';

class _CarouselNavigationControls extends StatelessWidget {
  const _CarouselNavigationControls({
    this.onPreviousPage,
    this.onNextPage,
    this.buttonColor,
    this.disabledButtonColor,
    this.iconColor,
    this.disabledIconColor,
  });

  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final Color? buttonColor;
  final Color? disabledButtonColor;
  final Color? iconColor;
  final Color? disabledIconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: [
        _CarouselNavigationButton(
          direction: TextDirection.rtl,
          onPressed: onPreviousPage,
          buttonColor: buttonColor,
          disabledButtonColor: disabledButtonColor,
          iconColor: iconColor,
          disabledIconColor: disabledIconColor,
        ),
        _CarouselNavigationButton(
          direction: TextDirection.ltr,
          onPressed: onNextPage,
          buttonColor: buttonColor,
          disabledButtonColor: disabledButtonColor,
          iconColor: iconColor,
          disabledIconColor: disabledIconColor,
        ),
      ],
    );
  }
}

class _CarouselNavigationButton extends StatelessWidget {
  const _CarouselNavigationButton({
    required this.direction,
    this.onPressed,
    this.buttonColor,
    this.disabledButtonColor,
    this.iconColor,
    this.disabledIconColor,
  });

  final TextDirection direction;
  final VoidCallback? onPressed;
  final Color? buttonColor;
  final Color? disabledButtonColor;
  final Color? iconColor;
  final Color? disabledIconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackButtonColor =
        buttonColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final fallbackDisabledButtonColor =
        disabledButtonColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2);
    final fallbackIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final fallbackDisabledIconColor =
        disabledIconColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Directionality(
      textDirection: direction,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: fallbackButtonColor,
          disabledBackgroundColor: fallbackDisabledButtonColor,
          foregroundColor: fallbackIconColor,
          disabledForegroundColor: fallbackDisabledIconColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadiusDirectional.horizontal(
              end: Radius.circular(12),
            ).resolve(direction),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size.square(32),
          padding: EdgeInsets.zero,
          iconSize: 20,
        ),
        icon: const Icon(Icons.chevron_right),
      ),
    );
  }
}

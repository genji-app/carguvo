part of 'horizontal_paginated_carousel.dart';

class _CarouselHeader extends StatelessWidget {
  const _CarouselHeader({
    required this.title,
    required this.titleStyle,
    required this.actionWidget,
    required this.showNavigationButtons,
    required this.showNavigationControls,
    required this.currentPageNotifier,
    required this.itemCount,
    required this.columns,
    required this.onPreviousPage,
    required this.onNextPage,
    this.navigationButtonColor,
    this.navigationButtonDisabledColor,
    this.navigationIconColor,
    this.navigationIconDisabledColor,
  });

  final Widget? title;
  final TextStyle? titleStyle;
  final Widget? actionWidget;
  final bool showNavigationButtons;
  final bool showNavigationControls;
  final ValueNotifier<int> currentPageNotifier;
  final int itemCount;
  final double columns;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Color? navigationButtonColor;
  final Color? navigationButtonDisabledColor;
  final Color? navigationIconColor;
  final Color? navigationIconDisabledColor;

  bool _canGoNext(int currentPage, int itemCount, double columns) {
    return currentPage < itemCount - columns;
  }

  bool _canGoPrev(int currentPage) {
    return currentPage > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 12),
          if (title != null)
            DefaultTextStyle(
              style:
                  titleStyle ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(color: Colors.white),
              child: title!,
            ),
          if (title != null && actionWidget != null) const SizedBox(width: 8),
          if (actionWidget != null) actionWidget!,
          const Spacer(),
          if (showNavigationButtons && showNavigationControls)
            ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, _) {
                return _CarouselNavigationControls(
                  buttonColor: navigationButtonColor,
                  disabledButtonColor: navigationButtonDisabledColor,
                  iconColor: navigationIconColor,
                  disabledIconColor: navigationIconDisabledColor,
                  onNextPage: _canGoNext(currentPage, itemCount, columns)
                      ? onNextPage
                      : null,
                  onPreviousPage: _canGoPrev(currentPage)
                      ? onPreviousPage
                      : null,
                );
              },
            ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

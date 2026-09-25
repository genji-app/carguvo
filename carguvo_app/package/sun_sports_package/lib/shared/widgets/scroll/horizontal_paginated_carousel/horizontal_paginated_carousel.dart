// ignore_for_file: unnecessary_library_name

library horizontal_paginated_carousel;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../axis_lock_horizontal_scroll.dart';
import 'carousel_interaction_strategy.dart';
import 'carousel_navigation_mixin.dart';

part 'carousel_header.dart';
part 'carousel_list_view.dart';
part 'carousel_navigation_controls.dart';

class HorizontalPaginatedCarousel extends StatefulWidget {
  const HorizontalPaginatedCarousel({
    required this.itemCount,
    required this.itemBuilder,
    required this.columnsBuilder,
    required this.heightBuilder,
    required this.horizontalPadding,
    required this.itemSpacing,
    required this.hasMouse,
    super.key,
    this.itemBuilderWithWidth,
    this.title,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.cardBorderRadius = 12.0,
    this.actionWidget,
    this.enablePeek = false,
    this.titleStyle,
    this.navigationButtonColor,
    this.navigationButtonDisabledColor,
    this.navigationIconColor,
    this.navigationIconDisabledColor,
    this.showNavigationButtons = true,
  });

  final bool hasMouse;

  final Widget? title;

  final TextStyle? titleStyle;

  final int itemCount;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final Widget Function(BuildContext context, int index, double cardWidth)?
  itemBuilderWithWidth;

  final int Function(double availableWidth) columnsBuilder;

  final double Function(double cardWidth) heightBuilder;

  final Widget? actionWidget;

  final Color backgroundColor;

  final double cardBorderRadius;

  final double horizontalPadding;

  final double itemSpacing;

  final bool enablePeek;

  final Color? navigationButtonColor;

  final Color? navigationButtonDisabledColor;

  final Color? navigationIconColor;

  final Color? navigationIconDisabledColor;

  final bool showNavigationButtons;

  @override
  State<HorizontalPaginatedCarousel> createState() =>
      _HorizontalPaginatedCarouselState();
}

class _HorizontalPaginatedCarouselState
    extends State<HorizontalPaginatedCarousel>
    with CarouselNavigationMixin {
  late final ScrollController _scrollController;
  double _cachedItemFullWidth = 0.0;

  bool _cacheValid = false;
  double _cachedWidth = double.negativeInfinity;
  Widget? _cachedColumn;

  final ScrollGestureAxisLock _wheelAxisLock = ScrollGestureAxisLock();

  CarouselInteractionStrategy get _strategy => widget.hasMouse
      ? const PointerDrivenCarouselStrategy()
      : const GestureDrivenCarouselStrategy();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(HorizontalPaginatedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.itemBuilder != widget.itemBuilder ||
        oldWidget.itemBuilderWithWidth != widget.itemBuilderWithWidth ||
        oldWidget.title != widget.title ||
        oldWidget.columnsBuilder != widget.columnsBuilder ||
        oldWidget.heightBuilder != widget.heightBuilder) {
      _cacheValid = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    currentPageNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    handleScroll(
      _scrollController.offset,
      _cachedItemFullWidth,
      widget.itemCount,
    );
  }

  void _goToPreviousPage() {
    final targetPage = currentPageNotifier.value - 1;
    navigateToPage(
      controller: _scrollController,
      targetPage: targetPage,
      itemWidth: _cachedItemFullWidth,
      itemCount: widget.itemCount,
    );
  }

  void _goToNextPage() {
    final targetPage = currentPageNotifier.value + 1;
    navigateToPage(
      controller: _scrollController,
      targetPage: targetPage,
      itemWidth: _cachedItemFullWidth,
      itemCount: widget.itemCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strategy = _strategy;

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.cardBorderRadius),
        color: widget.backgroundColor,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          if (availableWidth <= 0) {
            return const SizedBox.shrink();
          }

          final baseColumns = widget.columnsBuilder(availableWidth);
          final double columns = widget.enablePeek
              ? (baseColumns + 0.15)
              : baseColumns.toDouble();
          final paddingH = widget.horizontalPadding;
          final spacing = widget.itemSpacing;

          final contentWidth = math.max(0.0, availableWidth - (2 * paddingH));
          final rawCardWidth = (contentWidth - (columns - 1) * spacing) / columns;
          final cardWidth = math.max(0.0, rawCardWidth);
          _cachedItemFullWidth = cardWidth + spacing;
          final dynamicHeight = math.max(0.0, widget.heightBuilder(cardWidth));

          if (_cacheValid && availableWidth == _cachedWidth) {
            return _cachedColumn!;
          }
          _cacheValid = true;
          _cachedWidth = availableWidth;
          final column = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CarouselHeader(
                title: widget.title,
                titleStyle: widget.titleStyle,
                actionWidget: widget.actionWidget,
                showNavigationButtons: widget.showNavigationButtons,
                showNavigationControls: strategy.showNavigationControls,
                currentPageNotifier: currentPageNotifier,
                itemCount: widget.itemCount,
                columns: columns,
                onPreviousPage: _goToPreviousPage,
                onNextPage: _goToNextPage,
                navigationButtonColor: widget.navigationButtonColor,
                navigationButtonDisabledColor:
                    widget.navigationButtonDisabledColor,
                navigationIconColor: widget.navigationIconColor,
                navigationIconDisabledColor: widget.navigationIconDisabledColor,
              ),
              _CarouselListView(
                scrollController: _scrollController,
                strategy: strategy,
                itemCount: widget.itemCount,
                itemBuilder: widget.itemBuilder,
                itemBuilderWithWidth: widget.itemBuilderWithWidth,
                cardWidth: cardWidth,
                dynamicHeight: dynamicHeight,
                spacing: spacing,
                paddingH: paddingH,
                wheelAxisLock: _wheelAxisLock,
                cachedItemFullWidth: _cachedItemFullWidth,
              ),
              const SizedBox(height: 16),
            ],
          );
          _cachedColumn = column;
          return column;
        },
      ),
    );

    return strategy.wrapContainer(context, child: content);
  }
}

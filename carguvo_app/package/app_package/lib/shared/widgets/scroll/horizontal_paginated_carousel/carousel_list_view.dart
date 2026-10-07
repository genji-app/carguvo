// ignore_for_file: deprecated_member_use

part of 'horizontal_paginated_carousel.dart';

class _CarouselListView extends StatelessWidget {
  const _CarouselListView({
    required this.scrollController,
    required this.strategy,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemBuilderWithWidth,
    required this.cardWidth,
    required this.dynamicHeight,
    required this.spacing,
    required this.paddingH,
    required this.wheelAxisLock,
    required this.cachedItemFullWidth,
  });

  final ScrollController scrollController;
  final CarouselInteractionStrategy strategy;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int, double)? itemBuilderWithWidth;
  final double cardWidth;
  final double dynamicHeight;
  final double spacing;
  final double paddingH;
  final ScrollGestureAxisLock wheelAxisLock;
  final double cachedItemFullWidth;

  @override
  Widget build(BuildContext context) {
    final itemPadding = spacing / 2;

    final listView = ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: strategy.getScrollPhysics(cachedItemFullWidth),
      itemExtent: cachedItemFullWidth > 0 ? cachedItemFullWidth : null,
      cacheExtent:
          cardWidth *
          1.5,
      padding: EdgeInsets.symmetric(horizontal: paddingH - itemPadding),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final card = Padding(
          padding: EdgeInsets.symmetric(horizontal: itemPadding),
          child: SizedBox(
            width: cardWidth,
            child: itemBuilderWithWidth != null
                ? itemBuilderWithWidth!(context, index, cardWidth)
                : itemBuilder(context, index),
          ),
        );

        return strategy.wrapItem(card, wheelAxisLock: wheelAxisLock);
      },
    );

    return strategy.wrapCarousel(
      listView: listView,
      controller: scrollController,
      height: dynamicHeight,
    );
  }
}

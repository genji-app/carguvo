import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension HandleFutureError<R> on Future<R> {
  Future<R?> handleError([
    void Function(Object error, StackTrace stackTrace)? onError,
  ]) async {
    try {
      return await this;
    } catch (e, st) {
      onError?.call(e, st);
      return null;
    }
  }
}

class SliverLoadMoreBuilderDelegate extends SliverChildBuilderDelegate {
  SliverLoadMoreBuilderDelegate({
    required NullableIndexedWidgetBuilder itemBuilder,
    required WidgetBuilder loadingMoreBuilder,
    required bool enableLoadMore,
    required AsyncCallback onLoadMore,
    required int itemCount,
  }) : super(childCount: itemCount, (context, index) {
         final isLastIndex = index == itemCount - 1;

         if (isLastIndex) {
           return _LoadMoreTrigger(
             enable: enableLoadMore,
             onLoadMore: onLoadMore,
             loadingMoreBuilder: loadingMoreBuilder,
           );
         }

         return itemBuilder(context, index);
       });
}

class SliverSeparatedLoadMoreBuilderDelegate
    extends SliverChildBuilderDelegate {
  SliverSeparatedLoadMoreBuilderDelegate({
    required NullableIndexedWidgetBuilder itemBuilder,
    required NullableIndexedWidgetBuilder separatorBuilder,
    required WidgetBuilder loadingMoreBuilder,
    required bool enableLoadMore,
    required AsyncCallback onLoadMore,
    required int itemCount,
  }) : super(childCount: itemCount * 2, (context, index) {
         final isLastIndex = index == itemCount * 2 - 1;

         if (isLastIndex) {
           return _LoadMoreTrigger(
             enable: enableLoadMore,
             onLoadMore: onLoadMore,
             loadingMoreBuilder: loadingMoreBuilder,
           );
         }

         final itemIndex = index ~/ 2;

         return index.isEven
             ? itemBuilder(context, itemIndex)
             : separatorBuilder(context, itemIndex);
       });
}

class _LoadMoreTrigger extends StatefulWidget {
  const _LoadMoreTrigger({
    required this.enable,
    required this.onLoadMore,
    required this.loadingMoreBuilder,
  });

  final bool enable;
  final AsyncCallback onLoadMore;
  final WidgetBuilder loadingMoreBuilder;

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  var _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    if (widget.enable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
    }
  }

  @override
  void didUpdateWidget(covariant _LoadMoreTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enable != widget.enable && widget.enable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore().handleError();
    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMore) return widget.loadingMoreBuilder(context);

    return const SizedBox.shrink();
  }
}

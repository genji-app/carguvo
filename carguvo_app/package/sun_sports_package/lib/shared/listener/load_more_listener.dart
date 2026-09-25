import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadMoreListener extends StatefulWidget {
  const LoadMoreListener({
    required this.child,
    required this.onLoadMore,
    this.listen = true,
    this.extentTrigger,
    super.key,
  });

  final Widget child;
  final AsyncCallback onLoadMore;
  final bool listen;

  final double? extentTrigger;

  @override
  State<LoadMoreListener> createState() => _LoadMoreListenerState();
}

class _LoadMoreListenerState extends State<LoadMoreListener> {
  bool _loading = false;

  Future<void> _loadMore() async {
    if (_loading) return;

    if (mounted) setState(() => _loading = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _loading = false);
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.metrics.extentAfter <=
        (widget.extentTrigger ?? notification.metrics.viewportDimension / 2)) {
      _loadMore();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: widget.listen ? _onNotification : null,
        child: widget.child,
      );
}

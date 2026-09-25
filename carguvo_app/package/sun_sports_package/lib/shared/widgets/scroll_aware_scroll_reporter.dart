import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';

class ScrollAwareScrollReporter extends StatefulWidget {
  final Widget child;

  const ScrollAwareScrollReporter({required this.child, super.key});

  @override
  State<ScrollAwareScrollReporter> createState() =>
      _ScrollAwareScrollReporterState();
}

class _ScrollAwareScrollReporterState extends State<ScrollAwareScrollReporter> {
  bool _scrolling = false;

  bool _onNotification(ScrollNotification notification) {
    final controller = ScrollAwareController.instance;
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      _scrolling = true;
      controller.onScrollStart();
    } else if (notification is ScrollEndNotification) {
      _scrolling = false;
      controller.onScrollEnd();
    }
    return false;
  }

  @override
  void dispose() {
    if (_scrolling) ScrollAwareController.instance.onScrollEnd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: widget.child,
    );
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';

class MiniGameMinimizedFreeze extends StatefulWidget {
  const MiniGameMinimizedFreeze({
    required this.busy,
    required this.child,
    this.linger = const Duration(seconds: 3),
    super.key,
  });

  final bool busy;

  final Duration linger;

  final Widget child;

  @override
  State<MiniGameMinimizedFreeze> createState() =>
      _MiniGameMinimizedFreezeState();
}

class _MiniGameMinimizedFreezeState extends State<MiniGameMinimizedFreeze> {
  Timer? _lingerTimer;

  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    if (!widget.busy) _armLinger();
  }

  @override
  void didUpdateWidget(MiniGameMinimizedFreeze oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busy) {
      _lingerTimer?.cancel();
      if (!_enabled) setState(() => _enabled = true);
    } else if (oldWidget.busy) {
      _armLinger();
    }
  }

  void _armLinger() {
    _lingerTimer?.cancel();
    _lingerTimer = Timer(widget.linger, () {
      if (mounted) setState(() => _enabled = false);
    });
  }

  @override
  void dispose() {
    _lingerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(enabled: _enabled, child: widget.child);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

const Duration kMiniGameMinLoading = Duration(seconds: 1);

class MiniLoadingGate extends StatefulWidget {
  final bool loading;

  final Widget child;

  final double indicatorSize;

  final Color background;

  final Duration minShow;

  const MiniLoadingGate({
    required this.loading,
    required this.child,
    this.indicatorSize = 72,
    this.background = Colors.transparent,
    this.minShow = kMiniGameMinLoading,
    super.key,
  });

  @override
  State<MiniLoadingGate> createState() => _MiniLoadingGateState();
}

class _MiniLoadingGateState extends State<MiniLoadingGate> {
  DateTime? _shownAt;

  bool _holding = false;

  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    if (widget.loading) _shownAt = DateTime.now();
  }

  @override
  void didUpdateWidget(MiniLoadingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading == oldWidget.loading) return;
    if (widget.loading) {
      _holdTimer?.cancel();
      _holding = false;
      _shownAt = DateTime.now();
      return;
    }
    final shownAt = _shownAt;
    final remaining = shownAt == null
        ? Duration.zero
        : widget.minShow - DateTime.now().difference(shownAt);
    if (remaining <= Duration.zero) return;
    _holding = true;
    _holdTimer = Timer(remaining, () {
      if (mounted) setState(() => _holding = false);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading && !_holding) return widget.child;
    return S88Loading(
      indicatorSize: widget.indicatorSize,
      backgroundColor: widget.background,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

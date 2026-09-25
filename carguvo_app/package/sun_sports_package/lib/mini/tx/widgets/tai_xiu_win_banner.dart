import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class TaiXiuWinBanner extends StatefulWidget {
  final int winToken;
  final int amount;

  const TaiXiuWinBanner({
    required this.winToken,
    required this.amount,
    super.key,
  });

  @override
  State<TaiXiuWinBanner> createState() => _TaiXiuWinBannerState();
}

class _TaiXiuWinBannerState extends State<TaiXiuWinBanner>
    with SingleTickerProviderStateMixin {
  static const double _kRiseDistance = 20;
  static const int _kRiseMs = 300;
  static const int _kHoldMs = 4000;
  static const int _kFadeMs = 500;

  late final AnimationController _controller;
  Animation<double> _rise = const AlwaysStoppedAnimation(0);
  Animation<double> _opacity = const AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(TaiXiuWinBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winToken != widget.winToken) _play();
  }

  void _play() {
    const totalMs = _kRiseMs + _kHoldMs + _kFadeMs;
    _controller.duration = const Duration(milliseconds: totalMs);
    _rise = Tween<double>(begin: 0, end: -_kRiseDistance).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, _kRiseMs / totalMs, curve: Curves.easeOut),
      ),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1),
        weight: _kRiseMs.toDouble(),
      ),
      TweenSequenceItem(tween: ConstantTween(1), weight: _kHoldMs.toDouble()),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 0),
        weight: _kFadeMs.toDouble(),
      ),
    ]).animate(_controller);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.winToken == 0 || widget.amount <= 0) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.status == AnimationStatus.completed) {
            return const SizedBox.shrink();
          }
          return Transform.translate(
            offset: Offset(0, _rise.value),
            child: Opacity(opacity: _opacity.value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xF2181410),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6BE95)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            '+${NumberFormat('#,###').format(widget.amount)}',
            style: AppTextStyles.headingSmall(color: const Color(0xFFFFD54F)),
          ),
        ),
      ),
    );
  }
}

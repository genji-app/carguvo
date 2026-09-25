import 'package:flutter/material.dart';

class JackpotCountAnimation extends StatefulWidget {
  final int jackpot;
  final String Function(int) money;
  final Widget Function(String) gold;

  const JackpotCountAnimation({
    required this.jackpot,
    required this.money,
    required this.gold,
    super.key,
  });

  @override
  State<JackpotCountAnimation> createState() => _JackpotCountAnimationState();
}

class _JackpotCountAnimationState extends State<JackpotCountAnimation>
    with SingleTickerProviderStateMixin {
  static const int _stepCount = 10;

  static const Duration kCountDuration = Duration(milliseconds: 500);

  late final AnimationController _controller;

  int _displayed = 0;

  int _origin = 0;

  int _target = 0;

  int _lastStep = -1;

  @override
  void initState() {
    super.initState();
    _displayed = widget.jackpot;
    _origin = widget.jackpot;
    _target = widget.jackpot;
    _controller = AnimationController(vsync: this, duration: kCountDuration)
      ..addListener(_tick);
  }

  @override
  void didUpdateWidget(covariant JackpotCountAnimation old) {
    super.didUpdateWidget(old);
    if (old.jackpot != widget.jackpot) {
      _animateTo(widget.jackpot);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(int target) {
    final from = _displayed;
    if (target == from) return;

    _origin = from;
    _target = target;
    _lastStep = -1;
    _controller
      ..duration = kCountDuration
      ..forward(from: 0);
  }

  void _tick() {
    final v = _controller.value;
    final step = (v * _stepCount + 1e-6).floor().clamp(0, _stepCount);
    if (step == _lastStep) return;
    _lastStep = step;

    final int newValue;
    if (step >= _stepCount) {
      newValue = _target;
    } else {
      final t = step / _stepCount;
      newValue = (_origin + (_target - _origin) * t).round();
    }
    if (newValue == _displayed) return;
    _displayed = newValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: widget.gold(widget.money(_displayed)));
  }
}

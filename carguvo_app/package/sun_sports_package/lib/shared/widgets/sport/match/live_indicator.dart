import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class LiveIndicator extends StatefulWidget {
  final String text;
  final double fontSize;
  final bool showAnimation;
  final Color backgroundColor;
  final Color textColor;

  const LiveIndicator({
    super.key,
    this.text = 'Trực tiếp',
    this.fontSize = 10,
    this.showAnimation = true,
    this.backgroundColor = AppColors.red500,
    this.textColor = const Color(0xFFFFFEF5),
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.showAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showAnimation && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.showAnimation && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAnimation) {
      return _buildBadge();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) =>
          Opacity(opacity: _pulseAnimation.value, child: child),
      child: _buildBadge(),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.text,
        style: AppTextStyles.textStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
          color: widget.textColor,
        ),
      ),
    );
  }
}

class LiveDotIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final bool showAnimation;

  const LiveDotIndicator({
    super.key,
    this.color = AppColors.red500,
    this.size = 8,
    this.showAnimation = true,
  });

  @override
  State<LiveDotIndicator> createState() => _LiveDotIndicatorState();
}

class _LiveDotIndicatorState extends State<LiveDotIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.showAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAnimation) {
      return _buildDot();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) =>
          Opacity(opacity: _animation.value, child: child),
      child: _buildDot(),
    );
  }

  Widget _buildDot() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );
  }
}

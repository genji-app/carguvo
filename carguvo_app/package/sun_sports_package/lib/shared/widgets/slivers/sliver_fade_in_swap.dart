import 'package:flutter/widgets.dart';

class SliverFadeInSwap extends StatefulWidget {
  const SliverFadeInSwap({
    required this.token,
    required this.sliver,
    super.key,
    this.duration = const Duration(milliseconds: 200),
  });

  final Object token;

  final Widget sliver;

  final Duration duration;

  @override
  State<SliverFadeInSwap> createState() => _SliverFadeInSwapState();
}

class _SliverFadeInSwapState extends State<SliverFadeInSwap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void didUpdateWidget(SliverFadeInSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      _controller
        ..duration = widget.duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      child: widget.sliver,
      builder: (context, child) =>
          SliverOpacity(opacity: _opacity.value, sliver: child!),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/mini_game/presentation/state/mini_poker_state_provider.dart'
    show MiniPokerNotifier;

class MinipokerWinBanner extends StatefulWidget {
  final int winToken;
  final String? hand;
  final int amount;
  final bool turbo;

  const MinipokerWinBanner({
    required this.winToken,
    required this.hand,
    required this.amount,
    required this.turbo,
    super.key,
  });

  @override
  State<MinipokerWinBanner> createState() => _MinipokerWinBannerState();
}

class _MinipokerWinBannerState extends State<MinipokerWinBanner>
    with SingleTickerProviderStateMixin {
  static const double _kRiseDistance = 20;
  static const int _kRiseMs = 300;

  late final AnimationController _controller;
  Animation<double> _rise = const AlwaysStoppedAnimation(0);
  Animation<double> _opacity = const AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(MinipokerWinBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winToken != widget.winToken) _play();
  }

  void _play() {
    final holdMs = widget.turbo ? 500 : 1000;
    final fadeMs = widget.turbo ? 500 : 1000;
    final totalMs = _kRiseMs + holdMs + fadeMs;
    _controller.duration = Duration(milliseconds: totalMs);
    _rise = Tween<double>(begin: 0, end: -_kRiseDistance).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, _kRiseMs / totalMs, curve: Curves.easeOut),
      ),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval((_kRiseMs + holdMs) / totalMs, 1),
      ),
    );
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hand = widget.hand;
    if (widget.winToken == 0 || hand == null) return const SizedBox.shrink();
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hand,
                style: AppTextStyles.labelMedium(color: AppColors.gray25),
              ),
              Text(
                '+${MiniPokerNotifier.formatMoney(widget.amount)}',
                style: AppTextStyles.headingSmall(
                  color: const Color(0xFFFFD54F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

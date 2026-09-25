import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/money_formatter.dart';

class JackpotMoneyOverlay extends StatefulWidget {
  final int token;

  final int amount;

  final bool active;

  final Duration duration;

  final Alignment alignment;

  final double fontSize;

  const JackpotMoneyOverlay({
    required this.token,
    required this.amount,
    required this.active,
    this.duration = const Duration(seconds: 5),
    this.alignment = const Alignment(0, 0.30),
    this.fontSize = 26,
    super.key,
  });

  @override
  State<JackpotMoneyOverlay> createState() => _JackpotMoneyOverlayState();
}

class _JackpotMoneyOverlayState extends State<JackpotMoneyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _seenToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.token > 0) {
      _seenToken = widget.token;
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(JackpotMoneyOverlay old) {
    super.didUpdateWidget(old);
    if (widget.token != _seenToken && widget.token > 0) {
      _seenToken = widget.token;
      _controller
        ..duration = widget.duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: widget.active ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Align(
          alignment: widget.alignment,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeOut.transform(_controller.value);
              final value = (widget.amount * t).round();
              return Text(
                MoneyFormatter.formatWithCommas(value),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFD24A),
                  letterSpacing: 1,
                  shadows: const [
                    Shadow(color: Color(0xFF7A3B00), blurRadius: 2),
                    Shadow(color: Color(0xCC000000), blurRadius: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';

@immutable
class BdScoreFlipEvent {
  const BdScoreFlipEvent({
    required this.from,
    required this.increase,
    required this.seq,
  });

  final int from;

  final bool increase;

  final int seq;
}

class BdScoreFlipMobile extends StatefulWidget {
  const BdScoreFlipMobile({
    required this.home,
    required this.away,
    required this.animate,
    required this.style,
    this.homeFlip,
    this.awayFlip,
    super.key,
  });

  final int? home;
  final int? away;

  final bool animate;

  final TextStyle style;

  final BdScoreFlipEvent? homeFlip;
  final BdScoreFlipEvent? awayFlip;

  @override
  State<BdScoreFlipMobile> createState() => _BdScoreFlipMobileState();
}

class _SideFlip {
  _SideFlip(this._controller, this._rebuild);

  final AnimationController _controller;
  final void Function() _rebuild;

  int? outgoing;

  bool tinted = false;

  bool increase = true;

  int seq = 0;

  Timer? _tintTimer;

  void start({required int from, required bool increase}) {
    _tintTimer?.cancel();
    seq++;
    outgoing = from;
    tinted = true;
    this.increase = increase;
    _controller.forward(from: 0).whenComplete(() {
      if (outgoing == null) return;
      outgoing = null;
      _rebuild();
    });
    _tintTimer = Timer(_BdScoreFlipMobileState.tintDuration, () {
      tinted = false;
      _rebuild();
    });
  }

  void clear() {
    _tintTimer?.cancel();
    _tintTimer = null;
    outgoing = null;
    tinted = false;
    _controller.stop();
    _controller.value = 1;
  }

  void dispose() {
    _tintTimer?.cancel();
    _controller.dispose();
  }
}

class _BdScoreFlipMobileState extends State<BdScoreFlipMobile>
    with TickerProviderStateMixin {
  static const Duration slideDuration = Duration(milliseconds: 450);

  static const Duration tintDuration = Duration(seconds: 3);

  static const Duration _untintDuration = Duration(milliseconds: 500);

  static const Curve _curve = Cubic(0.33, 1, 0.68, 1);

  static const Color _goalColor = Color(0xFF70D898);
  static const Color _cancelColor = Color(0xFFF89060);

  static const Color _boxBg = Color(0xFF1A3324);
  static const Color _boxBorder = Color(0xFF1E2E22);
  static const Duration _boxDuration = Duration(milliseconds: 300);

  late final _SideFlip _home = _SideFlip(
    AnimationController(vsync: this, duration: slideDuration, value: 1),
    _rebuild,
  );
  late final _SideFlip _away = _SideFlip(
    AnimationController(vsync: this, duration: slideDuration, value: 1),
    _rebuild,
  );

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(BdScoreFlipMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _home.clear();
      _away.clear();
      return;
    }
    _maybeStart(_home, widget.homeFlip, oldWidget.homeFlip);
    _maybeStart(_away, widget.awayFlip, oldWidget.awayFlip);
  }

  static void _maybeStart(
    _SideFlip side,
    BdScoreFlipEvent? next,
    BdScoreFlipEvent? prev,
  ) {
    if (next == null || next.seq == prev?.seq) return;
    side.start(from: next.from, increase: next.increase);
  }

  @override
  void dispose() {
    _home.dispose();
    _away.dispose();
    super.dispose();
  }

  Widget _digit(int? value, _SideFlip side) {
    final style = widget.style.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final height = (style.fontSize ?? 14) * (style.height ?? 1);
    final tint = !side.tinted
        ? Colors.white
        : side.increase
            ? _goalColor
            : _cancelColor;
    final curved = CurvedAnimation(parent: side._controller, curve: _curve);
    final incoming = AnimatedDefaultTextStyle(
      key: ValueKey<int>(side.seq),
      duration: _untintDuration,
      style: style.copyWith(color: tint),
      child: Text(value == null ? '–' : '$value'),
    );
    return ClipRect(
      child: SizedBox(
        height: height,
        child: AnimatedBuilder(
          animation: curved,
          builder: (_, __) {
            final t = curved.value;
            final dir = side.increase ? 1.0 : -1.0;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, (t - 1) * height * dir),
                  child: incoming,
                ),
                if (side.outgoing != null)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, t * height * dir),
                      child: Center(
                        child: Text(
                          '${side.outgoing}',
                          style: style.copyWith(
                            color: AppColorStyles.contentTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _home.tinted || _away.tinted;
    return AnimatedContainer(
      duration: _boxDuration,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: active ? _boxBg : _boxBg.withValues(alpha: 0),
        border: Border.all(
          color: active ? _boxBorder : _boxBorder.withValues(alpha: 0),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _digit(widget.home, _home),
          const SizedBox(width: 2),
          AnimatedDefaultTextStyle(
            duration: _boxDuration,
            style: widget.style.copyWith(
              color: active ? AppColorStyles.contentTertiary : Colors.white,
            ),
            child: const Text(':'),
          ),
          const SizedBox(width: 2),
          _digit(widget.away, _away),
        ],
      ),
    );
  }
}

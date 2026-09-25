import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/diamond_guide.dart';
import 'package:sun_sports/mini/diamond/diamond_history.dart';
import 'package:sun_sports/mini/diamond/diamond_rank.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/state/diamond_sub_view_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_bet_bar.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_controls.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_header.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_line_selection.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_reels.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class DiamondPanel extends ConsumerWidget {
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondPanel({
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(diamondSubViewProvider);
    void open(DiamondSubView v) =>
        ref.read(diamondSubViewProvider.notifier).state = v;
    void back() => open(DiamondSubView.none);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildContent(sub, open, back),
        if (sub == DiamondSubView.none)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ImageHelper.load(
                path: MiniGameIcons.diamondLogo,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    DiamondSubView sub,
    void Function(DiamondSubView) open,
    VoidCallback back,
  ) {
    switch (sub) {
      case DiamondSubView.lines:
        return DiamondLineSelection(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.rank:
        return DiamondRank(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.history:
        return DiamondHistory(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.guide:
        return DiamondGuide(
          borderRadius: borderRadius,
          onBack: back,
          onClose: onClose,
        );
      case DiamondSubView.none:
        return _MainInterface(
          borderRadius: borderRadius,
          onClose: onClose,
          onRank: () => open(DiamondSubView.rank),
          onHistory: () => open(DiamondSubView.history),
          onGuide: () => open(DiamondSubView.guide),
          onLines: () => open(DiamondSubView.lines),
        );
    }
  }
}

class _MainInterface extends ConsumerWidget {
  final BorderRadius borderRadius;
  final VoidCallback? onClose;
  final VoidCallback onRank;
  final VoidCallback onHistory;
  final VoidCallback onGuide;
  final VoidCallback onLines;

  const _MainInterface({
    required this.borderRadius,
    required this.onClose,
    required this.onRank,
    required this.onHistory,
    required this.onGuide,
    required this.onLines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DiamondHeader(
                    onRank: onRank,
                    onHistory: onHistory,
                    onGuide: onGuide,
                    onClose: onClose,
                  ),
                  const SizedBox(height: 12),
                  const DiamondReelsWithResult(),
                  const SizedBox(height: 6),
                  Text(
                    I18n.diamondBrand,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: kDiamondTextTertiary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DiamondBetBar(onOpenLines: onLines),
                  const SizedBox(height: 16),
                  const DiamondControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DiamondReelsWithResult extends ConsumerStatefulWidget {
  final double aspectRatio;

  const DiamondReelsWithResult({this.aspectRatio = 338 / 252, super.key});

  @override
  ConsumerState<DiamondReelsWithResult> createState() =>
      _DiamondReelsWithResultState();
}

class _DiamondReelsWithResultState extends ConsumerState<DiamondReelsWithResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  int _displayWin = 0;
  Timer? _delay;

  static const Duration _settleNormal = Duration(milliseconds: 2200);
  static const Duration _settleFast = Duration(milliseconds: 450);

  void _show(int win) {
    if (win > 0) SoundEffects.instance.playMiniGame(MiniGameSound.winSfx);
    setState(() => _displayWin = win);
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(diamondStateProvider.select((s) => s.spinning), (_, next) {
      if (next) {
        _delay?.cancel();
        _c.value = 0;
      } else {
        final s = ref.read(diamondStateProvider);
        if (s.moneyExchange > 0) {
          _delay?.cancel();
          _delay = Timer(s.fastSpin ? _settleFast : _settleNormal, () {
            if (mounted) _show(s.moneyExchange);
          });
        }
      }
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        DiamondReels(aspectRatio: widget.aspectRatio),
        Positioned(
          bottom: 8,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final v = _c.value;
              if (v == 0 || _displayWin == 0) return const SizedBox.shrink();
              final double opacity = v < 0.1
                  ? v / 0.1
                  : (v < 0.72 ? 1.0 : (1 - (v - 0.72) / 0.28).clamp(0.0, 1.0));
              final t = (v / 0.22).clamp(0.0, 1.0);
              final dy = 20 * (1 - Curves.easeOutExpo.transform(t));
              return Opacity(
                opacity: opacity,
                child: Transform.translate(offset: Offset(0, dy), child: child),
              );
            },
            child: _DiamondResultBox(amount: _displayWin),
          ),
        ),
      ],
    );
  }
}

class _DiamondResultBox extends StatelessWidget {
  final int amount;

  const _DiamondResultBox({required this.amount});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _ResultBorderPainter(radius: 16, width: 0.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF391500), Color(0xFF221300)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 1.35,
              offset: Offset(0, 1.35),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.1,
                    colors: [
                      const Color(0xFFFFBA71).withValues(alpha: 0.32),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: GradientText(
                '+${diamondMoney(amount)}',
                gradient: kDiamondGoldGradient,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 24 / 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBorderPainter extends CustomPainter {
  final double radius;
  final double width;

  const _ResultBorderPainter({required this.radius, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFF666666)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_ResultBorderPainter old) =>
      old.radius != radius || old.width != width;
}

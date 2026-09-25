import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/state/up_down_card.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_rive.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class UpDownPlayArea extends StatelessWidget {
  final int selectedBetIndex;
  final ValueChanged<int> onSelectBet;

  final bool betEnabled;

  const UpDownPlayArea({
    required this.selectedBetIndex,
    required this.onSelectBet,
    this.betEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 256,
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const UpDownASlots(),
          const UpDownCenterCard(),
          UpDownUnitColumn(
            selected: selectedBetIndex,
            onSelect: onSelectBet,
            enabled: betEnabled,
          ),
        ],
      ),
    );
  }
}

class UpDownASlots extends ConsumerWidget {
  final double slotWidth;

  final double slotHeight;

  final double gap;

  const UpDownASlots({
    this.slotWidth = 56,
    this.slotHeight = 66,
    this.gap = 16,
    super.key,
  });

  static const String _kActiveInput = 'isActive';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numOfAce = ref.watch(upDownStateProvider.select((s) => s.numOfAce));
    Widget slot(int index) {
      final selected = index < numOfAce;
      return SizedBox(
        width: slotWidth,
        height: slotHeight,
        child: UpDownRive(
          name: AppRive.upDownASymbol,
          booleans: {_kActiveInput: selected},
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kUpDownMaxAce; i++) ...[
          if (i > 0) SizedBox(height: gap),
          slot(i),
        ],
      ],
    );
  }
}

class UpDownCenterCard extends ConsumerStatefulWidget {
  final double scale;

  final double topGap;

  const UpDownCenterCard({this.scale = 1, this.topGap = 10, super.key});

  @override
  ConsumerState<UpDownCenterCard> createState() => _UpDownCenterCardState();
}

class _UpDownCenterCardState extends ConsumerState<UpDownCenterCard> {
  static const Duration _spinInterval = Duration(milliseconds: 50);

  final Random _rng = Random();
  Timer? _spinTimer;

  int _randomCode = 0;

  static bool _facesWarmed = false;

  static Future<void> _warmCardFaces() async {
    if (_facesWarmed) return;
    _facesWarmed = true;
    for (var code = 0; code < 52; code++) {
      await ImageHelper.precacheSvgPicture(decodeCard(code).faceAsset);
    }
  }

  @override
  void initState() {
    super.initState();
    _warmCardFaces();
    if (ref.read(upDownStateProvider).spinning) _startSpin();
  }

  void _startSpin() {
    _spinTimer?.cancel();
    _spinTimer = Timer.periodic(_spinInterval, (_) {
      if (!mounted) return;
      setState(() => _randomCode = _rng.nextInt(52));
    });
  }

  void _stopSpin() {
    _spinTimer?.cancel();
    _spinTimer = null;
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      upDownStateProvider.select((s) => s.spinning),
      (_, spinning) => spinning ? _startSpin() : _stopSpin(),
    );

    final spinning = ref.watch(
      upDownStateProvider.select((s) => s.spinning),
    );
    final code = ref.watch(
      upDownStateProvider.select((s) => s.history.isEmpty ? null : s.history.last),
    );

    final String path;
    double opacity = 1;
    if (spinning) {
      path = decodeCard(_randomCode).faceAsset;
      opacity = 0.75;
    } else if (code != null) {
      path = decodeCard(code).faceAsset;
    } else {
      path = MiniGameIcons.updownFaceDownCard;
    }

    final s = widget.scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topGap > 0) SizedBox(height: widget.topGap),
        RepaintBoundary(
          child: Container(
            width: 136 * s,
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(16 * s),
            ),
            child: Opacity(
              opacity: opacity,
              child: ImageHelper.load(
                path: path,
                width: 111 * s,
                height: 147 * s,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const UpDownCountdownPill(),
      ],
    );
  }
}

class UpDownCountdownPill extends ConsumerStatefulWidget {
  const UpDownCountdownPill({super.key});

  @override
  ConsumerState<UpDownCountdownPill> createState() =>
      _UpDownCountdownPillState();
}

class _UpDownCountdownPillState extends ConsumerState<UpDownCountdownPill> {
  Timer? _ticker;

  int _remaining = kUpDownRoundSeconds;

  @override
  void initState() {
    super.initState();
    final dl = ref.read(upDownStateProvider).timerDeadlineMs;
    _recompute(dl);
    if (dl != 0) _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _recompute(int deadlineMs) {
    if (deadlineMs == 0) {
      _remaining = kUpDownRoundSeconds;
      return;
    }
    final ms = deadlineMs - DateTime.now().millisecondsSinceEpoch;
    _remaining = ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(
        () => _recompute(ref.read(upDownStateProvider).timerDeadlineMs),
      );
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String get _label {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static const LinearGradient _runningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF754F), Color(0xFFB72424)],
  );

  static const LinearGradient _idleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF777777), Color(0xFFFFFFFF)],
  );

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      upDownStateProvider.select((s) => s.timerDeadlineMs),
      (_, dl) {
        setState(() => _recompute(dl));
        dl == 0 ? _stopTicker() : _startTicker();
      },
    );
    final running =
        ref.watch(upDownStateProvider.select((s) => s.timerDeadlineMs != 0));
    return Container(
      width: 77.69,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF161514),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: GradientText(
        _label,
        gradient: running ? _runningGradient : _idleGradient,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class UpDownUnitColumn extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  final bool enabled;

  final double chipWidth;
  final double chipHeight;
  final double gap;

  const UpDownUnitColumn({
    required this.selected,
    required this.onSelect,
    this.enabled = true,
    this.chipWidth = 56,
    this.chipHeight = 40,
    this.gap = 8,
    super.key,
  });

  static const List<String> _units = ['1K', '10K', '50K', '100K', '500K'];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _units.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            _UnitChip(
              label: _units[i],
              selected: i == selected,
              onTap: () => onSelect(i),
              width: chipWidth,
              height: chipHeight,
            ),
          ],
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.width = 56,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(onTap),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF000000), width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? const [Color(0x00000000), Color(0xFF7D5100)]
                  : const [Color(0xFF3D3C3B), Color(0xFF252423)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: GradientText(
            label,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}

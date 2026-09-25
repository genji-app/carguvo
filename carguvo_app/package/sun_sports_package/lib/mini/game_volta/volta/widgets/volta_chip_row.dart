import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/widgets/volta_gold_text.dart';

class VoltaChipRow extends ConsumerWidget {
  const VoltaChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(voltaStateProvider.select((s) => s.chipIndex));
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return Container(
      height: spec.chipRowHeight,
      decoration: _rowDecoration,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spec.chipGap),
        child: Row(
          children: <Widget>[
            for (
              int index = 0;
              index < VoltaChip.defaults.length;
              index++
            ) ...<Widget>[
              if (index > 0) SizedBox(width: spec.chipGap),
              VoltaChipTile(
                index: index,
                chip: VoltaChip.defaults[index],
                slot: spec.chipHeight,
                idleRatio: spec.chipIdleRatio,
                selected: index == selected,
                onTap: () {
                  VoltaFeedback.click();
                  ref.read(voltaStateProvider.notifier).selectChip(index);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const BoxDecoration _rowDecoration = BoxDecoration(
    color: VoltaColors.surface,
    border: Border(top: BorderSide(color: VoltaColors.hairline, width: 0.5)),
  );
}

class VoltaChipTile extends StatelessWidget {
  const VoltaChipTile({
    required this.index,
    required this.chip,
    required this.slot,
    required this.idleRatio,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int index;
  final VoltaChip chip;

  final double slot;

  final double idleRatio;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double h = selected ? slot : slot * idleRatio;
    final double w = h * kVoltaChipAspect;
    final double font = voltaChipLabelFontSize(h, chip.label);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: w,
        height: h,
        child: Align(
          child: Transform.translate(
            offset: Offset(0, -kVoltaChipLabelLift * h),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  if (selected) _glow(index, w, h),
                  VoltaIcons.chip(index, height: h),
                  _label(font, h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _glow(int index, double w, double h) {
    final double box = h * kVoltaChipGlowBox;
    return Positioned(
      left: (w - box) / 2,
      top: (h - box) / 2 + kVoltaChipLabelLift * h,
      width: box,
      height: box,
      child: _VoltaChipGlow(color: VoltaColors.chipGlow[index]),
    );
  }

  Widget _label(double font, double h) => Transform.translate(
    offset: Offset(0, kVoltaChipLabelLift * h),
    child: VoltaGoldText(
      chip.label,
      style: AppTextStyles.labelSmall().copyWith(fontSize: font, height: 1),
      shadows: <Shadow>[
        Shadow(
          color: const Color(0x99000000),
          offset: Offset(0, font / 14),
          blurRadius: font * 2 / 14,
        ),
      ],
    ),
  );
}

class _VoltaChipGlow extends StatefulWidget {
  const _VoltaChipGlow({required this.color});

  final Color color;

  @override
  State<_VoltaChipGlow> createState() => _VoltaChipGlowState();
}

class _VoltaChipGlowState extends State<_VoltaChipGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            widget.color.withValues(alpha: kVoltaChipGlowAlphas.first),
            for (final double a in kVoltaChipGlowAlphas)
              widget.color.withValues(alpha: a),
          ],
          stops: <double>[
            0,
            for (final double r in kVoltaChipGlowRadii)
              r / kVoltaChipGlowOuter,
          ],
        ),
      ),
    ),
  );
}

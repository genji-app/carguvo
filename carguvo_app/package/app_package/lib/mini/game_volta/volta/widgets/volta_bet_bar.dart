import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/core/utils/styles/mini_game_icons.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_gradients.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_layout_spec.dart';
import 'volta_action_row.dart';
import 'volta_chip_row.dart';

class VoltaBetBar extends ConsumerWidget {
  const VoltaBetBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRebet = ref.watch(voltaStateProvider.select((s) => s.canRebet));
    final canDouble = ref.watch(voltaStateProvider.select((s) => s.canDouble));
    final notifier = ref.read(voltaStateProvider.notifier);
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);
    final Size button = Size(spec.betBarButtonWidth, spec.betBarHeight);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spec.betBarPadH,
        vertical: spec.betBarPadV,
      ),
      child: SizedBox(
        height: spec.betBarChipLift + spec.betBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            VoltaActionButton(
              style: VoltaActionButtonStyle.rebet,
              size: button,
              frame: MiniGameIcons.voltaBackgroundRematch,
              outerLeft: true,
              enabled: canRebet,
              onTap: () =>
                  VoltaActionRow.runBetAction(context, ref, notifier.rebet),
        child: VoltaIcons.redo(size: spec.betBarIconSize),
            ),
            SizedBox(width: spec.betBarGap),
            const Expanded(child: _ChipRail()),
            SizedBox(width: spec.betBarGap),
            VoltaActionButton(
              style: VoltaActionButtonStyle.doubleUp,
              size: button,
              frame: MiniGameIcons.voltaBackgroundx2,
              outerLeft: false,
              enabled: canDouble,
              onTap: () => VoltaActionRow.runBetAction(
                context,
                ref,
                notifier.doubleStake,
              ),
              child: _X2Label(fontSize: spec.betBarLabelFontSize),
            ),
          ],
        ),
      ),
    );
  }

}

class _ChipRail extends ConsumerWidget {
  const _ChipRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(voltaStateProvider.select((s) => s.chipIndex));
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);
    final double chip = spec.betBarChipSize;
    final double fade = spec.betBarFadeWidth;
    final double bleed = spec.betBarChipBleed;

    return SizedBox(
      height: spec.betBarHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                kVoltaRailRadiusRatio * spec.betBarHeight,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: voltaRailBase),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: voltaRailBottomGlow),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: voltaRailTopGlow),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: kVoltaRailTopEdgeRatio * spec.betBarHeight,
                    child: ColoredBox(
                      color: Colors.white.withValues(
                        alpha: kVoltaRailTopEdgeAlpha,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _railContent(spec, selected, ref, fade, bleed, chip),
        ],
      ),
    );
  }

  Widget _railContent(
    VoltaLayoutSpec spec,
    int selected,
    WidgetRef ref,
    double fade,
    double bleed,
    double chip,
  ) {
    return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: -bleed,
              bottom: -bleed,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                hitTestBehavior: HitTestBehavior.deferToChild,
                padding: EdgeInsets.fromLTRB(fade / 4, 0, fade / 4, bleed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                        slot: chip,
                        idleRatio: spec.chipIdleRatio,
                        selected: index == selected,
                        onTap: () {
                          VoltaFeedback.click();
                          ref
                              .read(voltaStateProvider.notifier)
                              .selectChip(index);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _RailFade(
              width: fade,
              fromLeft: true,
              radius: kVoltaRailRadiusRatio * spec.betBarHeight,
            ),
            _RailFade(
              width: fade,
              fromLeft: false,
              radius: kVoltaRailRadiusRatio * spec.betBarHeight,
            ),
      ],
    );
  }

}

class _RailFade extends StatelessWidget {
  const _RailFade({
    required this.width,
    required this.fromLeft,
    required this.radius,
  });

  final double width;
  final bool fromLeft;

  final double radius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = fromLeft
        ? BorderRadius.horizontal(left: Radius.circular(radius))
        : BorderRadius.horizontal(right: Radius.circular(radius));
    final Widget layer = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: const <Color>[_edge, Color(0x00000000)],
        ),
      ),
      child: const SizedBox.expand(),
    );

    return Positioned(
      top: 0,
      bottom: 0,
      left: fromLeft ? 0 : null,
      right: fromLeft ? null : 0,
      width: width,
      child: IgnorePointer(
        child: Stack(children: <Widget>[layer, layer]),
      ),
    );
  }

  static const Color _edge = Color(0xA1000000);
}

class _X2Label extends StatelessWidget {
  const _X2Label({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTextStyles.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: VoltaColors.contentPrimary,
    );
    const double dx = 0.8766;
    const double dy = -0.4812;
    final LinearGradient gradient = LinearGradient(
      begin: const Alignment(-dx, -dy),
      end: const Alignment(dx, dy),
      colors: <Color>[
        Color(0xFF000000 | kVoltaActionLabelGradientFrom),
        Color(0xFF000000 | kVoltaActionLabelGradientTo),
      ],
      stops: const <double>[
        kVoltaActionLabelGradientFromStop,
        kVoltaActionLabelGradientToStop,
      ],
    );
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          'X2',
          style: base.copyWith(
            color: const Color(0x00000000),
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Color(0x40000000),
              ),
            ],
          ),
        ),
        ShaderMask(
          shaderCallback: gradient.createShader,
          blendMode: BlendMode.srcIn,
          child: Text('X2', style: base),
        ),
      ],
    );
  }
}

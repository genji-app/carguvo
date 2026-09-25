import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
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
              borderRadius: _radius(spec, outerLeft: true),
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
              borderRadius: _radius(spec, outerLeft: false),
              enabled: canDouble,
              onTap: () => VoltaActionRow.runBetAction(
                context,
                ref,
                notifier.doubleStake,
              ),
              child: Text(
                'X2',
                style: AppTextStyles.inter(
                  fontSize: spec.betBarLabelFontSize,
                  fontWeight: FontWeight.w700,
                  color: VoltaColors.contentPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BorderRadius _radius(VoltaLayoutSpec spec, {required bool outerLeft}) {
    final Radius outer = Radius.circular(spec.betBarRadiusOuter);
    final Radius inner = Radius.circular(spec.betBarRadiusInner);
    return outerLeft
        ? BorderRadius.horizontal(left: outer, right: inner)
        : BorderRadius.horizontal(left: inner, right: outer);
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
      child: DecoratedBox(
        decoration: _railDecoration,
        child: Stack(
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
                padding: EdgeInsets.symmetric(horizontal: fade / 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
            _RailFade(width: fade, fromLeft: true),
            _RailFade(width: fade, fromLeft: false),
          ],
        ),
      ),
    );
  }

  static const BoxDecoration _railDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[VoltaColors.betBarRailTop, VoltaColors.betBarRailBottom],
    ),
    border: Border(
      top: BorderSide(color: VoltaColors.betBarRailHighlight, width: 0.5),
    ),
  );
}

class _RailFade extends StatelessWidget {
  const _RailFade({required this.width, required this.fromLeft});

  final double width;
  final bool fromLeft;

  @override
  Widget build(BuildContext context) {
    final Widget layer = DecoratedBox(
      decoration: BoxDecoration(
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

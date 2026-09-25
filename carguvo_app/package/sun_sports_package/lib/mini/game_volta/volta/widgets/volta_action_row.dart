import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/domain/volta_bet_rules.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_icons.dart';

class VoltaActionRow extends ConsumerWidget {
  const VoltaActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRebet = ref.watch(voltaStateProvider.select((s) => s.canRebet));
    final canDouble = ref.watch(voltaStateProvider.select((s) => s.canDouble));
    final notifier = ref.read(voltaStateProvider.notifier);
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return Container(
      height: spec.actionRowHeight,
      decoration: _rowDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          VoltaActionButton(
            style: VoltaActionButtonStyle.rebet,
            size: Size(spec.actionButtonWidth, spec.actionButtonHeight),
            enabled: canRebet,
            onTap: () => runBetAction(context, ref, notifier.rebet),
            child: VoltaIcons.redo(size: 28),
          ),
          SizedBox(width: spec.actionGap),
          VoltaActionButton(
            style: VoltaActionButtonStyle.doubleUp,
            size: Size(spec.actionButtonWidth, spec.actionButtonHeight),
            enabled: canDouble,
            onTap: () => runBetAction(context, ref, notifier.doubleStake),
            child: Text(
              'X2',
              style: AppTextStyles.labelLarge(
                color: VoltaColors.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void runBetAction(
    BuildContext context,
    WidgetRef ref,
    Future<VoltaBetOutcome> Function() action,
  ) {
    VoltaFeedback.click();
    if (!VoltaFeedback.requireSignedIn(context, ref)) return;
    unawaited(
      VoltaBetLoading.run(context, action).then((VoltaBetOutcome outcome) {
        if (!context.mounted) return;
        VoltaBetFeedback.show(context, outcome);
      }),
    );
  }

  static const BoxDecoration _rowDecoration = BoxDecoration(
    color: VoltaColors.surface,
    border: Border(top: BorderSide(color: VoltaColors.hairline)),
  );
}

@immutable
class VoltaActionButtonStyle {
  final Color baseTop;
  final Color baseBottom;

  final double scrim;

  final List<Color> topColors;
  final List<double> topStops;

  final List<Color> bottomColors;
  final List<double> bottomStops;

  static const double bottomExtent = 0.2985;

  final Color rim;

  const VoltaActionButtonStyle({
    required this.baseTop,
    required this.baseBottom,
    required this.scrim,
    required this.topColors,
    required this.topStops,
    required this.bottomColors,
    required this.bottomStops,
    required this.rim,
  });

  static const VoltaActionButtonStyle rebet = VoltaActionButtonStyle(
    baseTop: VoltaColors.rebetTop,
    baseBottom: VoltaColors.rebetBottom,
    scrim: 0.5,
    topColors: <Color>[
      Color(0xB8FFE2BB),
      Color(0x5CFFBA71),
      Color(0x45BF8C55),
      Color(0x2E805D39),
      Color(0x17402F1C),
      Color(0x00000000),
    ],
    topStops: <double>[0, 0.3, 0.475, 0.65, 0.825, 1],
    bottomColors: <Color>[
      Color(0x80FFB871),
      Color(0x60BF8A55),
      Color(0x40805C39),
      Color(0x20402E1C),
      Color(0x00000000),
    ],
    bottomStops: <double>[0, 0.25, 0.5, 0.75, 1],
    rim: Color(0xFFFFE6B0),
  );

  static const VoltaActionButtonStyle doubleUp = VoltaActionButtonStyle(
    baseTop: VoltaColors.doubleTop,
    baseBottom: VoltaColors.doubleBottom,
    scrim: 0.35,
    topColors: <Color>[
      Color(0xC7FF7BFF),
      Color(0x96FF53EB),
      Color(0x64FF2BD6),
      Color(0x4BBF20A1),
      Color(0x3280166B),
      Color(0x19400B36),
      Color(0x00000000),
    ],
    topStops: <double>[0, 0.175, 0.35, 0.5125, 0.675, 0.8375, 1],
    bottomColors: <Color>[
      Color(0x8CFF2BD6),
      Color(0x69BF20A1),
      Color(0x4680166B),
      Color(0x23400B36),
      Color(0x00000000),
    ],
    bottomStops: <double>[0, 0.25, 0.5, 0.75, 1],
    rim: Color(0xFFFF7BFF),
  );
}

class VoltaActionButton extends StatelessWidget {
  const VoltaActionButton({
    required this.style,
    required this.size,
    required this.enabled,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  final VoltaActionButtonStyle style;
  final Size size;

  final BorderRadius? borderRadius;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: _shape,
            boxShadow: _shadows,
          ),
          child: ClipRRect(
            borderRadius: _shape,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[style.baseTop, style.baseBottom],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: style.scrim),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: size.height * VoltaActionButtonStyle.bottomExtent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: style.bottomColors,
                        stops: style.bottomStops,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: style.topColors,
                        stops: style.topStops,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(
                    color: style.rim.withValues(alpha: 0.57),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius get _shape => borderRadius ?? _pill;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(1000));

  static const List<BoxShadow> _shadows = <BoxShadow>[
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 1.35),
      blurRadius: 0.675,
    ),
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 4),
  ];
}

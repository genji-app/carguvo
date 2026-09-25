import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/component/mini_bet_unit_item.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_rive_button.dart';

const double kDragonBallLandscapeActionWidth = 240;

class DragonBallLandscapeActionColumn extends StatelessWidget {
  const DragonBallLandscapeActionColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _VHr(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(child: Center(child: _BetUnitRow())),
                _Hr(),
                Expanded(child: Center(child: _CircleButtonsRow())),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BetUnitRow extends ConsumerWidget {
  const _BetUnitRow();

  static const List<(int, String)> _chips = [
    (100, '100'),
    (1000, '1K'),
    (10000, '10K'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bet = ref.watch(dragonBallStateProvider.select((s) => s.bet));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (value, label) in _chips)
          MiniBetUnitItem(
            label: label,
            selected: value == bet,
            height: 36,
            onTap: () =>
                ref.read(dragonBallStateProvider.notifier).selectBet(value),
          ),
      ],
    );
  }
}

class _Hr extends StatelessWidget {
  const _Hr();

  @override
  Widget build(BuildContext context) => ImageHelper.load(
    path: AppIcons.hr,
    width: double.infinity,
    height: 2,
    fit: BoxFit.fill,
  );
}

class _VHr extends StatelessWidget {
  const _VHr();

  @override
  Widget build(BuildContext context) =>
      const RotatedBox(quarterTurns: 1, child: _Hr());
}

class _CircleButtonsRow extends ConsumerWidget {
  const _CircleButtonsRow();

  static const double _sideSize = 44;
  static const double _spinSize = 80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auto = ref.watch(dragonBallStateProvider.select((s) => s.autoSpin));
    final turbo = ref.watch(dragonBallStateProvider.select((s) => s.turbo));
    final notifier = ref.read(dragonBallStateProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LabeledButton(
          label: 'TURBO',
          child: MinipokerRiveButton(
            kind: MinipokerRiveButtonKind.turbo,
            size: _sideSize,
            active: turbo,
            onChanged: notifier.setTurbo,
          ),
        ),
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.spin,
          size: _spinSize,
          onChanged: (_) => notifier.spin(),
        ),
        _LabeledButton(
          label: 'AUTO',
          child: MinipokerRiveButton(
            kind: MinipokerRiveButtonKind.auto,
            size: _sideSize,
            active: auto,
            onChanged: notifier.setAuto,
          ),
        ),
      ],
    );
  }
}

class _LabeledButton extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledButton({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _CircleButtonsRow._sideSize,
      height: _CircleButtonsRow._sideSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            top: _CircleButtonsRow._sideSize + 6,
            left: -20,
            right: -20,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 16 / 10,
                color: AppColorStyles.contentTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

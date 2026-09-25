import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/dragon_ball_state_provider.dart';
import 'package:sun_sports/mini/component/mini_bet_unit_item.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_rive_button.dart';

class DragonBallActionRow extends StatelessWidget {
  const DragonBallActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandLabel(),
          SizedBox(height: 10),
          _BetUnitRow(),
          SizedBox(height: 12),
          _Hr(),
          SizedBox(height: 12),
          _CircleButtonsRow(),
        ],
      ),
    );
  }
}

class _BrandLabel extends StatelessWidget {
  const _BrandLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'DRAGONBALL · SUN88',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 18 / 12,
        letterSpacing: 3,
        color: Colors.white.withValues(alpha: 0.35),
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (value, label) in _chips)
          MiniBetUnitItem(
            label: label,
            selected: value == bet,
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

class _CircleButtonsRow extends ConsumerWidget {
  const _CircleButtonsRow();

  static const double _size = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auto = ref.watch(dragonBallStateProvider.select((s) => s.autoSpin));
    final turbo = ref.watch(dragonBallStateProvider.select((s) => s.turbo));
    final notifier = ref.read(dragonBallStateProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.turbo,
          size: _size,
          active: turbo,
          onChanged: notifier.setTurbo,
        ),
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.spin,
          size: _size,
          onChanged: (_) => notifier.spin(),
        ),
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.auto,
          size: _size,
          active: auto,
          onChanged: notifier.setAuto,
        ),
      ],
    );
  }
}

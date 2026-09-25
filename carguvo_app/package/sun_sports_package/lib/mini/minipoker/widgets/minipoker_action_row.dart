import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/mini_poker_state_provider.dart';
import 'package:sun_sports/mini/component/mini_bet_unit_item.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_rive_button.dart';

class MinipokerActionRow extends StatelessWidget {
  const MinipokerActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MinipokerBetUnitRow(),
          SizedBox(height: 12),
          _Hr(),
          SizedBox(height: 12),
          MinipokerCircleButtonsRow(),
        ],
      ),
    );
  }
}

class MinipokerBetUnitRow extends ConsumerWidget {
  final double chipWidth;
  final double chipHeight;

  final double? gap;

  const MinipokerBetUnitRow({
    this.chipWidth = 56,
    this.chipHeight = 40,
    this.gap,
    super.key,
  });

  static const List<(int, String)> _chips = [
    (100, '100'),
    (1000, '1K'),
    (10000, '10K'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bet = ref.watch(miniPokerStateProvider.select((s) => s.bet));
    final items = [
      for (final (value, label) in _chips)
        MiniBetUnitItem(
          label: label,
          selected: value == bet,
          width: chipWidth,
          height: chipHeight,
          onTap: () =>
              ref.read(miniPokerStateProvider.notifier).selectBet(value),
        ),
    ];
    final g = gap;
    if (g == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, item) in items.indexed) ...[
          if (i > 0) SizedBox(width: g),
          item,
        ],
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

class MinipokerCircleButtonsRow extends ConsumerWidget {
  final double sideSize;

  final double spinSize;

  const MinipokerCircleButtonsRow({
    this.sideSize = 64,
    this.spinSize = 64,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auto = ref.watch(miniPokerStateProvider.select((s) => s.autoSpin));
    final turbo = ref.watch(miniPokerStateProvider.select((s) => s.turbo));
    final notifier = ref.read(miniPokerStateProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.turbo,
          size: sideSize,
          active: turbo,
          onChanged: notifier.setTurbo,
        ),
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.spin,
          size: spinSize,
          onChanged: (_) => notifier.spin(manual: true),
        ),
        MinipokerRiveButton(
          kind: MinipokerRiveButtonKind.auto,
          size: sideSize,
          active: auto,
          onChanged: notifier.setAuto,
        ),
      ],
    );
  }
}

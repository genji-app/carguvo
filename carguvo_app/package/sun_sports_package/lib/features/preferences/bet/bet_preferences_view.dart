import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/preferences/bet/bet.dart';

class BetPreferencesView extends ConsumerWidget {
  const BetPreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch<BetPreferences>(betPreferencesProvider);
    final notifier = ref.watch<BetPreferencesNotifier>(
      betPreferencesProvider.notifier,
    );

    return OddsStyleSelector(
      onChanged: notifier.updateOddsStyle,
      value: state.oddsStyle,
    );
  }
}

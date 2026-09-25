import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_volta_core/volta_notifier.dart';

import 'package:sun_sports/providers/user_provider/user_provider.dart';

import '../data/volta_bet_api.dart';
import '../data/volta_event_source.dart';
import '../data/volta_live_api.dart';
import '../data/volta_live_event_source.dart';
import '../data/volta_results_api.dart';
import '../data/volta_stats_api.dart';
import 'volta_state.dart';

export 'package:game_volta_core/volta_notifier.dart';

final voltaEventSourceProvider = Provider.autoDispose<VoltaEventSource>((ref) {
  final VoltaEventSource source = createVoltaEventSource();
  ref.onDispose(() => unawaited(source.dispose()));
  return source;
});

final voltaBetApiProvider = Provider.autoDispose<VoltaBetApi>(
  (ref) => const VoltaBetApi(),
);

final voltaStatsApiProvider = Provider.autoDispose<VoltaStatsApi>(
  (ref) => const VoltaStatsApi(),
);

final voltaResultsApiProvider = Provider.autoDispose<VoltaResultsApi>(
  (ref) => const VoltaResultsApi(),
);

final voltaLiveApiProvider = Provider.autoDispose<VoltaLiveApi>(
  (ref) => const VoltaLiveApi(),
);

final voltaStateProvider =
    StateNotifierProvider.autoDispose<VoltaNotifier, VoltaState>((ref) {
      final VoltaNotifier notifier = VoltaNotifier(
        _FlutterVoltaAccount(ref),
        ref.watch(voltaEventSourceProvider),
        ref.watch(voltaBetApiProvider),
        ref.watch(voltaStatsApiProvider),
        ref.watch(voltaLiveApiProvider),
        ref.watch(voltaResultsApiProvider),
      );
      ref.listen<double>(
        balanceInVNDProvider,
        (double? _, double next) => notifier.setServerBalance(next),
        fireImmediately: true,
      );
      return notifier;
    });

class _FlutterVoltaAccount extends VoltaAccount {
  const _FlutterVoltaAccount(this._ref);

  final Ref _ref;

  @override
  Future<void> refreshBalance() =>
      _ref.read(userProvider.notifier).refreshBalance();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/providers/infra_provider.dart';

import 'sport_switch_state.dart';
import 'sport_switching_config.dart';
import 'sport_switching_service.dart';

final sportSwitchingServiceProvider = Provider<SportSwitchingService>((ref) {
  final adapter = ref.read(sportSocketAdapterProvider);
  final storage = ref.read(sportStorageProvider);

  final service = SportSwitchingService(
    adapter: adapter,
    storage: storage,
    config: SportSwitchingConfig.defaultConfig,
  );

  ref.onDispose(() => service.dispose());

  return service;
});

final sportSwitchStateProvider = StreamProvider<SportSwitchState>((ref) {
  final service = ref.read(sportSwitchingServiceProvider);
  return service.stateStream;
});

final sportSwitchCurrentSportIdProvider = Provider<int>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.currentSportId ?? 1;
});

final isSportSwitchingProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.isSwitching ?? false;
});

final sportSwitchErrorProvider = Provider<String?>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.errorMessage;
});

final displaySportIdProvider = Provider<int>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.displaySportId ?? 1;
});

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

import 'mini_game_config_loader.dart';
import 'mini_game_remote_config.dart';

final miniGameConfigProvider = FutureProvider<MiniGameRemoteConfig>((ref) {
  return MiniGameConfigLoader().load();
});

final miniGameHostUrlProvider = Provider<String>((ref) {
  final config = ref.watch(miniGameConfigProvider).requireValue;
  return kIsWeb ? config.resourceWebUrl : config.resourceAppUrl;
});

final miniGameWsUrlProvider = Provider<String>((ref) {
  final fromConfig = SbConfig.miniGameWsUrl;
  if (fromConfig.isNotEmpty && fromConfig.startsWith('ws')) return fromConfig;
  return 'wss://websocket.azhkthg1.net/websocket';
});

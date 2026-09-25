import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/features/sport/data/datasources/sport_remote_datasource.dart';
import 'package:sun_sports/features/sport/data/repositories/sport_repository_impl.dart';
import 'package:sun_sports/features/sport/domain/repositories/sport_repository.dart';
import 'package:sun_sports/providers/infra_provider.dart';

final sportRemoteDataSourceProvider = Provider<SportRemoteDataSource>((ref) {
  final httpManager = ref.read(sbHttpManagerProvider);
  final storage = ref.read(sportStorageProvider);
  return SportRemoteDataSourceImpl(httpManager, storage);
});

final sportRepositoryProvider = Provider<SportRepository>((ref) {
  final dataSource = ref.read(sportRemoteDataSourceProvider);
  return SportRepositoryImpl(dataSource);
});

final sportWsSettingUrlProvider = Provider<String>(
  (ref) => ref.read(sbHttpManagerProvider).urlHomeWebsocket,
);

final socketConfigProvider = Provider<socket.SocketConfig>((ref) {
  final cfg = SbConfig.instance.mainConfig;
  final Object? urlOverride = cfg['sport_socket_url'];
  final Object? sampleMs = cfg['sport_socket_sample_ms'];
  final Object? maxParse = cfg['sport_socket_max_parse'];
  final settingUrl = ref.read(sportWsSettingUrlProvider);

  final String url;
  if (urlOverride is String && urlOverride.startsWith('ws')) {
    url = urlOverride;
  } else if (settingUrl.startsWith('wss://')) {
    url = settingUrl;
  } else {
    url = 'wss://nowsgb.sb21.net';
  }

  var config = socket.SocketConfig.liveMode(
    url: url,
    logger: kDebugMode
        ? const socket.ConsoleLogger()
        : const socket.NoOpLogger(),
    useV2Protocol: true,
    v2Language: 'vi',
    autoRefreshConfig: const socket.AutoRefreshConfig(
      refreshInterval: Duration(seconds: 300),
      todayRefreshInterval: Duration(seconds: 600),
      earlyRefreshInterval: Duration(seconds: 600),
    ),
  );
  config = config.copyWith(
    v2BatchInterval: const Duration(seconds: 1),
  );
  if (sampleMs is int && sampleMs > 0) {
    config = config.copyWith(sampleInterval: Duration(milliseconds: sampleMs));
  }
  if (maxParse is int && maxParse > 0) {
    config = config.copyWith(maxParsePerSample: maxParse);
  }
  final Object? v2BatchMs = cfg['sport_socket_v2_batch_ms'];
  if (v2BatchMs is int && v2BatchMs > 0) {
    config = config.copyWith(
      v2BatchInterval: Duration(milliseconds: v2BatchMs),
    );
  }
  return config;
});

final sportSocketAdapterProvider = Provider<SportSocketAdapter>((ref) {
  final config = ref.read(socketConfigProvider);
  final adapter = SportSocketAdapter(config: config);

  ref.onDispose(() {
    adapter.dispose();
  });

  return adapter;
});

final socketConnectionStateProvider = StreamProvider<socket.ConnectionStateEvent>((
  ref,
) {
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onConnectionChanged;
});

final socketDataChangeProvider = StreamProvider<SportSocketUpdate>((ref) {
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onUpdate;
});

final socketMetricsProvider = StreamProvider<socket.ProcessorMetrics>((ref) {
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onMetrics;
});

final isSocketConnectedProvider = Provider<bool>((ref) {
  final state = ref.watch(socketConnectionStateProvider);
  return state.whenOrNull(
        data: (event) => event.currentState == socket.ConnectionState.connected,
      ) ??
      false;
});

final socketConnectionEnumProvider = Provider<socket.ConnectionState>((ref) {
  final state = ref.watch(socketConnectionStateProvider);
  return state.whenOrNull(data: (event) => event.currentState) ??
      socket.ConnectionState.disconnected;
});

final isAdapterInitializedProvider = Provider<bool>((ref) {
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.isInitialized;
});

Future<void> initializeSportSocketAfterLogin(WidgetRef ref) async {
  if (kDebugMode) {
    debugPrint('🚀 [SportSocket] Initializing after login...');
  }

  try {
    final adapter = ref.read(sportSocketAdapterProvider);

    if (adapter.isInitialized) {
      if (kDebugMode) {
        debugPrint('✅ [SportSocket] Already initialized, skipping');
      }
      return;
    }

    final repository = ref.read(sportRepositoryProvider);
    final v2DataSource = ref.read(eventsV2RemoteDataSourceProvider);
    final storage = ref.read(sportStorageProvider);

    final int sportId = await storage.getSportId();

    await adapter.initialize(
      repository: repository,
      v2DataSource: v2DataSource,
      sportId: sportId,
    );

    if (kDebugMode) {
      debugPrint('✅ [SportSocket] Initialized after login - sportId: $sportId');
    }
  } catch (e, st) {
    AppLogger(tag: 'SportSocket')
        .e('Init after login failed', error: e, stackTrace: st);
  }
}

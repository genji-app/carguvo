import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/network/sb_config_loader.dart';
import 'package:sun_sports/features/download_app/data/models/download_app_config.dart';

const String _kDownloadAppConfigUrl =
    'https://raw.githack.com/genji-app/config_download/main/config_download_app.json';

class DownloadAppConfigState {
  const DownloadAppConfigState({
    this.remote,
    this.isLoading = false,
    this.error,
  });

  final DownloadAppRemoteConfig? remote;
  final bool isLoading;
  final String? error;

  bool get hasConfig => remote != null;

  DownloadAppConfig? get platformConfig => remote?.current;

  DownloadAppConfig? get displayConfig => remote?.display;

  DownloadAppConfigState copyWith({
    DownloadAppRemoteConfig? remote,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return DownloadAppConfigState(
      remote: remote ?? this.remote,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const Object _sentinel = Object();
}

class DownloadAppConfigNotifier extends StateNotifier<DownloadAppConfigState> {
  DownloadAppConfigNotifier() : super(const DownloadAppConfigState());

  Future<void> load() async {
    if (state.isLoading || state.hasConfig) return;
    await _fetch();
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    await _fetch();
  }

  Future<void> _fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await SbConfigLoader.getConfigJson(_kDownloadAppConfigUrl);
      final config = DownloadAppRemoteConfig.fromJson(json);
      state = DownloadAppConfigState(remote: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final downloadAppConfigProvider =
    StateNotifierProvider<DownloadAppConfigNotifier, DownloadAppConfigState>(
      (ref) => DownloadAppConfigNotifier(),
    );

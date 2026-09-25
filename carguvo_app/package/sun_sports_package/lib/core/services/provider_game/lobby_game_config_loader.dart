import 'package:flutter/foundation.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';

class LobbyGameConfigLoader {
  LobbyGameConfigLoader._();

  static const String fileName = 'lobbyGameConfig.json';

  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static Future<bool>? _inFlight;

  static Future<bool> load({bool force = false}) {
    if (_loaded && !force) return Future<bool>.value(true);
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  @visibleForTesting
  static void resetForTesting() {
    _loaded = false;
    _inFlight = null;
  }

  static Future<bool> _load() async {
    final raw = await BundleManager.instance.getTextData(
      fileName,
      bundleKey: BundleDefines.dynamic,
    );
    if (raw == null || raw.isEmpty) {
      debugPrint('[LobbyGameConfig] chưa đọc được $fileName → bỏ vòng này');
      return false;
    }

    final manager = ProviderGameManager.instance;
    if (!manager.applyLobbyConfig(raw, fetchGameList: false)) {
      debugPrint('[LobbyGameConfig] $fileName parse lỗi → bỏ');
      return false;
    }

    _loaded = true;
    debugPrint(
      '[LobbyGameConfig] loaded: '
      '${manager.lobbyGameList.length} game, '
      '${manager.environments.length} environment, '
      '${manager.sunGameDetails.length} gameSun '
      '(ẩn ${manager.hiddenSunGameIds.length}, '
      'sắp ra mắt ${manager.comingSoonSunGameIds.length}, '
      'bảo trì ${manager.excludedGameIds.length}), '
      '${manager.categories.length} danh mục',
    );
    return true;
  }
}

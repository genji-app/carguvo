part of '../provider_game_manager.dart';

extension ProviderGameManagerSun on ProviderGameManager {

  bool isSunGame(int gameId) => _sunGameDetails.containsKey(gameId);

  String? sunProviderTagOf(int gameId) =>
      isSunGame(gameId) ? ProviderGameManager.sunProviderTag : null;

  bool isSunGameVisible(int gameId) =>
      isSunGame(gameId) && !_hiddenSunGameIds.contains(gameId);

  SunGameStatus sunGameStatus(int gameId) {
    if (!isSunGame(gameId)) return SunGameStatus.notFound;
    if (!isSunGameVisible(gameId)) return SunGameStatus.hidden;
    if (_excludedGameIds.contains(gameId)) return SunGameStatus.maintenance;
    if (_comingSoonSunGameIds.contains(gameId)) return SunGameStatus.comingSoon;
    return SunGameStatus.active;
  }

  SunGameTag sunGameTag(int gameId) {
    if (!isSunGame(gameId)) return SunGameTag.none;
    if (_comingSoonSunGameIds.contains(gameId)) return SunGameTag.comingSoon;
    if (_newSunGameIds.contains(gameId)) return SunGameTag.newGame;
    return SunGameTag.none;
  }

  List<SunGameDetail> get visibleSunGames {
    final games = _sunGameDetails.values
        .where((g) => isSunGameVisible(g.gameId))
        .toList()
      ..sort((a, b) {
        final byPriority = a.priority.compareTo(b.priority);
        return byPriority != 0 ? byPriority : a.gameId.compareTo(b.gameId);
      });
    return List.unmodifiable(games);
  }

  List<SunGameDetail> visibleSunGamesByCategory(GameItemType category) =>
      List.unmodifiable(
        visibleSunGames.where((g) => g.category.contains(category)),
      );

  List<SunGameDetail> getListSunGameNew() => List.unmodifiable(<SunGameDetail>[
    for (final id in _newSunGameIds)
      if (isSunGameVisible(id)) _sunGameDetails[id]!,
  ]);

  @Deprecated('Đổi tên theo khoá config `newSunGame`; dùng newSunGameIds')
  List<int> getListGameVeeNew() => newSunGameIds;

  List<SunOrientation> resolveSunOrientations(
    int gameId, {
    SunDeviceKind? device,
  }) {
    final game = _sunGameDetails[gameId];
    if (game == null) return const <SunOrientation>[];

    final kind = device ?? ProviderGameManager.currentSunDeviceKind;
    final raw = switch (kind) {
      SunDeviceKind.phone => game.mobileOrientation,
      SunDeviceKind.tablet => game.tabletOrientation,
      SunDeviceKind.desktop => game.desktopOrientation,
    };

    final resolved = SunOrientation.expandAll(raw);
    if (resolved.isNotEmpty) return resolved;

    return switch (kind) {
      SunDeviceKind.phone || SunDeviceKind.tablet => SunOrientation.landscape,
      SunDeviceKind.desktop => SunOrientation.all,
    };
  }

  SunGameUrlResult buildSunGameUrl({
    required int gameId,
    required String accessToken,
    String refreshToken = '',
    SunReturnStrategy? returnStrategy,
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
    String Function(String baseUrl)? baseUrlTransformer,
  }) {
    final status = sunGameStatus(gameId);
    if (!status.isPlayable) return SunUrlBlocked(gameId, status);

    final game = _sunGameDetails[gameId]!;

    switch (game.launchStrategy) {
      case SunLaunchStrategy.native:
        if (game.gameBundle.isEmpty) {
          return SunUrlUnavailable(
            gameId,
            reason: 'game native nhưng thiếu game_bundle',
          );
        }
        return SunUrlNative(gameId, game.gameBundle);
      case SunLaunchStrategy.underDevelopment:
      case SunLaunchStrategy.unknown:
        return SunUrlUnavailable(
          gameId,
          reason: 'launch_strategy = ${game.launchStrategy.name}',
        );
      default:
        break;
    }

    if (game.gameBundle.isEmpty) {
      return SunUrlUnavailable(gameId, reason: 'thiếu game_bundle');
    }
    final rawBaseUrl = _environments[game.gameBundle];
    if (rawBaseUrl == null || rawBaseUrl.isEmpty) {
      return SunUrlUnavailable(
        gameId,
        reason: 'thiếu environments["${game.gameBundle}"]',
      );
    }

    final strategy =
        returnStrategy ??
        (AppDevice.isBrowser
            ? const SunReturnStrategy.webClose()
            : const SunReturnStrategy.appClose());

    SunReturnStrategy resolvedReturn = strategy;
    if (strategy is SunHomeReturn) {
      final homeUrl = _environments['home_uri'];
      if (homeUrl == null || homeUrl.isEmpty) {
        return SunUrlUnavailable(
          gameId,
          reason: 'SunReturnStrategy.home() nhưng thiếu environments["home_uri"]',
        );
      }
      resolvedReturn = SunReturnStrategy.redirect(homeUrl);
    }

    final baseUrl = baseUrlTransformer?.call(rawBaseUrl) ?? rawBaseUrl;
    var uri = Uri.parse(baseUrl);
    if (uri.path.isEmpty) uri = uri.replace(path: '/');

    final params = <String, String>{...uri.queryParameters};

    void putIfAbsent(String key, String value) {
      if (!params.containsKey(key)) params[key] = value;
    }

    final ru = switch (resolvedReturn) {
      SunAppCloseReturn() => 'flutter-app',
      SunWebCloseReturn() => 'flutter-web',
      SunWindowCloseReturn() => 'close',
      SunRedirectReturn(url: final url) => url,
      SunHomeReturn() => 'close',
    };

    void applyIframeReturn() {
      switch (resolvedReturn) {
        case SunAppCloseReturn():
          params['iframeType'] = 'flutter-app';
        case SunWebCloseReturn():
          params['iframeType'] = 'flutter-web';
        case SunWindowCloseReturn():
          params['ru'] = 'close';
        case SunRedirectReturn(url: final url):
          params['ru'] = url;
        case SunHomeReturn():
          params['ru'] = 'close';
      }
    }

    void applyRoomParams() {
      if (serverId != null && serverId > 0) {
        putIfAbsent('serverID', serverId.toString());
      }
      if (roomId != null && roomId > 0) {
        putIfAbsent('roomID', roomId.toString());
      }
      if (roomPassword != null && roomPassword.isNotEmpty) {
        putIfAbsent('roomPassword', roomPassword);
      }
    }

    switch (game.launchStrategy) {
      case SunLaunchStrategy.standard:
        params['accessToken'] = accessToken;
        params['refreshToken'] = refreshToken;
        params['useCardGameWSJson'] = 'true';
        params['ru'] = ru;
        if (extraQueryParams != null) params.addAll(extraQueryParams);
        putIfAbsent('gameID', gameId.toString());
        applyRoomParams();

      case SunLaunchStrategy.fish:
        params['accessToken'] = accessToken;
        params['ru'] = ru;
        if (extraQueryParams != null) params.addAll(extraQueryParams);

      case SunLaunchStrategy.sicbo:
        params['accessToken'] = accessToken;
        params['refreshToken'] = refreshToken;
        params['ru'] = ru;
        params['t'] = DateTime.now().millisecondsSinceEpoch.toString();
        if (extraQueryParams != null) params.addAll(extraQueryParams);

      case SunLaunchStrategy.iframe:
        params['token'] = accessToken;
        if (extraQueryParams != null) params.addAll(extraQueryParams);
        putIfAbsent('gameID', gameId.toString());
        applyIframeReturn();

      case SunLaunchStrategy.card:
        params['accessToken'] = accessToken;
        params['refreshToken'] = refreshToken;
        params['useCardGameWSJson'] = 'true';
        if (extraQueryParams != null) params.addAll(extraQueryParams);
        putIfAbsent('gameID', gameId.toString());
        applyRoomParams();
        applyIframeReturn();

      case SunLaunchStrategy.iframeSession:
        params['accessToken'] = accessToken;
        params['refreshToken'] = refreshToken;
        if (extraQueryParams != null) params.addAll(extraQueryParams);
        applyIframeReturn();

      case SunLaunchStrategy.native:
      case SunLaunchStrategy.underDevelopment:
      case SunLaunchStrategy.unknown:
        return SunUrlUnavailable(
          gameId,
          reason: 'launch_strategy = ${game.launchStrategy.name}',
        );
    }

    return SunUrlSuccess(
      uri.replace(query: _encodeQuery(params)).toString(),
      game,
    );
  }
}

String _encodeQuery(Map<String, String> params) => params.entries
    .map(
      (e) =>
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
    )
    .join('&');

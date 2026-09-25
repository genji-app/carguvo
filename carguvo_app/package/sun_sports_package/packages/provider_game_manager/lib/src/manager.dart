part of '../provider_game_manager.dart';

class ProviderGameManager {
  ProviderGameManager._();

  static ProviderGameManager? _instance;

  static ProviderGameManager get instance =>
      _instance ??= ProviderGameManager._();

  static void resetForTesting() => _instance = null;

  static const int minGoldToPlay = 1000;

  bool init() {
    if (_productInfos.isNotEmpty) return false;
    return restoreGameListFromCache();
  }

  static bool _isRequesting = false;
  static bool get isRequesting => _isRequesting;

  String _url = '';

  // ignore: unnecessary_getters_setters — `_url` còn được mutate nội bộ.
  String get url => _url;

  set url(String value) => _url = value;

  final List<ProductProviderInfo> _productInfos = <ProductProviderInfo>[];

  List<ProductProviderInfo> get productInfos =>
      List.unmodifiable(_productInfos);

  final Map<int, ProductProviderInfo> _mapProductByGameId =
      <int, ProductProviderInfo>{};
  Map<int, ProductProviderInfo> get mapProductByGameId =>
      Map.unmodifiable(_mapProductByGameId);

  final Map<String, ProductProviderInfo> _mapProductByCodeFull =
      <String, ProductProviderInfo>{};
  Map<String, ProductProviderInfo> get mapProductByCodeFull =>
      Map.unmodifiable(_mapProductByCodeFull);

  final Map<String, ProductProviderInfo> _mapProductByCode =
      <String, ProductProviderInfo>{};

  Map<String, ProductProviderInfo> get mapProductByCode =>
      Map.unmodifiable(_mapProductByCode);

  final Map<String, ProviderOverride> _providerOverrides = <String, ProviderOverride>{};

  final Map<String, String> _apiGameCodes = <String, String>{};

  final Map<int, int> _sunLoadStopDebounceMs = <int, int>{};

  bool _hasConfigExternalGames = false;

  bool get hasConfigExternalGames => _hasConfigExternalGames;

  Map<String, ProviderOverride> get providerOverrides =>
      Map.unmodifiable(_providerOverrides);

  ProviderOverride? providerOverrideOf(String providerId) =>
      _providerOverrides[providerId];

  final List<ProviderDetail> _providerDetails = <ProviderDetail>[];
  List<ProviderDetail> get providerDetails =>
      List.unmodifiable(_providerDetails);

  final Map<GameItemType, List<String>> _providerByCategory =
      <GameItemType, List<String>>{};
  Map<GameItemType, List<String>> get providerByCategory =>
      Map.unmodifiable(_providerByCategory);

  final Map<String, int> _lobbyGameList = <String, int>{};

  Map<String, int> get lobbyGameList => Map.unmodifiable(_lobbyGameList);

  List<int> _excludedGameIds = <int>[];

  List<int> get excludedGameIds => List.unmodifiable(_excludedGameIds);

  final Map<String, String> _environments = <String, String>{};

  Map<String, String> get environments => Map.unmodifiable(_environments);

  final Map<int, SunGameDetail> _sunGameDetails = <int, SunGameDetail>{};
  Map<int, SunGameDetail> get sunGameDetails =>
      Map.unmodifiable(_sunGameDetails);

  List<String> _newGameList = <String>[];
  List<String> get newGameList => List.unmodifiable(_newGameList);

  List<int> _newSunGameIds = <int>[];

  List<int> get newSunGameIds => List.unmodifiable(_newSunGameIds);

  @Deprecated('Đổi tên theo khoá config `newSunGame`; dùng newSunGameIds')
  List<int> get newGameVeeList => newSunGameIds;

  List<int> _comingSoonSunGameIds = <int>[];

  List<int> get comingSoonSunGameIds => List.unmodifiable(_comingSoonSunGameIds);

  List<int> _hiddenSunGameIds = <int>[];

  List<int> get hiddenSunGameIds => List.unmodifiable(_hiddenSunGameIds);

  final Map<String, List<Object>> _displayCollections =
      <String, List<Object>>{};

  Map<String, List<Object>> get displayCollections =>
      Map.unmodifiable(_displayCollections);

  final List<LobbySection> _lobbySections = <LobbySection>[];

  List<LobbySection> get lobbySections => List.unmodifiable(_lobbySections);

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  bool get hasGameList => _productInfos.isNotEmpty;

  bool _isRestoredFromCache = false;

  bool get isRestoredFromCache => _isRestoredFromCache;

  final StreamController<void> _lobbyConfigCtrl =
      StreamController<void>.broadcast();
  final StreamController<void> _updateListCtrl =
      StreamController<void>.broadcast();
  final StreamController<void> _closeCtrl =
      StreamController<void>.broadcast();

  Stream<void> get onLobbyGameConfigLoaded => _lobbyConfigCtrl.stream;

  Stream<void> get onUpdateGameList => _updateListCtrl.stream;

  Stream<void> get onCloseGameProvider => _closeCtrl.stream;

  void emitCloseGameProvider() => _closeCtrl.add(null);

  Future<void> dispose() async {
    await _lobbyConfigCtrl.close();
    await _updateListCtrl.close();
    await _closeCtrl.close();
  }

  static const int _maxSafe = 0x1FFFFFFFFFFFFF;

  String getApiUrl() => base64Encode(utf8.encode('$_url/get-url'));

  bool applyLobbyConfig(String raw, {bool fetchGameList = true}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (err) {
      _log('Failed to parse lobby game config. ($err)', error: true);
      return false;
    }
    final res = _asMap(decoded);
    if (res == null) {
      _log('Failed to parse lobby game config.', error: true);
      return false;
    }

    final configUrl = res['url'];
    if (_url.isEmpty &&
        configUrl is String &&
        configUrl.trim().isNotEmpty) {
      _url = configUrl.trim();
    }

    _newGameList = [
      for (final v in (res['newGame'] as List? ?? const [])) v.toString(),
    ];
    _newSunGameIds = _intList(res['newSunGame'] ?? res['newVeeGame']);

    _lobbyGameList.clear();
    final gameList = res['gameList'] as List? ?? const [];
    for (var i = 0; i < gameList.length; i++) {
      _lobbyGameList[gameList[i].toString()] =
          i + 1;
    }

    _providerDetails.clear();
    final providerType = res['providerType'] as List? ?? const [];
    for (var i = 0; i < providerType.length; i++) {
      _providerDetails.add(
        ProviderDetail()
          ..providerId = providerType[i].toString()
          ..priority = i,
      );
    }

    _providerByCategory.clear();
    final byCategory = res['providerByCategory'];
    if (byCategory is Map) {
      byCategory.forEach((key, value) {
        if (value is! List) return;
        final arr = value.map((v) => v.toString()).toList()
          ..sort(
            (a, b) => _providerPriority(a).compareTo(_providerPriority(b)),
          );
        _providerByCategory[GameItemType.forName(key.toString())] = arr;
      });
    }

    _providerOverrides.clear();
    final overrides = res['providerOverrides'];
    if (overrides is Map) {
      overrides.forEach((key, value) {
        final map = _asMap(value);
        if (map == null) return;
        _providerOverrides[key.toString()] = ProviderOverride.fromJson(map);
      });
    }
    _applyProviderGameTypeOverrides();

    _applyExternalGames(res['externalGames']);

    _sunLoadStopDebounceMs.clear();
    final sunOverrides = res['sunGameOverrides'];
    if (sunOverrides is Map) {
      sunOverrides.forEach((key, value) {
        final id = int.tryParse(key.toString());
        final map = _asMap(value);
        if (id == null || map == null) return;
        final ms = (map['load_stop_debounce_ms'] as num?)?.toInt();
        if (ms != null) _sunLoadStopDebounceMs[id] = ms;
      });
    }

    _excludedGameIds = _intList(res['excludedGameIds']);

    _comingSoonSunGameIds = _intList(res['gameSunComingSoon']);

    _hiddenSunGameIds = _intList(res['gameSunHidden']);

    _categoryIds
      ..clear()
      ..addAll(<String>[
        for (final v in (res['categories'] as List? ?? const []))
          if (v.toString().trim().isNotEmpty) v.toString().trim(),
      ]);

    _displayCollections.clear();
    final collections = res['displayCollections'];
    if (collections is Map) {
      collections.forEach((key, value) {
        if (value is! List) return;
        _displayCollections[key.toString()] = <Object>[
          for (final v in value)
            if (v is num) v.toInt() else v.toString(),
        ];
      });
    }

    _lobbySections
      ..clear()
      ..addAll(<LobbySection>[
        for (final s in ((res['lobby'] as Map?)?['sections'] as List? ?? const []))
          if (_asMap(s) case final Map<String, dynamic> section?)
            LobbySection.fromJson(section),
      ]);

    _environments.clear();
    final environments = res['environments'];
    if (environments is Map) {
      environments.forEach((key, value) {
        _environments[key.toString()] = value.toString();
      });
    }

    _sunGameDetails.clear();
    final sunConfig = res['gameSun'];
    if (sunConfig is Map) {
      sunConfig.forEach((key, detail) {
        final d = _asMap(detail);
        if (d == null) return;
        final gameDetail = SunGameDetail()
          ..gameId = int.tryParse(key.toString()) ?? 0
          ..name = [
            for (final v in (d['name'] as List? ?? const [])) v.toString(),
          ]
          ..priority = (d['priority'] as num?)?.toInt() ?? 0
          ..category = [
            for (final c in (d['cat'] as List? ?? const []))
              GameItemType.forName(c.toString()),
          ]
          ..mobileOrientation = [
            for (final v in (d['mobile_orientation'] as List? ?? const []))
              v.toString(),
          ]
          ..tabletOrientation = [
            for (final v in (d['tablet_orientation'] as List? ?? const []))
              v.toString(),
          ]
          ..desktopOrientation = [
            for (final v in (d['desktop_orientation'] as List? ?? const []))
              v.toString(),
          ]
          ..gameBundle = d['game_bundle']?.toString() ?? ''
          ..launchStrategy = SunLaunchStrategy.fromName(
            d['launch_strategy']?.toString(),
          );
        _sunGameDetails[gameDetail.gameId] = gameDetail;
      });
    }
    _log('Loaded lobby game config');
    if (!fetchGameList) {
      _log('bỏ qua getGameList (fetchGameList=false) — host tự gọi khi cần');
    } else if (_url.isEmpty) {
      _log('bỏ qua getGameList: url rỗng', error: true);
    } else {
      unawaited(getGameList());
    }
    _lobbyConfigCtrl.add(null);
    return true;
  }

  void _applyProviderGameTypeOverrides() {
    final targets = <GameItemType, List<String>>{};
    for (final entry in _providerOverrides.entries) {
      final ov = entry.value;
      if (ov.gameType == null || ov.gameType!.isEmpty) continue;
      final overrideKey = GameItemType.forName(ov.gameType!);
      for (final list in _providerByCategory.values) {
        list.removeWhere((pid) => pid == entry.key);
      }
      targets.putIfAbsent(overrideKey, () => <String>[]).add(entry.key);
    }
    targets.forEach((key, pids) {
      final target = _providerByCategory.putIfAbsent(key, () => <String>[]);
      for (final pid in pids) {

        if (!target.contains(pid)) target.add(pid);
      }
    });

    for (final list in _providerByCategory.values) {

      list.sort((a, b) => _providerPriority(a).compareTo(_providerPriority(b)));
    }
  }

  int _providerPriority(String providerId) {
    for (final detail in _providerDetails) {
      if (detail.providerId == providerId) return detail.priority;
    }
    return _maxSafe;
  }

  int _lobbyPriority(ProductProviderInfo info) =>
      _lobbyGameList[info.fullCode] ?? _maxSafe;

  List<String> getProviderTypeByGameType(GameItemType category) {
    if (category == GameItemType.none) {
      return _providerDetails.map((detail) => detail.providerId).toList();
    }
    return _providerByCategory[category] ?? <String>[];
  }

  Future<void> getGameList() => sendGetGameList();

  List<ProductProviderInfo> getListNewGame() {
    final ret = <ProductProviderInfo>[];
    for (final codeNew in _newGameList) {
      final prodInfo = _mapProductByCodeFull[codeNew];
      if (prodInfo != null) {
        ret.add(prodInfo);
      } else {
        _log('Not found product info for new game: $codeNew', error: true);
      }
    }
    return ret;
  }

  List<String> get recentGameRefs {
    final raw = AppStorage.get(recentGamesKey);
    if (raw == null || raw.isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <String>[];
      final refs = <String>[
        for (final v in decoded)
          if (v is num && v.toInt() > 0)
            v.toInt().toString()
          else if (v is String && v.trim().isNotEmpty)
            v.trim(),
      ];
      return List.unmodifiable(refs.take(maxRecentGames));
    } catch (err) {
      _log('recentGameRefs: cache hỏng ($err) → coi như rỗng', error: true);
      return const <String>[];
    }
  }

  List<int> get recentGameIds {
    final ids = <int>[];
    for (final ref in recentGameRefs) {
      final id = int.tryParse(ref);
      if (id != null) ids.add(id);
    }
    return ids;
  }

  List<String> pushRecentGameRef(String ref) {
    final key = ref.trim();
    if (key.isEmpty) return recentGameRefs;
    final next = <String>[key, ...recentGameRefs.where((r) => r != key)];
    if (next.length > maxRecentGames) {
      next.removeRange(maxRecentGames, next.length);
    }
    if (!AppStorage.set(recentGamesKey, jsonEncode(next))) {
      _log('pushRecentGame: không ghi được storage', error: true);
    }
    return List.unmodifiable(next);
  }

  void pushRecentLobbyGame(LobbyGame game) => pushRecentGameRef(game.ref);

  List<int> pushRecentGame(int gameId) {
    if (gameId <= 0) return recentGameIds;
    pushRecentGameRef(gameId.toString());
    return recentGameIds;
  }

  void clearRecentGames() => AppStorage.remove(recentGamesKey);

  List<ProductProviderInfo> getListRecentGame() {
    final ret = <ProductProviderInfo>[];
    for (final ref in recentGameRefs) {
      final prodInfo = _recentProviderGame(ref);
      if (prodInfo != null) {
        ret.add(prodInfo);
      } else {
        _log('Not found product info for recent game: $ref', error: true);
      }
    }
    return ret;
  }

  ProductProviderInfo? _recentProviderGame(String ref) {
    final gameId = int.tryParse(ref);
    if (gameId != null) return _mapProductByGameId[gameId];
    return _providerGameByRef(ref, applyLobbyWhitelist: false);
  }

  Future<LobbyGameUrl> gameUrlOf(
    LobbyGame game, {
    String accessToken = '',
    String refreshToken = '',
    SunReturnStrategy? returnStrategy,
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
    String Function(String baseUrl)? baseUrlTransformer,
  }) async {
    final LobbyGameUrl result;
    switch (game) {
      case SunLobbyGame():
        final sunResult = buildSunGameUrl(
          gameId: game.gameId,
          accessToken: accessToken,
          refreshToken: refreshToken,
          returnStrategy: returnStrategy,
          serverId: serverId,
          roomId: roomId,
          roomPassword: roomPassword,
          extraQueryParams: extraQueryParams,
          baseUrlTransformer: baseUrlTransformer,
        );
        result = switch (sunResult) {
          SunUrlSuccess(:final url) => LobbyGameUrlReady(url, game),
          SunUrlNative(:final gameBundle) =>
            LobbyGameUrlNative(gameBundle, game),
          SunUrlBlocked(:final status) => LobbyGameUrlBlocked(status, game),
          SunUrlUnavailable(:final reason) =>
            LobbyGameUrlUnavailable(game, reason: reason),
        };

      case ProviderLobbyGame():
        if (_url.isEmpty) {
          result = LobbyGameUrlUnavailable(
            game,
            reason: 'chưa gán ProviderGameManager.url',
          );
        } else {
          final request = ProductProviderInfo()
            ..providerId = game.providerId
            ..providerName = game.providerName
            ..productId = game.productId
            ..gameName = game.gameName
            ..gameCode = game.effectiveApiGameCode
            ..gameId = game.gameId;
          final url = await getProductUrl(request);
          if (url == '-1' || url.isEmpty) {
            result = LobbyGameUrlUnavailable(
              game,
              reason: 'get-url trả -1 cho ${game.ref}',
            );
          } else {
            result = LobbyGameUrlReady(url, game);
          }
        }
    }

    if (result is LobbyGameUrlReady || result is LobbyGameUrlNative) {
      pushRecentLobbyGame(game);
    }
    return result;
  }

  static const String sunProviderTag = 'tag_sunwin.webp';

  static const String sunProviderId = 'sunwin';

  static const String sunProviderName = 'Sunwin';
  final List<String> _categoryIds = <String>[];
  List<String> get categoryIds => List.unmodifiable(_categoryIds);
  static SunDeviceKind get currentSunDeviceKind {
    if (AppDevice.isTablet) return SunDeviceKind.tablet;
    if (AppDevice.isMobile) return SunDeviceKind.phone;
    return SunDeviceKind.desktop;
  }
  String? getEnvironmentByGameBundle(String gameBundle) =>
      _environments[gameBundle];

  String? getEnvironmentByGameId(int gameId) {
    final detail = _sunGameDetails[gameId];
    if (detail == null || detail.gameBundle.isEmpty) return null;
    return _environments[detail.gameBundle];
  }

  FilteredGameList getGameListFiltered(
    GameItemType category, {
    String providerId = '',
    String productId = '',
  }) {
    final ret = FilteredGameList();
    if (category == GameItemType.none && providerId.isEmpty) {
      return ret;
    } else if (category == GameItemType.newGame) {
      ret.listProviderGame = getListNewGame();
    } else if (category == GameItemType.recent) {
      ret.listProviderGame = getListRecentGame();
    } else {
      List<ProductProviderInfo> listProviderGame;
      if (providerId.isEmpty || providerId == 'NONE') {
        listProviderGame = getGameListByCategory(category);
      } else {
        listProviderGame =
            getGameListByProvider(providerId)
                .where(
                  (info) =>
                      info.gameType.contains(category.index) ||
                      category == GameItemType.none,
                )
                .where(
                  (info) =>
                      info.productId == productId || productId.isEmpty,
                )
                .toList()
              ..sort(_byLobbyPriority);
      }
      ret.listProviderGame = listProviderGame;
    }
    return ret;
  }

  List<ProductProviderInfo> getGameListByCategory(GameItemType category) {
    return _productInfos
        .where(
          (info) =>
              info.gameType.contains(category.index) &&
              _lobbyGameList.containsKey(info.fullCode),
        )
        .toList()
      ..sort(_byLobbyPriority);
  }

  List<ProductProviderInfo> getGameListByProvider(String providerId) {
    return _productInfos
        .where(
          (info) =>
              info.providerId == providerId &&
              _lobbyGameList.containsKey(info.fullCode),
        )
        .toList();
  }

  int _byLobbyPriority(ProductProviderInfo a, ProductProviderInfo b) =>
      _lobbyPriority(a).compareTo(_lobbyPriority(b));

  ProductProviderInfo? getProductInfos(String gameCode) {
    for (final info in _productInfos) {
      if (info.gameCode == gameCode) return info;
    }
    return null;
  }

  ProductProviderInfo? getProductInfoByProductId(String productId) {
    for (final info in _productInfos) {
      if (info.productId == productId) return info;
    }
    return null;
  }

  ProductProviderInfo? getProductInfoFromGameName(
    String gameName, [
    String providerName = '',
  ]) {
    return getProductInfoByProductId(gameName);
  }

  ProductProviderInfo? getProductInfoByGameId(int gameId) =>
      _mapProductByGameId[gameId];

  Future<String> getProductUrlFromGameCode(String gameCode) async {
    final product = getProductInfos(gameCode);
    if (product == null) {
      _log('Product not found for game code: $gameCode', error: true);
      return '-1';
    }
    return getProductUrl(product);
  }

  Future<String> getProductUrl(ProductProviderInfo product) async {
    final data = <String, dynamic>{
      'providerId': product.providerId,
      'productId': product.productId,
      'gameCode': product.gameCode,
      'extra': <String, dynamic>{
        'isMobileLogin': AppDevice.isMobile,
        'lang': AppSession.language,
      },
    };
    if (AppDevice.isBrowser) {
      final home = AppDevice.pageUrl;
      if (home != null) data['homeUrl'] = home;
    }

    final response = await AppHttp.post(
      '$_url/get-url',
      jsonEncode(data),
      headers: _authHeaders,
    );
    if (response == null) {
      return '-1';
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(response);
    } catch (_) {
      return '-1';
    }
    final resp = _asMap(decoded);
    if (resp != null && resp['status'] == 0) {
      final url = _asMap(resp['data'])?['url']?.toString();
      return (url == null || url.isEmpty) ? '-1' : url;
    }
    return '-1';
  }

  static Map<String, String>? get _authHeaders {
    final token = AppSession.accessToken;
    return token.isEmpty ? null : <String, String>{'Authorization': token};
  }

  static const String gameListCacheKey = 'ProviderGameManager.gameList';

  static const String recentGamesKey = 'ProviderGameManager.recentGames';

  static const int maxRecentGames = 10;

  Future<void> sendGetGameList() async {
    final response = await AppHttp.get('$_url/games', headers: _authHeaders);
    if (response == null) {
      _log('No response received for provider game list.', error: true);
      return;
    }

    _isLoaded = true;
    if (_applyGameList(response)) {
      _saveGameListCache(response);
      _isRestoredFromCache = false;
    }
    _updateListCtrl.add(null);
  }

  bool restoreGameListFromCache() {
    final raw = AppStorage.get(gameListCacheKey);
    if (raw == null || raw.isEmpty) return false;

    if (!_applyGameList(raw)) {
      _log('restoreGameListFromCache: cache không dùng được', error: true);
      return false;
    }
    _isRestoredFromCache = true;
    _log('Restored ${_productInfos.length} game từ cache');
    _updateListCtrl.add(null);
    return true;
  }

  void _saveGameListCache(String raw) {
    if (!AppStorage.set(gameListCacheKey, raw)) {
      _log('sendGetGameList: không ghi được cache danh sách game', error: true);
    }
  }

  bool _applyGameList(String response) {
    final Object? decoded;
    try {
      decoded = jsonDecode(response);
    } catch (err) {
      _log('sendGetGameList: JSON lỗi: $err', error: true);
      return false;
    }
    final res = _asMap(decoded);
    if (res == null) {
      _log('sendGetGameList: body không phải object', error: true);
      return false;
    }

    if (res['status'] != 0) {
      _log('Failed to fetch game list: ${res['message']}', error: true);
      return false;
    }

    _rebuildProductInfos(res['data'] as List? ?? const []);
    return true;
  }

  void _applyExternalGames(Object? raw) {
    _apiGameCodes.clear();
    if (raw is! List || raw.isEmpty) {
      _hasConfigExternalGames = false;
      return;
    }

    _rebuildProductInfos(raw);
    _hasConfigExternalGames = true;

    for (final providerGroup in raw) {
      final group = _asMap(providerGroup);
      final providerId = group?['providerId']?.toString() ?? '';
      final gameList = group?['gameList'];
      if (gameList is! List) continue;
      for (final itemRaw in gameList) {
        final item = _asMap(itemRaw);
        if (item == null) continue;
        final code = item['apiGameCode']?.toString();
        if (code == null || code.isEmpty) continue;
        final shortCode =
            '${providerId}_${item['productId'] ?? ''}_${item['gameCode'] ?? ''}';
        _apiGameCodes[shortCode] = code;
      }
    }

    if (_lobbyGameList.isEmpty) {
      var priority = 1;
      for (final info in _productInfos) {
        _lobbyGameList[info.fullCode] = priority++;
      }
    }

    _log('externalGames: ${_productInfos.length} game NCC từ config');
  }

  void _rebuildProductInfos(List data) {
    _productInfos.clear();
    _mapProductByGameId.clear();
    _mapProductByCodeFull.clear();
    _mapProductByCode.clear();

    for (final providerGroup in data) {
      final group = _asMap(providerGroup);
      if (group == null) continue;
      final gameList = group['gameList'];
      if (gameList is! List) continue;

      gameList.sort((a, b) {
        final ma = _asMap(a);
        final mb = _asMap(b);
        if (ma == null || mb == null) return 0;
        final pa = ma['productId']?.toString() ?? '';
        final pb = mb['productId']?.toString() ?? '';
        if (pa == pb) {
          return (ma['gameName']?.toString() ?? '')
              .compareTo(mb['gameName']?.toString() ?? '');
        }
        return pa.compareTo(pb);
      });

      for (final itemRaw in gameList) {
        final item = _asMap(itemRaw);
        if (item == null) continue;
        final info = ProductProviderInfo()
          ..providerName = group['providerName']?.toString() ?? ''
          ..providerId = group['providerId']?.toString() ?? ''
          ..productId = item['productId']?.toString() ?? ''
          ..gameName = item['gameName']?.toString() ?? ''
          ..gameCode = item['gameCode']?.toString() ?? ''
          ..gameType = [
            for (final t in (item['gameType'] as List? ?? const []))
              (t as num).toInt(),
          ]
          ..gameId = (item['gameId'] as num?)?.toInt() ?? 0;

        final extra = _asMap(item['extra']);
        final orientationRaw = extra?['orientation'];
        info.orientation =
            orientationRaw is num
                ? DefineOrientation.fromServerValue(orientationRaw.toInt())
                : DefineOrientation.portrait;

        _productInfos.add(info);
        _mapProductByGameId[info.gameId] = info;
        _mapProductByCodeFull[info.fullCode] = info;
        _mapProductByCode[info.shortCode] = info;
      }
    }
  }

  static Future<ProviderGamePlayDecision> resolvePlay(int gameId) async {
    final manager = ProviderGameManager.instance;
    if (_isRequesting) {
      _log('A request is already in progress. Please wait.', error: true);
      return const PlayDecisionBusy();
    }

    if (!AppSession.isLoggedIn) return const PlayDecisionNeedLogin();
    if (manager._excludedGameIds.contains(gameId)) {
      return PlayDecisionGameMaintaining(gameId);
    }
    final gold = AppSession.gold;
    if (gold < minGoldToPlay) {
      return PlayDecisionNotEnoughMoney(gold, minGoldToPlay);
    }

    final productInfo = manager.getProductInfoByGameId(gameId);
    if (productInfo == null) {
      return PlayDecisionUnavailable(gameId, reason: 'không có product info');
    }

    if (AppDevice.isBrowser &&
        AppDevice.isMobile &&
        productInfo.orientation == DefineOrientation.landscape) {
      final providerGameUrl =
          '${AppDevice.pageBaseUrl}provider/index.html'
          '?token=${AppSession.accessToken}'
          '&gameCode=${productInfo.gameCode}'
          '&providerId=${productInfo.providerId}'
          '&productId=${productInfo.productId}'
          '&isMobileLogin=${AppDevice.isMobile}'
          '&lang=${AppSession.language}'
          '&api=${manager.getApiUrl()}';
      _log('Opening game URL: $providerGameUrl');
      return PlayDecisionOpenInNewTab(providerGameUrl, productInfo);
    }

    _isRequesting = true;
    try {
      final url = await manager.getProductUrlFromGameCode(
        productInfo.gameCode,
      );
      if (url == '-1') {
        return PlayDecisionUnavailable(gameId, reason: 'get-url trả -1');
      }
      manager.pushRecentGameRef(productInfo.shortCode);
      return PlayDecisionPlay(url, productInfo);
    } catch (err) {
      _log('Failed to get product URL: $err', error: true);
      return PlayDecisionUnavailable(gameId, reason: '$err');
    } finally {
      _isRequesting = false;
    }
  }

  static Map<String, dynamic>? _asMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static List<int> _intList(Object? value) {
    if (value is! List) return <int>[];
    return <int>[
      for (final v in value)
        if (v is num) v.toInt() else int.tryParse(v.toString()) ?? -1,
    ]..removeWhere((id) => id < 0);
  }
}

void _log(String message, {bool error = false}) {
  providerGameManagerLog?.call(
    '[ProviderGameManager]${error ? ' [E]' : ''} $message',
    isError: error,
  );
}

final ProviderGameManager providerGameManager = ProviderGameManager.instance;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:sun_sports/core/services/provider_game/game_api_client_provider.dart';

enum NccProvider {
  ksport(apiProviderId: null, apiGameCode: null),

  saba(apiProviderId: 'saba', apiGameCode: 'saba'),

  bti(apiProviderId: 'bti', apiGameCode: 'SporstBook'),

  imSport(apiProviderId: 'inplay_matrix', apiGameCode: 'sportbook');

  static const NccProvider imEsport = NccProvider.imSport;

  const NccProvider({required this.apiProviderId, required this.apiGameCode});

  final String? apiProviderId;

  final String? apiGameCode;

  bool get isSportbookLaunch => apiProviderId != null;
}

class NccLaunchException implements Exception {
  const NccLaunchException(this.message);

  final String message;

  @override
  String toString() => 'NccLaunchException: $message';
}

sealed class NccLaunchResult {
  const NccLaunchResult();
}

class NccLaunchSuccess extends NccLaunchResult {
  const NccLaunchSuccess(this.url);

  final String url;
}

class NccLaunchFailure extends NccLaunchResult {
  const NccLaunchFailure(this.message);

  final String message;
}

class NccLaunchCancelled extends NccLaunchResult {
  const NccLaunchCancelled();
}

class NccSportbookLauncher {
  const NccSportbookLauncher(this._client);

  final gac.GameApiClient _client;

  Future<String> fetchLaunchUrl(NccProvider provider) async {
    final providerId = provider.apiProviderId;
    final gameCode = provider.apiGameCode;
    if (providerId == null || gameCode == null) {
      throw NccLaunchException('NCC ${provider.name} không hỗ trợ launch URL');
    }

    final providers = await _client.getGames();
    gac.ProviderGames? matchedProvider;
    for (final p in providers) {
      if (p.providerId.toLowerCase().trim() == providerId) {
        matchedProvider = p;
        break;
      }
    }
    if (matchedProvider == null) {
      throw const NccLaunchException('NCC chưa sẵn sàng');
    }

    gac.Game? matchedGame;
    for (final g in matchedProvider.gameList) {
      if (g.gameCode == gameCode ||
          g.gameCode.toLowerCase() == gameCode.toLowerCase()) {
        matchedGame = g;
        break;
      }
    }
    if (matchedGame == null) {
      throw const NccLaunchException('NCC chưa sẵn sàng');
    }

    return _client.getGameUrl(
      gac.GetGameUrlRequest(
        providerId: matchedProvider.providerId,
        productId: matchedGame.productId,
        gameCode: matchedGame.gameCode,
        lang: 'vi',
        isMobileLogin: false,
      ),
    );
  }
}

class NccLaunchNotifier extends StateNotifier<NccProvider?> {
  NccLaunchNotifier(this._launcher) : super(null);

  final NccSportbookLauncher _launcher;

  int _requestId = 0;

  Future<NccLaunchResult> launch(NccProvider provider) async {
    if (state != null) return const NccLaunchCancelled();

    final id = ++_requestId;
    state = provider;
    try {
      final url = await _launcher.fetchLaunchUrl(provider);
      if (id != _requestId) return const NccLaunchCancelled();
      return NccLaunchSuccess(url);
    } on NccLaunchException catch (e) {
      return NccLaunchFailure(e.message);
    } catch (_) {
      return const NccLaunchFailure('Không thể mở nhà cung cấp');
    } finally {
      if (id == _requestId) state = null;
    }
  }
}

final nccSportbookLauncherProvider = Provider<NccSportbookLauncher>(
  (ref) => NccSportbookLauncher(ref.watch(gameApiClientProvider)),
);

final nccLaunchProvider =
    StateNotifierProvider<NccLaunchNotifier, NccProvider?>(
      (ref) => NccLaunchNotifier(ref.watch(nccSportbookLauncherProvider)),
    );

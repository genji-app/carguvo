import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/favorite_data.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'league_provider.dart';
import 'package:sun_sports/core/services/providers/reconnect_aware.dart';
import 'package:sun_sports/core/services/providers/reconnect_coordinator.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';

class FavoriteState {
  final Map<int, FavoriteData> favoritesBySport;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  final Map<int, List<LeagueModelV2>> favoriteEventsLeaguesBySport;
  final Map<int, bool> favoriteEventsLoadingBySport;
  final Map<int, String?> favoriteEventsErrorBySport;

  const FavoriteState({
    this.favoritesBySport = const {},
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.favoriteEventsLeaguesBySport = const {},
    this.favoriteEventsLoadingBySport = const {},
    this.favoriteEventsErrorBySport = const {},
  });

  FavoriteData? getFavoriteData(int sportId) => favoritesBySport[sportId];

  List<LeagueModelV2>? getFavoriteEventsLeagues(int sportId) =>
      favoriteEventsLeaguesBySport[sportId];

  bool isFavoriteEventsLoading(int sportId) =>
      favoriteEventsLoadingBySport[sportId] == true;

  String? getFavoriteEventsError(int sportId) =>
      favoriteEventsErrorBySport[sportId];

  bool isLeagueFavorite(int sportId, int leagueId) {
    final data = getFavoriteData(sportId);
    return data?.isLeagueFavorite(leagueId) ?? false;
  }

  bool isEventFavorite(int sportId, int eventId) {
    final data = getFavoriteData(sportId);
    return data?.isEventFavorite(eventId) ?? false;
  }

  FavoriteState copyWith({
    Map<int, FavoriteData>? favoritesBySport,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
    Map<int, List<LeagueModelV2>>? favoriteEventsLeaguesBySport,
    Map<int, bool>? favoriteEventsLoadingBySport,
    Map<int, String?>? favoriteEventsErrorBySport,
  }) {
    return FavoriteState(
      favoritesBySport: favoritesBySport ?? this.favoritesBySport,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      favoriteEventsLeaguesBySport:
          favoriteEventsLeaguesBySport ?? this.favoriteEventsLeaguesBySport,
      favoriteEventsLoadingBySport:
          favoriteEventsLoadingBySport ?? this.favoriteEventsLoadingBySport,
      favoriteEventsErrorBySport:
          favoriteEventsErrorBySport ?? this.favoriteEventsErrorBySport,
    );
  }
}

final StateNotifierProvider<FavoriteNotifier, FavoriteState> favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
      final notifier = FavoriteNotifier(ref);
      final coordinator = ref.read(reconnectCoordinatorProvider);
      final reconnectCb = () =>
          ref.read(favoriteProvider.notifier).refreshOnReconnect();
      coordinator.register(reconnectCb);
      ref.onDispose(() => coordinator.unregister(reconnectCb));

      ref.listen(userInfoProvider.select((u) => u?.custId), (previous, next) {
        if (previous != next) {
          notifier.reset();
        }
      });

      return notifier;
    });

class FavoriteNotifier extends StateNotifier<FavoriteState>
    implements ReconnectAware {
  final Ref _ref;
  final SbHttpManager _httpManager;
  CancelToken? _cancelToken;
  CancelToken? _favoriteEventsCancelToken;

  FavoriteNotifier(this._ref)
    : _httpManager = SbHttpManager.instance,
      super(const FavoriteState());

  @override
  void dispose() {
    _cancelToken?.cancel();
    _favoriteEventsCancelToken?.cancel();
    super.dispose();
  }

  @override
  void refreshOnReconnect() {
    final sportId = _ref.read(currentSportIdProvider);
    fetchFavoriteEvents(sportId);
  }

  void reset() {
    _cancelToken?.cancel();
    _favoriteEventsCancelToken?.cancel();
    state = const FavoriteState();
  }

  void invalidateFavoriteEventsCache(int sportId) {
    if (!state.favoriteEventsLeaguesBySport.containsKey(sportId)) return;
    // ignore: discarded_futures — refetch ngầm, UI tự cập nhật qua state.
    fetchFavoriteEvents(sportId, forceRefresh: true, silent: true);
  }

  Future<bool> fetchFavoriteEvents(
    int sportId, {
    bool forceRefresh = false,
    bool silent = false,
  }) async {
    if (!_ref.read(isAuthenticatedProvider)) {
      return false;
    }

    if (!forceRefresh &&
        state.favoriteEventsLeaguesBySport.containsKey(sportId)) {
      return true;
    }

    _favoriteEventsCancelToken?.cancel();
    _favoriteEventsCancelToken = CancelToken();

    if (!silent) {
      final loadingBySport = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySport[sportId] = true;
      final errorBySport = Map<int, String?>.from(
        state.favoriteEventsErrorBySport,
      );
      errorBySport.remove(sportId);
      state = state.copyWith(
        favoriteEventsLoadingBySport: loadingBySport,
        favoriteEventsErrorBySport: errorBySport,
      );
    }

    try {
      var favoriteData = state.getFavoriteData(sportId);
      if (favoriteData == null) {
        await fetchFavorites(sportId);
        favoriteData = state.getFavoriteData(sportId);
      }
      final leagueIds = favoriteData?.leagueIds ?? [];

      final favoriteLeagues = await _httpManager.getFavoriteEvents(
        sportId,
        cancelToken: _favoriteEventsCancelToken!,
      );

      List<LeagueModelV2> eventsApiLeagues = [];
      if (leagueIds.isNotEmpty) {
        final request = EventsRequestModel(
          sportId: sportId,
          timeRange: 4,
          leagueIds: leagueIds,
          sortByTime: false,
        );
        eventsApiLeagues = await _httpManager.getEventsV2(
          request,
          cancelToken: _favoriteEventsCancelToken!,
        );
        eventsApiLeagues = eventsApiLeagues
            .map(
              (l) => l.copyWith(
                isFavorited: true,
                events: l.events
                    .map((e) => e.copyWith(isFavorited: true))
                    .toList(),
              ),
            )
            .toList();
      }

      final combined = [...favoriteLeagues, ...eventsApiLeagues];

      final leaguesBySport = Map<int, List<LeagueModelV2>>.from(
        state.favoriteEventsLeaguesBySport,
      );
      leaguesBySport[sportId] = combined;
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      state = state.copyWith(
        favoriteEventsLeaguesBySport: leaguesBySport,
        favoriteEventsLoadingBySport: loadingBySportAfter,
      );
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return false;
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      final errorBySportAfter = Map<int, String?>.from(
        state.favoriteEventsErrorBySport,
      );
      errorBySportAfter[sportId] = 'Failed to load favorites: ${e.message}';
      state = state.copyWith(
        favoriteEventsLoadingBySport: loadingBySportAfter,
        favoriteEventsErrorBySport: errorBySportAfter,
      );
      return false;
    } catch (e) {
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      final errorBySportAfter = Map<int, String?>.from(
        state.favoriteEventsErrorBySport,
      );
      errorBySportAfter[sportId] = 'An error occurred: $e';
      state = state.copyWith(
        favoriteEventsLoadingBySport: loadingBySportAfter,
        favoriteEventsErrorBySport: errorBySportAfter,
      );
      return false;
    }
  }

  Future<bool> fetchFavorites(int sportId, {bool forceRefresh = false}) async {
    if (!forceRefresh && state.favoritesBySport.containsKey(sportId)) {
      if (state.lastUpdated != null) {
        final age = DateTime.now().difference(state.lastUpdated!);
        if (age.inMinutes < 5) {
          return false;
        }
      }
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final favoriteData = await _httpManager.getFavorites(
        sportId,
        cancelToken: _cancelToken!,
      );

      final updatedFavorites = Map<int, FavoriteData>.from(
        state.favoritesBySport,
      );
      updatedFavorites[sportId] = favoriteData;

      state = state.copyWith(
        favoritesBySport: updatedFavorites,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load favorites: ${e.message}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
      return false;
    }
  }

  Future<void> refresh(int sportId) async {
    await fetchFavorites(sportId, forceRefresh: true);
  }

  Future<bool> addFavoriteLeague({
    required int sportId,
    required int leagueId,
  }) async {
    try {
      await _httpManager.addFavoriteLeague(
        sportId: sportId,
        leagueId: leagueId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to add favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
  }) async {
    try {
      await _httpManager.removeFavoriteLeague(
        sportId: sportId,
        leagueId: leagueId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> addFavoriteEvent({
    required int sportId,
    required int eventId,
  }) async {
    try {
      await _httpManager.addFavoriteEvent(sportId: sportId, eventId: eventId);
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to add favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> removeFavoriteEvent({
    required int sportId,
    required int eventId,
  }) async {
    try {
      await _httpManager.removeFavoriteEvent(
        sportId: sportId,
        eventId: eventId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

}

const _favoriteEventsRefreshInterval = Duration(seconds: 300);

final favoriteEventsAutoRefreshProvider = Provider.autoDispose
    .family<void, int>((ref, sportId) {
      final notifier = ref.read(favoriteProvider.notifier);

      final favState = ref.read(favoriteProvider);
      final hasCache = favState.favoriteEventsLeaguesBySport.containsKey(
        sportId,
      );
      if (hasCache && !favState.isFavoriteEventsLoading(sportId)) {
        Future.microtask(
          () => notifier.fetchFavoriteEvents(
            sportId,
            forceRefresh: true,
            silent: true,
          ),
        );
      }

      final timer = Timer.periodic(_favoriteEventsRefreshInterval, (_) {
        notifier.fetchFavoriteEvents(sportId, forceRefresh: true, silent: true);
      });
      ref.onDispose(timer.cancel);
    });

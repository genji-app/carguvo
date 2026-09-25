import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/game.dart';

part 'game_filter_provider.freezed.dart';

enum GameViewMode { lobby, filter }

enum GameFilterStatus {
  initial,

  loading,

  success,

  failure;

  bool get isInitial => this == GameFilterStatus.initial;
  bool get isLoading => this == GameFilterStatus.loading;
  bool get isSuccess => this == GameFilterStatus.success;
  bool get isFailure => this == GameFilterStatus.failure;
}

@freezed
sealed class GameFilterState with _$GameFilterState {
  const factory GameFilterState({
    @Default('') String searchQuery,
    @Default(GameCategorySelection()) GameCategorySelection categorySelection,
    @Default([]) List<LobbyGame> results,
    @Default(GameFilterStatus.initial) GameFilterStatus status,
  }) = _GameFilterState;
}

extension GameFilterStateX on GameFilterState {
  GameViewMode get viewMode => searchQuery.isEmpty && categorySelection.isEmpty
      ? GameViewMode.lobby
      : GameViewMode.filter;
}

class GameFilterNotifier extends StateNotifier<GameFilterState>
    with LoggerMixin {
  GameFilterNotifier({
    required ProviderGameManager manager,
    GameCategorySelection initialCategory = const GameCategorySelection(),
  }) : _manager = manager,
       super(GameFilterState(categorySelection: initialCategory)) {
    _eventsSubscription = _manager.onUpdateGameList.listen((_) {
      if (state.viewMode != GameViewMode.filter) return;
      logInfo('Catalog đổi, lọc lại danh sách game...');
      _runSearch();
    });
    _runSearch();
  }

  final ProviderGameManager _manager;
  StreamSubscription<void>? _eventsSubscription;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (state.searchQuery == query) return;
      state = state.copyWith(searchQuery: query);
      _runSearch();
    });
  }

  void setCategorySelection(GameCategorySelection selection) {
    if (state.categorySelection == selection) return;
    state = state.copyWith(categorySelection: selection);
    _runSearch();
    logInfo('Category selection changed: ${selection.label}');
  }

  Future<void> reset() async {
    state = const GameFilterState();
    await _runSearch();
  }

  Future<void> _runSearch() async {
    if (state.viewMode == GameViewMode.lobby) return;

    try {
      final base = _manager.categoryGames(state.categorySelection.categoryId);
      final query = state.searchQuery.trim();
      final results = query.isEmpty
          ? base
          : () {
              final matched =
                  _manager.searchLobbyGames(query).map((g) => g.ref).toSet();
              return base.where((g) => matched.contains(g.ref)).toList();
            }();
      if (!mounted) return;
      state = state.copyWith(
        results: results,
        status: GameFilterStatus.success,
      );
    } catch (e) {
      if (!mounted) return;
      logError('GameFilterNotifier: lọc game lỗi: $e');
      state = state.copyWith(results: [], status: GameFilterStatus.failure);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }
}

final gameFilterProvider =
    StateNotifierProvider.autoDispose<GameFilterNotifier, GameFilterState>((
      ref,
    ) {
      final initialCategory = ref.read(gameCategorySelectionProvider);

      ref.watch(providerGameDataProvider);

      final notifier = GameFilterNotifier(
        manager: ref.read(providerGameManagerProvider),
        initialCategory: initialCategory,
      );

      ref.listen(gameCategorySelectionProvider, (prev, next) {
        notifier.setCategorySelection(next);
      });

      return notifier;
    });

typedef GameCategoryPreview = ({String query, GameCategorySelection selection});

final gameCategoryPreviewProvider = FutureProvider.family
    .autoDispose<List<LobbyGame>, GameCategoryPreview>((ref, key) async {
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 5), link.close);
      ref.onDispose(timer.cancel);

      ref.watch(providerGameDataProvider);

      final manager = ref.read(providerGameManagerProvider);
      final base = manager.categoryGames(key.selection.categoryId);
      final query = key.query.trim();
      if (query.isEmpty) return base;
      final matched = manager.searchLobbyGames(query).map((g) => g.ref).toSet();
      return base.where((g) => matched.contains(g.ref)).toList();
    });

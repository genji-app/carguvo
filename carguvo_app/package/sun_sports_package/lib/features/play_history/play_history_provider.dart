import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/misc/misc.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/features/transaction/transaction_provider.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

class PlayHistoryNotifier
    extends StateNotifier<PaginatedState<List<UnifiedTransaction>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<
          PaginatedTransactions,
          List<UnifiedTransaction>
        > {
  PlayHistoryNotifier({required TransactionRepository repository})
    : _repository = repository,
      super(const PaginatedState.initial());

  final TransactionRepository _repository;

  static const int _limit = 20;

  Future<void> initialize() {
    logInfo('✅ PlayHistoryNotifier initialize');
    return loadInitial();
  }

  @override
  void dispose() {
    logInfo('🔴 PlayHistoryNotifier disposed');
    super.dispose();
  }

  @override
  Future<void> loadInitial() {
    state = const PaginatedState.initial();
    return super.loadInitial();
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError('Request failed', error, stackTrace);
  }

  List<UnifiedTransaction> _filterCasinoOnly(List<UnifiedTransaction> items) {
    return items.where((e) {
      return e is ActivityTransaction && e.group == ActivityGroup.casino;
    }).toList();
  }

  @override
  Future<void> onInitialResponse(PaginatedTransactions response) async {
    logInfo('Loaded ${response.items.length} items (initial)');

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.nextCursor,
      );
    }
  }

  @override
  Future<void> onMoreResponse(
    PaginatedTransactions response,
    List<UnifiedTransaction> data,
  ) async {
    logInfo('Loaded ${response.items.length} items (more)');
    final newData = [...data, ...response.items];
    state = PaginatedState.withData(data: newData, cursor: response.nextCursor);
  }

  @override
  Future<void> onRefreshResponse(PaginatedTransactions response) async {
    logInfo('Refreshed ${response.items.length} items');

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.nextCursor,
      );
    }
  }

  @override
  Future<PaginatedTransactions> request([int? cursor]) async {
    int currentCursor = cursor ?? 0;
    final accumulatedFilteredItems = <UnifiedTransaction>[];
    PaginatedTransactions? lastResponse;

    while (true) {
      logDebug('Requesting play history... | skip: $currentCursor');
      final response = await _repository.getTransactionsByFilter(
        filter: TransactionFilter.activityLog,
        cursor: currentCursor,
        limit: _limit,
      );

      lastResponse = response;
      final newRawItems = response.items;
      final newFilteredItems = _filterCasinoOnly(newRawItems);

      accumulatedFilteredItems.addAll(newFilteredItems);

      if (accumulatedFilteredItems.length >= 10 ||
          response.nextCursor == null) {
        break;
      }
      currentCursor = response.nextCursor!;
    }

    return PaginatedTransactions(
      items: accumulatedFilteredItems,
      totalCount: lastResponse.totalCount,
      currentCursor: cursor ?? 0,
      limit: _limit,
      isLastPage: lastResponse.isLastPage,
      nextCursor: lastResponse.nextCursor,
    );
  }
}

final playHistoryProvider =
    StateNotifierProvider.autoDispose<
      PlayHistoryNotifier,
      PaginatedState<List<UnifiedTransaction>>
    >((ref) {
      return PlayHistoryNotifier(
        repository: ref.read(transactionRepositoryProvider),
      );
    });

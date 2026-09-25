import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/misc/misc.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

typedef CountdownMinutesProvider = int? Function();

class TransactionHistoryNotifier
    extends StateNotifier<PaginatedState<List<UnifiedTransaction>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<
          PaginatedTransactions,
          List<UnifiedTransaction>
        > {
  TransactionHistoryNotifier({
    required TransactionRepository repository,
    required TransactionFilter filter,
    CountdownMinutesProvider? countdownMinutesProvider,
  }) : _repository = repository,
       _filter = filter,
       _countdownMinutesProvider = countdownMinutesProvider,
       _currentCountdown = countdownMinutesProvider?.call(),
       super(const PaginatedState.initial()) {
    _subscribeToEvents();
  }

  final TransactionRepository _repository;
  final TransactionFilter _filter;
  final CountdownMinutesProvider? _countdownMinutesProvider;
  StreamSubscription<TransactionEvent>? _eventSubscription;
  Timer? _expirationTimer;
  int? _currentCountdown;

  final _errorController = StreamController<TransactionFailure>.broadcast();
  TransactionFailure? _failure;

  Stream<TransactionFailure> get errorEvents => _errorController.stream;

  TransactionFailure? get failure => _failure;

  static const int _limit = 30;

  Future<void> updateCountdown(
    int minutes, {
    Duration delay = Duration.zero,
  }) async {
    if (_filter != TransactionFilter.activityLog) return;
    _currentCountdown = minutes;

    if (minutes == 0) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        if (!mounted) return;
      }
      state = PaginatedState.empty();
      _stopExpirationTimer();
      return;
    }

    _pruneExpiredItems();
    _startExpirationTimer();
  }

  List<UnifiedTransaction> _filterExpired(List<UnifiedTransaction> items) {
    if (_filter != TransactionFilter.activityLog) return items;
    final countdown = _currentCountdown ?? _countdownMinutesProvider?.call();
    if (countdown == null) return items;
    if (countdown == 0) return const [];

    final cutoff = DateTime.now().subtract(Duration(minutes: countdown));
    return items.where((t) => t.sortTime.isAfter(cutoff)).toList();
  }

  void _pruneExpiredItems() {
    if (!mounted || _filter != TransactionFilter.activityLog) return;
    final countdown = _currentCountdown ?? _countdownMinutesProvider?.call();
    if (countdown == null) return;

    final currentData = state.data;
    if (currentData == null || currentData.isEmpty) {
      _stopExpirationTimer();
      return;
    }

    if (countdown == 0) {
      state = PaginatedState.empty();
      _stopExpirationTimer();
      return;
    }

    final cutoff = DateTime.now().subtract(Duration(minutes: countdown));

    if (currentData.last.sortTime.isAfter(cutoff) &&
        currentData.first.sortTime.isAfter(cutoff)) {
      return;
    }

    final validItems = currentData
        .where((t) => t.sortTime.isAfter(cutoff))
        .toList();

    if (validItems.length != currentData.length) {
      logInfo(
        'Pruned ${currentData.length - validItems.length} expired items for filter=${_filter.name} (countdown=$countdown min)',
      );
      if (validItems.isEmpty) {
        state = PaginatedState.empty();
        _stopExpirationTimer();
      } else {
        state = state.copyWith(data: validItems);
      }
    }
  }

  void _startExpirationTimer() {
    if (_filter != TransactionFilter.activityLog) return;
    final countdown = _currentCountdown ?? _countdownMinutesProvider?.call();
    if (countdown == null || countdown <= 0) {
      _stopExpirationTimer();
      return;
    }

    if (_expirationTimer != null && _expirationTimer!.isActive) return;

    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _pruneExpiredItems();
    });
  }

  void _stopExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  Future<void> initialize() {
    logInfo(
      'TransactionHistoryNotifier initialized with filter=${_filter.name}',
    );
    return loadInitial();
  }

  @override
  void dispose() {
    _stopExpirationTimer();
    _eventSubscription?.cancel();
    _errorController.close();
    logInfo('TransactionHistoryNotifier disposed filter=${_filter.name}');
    super.dispose();
  }

  @override
  Future<PaginatedTransactions> request([int? cursor]) {
    _failure = null;

    logDebug(
      'Requesting transaction history... | filter: ${_filter.name}, cursor (skip): $cursor, limit: $_limit',
    );
    return _repository.getTransactionsByFilter(
      filter: _filter,
      limit: _limit,
      cursor: cursor,
    );
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError(
      'Transaction request failed with filter=${_filter.name}',
      error,
      stackTrace,
    );

    final mappedFailure = error is TransactionFailure
        ? error
        : TransactionUnknownFailure(source: error);

    _failure = mappedFailure;
    _errorController.add(mappedFailure);
  }

  @override
  Future<void> onInitialResponse(PaginatedTransactions response) async {
    logInfo(
      'Loaded initial transactions for filter=${_filter.name}. Count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    final filteredItems = _filterExpired(response.items);

    if (filteredItems.isEmpty) {
      state = PaginatedState.empty();
      _stopExpirationTimer();
    } else {
      state = PaginatedState.withData(
        data: filteredItems,
        cursor: response.nextCursor,
      );
      _startExpirationTimer();
    }
  }

  @override
  Future<void> onRefreshResponse(PaginatedTransactions response) async {
    logInfo(
      'Refreshed transactions for filter=${_filter.name}. Count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    final filteredItems = _filterExpired(response.items);

    if (filteredItems.isEmpty) {
      state = PaginatedState.empty();
      _stopExpirationTimer();
    } else {
      state = PaginatedState.withData(
        data: filteredItems,
        cursor: response.nextCursor,
      );
      _startExpirationTimer();
    }
  }

  @override
  Future<void> onMoreResponse(
    PaginatedTransactions response,
    List<UnifiedTransaction> data,
  ) async {
    logInfo(
      'Loaded more transactions for filter=${_filter.name}. Current count: ${data.length}, new count: ${response.items.length}, nextCursor: ${response.nextCursor}',
    );

    final filteredExisting = _filterExpired(data);
    final filteredNewItems = _filterExpired(response.items);
    final newData = [...filteredExisting, ...filteredNewItems];

    if (newData.isEmpty) {
      state = PaginatedState.empty();
      _stopExpirationTimer();
    } else {
      state = PaginatedState.withData(
        data: newData,
        cursor: response.nextCursor,
      );
      _startExpirationTimer();
    }
  }

  void _subscribeToEvents() {
    _eventSubscription = _repository.events.listen((event) {
      if (!mounted) return;

      bool shouldRefresh = false;

      if (event is TransactionCreatedEvent) {
        if (_filter.activeSources.contains(event.source)) {
          logInfo(
            'Received TransactionCreatedEvent for source=${event.source.name}. Triggering sync for filter=${_filter.name}',
          );
          shouldRefresh = true;
        }
      } else if (event is TransactionMutatedEvent ||
          event is TransactionCacheInvalidatedEvent ||
          event is ComplainCreatedEvent) {
        logInfo(
          'Received ${event.runtimeType}. Triggering sync for filter=${_filter.name}',
        );
        shouldRefresh = true;
      }

      if (shouldRefresh) {
        if (state.status == PaginatedStatus.loading ||
            state.status == PaginatedStatus.refreshing) {
          logInfo(
            'Skipping event sync for filter=${_filter.name} because notifier is already loading/refreshing',
          );
          return;
        }

        refresh(false);
      }
    });
  }
}

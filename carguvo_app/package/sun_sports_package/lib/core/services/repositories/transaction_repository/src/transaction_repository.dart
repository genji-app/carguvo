import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

import 'data_sources/data_sources.dart';
import 'models/models.dart';
import 'transaction_cache.dart';
import 'transaction_event.dart';
import 'transaction_failure.dart';

class TransactionRepository {
  static bool useMockData = false;

  static const List<int> allowedCountdownOptions = [0, 2, 15, 60];

  TransactionRepository({
    required SbHttpManager httpManager,
    TransactionCache? cache,
    gac.GameApiClient? gameApiClient,
  }) : _httpManager = httpManager,
       _cache = cache ?? InMemoryTransactionCache(),
       _gameApiClient = gameApiClient,
       _events = StreamController<TransactionEvent>.broadcast(),
       _slip = PaymentSlipDataSource(httpManager),
       _cardDeposit = CardDepositDataSource(httpManager),
       _cardWithdraw = CardWithdrawDataSource(httpManager),
       _activityLog = ActivityLogDataSource(httpManager);

  final SbHttpManager _httpManager;
  final gac.GameApiClient? _gameApiClient;
  final TransactionCache _cache;
  final StreamController<TransactionEvent> _events;

  final PaymentSlipDataSource _slip;
  final CardDepositDataSource _cardDeposit;
  final CardWithdrawDataSource _cardWithdraw;
  final ActivityLogDataSource _activityLog;

  DepositComplainsDataSource? _complainsSource;
  DepositComplainsDataSource get _complains =>
      _complainsSource ??= DepositComplainsDataSource(_httpManager);

  Stream<TransactionEvent> get events => _events.stream;

  final Map<String, Future<PaginatedTransactions>> _inFlightRequests = {};
  Future<int>? _inFlightHistoryConfig;
  int? _cachedHistoryConfig;

  Future<PaginatedTransactions> getTransactionsByFilter({
    required TransactionFilter filter,
    int limit = 10,
    int? cursor,
  }) async {
    if (cursor == null) {
      final cached = _cache.getFirstPage(filter);
      if (cached != null) {
        debugPrint('[TransactionRepository] cache HIT filter=${filter.name}');
        return cached;
      }
      debugPrint('[TransactionRepository] cache MISS filter=${filter.name}');
    }

    final requestKey = '${filter.name}_${cursor ?? 0}_$limit';
    final existingFuture = _inFlightRequests[requestKey];
    if (existingFuture != null) {
      debugPrint(
        '[TransactionRepository] coalescing in-flight request: $requestKey',
      );
      return existingFuture;
    }

    final future = _executeAndCache(filter, limit, cursor);
    _inFlightRequests[requestKey] = future;

    try {
      return await future;
    } finally {
      _inFlightRequests.remove(requestKey);
    }
  }

  Future<PaginatedTransactions> _executeAndCache(
    TransactionFilter filter,
    int limit,
    int? cursor,
  ) async {
    final result = await _dispatch(filter, limit, cursor);

    if (cursor == null) {
      _cache.setFirstPage(filter, result);
      debugPrint('[TransactionRepository] cache SET filter=${filter.name}');
    }

    return result;
  }

  Future<PaginatedTransactions> fetchDepositComplains({
    int limit = 10,
    int? cursor,
  }) => _complains.fetch(limit: limit, cursor: cursor);

  void notifySourceChanged(TransactionSource source) =>
      _invalidateAndNotify(TransactionCreatedEvent(source: source));

  void notifyMutation() =>
      _invalidateAndNotify(const TransactionMutatedEvent());

  void notifyComplainCreated() =>
      _invalidateAndNotify(const ComplainCreatedEvent());

  void invalidateAll() {
    _cache.invalidate();
    _cachedHistoryConfig = null;
    _events.add(const TransactionCacheInvalidatedEvent());
    debugPrint('[TransactionRepository] invalidateAll');
  }

  void dispose() {
    _cache.invalidate();
    _cachedHistoryConfig = null;
    _events.close();
  }

  Future<void> cancelTransaction(String transactionId) async {
    try {
      debugPrint('[TransactionRepository] cancel id=$transactionId');

      notifyMutation();
      debugPrint('[TransactionRepository] cancel success');
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionFailure.fromAction(e), st);
    }
  }

  Future<void> createComplain({
    required String transactionId,
    required String reason,
    String? note,
  }) async {
    try {
      debugPrint(
        '[TransactionRepository] createComplain id=$transactionId reason=$reason',
      );

      notifyComplainCreated();
      debugPrint('[TransactionRepository] createComplain success');
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionFailure.fromAction(e), st);
    }
  }

  Future<void> clearActivityLogs() async {
    try {
      debugPrint('[TransactionRepository] clearActivityLogs');
      await _activityLog.clearAll();

      _cache.invalidateFilter(TransactionFilter.activityLog);

      _events.add(const TransactionMutatedEvent());
      debugPrint('[TransactionRepository] clearActivityLogs success');
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionFailure.fromAction(e), st);
    }
  }

  Future<int> getHistoryConfig() async {
    if (_cachedHistoryConfig != null) {
      debugPrint(
        '[TransactionRepository] cache HIT historyConfig=$_cachedHistoryConfig',
      );
      return _cachedHistoryConfig!;
    }
    if (_gameApiClient == null) return 0;
    if (_inFlightHistoryConfig != null) {
      debugPrint(
        '[TransactionRepository] coalescing in-flight getHistoryConfig',
      );
      return _inFlightHistoryConfig!;
    }

    final future = _fetchHistoryConfig();
    _inFlightHistoryConfig = future;

    try {
      final config = await future;
      _cachedHistoryConfig = config;
      return config;
    } finally {
      _inFlightHistoryConfig = null;
    }
  }

  Future<int> _fetchHistoryConfig() async {
    try {
      return await _gameApiClient!.getHistoryConfig();
    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionFailure.from(e, TransactionSource.activityLog),
        st,
      );
    }
  }

  int _historyConfigMutationToken = 0;

  Future<bool> updateHistoryConfig(int timeCountDown) async {
    final token = ++_historyConfigMutationToken;
    try {
      final bool success;
      if (timeCountDown == 0) {
        final results = await Future.wait([
          if (_gameApiClient != null)
            _gameApiClient.updateHistoryConfig(0)
          else
            Future.value(true),
          _activityLog.clearAll().then((_) => true).catchError((Object e) {
            debugPrint(
              '[TransactionRepository] auto-clearing activity logs failed: $e',
            );
            return false;
          }),
        ]);
        success = results.first;
      } else {
        success = _gameApiClient != null
            ? await _gameApiClient.updateHistoryConfig(timeCountDown)
            : true;
      }

      if (success) {
        if (token == _historyConfigMutationToken) {
          _cachedHistoryConfig = timeCountDown;
        }
        _cache.invalidateFilter(TransactionFilter.activityLog);
        _events.add(const TransactionMutatedEvent());
      }
      return success;
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionFailure.fromAction(e), st);
    }
  }

  Future<PaginatedTransactions> _dispatch(
    TransactionFilter filter,
    int limit,
    int? cursor,
  ) {
    debugPrint(
      '[TransactionRepository] dispatch filter=${filter.name} cursor=$cursor limit=$limit',
    );
    return switch (filter) {
      TransactionFilter.activityLog => _activityLog.fetch(
        limit: limit,
        cursor: cursor,
      ),
      TransactionFilter.slip ||
      TransactionFilter.slipDeposit ||
      TransactionFilter.slipWithdraw => _slip.fetch(
        slipType: filter.slipType!,
        limit: limit,
        cursor: cursor,
      ),
      TransactionFilter.cardDeposit => _cardDeposit.fetch(
        limit: limit,
        cursor: cursor,
      ),
      TransactionFilter.cardWithdraw => _cardWithdraw.fetch(
        limit: limit,
        cursor: cursor,
      ),
    };
  }

  void _invalidateAndNotify(TransactionEvent event) {
    _cache.invalidate();
    _events.add(event);
    debugPrint(
      '[TransactionRepository] invalidate + emit ${event.runtimeType}',
    );
  }
}

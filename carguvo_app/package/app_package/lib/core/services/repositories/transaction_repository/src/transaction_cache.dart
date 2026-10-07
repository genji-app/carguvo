import 'models/models.dart';

abstract interface class TransactionCache {
  PaginatedTransactions? getFirstPage(TransactionFilter filter);

  void setFirstPage(TransactionFilter filter, PaginatedTransactions page);

  void invalidate();

  void invalidateFilter(TransactionFilter filter);
}

final class InMemoryTransactionCache implements TransactionCache {
  InMemoryTransactionCache({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;

  final _store =
      <TransactionFilter, ({PaginatedTransactions page, DateTime createdAt})>{};

  @override
  PaginatedTransactions? getFirstPage(TransactionFilter filter) {
    final entry = _store[filter];
    if (entry == null) return null;

    final isExpired = DateTime.now().difference(entry.createdAt) > ttl;
    if (isExpired) {
      _store.remove(filter);
      return null;
    }
    return entry.page;
  }

  @override
  void setFirstPage(TransactionFilter filter, PaginatedTransactions page) {
    _store[filter] = (page: page, createdAt: DateTime.now());
  }

  @override
  void invalidate() => _store.clear();

  @override
  void invalidateFilter(TransactionFilter filter) => _store.remove(filter);
}

import 'unified_transaction.dart';

class PaginatedTransactions {
  const PaginatedTransactions({
    required this.items,
    required this.totalCount,
    required this.currentCursor,
    required this.limit,
    required this.isLastPage,
    this.nextCursor,
  });

  final List<UnifiedTransaction> items;

  final int totalCount;

  final int currentCursor;

  final int limit;

  final int? nextCursor;

  final bool isLastPage;
}

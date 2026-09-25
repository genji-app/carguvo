class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentCursor;
  final int limit;
  final int? nextCursor;
  final bool isLastPage;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentCursor,
    required this.limit,
    required this.isLastPage,
    this.nextCursor,
  });
}

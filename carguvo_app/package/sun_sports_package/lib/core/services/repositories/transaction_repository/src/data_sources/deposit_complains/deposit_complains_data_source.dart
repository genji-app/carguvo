import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

final class DepositComplainsDataSource {
  DepositComplainsDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'DepositComplainsDataSource';

  Future<PaginatedTransactions> fetch({int limit = 10, int? cursor}) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit');

      final (count, items) = await _httpManager.fetchDepositComplainsHistory(
        skip: skip,
        limit: limit,
      );

      debugPrint('[$_tag] response count=$count items=${items.length}');

      final unified = items
          .map((e) => DepositComplainResponseDto.fromJson(e))
          .map((e) => e.toUnified())
          .toList();

      return _paginate(count, unified, skip, limit);
    } catch (e, st) {
      debugPrint('[$_tag] Error fetching deposit complains: $e\n$st');
      Error.throwWithStackTrace(
        TransactionFailure.from(e, TransactionSource.paymentSlip),
        st,
      );
    }
  }

  PaginatedTransactions _paginate(
    int totalCount,
    List<UnifiedTransaction> items,
    int skip,
    int limit,
  ) {
    final isLastPage = skip + items.length >= totalCount;
    return PaginatedTransactions(
      items: items,
      totalCount: totalCount,
      currentCursor: skip,
      limit: limit,
      nextCursor: isLastPage ? null : skip + limit,
      isLastPage: isLastPage,
    );
  }
}

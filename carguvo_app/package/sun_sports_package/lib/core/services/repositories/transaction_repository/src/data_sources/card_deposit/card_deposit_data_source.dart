import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

part 'card_deposit_mock.dart';

final class CardDepositDataSource {
  CardDepositDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'CardDepositDataSource';

  static bool useMockData = false;

  Future<PaginatedTransactions> fetch({int limit = 10, int? cursor}) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit (mock=$useMockData)');

      if (useMockData || TransactionRepository.useMockData) {
        final allItems = (kMockCardDepositResponseDto['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final count =
            kMockCardDepositResponseDto['count'] as int? ?? allItems.length;
        final pagedItems = allItems.skip(skip).take(limit).toList();
        final unified = pagedItems
            .map((e) => CardDepositResponseDto.fromJson(e))
            .map((e) => e.toUnified())
            .toList();
        return _paginate(count, unified, skip, limit);
      }

      final (count, items) = await _httpManager.fetchCardDepositHistory(
        skip: skip,
        limit: limit,
      );

      debugPrint('[$_tag] response count=$count items=${items.length}');

      final unified = items
          .map((e) => CardDepositResponseDto.fromJson(e))
          .map((e) => e.toUnified())
          .toList();

      return _paginate(count, unified, skip, limit);
    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionFailure.from(e, TransactionSource.cardDeposit),
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

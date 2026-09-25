import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

part 'activity_log_mock.dart';

final class ActivityLogDataSource {
  ActivityLogDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'ActivityLogDataSource';

  static bool useMockData = false;

  Future<PaginatedTransactions> fetch({int limit = 10, int? cursor}) async {
    final skip = cursor ?? 0;
    try {
      debugPrint('[$_tag] fetch skip=$skip limit=$limit (mock=$useMockData)');

      if (useMockData || TransactionRepository.useMockData) {
        final allItems = (kMockActivityLogResponseDto['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final count =
            kMockActivityLogResponseDto['count'] as int? ?? allItems.length;
        final pagedItems = allItems.skip(skip).take(limit).toList();
        final unified = pagedItems
            .map((e) => PlayHistoryItemDto.fromJson(e))
            .map((e) => e.toUnified())
            .toList();
        return _paginate(count, unified, skip, limit);
      }

      final response = await _httpManager.fetchPlayHistory(
        skip: skip,
        limit: limit,
        assetName: 'gold',
      );

      debugPrint(
        '[$_tag] response totalCount=${response.count} items=${response.items.length}',
      );

      final unified = response.items.map((e) => e.toUnified()).toList();

      return _paginate(response.count, unified, skip, limit);
    } catch (e, st) {
      Error.throwWithStackTrace(
        TransactionFailure.from(e, TransactionSource.activityLog),
        st,
      );
    }
  }

  Future<void> clearAll() async {
    try {
      debugPrint('[$_tag] clearAll');
      await _httpManager.cleanupPlayHistory();
    } catch (e, st) {
      Error.throwWithStackTrace(TransactionFailure.fromAction(e), st);
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

import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

part 'payment_slip_mock.dart';

final class PaymentSlipDataSource {
  PaymentSlipDataSource(this._httpManager);

  final SbHttpManager _httpManager;
  static const _tag = 'PaymentSlipDataSource';

  static bool useMockData = false;

  Future<PaginatedTransactions> fetch({
    required int slipType,
    int limit = 10,
    int? cursor,
  }) async {
    final skip = cursor ?? 0;
    try {
      debugPrint(
        '[$_tag] fetch slipType=$slipType skip=$skip limit=$limit (mock=$useMockData)',
      );

      if (useMockData || TransactionRepository.useMockData) {
        final data =
            kMockPaymentSlipResponseDto['data'] as Map<String, dynamic>;
        final allItems = (data['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final filteredItems = slipType == 0
            ? allItems
            : allItems.where((e) => e['slipType'] == slipType).toList();
        final count = filteredItems.length;
        final pagedItems = filteredItems.skip(skip).take(limit).toList();
        final items = pagedItems
            .map((e) => PaymentSlipDto.fromJson(e))
            .map((e) => e.toUnified())
            .toList();
        return _paginate(count, items, skip, limit);
      }

      final response = await _httpManager.getTransactionSlipHistory(
        skip: skip,
        limit: limit,
        slipType: slipType,
      );

      debugPrint(
        '[$_tag] response count=${response.count} items=${response.items.length}',
      );

      final items = response.items.map((e) => e.toUnified()).toList();

      return _paginate(response.count, items, skip, limit);
    } catch (e, st) {
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

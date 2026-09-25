import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/features/transaction/history_config/history_config_provider.dart';

import '../transaction_provider.dart';
import 'transaction_history_notifier.dart';

final transactionHistoryProvider = StateNotifierProvider.family
    .autoDispose<
      TransactionHistoryNotifier,
      PaginatedState<List<UnifiedTransaction>>,
      TransactionFilter
    >((ref, filter) {
      final repository = ref.watch(transactionRepositoryProvider);
      final notifier = TransactionHistoryNotifier(
        repository: repository,
        filter: filter,
        countdownMinutesProvider: filter == TransactionFilter.activityLog
            ? () => ref.read(historyConfigProvider).valueOrNull
            : null,
      );

      if (filter == TransactionFilter.activityLog) {
        ref.listen<AsyncValue<int>>(historyConfigProvider, (prev, next) {
          final minutes = next.valueOrNull;
          if (minutes != null) {
            notifier.updateCountdown(
              minutes,
              delay: minutes == 0
                  ? const Duration(milliseconds: 250)
                  : Duration.zero,
            );
          }
        });
      }

      return notifier..initialize();
    });

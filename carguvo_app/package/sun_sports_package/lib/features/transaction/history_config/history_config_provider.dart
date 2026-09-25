import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/transaction/transaction_provider.dart';

import 'history_config_notifier.dart';

final historyConfigProvider =
    StateNotifierProvider.autoDispose<HistoryConfigNotifier, AsyncValue<int>>((
      ref,
    ) {
      final repository = ref.watch(transactionRepositoryProvider);
      return HistoryConfigNotifier(repository: repository);
    });

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/features/transaction/transaction_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';

void notifyMoneyFlowSuccess(
  WidgetRef ref, {
  required TransactionSource source,
  bool refreshBalance = true,
  bool watchBalance = true,
  Duration? firstWatchInterval,
}) {
  final userNotifier = ref.read(userProvider.notifier);

  if (watchBalance) {
    userNotifier.watchBalanceAfterMoneyFlow(
      firstTickInterval: firstWatchInterval,
    );
  }
  if (refreshBalance) {
    // ignore: unawaited_futures
    userNotifier.refreshBalance();
  }
  ref.read(transactionRepositoryProvider).notifySourceChanged(source);
}

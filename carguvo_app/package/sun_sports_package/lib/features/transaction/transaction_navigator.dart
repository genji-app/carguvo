import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';

import 'details/transaction_details_screen.dart';

abstract class TransactionNavigator {
  void pushToTransactionDetails(
    BuildContext context,
    UnifiedTransaction transaction,
  );
}

class TransactionNavigatorStandard implements TransactionNavigator {
  const TransactionNavigatorStandard();

  @override
  void pushToTransactionDetails(
    BuildContext context,
    UnifiedTransaction transaction,
  ) {
    Navigator.of(context).push(TransactionDetailsScreen.route(transaction));
  }
}

final transactionNavigatorProvider = Provider<TransactionNavigator>((ref) {
  return const TransactionNavigatorStandard();
});

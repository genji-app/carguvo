export 'package:transaction_domain/transaction_domain.dart'
    show TransactionSource;

export 'package:provider_game_manager/provider_game_manager.dart'
    show ActivityGroup;

import 'package:transaction_domain/transaction_domain.dart';

enum TransactionFilter {
  activityLog,

  slip,

  cardDeposit,

  cardWithdraw,

  slipDeposit,

  slipWithdraw,
}

extension TransactionFilterX on TransactionFilter {
  Set<TransactionSource> get activeSources => switch (this) {
    TransactionFilter.activityLog => {TransactionSource.activityLog},
    TransactionFilter.slip => {TransactionSource.paymentSlip},
    TransactionFilter.slipDeposit => {TransactionSource.paymentSlip},
    TransactionFilter.slipWithdraw => {TransactionSource.paymentSlip},
    TransactionFilter.cardDeposit => {TransactionSource.cardDeposit},
    TransactionFilter.cardWithdraw => {TransactionSource.cardWithdraw},
  };

  int? get slipType => switch (this) {
    TransactionFilter.slip => 0,
    TransactionFilter.slipDeposit => 1,
    TransactionFilter.slipWithdraw => 2,
    _ => null,
  };

  bool get isVisible => switch (this) {
    TransactionFilter.activityLog => true,
    TransactionFilter.slip => true,
    TransactionFilter.cardDeposit => true,
    TransactionFilter.cardWithdraw => true,
    _ => false,
  };
}

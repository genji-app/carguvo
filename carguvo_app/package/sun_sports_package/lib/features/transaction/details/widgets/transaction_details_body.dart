import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/features/transaction/payment_config/payment_config.dart';
import 'package:sun_sports/features/transaction/transaction.dart';

class TransactionDetailsBody extends ConsumerStatefulWidget {
  const TransactionDetailsBody({required this.transaction, super.key});

  final UnifiedTransaction transaction;

  @override
  ConsumerState<TransactionDetailsBody> createState() =>
      _TransactionDetailsBodyState();
}

class _TransactionDetailsBodyState
    extends ConsumerState<TransactionDetailsBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(paymentConfigProvider.notifier)
          .loadFromApi(SbHttpManager.instance);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await ref
            .read(paymentConfigProvider.notifier)
            .loadFromApi(SbHttpManager.instance);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                child: widget.transaction.map(
                  slip: (_) => TransactionDetailsView(widget.transaction),
                  cardDeposit: (_) =>
                      TransactionDetailsView(widget.transaction),
                  cardWithdraw: (_) =>
                      TransactionDetailsView(widget.transaction),
                  activity: (value) => ActivityLogDetailsView(value),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

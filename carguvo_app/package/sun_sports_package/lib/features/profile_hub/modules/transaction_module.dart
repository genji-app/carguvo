import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/features/transaction/transaction.dart';

class _TransactionProfileHubNavigator implements TransactionNavigator {
  @override
  void pushToTransactionDetails(
    BuildContext context,
    UnifiedTransaction transaction,
  ) {
    ProfileHub.of(
      context,
    ).pushNamed<void>(ProfileHub.transactionDetails, arguments: transaction);
  }
}

class TransactionProfileHubRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.transactionHistory: (context, args) =>
        ProfileHubScaffold.withCenterTitle(
          title: const Text(I18n.txtTransactionHistory),
          bodyPadding: EdgeInsets.zero,
          body: ProviderScope(
            overrides: [
              transactionNavigatorProvider.overrideWithValue(
                _TransactionProfileHubNavigator(),
              ),
            ],
            child: const TransactionHistoryFlowView(),
          ),
        ),
    ProfileHub.transactionDetails: (context, args) {
      if (args is! UnifiedTransaction) {
        return const ProfileHubScaffold(
          body: Center(child: Text('Invalid Transaction arguments')),
        );
      }
      return ProfileHubScaffold.withCenterTitle(
        title: Text(args.detailsTitle),
        body: TransactionDetailsBody(transaction: args),
      );
    },
  };
}

final transactionProfileHubRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => TransactionProfileHubRoutes(),
);

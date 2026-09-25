import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';

final transactionCacheProvider = Provider<TransactionCache>(
  (ref) => InMemoryTransactionCache(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  ref.watch(userInfoProvider.select((user) => user?.custId));

  final repository = TransactionRepository(
    httpManager: SbHttpManager.instance,
    gameApiClient: ref.watch(gameApiClientProvider),
    cache: ref.watch(transactionCacheProvider),
  );

  ref.listen(userInfoProvider.select((user) => user?.balance), (
    previous,
    next,
  ) {
    if (previous != null && next != null && previous != next) {
      repository.notifyMutation();
    }
  });

  ref.onDispose(repository.dispose);
  return repository;
});

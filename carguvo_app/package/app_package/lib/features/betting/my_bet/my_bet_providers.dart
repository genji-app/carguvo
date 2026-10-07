import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/features/betting/my_bet/my_bet_provider.dart';

import 'my_bet_notifier.dart';

export 'package:app_package/features/my_bet_hub/my_bet_hub_providers.dart';

final activeBetCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(myBetRepositoryProvider);
  return repo.activeBetCountStream;
});

final myBetNotifierProvider = NotifierProvider<MyBetNotifier, MyBetState>(
  MyBetNotifier.new,
);

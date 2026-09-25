import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';

import 'my_bet_notifier.dart';

export 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';

final activeBetCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(myBetRepositoryProvider);
  return repo.activeBetCountStream;
});

final myBetNotifierProvider = NotifierProvider<MyBetNotifier, MyBetState>(
  MyBetNotifier.new,
);

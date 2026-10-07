import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_bet_hub_controller.dart';

final myBetHubControllerProvider = ChangeNotifierProvider<MyBetHubController>((
  ref,
) {
  final controller = MyBetHubController();

  return controller;
});

final myBetOverlayVisibleProvider = Provider<bool>((ref) {
  return ref.watch(myBetHubControllerProvider.select((c) => c.isVisible));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SportNavigationNotifier extends StateNotifier<int> {
  SportNavigationNotifier() : super(3);

  void selectItem(int index) {
    state = index;
  }
}

final sportNavigationProvider =
    StateNotifierProvider<SportNavigationNotifier, int>(
      (ref) => SportNavigationNotifier(),
    );

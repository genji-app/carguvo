import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniGameVisibilityNotifier extends StateNotifier<bool> {
  MiniGameVisibilityNotifier() : super(true);

  bool get isVisible => state;

  void hide() {
    if (!state) return;
    state = false;
  }

  void show() {
    if (state) return;
    state = true;
  }
}

final miniGameVisibilityProvider =
    StateNotifierProvider<MiniGameVisibilityNotifier, bool>(
      (ref) => MiniGameVisibilityNotifier(),
    );

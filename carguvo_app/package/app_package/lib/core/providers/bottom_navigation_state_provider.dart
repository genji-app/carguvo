import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationStateProvider =
    StateNotifierProvider<BottomNavigationStateNotifier, BottomNavigationState>(
      (ref) => BottomNavigationStateNotifier(),
    );

class BottomNavigationState {
  final bool isCollapsed;
  final bool isAnimating;

  const BottomNavigationState({
    this.isCollapsed = false,
    this.isAnimating = false,
  });

  BottomNavigationState copyWith({bool? isCollapsed, bool? isAnimating}) {
    return BottomNavigationState(
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

class BottomNavigationStateNotifier
    extends StateNotifier<BottomNavigationState> {
  BottomNavigationStateNotifier() : super(const BottomNavigationState());

  void collapse() {
    if (!state.isCollapsed && !state.isAnimating) {
      state = state.copyWith(isCollapsed: true, isAnimating: true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          state = state.copyWith(isAnimating: false);
        }
      });
    }
  }

  void expand() {
    if (state.isCollapsed && !state.isAnimating) {
      state = state.copyWith(isCollapsed: false, isAnimating: true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          state = state.copyWith(isAnimating: false);
        }
      });
    }
  }

  void toggle() {
    if (state.isCollapsed) {
      expand();
    } else {
      collapse();
    }
  }
}

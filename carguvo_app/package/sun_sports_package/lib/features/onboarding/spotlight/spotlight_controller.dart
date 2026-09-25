import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'spotlight_core.dart';

enum SpotlightPhase {
  idle,

  transitioning,

  showing,
}

@immutable
class SpotlightState {
  const SpotlightState({
    this.tour,
    this.index = 0,
    this.phase = SpotlightPhase.idle,
  });

  final SpotlightTour? tour;
  final int index;
  final SpotlightPhase phase;

  bool get isRunning => tour != null && phase != SpotlightPhase.idle;
  bool get isVisible => phase != SpotlightPhase.idle;
  bool get isLast => tour != null && index >= tour!.length - 1;
  bool get isFirst => index <= 0;

  SpotlightStep? get step =>
      (tour != null && index >= 0 && index < tour!.length)
      ? tour!.steps[index]
      : null;

  SpotlightState copyWith({
    SpotlightTour? tour,
    int? index,
    SpotlightPhase? phase,
    bool resetTour = false,
  }) {
    return SpotlightState(
      tour: resetTour ? null : (tour ?? this.tour),
      index: index ?? this.index,
      phase: phase ?? this.phase,
    );
  }
}

class SpotlightController extends StateNotifier<SpotlightState> {
  SpotlightController({
    required SpotlightNavigator navigator,
    Future<void> Function(String tourId)? onCompleted,
  }) : _navigator = navigator,
       _onCompleted = onCompleted,
       super(const SpotlightState());

  final SpotlightNavigator _navigator;
  final Future<void> Function(String tourId)? _onCompleted;

  int _transition = 0;

  Future<void> start(SpotlightTour tour) async {
    if (state.isRunning) return;
    state = SpotlightState(
      tour: tour,
      index: 0,
      phase: SpotlightPhase.transitioning,
    );
    try {
      await _navigator.prepareTour();
    } catch (_) {}
    await _enter(0);
  }

  Future<void> _enter(int i) async {
    final tour = state.tour;
    if (tour == null) return;
    final token = ++_transition;

    state = state.copyWith(index: i, phase: SpotlightPhase.transitioning);
    try {
      await tour.steps[i].onEnter?.call(_navigator);
    } catch (e) {
      if (kDebugMode) debugPrint('[Spotlight] onEnter step $i lỗi: $e');
    }
    if (token != _transition) return;
    if (!mounted || state.tour == null) return;
    state = state.copyWith(phase: SpotlightPhase.showing);
  }

  Future<void> next() async {
    final tour = state.tour;
    if (tour == null) return;
    if (state.isLast) {
      await finish();
      return;
    }
    await _runExit(state.index);
    await _enter(state.index + 1);
  }

  Future<void> prev() async {
    final tour = state.tour;
    if (tour == null || state.isFirst) return;
    await _runExit(state.index);
    await _enter(state.index - 1);
  }

  Future<void> _runExit(int i) async {
    final tour = state.tour;
    if (tour == null) return;
    try {
      await tour.steps[i].onExit?.call(_navigator);
    } catch (_) {}
  }

  Future<void> skip() => _end(completed: false);

  Future<void> finish() => _end(completed: true);

  Future<void> _end({required bool completed}) async {
    final tour = state.tour;
    if (tour == null) return;
    ++_transition;
    state = const SpotlightState();
    try {
      await _navigator.restoreAfterTour();
    } catch (_) {}
    if (completed) {
      try {
        await _onCompleted?.call(tour.id);
      } catch (_) {}
    }
  }
}

final spotlightNavigatorProvider = Provider<SpotlightNavigator>(
  (ref) => const NoopSpotlightNavigator(),
);

final spotlightOnCompletedProvider =
    Provider<Future<void> Function(String tourId)?>((ref) => null);

final spotlightControllerProvider =
    StateNotifierProvider<SpotlightController, SpotlightState>((ref) {
      return SpotlightController(
        navigator: ref.watch(spotlightNavigatorProvider),
        onCompleted: ref.watch(spotlightOnCompletedProvider),
      );
    });

final spotlightShowAfterRegisterProvider = StateProvider<bool>((ref) => false);

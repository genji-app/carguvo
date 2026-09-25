import 'package:flutter_riverpod/flutter_riverpod.dart';

class VibratingOddsState {
  final Set<String> activeSelections;

  final Map<String, int> selectionLeagueMap;

  final Map<String, int> selectionEventMap;

  final Map<int, Set<String>> leagueSelectionsMap;

  final Map<int, Set<String>> eventSelectionsMap;

  const VibratingOddsState({
    this.activeSelections = const {},
    this.selectionLeagueMap = const {},
    this.selectionEventMap = const {},
    this.leagueSelectionsMap = const {},
    this.eventSelectionsMap = const {},
  });

  bool isVibrating(String selectionId) {
    return activeSelections.contains(selectionId);
  }

  bool hasVibratingInLeague(int leagueId) {
    return leagueSelectionsMap[leagueId]?.isNotEmpty ?? false;
  }

  VibratingOddsState copyWith({
    Set<String>? activeSelections,
    Map<String, int>? selectionLeagueMap,
    Map<String, int>? selectionEventMap,
    Map<int, Set<String>>? leagueSelectionsMap,
    Map<int, Set<String>>? eventSelectionsMap,
  }) {
    return VibratingOddsState(
      activeSelections: activeSelections ?? this.activeSelections,
      selectionLeagueMap: selectionLeagueMap ?? this.selectionLeagueMap,
      selectionEventMap: selectionEventMap ?? this.selectionEventMap,
      leagueSelectionsMap: leagueSelectionsMap ?? this.leagueSelectionsMap,
      eventSelectionsMap: eventSelectionsMap ?? this.eventSelectionsMap,
    );
  }
}

class VibratingOddsNotifier extends StateNotifier<VibratingOddsState> {
  VibratingOddsNotifier() : super(const VibratingOddsState());

  void setVibrating(String selectionId, {int leagueId = 0, int eventId = 0}) {
    final alreadyActive = state.activeSelections.contains(selectionId);

    if (alreadyActive &&
        state.selectionLeagueMap[selectionId] == leagueId &&
        state.selectionEventMap[selectionId] == eventId) {
      return;
    }

    final newLeagueSelectionsMap = _copyIndex(state.leagueSelectionsMap);
    final oldLeagueId = state.selectionLeagueMap[selectionId];
    if (oldLeagueId != null && oldLeagueId != leagueId) {
      _removeFromIndex(newLeagueSelectionsMap, oldLeagueId, selectionId);
    }
    _addToIndex(newLeagueSelectionsMap, leagueId, selectionId);

    final newEventSelectionsMap = _copyIndex(state.eventSelectionsMap);
    final oldEventId = state.selectionEventMap[selectionId];
    if (oldEventId != null && oldEventId != eventId) {
      _removeFromIndex(newEventSelectionsMap, oldEventId, selectionId);
    }
    _addToIndex(newEventSelectionsMap, eventId, selectionId);

    state = state.copyWith(
      activeSelections: alreadyActive
          ? state.activeSelections
          : {...state.activeSelections, selectionId},
      selectionLeagueMap: {...state.selectionLeagueMap, selectionId: leagueId},
      selectionEventMap: {...state.selectionEventMap, selectionId: eventId},
      leagueSelectionsMap: newLeagueSelectionsMap,
      eventSelectionsMap: newEventSelectionsMap,
    );
  }

  void removeVibrating(String selectionId) {
    if (!state.activeSelections.contains(selectionId)) return;

    final leagueId = state.selectionLeagueMap[selectionId];
    final eventId = state.selectionEventMap[selectionId];

    final updatedSelections = Set<String>.from(state.activeSelections)
      ..remove(selectionId);
    final updatedLeagueMap = Map<String, int>.from(state.selectionLeagueMap)
      ..remove(selectionId);
    final updatedEventMap = Map<String, int>.from(state.selectionEventMap)
      ..remove(selectionId);

    final updatedLeagueSelections = _copyIndex(state.leagueSelectionsMap);
    if (leagueId != null) {
      _removeFromIndex(updatedLeagueSelections, leagueId, selectionId);
    }

    final updatedEventSelections = _copyIndex(state.eventSelectionsMap);
    if (eventId != null) {
      _removeFromIndex(updatedEventSelections, eventId, selectionId);
    }

    state = state.copyWith(
      activeSelections: updatedSelections,
      selectionLeagueMap: updatedLeagueMap,
      selectionEventMap: updatedEventMap,
      leagueSelectionsMap: updatedLeagueSelections,
      eventSelectionsMap: updatedEventSelections,
    );
  }

  void removeVibratingByEvent(int eventId) {
    final affected = state.eventSelectionsMap[eventId];
    if (affected == null || affected.isEmpty) return;

    final updatedSelections = Set<String>.from(state.activeSelections);
    final updatedLeagueMap = Map<String, int>.from(state.selectionLeagueMap);
    final updatedEventMap = Map<String, int>.from(state.selectionEventMap);
    final updatedLeagueSelections = _copyIndex(state.leagueSelectionsMap);

    for (final selId in affected) {
      updatedSelections.remove(selId);
      final leagueId = updatedLeagueMap.remove(selId);
      updatedEventMap.remove(selId);
      if (leagueId != null) {
        _removeFromIndex(updatedLeagueSelections, leagueId, selId);
      }
    }

    final updatedEventSelections = _copyIndex(state.eventSelectionsMap)
      ..remove(eventId);

    state = state.copyWith(
      activeSelections: updatedSelections,
      selectionLeagueMap: updatedLeagueMap,
      selectionEventMap: updatedEventMap,
      leagueSelectionsMap: updatedLeagueSelections,
      eventSelectionsMap: updatedEventSelections,
    );
  }

  void clearAll() {
    if (state.activeSelections.isEmpty) return;
    state = const VibratingOddsState();
  }

  static Map<int, Set<String>> _copyIndex(Map<int, Set<String>> src) =>
      src.map((k, v) => MapEntry(k, Set<String>.from(v)));

  static void _addToIndex(Map<int, Set<String>> map, int key, String value) {
    (map[key] ??= <String>{}).add(value);
  }

  static void _removeFromIndex(
    Map<int, Set<String>> map,
    int key,
    String value,
  ) {
    map[key]?.remove(value);
    if (map[key]?.isEmpty == true) map.remove(key);
  }
}

final vibratingOddsProvider =
    StateNotifierProvider<VibratingOddsNotifier, VibratingOddsState>(
      (ref) => VibratingOddsNotifier(),
    );

final isVibratingProvider = Provider.autoDispose.family<bool, String>((
  ref,
  selectionId,
) {
  return ref.watch(
    vibratingOddsProvider.select((state) => state.isVibrating(selectionId)),
  );
});

final hasVibratingInLeagueProvider = Provider.autoDispose.family<bool, int>((
  ref,
  leagueId,
) {
  return ref.watch(
    vibratingOddsProvider.select(
      (state) => state.hasVibratingInLeague(leagueId),
    ),
  );
});

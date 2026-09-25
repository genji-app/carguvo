import 'volta_wire.dart';
import 'volta_event.dart';

class VoltaEventMerger {
  const VoltaEventMerger._();

  static const int fastRoundPatchSeconds = 5;

  static const int fastRoundThresholdSeconds = 30;

  static const int keepAfterFinishSeconds = 4;

  static List<VoltaEvent> merge({
    required List<VoltaEvent> current,
    required List<VoltaWireEvent> incoming,
    required int nowSecond,
  }) {
    final Map<int, VoltaEvent> byId = <int, VoltaEvent>{
      for (final VoltaEvent e in current) e.eventId: e,
    };

    for (final VoltaWireEvent wire in incoming) {
      final VoltaEvent? found = byId[wire.eventId];
      final VoltaEvent merged =
          found == null ? VoltaEvent.fromWire(wire) : found.merge(wire);
      byId[wire.eventId] = _patchFastRound(merged);
    }

    final List<VoltaEvent> alive = byId.values
        .where((VoltaEvent e) => _isAlive(e, nowSecond))
        .toList(growable: false);

    final List<VoltaEvent> sorted = alive.toList()
      ..sort((VoltaEvent a, VoltaEvent b) => a.eventId.compareTo(b.eventId));

    final int cut = _currentIndex(sorted);
    if (cut <= 0) return List<VoltaEvent>.unmodifiable(sorted);
    return List<VoltaEvent>.unmodifiable(sorted.sublist(cut));
  }

  static VoltaEvent? currentOf(List<VoltaEvent> events) =>
      events.isEmpty ? null : events.first;

  static bool isUsable(VoltaEvent? current) =>
      current != null && current.hasStart;

  static VoltaEvent _patchFastRound(VoltaEvent event) {
    if (!event.hasStart || !event.hasFinish) return event;
    final int length = event.finishSecond - event.startSecond;
    if (length >= fastRoundThresholdSeconds) return event;
    return event.copyWith(
      finishSecond: event.finishSecond + fastRoundPatchSeconds,
    );
  }

  static bool _isAlive(VoltaEvent event, int nowSecond) =>
      !event.hasFinish ||
      nowSecond < event.finishSecond + keepAfterFinishSeconds;

  static int _currentIndex(List<VoltaEvent> sorted) {
    int firstWithStart = -1;
    int lastWithFinish = -1;
    for (int i = 0; i < sorted.length; i++) {
      if (firstWithStart < 0 && sorted[i].hasStart) firstWithStart = i;
      if (sorted[i].hasFinish) lastWithFinish = i;
    }
    return firstWithStart > lastWithFinish ? firstWithStart : lastWithFinish;
  }
}

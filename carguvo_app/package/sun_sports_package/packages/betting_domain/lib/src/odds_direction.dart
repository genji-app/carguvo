library;

const Duration kOddsIndicatorDisplayDuration = Duration(seconds: 5);

const Duration kOddsCleanupInterval = Duration(seconds: 30);

const Duration kOddsMaxEntryAge = Duration(seconds: 15);

const int kOddsCleanupMinEntries = 100;

const double kOddsDefaultValue = -999999;

enum OddsDirection { none, up, down }

OddsDirection oddsDirectionFromChange({
  required double? current,
  required double? previous,
}) {
  if (previous == null || current == null) return OddsDirection.none;
  if (current > previous) return OddsDirection.up;
  if (current < previous) return OddsDirection.down;
  return OddsDirection.none;
}

bool isOddsIndicatorActive(DateTime? lastChangeTime, {DateTime? now}) {
  if (lastChangeTime == null) return false;
  return (now ?? DateTime.now()).difference(lastChangeTime) <
      kOddsIndicatorDisplayDuration;
}

class OddsChangeRecord {
  const OddsChangeRecord({
    required this.selectionId,
    this.previousValue = kOddsDefaultValue,
    this.currentValue = kOddsDefaultValue,
    this.direction = OddsDirection.none,
    this.lastChangeTime,
  });

  final String selectionId;
  final double previousValue;
  final double currentValue;
  final OddsDirection direction;
  final DateTime? lastChangeTime;

  bool get isFirstTime => previousValue == kOddsDefaultValue;

  bool get isIndicatorActive => isOddsIndicatorActive(lastChangeTime);

  bool get shouldSkip => selectionId.isEmpty || currentValue == 0;

  OddsChangeRecord copyWith({
    String? selectionId,
    double? previousValue,
    double? currentValue,
    OddsDirection? direction,
    DateTime? lastChangeTime,
    bool clearLastChangeTime = false,
  }) {
    return OddsChangeRecord(
      selectionId: selectionId ?? this.selectionId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      direction: direction ?? this.direction,
      lastChangeTime: clearLastChangeTime ? null : (lastChangeTime ?? this.lastChangeTime),
    );
  }
}

class OddsDirectionTracker {
  OddsDirectionTracker({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  final Map<String, OddsChangeRecord> changes = {};

  OddsChangeRecord? update({
    required String selectionId,
    required double currentValue,
    double? previousValue,
    OddsDirection? direction,
  }) {
    if (selectionId.isEmpty || currentValue == 0) return null;

    final existing = changes[selectionId];
    final now = _clock();

    if (existing == null) {
      final record = OddsChangeRecord(
        selectionId: selectionId,
        previousValue: previousValue ?? kOddsDefaultValue,
        currentValue: currentValue,
        direction: direction ?? OddsDirection.none,
        lastChangeTime: now,
      );
      changes[selectionId] = record;
      return record;
    }

    final prevValue = existing.isFirstTime ? existing.currentValue : existing.currentValue;
    final computedDirection = direction ??
        oddsDirectionFromChange(current: currentValue, previous: prevValue);

    final record = OddsChangeRecord(
      selectionId: selectionId,
      previousValue: prevValue,
      currentValue: currentValue,
      direction: computedDirection,
      lastChangeTime: now,
    );
    changes[selectionId] = record;
    return record;
  }

  void resetIndicator(String selectionId) {
    final existing = changes[selectionId];
    if (existing == null) return;
    changes[selectionId] = existing.copyWith(
      direction: OddsDirection.none,
      clearLastChangeTime: true,
    );
  }

  List<String> cleanupStaleEntries() {
    if (changes.length < kOddsCleanupMinEntries) return [];

    final now = _clock();
    final toRemove = <String>[];

    for (final entry in changes.entries) {
      final data = entry.value;
      final hasActiveIndicator = data.direction != OddsDirection.none && data.isIndicatorActive;
      final isRecent = data.lastChangeTime != null &&
          now.difference(data.lastChangeTime!) < kOddsMaxEntryAge;
      if (!hasActiveIndicator && !isRecent) {
        toRemove.add(entry.key);
      }
    }

    for (final key in toRemove) {
      changes.remove(key);
    }
    return toRemove;
  }

  void clearAll() {
    changes.clear();
  }

  OddsChangeRecord? recordFor(String selectionId) => changes[selectionId];

  bool isIndicatorActive(String selectionId) {
    final record = changes[selectionId];
    return record?.isIndicatorActive ?? false;
  }
}

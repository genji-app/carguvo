library;

class MissingOfferTracker {
  MissingOfferTracker({
    this.grace = const Duration(seconds: 8),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration grace;

  final DateTime Function() _now;

  final Map<String, DateTime> _missingSince = {};

  bool shouldDisable(String key, {required bool isMissing}) {
    if (!isMissing) {
      _missingSince.remove(key);
      return false;
    }
    final since = _missingSince.putIfAbsent(key, _now);
    return _now().difference(since) >= grace;
  }

  Duration? nextDeadlineIn() {
    if (_missingSince.isEmpty) return null;
    final now = _now();
    Duration? min;
    for (final since in _missingSince.values) {
      final remain = grace - now.difference(since);
      if (min == null || remain < min) min = remain;
    }
    return min!.isNegative ? Duration.zero : min;
  }

  bool get hasPending => _missingSince.isNotEmpty;

  void clear() => _missingSince.clear();
}

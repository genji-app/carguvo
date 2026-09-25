class NoticeGapRules {
  NoticeGapRules({DateTime Function()? clock, void Function()? onSuspend})
      : _clock = clock ?? DateTime.now,
        _onSuspend = onSuspend;

  final DateTime Function() _clock;

  final void Function()? _onSuspend;

  static const Duration staleTickGap = Duration(seconds: 60);

  static const Duration resumeCooldown = Duration(seconds: 8);

  DateTime? _lastTickAt;

  DateTime? _suppressUntil;

  void suppressFor(Duration duration) {
    _suppressUntil = _clock().add(duration);
  }

  bool shouldSuppress() {
    final now = _clock();
    final last = _lastTickAt;
    _lastTickAt = now;
    if (last != null && now.difference(last) > staleTickGap) {
      _suppressUntil = now.add(resumeCooldown);
      _onSuspend?.call();
    }
    final until = _suppressUntil;
    return until != null && now.isBefore(until);
  }

  void dispose() {
    _lastTickAt = null;
    _suppressUntil = null;
  }
}

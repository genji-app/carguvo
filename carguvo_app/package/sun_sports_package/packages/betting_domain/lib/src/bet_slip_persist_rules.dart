library;

const Duration betSlipPersistTtl = Duration(hours: 24);

bool isBetSlipPersistExpired({required int? savedAtMs, required int nowMs}) {
  final savedAt = savedAtMs ?? 0;
  if (savedAt <= 0) return true;
  return nowMs - savedAt > betSlipPersistTtl.inMilliseconds;
}

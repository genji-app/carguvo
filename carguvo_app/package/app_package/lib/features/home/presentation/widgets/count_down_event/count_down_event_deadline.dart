library;

final DateTime kEventCupDeadline = DateTime(2026, 8, 26);

bool isEventCupExpired([DateTime? now]) {
  final DateTime hideFrom = DateTime(
    kEventCupDeadline.year,
    kEventCupDeadline.month,
    kEventCupDeadline.day + 1,
  );
  return !(now ?? DateTime.now()).isBefore(hideFrom);
}

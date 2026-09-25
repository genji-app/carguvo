library;

final RegExp _kOddsPattern = RegExp(r'(tỉ|tỷ)\s*lệ\s*cược', caseSensitive: false);
final RegExp _kMatchPattern = RegExp(r'(cập\s*nhật|trận\s*đấu)', caseSensitive: false);

enum NotificationCategoryKind { goodOdds, matchResult, other }

const String kGoodOddsLabel = 'Tỷ lệ cược tốt!';
const String kMatchResultLabel = 'Cập nhật kết quả trận đấu';
const String kOtherLabel = 'Khác';

extension NotificationCategoryKindLabel on NotificationCategoryKind {
  String get label => switch (this) {
        NotificationCategoryKind.goodOdds => kGoodOddsLabel,
        NotificationCategoryKind.matchResult => kMatchResultLabel,
        NotificationCategoryKind.other => kOtherLabel,
      };
}

NotificationCategoryKind notificationCategoryOf(String message) {
  if (_kOddsPattern.hasMatch(message)) return NotificationCategoryKind.goodOdds;
  if (_kMatchPattern.hasMatch(message)) return NotificationCategoryKind.matchResult;
  return NotificationCategoryKind.other;
}

String notificationCategoryLabelOf(String message) =>
    notificationCategoryOf(message).label;

String notificationRelativeTime(DateTime? createdAt, {DateTime? now}) {
  if (createdAt == null) return '';
  final base = now ?? DateTime.now();
  var seconds = base.difference(createdAt).inSeconds;
  if (seconds < 0) seconds = 0;
  if (seconds >= 86400) return '${seconds ~/ 86400} ngày';
  if (seconds >= 3600) return '${seconds ~/ 3600} giờ';
  if (seconds >= 60) return '${seconds ~/ 60} phút';
  return '< 1 phút';
}

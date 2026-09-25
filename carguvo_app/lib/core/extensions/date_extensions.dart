import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  /// Ví dụ: 20/10/2023
  String get formatted => DateFormat('dd/MM/yyyy').format(this);

  /// Ví dụ: 20/10/2023 14:30
  String get formattedWithTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Ví dụ: Thứ Ba, 24 Tháng 10
  String get formattedFull {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final weekday = weekdays[this.weekday - 1];
    final day = this.day;
    final month = this.month;
    return '$weekday, $day Tháng $month';
  }

  /// Ví dụ: Hôm nay, 24 Tháng 10
  String get formattedRelative {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);

    if (date == today) {
      return 'Hôm nay, $day Tháng $month';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, $day Tháng $month';
    }
    return formattedFull;
  }

  /// Ví dụ: 14:30
  String get timeOnly => DateFormat('HH:mm').format(this);
}

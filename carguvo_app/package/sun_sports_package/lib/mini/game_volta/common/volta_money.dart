import 'package:sun_sports/core/utils/money_formatter.dart';

class VoltaMoney {
  const VoltaMoney._();

  static String format(int value) => MoneyFormatter.formatWithCommas(value);

  static String signed(int value) {
    if (value == 0) return '0';
    return value > 0 ? '+ ${format(value)}' : '- ${format(-value)}';
  }

  static int parse(Object? raw) {
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final String digits = raw.replaceAll(RegExp(r'[^0-9-]'), '');
      return int.tryParse(digits) ?? 0;
    }
    return 0;
  }
}

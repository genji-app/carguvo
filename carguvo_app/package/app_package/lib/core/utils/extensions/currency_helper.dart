import 'package:intl/intl.dart';

class CurrencyHelper {
  static String formatCurrency(String amount) {
    try {
      final num = double.parse(amount.replaceAll(',', ''));
      final formatter = NumberFormat('#,###');
      return '\$ ${formatter.format(num)}';
    } catch (e) {
      return '\$ $amount';
    }
  }

  static String formatCurrencyInt(int amount) {
    final formatter = NumberFormat('#,###');
    return '\$ ${formatter.format(amount)}';
  }

  static String formatCurrencyDouble(double amount) {
    final formatter = NumberFormat('#,###');
    return '\$ ${formatter.format(amount)}';
  }

  static String formatCurrencyNoUnit(num amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
}

import 'package:app_format/app_format.dart' as af;
import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final _numberFormat = NumberFormat('#,###');
  static final _viFormat = NumberFormat.decimalPattern('vi');

  static String formatServerMoney(num serverValue) =>
      af.formatServerMoney(serverValue);

  static String formatCompact(int value) => af.formatCompact(value);

  static String formatWithCommas(num amount) {
    if (amount == 0) return '0';
    if (amount is int) return af.formatWithCommas(amount);
    return _numberFormat.format(amount);
  }

  static String formatVietnamese(num amount) => _viFormat.format(amount);

  static String formatWithCurrency(num amount, {String currency = 'VND'}) =>
      '${formatWithCommas(amount)} $currency';

  static String formatDoubleWithCurrency(double value, {String currency = ''}) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formatted $currency';
  }

  static int floorToThousand(int amount) => af.floorToThousand(amount);

  static const stakeNormalizeDebounce = af.stakeNormalizeDebounce;

  static int serverToActual(num serverValue) => af.serverToActual(serverValue);

  static num actualToServer(int actualValue) => af.actualToServer(actualValue);
}

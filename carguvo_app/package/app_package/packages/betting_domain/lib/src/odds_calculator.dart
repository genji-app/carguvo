import 'package:app_format/app_format.dart';

import 'league_enums.dart';

class OddsCalculator {
  OddsCalculator._();

  static double calculateWin(double stake, double ratio, OddsStyle style) {
    if (stake <= 0) return 0;

    switch (style) {
      case OddsStyle.decimal:
        return stake * (ratio - 1);

      case OddsStyle.malay:
        if (ratio >= 0) {
          return stake * ratio;
        } else {
          return stake.toDouble();
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return stake * ratio;
        } else {
          return stake.toDouble();
        }

      case OddsStyle.hongKong:
        return stake * ratio;
    }
  }

  static double calculateLose(double stake, double ratio, OddsStyle style) {
    if (stake <= 0) return 0;

    switch (style) {
      case OddsStyle.decimal:
      case OddsStyle.hongKong:
        return stake.toDouble();

      case OddsStyle.malay:
        if (ratio >= 0) {
          return stake.toDouble();
        } else {
          return stake * ratio.abs();
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return stake.toDouble();
        } else {
          return stake * ratio.abs();
        }
    }
  }

  static double calculateHalfWin(double stake, double ratio, OddsStyle style) {
    return calculateWin(stake, ratio, style) / 2;
  }

  static double calculateHalfLose(double stake, double ratio, OddsStyle style) {
    return calculateLose(stake, ratio, style) / 2;
  }

  static double calculateTotalReturn(
    double stake,
    double ratio,
    OddsStyle style,
  ) {
    return stake + calculateWin(stake, ratio, style);
  }

  static String getStyleName(OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return 'Decimal';
      case OddsStyle.malay:
        return 'Malaysia';
      case OddsStyle.indo:
        return 'Indonesia';
      case OddsStyle.hongKong:
        return 'Hongkong';
    }
  }

  static String getWinFormula(double ratio, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return 'Tiền cược x ${(ratio - 1).toStringAsFixed(2)}';

      case OddsStyle.malay:
        if (ratio >= 0) {
          return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
        } else {
          return 'Tiền cược';
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
        } else {
          return 'Tiền cược';
        }

      case OddsStyle.hongKong:
        return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
    }
  }

  static String getLoseFormula(double ratio, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
      case OddsStyle.hongKong:
        return 'Tiền cược';

      case OddsStyle.malay:
        if (ratio >= 0) {
          return 'Tiền cược';
        } else {
          return 'Tiền cược x ${ratio.abs().toStringAsFixed(2)}';
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return 'Tiền cược';
        } else {
          return 'Tiền cược x ${ratio.abs().toStringAsFixed(2)}';
        }
    }
  }

  static String formatMoney(double value) {
    return formatCompact(value.toInt());
  }

  static String formatMoneyValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

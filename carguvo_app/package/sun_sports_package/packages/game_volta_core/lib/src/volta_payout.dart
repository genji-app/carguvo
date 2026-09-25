library;

enum VoltaOddsStyle {
  malay(0, 'my'),
  indonesia(1, 'id'),
  decimal(2, 'de'),
  hongKong(3, 'hk'),
  american(4, 'us');

  const VoltaOddsStyle(this.code, this.wire);

  final int code;

  final String wire;
}

class VoltaPayout {
  const VoltaPayout._();

  static double? totalReturn({
    required double odds,
    required int stake,
    VoltaOddsStyle style = VoltaOddsStyle.decimal,
  }) {
    if (stake <= 0) return null;
    final double s = stake.toDouble();

    switch (style) {
      case VoltaOddsStyle.decimal:
        if (odds <= 1) return null;
        return s * odds;

      case VoltaOddsStyle.malay:
        if (odds > 0 && odds <= 1) return s * odds + s;
        if (odds < 0 && odds >= -1) return s + s / -odds;
        return null;

      case VoltaOddsStyle.indonesia:
        if (odds >= 1) return s * odds + s;
        if (odds <= -1) return s + s / -odds;
        return null;

      case VoltaOddsStyle.hongKong:
        if (odds <= 0) return null;
        return s * odds + s;

      case VoltaOddsStyle.american:
        if (odds >= 100) return s * odds / 100 + s;
        if (odds <= -100) return s * 100 / -odds + s;
        return null;
    }
  }

  static int? wireWinnings({required double odds, required int stake}) {
    final double? total = totalReturn(odds: odds, stake: stake);
    return total?.round();
  }

  static int? profit({
    required double odds,
    required int stake,
    VoltaOddsStyle style = VoltaOddsStyle.decimal,
  }) {
    final double? total = totalReturn(odds: odds, stake: stake, style: style);
    if (total == null) return null;
    return (total - stake).round();
  }
}

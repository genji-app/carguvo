library;

import 'league_enums.dart';

double betPayoutFor(int stake, double odds, OddsStyle style) {
  if (stake <= 0 || odds == 0 || odds == -100) return 0;
  switch (style) {
    case OddsStyle.decimal:
      return stake * odds;
    case OddsStyle.hongKong:
      return stake * odds + stake;
    case OddsStyle.malay:
      if (odds > 0 && odds <= 1) return stake * odds + stake;
      if (odds < 0) return stake + stake * odds.abs();
      return stake.toDouble();
    case OddsStyle.indo:
      if (odds >= 1) return stake * odds + stake;
      if (odds < -1) return stake + stake * odds.abs();
      return stake.toDouble();
  }
}

double betCostFor(int stake, double odds, OddsStyle style) {
  if (stake <= 0) return 0;
  if (style == OddsStyle.malay && odds < 0) return stake * odds.abs();
  if (style == OddsStyle.indo && odds < -1) return stake * odds.abs();
  return stake.toDouble();
}

double roundPlaceOdds(double raw) =>
    double.parse((raw).toStringAsFixed(2));

double roundPlaceOddsFromString(String raw) =>
    roundPlaceOdds(double.tryParse(raw) ?? 0);

bool isShortForBalance({required int? balance, required int totalCostVnd}) {
  if (balance == null) return false;
  if (balance <= 0) return true;
  return totalCostVnd > balance;
}

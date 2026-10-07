library;

import 'league_enums.dart';

class BettingRestRules {
  BettingRestRules._();

  static int thousandUnitToVnd(num raw) => (raw * 1000).round();

  static int parlayRouteSportId(List<int> legSportIds) {
    if (legSportIds.isEmpty) return 1;
    if (legSportIds.every((s) => s == 1)) return 1;
    return legSportIds.firstWhere((s) => s != 1);
  }

  static String oddsStyleApiCode(OddsStyle style) => switch (style) {
        OddsStyle.decimal => 'de',
        OddsStyle.hongKong => 'hk',
        OddsStyle.malay => 'ma',
        OddsStyle.indo => 'in',
      };

  static OddsStyle get parlaySendStyle => OddsStyle.decimal;

  static String get parlaySendOddsStyleApi => 'de';

  static bool isPlaceSuccess({
    required String? ticketId,
    required int errorCode,
    required String status,
  }) {
    final hasTicket = ticketId != null && ticketId.isNotEmpty;
    return hasTicket && (errorCode == 0 || status == 'Active');
  }

  static double? freshOddsFromValues(Object? values) {
    if (values is List && values.length >= 2) {
      return double.tryParse(values[1].toString());
    }
    return null;
  }

  static int parlayStakeForLeg(int legIndex, int stake) =>
      legIndex == 0 ? stake : 0;

  static const Set<int> staleOfferCodes = {607, 620, 622};

  static const Set<int> basisChangedCodes = {603, 604, 612, 607, 620, 622};

  static const int sessionStaleCode = 632;
}

import 'package:betting_domain/betting_domain.dart'
    show resolveLivePeriodLabel;

class LiveMatchPeriodResolver {
  static String resolve({
    required int sportId,
    required int gamePart,
    int? currentSet,
  }) {
    return resolveLivePeriodLabel(
      sportId: sportId,
      gamePart: gamePart,
      currentSet: currentSet,
    );
  }
}

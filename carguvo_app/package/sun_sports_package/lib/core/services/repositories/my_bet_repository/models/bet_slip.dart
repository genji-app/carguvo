// ignore_for_file: always_put_required_named_parameters_first

library;

import 'package:betting_domain/betting_domain.dart'
    show BetSlip, ChildBet;
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;

export 'package:betting_domain/betting_domain.dart'
    show
        BetSlip,
        BetSlipX,
        BetSlipStatus,
        ChildBet,
        CashoutInfo,
        CashoutResponse;

extension BetSlipSportX on BetSlip {
  SportType? get sport => SportType.fromId(sportId);
}

extension ChildBetSportX on ChildBet {
  SportType? get sport => SportType.fromId(sportId);
}

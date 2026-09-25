import 'package:sun_sports/core/services/repositories/my_bet_repository/my_bet_repository.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

extension BetSlipX on BetSlip {
  OddsStyle get oddsStyleEnum {
    return switch (oddsStyle.toLowerCase()) {
      'ma' || 'malay' || 'my' => OddsStyle.malay,
      'indo' || 'id' => OddsStyle.indo,
      'hk' || 'hongkong' => OddsStyle.hongKong,
      'de' => OddsStyle.decimal,
      _ => OddsStyle.decimal,
    };
  }
}

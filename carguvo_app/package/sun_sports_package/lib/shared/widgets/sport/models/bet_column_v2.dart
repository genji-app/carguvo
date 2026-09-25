import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_model_v2.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

export 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    show BetColumnType, BetColumnTypeX, OddsChangeDirection;

class BetItemV2 {
  final String? label;
  final String? value;

  final String? selectionId;

  final OddsModelV2? oddsData;

  final MarketModelV2? marketData;

  final OddsType? oddsType;

  const BetItemV2({
    this.label,
    this.value,
    this.selectionId,
    this.oddsData,
    this.marketData,
    this.oddsType,
  });
}

class BetColumnV2 {
  final BetColumnType type;
  final List<BetItemV2> items;

  const BetColumnV2({required this.type, this.items = const []});

  String get title => type.title;
}

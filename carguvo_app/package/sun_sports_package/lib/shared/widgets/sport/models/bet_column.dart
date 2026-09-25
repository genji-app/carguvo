import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

export 'package:sun_sports/shared/domain/enums/betting_enums.dart'
    show BetColumnType, BetColumnTypeX, OddsChangeDirection;

class BetItem {
  final String? label;
  final String? value;

  final String? selectionId;

  final LeagueOddsData? oddsData;

  final LeagueMarketData? marketData;

  final OddsType? oddsType;

  const BetItem({
    this.label,
    this.value,
    this.selectionId,
    this.oddsData,
    this.marketData,
    this.oddsType,
  });
}

class BetColumn {
  final BetColumnType type;
  final List<BetItem> items;

  const BetColumn({required this.type, this.items = const []});

  String get title => type.title;
}

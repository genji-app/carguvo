import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart'
    show PointsFormatter;
import 'package:sun_sports/shared/helpers/market_odds_rules.dart';
import 'package:sun_sports/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

class _BetColsCacheEntry {
  final OddsFormatV2 fmt;
  final List<BetColumnV2> cols;
  const _BetColsCacheEntry(this.fmt, this.cols);
}

final Expando<_BetColsCacheEntry> _betColsCache = Expando('betColsV2');

class MarketConverterServiceV2 {
  static List<BetColumnV2> marketsToBetColumns(
    List<MarketModelV2> markets, {
    OddsFormatV2 oddsFormat = OddsFormatV2.decimal,
  }) {
    final cached = _betColsCache[markets];
    if (cached != null && cached.fmt == oddsFormat) {
      return cached.cols;
    }

    final columns = <BetColumnV2>[];

    for (final market in markets) {
      final columnType = _getColumnType(market);

      if (columnType == null) continue;

      if (market.oddsList.isNotEmpty) {
        final firstOdds = market.mainLineOdds ?? market.oddsList.first;

        final formattedPoints = PointsFormatter.format(firstOdds.points);

        final effectiveFormat = MarketOddsRules.isAlwaysDecimal(market.marketId)
            ? OddsFormatV2.decimal
            : oddsFormat;

        if (columnType == BetColumnType.matchResult ||
            columnType == BetColumnType.matchResultH1) {
          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: '1',
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                if (firstOdds.isThreeWay)
                  BetItemV2(
                    label: 'X',
                    value: firstOdds.formatDrawOdds(effectiveFormat),
                    selectionId: firstOdds.selectionDrawId,
                    oddsData: firstOdds,
                    marketData: market,
                    oddsType: OddsType.draw,
                  ),
                BetItemV2(
                  label: '2',
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        } else if (columnType == BetColumnType.overUnder ||
            columnType == BetColumnType.overUnderH1) {
          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: formattedPoints,
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                BetItemV2(
                  label: 'U',
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        } else {
          final pointsValue = firstOdds.pointsValue;
          final String homeLabel;
          final String awayLabel;
          if (pointsValue == 0) {
            final homeDec = firstOdds.getHomeOdds(OddsFormatV2.decimal);
            final awayDec = firstOdds.getAwayOdds(OddsFormatV2.decimal);
            final homeIsUpper = (homeDec > 0 && awayDec > 0)
                ? homeDec <= awayDec
                : true;
            homeLabel = homeIsUpper ? formattedPoints : '';
            awayLabel = homeIsUpper ? '' : formattedPoints;
          } else {
            homeLabel = pointsValue < 0 ? formattedPoints : '';
            awayLabel = pointsValue > 0 ? formattedPoints : '';
          }

          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: homeLabel,
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                BetItemV2(
                  label: awayLabel,
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        }
      }
    }

    final sorted = _sortColumns(columns);
    _betColsCache[markets] = _BetColsCacheEntry(oddsFormat, sorted);
    return sorted;
  }

  static BetColumnType? _getColumnType(MarketModelV2 market) {
    final id = market.marketId;
    final type = market.marketType;

    switch (type) {
      case MarketTypeV2.handicap:
        return BetColumnType.handicap;
      case MarketTypeV2.handicapFirstHalf:
        return BetColumnType.handicapH1;
      case MarketTypeV2.overUnder:
        return BetColumnType.overUnder;
      case MarketTypeV2.overUnderFirstHalf:
        return BetColumnType.overUnderH1;
      case MarketTypeV2.fullTime1X2:
        return BetColumnType.matchResult;
      case MarketTypeV2.firstHalf1X2:
        return BetColumnType.matchResultH1;
      case MarketTypeV2.unknown:
        break;
    }

    if (id == 5) return BetColumnType.handicap;
    if (id == 6) return BetColumnType.handicapH1;
    if (id == 3) return BetColumnType.overUnder;
    if (id == 4) return BetColumnType.overUnderH1;
    if (id == 1) return BetColumnType.matchResult;
    if (id == 2) return BetColumnType.matchResultH1;

    if (id == 27) return BetColumnType.handicap;
    if (id == 28) return BetColumnType.handicapH1;
    if (id == 25) return BetColumnType.overUnder;
    if (id == 26) return BetColumnType.overUnderH1;
    if (id == 23) return BetColumnType.matchResult;
    if (id == 24) return BetColumnType.matchResultH1;

    if (id == 201) return BetColumnType.handicap;
    if (id == 203) return BetColumnType.handicapH1;
    if (id == 202) return BetColumnType.overUnder;
    if (id == 204) return BetColumnType.overUnderH1;
    if (id == 200) return BetColumnType.matchResult;
    if (id == 205) return BetColumnType.matchResultH1;

    if (id == 402) return BetColumnType.handicap;
    if (id == 401) return BetColumnType.overUnder;
    if (id == 400) return BetColumnType.matchResult;

    if (id == 509) return BetColumnType.handicap;
    if (id == 510) return BetColumnType.overUnder;
    if (id == 500) return BetColumnType.matchResult;

    if (id == 709) return BetColumnType.handicap;
    if (id == 710) return BetColumnType.overUnder;
    if (id == 700) return BetColumnType.matchResult;

    if (id == 609) return BetColumnType.handicap;
    if (id == 610) return BetColumnType.overUnder;
    if (id == 600) return BetColumnType.matchResult;

    return null;
  }

  static List<BetColumnV2> _sortColumns(List<BetColumnV2> columns) {
    final order = [
      BetColumnType.handicap,
      BetColumnType.overUnder,
      BetColumnType.matchResult,
      BetColumnType.handicapH1,
      BetColumnType.overUnderH1,
      BetColumnType.matchResultH1,
    ];

    columns.sort((a, b) {
      final indexA = order.indexOf(a.type);
      final indexB = order.indexOf(b.type);
      return indexA.compareTo(indexB);
    });

    return columns;
  }

  static List<BetColumnV2> emptyColumns({bool includeH1 = true}) {
    final columns = [
      const BetColumnV2(type: BetColumnType.handicap),
      const BetColumnV2(type: BetColumnType.overUnder),
      const BetColumnV2(type: BetColumnType.matchResult),
    ];

    if (includeH1) {
      columns.addAll([
        const BetColumnV2(type: BetColumnType.handicapH1),
        const BetColumnV2(type: BetColumnType.overUnderH1),
        const BetColumnV2(type: BetColumnType.matchResultH1),
      ]);
    }

    return columns;
  }
}

extension EventModelV2UIConverter on EventModelV2 {
  List<BetColumnV2> toBetColumnsV2({
    OddsFormatV2 oddsFormat = OddsFormatV2.decimal,
  }) => MarketConverterServiceV2.marketsToBetColumns(
    markets,
    oddsFormat: oddsFormat,
  );
}

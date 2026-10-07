import 'package:freezed_annotation/freezed_annotation.dart';

import 'odds_model_v2.dart';

part 'market_model_v2.freezed.dart';

@freezed
sealed class MarketModelV2 with _$MarketModelV2 {
  const factory MarketModelV2({
    @Default([]) List<OddsModelV2> oddsList,

    @Default(0) int sportId,

    @Default(0) int leagueId,

    @Default(0) int eventId,

    @Default(0) int marketId,

    @Default(false) bool isSuspended,

    @Default(false) bool isParlay,

    @Default(false) bool isCashOut,

    @Default(0) int promotionType,

    @Default(0) int groupId,
  }) = _MarketModelV2;

  const MarketModelV2._();

  factory MarketModelV2.fromJson(Map<String, dynamic> json) {
    final oddsList = <OddsModelV2>[];
    final rawOddsList = json['0'];
    if (rawOddsList is List) {
      for (final item in rawOddsList) {
        if (item is Map<String, dynamic>) {
          oddsList.add(OddsModelV2.fromJson(item));
        } else if (item is Map) {
          oddsList.add(OddsModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return MarketModelV2(
      oddsList: oddsList,
      sportId: _parseInt(json['1']),
      leagueId: _parseInt(json['2']),
      eventId: _parseInt(json['3']),
      marketId: _parseInt(json['4']),
      isSuspended: json['5'] == true,
      isParlay: json['6'] == true,
      isCashOut: json['7'] == true,
      promotionType: _parseInt(json['8']),
      groupId: _parseInt(json['9']),
    );
  }

  OddsModelV2? get mainLineOdds {
    try {
      return oddsList.firstWhere((odds) => odds.isMainLine);
    } catch (_) {
      return oddsList.isNotEmpty ? oddsList.first : null;
    }
  }

  bool get isAvailable => !isSuspended && oddsList.isNotEmpty;

  MarketTypeV2 get marketType => MarketTypeV2.fromId(marketId);

  List<OddsModelV2> get availableOdds =>
      oddsList.where((odds) => odds.isAvailable).toList();

  bool get isHandicapMarket => marketId == 5 || marketId == 6;

  bool get isOverUnderMarket => marketId == 3 || marketId == 4;

  bool get is1X2Market => marketId == 1 || marketId == 2;

  bool get isPromotion => promotionType == 1;
}

enum MarketTypeV2 {
  unknown(0, 'Unknown'),
  fullTime1X2(1, '1X2'),
  firstHalf1X2(2, '1X2 First Half'),
  overUnder(3, 'Over/Under'),
  overUnderFirstHalf(4, 'Over/Under First Half'),
  handicap(5, 'Handicap'),
  handicapFirstHalf(6, 'Handicap First Half');

  final int id;
  final String displayName;

  const MarketTypeV2(this.id, this.displayName);

  static MarketTypeV2 fromId(int id) {
    return MarketTypeV2.values.firstWhere(
      (type) => type.id == id,
      orElse: () => MarketTypeV2.unknown,
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

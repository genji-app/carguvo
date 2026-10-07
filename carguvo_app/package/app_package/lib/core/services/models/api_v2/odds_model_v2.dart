import 'package:freezed_annotation/freezed_annotation.dart';

import 'odds_style_model_v2.dart';

part 'odds_model_v2.freezed.dart';

@freezed
sealed class OddsModelV2 with _$OddsModelV2 {
  const factory OddsModelV2({
    @Default('') String selectionHomeId,

    @Default('') String selectionAwayId,

    @Default('') String selectionDrawId,

    @Default('') String points,

    OddsStyleModelV2? homeOdds,

    OddsStyleModelV2? awayOdds,

    OddsStyleModelV2? drawOdds,

    @Default('') String strOfferId,

    @Default(false) bool isMainLine,

    @Default(false) bool isSuspended,

    @Default(false) bool isHidden,

    @Default('') String playerName,

    @Default('') String playerId,

    @Default(0) int period,
  }) = _OddsModelV2;

  const OddsModelV2._();

  factory OddsModelV2.fromJson(Map<String, dynamic> json) {
    return OddsModelV2(
      selectionHomeId: json['0']?.toString() ?? '',
      selectionAwayId: json['1']?.toString() ?? '',
      selectionDrawId: json['2']?.toString() ?? '',
      points: json['3']?.toString() ?? '',
      homeOdds: json['4'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['4'] as Map),
            )
          : null,
      awayOdds: json['5'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['5'] as Map),
            )
          : null,
      drawOdds: json['6'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['6'] as Map),
            )
          : null,
      strOfferId: json['7']?.toString() ?? '',
      isMainLine: json['8'] == true,
      isSuspended: json['9'] == true,
      isHidden: json['10'] == true,
      playerName: json['11']?.toString() ?? '',
      playerId: json['12']?.toString() ?? '',
      period: _parseInt(json['13']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double get pointsValue => double.tryParse(points) ?? 0.0;

  bool get isHandicap => points.isNotEmpty && pointsValue != 0.0;

  bool get isAvailable =>
      !isSuspended &&
      !isHidden &&
      (homeOdds?.isValid == true || awayOdds?.isValid == true);

  String get handicapDisplay {
    if (points.isEmpty) return '';
    final value = pointsValue;
    if (value > 0) return '+$points';
    return points;
  }

  bool get isThreeWay => selectionDrawId.isNotEmpty && drawOdds != null;

  double getHomeOdds(OddsFormatV2 format) {
    return homeOdds?.getValueByFormat(format) ?? 0.0;
  }

  double getAwayOdds(OddsFormatV2 format) {
    return awayOdds?.getValueByFormat(format) ?? 0.0;
  }

  double? getDrawOdds(OddsFormatV2 format) {
    return drawOdds?.getValueByFormat(format);
  }

  String formatHomeOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getHomeOdds(format);
    if (value == 0) return '-';
    return value.toStringAsFixed(decimals);
  }

  String formatAwayOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getAwayOdds(format);
    if (value == 0) return '-';
    return value.toStringAsFixed(decimals);
  }

  String? formatDrawOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getDrawOdds(format);
    if (value == null || value == 0) return null;
    return value.toStringAsFixed(decimals);
  }
}

import 'package:betting_domain/betting_domain.dart'
    show HotStatsInput, HotStatsRules;
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';

HotBettingTrend? resolveHotBettingTrend(
  Map<String, dynamic> simpleJson, {
  required String? mainLinePoints,
  required String homeName,
  required String awayName,
}) {
  final double? mainLine = (mainLinePoints == null || mainLinePoints.isEmpty)
      ? null
      : (double.tryParse(mainLinePoints) ?? 0);
  return HotStatsRules.bettingTrend(
    simpleJson,
    HotStatsInput(mainLine: mainLine, home: homeName, away: awayName),
  );
}

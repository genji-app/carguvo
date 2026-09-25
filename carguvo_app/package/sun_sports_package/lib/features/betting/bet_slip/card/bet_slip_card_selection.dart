import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';

class BetSlipSelectionText {
  const BetSlipSelectionText._();

  static String translate(String oddsName, String homeName, String awayName) {
    switch (oddsName.toLowerCase()) {
      case 'home':
        return homeName.isNotEmpty ? homeName : oddsName;
      case 'away':
        return awayName.isNotEmpty ? awayName : oddsName;
      case 'draw':
        return 'Hòa';
      case 'over':
        return 'Tài';
      case 'under':
        return 'Xỉu';
      case 'odd':
        return 'Lẻ';
      case 'even':
        return 'Chẵn';
      case 'yes':
        return 'Có';
      case 'no':
        return 'Không';
      case 'exact':
        return 'Chính xác';
      case 'none':
        return 'Không có';
      case '1st half':
        return 'Hiệp 1';
      case '2nd half':
        return 'Hiệp 2';
      default:
        return oddsName;
    }
  }

  static List<InlineSpan> buildSpans({
    required String oddsName,
    required String cls,
    required String oddsStyle,
    required String homeName,
    required String awayName,
    required int marketId,
    String score = '',
  }) {
    final segments = buildSegments(
      oddsName: oddsName,
      cls: cls,
      oddsStyle: oddsStyle,
      homeName: homeName,
      awayName: awayName,
      marketId: marketId,
      score: score,
    );

    return [
      TextSpan(
        text: segments.name,
        style: AppTextStyles.labelMedium(color: AppColorStyles.contentPrimary),
      ),
      if (segments.points != null)
        TextSpan(
          text: ' ${segments.points}',
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentPrimary,
          ),
        ),
      if (segments.score != null)
        TextSpan(
          text: ' ${segments.score}',
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentTertiary,
          ),
        ),
      if (segments.style != null)
        TextSpan(
          text: ' ${segments.style}',
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentTertiary,
          ),
        ),
    ];
  }

  @visibleForTesting
  static ({String name, String? points, String? score, String? style})
  buildSegments({
    required String oddsName,
    required String cls,
    required String oddsStyle,
    required String homeName,
    required String awayName,
    required int marketId,
    String score = '',
  }) {
    final name = translate(oddsName, homeName, awayName);

    if (MarketLayoutHelper.isCombo(marketId) ||
        MarketLayoutHelper.isHalfTimeFullTime(marketId)) {
      String? decoded;
      if (MarketLayoutHelper.isCombo(marketId)) {
        decoded = MarketLayoutHelper.comboCellLabel(
          marketId,
          cls,
          homeName: homeName,
          awayName: awayName,
        );
      } else {
        final label = MarketLayoutHelper.htFtLabel(
          cls,
          homeName: homeName,
          awayName: awayName,
        );
        decoded = label == cls ? null : label;
      }
      return (
        name: decoded ?? name,
        points: null,
        score: _placementScoreText(score),
        style: oddsStyle.isNotEmpty ? oddsStyle.toUpperCase() : null,
      );
    }

    final isGoalCountSelection =
        MarketLayoutHelper.isTotalScore(marketId) ||
        MarketLayoutHelper.isExactGoals(marketId);

    final isScore = cls.contains(':') && !isGoalCountSelection;
    final showPoint =
        MarketLayoutHelper.isHandicap(marketId) ||
        MarketLayoutHelper.isOverUnder(marketId);
    final pointsText = isScore
        ? (CorrectScoreHelper.isAOS(cls) ? 'AOS' : '[${cls.replaceAll(':', '-')}]')
        : (showPoint && cls.isNotEmpty && (double.tryParse(cls) ?? 0) != 0
              ? '($cls)'
              : null);

    final scoreText = _placementScoreText(score);

    return (
      name: name,
      points: pointsText,
      score: scoreText,
      style: oddsStyle.isNotEmpty ? oddsStyle.toUpperCase() : null,
    );
  }

  static String? _placementScoreText(String score) {
    final normalized = score
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(':', '-')
        .trim();
    return normalized.isEmpty ? null : '[$normalized]';
  }
}

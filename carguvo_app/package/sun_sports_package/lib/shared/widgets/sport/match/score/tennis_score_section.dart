import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sport/match/score_header_config.dart';

class TennisScoreSection extends StatelessWidget {
  final EventModelV2 event;
  final bool isDesktop;

  const TennisScoreSection({required this.event, this.isDesktop = false, super.key});

  static const _columnW = ScoreHeaderConfig.columnWidth;

  double get _gap => isDesktop
      ? ScoreHeaderConfig.columnGapDesktop
      : ScoreHeaderConfig.columnGap;

  static final _textStyle = AppTextStyles.paragraphXSmall(
    color: AppColorStyles.contentSecondary,
  );

  static final _totalTextStyle = AppTextStyles.paragraphXSmall(
    color: AppColorStyles.contentPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final score = event.score;
    if (score is! TennisScoreModelV2) {
      return _buildEmptyLayout();
    }

    int homeTotal = 0;
    int awayTotal = 0;
    for (final s in score.liveScores) {
      if (s.homeScore.isNotEmpty) {
        homeTotal += s.homeScoreInt;
        awayTotal += s.awayScoreInt;
      }
    }

    final point = score.currentPointDisplay;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildScoreColumn(
          home: score.homeSetScore.toString(),
          away: score.awaySetScore.toString(),
        ),
        SizedBox(width: _gap),
        for (var i = 0; i < 5; i++) ...[
          _buildScoreColumn(
            home: _getSetScore(score, i, true),
            away: _getSetScore(score, i, false),
          ),
          SizedBox(width: _gap),
        ],
        _buildScoreColumn(home: point?.$1 ?? '-', away: point?.$2 ?? '-'),
        SizedBox(width: _gap),
        _buildTotalColumn(
          home: homeTotal > 0 ? homeTotal.toString() : '-',
          away: awayTotal > 0 ? awayTotal.toString() : '-',
        ),
      ],
    );
  }

  Widget _buildEmptyLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 7; i++) ...[
          _buildScoreColumn(home: '-', away: '-'),
          SizedBox(width: _gap),
        ],
        _buildTotalColumn(home: '-', away: '-'),
      ],
    );
  }

  String _getSetScore(TennisScoreModelV2 score, int index, bool isHome) {
    final s = score.liveScores.elementAtOrNull(index);
    if (s == null) return '-';
    final value = isHome ? s.homeScore : s.awayScore;
    return value.isNotEmpty ? value : '-';
  }

  Widget _buildScoreColumn({required String home, required String away}) {
    return SizedBox(
      width: _columnW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScoreCell(value: home),
          _ScoreCell(value: away),
        ],
      ),
    );
  }

  Widget _buildTotalColumn({required String home, required String away}) {
    return Container(
      width: _columnW,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        border: Border.all(color: AppColors.gray500, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScoreCell(value: home, isTotal: true),
          _ScoreCell(value: away, isTotal: true),
        ],
      ),
    );
  }
}

class _ScoreCell extends StatelessWidget {
  final String value;
  final bool isTotal;

  const _ScoreCell({required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Text(
        value,
        style: isTotal
            ? TennisScoreSection._totalTextStyle
            : TennisScoreSection._textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

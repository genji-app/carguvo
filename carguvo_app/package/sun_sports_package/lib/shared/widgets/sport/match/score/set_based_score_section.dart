import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sport/match/score_header_config.dart';

class SetBasedScoreSection extends StatelessWidget {
  final int eventId;
  final List<HomeAwayScoreV2> liveScores;
  final int homeSetScore;
  final int awaySetScore;
  final int homeTotalPoint;
  final int awayTotalPoint;

  final int fixedColumnCount;

  final bool isDesktop;

  const SetBasedScoreSection({
    required this.eventId,
    required this.liveScores,
    required this.homeSetScore,
    required this.awaySetScore,
    required this.homeTotalPoint,
    required this.awayTotalPoint,
    required this.fixedColumnCount,
    this.isDesktop = false,
    super.key,
  });

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fixedColumnCount; i++) ...[
          _buildScoreColumn(
            home: _getScore(i, true),
            away: _getScore(i, false),
          ),
          SizedBox(width: _gap),
        ],
        _buildTotalColumn(
          home: homeTotalPoint.toString(),
          away: awayTotalPoint.toString(),
        ),
      ],
    );
  }

  String _getScore(int index, bool isHome) {
    final s = liveScores.elementAtOrNull(index);
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
            ? SetBasedScoreSection._totalTextStyle
            : SetBasedScoreSection._textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

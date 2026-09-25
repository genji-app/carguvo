import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sport/match/score_header_config.dart';

extension BasketballScoreX on BasketballScoreModelV2 {
  HomeAwayScoreV2? get q1 => liveScores.elementAtOrNull(0);
  HomeAwayScoreV2? get q2 => liveScores.elementAtOrNull(1);
  HomeAwayScoreV2? get ht =>
      liveScores.elementAtOrNull(2);
  HomeAwayScoreV2? get q3 => liveScores.elementAtOrNull(3);
  HomeAwayScoreV2? get q4 => liveScores.elementAtOrNull(4);
}

class BasketballScoreSection extends ConsumerWidget {
  final EventModelV2 event;
  final bool isDesktop;

  const BasketballScoreSection({required this.event, this.isDesktop = false, super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final score = event.score;
    if (score is! BasketballScoreModelV2) {
      return _buildEmptyLayout();
    }

    final liveTotal = ref.watch(eventScoreProvider(event.eventId));
    final homeTotal = liveTotal?.$1 ?? score.homeScoreFT;
    final awayTotal = liveTotal?.$2 ?? score.awayScoreFT;

    final quarters = [score.q1, score.q2, score.ht, score.q3, score.q4];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final q in quarters) ...[
          _buildScoreColumn(
            home: _valueOrDash(q?.homeScore),
            away: _valueOrDash(q?.awayScore),
          ),
          SizedBox(width: _gap),
        ],
        _buildTotalColumn(
          home: homeTotal.toString(),
          away: awayTotal.toString(),
        ),
      ],
    );
  }

  Widget _buildEmptyLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          _buildScoreColumn(home: '-', away: '-'),
          SizedBox(width: _gap),
        ],
        _buildTotalColumn(home: '-', away: '-'),
      ],
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.isEmpty) return '-';
    return value;
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
            ? BasketballScoreSection._totalTextStyle
            : BasketballScoreSection._textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

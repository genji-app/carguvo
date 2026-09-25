import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/currency_helper.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

class RankingEntry {
  final int? rank;
  final String username;
  final int winAmount;

  const RankingEntry({
    required this.username,
    required this.winAmount,
    this.rank,
  });
}

const double kRankColumnWidth = 64;

const EdgeInsets _kCellPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 16,
);

class RankingRow extends StatelessWidget {
  final int rank;
  final RankingEntry entry;
  final bool showDivider;

  const RankingRow({
    required this.rank,
    required this.entry,
    required this.showDivider,
    super.key,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: showDivider
          ? const Border(
              bottom: BorderSide(color: AppColorStyles.borderPrimary),
            )
          : null,
    ),
    child: Row(
      children: [
        SizedBox(
          width: kRankColumnWidth,
          child: Center(child: _RankBadge(rank: rank)),
        ),
        Expanded(
          child: Padding(
            padding: _kCellPadding,
            child: Text(
              entry.username,
              style: AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: _kCellPadding,
          child: GradientText(
            CurrencyHelper.formatCurrencyNoUnit(entry.winAmount),
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  String? get _topIcon => switch (rank) {
    1 => MiniGameIcons.txRanking1,
    2 => MiniGameIcons.txRanking2,
    3 => MiniGameIcons.txRanking3,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _topIcon;
    if (icon != null) {
      return ImageHelper.load(path: icon, width: 34, height: 34);
    }
    return Text(
      '$rank',
      style: AppTextStyles.textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
        color: Colors.white,
      ),
    );
  }
}

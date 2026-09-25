import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sport/models/bet_column.dart';
import '../../../../../shared/widgets/cards/bet_card.dart';

class MarketRowBetDetail extends StatelessWidget {
  final String marketName;

  final List<BetColumn> betColumns;

  const MarketRowBetDetail({
    super.key,
    required this.marketName,
    this.betColumns = const [],
  });

  static const List<BetColumn> _defaultBetColumns = [
    BetColumn(type: BetColumnType.handicap),
    BetColumn(type: BetColumnType.overUnder),
    BetColumn(type: BetColumnType.matchResult),
    BetColumn(type: BetColumnType.handicapH1),
    BetColumn(type: BetColumnType.overUnderH1),
    BetColumn(type: BetColumnType.matchResultH1),
  ];

  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const _headerPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const _tabColor = Color(0xFFAAA49B);
  static const _marketNameColor = Color(0xFFFFFCDB);

  static final _headerGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0),
      Colors.white.withOpacity(0.06),
      Colors.white.withOpacity(0),
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  List<BetColumn> get _columns =>
      betColumns.isNotEmpty ? betColumns : _defaultBetColumns;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _buildMarketNameHeader(),
      _buildOddsContent(),
    ],
  );

  Widget _buildMarketNameHeader() => Container(
    padding: _headerPadding,
    decoration: BoxDecoration(gradient: _headerGradient),
    child: Row(
      children: [
        SizedBox(
          width: 141,
          child: Text(
            marketName,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _marketNameColor,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 3 && i < _columns.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      _columns[i].title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: _tabColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              for (var i = 3; i < 6 && i < _columns.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      _columns[i].title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: _tabColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
      ],
    ),
  );

  Widget _buildOddsContent() => Padding(
    padding: _contentPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 141),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 3 && i < _columns.length; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildBetColumnItems(_columns[i].items),
                  ),
                ),
                if (i != 2) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 3; i < 6 && i < _columns.length; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildBetColumnItems(_columns[i].items),
                  ),
                ),
                if (i != 5) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
      ],
    ),
  );

  List<Widget> _buildBetColumnItems(List<BetItem> items) {
    if (items.isEmpty) {
      return const [SizedBox(height: 36)];
    }

    return List.generate(items.length, (index) {
      final item = items[index];
      final isLast = index == items.length - 1;

      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
        child: BetCard(
          label: item.label,
          value: item.value,
          selectionId: item.selectionId,
        ),
      );
    });
  }
}

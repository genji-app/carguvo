import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/hot_match/hot_match_container.dart';

class HotMatchShimmerLoading extends StatelessWidget {
  const HotMatchShimmerLoading({
    super.key,
    this.isRightSidebar = false,
    this.showLeagueFilter = true,
    this.compactCards = false,
  });

  final bool compactCards;
  final bool isRightSidebar;

  final bool showLeagueFilter;

  static const double _horizontalGap = 8;

  static const double _horizontalPadding = 12;
  static const double _cardGutter = 4;
  static const Color _barColor = AppColorStyles.borderPrimary;

  static const double _scoreboardGap = 8;
  static const double _logoSize = 40;
  static const double _stateColumnWidth = 96;
  static const double _twoNameLinesMinHeight = 40;

  static const _cardShadow = BoxShadow(
    offset: Offset(0, -0.65),
    blurRadius: 0.5,
    spreadRadius: 0.05,
    blurStyle: BlurStyle.inner,
    color: Color(0x26FFFFFF),
  );

  @override
  Widget build(BuildContext context) {
    final itemsToShow = HotMatchContainer.itemsToShowOf(
      context,
      isRightSidebar: isRightSidebar,
    );
    final isDesktopOdds = !ResponsiveBuilder.isMobile(context);
    final totalGaps = itemsToShow > 1
        ? (itemsToShow - 1) * _horizontalGap
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [_cardShadow],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth - _cardGutter * 2;
          final itemWidth = ((contentWidth - totalGaps) / itemsToShow)
              .floorToDouble();
          if (compactCards) {
            final width = HotMatchContainer.compactCardWidth(
              constraints.maxWidth,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(8),
                if (showLeagueFilter) _leagueFilter(context),
                SizedBox(
                  height: HotMatchContainer.compactCardHeight + _cardGutter,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: _cardGutter,
                      right: _cardGutter,
                      bottom: _cardGutter,
                    ),
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const Gap(_horizontalGap),
                        _compactCard(width),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
          final card = _card(
            reserveTwoLines: itemsToShow > 1,
            isDesktopOdds: isDesktopOdds,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(8),
              if (showLeagueFilter) _leagueFilter(context),
              Padding(
                padding: const EdgeInsets.only(
                  left: _cardGutter,
                  right: _cardGutter,
                  bottom: _cardGutter,
                ),
                child: itemsToShow == 1
                    ? card
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < itemsToShow; i++) ...[
                            if (i > 0) const Gap(_horizontalGap),
                            SizedBox(width: itemWidth, child: card),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _compactCard(double width) {
    Widget teamRow() => SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _bar(width: 24, height: 24, radius: 4),
            const Gap(8),
            _bar(width: width * 0.45, height: 10),
          ],
        ),
      ),
    );
    return Container(
      width: width,
      height: HotMatchContainer.compactCardHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
            child: Row(
              children: [
                const Gap(4),
                _bar(width: 48, height: 8),
                const Gap(4),
                _bar(width: 28, height: 8),
              ],
            ),
          ),
          const Gap(4),
          teamRow(),
          teamRow(),
        ],
      ),
    );
  }

  static Widget _leagueFilter(BuildContext context) {
    final height = HotMatchContainer.leagueFilterRowHeight(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: HotMatchContainer.leagueFilterBottomGap,
      ),
      child: SizedBox(
        height: height,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          children: [
            _PillPlaceholder(width: 80, height: height),
            const Gap(8),
            _PillPlaceholder(width: 140, height: height),
            const Gap(8),
            _PillPlaceholder(width: 110, height: height),
          ],
        ),
      ),
    );
  }

  static Widget _card({
    required bool reserveTwoLines,
    required bool isDesktopOdds,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoBar(),
          _infoDivider(),
          _scoreboard(reserveTwoLines: reserveTwoLines),
          _odds(isDesktopOdds: isDesktopOdds),
        ],
      ),
    );
  }

  static Widget _infoBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: _barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _reservedLine(AppTextStyles.labelXSmall()),
                  ),
                ),
                const Gap(4),
                const SizedBox(width: 20, height: 20),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bar(width: 16, height: 16, radius: 8),
              const Gap(4),
              _textLine(AppTextStyles.labelSmall(), width: 20),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _infoDivider() => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
      ),
    ),
  );

  static Widget _scoreboard({required bool reserveTwoLines}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _bar(
                        width: _logoSize,
                        height: _logoSize,
                        radius: _logoSize / 2,
                      ),
                    ),
                  ),
                  const Gap(_scoreboardGap),
                  Expanded(
                    child: Center(
                      child: _bar(
                        width: _logoSize,
                        height: _logoSize,
                        radius: _logoSize / 2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: _stateColumnWidth, child: _matchState()),
            ],
          ),
          const Gap(_scoreboardGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _teamName(width: 96, reserveTwoLines: reserveTwoLines),
              ),
              const Gap(_scoreboardGap),
              Expanded(
                child: _teamName(width: 72, reserveTwoLines: reserveTwoLines),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _matchState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _textLine(AppTextStyles.labelMedium(), width: 48, height: 8),
        _textLine(AppTextStyles.labelMedium(), width: 56, height: 12),
      ],
    );
  }

  static Widget _teamName({
    required double width,
    required bool reserveTwoLines,
  }) {
    final line = _textLine(AppTextStyles.labelSmall(), width: width);
    if (!reserveTwoLines) return line;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _twoNameLinesMinHeight),
      child: Align(alignment: Alignment.topCenter, child: line),
    );
  }

  static Widget _odds({required bool isDesktopOdds}) {
    Widget cell() => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BetCardMobileV2.defaultBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _textLine(
            AppTextStyles.textStyle(fontSize: isDesktopOdds ? 12 : 11.5),
            width: 28,
            height: 8,
          ),
          _textLine(
            AppTextStyles.displayStyle(
              fontSize: isDesktopOdds ? 14 : 13,
              fontWeight: FontWeight.w700,
            ),
            width: 32,
            height: 10,
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(child: cell()),
          const Gap(16),
          Expanded(child: cell()),
        ],
      ),
    );
  }

  static Widget _reservedLine(TextStyle style) => Text(
    ' ',
    maxLines: 1,
    style: style.copyWith(color: const Color(0x00000000)),
  );

  static Widget _textLine(
    TextStyle style, {
    required double width,
    double height = 10,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _reservedLine(style),
        _bar(width: width, height: height),
      ],
    );
  }

  static Widget _bar({
    required double width,
    required double height,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _barColor,
        borderRadius: BorderRadius.circular(radius ?? height / 2),
      ),
    );
  }
}

class _PillPlaceholder extends StatelessWidget {
  const _PillPlaceholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(999),
    ),
  );
}

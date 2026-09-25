import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/enums/market_filter.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'bet_slip_card_selection.dart';

class _UIDimensions {
  static const double iconSize = 18.0;
  static const double iconPadding = 4.0;
  static const double sportIconSize = 20.0;
  static const double horizontalPadding = 12.0;
}

class BetCardMatchData {
  const BetCardMatchData({
    required this.matchName,
    required this.leagueName,
    required this.marketName,
    required this.displayOdds,
    required this.oddsName,
    required this.cls,
    required this.matchDateText,
    required this.matchType,
    required this.isLive,
    required this.sport,
    required this.marketId,
    required this.settlementStatus,
    this.score = '',
    this.homeName = '',
    this.awayName = '',
    this.oddsStyle = '',
  });

  factory BetCardMatchData.fromBetSlip(BetSlip bet, {bool asComboLeg = false}) {
    return BetCardMatchData(
      matchName: bet.fullMatchNameWithScore,
      leagueName: bet.leagueName,
      marketName: bet.displayMarketName,
      displayOdds: bet.displayOdds,
      oddsName: bet.oddsName,
      cls: bet.cls,
      matchDateText: DateFormat(dateTimeFormat).format(bet.startDate),
      matchType: bet.matchTypeEnum,
      isLive: bet.isMatchLive,
      sport: bet.sport,
      marketId: bet.marketId,
      settlementStatus: asComboLeg
          ? SettlementStatusEnum.fromString(bet.settlementStatus)
          : bet.settlementStatusEnum,
      score: bet.score,
      homeName: bet.homeName ?? '',
      awayName: bet.awayName ?? '',
      oddsStyle: bet.oddsStyle,
    );
  }

  factory BetCardMatchData.fromChildBet(ChildBet subBet) {
    return BetCardMatchData(
      matchName: subBet.fullMatchNameWithScore,
      leagueName: subBet.leagueName,
      marketName: subBet.displayMarketName,
      displayOdds: subBet.displayOdds,
      oddsName: subBet.oddsName,
      cls: subBet.cls,
      matchDateText: DateFormat(dateTimeFormat).format(subBet.startDate),
      matchType: subBet.matchTypeEnum,
      isLive: subBet.isMatchLive,
      sport: subBet.sport,
      marketId: subBet.marketId,
      settlementStatus: subBet.settlementStatusEnum,
      score: subBet.score,
      homeName: subBet.homeName ?? '',
      awayName: subBet.awayName ?? '',
      oddsStyle: subBet.oddsStyle,
    );
  }

  final String matchName;
  final String leagueName;
  final String marketName;
  final String displayOdds;
  final String oddsName;
  final String cls;
  final String matchDateText;
  final MatchType matchType;
  final bool isLive;
  final SportType? sport;

  final int marketId;

  final SettlementStatusEnum settlementStatus;

  final String score;
  final String homeName;
  final String awayName;
  final String oddsStyle;

  static const String dateTimeFormat = 'HH:mm - dd/MM/yyyy';
}

class BetSlipCardMatch extends StatelessWidget {
  const BetSlipCardMatch({
    required this.betData,
    required this.hintData,
    super.key,
    this.onScoreIconTap,
    this.scoreIconEnabled = true,
    this.scoreIconLoading = false,
    this.showSportIcon = false,
    this.statsContent,
  });

  final BetCardMatchData betData;

  final HintData hintData;

  final VoidCallback? onScoreIconTap;

  final bool scoreIconEnabled;

  final bool scoreIconLoading;

  final bool showSportIcon;

  final Widget? statsContent;

  @override
  Widget build(BuildContext context) {
    final isLeagueBetting = betData.matchType == MatchType.leagueBetting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BetSlipLegHeader(
          marketName: betData.marketName,
          marketIcon: MarketCategoryIcon.forMarketId(betData.marketId),
          selectionSpans: BetSlipSelectionText.buildSpans(
            oddsName: betData.oddsName,
            cls: betData.cls,
            oddsStyle: betData.oddsStyle,
            homeName: betData.homeName,
            awayName: betData.awayName,
            marketId: betData.marketId,
            score: betData.score,
          ),
          displayOdds: betData.displayOdds,
          settlementStatus: betData.settlementStatus,
          hintData: hintData,
        ),
        _buildMatchRow(isLeagueBetting),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: statsContent ?? _buildTimeRow(isLeagueBetting),
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildMatchRow(bool isLeagueBetting) {
    return Padding(
      padding: const EdgeInsets.all(_UIDimensions.horizontalPadding),
      child: Row(
        children: [
          if (showSportIcon) ...[
            _buildSportIcon(betData.sport ?? SportType.soccer) ??
                const SizedBox.shrink(),
            const Gap(4),
          ],
          Expanded(
            child: Text(
              betData.matchName,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!isLeagueBetting) ...[const Gap(4), _buildScoreIcon()],
        ],
      ),
    );
  }

  Widget _buildTimeRow(bool isLeagueBetting) {
    return SizedBox(
      height: 20,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: _UIDimensions.horizontalPadding,
        ),
        child: Row(
          children: [
            if (betData.isLive && !isLeagueBetting) ...[
              const MatchLiveIcon(),
              const Gap(6),
            ],
            Text(
              betData.matchDateText,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
            if (betData.leagueName.isNotEmpty) ...[
              const Gap(6),
              const _VerticalBar(),
              const Gap(6),
              Flexible(
                child: Text(
                  betData.leagueName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.paragraphXSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildSportIcon(SportType sport) {
    final path = switch (sport) {
      SportType.soccer => AppIcons.iconSoccer,
      SportType.basketball => AppIcons.iconBasketball,
      SportType.tennis => AppIcons.iconTennis,
      SportType.volleyball => AppIcons.iconVolleyball,
      SportType.tableTennis => AppIcons.iconTableTennis,
      SportType.badminton => AppIcons.iconBadminton,
      _ => null,
    };
    if (path == null) return null;
    return SizedBox.square(
      dimension: _UIDimensions.sportIconSize,
      child: ImageHelper.load(path: path),
    );
  }

  Widget _buildScoreIcon() {
    if (scoreIconLoading) {
      return const SizedBox.square(
        dimension: 20,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      );
    }

    final icon = Opacity(
      opacity: scoreIconEnabled ? 1.0 : 0.5,
      child: SizedBox.square(
        dimension: 20,
        child: ImageHelper.load(path: AppIcons.icScore),
      ),
    );

    if (!scoreIconEnabled || onScoreIconTap == null) return icon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onScoreIconTap),
      child: icon,
    );
  }
}

class BetSlipLegHeader extends StatelessWidget {
  const BetSlipLegHeader({
    required this.marketName,
    required this.selectionSpans,
    required this.displayOdds,
    required this.settlementStatus,
    this.marketIcon,
    this.hintData,
    this.tooltipTitle,
    super.key,
  });

  final String marketName;

  final Widget? marketIcon;

  final List<InlineSpan> selectionSpans;
  final String displayOdds;

  final SettlementStatusEnum settlementStatus;

  final HintData? hintData;

  final String? tooltipTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (marketIcon != null) ...[marketIcon!, const Gap(4)],
              Expanded(
                child: Text(
                  marketName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
              ),
              const Gap(12),
              if (hintData != null)
                BetExplanationTooltip.icon(
                  hintData: hintData!,
                  iconColor: AppColorStyles.contentSecondary,
                  iconSize: _UIDimensions.iconSize,
                  titleOverride: tooltipTitle,
                  config: const BetTooltipConfig(
                    rootOverlay: false,
                    triggerPadding: EdgeInsets.all(_UIDimensions.iconPadding),
                    offset: Offset(8, 0),
                  ),
                ),
              if (settlementStatus.isSettled) ...[
                const Gap(8),
                BetSlipCardStatusBadge(settlementStatus),
              ],
            ],
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: selectionSpans),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(12),
              Text(
                displayOdds,
                style: AppTextStyles.labelMedium(
                  color: const Color(0xFFACDC79),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MarketCategoryIcon {
  const MarketCategoryIcon._();

  static const double _size = 16;

  static Widget? forMarketId(int marketId) {
    final path = switch (marketId) {
      _ when MarketFilterMapping.cornerMarketIds.contains(marketId) =>
        AppIcons.phatGoc,
      _ when MarketFilterMapping.bookingMarketIds.contains(marketId) =>
        AppIcons.iconMarketCard,
      _ => null,
    };
    if (path == null) return null;
    return SizedBox.square(
      dimension: _size,
      child: ImageHelper.load(path: path),
    );
  }
}

class MatchLiveIcon extends StatelessWidget {
  const MatchLiveIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.red500,
      ),
      child: Text(
        'Trực tiếp',
        style: AppTextStyles.labelXXSmall(color: AppColorStyles.contentPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:sun_sports/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';
import 'package:sun_sports/shared/widgets/teams/team_display.dart';
import 'package:sun_sports/features/sport/presentation/providers/match_notice_provider.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_shared_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/score/soccer_score_section.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll_blocked_tap.dart';
import 'package:sun_sports/shared/widgets/scroll_deferred_mount.dart';
import 'package:sun_sports/shared/widgets/sport/match/static_odds_cell.dart';

final _kText10W500White = AppTextStyles.textStyle(
    fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFFFFFEF5));
final _kText12W400White = AppTextStyles.textStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFFFFEF5));
final _kLabelXSmallGrey =
    AppTextStyles.labelXSmall(color: const Color(0xFF9C9B95));

class MatchRowSoccerV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool isDesktop;

  const MatchRowSoccerV2({
    required this.event,
    this.league,
    this.isDesktop = false,
    super.key,
  });

  bool get _canShowStats => event.eventStatsId > 0;
  bool get _canShowTracker => event.eventStatsId > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const oddsFormat = OddsFormatV2.decimal;
    final oddsSportId = sportIdForFavoriteEvent(
      event,
      league,
      ref.read(selectedSportV2Provider).id,
    );
    final betColumns = getBetColumnsV2(event, oddsFormat);
    final h1BetColumns = isDesktop
        ? getBetColumnsH1V2(event, oddsFormat)
        : null;
    final isLive = event.isLive;
    final matchTime = isLive ? event.liveStatusDisplay : event.formattedTime;
    final (minute, period) = parseMatchTime(matchTime);
    final hasLiveStream = isLive && event.isLiveStream == true;

    final footer = MatchFooterV2(
      event: event,
      league: league,
      canShowStats: _canShowStats,
      canShowTracker: _canShowTracker,
      compact: !isDesktop,
      onNavigate: () => navigateToBetDetail(ref, event, league),
      onFavoriteTap: () =>
          toggleFavoriteEvent(context, ref, event, league: league),
    );

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MatchHeaderSoccerV2(
            columns: betColumns,
            h1Columns: h1BetColumns,
            isLive: isLive,
            minute: minute,
            period: period,
            eventId: event.eventId,
            onLiveBadgeTap: !isDesktop && hasLiveStream
                ? () => navigateToBetDetail(ref, event, league)
                : null,
          ),

          Expanded(
            child: Container(
              color: AppColorStyles.backgroundQuaternary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TeamsSectionSoccerV2(
                    event: event,
                    isLive: isLive,
                    isDesktop: isDesktop,
                    inlineFooter: isDesktop ? null : footer,
                    onTap: () => navigateToBetDetail(ref, event, league),
                  ),

                  SizedBox(width: isDesktop ? 24 : 16),

                  _OddsSectionSoccerV2(
                    sportId: oddsSportId,
                    event: event,
                    league: league,
                    columns: betColumns,
                    isDesktop: isDesktop,
                  ),

                  if (h1BetColumns != null) ...[
                    const SizedBox(width: 24),
                    _OddsSectionSoccerV2(
                      sportId: oddsSportId,
                      event: event,
                      league: league,
                      columns: h1BetColumns,
                      isDesktop: isDesktop,
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (isDesktop) footer,
        ],
      ),
    );
  }
}

class _MatchHeaderSoccerV2 extends StatelessWidget {
  final List<BetColumnV2?> columns;

  final List<BetColumnV2?>? h1Columns;
  final bool isLive;
  final String? minute;
  final String? period;
  final int eventId;

  final VoidCallback? onLiveBadgeTap;

  const _MatchHeaderSoccerV2({
    required this.columns,
    required this.isLive,
    required this.eventId,
    this.h1Columns,
    this.minute,
    this.period,
    this.onLiveBadgeTap,
  });

  String _getDefaultTitle(int index) {
    switch (index) {
      case 0:
        return 'Kèo chấp';
      case 1:
        return 'Tài xỉu';
      case 2:
        return '1X2';
      default:
        return '';
    }
  }

  String _getH1Title(int index) {
    switch (index) {
      case 0:
        return 'H1 Chấp';
      case 1:
        return 'H1 Tài/Xỉu';
      case 2:
        return 'H1 1X2';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (isLive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Trực tiếp',
                      style: _kText10W500White,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (isLive) ...[
                  Flexible(
                    child: LiveMatchTimeDisplay(
                      eventId: eventId,
                      initialMinute: minute,
                      initialPeriod: period,
                      sportId: 1,
                    ),
                  ),
                  if (onLiveBadgeTap != null) ...[
                    const SizedBox(width: 6),
                    ScrollBlockedTap(
                      showClickCursor: true,
                      onTap: SoundTap.wrap(onLiveBadgeTap),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 28,
                        height: 18,
                        child: ImageHelper.load(
                          path: AppIcons.live,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  if (minute != null)
                    Text(
                      minute!,
                      style: _kText12W400White,
                    ),
                  if (minute != null && period != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (period != null)
                    Flexible(
                      child: Text(
                        period!,
                        style: _kText12W400White,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(
                    child: Text(
                      columns[i]?.title ?? _getDefaultTitle(i),
                      textAlign: TextAlign.center,
                      style: _kLabelXSmallGrey,
                    ),
                  ),
              ],
            ),
          ),

          if (h1Columns != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  for (var i = 0; i < h1Columns!.length; i++)
                    Expanded(
                      child: Text(
                        _getH1Title(i),
                        textAlign: TextAlign.center,
                        style: _kLabelXSmallGrey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamsSectionSoccerV2 extends StatelessWidget {
  final EventModelV2 event;
  final bool isLive;
  final bool isDesktop;
  final VoidCallback? onTap;

  final Widget? inlineFooter;

  const _TeamsSectionSoccerV2({
    required this.event,
    required this.isLive,
    required this.isDesktop,
    this.onTap,
    this.inlineFooter,
  });

  Widget _buildTeam({required bool home}) {
    final key = home
        ? MatchNoticeNotifier.homeKey(event.eventId)
        : MatchNoticeNotifier.awayKey(event.eventId);
    return Consumer(
      builder: (context, ref, _) {
        final n = ref.watch(matchNoticeProvider.select((m) => m[key]));
        return TeamDisplay(
          teamName: home ? event.homeName : event.awayName,
          teamLogo: home ? event.homeLogo : event.awayLogo,
          otherTeamLogo: home ? event.awayLogo : event.homeLogo,
          sportId: event.sportId,
          isHome: home,
          isUpperTeam: event.hasUpperTeam
              ? (home ? event.isHomeUpper : event.isAwayUpper)
              : null,
          notice: n?.$1,
          noticeSeq: n?.$2 ?? 0,
          onNoticeCompleted: n == null
              ? null
              : () => ref
                  .read(matchNoticeProvider.notifier)
                  .clearNotice(key, n.$2),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ScrollBlockedTap(
                    onTap: SoundTap.wrap(onTap),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 32, child: _buildTeam(home: true)),
                        SizedBox(height: 32, child: _buildTeam(home: false)),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: isDesktop ? 16 : 8),

                if (isLive) ...[
                  SoccerScoreSection(event: event, showCards: isDesktop),
                ],
              ],
            ),

            if (inlineFooter != null) ...[
              const SizedBox(height: 10),
              SizedBox(height: 35, child: inlineFooter),
            ]
            else if (isLive && event.isLiveStream == true)
              SizedBox(
                height: 50,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    ScrollBlockedTap(
                      onTap: SoundTap.wrap(onTap),
                      child: SizedBox(
                        width: 40,
                        height: 26,
                        child: ImageHelper.load(path: AppIcons.live),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OddsSectionSoccerV2 extends StatelessWidget {
  final int sportId;
  final EventModelV2 event;
  final LeagueModelV2? league;
  final List<BetColumnV2?> columns;
  final bool isDesktop;

  const _OddsSectionSoccerV2({
    required this.sportId,
    required this.event,
    required this.columns,
    required this.isDesktop,
    this.league,
  });

  bool _is1X2Column(BetColumnV2 column) {
    return column.type == BetColumnType.matchResult ||
        column.type == BetColumnType.matchResultH1;
  }

  double get _cellGap => isDesktop ? 4 : 2;
  double get _sectionHeight => isDesktop ? 130 : 109;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: _sectionHeight,
        child: ScrollDeferredMount(
          placeholder: Consumer(
            builder: (context, ref, _) {
              final format = ref.watch(oddsStyleProvider).toOddsFormatV2();
              return _buildGrid(
                eventLocked: event.isSuspended,
                staticFormat: format,
              );
            },
          ),
          child: Consumer(
            builder: (context, ref, _) {
              final eventLocked = event.isSuspended ||
                  ref.watch(detailSwapGuardProvider) != ListBettingGuard.open ||
                  ref.watch(isEventSuspendedProvider(event.eventId));
              return _buildGrid(eventLocked: eventLocked);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGrid({
    required bool eventLocked,
    OddsFormatV2? staticFormat,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          Expanded(
            child: Column(
              children: _buildColumnItems(
                columns[i],
                i,
                eventLocked,
                staticFormat: staticFormat,
              ),
            ),
          ),
          if (i != columns.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  List<Widget> _buildColumnItems(
    BetColumnV2? column,
    int columnIndex,
    bool eventLocked, {
    OddsFormatV2? staticFormat,
  }) {
    if (column == null || column.items.isEmpty) {
      return _buildLockedPlaceholder(columnIndex);
    }

    final items = column.items;
    final is1X2 = _is1X2Column(column);
    final oddsCount = is1X2 ? 3 : 2;
    const slotCount = 3;

    const oneX2DisplayOrder = [0, 2, 1];

    return List.generate(slotCount, (index) {
      final isLast = index == slotCount - 1;

      if (index >= oddsCount) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : _cellGap),
            child: const SizedBox.expand(),
          ),
        );
      }

      final itemIndex = is1X2 ? oneX2DisplayOrder[index] : index;

      if (itemIndex < items.length) {
        final item = items[itemIndex];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : _cellGap),
            child: SizedBox.expand(
              child: staticFormat != null
                  ? _buildStaticCell(item, eventLocked, staticFormat)
                  : _buildRealCell(item, eventLocked),
            ),
          ),
        );
      }

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : _cellGap),
          child: const SizedBox.expand(),
        ),
      );
    });
  }

  Widget _buildRealCell(BetItemV2 item, bool eventLocked) {
    BettingPopupDataV2? bettingData;
    if (item.oddsData != null &&
        item.marketData != null &&
        item.oddsType != null) {
      bettingData = BettingPopupDataV2(
        sportId: sportId,
        oddsData: item.oddsData!,
        marketData: item.marketData!,
        eventData: event,
        oddsType: item.oddsType!,
        leagueData: league,
        oddsFormat: OddsFormatV2.decimal,
      );
    }
    return BetCardMobileV2(
      label: item.label,
      value: item.value,
      selectionId: item.selectionId,
      bettingPopupData: bettingData,
      isVertical: true,
      isDesktop: isDesktop,
      isSetHeightOdds: true,
      isCompact: !isDesktop,
      eventLevelLocked: eventLocked,
    );
  }

  Widget _buildStaticCell(
    BetItemV2 item,
    bool eventLocked,
    OddsFormatV2 format,
  ) {
    return StaticOddsCell(
      label: item.label,
      value: StaticOddsCell.displayValueFor(item, format),
      locked: eventLocked || (item.marketData?.isSuspended ?? false),
      isDesktop: isDesktop,
      isCompact: !isDesktop,
    );
  }

  List<Widget> _buildLockedPlaceholder(int columnIndex) {
    final lockedCount = columnIndex == 2 ? 3 : 2;
    const slotCount = 3;

    return List.generate(slotCount, (index) {
      final isLast = index == slotCount - 1;

      if (index >= lockedCount) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : _cellGap),
            child: const SizedBox.expand(),
          ),
        );
      }

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : _cellGap),
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock, size: 16, color: Colors.white54),
            ),
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/features/sport/domain/services/market_converter_service_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';
import 'package:sun_sports/shared/widgets/sport/match/score_header_config.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:sun_sports/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/stats/stats_dialog.dart';
import 'package:sun_sports/shared/widgets/tooltip/parlay_tooltip.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/tracker/tracker_popup_dialog.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll_blocked_tap.dart';

final _kText14W700Yellow = AppTextStyles.textStyle(
    fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFDE272));
final _kText14W700White = AppTextStyles.textStyle(
    fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFFFEF5));
final _kText10W500White = AppTextStyles.textStyle(
    fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFFFFFEF5));
final _kText12W400White = AppTextStyles.textStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFFFFEF5));
final _kParaXSmallSecondary =
    AppTextStyles.paragraphXSmall(color: AppColorStyles.contentSecondary);
final _kLabelXXSmallGrey =
    AppTextStyles.labelXXSmall(color: const Color(0xFF9C9B95));

int sportIdForFavoriteEvent(
  EventModelV2 event,
  LeagueModelV2? league,
  int selectedSportId,
) {
  if (event.sportId > 0) return event.sportId;
  if (league != null && league.sportId != 0) return league.sportId;
  return selectedSportId;
}

bool isEventFavoriteDisplayed(
  FavoriteState fav,
  int sportId,
  EventModelV2 event,
  LeagueModelV2? league,
) {
  final hasBucket = fav.favoritesBySport.containsKey(sportId);
  if (!hasBucket) {
    return event.isFavorited || (league?.isFavorited ?? false);
  }
  final byEvent = fav.isEventFavorite(sportId, event.eventId);
  final byLeague =
      league != null && fav.isLeagueFavorite(sportId, league.leagueId);
  return byEvent || byLeague;
}

void navigateToBetDetail(
  WidgetRef ref,
  EventModelV2 event,
  LeagueModelV2? league,
) {
  if (league == null) return;
  ref.read(selectedEventV2Provider.notifier).state = event;
  ref.read(selectedLeagueV2Provider.notifier).state = league;
  ref.read(mainContentProvider.notifier).goToBetDetail();
}

Future<void> toggleFavoriteEvent(
  BuildContext context,
  WidgetRef ref,
  EventModelV2 event, {
  LeagueModelV2? league,
}) async {
  if (!requireLogin(context, ref)) return;
  final selectedId = ref.read(selectedSportV2Provider).id;
  final sportId = sportIdForFavoriteEvent(event, league, selectedId);
  final notifier = ref.read(favoriteProvider.notifier);
  final fav = ref.read(favoriteProvider);
  final filled = isEventFavoriteDisplayed(fav, sportId, event, league);

  late final bool success;
  late final String message;
  if (!filled) {
    success = await notifier.addFavoriteEvent(
      sportId: sportId,
      eventId: event.eventId,
    );
    message = 'Đã thêm trận đấu vào yêu thích';
  } else {
    final hasBucket = fav.favoritesBySport.containsKey(sportId);
    if (hasBucket && fav.isEventFavorite(sportId, event.eventId)) {
      success = await notifier.removeFavoriteEvent(
        sportId: sportId,
        eventId: event.eventId,
      );
      message = 'Đã xoá trận đấu khỏi yêu thích';
    } else if (hasBucket &&
        league != null &&
        fav.isLeagueFavorite(sportId, league.leagueId)) {
      success = await notifier.removeFavoriteLeague(
        sportId: sportId,
        leagueId: league.leagueId,
      );
      message = 'Đã xoá giải đấu khỏi yêu thích';
    } else {
      success = await notifier.removeFavoriteEvent(
        sportId: sportId,
        eventId: event.eventId,
      );
      message = 'Đã xoá trận đấu khỏi yêu thích';
    }
  }
  if (success && context.mounted) {
    AppToast.showSuccess(context, message: message);
  }
}

List<BetColumnV2?> getBetColumnsV2(
  EventModelV2 event,
  OddsFormatV2 oddsFormat,
) {
  final allBetColumns = event.toBetColumnsV2(oddsFormat: oddsFormat);

  BetColumnV2? handicapCol;
  BetColumnV2? overUnderCol;
  BetColumnV2? matchResultCol;

  for (final col in allBetColumns) {
    switch (col.type) {
      case BetColumnType.handicap:
        handicapCol ??= col;
      case BetColumnType.overUnder:
        overUnderCol ??= col;
      case BetColumnType.matchResult:
        matchResultCol ??= col;
      default:
        break;
    }
  }

  return [handicapCol, overUnderCol, matchResultCol];
}

List<BetColumnV2?> getBetColumnsH1V2(
  EventModelV2 event,
  OddsFormatV2 oddsFormat,
) {
  final allBetColumns = event.toBetColumnsV2(oddsFormat: oddsFormat);

  BetColumnV2? handicapH1Col;
  BetColumnV2? overUnderH1Col;
  BetColumnV2? matchResultH1Col;

  for (final col in allBetColumns) {
    switch (col.type) {
      case BetColumnType.handicapH1:
        handicapH1Col ??= col;
      case BetColumnType.overUnderH1:
        overUnderH1Col ??= col;
      case BetColumnType.matchResultH1:
        matchResultH1Col ??= col;
      default:
        break;
    }
  }

  return [handicapH1Col, overUnderH1Col, matchResultH1Col];
}

final RegExp _matchTimeSeparator = RegExp(r'\s*\|\s*');

(String? minute, String? period) parseMatchTime(String? matchTime) {
  if (matchTime == null) return (null, null);
  final parts = matchTime.split(_matchTimeSeparator);
  if (parts.length >= 2) {
    return (parts[0].trim(), parts[1].trim());
  }
  return (matchTime, null);
}

int? extractCurrentSet(EventModelV2 event) {
  final score = event.score;
  if (score is VolleyballScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  if (score is BadmintonScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  if (score is TableTennisScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  return null;
}

(int, int)? extractSetScore(EventModelV2 event) {
  final score = event.score;
  if (score is VolleyballScoreModelV2) {
    return (score.homeSetScore, score.awaySetScore);
  }
  if (score is BadmintonScoreModelV2) {
    return (score.homeGameScore, score.awayGameScore);
  }
  if (score is TennisScoreModelV2) {
    return (score.homeSetScore, score.awaySetScore);
  }
  return null;
}

int? getMoreMarketsCount(EventModelV2 event) {
  final totalMarkets = event.marketCount;
  const displayedMarkets = 3;
  return totalMarkets > displayedMarkets
      ? totalMarkets - displayedMarkets
      : null;
}

class MatchFooterV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool canShowStats;
  final bool canShowTracker;
  final VoidCallback? onNavigate;
  final VoidCallback? onFavoriteTap;

  final bool showLiveBadge;

  final bool compact;

  const MatchFooterV2({
    required this.event,
    required this.canShowStats,
    required this.canShowTracker,
    this.league,
    this.onNavigate,
    this.onFavoriteTap,
    this.showLiveBadge = false,
    this.compact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moreMarketsCount = getMoreMarketsCount(event);
    final selectedId =
        ref.watch(selectedSportV2Provider.select((s) => s.id));
    final sportId = sportIdForFavoriteEvent(event, league, selectedId);
    final isEventFavorited = ref.watch(
      favoriteProvider.select(
        (fav) => isEventFavoriteDisplayed(fav, sportId, event, league),
      ),
    );

    final gap = SizedBox(width: compact ? 16 : 20);
    final icons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScrollBlockedTap(
                showClickCursor: true,
                onTap: SoundTap.wrap(onFavoriteTap),
                behavior: HitTestBehavior.opaque,
                child: RepaintBoundary(
                    child: ImageHelper.load(
                      path: isEventFavorited
                          ? AppIcons.iconFavoriteSelected
                          : AppIcons.iconUnFavorite,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: isEventFavorited ? null : const Color(0xB3FFFCDB),
                    ),
                ),
              ),
              gap,
              ScrollBlockedTap(
                showClickCursor: true,
                onTap: SoundTap.wrap(canShowStats
                      ? () {
                          if (!requireLogin(context, ref)) return;
                          _showStatsDialog(context);
                        }
                      : null),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: ImageHelper.load(
                      path: AppIcons.iconBarChart,
                      color: canShowStats
                          ? AppColorStyles.contentSecondary
                          : AppColorStyles.contentSecondary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                ),
              ),
              gap,
              ScrollBlockedTap(
                showClickCursor: true,
                onTap: SoundTap.wrap(canShowTracker
                      ? () {
                          if (!requireLogin(context, ref)) return;
                          _showTrackerPopup(context, sportId);
                        }
                      : null),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: ImageHelper.load(
                      path: AppIcons.iconChart,
                      color: canShowTracker
                          ? AppColorStyles.contentSecondary
                          : AppColorStyles.contentSecondary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                ),
              ),
              if (event.isParlay) ...[
                gap,
                ParlayIconButtonV2(eventId: event.eventId),
              ],
              if (showLiveBadge &&
                  event.isLive &&
                  event.isLiveStream == true) ...[
                gap,
                ScrollBlockedTap(
                  showClickCursor: true,
                  onTap: SoundTap.wrap(onNavigate),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                      width: 40,
                      height: 26,
                      child: ImageHelper.load(
                        path: AppIcons.live,
                        fit: BoxFit.contain,
                      ),
                  ),
                ),
              ],
            ],
          );

    final Widget? more = moreMarketsCount == null
        ? null
        : ScrollBlockedTap(
            showClickCursor: true,
            onTap: SoundTap.wrap(onNavigate),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+$moreMarketsCount',
                  style: compact ? _kText14W700Yellow : _kText14W700White,
                ),
                if (!compact) const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: compact
                      ? const Color(0xFFFDE272)
                      : const Color(0xFFFFFEF5),
                ),
              ],
            ),
          );

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: compact
          ? Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icons,
                    if (more != null) ...[gap, more],
                  ],
                ),
              ),
            )
          : Row(
              children: [
                icons,
                const Spacer(),
                if (more != null) more,
              ],
            ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    StatsDialog.showForMatch(
      context: context,
      eventStatsId: event.eventStatsId,
      homeName: event.homeName,
      awayName: event.awayName,
      config: StatsDialogConfig.mobile,
      width: MediaQuery.of(context).size.width,
    );
  }

  void _showTrackerPopup(BuildContext context, int sportId) {
    TrackerPopupDialog.show(
      context: context,
      eventStatsId: event.eventStatsId,
      sportId: sportId,
      homeName: event.homeName,
      awayName: event.awayName,
    );
  }
}

class ParlayIconButtonV2 extends ConsumerStatefulWidget {
  final int eventId;

  const ParlayIconButtonV2({required this.eventId, super.key});

  @override
  ConsumerState<ParlayIconButtonV2> createState() => _ParlayIconButtonV2State();
}

class _ParlayIconButtonV2State extends ConsumerState<ParlayIconButtonV2> {
  final GlobalKey _iconKey = GlobalKey();

  void _showTooltip(bool isInCombo) {
    ParlayTooltip.show(
      context: context,
      targetKey: _iconKey,
      message: isInCombo
          ? 'Trận này đã thêm vào cược xiên'
          : 'Trận này chưa thêm vào cược xiên',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInCombo = ref.watch(isBetInComboProvider(widget.eventId));

    return ScrollBlockedTap(
      showClickCursor: true,
      onTap: SoundTap.wrap(() => _showTooltip(isInCombo)),
      child: SizedBox(
        key: _iconKey,
        width: 20,
        height: 20,
        child: ImageHelper.load(
          path: AppIcons.iconParlay,
          color: isInCombo
              ? AppColors.green300
              : AppColorStyles.contentSecondary,
        ),
      ),
    );
  }
}

class NonSoccerOddsSection extends StatelessWidget {
  final int sportId;
  final EventModelV2 event;
  final LeagueModelV2? league;
  final List<BetColumnV2?> columns;
  final bool isDesktop;

  const NonSoccerOddsSection({
    required this.sportId,
    required this.event,
    required this.columns,
    required this.isDesktop,
    this.league,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x0FACDC79),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chấp',
                    textAlign: TextAlign.center,
                    style: _kParaXSmallSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tài/Xỉu',
                    textAlign: TextAlign.center,
                    style: _kParaXSmallSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đội thắng',
                    textAlign: TextAlign.center,
                    style: _kParaXSmallSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: isDesktop ? 76 : 94,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  Expanded(
                    child: Column(children: _buildColumnItems(columns[i])),
                  ),
                  if (i != columns.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildColumnItems(BetColumnV2? column) {
    if (column == null || column.items.isEmpty) {
      return _buildLockedPlaceholder();
    }

    final items = column.items;
    const itemCount = 2;

    return List.generate(itemCount, (index) {
      final isLast = index == itemCount - 1;

      if (index < items.length) {
        final item = items[index];

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

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
            child: SizedBox.expand(
              child: BetCardMobileV2(
                label: item.label,
                value: item.value,
                selectionId: item.selectionId,
                bettingPopupData: bettingData,
                isVertical:
                    !isDesktop || column.type == BetColumnType.matchResult,
                isDesktop: isDesktop,
                isSetHeightOdds: true,
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: const SizedBox.expand(),
        ),
      );
    });
  }

  List<Widget> _buildLockedPlaceholder() {
    return List.generate(2, (index) {
      final isLast = index == 1;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
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

class NonSoccerHeader extends StatelessWidget {
  final ScoreHeaderConfig config;
  final bool isLive;
  final String? minute;
  final String? period;
  final int eventId;
  final int sportId;
  final bool isDesktop;
  final int? initialCurrentSet;
  final (int, int)? initialSetScore;

  const NonSoccerHeader({
    required this.config,
    required this.isLive,
    required this.eventId,
    this.isDesktop = false,
    this.sportId = 0,
    this.minute,
    this.period,
    this.initialCurrentSet,
    this.initialSetScore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
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
                if (isLive)
                  Expanded(
                    child: LiveMatchTimeDisplay(
                      eventId: eventId,
                      initialMinute: minute,
                      initialPeriod: period,
                      sportId: sportId,
                      initialCurrentSet: initialCurrentSet,
                      initialSetScore: initialSetScore,
                    ),
                  )
                else ...[
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

          SizedBox(
            width: config.totalWidth(isDesktop: isDesktop),
            child: Row(
              children: [
                if (config.prefixColumn != null) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      config.prefixColumn!,
                      textAlign: TextAlign.center,
                      style: _kLabelXXSmallGrey,
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                for (var i = 0; i < config.columns.length; i++) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      config.columns[i],
                      textAlign: TextAlign.center,
                      style: _kLabelXXSmallGrey,
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                if (config.hasPts) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      'PTS',
                      textAlign: TextAlign.center,
                      style: _kLabelXXSmallGrey,
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                SizedBox(
                  width: ScoreHeaderConfig.columnWidth,
                  child: Text(
                    config.totalLabel,
                    textAlign: TextAlign.center,
                    style: _kLabelXXSmallGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_events/sport_events.dart'
    show LeagueAliasStore, leagueChipLabels;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/features/game/category/game_category_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll/axis_lock_horizontal_scroll.dart';
import 'package:sun_sports/shared/widgets/scroll/snap_scroll_physics.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';
import 'package:sun_sports/shared/widgets/tracker/tracker_popup_dialog.dart';

class HotMatchContainer extends ConsumerStatefulWidget {
  final HotMatchEventV2 match;
  final List<HotMatchEventV2>? matches;
  final VoidCallback? onTap;

  final void Function(HotMatchEventV2 match)? onMatchSelected;

  final String? timeUntilMatch;

  final int? viewCount;

  final int? bettingPercentage;

  final String? favoredTeam;

  final bool isRightSidebar;

  final bool showLeagueFilter;

  final bool compactCards;

  const HotMatchContainer({
    super.key,
    required this.match,
    required this.isRightSidebar,
    this.matches,
    this.onTap,
    this.onMatchSelected,
    this.timeUntilMatch,
    this.viewCount,
    this.bettingPercentage,
    this.favoredTeam,
    this.showLeagueFilter = false,
    this.compactCards = false,
  });

  static const double compactCardHeight = 100;

  static double compactCardWidth(double pagerWidth) {
    final raw = (pagerWidth - _cardGutter - _horizontalGap) / 1.8;
    return raw.clamp(132.0, 240.0).floorToDouble();
  }

  static const double _horizontalGap = 8;

  static const double _horizontalPadding = 12;

  static const double _cardGutter = 4;

  static const double _twoCardMaxWidth = 1530;

  static int itemsToShowOf(
    BuildContext context, {
    bool isRightSidebar = false,
  }) {
    if (ResponsiveBuilder.isMobile(context) || isRightSidebar) return 1;
    return MediaQuery.sizeOf(context).width <= _twoCardMaxWidth ? 2 : 3;
  }

  static const double leagueFilterBottomGap = 8;

  static double leagueFilterRowHeight(BuildContext context) {
    final double paddingV = GameCategoryButton.compactPadding.vertical;
    const double icon = GameCategoryButton.compactIconSize;
    const double fontSize = 14;
    const double heightFactor = 20 / 14;
    final double lineHeight =
        MediaQuery.textScalerOf(context).scale(fontSize) * heightFactor;
    final double needed = paddingV + math.max(icon, lineHeight);
    final double floor = GameCategoryButton.compactConstraints.minHeight;
    return needed > floor ? needed.ceilToDouble() : floor;
  }

  @override
  ConsumerState<HotMatchContainer> createState() => _HotMatchContainerState();
}

class _HotMatchContainerState extends ConsumerState<HotMatchContainer>
    with SingleTickerProviderStateMixin {
  final ScrollController _pager = ScrollController();

  int? _leagueId;

  bool _canPrev = false;
  bool _canNext = false;

  final ScrollGestureAxisLock _chipWheelLock = ScrollGestureAxisLock();

  int _cardCount = 0;

  double _pagerStep = 0;

  static const Duration _pageAnim = Duration(milliseconds: 220);

  late final AnimationController _navFadeCtl = AnimationController(
    vsync: this,
    duration: _navRestore,
    value: 1,
  );

  Timer? _navIdle;

  static const Duration _navIdleDelay = Duration(milliseconds: 120);
  static const Duration _navRestore = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _pager.addListener(_syncArrows);
    LeagueAliasStore.instance.addListener(_onLeagueAliasChanged);
  }

  void _onLeagueAliasChanged() {
    if (mounted && widget.showLeagueFilter) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncArrows());
  }

  @override
  void dispose() {
    _pager.removeListener(_syncArrows);
    LeagueAliasStore.instance.removeListener(_onLeagueAliasChanged);
    _pager.dispose();
    _navIdle?.cancel();
    _navFadeCtl.dispose();
    super.dispose();
  }

  void _syncArrows() {
    if (!mounted || !_pager.hasClients) return;
    final position = _pager.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    _updateNavFade(position);
    final canPrev = position.pixels > 1;
    final canNext = position.pixels < position.maxScrollExtent - 1;
    if (canPrev == _canPrev && canNext == _canNext) return;
    setState(() {
      _canPrev = canPrev;
      _canNext = canNext;
    });
  }

  void _updateNavFade(ScrollPosition position) {
    final target = _navFadeFor(position);
    if (target < _navFadeCtl.value) _navFadeCtl.value = target;
    _navIdle?.cancel();
    _navIdle = Timer(_navIdleDelay, _restoreNav);
  }

  void _restoreNav() {
    if (!mounted) return;
    _navFadeCtl.animateTo(1, curve: Curves.easeOut);
  }

  double _navFadeFor(ScrollPosition position) {
    final width = _pagerStep > 0 ? _pagerStep : position.viewportDimension;
    if (width <= 0) return 1;
    final fraction = (position.pixels % width) / width;
    final toEdge = fraction <= 0.5 ? fraction : 1 - fraction;
    return (1 - toEdge * 2).clamp(0.0, 1.0);
  }

  void _scrollPage({required bool left}) {
    if (!_pager.hasClients) return;
    final position = _pager.position;
    final step = _pagerStep > 0 ? _pagerStep : position.viewportDimension;
    final target = (position.pixels + (left ? -step : step)).clamp(
      0.0,
      position.maxScrollExtent,
    );
    _pager.animateTo(target, duration: _pageAnim, curve: Curves.easeOutCubic);
  }

  void _selectLeague(int? leagueId) {
    if (leagueId == _leagueId) return;
    setState(() => _leagueId = leagueId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pager.hasClients) _pager.jumpTo(0);
      _syncArrows();
    });
  }

  List<(int, String, int)> _leaguesOf(List<HotMatchEventV2> matches) {
    final names = <int, String>{};
    final counts = <int, int>{};
    var sportId = 0;
    for (final m in matches) {
      counts[m.leagueId] = (counts[m.leagueId] ?? 0) + 1;
      final name = m.leagueName;
      if (name.trim().isNotEmpty) names.putIfAbsent(m.leagueId, () => name);
      if (sportId <= 0) sportId = m.event.sportId;
    }
    if (names.isEmpty) return const [];
    if (sportId <= 0) sportId = ref.read(currentSportIdProvider);
    final labels = leagueChipLabels(
      [
        for (final id in counts.keys)
          if (names[id] case final name?) (id: id, name: name),
      ],
      sportId: sportId,
      table: LeagueAliasStore.instance.table,
    );
    return [
      for (final entry in counts.entries)
        if (labels[entry.key] case final label?)
          (entry.key, label, entry.value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    final itemsToShow = HotMatchContainer.itemsToShowOf(
      context,
      isRightSidebar: widget.isRightSidebar,
    );

    final all = widget.matches ?? [widget.match];
    final leagues = widget.showLeagueFilter
        ? _leaguesOf(all)
        : const <(int, String, int)>[];
    if (_leagueId != null && !leagues.any((league) => league.$1 == _leagueId)) {
      _leagueId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pager.hasClients) _pager.jumpTo(0);
        _syncArrows();
      });
    }
    final leagueId = _leagueId;
    final matchesList = leagueId == null
        ? all
        : [
            for (final m in all)
              if (m.leagueId == leagueId) m,
          ];

    if (matchesList.length != _cardCount) {
      _cardCount = matchesList.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncArrows());
    }
    final canScroll = !widget.compactCards && matchesList.length > itemsToShow;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(8),
        if (widget.showLeagueFilter) _buildLeagueFilter(leagues, all.length),
        Stack(
          children: [
            _buildPager(
              matches: matchesList,
              itemsToShow: itemsToShow,
              isMobile: isMobile,
            ),
            if (canScroll) ...[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _scrollPage(left: true),
                    isEnabled: _canPrev,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _scrollPage(left: false),
                    isEnabled: _canNext,
                  ),
                ),
              ),
            ],
            if (widget.compactCards) ...[
              if (_canPrev)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _buildCompactNavButton(left: true)),
                ),
              if (_canNext)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _buildCompactNavButton(left: false)),
                ),
            ],
          ],
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          if (isMobile && maxHeight.isFinite && maxHeight > 0) {
            return SizedBox(
              height: maxHeight,
              child: SingleChildScrollView(child: content),
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _buildPager({
    required List<HotMatchEventV2> matches,
    required int itemsToShow,
    required bool isMobile,
  }) {
    final sportId = ref.watch(currentSportIdProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.maxWidth;
        final contentWidth = viewport - HotMatchContainer._cardGutter * 2;
        final totalGaps = itemsToShow > 1
            ? (itemsToShow - 1) * HotMatchContainer._horizontalGap
            : 0.0;
        final itemWidth = widget.compactCards
            ? HotMatchContainer.compactCardWidth(viewport)
            : itemsToShow > 0
            ? ((contentWidth - totalGaps) / itemsToShow).floorToDouble()
            : contentWidth;
        final step = itemWidth + HotMatchContainer._horizontalGap;
        _pagerStep = step;

        return AxisLockHorizontalScroll(
          controller: _pager,
          child: SingleChildScrollView(
            controller: _pager,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: HotMatchContainer._cardGutter,
              right: HotMatchContainer._cardGutter,
              bottom: HotMatchContainer._cardGutter,
            ),
            physics: NeverScrollableScrollPhysics(
              parent: SnapScrollPhysics(
                itemWidth: step,
                parent: const ClampingScrollPhysics(),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < matches.length; i++) ...[
                  if (i > 0) const Gap(HotMatchContainer._horizontalGap),
                  SizedBox(
                    width: itemWidth,
                    child: widget.compactCards
                        ? _buildCompactCard(matches[i])
                        : _buildMatchCard(
                            ref: ref,
                            matchItem: matches[i],
                            sportId: sportId,
                            cardWidth: isMobile ? null : itemWidth,
                            reserveTwoLines: itemsToShow > 1,
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeagueFilter(List<(int, String, int)> leagues, int total) {
    final items = <({int? id, String label, bool hasIcon})>[
      (id: null, label: 'Hot ($total)', hasIcon: true),
      for (final (id, name, count) in leagues)
        (id: id, label: '$name ($count)', hasIcon: false),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        bottom: HotMatchContainer.leagueFilterBottomGap,
      ),
      child: SizedBox(
        height: HotMatchContainer.leagueFilterRowHeight(context),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: HotMatchContainer._horizontalPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item.id == _leagueId;
              return VerticalWheelForwarder(
                axisLock: _chipWheelLock,
                child: GameCategoryButton(
                  label: item.label,
                  isSelected: selected,
                  compact: true,
                  backgroundColor: AppColorStyles.backgroundQuaternary,
                  onPressed: () => _selectLeague(item.id),
                  iconBuilder: item.hasIcon && selected
                      ? (bool isSelected) => ImageHelper.load(
                          path: AppIcons.catAllActive,
                          width: GameCategoryButton.compactIconSize,
                          height: GameCategoryButton.compactIconSize,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static const double _compactThreshold = 110;

  Widget _buildMatchCard({
    required WidgetRef ref,
    required HotMatchEventV2 matchItem,
    required int sportId,
    required bool reserveTwoLines,
    double? cardWidth,
  }) {
    final oddsV2 = matchItem.getHandicapMarket(sportId)?.mainLineOdds;
    final compact = cardWidth != null && cardWidth < _compactThreshold;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final trend = isAuthenticated ? matchItem.bettingTrend : null;
    final padding = compact ? 8.0 : 16.0;
    final gap = compact ? 8.0 : 16.0;

    final onMatchSelected = widget.onMatchSelected;
    final VoidCallback? cardOnTap = onMatchSelected != null
        ? () => onMatchSelected(matchItem)
        : widget.onTap;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(cardOnTap),
        child: Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -0.65),
                blurRadius: 0.5,
                spreadRadius: 0.05,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMatchInfoBar(
                match: matchItem,
                compact: compact,
                onBarTap: cardOnTap,
              ),
              _buildInfoDivider(),
              _buildScoreboard(
                match: matchItem,
                compact: compact,
                reserveTwoLines: reserveTwoLines,
                handicapPoints: oddsV2?.pointsValue,
              ),
              _buildBettingOdds(
                match: matchItem,
                sportId: sportId,
                isDesktop: cardWidth != null,
                padding: padding,
                gap: gap,
                trend: trend,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(HotMatchEventV2 match) {
    final onMatchSelected = widget.onMatchSelected;
    final VoidCallback? onTap = onMatchSelected != null
        ? () => onMatchSelected(match)
        : widget.onTap;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        child: Container(
          height: HotMatchContainer.compactCardHeight,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -0.65),
                blurRadius: 0.5,
                spreadRadius: 0.05,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16, child: _buildCompactHeader(match)),
              const Gap(4),
              SizedBox(
                height: 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompactTeamRow(match.homeName, match.homeLogo),
                          _buildCompactTeamRow(match.awayName, match.awayLogo),
                        ],
                      ),
                    ),
                    if (match.isLive) _buildCompactScore(match),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(HotMatchEventV2 match) {
    final dim = AppTextStyles.labelXXSmall(
      color: const Color(0xFFBEBEBE).withValues(alpha: 0.7),
    );
    final divider = Container(width: 1, height: 10, color: AppColors.gray400);
    if (match.isLive) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Trực tiếp',
              style: AppTextStyles.labelXXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          const Gap(4),
          Flexible(
            child: LiveMatchTimeDisplay(
              eventId: match.event.eventId,
              sportId: match.event.sportId,
              initialMinute: match.event.minuteString.isNotEmpty
                  ? match.event.minuteString
                  : null,
              initialPeriod: match.event.gamePartEnum.displayName,
              style: AppTextStyles.labelXXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              separator: const SizedBox(width: 4),
            ),
          ),
        ],
      );
    }
    final start = match.startTime == 0
        ? null
        : match.event.startDateTime.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            start == null
                ? '--/--/----'
                : '${two(start.day)}/${two(start.month)}/${start.year}',
            style: dim,
          ),
          const Gap(4),
          divider,
          const Gap(4),
          Text(
            start == null ? '--:--' : '${two(start.hour)}:${two(start.minute)}',
            style: dim,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTeamRow(String name, String logo) {
    return SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: logo.isEmpty
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: ImageHelper.load(
                        path: logo,
                        width: 24,
                        height: 24,
                        cacheWidth: 48,
                        cacheHeight: 48,
                        fit: BoxFit.contain,
                        errorWidget: const SizedBox.shrink(),
                        maxRetries: 1,
                      ),
                    ),
            ),
            const Gap(8),
            Expanded(
              child: Text(
                name.isEmpty ? '--' : name,
                style: AppTextStyles.paragraphXSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactScore(HotMatchEventV2 match) {
    return Consumer(
      builder: (context, ref, _) {
        final event = match.event;
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(event.eventId)),
        );
        final home =
            score?.$1 ?? (event.score != null ? event.displayHomeScore : null);
        final away =
            score?.$2 ?? (event.score != null ? event.displayAwayScore : null);
        if (home == null || away == null) return const SizedBox.shrink();
        final digits = AppTextStyles.labelSmall(
          color: AppColorStyles.contentPrimary,
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 0, 6),
          child: Container(
            width: 24,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColorStyles.borderPrimary),
            ),
            child: Column(
              children: [
                for (final value in [home, away])
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('$value', style: digits),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchInfoBar({
    required HotMatchEventV2 match,
    bool compact = false,
    VoidCallback? onBarTap,
  }) => RepaintBoundary(
    child: _MatchInfoBar(
      match: match,
      viewCount: match.totalUsers ?? widget.viewCount,
      compact: compact,
      onTap: onBarTap ?? widget.onTap,
    ),
  );

  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: FadeTransition(
        opacity: _navFadeCtl.drive(
          Tween<double>(begin: 0, end: isEnabled ? 1.0 : 0.5),
        ),
        child: InkWell(
          onTap: isEnabled ? SoundTap.wrap(onTap) : null,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: 16,
                color: isEnabled
                    ? AppColorStyles.contentPrimary
                    : AppColorStyles.contentSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavButton({required bool left}) {
    return FadeTransition(
      opacity: _navFadeCtl,
      child: GestureDetector(
        onTap: SoundTap.wrap(() => _scrollPage(left: left)),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            left ? Icons.chevron_left : Icons.chevron_right,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoDivider() => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
      ),
    ),
  );

  Widget _buildScoreboard({
    required HotMatchEventV2 match,
    required bool compact,
    required bool reserveTwoLines,
    double? handicapPoints,
  }) {
    const evenColor = _evenHandicapTeamColor;
    Color homeColor;
    Color awayColor;
    if (handicapPoints == null) {
      homeColor = AppColorStyles.contentPrimary;
      awayColor = AppColorStyles.contentPrimary;
    } else if (handicapPoints == 0) {
      homeColor = evenColor;
      awayColor = evenColor;
    } else if (handicapPoints < 0) {
      homeColor = AppColors.orange400;
      awayColor = AppColorStyles.contentPrimary;
    } else {
      homeColor = AppColorStyles.contentPrimary;
      awayColor = AppColors.orange400;
    }

    final logoSize = compact ? 24.0 : 40.0;
    final stateWidth = compact ? 64.0 : _stateColumnWidth;
    final state = _buildMatchState(match, compact: compact);

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
                      child: _buildTeamLogo(match.homeLogo, size: logoSize),
                    ),
                  ),
                  const Gap(_scoreboardGap),
                  Expanded(
                    child: Center(
                      child: _buildTeamLogo(match.awayLogo, size: logoSize),
                    ),
                  ),
                ],
              ),
              SizedBox(width: stateWidth, child: state),
            ],
          ),
          const Gap(_scoreboardGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTeamName(
                  match.homeName,
                  homeColor,
                  reserveTwoLines: reserveTwoLines,
                ),
              ),
              const Gap(_scoreboardGap),
              Expanded(
                child: _buildTeamName(
                  match.awayName,
                  awayColor,
                  reserveTwoLines: reserveTwoLines,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const double _scoreboardGap = 8;
  static const double _stateColumnWidth = 96;

  Widget _buildTeamName(
    String name,
    Color color, {
    required bool reserveTwoLines,
  }) {
    final text = Text(
      name,
      style: AppTextStyles.labelSmall(color: color),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    if (!reserveTwoLines) return text;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: text,
    );
  }

  static Widget _scaleDownIf(bool compact, Widget child) =>
      compact ? FittedBox(fit: BoxFit.scaleDown, child: child) : child;

  Widget _buildMatchState(HotMatchEventV2 match, {bool compact = false}) {
    if (match.isLive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveMatchTimeDisplay(
            eventId: match.event.eventId,
            sportId: match.event.sportId,
            initialMinute: match.event.minuteString.isNotEmpty
                ? match.event.minuteString
                : null,
            initialPeriod: match.event.gamePartEnum.displayName,
            leadingStyle: compact
                ? AppTextStyles.labelSmall(color: AppColors.green300)
                : AppTextStyles.labelMedium(color: AppColors.green300),
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentSecondary,
            ),
            separator: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
              child: SizedBox(
                width: 2,
                height: 15,
                child: ColoredBox(color: AppColorStyles.contentSecondary),
              ),
            ),
          ),
          _buildLiveScore(match, compact: compact),
        ],
      );
    }
    if (match.startTime == 0) return _buildVersus(compact: compact);
    final (day, time) = _kickoffLabels(match.event.startDateTime);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _scaleDownIf(
          compact,
          Text(
            day,
            style: AppTextStyles.labelMedium(color: Colors.white),
            maxLines: 1,
          ),
        ),
        _scaleDownIf(
          compact,
          Text(
            time,
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentSecondary,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveScore(HotMatchEventV2 match, {bool compact = false}) {
    return Consumer(
      builder: (context, ref, _) {
        final event = match.event;
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(event.eventId)),
        );
        final home =
            score?.$1 ?? (event.score != null ? event.displayHomeScore : null);
        final away =
            score?.$2 ?? (event.score != null ? event.displayAwayScore : null);
        if (home == null || away == null) {
          return _buildVersus(compact: compact);
        }

        final digits = AppTextStyles.labelLarge(
          color: AppColorStyles.contentPrimary,
        );
        Widget box(int value) => Container(
          constraints: const BoxConstraints(minWidth: 24),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text('$value', style: digits),
        );
        final row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            box(home),
            Text('-', style: digits),
            box(away),
          ],
        );
        return compact
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: 80, child: row),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: row,
              );
      },
    );
  }

  Widget _buildVersus({bool compact = false}) => _scaleDownIf(
    compact,
    Text(
      'VS',
      style: AppTextStyles.textStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColorStyles.contentTertiary,
        height: 24 / 16,
      ),
    ),
  );

  static (String, String) _kickoffLabels(DateTime start) {
    final dt = start.toLocal();
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final days =
        (DateTime(
                  dt.year,
                  dt.month,
                  dt.day,
                ).difference(DateTime(now.year, now.month, now.day)).inHours /
                24)
            .round();
    final day = switch (days) {
      0 => 'Hôm nay',
      1 => 'Ngày mai',
      _ => '${two(dt.day)}/${two(dt.month)}',
    };
    return (day, '${two(dt.hour)}:${two(dt.minute)}');
  }

  static const Color _evenHandicapTeamColor = Color(0xFFFFFDE6);

  Widget _buildTeamLogo(String logoUrl, {double size = 32}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFD5DCEB)],
      ),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1),
    ),
    child: ClipOval(
      child: logoUrl.isNotEmpty
          ? ImageHelper.load(
              path: logoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: ImageHelper.load(
                path: AppIcons.iconSoccer,
                width: size,
                height: size,
              ),
            )
          : ImageHelper.load(
              path: AppIcons.iconSoccer,
              width: size,
              height: size,
            ),
    ),
  );

  Widget _buildBettingOdds({
    required HotMatchEventV2 match,
    required int sportId,
    bool isDesktop = false,
    double padding = 16,
    double gap = 16,
    HotBettingTrend? trend,
  }) {
    final handicapMarket = match.getHandicapMarket(sportId);
    final oddsV2 = handicapMarket?.mainLineOdds;
    if (handicapMarket == null || oddsV2 == null) {
      return _buildLockedOdds(padding: padding, gap: gap, trend: trend);
    }

    final pointsValue = oddsV2.pointsValue;
    final String homePointsLabel = PointsFormatter.formatSigned(pointsValue);
    final String awayPointsLabel = PointsFormatter.formatSigned(-pointsValue);

    final leagueData = LeagueModelV2(
      events: const [],
      sportId: match.event.sportId > 0 ? match.event.sportId : sportId,
      leagueId: match.leagueId,
      leagueName: match.leagueName,
      leagueNameEn: match.leagueName,
      leagueLogo: match.leagueLogo,
    );

    BettingPopupDataV2 popupDataOf(OddsType oddsType) => BettingPopupDataV2(
      sportId: sportId,
      oddsData: oddsV2,
      marketData: handicapMarket,
      eventData: match.event,
      oddsType: oddsType,
      leagueData: leagueData,
      oddsFormat: OddsFormatV2.decimal,
    );

    final homeData = popupDataOf(OddsType.home);
    final awayData = popupDataOf(OddsType.away);

    return _buildOddsRow(
      padding: padding,
      gap: gap,
      trend: trend,
      home: BetCardMobileV2(
        label: homePointsLabel,
        selectionId: homeData.getSelectionId(),
        bettingPopupData: homeData,
        isDesktop: isDesktop,
      ),
      away: BetCardMobileV2(
        label: awayPointsLabel,
        selectionId: awayData.getSelectionId(),
        bettingPopupData: awayData,
        isDesktop: isDesktop,
      ),
    );
  }

  Widget _buildOddsRow({
    required double padding,
    required double gap,
    required Widget home,
    required Widget away,
    HotBettingTrend? trend,
  }) {
    Widget withBadge(
      Widget anchor,
      HotBettingTrend badgeTrend, {
      required bool withTeam,
    }) {
      return Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          anchor,
          Positioned(
            top: -_trendBadgeHeight / 2,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.8,
                    ),
                    child: _buildTrendBadge(badgeTrend, withTeam: withTeam),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget cell(Widget child, HotTrendSide side) =>
        trend != null && trend.side == side
        ? withBadge(child, trend, withTeam: false)
        : child;

    Widget row = Row(
      children: [
        Expanded(child: cell(home, HotTrendSide.home)),
        Gap(gap),
        Expanded(child: cell(away, HotTrendSide.away)),
      ],
    );
    if (trend != null && trend.side == null) {
      row = withBadge(row, trend, withTeam: true);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding > 10 ? 16 : 12),
      child: row,
    );
  }

  static const double _trendBadgeHeight = 14;
  static const Color _trendBadgeText = Color(0xFFFDE272);
  static const Color _trendBadgeBorder = Color(0x66FDE272);
  static const Color _trendBadgeBackground = Color(0xFF2E2412);

  Widget _buildTrendBadge(HotBettingTrend trend, {bool withTeam = false}) {
    final percent = trend.percentText;
    return Container(
      height: _trendBadgeHeight,
      padding: const EdgeInsets.only(left: 2, right: 5),
      decoration: BoxDecoration(
        color: _trendBadgeBackground,
        borderRadius: BorderRadius.circular(_trendBadgeHeight / 2),
        border: Border.all(color: _trendBadgeBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageHelper.load(path: AppIcons.iconHot, width: 10, height: 10),
          const Gap(2),
          Flexible(
            child: Text(
              withTeam ? '${trend.team} $percent' : percent,
              style: AppTextStyles.textStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: _trendBadgeText,
                height: 12 / 9,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static const Color _lockIconColor = Colors.white54;

  Widget _buildLockedOdds({
    double padding = 16,
    double gap = 16,
    HotBettingTrend? trend,
  }) => _buildOddsRow(
    padding: padding,
    gap: gap,
    trend: trend,
    home: _buildLockedBetButton(),
    away: _buildLockedBetButton(),
  );

  Widget _buildLockedBetButton() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(6),
    ),
    child: const SizedBox(
      height: 17,
      child: Icon(Icons.lock, size: 16, color: _lockIconColor),
    ),
  );
}

class _MatchInfoBar extends ConsumerStatefulWidget {
  final HotMatchEventV2 match;
  final int? viewCount;
  final bool compact;
  final VoidCallback? onTap;

  const _MatchInfoBar({
    required this.match,
    this.viewCount,
    this.compact = false,
    this.onTap,
  });

  @override
  ConsumerState<_MatchInfoBar> createState() => _MatchInfoBarState();
}

class _MatchInfoBarState extends ConsumerState<_MatchInfoBar> {
  Timer? _timer;
  String _countdownText = '';

  bool get _canShowTracker =>
      widget.match.event.eventStatsId > 0 && ref.read(isAuthenticatedProvider);

  void _showTrackerPopup(BuildContext context) {
    TrackerPopupDialog.show(
      context: context,
      eventStatsId: widget.match.event.eventStatsId,
      homeName: widget.match.event.homeName,
      awayName: widget.match.event.awayName,
    );
  }

  @override
  void initState() {
    super.initState();
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MatchInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.startTime != widget.match.startTime ||
        oldWidget.match.isLive != widget.match.isLive) {
      _timer?.cancel();
      _updateCountdown();
    }
  }

  void _startTimer(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      if (mounted) {
        _updateCountdown();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _updateCountdown() {
    if (widget.match.isLive) {
      setState(() {
        _countdownText = 'Trực tiếp';
      });
      _timer?.cancel();
      return;
    }

    final startTime = widget.match.startTime;
    if (startTime == 0) {
      setState(() {
        _countdownText = '';
      });
      return;
    }

    final now = DateTime.now();
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    final difference = startDateTime.difference(now);

    if (difference.isNegative) {
      setState(() {
        _countdownText = 'Trực tiếp';
      });
      _timer?.cancel();
      return;
    }

    final totalSeconds = difference.inSeconds;

    setState(() {
      if (totalSeconds >= 86400) {
        final days = totalSeconds ~/ 86400;
        _countdownText = '$days ngày';
        _startTimer(const Duration(hours: 1));
      } else if (totalSeconds >= 3600) {
        final hours = totalSeconds ~/ 3600;
        _countdownText = '$hours giờ';
        _startTimer(const Duration(hours: 1));
      } else if (totalSeconds >= 60) {
        final minutes = totalSeconds ~/ 60;
        _countdownText = '$minutes phút';
        _startTimer(const Duration(minutes: 1));
      } else {
        _countdownText = '$totalSeconds giây';
        _startTimer(const Duration(seconds: 1));
      }
    });
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      final millions = count / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}M';
      }
      return '${millions.toStringAsFixed(1).replaceAll('.', ',')}M';
    }
    if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '${thousands.toInt()}K';
      }
      return '${thousands.toStringAsFixed(1).replaceAll('.', ',')}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isAuthenticatedProvider);
    const badgeMaxWidth = 80.0;
    final gap = 4.0;
    final compact = widget.compact;
    final statusGroup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_countdownText.isNotEmpty)
          Flexible(
            child: Container(
              width: badgeMaxWidth,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                color: _countdownText == 'Trực tiếp'
                    ? AppColors.red500
                    : AppColorStyles.borderPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _countdownText,
                style: AppTextStyles.labelXSmall(
                  color: _countdownText == 'Trực tiếp'
                      ? Colors.white
                      : AppColorStyles.contentSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Visibility(
          visible: _countdownText == 'Trực tiếp',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(gap),
              GestureDetector(
                onTap: SoundTap.wrap(widget.onTap),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: ImageHelper.load(
                    path: AppIcons.iconLiveHotMatch,
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(gap),
        GestureDetector(
          onTap: SoundTap.wrap(
            _canShowTracker
                ? SoundTap.wrap(() => _showTrackerPopup(context))
                : null,
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: ImageHelper.load(
              path: AppIcons.iconChart,
              width: 16,
              height: 16,
              color: _canShowTracker
                  ? AppColorStyles.contentSecondary
                  : AppColorStyles.contentSecondary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
    final viewersGroup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_outline,
          size: 16,
          color: AppColorStyles.contentPrimary,
        ),
        const Gap(4),
        Text(
          widget.viewCount != null ? _formatViewCount(widget.viewCount!) : '-',
          style: AppTextStyles.labelSmall(color: AppColorStyles.contentPrimary),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: compact
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: statusGroup,
                  )
                : statusGroup,
          ),
          if (compact)
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: viewersGroup,
              ),
            )
          else
            viewersGroup,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/data/model/special_outright_model.dart';
import 'package:sun_sports/features/sport/presentation/providers/sport_providers.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_collapse_provider.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';

class SportDetailMobileSpecial extends ConsumerWidget {
  final bool isDesktop;

  const SportDetailMobileSpecial({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportId = ref.watch(
      selectedSportV2Provider.select((sport) => sport.id),
    );
    return _SpecialOutrightSliver(sportId: sportId, isDesktop: isDesktop);
  }
}

class _SpecialOutrightSliver extends ConsumerStatefulWidget {
  final int sportId;
  final bool isDesktop;

  const _SpecialOutrightSliver({required this.sportId, this.isDesktop = false});

  @override
  ConsumerState<_SpecialOutrightSliver> createState() =>
      _SpecialOutrightSliverState();
}

class _SpecialOutrightSliverState
    extends ConsumerState<_SpecialOutrightSliver> {
  final Set<int> _collapsedOutrightIds = {};

  final Set<int> _expandedExceptions = {};

  bool _collapseAll = false;

  @override
  void initState() {
    super.initState();
    _collapseAll = ref.read(sportDetailCollapseAllProvider);
    ref.listenManual(sportDetailCollapseAllProvider, (previous, next) {
      if (!mounted || next == _collapseAll) return;
      setState(() {
        _collapseAll = next;
        _collapsedOutrightIds.clear();
        _expandedExceptions.clear();
      });
    });
  }

  bool _isOutrightCollapsed(int outrightId) => _collapseAll
      ? !_expandedExceptions.contains(outrightId)
      : _collapsedOutrightIds.contains(outrightId);

  static const int _eventKeyOffset = -1000000000000;
  int _eventCollapseKey(int eventId) => _eventKeyOffset - eventId;

  List<List<SpecialOutrightModel>> _groupByLeague(
    List<SpecialOutrightModel> outrights,
  ) {
    final byLeague = <int, List<SpecialOutrightModel>>{};
    for (final o in outrights) {
      (byLeague[o.leagueId] ??= <SpecialOutrightModel>[]).add(o);
    }
    return byLeague.values.toList(growable: false);
  }

  void _toggleExpanded(int outrightId) {
    setState(() {
      final target = _collapseAll ? _expandedExceptions : _collapsedOutrightIds;
      if (target.contains(outrightId)) {
        target.remove(outrightId);
      } else {
        target.add(outrightId);
      }
    });
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    SpecialOutrightModel outright,
  ) async {
    final notifier = ref.read(favoriteProvider.notifier);
    final sportId = widget.sportId;
    final wasFavorited = ref
        .read(favoriteProvider)
        .isLeagueFavorite(sportId, outright.leagueId);
    final success = wasFavorited
        ? await notifier.removeFavoriteLeague(
            sportId: sportId,
            leagueId: outright.leagueId,
          )
        : await notifier.addFavoriteLeague(
            sportId: sportId,
            leagueId: outright.leagueId,
          );
    if (success && context.mounted) {
      AppToast.showSuccess(
        context,
        message: wasFavorited
            ? 'Đã xoá giải đấu khỏi Yêu thích'
            : 'Đã thêm giải đấu vào Yêu thích',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialOutrightAsync = ref.watch(
      specialOutrightProvider(widget.sportId),
    );
    final favoriteState = ref.watch(favoriteProvider);

    return specialOutrightAsync.when(
      data: (specialOutrights) {
        if (specialOutrights.isEmpty) {
          return const SliverToBoxAdapter(child: SportEmptyPage());
        }

        final leagueGroups = _groupByLeague(specialOutrights);

        return SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= leagueGroups.length) {
                  return const SizedBox.shrink();
                }
                final group = leagueGroups[index];

                if (group.length > 1) {
                  final leagueId = group.first.leagueId;
                  final leagueKey = -leagueId;
                  return RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _GroupedOutrightLeagueCard(
                        key: ValueKey('league-$leagueId'),
                        groups: group,
                        sportId: widget.sportId,
                        isDesktop: widget.isDesktop,
                        isLeagueExpanded: !_isOutrightCollapsed(leagueKey),
                        onToggleLeague: () => _toggleExpanded(leagueKey),
                        isGroupExpanded: (oid) => !_isOutrightCollapsed(oid),
                        onToggleGroup: _toggleExpanded,
                        isEventExpanded: (eid) =>
                            !_isOutrightCollapsed(_eventCollapseKey(eid)),
                        onToggleEvent: (eid) =>
                            _toggleExpanded(_eventCollapseKey(eid)),
                      ),
                    ),
                  );
                }

                final outright = group.first;
                final isFavorited = favoriteState.isLeagueFavorite(
                  widget.sportId,
                  outright.leagueId,
                );
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SpecialOutrightCard(
                      key: ValueKey(outright.outrightId),
                      specialOutright: outright,
                      sportId: widget.sportId,
                      isDesktop: widget.isDesktop,
                      isExpanded: !_isOutrightCollapsed(outright.outrightId),
                      isFavorited: isFavorited,
                      onToggle: () => _toggleExpanded(outright.outrightId),
                      onFavoriteTap: () => _toggleFavorite(context, outright),
                    ),
                  ),
                );
              },
              childCount: leagueGroups.length,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          ),
        );
      },
      loading: () => SliverFillRemaining(
        hasScrollBody: false,
        child: _buildLoadingState(context),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: _buildErrorState(
          context,
          localizedOrGenericError('SportDetailSpecial', error.toString()),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1B1A19)),
    child: const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(color: Color(0xFFACDC79)),
      ),
    ),
  );

  Widget _buildErrorState(BuildContext context, String error) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1B1A19)),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          error,
          style: AppTextStyles.textStyle(
            fontSize: 14,
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ),
    ),
  );
}

class _SpecialOutrightCard extends ConsumerWidget {
  final SpecialOutrightModel specialOutright;
  final int sportId;
  final bool isDesktop;
  final bool isExpanded;
  final bool isFavorited;
  final VoidCallback onToggle;
  final VoidCallback onFavoriteTap;

  const _SpecialOutrightCard({
    required this.specialOutright,
    required this.sportId,
    required this.isDesktop,
    required this.isExpanded,
    required this.isFavorited,
    required this.onToggle,
    required this.onFavoriteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildOutrightHeader(context),
          if (isExpanded) _buildSelectionsList(context, ref),
        ],
      ),
    );
  }

  Widget _buildOutrightHeader(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onToggle),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.transparent, width: 0.75),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildLeagueIcon(context),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _removeDateBracket(specialOutright.outrightName),
                            style: AppTextStyles.paragraphSmall(
                              color: AppColorStyles
                                  .contentTertiary,
                            ).copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: SoundTap.wrap(onToggle),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: isExpanded ? 0 : 0.5,
                            child: RepaintBoundary(
                              child: ImageHelper.load(
                                path: AppIcons.chevronUp,
                                width: 20,
                                height: 20,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RepaintBoundary(
              child: SizedBox(
                width: double.infinity,
                child: ImageHelper.load(
                  path: AppIcons.hr,
                  width: double.infinity,
                  height: 1,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueIcon(BuildContext context) {
    if (specialOutright.leagueLogo.isNotEmpty) {
      return SizedBox(
        width: isDesktop ? 28 : 26,
        height: isDesktop ? 28 : 26,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: ImageHelper.load(
            path: specialOutright.leagueLogo,
            width: isDesktop ? 24 : 22,
            height: isDesktop ? 24 : 22,
            fit: BoxFit.contain,
            errorWidget: RepaintBoundary(
              child: ImageHelper.load(
                path: SportType.fromId(sportId)?.iconPath ?? '',
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF00004B),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: ImageHelper.load(path: AppIcons.iconSoccer, width: 24, height: 24),
    );
  }

  Widget _buildSelectionsList(BuildContext context, WidgetRef ref) {
    final selections = specialOutright.selections;

    if (selections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: selections.map((selection) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RepaintBoundary(
              child: _buildSelectionRow(context, ref, selection),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectionRow(
    BuildContext context,
    WidgetRef ref,
    SpecialOutrightSelection selection,
  ) {
    return GestureDetector(
      onTap: SoundTap.wrap(
        () => _showOutrightBet(context, ref, specialOutright, selection, sportId: sportId),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: selection.logoUrl.isNotEmpty
                ? ImageHelper.load(
                    path: selection.logoUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    errorWidget: ImageHelper.load(
                      path: AppIcons.iconSoccer,
                      width: 24,
                      height: 24,
                    ),
                  )
                : ImageHelper.load(
                    path: AppIcons.iconSoccer,
                    width: 24,
                    height: 24,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selection.selectionName,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentPrimary,
              ).copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 185,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A19),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selection.odds > 0 ? selection.odds.toStringAsFixed(2) : '-',
              style: AppTextStyles.paragraphSmall(
                color: const Color(0xFFACDC79),
              ).copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

}

class _GroupedOutrightLeagueCard extends StatelessWidget {
  final List<SpecialOutrightModel> groups;
  final int sportId;
  final bool isDesktop;
  final bool isLeagueExpanded;
  final VoidCallback onToggleLeague;
  final bool Function(int outrightId) isGroupExpanded;
  final void Function(int outrightId) onToggleGroup;
  final bool Function(int eventId) isEventExpanded;
  final void Function(int eventId) onToggleEvent;

  const _GroupedOutrightLeagueCard({
    required this.groups,
    required this.sportId,
    required this.isDesktop,
    required this.isLeagueExpanded,
    required this.onToggleLeague,
    required this.isGroupExpanded,
    required this.onToggleGroup,
    required this.isEventExpanded,
    required this.onToggleEvent,
    super.key,
  });

  SpecialOutrightModel get _league => groups.first;

  List<List<SpecialOutrightModel>> _groupByEvent() {
    final byEvent = <int, List<SpecialOutrightModel>>{};
    for (final g in groups) {
      (byEvent[g.eventId] ??= <SpecialOutrightModel>[]).add(g);
    }
    return byEvent.values.toList(growable: false);
  }

  bool get _showEventHeaders {
    final eventIds = groups.map((g) => g.eventId).toSet();
    if (eventIds.length > 1) return true;
    final ev = _league.eventName.trim();
    if (ev.isEmpty) return false;
    return ev.toLowerCase() != _league.leagueName.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildLeagueHeader(context),
          if (isLeagueExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _showEventHeaders
                  ? _buildEventTiers(context)
                  : _buildFlatGroups(context),
            ),
        ],
      ),
    );
  }

  Widget _buildFlatGroups(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _GroupSection(
            key: ValueKey(groups[i].outrightId),
            group: groups[i],
            sportId: sportId,
            isExpanded: isGroupExpanded(groups[i].outrightId),
            onToggle: () => onToggleGroup(groups[i].outrightId),
          ),
        ],
      ],
    );
  }

  Widget _buildEventTiers(BuildContext context) {
    final events = _groupByEvent();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var e = 0; e < events.length; e++) ...[
          if (e > 0) const SizedBox(height: 8),
          _EventSection(
            key: ValueKey('event-${events[e].first.eventId}'),
            lines: events[e],
            sportId: sportId,
            isExpanded: isEventExpanded(events[e].first.eventId),
            onToggle: () => onToggleEvent(events[e].first.eventId),
            isGroupExpanded: isGroupExpanded,
            onToggleGroup: onToggleGroup,
          ),
        ],
      ],
    );
  }

  Widget _buildLeagueHeader(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onToggleLeague),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildLeagueLogo(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _league.leagueName,
                      style: AppTextStyles.paragraphSmall(
                        color: AppColorStyles.contentPrimary,
                      ).copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChevronToggle(
                    isExpanded: isLeagueExpanded,
                    onTap: onToggleLeague,
                  ),
                ],
              ),
            ),
            RepaintBoundary(
              child: SizedBox(
                width: double.infinity,
                child: ImageHelper.load(
                  path: AppIcons.hr,
                  width: double.infinity,
                  height: 1,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueLogo() {
    if (_league.leagueLogo.isNotEmpty) {
      return SizedBox(
        width: isDesktop ? 28 : 26,
        height: isDesktop ? 28 : 26,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: ImageHelper.load(
            path: _league.leagueLogo,
            width: isDesktop ? 24 : 22,
            height: isDesktop ? 24 : 22,
            fit: BoxFit.contain,
            errorWidget: RepaintBoundary(
              child: ImageHelper.load(
                path: SportType.fromId(sportId)?.iconPath ?? '',
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: ImageHelper.load(
        path: SportType.fromId(sportId)?.iconPath ?? '',
        width: isDesktop ? 28 : 26,
        height: isDesktop ? 28 : 26,
        fit: BoxFit.contain,
        color: Colors.white,
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final List<SpecialOutrightModel> lines;
  final int sportId;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool Function(int outrightId) isGroupExpanded;
  final void Function(int outrightId) onToggleGroup;

  const _EventSection({
    required this.lines,
    required this.sportId,
    required this.isExpanded,
    required this.onToggle,
    required this.isGroupExpanded,
    required this.onToggleGroup,
    super.key,
  });

  SpecialOutrightModel get _event => lines.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < lines.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  _GroupSection(
                    key: ValueKey(lines[i].outrightId),
                    group: lines[i],
                    sportId: sportId,
                    isExpanded: isGroupExpanded(lines[i].outrightId),
                    onToggle: () => onToggleGroup(lines[i].outrightId),
                    showDate: false,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = _event.eventName.trim().isNotEmpty
        ? _removeDateBracket(_event.eventName)
        : _removeDateBracket(_event.outrightName);
    final endDateText = _formatOutrightEndDate(_event);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onToggle),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (endDateText.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            endDateText,
                            style: AppTextStyles.paragraphXSmall(
                              color: AppColorStyles.contentTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChevronToggle(isExpanded: isExpanded, onTap: onToggle),
                ],
              ),
            ),
            RepaintBoundary(
              child: SizedBox(
                width: double.infinity,
                child: ImageHelper.load(
                  path: AppIcons.hr,
                  width: double.infinity,
                  height: 1,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final SpecialOutrightModel group;
  final int sportId;
  final bool isExpanded;
  final VoidCallback onToggle;

  final bool showDate;

  const _GroupSection({
    required this.group,
    required this.sportId,
    required this.isExpanded,
    required this.onToggle,
    this.showDate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        if (isExpanded) _buildSelections(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final endDateText = showDate ? _formatOutrightEndDate(group) : '';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onToggle),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _removeDateBracket(group.outrightName),
                      style: AppTextStyles.paragraphSmall(
                        color: AppColorStyles.contentPrimary,
                      ).copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (endDateText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        endDateText,
                        style: AppTextStyles.paragraphXSmall(
                          color: AppColorStyles.contentTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChevronToggle(isExpanded: isExpanded, onTap: onToggle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelections(BuildContext context) {
    final sels = group.selections;
    if (sels.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < sels.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _OutrightSelectionButton(
              group: group,
              selection: sels[i],
              sportId: sportId,
            ),
          ],
        ],
      ),
    );
  }
}

class _OutrightSelectionButton extends ConsumerWidget {
  final SpecialOutrightModel group;
  final SpecialOutrightSelection selection;
  final int sportId;

  const _OutrightSelectionButton({
    required this.group,
    required this.selection,
    required this.sportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: SoundTap.wrap(
        () => _showOutrightBet(context, ref, group, selection, sportId: sportId),
      ),
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: selection.logoUrl.isNotEmpty
                          ? ImageHelper.load(
                              path: selection.logoUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorWidget: ImageHelper.load(
                                path: AppIcons.iconSoccer,
                                width: 24,
                                height: 24,
                              ),
                            )
                          : ImageHelper.load(
                              path: AppIcons.iconSoccer,
                              width: 24,
                              height: 24,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selection.selectionName,
                        style: AppTextStyles.paragraphXSmall(
                          color: AppColorStyles.contentPrimary,
                        ).copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 185,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1A19),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                selection.odds > 0 ? selection.odds.toStringAsFixed(2) : '-',
                style: AppTextStyles.labelSmall(
                  color: const Color(0xFFACDC79),
                ).copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChevronToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ChevronToggle({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0 : 0.5,
              child: RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.chevronUp,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _removeDateBracket(String outrightName) {
  if (outrightName.isEmpty) return outrightName;
  final regex = RegExp(r'^\[\d{2}/\d{2}/\d{2,4}\]\s*');
  return outrightName.replaceFirst(regex, '').trim();
}

String _formatOutrightEndDate(SpecialOutrightModel outright) {
  DateTime? dt;
  if (outright.startTime > 0) {
    dt = DateTime.fromMillisecondsSinceEpoch(outright.startTime);
  } else if (outright.endDate.isNotEmpty) {
    dt = DateTime.tryParse(outright.endDate)?.toLocal();
  }
  if (dt == null) return '';
  return 'Ngày kết thúc: ${DateFormat('dd/MM/yyyy hh:mm a').format(dt)}';
}

void _showOutrightBet(
  BuildContext context,
  WidgetRef ref,
  SpecialOutrightModel outright,
  SpecialOutrightSelection selection, {
  required int sportId,
}) {
  if (!requireLogin(context, ref)) return;
  final bettingData = _createOutrightBettingData(
    outright,
    selection,
    sportId: sportId,
  );
  if (bettingData != null) {
    BetDetailsBottomSheet.show(context, data: bettingData);
  }
}

BettingPopupData? _createOutrightBettingData(
  SpecialOutrightModel outright,
  SpecialOutrightSelection selection, {
  required int sportId,
}) {
  try {
    final leagueData = LeagueData(
      leagueId: outright.leagueId,
      leagueName: outright.leagueName.isNotEmpty
          ? outright.leagueName
          : _extractLeagueName(outright.outrightName),
      leagueLogo: outright.leagueLogo,
    );

    int startTime = outright.startTime;
    if (startTime == 0 && outright.endDate.isNotEmpty) {
      try {
        startTime = DateTime.parse(outright.endDate).millisecondsSinceEpoch;
      } catch (_) {}
    }

    final matchName = _removeDateBracket(outright.eventName);
    final isPerMatch =
        matchName.trim().isNotEmpty &&
        matchName.trim().toLowerCase() !=
            outright.leagueName.trim().toLowerCase();

    final eventData = LeagueEventData(
      eventId: outright.eventId,
      eventName: _removeDateBracket(outright.outrightName),
      homeName: selection.selectionName,
      awayName: '',
      startTime: startTime,
      isParlay: true,
    );

    final marketData = LeagueMarketData(
      marketId: 0,
      marketName: _extractMarketName(outright.outrightName),
      isParlay: true,
      odds: [],
    );

    final oddsData = LeagueOddsData(
      points: selection.selectionCode,
      selectionHomeId: selection.selectionId,
      offerId: selection.offerId,
      oddsHome: OddsValue(decimal: selection.odds),
      oddsAway: const OddsValue(),
      oddsDraw: const OddsValue(),
    );

    return BettingPopupData(
      sportId: sportId,
      oddsData: oddsData,
      marketData: marketData,
      eventData: eventData,
      oddsType: OddsType.home,
      leagueData: leagueData,
      oddsStyle: OddsStyle.decimal,
      outrightMatchName: isPerMatch ? matchName : '',
    );
  } catch (e, st) {
    AppLoggers.ui.e(
      'Error creating outright BettingPopupData',
      error: e,
      stackTrace: st,
    );
    return null;
  }
}

String _extractLeagueName(String outrightName) {
  final cleanName = _removeDateBracket(outrightName);
  final parts = cleanName.split(' - ');
  if (parts.isNotEmpty) {
    final leaguePart = parts[0].replaceAll(RegExp(r'\d{4}/\d{4}'), '').trim();
    return leaguePart.isNotEmpty ? leaguePart : cleanName;
  }
  return cleanName;
}

String _extractMarketName(String outrightName) {
  final cleanName = _removeDateBracket(outrightName);
  final parts = cleanName.split(' - ');
  if (parts.length > 1) {
    return parts.last;
  }
  return cleanName;
}

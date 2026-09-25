import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' show V2TimeRange;
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/websocket/socket_sub_mode.dart';
import 'package:sun_sports/core/services/websocket/visible_league_subscription_manager.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_flat_item_v2.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_header_widget_v2.dart';
import 'package:sun_sports/shared/widgets/sport/league/progressive_reveal.dart';
import 'package:sun_sports/shared/widgets/sport/league/row_widget_memo.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_v2.dart';
import 'package:sun_sports/core/perf/perf.dart';

const Set<int> kLeagueSubAllTimeRanges = {
  V2TimeRange.live,
  V2TimeRange.today,
  V2TimeRange.early,
};

class LeagueEventsSliverV2 extends ConsumerStatefulWidget {
  final List<LeagueModelV2> leagues;
  final bool isDesktop;

  final bool includeEmptyLeagues;

  final bool showBackToTop;

  final bool showLeagueFavorite;

  final StateProvider<bool>? collapseAllProvider;

  final bool headerFrameOnly;

  final bool enableVisibleLeagueSub;

  final Set<int>? subTimeRanges;

  const LeagueEventsSliverV2({
    super.key,
    required this.leagues,
    this.isDesktop = false,
    this.includeEmptyLeagues = false,
    this.showBackToTop = true,
    this.showLeagueFavorite = true,
    this.collapseAllProvider,
    this.headerFrameOnly = false,
    this.enableVisibleLeagueSub = false,
    this.subTimeRanges,
  }) : assert(
          !enableVisibleLeagueSub || subTimeRanges != null,
          'Khi enableVisibleLeagueSub=true phải truyền subTimeRanges khác null '
          '(tập tr cố định per-screen; all-tr dùng kLeagueSubAllTimeRanges).',
        );

  @override
  ConsumerState<LeagueEventsSliverV2> createState() =>
      _LeagueEventsSliverV2State();
}

class _LeagueEventsSliverV2State extends ConsumerState<LeagueEventsSliverV2> {
  final Set<int> _collapsedLeagueIds = {};

  final Set<int> _expandedExceptions = {};

  bool _collapseAll = false;

  final WidgetMemo<String> _itemMemo = WidgetMemo<String>();

  final ProgressiveReveal _reveal = ProgressiveReveal();

  bool _revealScheduled = false;

  @override
  void initState() {
    super.initState();

    assert(
      !widget.enableVisibleLeagueSub || widget.subTimeRanges!.isNotEmpty,
      'subTimeRanges không được rỗng khi enableVisibleLeagueSub=true.',
    );

    final provider = widget.collapseAllProvider;
    if (provider != null) {
      _collapseAll = ref.read(provider);
      ref.listenManual(provider, (previous, next) {
        if (!mounted || next == _collapseAll) return;
        setState(() {
          _collapseAll = next;
          _collapsedLeagueIds.clear();
          _expandedExceptions.clear();
        });
      });
    }
  }

  bool _isLeagueCollapsed(int leagueId) => _collapseAll
      ? !_expandedExceptions.contains(leagueId)
      : _collapsedLeagueIds.contains(leagueId);

  void _toggleLeague(int leagueId) {
    setState(() {
      final target = _collapseAll ? _expandedExceptions : _collapsedLeagueIds;
      if (target.contains(leagueId)) {
        target.remove(leagueId);
      } else {
        target.add(leagueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<int> collapsedIds = _collapseAll
        ? widget.leagues
              .map((l) => l.leagueId)
              .where((id) => !_expandedExceptions.contains(id))
              .toSet()
        : _collapsedLeagueIds;

    final flatItems = buildFlatItemsV2(
      widget.leagues,
      collapsedLeagueIds: collapsedIds,
      includeEmptyLeagues: widget.includeEmptyLeagues,
    );
    _reveal.onTotalChanged(flatItems.length);

    if (flatItems.isEmpty) {
      return const SliverToBoxAdapter(
        child: SportEmptyPage(),
      );
    }

    final keyToIndex = <String, int>{};
    for (var i = 0; i < flatItems.length; i++) {
      final k = flatItems[i].key;
      assert(
        !keyToIndex.containsKey(k),
        'Duplicate FlatItemV2 key: $k',
      );
      keyToIndex[k] = i;
    }
    _itemMemo.retainOnly(keyToIndex.keys);

    if (!_reveal.isComplete(flatItems.length)) _scheduleRevealStep();

    return SliverMainAxisGroup(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= flatItems.length) {
                return const SizedBox.shrink();
              }
              final item = flatItems[index];
              return _buildItem(item);
            },
            childCount: _reveal.visibleCount(flatItems.length),
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            findChildIndexCallback: (Key key) {
              if (key is ValueKey<String>) return keyToIndex[key.value];
              return null;
            },
          ),
        ),
        if (widget.showBackToTop)
          const SliverToBoxAdapter(child: BackToTopOverlay()),
      ],
    );
  }

  void _scheduleRevealStep() {
    if (_revealScheduled) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted) return;
      setState(() => _reveal.advance());
    });
  }

  Widget _buildItem(FlatItemV2 item) {
    switch (item.type) {
      case FlatItemTypeV2.leagueHeader:
        final isExpanded = !_isLeagueCollapsed(item.league.leagueId);
        final topSpacing = item.leagueIndex > 0 ? 8.0 : 0.0;
        return Padding(
          padding: EdgeInsets.only(top: topSpacing),
          child: SizedBox(
            height: widget.headerFrameOnly
                ? 1.0
                : item.getHeight(isDesktop: widget.isDesktop),
            child: _itemMemo.reuse(
              item.key,
              (
                leagueHeaderMetaOf(item.league),
                isExpanded,
                widget.isDesktop,
                widget.showLeagueFavorite,
                widget.headerFrameOnly,
              ),
              () => LeagueHeaderWidgetV2(
                key: ValueKey(item.key),
                league: item.league,
                isDesktop: widget.isDesktop,
                isExpanded: isExpanded,
                onToggleExpand: () => _toggleLeague(item.league.leagueId),
                showFavorite: widget.showLeagueFavorite,
                frameOnly: widget.headerFrameOnly,
              ),
            ),
          ),
        );

      case FlatItemTypeV2.eventRow:
        final event = item.event!;
        Widget matchRow = SizedBox(
          height: item.getHeight(isDesktop: widget.isDesktop),
          child: _itemMemo.reuse(
            item.key,
            (event, leagueRowMetaOf(item.league), widget.isDesktop),
            () => MatchRowV2(
              key: ValueKey(item.key),
              event: event,
              league: item.league,
              isDesktop: widget.isDesktop,
            ),
          ),
        );

        if (widget.enableVisibleLeagueSub && SocketSubMode.current.isLeague) {
          matchRow = LeagueVisibilityReporter(
            leagueId: item.league.leagueId,
            timeRanges: widget.subTimeRanges!,
            child: matchRow,
          );
        }

        if (item.isLastEventInLeague) {
          final radius = Radius.circular(widget.isDesktop ? 12 : 10);
          return ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: radius,
              bottomRight: radius,
            ),
            child: matchRow,
          );
        }

        return matchRow;
    }
  }
}

class LeagueVisibilityReporter extends StatefulWidget {
  final int leagueId;

  final Set<int> timeRanges;
  final Widget child;

  const LeagueVisibilityReporter({
    required this.leagueId,
    required this.timeRanges,
    required this.child,
    super.key,
  });

  @override
  State<LeagueVisibilityReporter> createState() =>
      _LeagueVisibilityReporterState();
}

class _LeagueVisibilityReporterState extends State<LeagueVisibilityReporter> {
  @override
  void initState() {
    super.initState();
    if (PerfFlags.trace) PerfCounters.hit('rep.init');
    final manager = VisibleLeagueSubscriptionManager.instance;
    for (final tr in widget.timeRanges) {
      manager?.retain(widget.leagueId, timeRange: tr);
    }
  }

  @override
  void didUpdateWidget(covariant LeagueVisibilityReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final manager = VisibleLeagueSubscriptionManager.instance;
    if (oldWidget.leagueId != widget.leagueId) {
      for (final tr in oldWidget.timeRanges) {
        manager?.release(oldWidget.leagueId, timeRange: tr);
      }
      for (final tr in widget.timeRanges) {
        manager?.retain(widget.leagueId, timeRange: tr);
      }
      return;
    }
    final sameSet = oldWidget.timeRanges.length == widget.timeRanges.length &&
        oldWidget.timeRanges.containsAll(widget.timeRanges);
    if (!sameSet) {
      for (final tr in oldWidget.timeRanges.difference(widget.timeRanges)) {
        manager?.release(oldWidget.leagueId, timeRange: tr);
      }
      for (final tr in widget.timeRanges.difference(oldWidget.timeRanges)) {
        manager?.retain(widget.leagueId, timeRange: tr);
      }
    }
  }

  @override
  void dispose() {
    if (PerfFlags.trace) PerfCounters.hit('rep.dispose');
    final manager = VisibleLeagueSubscriptionManager.instance;
    for (final tr in widget.timeRanges) {
      manager?.release(widget.leagueId, timeRange: tr);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

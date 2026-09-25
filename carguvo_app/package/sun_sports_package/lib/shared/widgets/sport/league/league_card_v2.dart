import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/core/services/websocket/socket_sub_mode.dart';
import 'package:sun_sports/core/services/websocket/visible_league_subscription_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/sport/league/row_widget_memo.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_v2.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class LeagueCardV2 extends ConsumerStatefulWidget {
  final LeagueModelV2 league;

  final bool isDesktop;

  final int? maxVisibleMatches;

  final bool enableProgressiveRendering;

  final bool initiallyExpanded;

  final ValueChanged<bool>? onExpandChanged;

  final StateProvider<bool>? collapseAllProvider;

  final bool enableVisibleLeagueSub;

  final Set<int>? subTimeRanges;

  const LeagueCardV2({
    super.key,
    required this.league,
    this.isDesktop = false,
    this.maxVisibleMatches,
    this.enableProgressiveRendering = true,
    this.initiallyExpanded = true,
    this.onExpandChanged,
    this.collapseAllProvider,
    this.enableVisibleLeagueSub = false,
    this.subTimeRanges,
  }) : assert(
          !enableVisibleLeagueSub || subTimeRanges != null,
          'subTimeRanges BẮT BUỘC khác null khi enableVisibleLeagueSub=true '
          '(per-screen tr, không đọc global).',
        );

  @override
  ConsumerState<LeagueCardV2> createState() => _LeagueCardV2State();
}

class _LeagueCardV2State extends ConsumerState<LeagueCardV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _rotationAnimation;

  bool _isExpanded = true;
  int _renderedCount = 0;

  int? _retainedLeagueId;

  int _progressiveRenderingToken = 0;

  final WidgetMemo<int> _rowMemo = WidgetMemo<int>();

  static const int _batchSize = 10;
  static const Duration _batchDelay = Duration(milliseconds: 50);

  static const double _matchRowHeight = 160.0;
  static const double _matchRowHeightDesktop = 200.0;
  static const double _matchRowHeightNonSoccer = 270.0;
  static const double _matchRowHeightNonSoccerDesktop = 250.0;

  @override
  void initState() {
    super.initState();
    assert(
      !widget.enableVisibleLeagueSub || widget.subTimeRanges!.isNotEmpty,
      'subTimeRanges không được rỗng khi enableVisibleLeagueSub=true.',
    );
    _isExpanded = widget.initiallyExpanded;

    final collapseProvider = widget.collapseAllProvider;
    if (collapseProvider != null) {
      _isExpanded = !ref.read(collapseProvider);
    }

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 0.0 : 1.0,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    if (collapseProvider != null) {
      ref.listenManual(collapseProvider, (previous, next) {
        if (!mounted) return;
        _setExpanded(!next);
      });
    }

    if (widget.enableProgressiveRendering && widget.maxVisibleMatches == null) {
      _startProgressiveRendering();
    } else {
      _renderedCount = _effectiveMatchCount;
    }

    if (_isExpanded) _retainLeagueSub();
  }

  bool get _leagueSubEnabled =>
      widget.enableVisibleLeagueSub && SocketSubMode.current.isLeague;

  void _retainLeagueSub() {
    if (!_leagueSubEnabled || _retainedLeagueId != null) return;
    final id = widget.league.leagueId;
    final manager = VisibleLeagueSubscriptionManager.instance;
    for (final tr in widget.subTimeRanges!) {
      manager?.retain(id, timeRange: tr);
    }
    _retainedLeagueId = id;
  }

  void _releaseLeagueSub() {
    final id = _retainedLeagueId;
    if (id == null) return;
    final manager = VisibleLeagueSubscriptionManager.instance;
    for (final tr in widget.subTimeRanges!) {
      manager?.release(id, timeRange: tr);
    }
    _retainedLeagueId = null;
  }

  int get _effectiveMatchCount {
    final total = widget.league.events.length;
    return widget.maxVisibleMatches?.clamp(0, total) ?? total;
  }

  double get _itemHeight {
    final isSoccer = widget.league.sportId == 1 || widget.league.sportId == 0;
    if (isSoccer) {
      return widget.isDesktop ? _matchRowHeightDesktop : _matchRowHeight;
    }
    return widget.isDesktop
        ? _matchRowHeightNonSoccerDesktop
        : _matchRowHeightNonSoccer;
  }

  void _startProgressiveRendering() {
    _progressiveRenderingToken++;
    final currentToken = _progressiveRenderingToken;

    _renderedCount = _batchSize.clamp(0, _effectiveMatchCount);

    Future.doWhile(() async {
      if (!mounted || currentToken != _progressiveRenderingToken) return false;
      if (_renderedCount >= _effectiveMatchCount) return false;

      await Future<void>.delayed(_batchDelay);

      if (!mounted || currentToken != _progressiveRenderingToken) return false;

      setState(() {
        _renderedCount = (_renderedCount + _batchSize).clamp(
          0,
          _effectiveMatchCount,
        );
      });

      return _renderedCount < _effectiveMatchCount;
    });
  }

  void _toggleExpand() => _setExpanded(!_isExpanded);

  void _setExpanded(bool expanded) {
    if (expanded == _isExpanded) return;

    setState(() {
      _isExpanded = expanded;
    });

    if (_isExpanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }

    if (_isExpanded) {
      _retainLeagueSub();
    } else {
      _releaseLeagueSub();
    }

    widget.onExpandChanged?.call(_isExpanded);
  }

  @override
  void didUpdateWidget(LeagueCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.league.leagueId != widget.league.leagueId) {
      _renderedCount = 0;
      if (widget.enableProgressiveRendering &&
          widget.maxVisibleMatches == null) {
        _startProgressiveRendering();
      } else {
        _renderedCount = _effectiveMatchCount;
      }
      if (_leagueSubEnabled) {
        _releaseLeagueSub();
        if (_isExpanded) _retainLeagueSub();
      }
    }
  }

  @override
  void dispose() {
    _releaseLeagueSub();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.league.events;
    if (events.isEmpty) return const SizedBox.shrink();
    final safeRenderedCount = _renderedCount.clamp(0, events.length);
    _rowMemo.retainOnly(events.map((e) => e.eventId));

    return Container(
      margin: EdgeInsets.only(bottom: widget.isDesktop ? 8 : 4),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeagueHeaderV2(
              league: widget.league,
              isExpanded: _isExpanded,
              isDesktop: widget.isDesktop,
              rotationAnimation: _rotationAnimation,
              onTap: _toggleExpand,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? SizedBox(
                      height: safeRenderedCount * _itemHeight,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: safeRenderedCount,
                        itemExtent: _itemHeight,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        cacheExtent: 500,
                        itemBuilder: (context, i) {
                          final event = events[i];
                          return RepaintBoundary(
                            child: _rowMemo.reuse(
                              event.eventId,
                              (
                                event,
                                leagueRowMetaOf(widget.league),
                                widget.isDesktop,
                              ),
                              () => MatchRowV2(
                                key: ValueKey(event.eventId),
                                event: event,
                                league: widget.league,
                                isDesktop: widget.isDesktop,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueHeaderV2 extends StatelessWidget {
  final LeagueModelV2 league;
  final bool isExpanded;
  final bool isDesktop;
  final Animation<double> rotationAnimation;
  final VoidCallback onTap;

  const _LeagueHeaderV2({
    required this.league,
    required this.isExpanded,
    required this.isDesktop,
    required this.rotationAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: isDesktop ? 48 : 40,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: 6,
        ),
        child: Row(
          children: [
          Expanded(
            child: Row(
              children: [
                if (league.leagueLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: Container(
                      color: Colors.white,
                      width: isDesktop ? 26 : 24,
                      height: isDesktop ? 26 : 24,
                      child: ImageHelper.load(
                        path: league.leagueLogo,
                        width: isDesktop ? 26 : 24,
                        height: isDesktop ? 26 : 24,
                        fit: BoxFit.contain,
                        errorWidget: SizedBox(width: isDesktop ? 26 : 24),
                      ),
                    ),
                  )
                else
                  ImageHelper.load(
                    path: SportType.fromId(league.sportId)?.iconPath ?? '',
                    width: isDesktop ? 26 : 24,
                    height: isDesktop ? 26 : 24,
                    fit: BoxFit.contain,
                    color: const Color(0xB3FFFCDB),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    league.displayName,
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColorStyles.contentSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${league.events.length})',
                  style: AppTextStyles.textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
            RotationTransition(
              turns: rotationAnimation,
              child: RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.chevronUp,
                  width: isDesktop ? 24 : 20,
                  height: isDesktop ? 24 : 20,
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

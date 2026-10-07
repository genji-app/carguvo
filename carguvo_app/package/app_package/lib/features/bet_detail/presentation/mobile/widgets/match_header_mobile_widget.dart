import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/services/config/sb_config.dart';
import 'package:app_package/core/services/models/league_model.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/shared/widgets/stats/stats_dialog.dart';
import 'package:app_package/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:app_package/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:app_package/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:app_package/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:app_package/shared/widgets/livestream/livestream_widget.dart';
import 'package:app_package/shared/widgets/tracker/tracker_widget.dart';
import 'package:app_package/shared/widgets/sport/match/match_notice_rive_animation.dart';
import 'package:app_package/shared/widgets/sport/match/match_notice_suspend_guard.dart';
import 'package:app_package/core/services/models/api_v2/event_model_v2_extensions.dart'
    show ftHandicapMarketIds;
import 'package:betting_domain/betting_domain.dart' show HeadToHead;
import 'package:app_package/features/bet_detail/data/head_to_head_repository.dart';
import 'package:app_package/features/bet_detail/presentation/mobile/widgets/bd_h2h_panel_mobile.dart';
import 'package:app_package/features/bet_detail/presentation/mobile/widgets/bd_match_card_mobile.dart';
import 'bd_score_flip_mobile.dart';
import 'package:app_package/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:app_package/providers/auth_provider.dart';
import 'package:app_package/shared/widgets/livestream/pip_manager.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';

class MatchHeaderMobileWidget extends ConsumerStatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  final bool eventEnded;

  final int sportId;

  final GlobalKey? livestreamKey;
  final void Function(MatchTab)? onTabChanged;

  final Widget Function(BuildContext context, Widget? pinnedHead, Widget? body)?
  layoutBuilder;

  const MatchHeaderMobileWidget({
    super.key,
    required this.eventData,
    this.eventEnded = false,
    this.leagueData,
    required this.sportId,
    this.livestreamKey,
    this.onTabChanged,
    this.layoutBuilder,
  });

  @override
  ConsumerState<MatchHeaderMobileWidget> createState() =>
      _MatchHeaderMobileWidgetState();
}

enum MatchTab { statistics, scoreboard, follow, live, h2h }

abstract class MatchHeaderTabController {
  void setTab(MatchTab tab);
}

class _MatchHeaderMobileWidgetState
    extends ConsumerState<MatchHeaderMobileWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin
    implements MatchHeaderTabController {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late MatchTab _selectedTab;

  void setTab(MatchTab tab) {
    if (_selectedTab != tab) {
      if (tab != MatchTab.live) {
        _pauseVideoIfPlaying();
      } else {
        _playVideoIfPaused();
      }
      setState(() {
        _selectedTab = tab;
      });
      widget.onTabChanged?.call(tab);
    }
  }

  void _pauseVideoIfPlaying() {}

  void _playVideoIfPaused() {
    if (!mounted) return;
    _checkLivestreamUrl(reloadVideo: true);
  }

  String? _livestreamUrl;
  bool _isCheckingLivestream = false;

  MatchNoticeType? _homeNotice;
  MatchNoticeType? _awayNotice;

  int _homeNoticeSeq = 0;

  BdScoreFlipEvent? _homeFlip;
  BdScoreFlipEvent? _awayFlip;
  int _flipSeq = 0;
  int _awayNoticeSeq = 0;

  Timer? _homeNoticeTimer;
  Timer? _awayNoticeTimer;

  static const Duration _noticeFallbackDuration = Duration(seconds: 6);

  int? _noticeSettledEventId;

  late final MatchNoticeSuspendGuard _noticeSuspendGuard;

  void _detectNotices(LeagueEventData prev, LeagueEventData next) {
    final suppress = _noticeSuspendGuard.shouldSuppressTick();
    if (!next.isLive) return;
    if (prev.eventId != next.eventId) {
      _noticeSettledEventId = null;
      _homeFlip = null;
      _awayFlip = null;
      return;
    }
    if (_noticeSettledEventId != next.eventId) {
      _noticeSettledEventId = next.eventId;
      return;
    }
    if (prev.gamePart == 0 && prev.gameTime == 0) return;
    if (suppress) return;
    final home = _diffNotice(prev, next, home: true);
    if (home != null) _triggerNotice(home: true, type: home);
    final away = _diffNotice(prev, next, home: false);
    if (away != null) _triggerNotice(home: false, type: away);
    _detectScoreFlips(prev, next);
  }

  void _detectScoreFlips(LeagueEventData prev, LeagueEventData next) {
    final pen = next.isPenaltyShootout;
    if (pen != prev.isPenaltyShootout) return;
    final (ph, pa) = pen
        ? (prev.homeScorePen, prev.awayScorePen)
        : (prev.displayHomeScore, prev.displayAwayScore);
    final (nh, na) = pen
        ? (next.homeScorePen, next.awayScorePen)
        : (next.displayHomeScore, next.displayAwayScore);
    BdScoreFlipEvent? flip(int from, int to) {
      if ((to - from).abs() != 1) return null;
      return BdScoreFlipEvent(from: from, increase: to > from, seq: ++_flipSeq);
    }
    final home = flip(ph, nh);
    final away = flip(pa, na);
    if (home == null && away == null) return;
    if (home != null) _homeFlip = home;
    if (away != null) _awayFlip = away;
    if (pen) return;
    if (home != null && !home.increase) {
      _triggerNotice(home: true, type: MatchNoticeType.huyBan);
    }
    if (away != null && !away.increase) {
      _triggerNotice(home: false, type: MatchNoticeType.huyBan);
    }
  }

  MatchNoticeType? _diffNotice(
    LeagueEventData prev,
    LeagueEventData next, {
    required bool home,
  }) {
    final goal = home
        ? next.homeScore > prev.homeScore
        : next.awayScore > prev.awayScore;
    if (goal) return MatchNoticeType.ghiBan;
    final red = home
        ? next.redCardsHome > prev.redCardsHome
        : next.redCardsAway > prev.redCardsAway;
    if (red) return MatchNoticeType.theDo;
    final yellow = home
        ? next.yellowCardsHome > prev.yellowCardsHome
        : next.yellowCardsAway > prev.yellowCardsAway;
    if (yellow) return MatchNoticeType.theVang;
    final corner = home
        ? next.cornersHome > prev.cornersHome
        : next.cornersAway > prev.cornersAway;
    if (corner) return MatchNoticeType.phatGoc;
    return null;
  }

  void _triggerNotice({required bool home, required MatchNoticeType type}) {
    (home ? _homeNoticeTimer : _awayNoticeTimer)?.cancel();
    setState(() {
      if (home) {
        _homeNotice = type;
        _homeNoticeSeq++;
      } else {
        _awayNotice = type;
        _awayNoticeSeq++;
      }
    });
    final timer = Timer(_noticeFallbackDuration, () => _clearNotice(home: home));
    if (home) {
      _homeNoticeTimer = timer;
    } else {
      _awayNoticeTimer = timer;
    }
  }

  void _clearAllNotices() {
    _homeNoticeTimer?.cancel();
    _awayNoticeTimer?.cancel();
    if (!mounted || (_homeNotice == null && _awayNotice == null)) return;
    setState(() {
      _homeNotice = null;
      _awayNotice = null;
    });
  }

  void _clearNotice({required bool home}) {
    (home ? _homeNoticeTimer : _awayNoticeTimer)?.cancel();
    if (!mounted) return;
    setState(() {
      if (home) {
        _homeNotice = null;
      } else {
        _awayNotice = null;
      }
    });
  }

  bool get hasLivestreamUrl {
    if (!widget.eventData.isLive || !widget.eventData.isLivestream) {
      return false;
    }
    return _livestreamUrl != null && _livestreamUrl!.isNotEmpty;
  }

  bool get _isLoggedIn => ref.read(isAuthenticatedProvider);

  bool get _canUseTracker => _isLoggedIn;

  bool get _canShowStats => widget.eventData.eventStatsId > 0 && _isLoggedIn;

  bool get _useCard => !const {2, 4, 5, 7}.contains(widget.sportId);

  bool _liveOn = true;

  void _toggleLive() => setState(() => _liveOn = !_liveOn);

  HeadToHead? _h2h;
  int _h2hFetchedFor = 0;
  int _h2hAttempts = 0;

  static const int _kH2hMaxAttempts = 3;

  void _maybeFetchH2h() {
    if (!_useCard) return;
    final statsId = widget.eventData.eventStatsId;
    if (statsId <= 0 || _h2hFetchedFor == statsId) return;
    _h2hFetchedFor = statsId;
    final hit = HeadToHeadRepository.cached(statsId);
    if (hit != null) {
      _h2h = hit;
      return;
    }
    _h2hAttempts++;
    HeadToHeadRepository.fetch(statsId).then((data) {
      if (!mounted || _h2hFetchedFor != statsId) return;
      if (data == null &&
          !HeadToHeadRepository.hasResult(statsId) &&
          _h2hAttempts < _kH2hMaxAttempts) {
        _h2hFetchedFor = 0;
        return;
      }
      setState(() => _h2h = data);
      _resolveTab();
    });
  }

  MatchTab get _effectiveTab {
    if (!_useCard) return _selectedTab;
    final tabs = _cardTabs;
    if (tabs.isEmpty) return _selectedTab;
    return tabs.contains(_selectedTab) ? _selectedTab : tabs.first;
  }

  void _resolveTab() {
    if (!_useCard) return;
    final tabs = _cardTabs;
    if (tabs.isEmpty || tabs.contains(_selectedTab)) return;
    setState(() => _selectedTab = tabs.first);
    widget.onTabChanged?.call(_selectedTab);
  }

  List<MatchTab> get _cardTabs => [
    if (widget.eventData.eventStatsId > 0) MatchTab.follow,
    if (_h2h != null) MatchTab.h2h,
    if (hasLivestreamUrl) MatchTab.live,
  ];

  void _showStatsDialog(BuildContext context) {
    if (!_canShowStats) return;

    StatsDialog.showForMatch(
      context: context,
      eventStatsId: widget.eventData.eventStatsId,
      homeName: widget.eventData.homeName,
      awayName: widget.eventData.awayName,
      config: StatsDialogConfig.mobile,
      width: MediaQuery.of(context).size.width,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedTab = MatchTab.scoreboard;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabChanged?.call(_selectedTab);
    });

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.eventData.isLive) {
      _pulseController.repeat(reverse: true);
    }

    MatchNoticeRiveAnimation.preload();

    _noticeSuspendGuard = MatchNoticeSuspendGuard(onSuspend: _clearAllNotices);

    debugPrint(
      '[LS-INIT-M] eventId=${widget.eventData.eventId} '
      'isLive=${widget.eventData.isLive} '
      'isLivestream=${widget.eventData.isLivestream}'
      'link=$_livestreamUrl',
    );

    if (widget.eventData.isLive && widget.eventData.isLivestream) {
      debugPrint('_checkLivestreamUrl → gọi _checkLivestreamUrl(isInitial: true)');
      _checkLivestreamUrl(isInitial: true);
    } else {
      debugPrint(
        '[LS-INIT-M] → BỎ QUA _checkLivestreamUrl (không live hoặc không livestream)',
      );
    }
  }

  Future<void> _checkLivestreamUrl({
    bool isInitial = false,
    bool reloadVideo = false,
  }) async {
    if (_isCheckingLivestream && !reloadVideo) return;

    final previousUrl = _livestreamUrl;

    setState(() {
      _isCheckingLivestream = true;
    });

    final eventId = widget.eventData.eventId.toString();
    debugPrint('[LS-FLOW-M] 1. getLiveLink START eventId=$eventId');

    try {
      final httpManager = SbHttpManager.instance;
      final brand = SbConfig.brandId;

      final response = await httpManager.getLiveLink(eventId, brand);

      debugPrint(
        '[LS-FLOW-M] 2. getLiveLink OK eventId=$eventId url=${response.url}',
      );

      if (mounted) {
        setState(() {
          _livestreamUrl = response.url;
          debugPrint('link streaming: ${response.url}');
          _isCheckingLivestream = false;

          if (isInitial &&
              hasLivestreamUrl &&
              _selectedTab == MatchTab.scoreboard) {
            _selectedTab = MatchTab.live;
            widget.onTabChanged?.call(_selectedTab);
          }
        });

        if (reloadVideo && response.url!.isNotEmpty==true) {
          PipManager()
            ..setOnVideoPage(true)
            ..loadUrl(
              response.url.toString(),
              context,
              eventId: widget.eventData.eventId,
            );
        }
      }
    } catch (e) {
      debugPrint('[LS-FLOW-M] X. getLiveLink ERROR eventId=$eventId error=$e');
      if (mounted) {
        if (reloadVideo && previousUrl != null && previousUrl.isNotEmpty) {
          setState(() {
            _isCheckingLivestream = false;
          });
          PipManager()
            ..setOnVideoPage(true)
            ..loadUrl(
              previousUrl,
              context,
              eventId: widget.eventData.eventId,
            );
        } else {
          setState(() {
            _livestreamUrl = null;
            _isCheckingLivestream = false;
          });
        }
      }
    }
  }

  (int, int)? _lastScore;
  (int, int)? _lastPenScore;

  void _rememberScore() {
    final e = widget.eventData;
    final h = e.displayHomeScore;
    final a = e.displayAwayScore;
    if (e.isLive || h > 0 || a > 0) _lastScore = (h, a);
    if (e.homeScorePen > 0 || e.awayScorePen > 0) {
      _lastPenScore = (e.homeScorePen, e.awayScorePen);
    }
  }

  @override
  void didUpdateWidget(MatchHeaderMobileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rememberScore();

    _detectNotices(oldWidget.eventData, widget.eventData);

    debugPrint(
      '[LS-DIDUPDATE-M] old.eventId=${oldWidget.eventData.eventId} '
      'new.eventId=${widget.eventData.eventId} '
      'new.isLive=${widget.eventData.isLive} '
      'new.isLivestream=${widget.eventData.isLivestream} '
      'changedEvent=${oldWidget.eventData.eventId != widget.eventData.eventId}',
    );

    if (widget.eventData.isLive != oldWidget.eventData.isLive) {
      if (widget.eventData.isLive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    if (oldWidget.eventData.eventId != widget.eventData.eventId) {
      setState(() {
        _livestreamUrl = null;
        _isCheckingLivestream = false;
      });
      if (widget.eventData.isLive && widget.eventData.isLivestream) {
        print('_checkLivestreamUrl: Đổi sang trận khác = "mới vào" trận mới → cho phép switch sang live.');
        _checkLivestreamUrl(isInitial: true);
      } else if (_selectedTab == MatchTab.live) {
        setState(() {
          _selectedTab = MatchTab.scoreboard;
          widget.onTabChanged?.call(_selectedTab);
        });
      }
      return;
    }

    final hadPrerequisites =
        oldWidget.eventData.isLive && oldWidget.eventData.isLivestream;
    final hasPrerequisites =
        widget.eventData.isLive && widget.eventData.isLivestream;

    if (hasPrerequisites != hadPrerequisites) {
      if (hasPrerequisites) {
        print('_checkLivestreamUrl: hasPrerequisites');
        _checkLivestreamUrl();
      } else {
        setState(() {
          _livestreamUrl = null;
          if (_selectedTab == MatchTab.live) {
            _selectedTab = MatchTab.scoreboard;
            widget.onTabChanged?.call(_selectedTab);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _noticeSuspendGuard.dispose();
    _homeNoticeTimer?.cancel();
    _awayNoticeTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _rememberScore();
    ref.watch(isAuthenticatedProvider);
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (!next && _selectedTab == MatchTab.follow) {
        setTab(MatchTab.scoreboard);
      }
    });
    if (_useCard) {
      _maybeFetchH2h();
      final tabs = _cardTabs;
      final hasPane = _liveOn && tabs.isNotEmpty;
      final head = _buildCardHead(tabs, hasPane: hasPane);
      final body = hasPane ? BdMatchCardPane(child: _buildTabContent()) : null;
      final builder = layoutBuilderOf;
      if (builder != null) return builder(context, head, body);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [head, if (body != null) body],
      );
    }
    final Widget legacy = Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabContent(),
          Padding(padding: const EdgeInsets.all(4), child: _buildTabs()),
        ],
      ),
    );
    final legacyBuilder = layoutBuilderOf;
    if (legacyBuilder != null) return legacyBuilder(context, null, legacy);
    return legacy;
  }

  Widget Function(BuildContext, Widget?, Widget?)? get layoutBuilderOf =>
      widget.layoutBuilder;

  Widget _buildCardHead(List<MatchTab> tabs, {required bool hasPane}) {
    return BdMatchCardMobile(
      eventData: widget.eventData,
      leagueName: widget.leagueData?.leagueName ?? '',
      sportId: widget.sportId,
      ftHandicapPoints: _cardHandicapPoints,
      eventEnded: widget.eventEnded,
      lastScore: _lastScore,
      lastPenScore: _lastPenScore,
      homeFlip: _homeFlip,
      awayFlip: _awayFlip,
      onShare: null,
      onStats: () => _showStatsDialog(context),
      statsEnabled: _canShowStats,
      tabs: tabs.isEmpty ? null : _buildCardTabs(disabled: !_liveOn),
      hideBottomBorderRadius: hasPane,
      homeNotice: _homeNotice,
      awayNotice: _awayNotice,
      homeNoticeSeq: _homeNoticeSeq,
      awayNoticeSeq: _awayNoticeSeq,
      onHomeNoticeCompleted: () => _clearNotice(home: true),
      onAwayNoticeCompleted: () => _clearNotice(home: false),
    );
  }

  double get _cardHandicapPoints {
    for (final market in widget.eventData.markets) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue ?? 0;
      }
    }
    return 0;
  }

  Widget _buildCardTabs({bool disabled = false}) {
    final tabs = _cardTabs;
    Widget segment(String label, MatchTab tab, {bool dot = false}) {
      final active = _effectiveTab == tab;
      return GestureDetector(
        onTap: disabled
            ? null
            : SoundTap.wrap(() {
                _pauseVideoIfPlaying();
                if (_selectedTab == tab) return;
                setState(() => _selectedTab = tab);
                widget.onTabChanged?.call(_selectedTab);
              }),
        child: Opacity(
          opacity: active ? 1.0 : 0.6,
          child: Container(
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColorStyles.backgroundQuaternary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelXXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
                if (dot) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF04438),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          if (widget.eventData.isLive)
            BdLiveToggle(
              on: _liveOn,
              onTap: _toggleLive,
              compact: tabs.length > 2,
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF111010),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final tab in tabs)
                  if (tab == MatchTab.follow)
                    segment('Diễn biến', tab)
                  else if (tab == MatchTab.h2h)
                    segment('Đối đầu', tab)
                  else if (tab == MatchTab.live)
                    segment('Trực tiếp', tab, dot: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_effectiveTab) {
      case MatchTab.follow:
        if (!_isLoggedIn) return _buildTrackerLoginPrompt();
        return _buildTrackerContent();
      case MatchTab.live:
        return _buildLiveContent();
      case MatchTab.h2h:
        final data = _h2h;
        return data != null
            ? BdH2hPanelMobile(
                data: data,
                homeName: widget.eventData.homeName,
                awayName: widget.eventData.awayName,
              )
            : (_isLoggedIn
                ? _buildTrackerContent()
                : _buildTrackerLoginPrompt());
      case MatchTab.scoreboard:
      case MatchTab.statistics:
        return _buildStatisticsContent();
    }
  }

  String _getStatisticsBackgroundImageUrl() {
    switch (widget.sportId) {
      case 1:
        return AppImages.soccerstadiumphotoshot1;
      case 2:
        return AppImages.betDetailBackgroundBaseketball;
      case 4:
        return AppImages.betDetailBackgroundTennis;
      case 5:
        return AppImages.betDetailBackgroundVolleyball;
      case 7:
        return AppIcons.iconBadminton;
      default:
        return AppImages.soccerstadiumphotoshot1;
    }
  }

  Widget _buildStatisticsContent() => Container(
    constraints: const BoxConstraints(minHeight: 140),
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: const Color.fromRGBO(255, 255, 255, 0.12),
                  width: 1.0,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ImageHelper.load(
                      path: _getStatisticsBackgroundImageUrl(),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(color: const Color(0xFF1B1A19).withOpacity(0.7)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildStatisticsTable(),
        ),
      ],
    ),
  );

  Widget _buildStatisticsTable() {
    final leagueName = widget.leagueData?.leagueName ?? '';

    final Widget? table = switch (widget.sportId) {
      2 => StatisticsTableBasketball(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      4 => StatisticsTableTennis(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      5 => StatisticsTableVolleyball(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      7 => StatisticsTableBadminton(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      _ => null,
    };

    if (table == null) {
      return MobileStatisticsTableWidget(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        leagueName: leagueName,
        homeNotice: _homeNotice,
        awayNotice: _awayNotice,
        homeNoticeSeq: _homeNoticeSeq,
        awayNoticeSeq: _awayNoticeSeq,
        onHomeNoticeCompleted: () => _clearNotice(home: true),
        onAwayNoticeCompleted: () => _clearNotice(home: false),
      );
    }

    if (leagueName.isEmpty) return table;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColorStyles.backgroundTertiary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLeagueNameHeader(leagueName),
            ImageHelper.load(
              path: AppIcons.hr,
              width: double.infinity,
              height: 2,
              fit: BoxFit.fill,
            ),
            table,
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueNameHeader(String leagueName) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      leagueName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTextStyles.paragraphXSmall(
        color: AppColorStyles.contentSecondary,
      ),
    ),
  );

  Widget _buildTrackerLoginPrompt() => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 160),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    color: const Color(0xFFE9E9E7),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Đăng nhập để xem diễn biến trận',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelXSmall(color: const Color(0xFF3F3E3B)),
        ),
        const SizedBox(height: 8),
        Text(
          'Sơ đồ sân, tấn công, phạt góc theo thời gian thực',
          textAlign: TextAlign.center,
          style: AppTextStyles.paragraphXXSmall(color: const Color(0xFF6B6A66)),
        ),
      ],
    ),
  );

  static const double _kTrackerCropTop = 155;

  static const double _kTrackerPitchRatio = 0.562;

  Widget _buildTrackerContent() => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      const radius = BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );

      if (!_useCard) {
        final height = (width * 9 / 16).clamp(200.0, double.infinity);
        return ClipRRect(
          borderRadius: radius,
          child: TrackerWidget(
            eventStatsId: widget.eventData.eventStatsId,
            sportId: widget.sportId,
            height: height,
          ),
        );
      }

      final visible = width * _kTrackerPitchRatio;
      final full = visible + _kTrackerCropTop;
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: visible,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -_kTrackerCropTop,
                left: 0,
                right: 0,
                height: full,
                child: TrackerWidget(
                  eventStatsId: widget.eventData.eventStatsId,
                  sportId: widget.sportId,
                  height: full,
                  croppedTop: _kTrackerCropTop,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildLiveContent() => Container(
    child: LivestreamWidget(
      key: widget.livestreamKey,
      url: _livestreamUrl ?? '',
      eventData: widget.eventData,
      sportId: widget.sportId,
      notice: MatchNoticeOverlayData(
        homeNotice: _homeNotice,
        awayNotice: _awayNotice,
        homeNoticeSeq: _homeNoticeSeq,
        awayNoticeSeq: _awayNoticeSeq,
        onHomeNoticeCompleted: () => _clearNotice(home: true),
        onAwayNoticeCompleted: () => _clearNotice(home: false),
      ),
    ),
  );

  Widget _buildTabs() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: SoundTap.wrap(
          _canShowStats ? () => _showStatsDialog(context) : null,
        ),
        child: Opacity(
          opacity: _canShowStats ? 1.0 : 0.5,
          child: Container(
            margin: const EdgeInsets.only(left: 14),
            child: ImageHelper.load(
              path: AppIcons.iconChart,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF111010),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: SoundTap.wrap(() {
                _pauseVideoIfPlaying();
                if (_selectedTab != MatchTab.scoreboard) {
                  setState(() {
                    _selectedTab = MatchTab.scoreboard;
                  });
                  widget.onTabChanged?.call(_selectedTab);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 32,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedTab == MatchTab.scoreboard
                      ? AppColorStyles.backgroundQuaternary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Bảng điểm',
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedTab == MatchTab.scoreboard
                          ? AppColorStyles.contentPrimary
                          : AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: SoundTap.wrap(
                _canUseTracker
                    ? () {
                        _pauseVideoIfPlaying();
                        if (_selectedTab != MatchTab.follow) {
                          setState(() {
                            _selectedTab = MatchTab.follow;
                          });
                          widget.onTabChanged?.call(_selectedTab);
                        }
                      }
                    : null,
              ),
              child: Opacity(
                opacity: _canUseTracker ? 1.0 : 0.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTab == MatchTab.follow
                        ? AppColorStyles.backgroundQuaternary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Theo dõi',
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _selectedTab == MatchTab.follow
                            ? AppColorStyles.contentPrimary
                            : AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (hasLivestreamUrl)
              GestureDetector(
                onTap: SoundTap.wrap(hasLivestreamUrl
                    ? () {
                        if (_selectedTab != MatchTab.live) {
                          _playVideoIfPaused();
                          setState(() {
                            _selectedTab = MatchTab.live;
                          });
                          widget.onTabChanged?.call(_selectedTab);
                        }
                      }
                    : null),
                child: Opacity(
                  opacity: hasLivestreamUrl ? 1.0 : 0.5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTab == MatchTab.live
                          ? AppColorStyles.backgroundQuaternary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Trực tuyến',
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _selectedTab == MatchTab.live
                                ? AppColorStyles.contentPrimary
                                : AppColorStyles.contentSecondary,
                          ),
                        ),
                        if (hasLivestreamUrl) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFD6F8E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

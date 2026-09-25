import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/stats/stats_dialog.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_widget.dart';
import 'package:sun_sports/shared/widgets/tracker/tracker_widget.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_suspend_guard.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/shared/widgets/livestream/pip_manager.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MatchHeaderMobileWidget extends ConsumerStatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  final int sportId;

  final bool
  hideStatisticsTable;
  final GlobalKey? statisticsTableKey;
  final bool
  hideStatisticsTableOpacity;
  final GlobalKey? livestreamKey;
  final void Function(MatchTab)? onTabChanged;

  const MatchHeaderMobileWidget({
    super.key,
    required this.eventData,
    this.leagueData,
    required this.sportId,
    this.hideStatisticsTable = false,
    this.statisticsTableKey,
    this.hideStatisticsTableOpacity = false,
    this.livestreamKey,
    this.onTabChanged,
  });

  @override
  ConsumerState<MatchHeaderMobileWidget> createState() =>
      _MatchHeaderMobileWidgetState();
}

enum MatchTab { statistics, scoreboard, follow, live }

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
    if (!PipManager().userClosed || !mounted) return;
    _checkLivestreamUrl(reloadVideo: true);
  }

  String? _livestreamUrl;
  bool _isCheckingLivestream = false;

  MatchNoticeType? _homeNotice;
  MatchNoticeType? _awayNotice;

  int _homeNoticeSeq = 0;
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

  @override
  void didUpdateWidget(MatchHeaderMobileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    ref.watch(isAuthenticatedProvider);
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (!next && _selectedTab == MatchTab.follow) {
        setTab(MatchTab.scoreboard);
      }
    });
    return Container(
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
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case MatchTab.follow:
        return _buildTrackerContent();
      case MatchTab.live:
        return _buildLiveContent();
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
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      4 => StatisticsTableTennis(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      5 => StatisticsTableVolleyball(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      7 => StatisticsTableBadminton(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      _ => null,
    };

    if (table == null) {
      return MobileStatisticsTableWidget(
        key: widget.statisticsTableKey,
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

  Widget _buildTrackerContent() => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final height = (width * 9 / 16).clamp(200.0, double.infinity);
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: TrackerWidget(
          eventStatsId: widget.eventData.eventStatsId,
          sportId: widget.sportId,
          height: height,
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
      onPiPActivated: () {
        setTab(MatchTab.scoreboard);
      },
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

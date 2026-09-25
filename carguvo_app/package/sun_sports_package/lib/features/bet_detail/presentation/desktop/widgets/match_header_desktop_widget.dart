import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_suspend_guard.dart';

import 'desktop_livestream_iframe_stub.dart'
    if (dart.library.html) 'desktop_livestream_iframe_web.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart'
    show ftHandicapMarketIds;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';
import 'package:sun_sports/shared/widgets/stats/stats_dialog.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:sun_sports/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MatchHeaderDesktopWidget extends ConsumerStatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  final int sportId;

  final bool isDesktop;

  const MatchHeaderDesktopWidget({
    super.key,
    required this.eventData,
    this.leagueData,
    required this.sportId,
    this.isDesktop = false,
  });

  @override
  ConsumerState<MatchHeaderDesktopWidget> createState() =>
      _MatchHeaderDesktopWidgetState();
}

enum _DesktopMatchTab { statistics, scoreboard, live }

class _MatchHeaderDesktopWidgetState
    extends ConsumerState<MatchHeaderDesktopWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late _DesktopMatchTab _selectedTab;

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

  bool get _canShowStats =>
      widget.eventData.eventStatsId > 0 && ref.read(isAuthenticatedProvider);

  void _showStatsDialog(BuildContext context) {
    if (!_canShowStats) return;

    StatsDialog.showForMatch(
      context: context,
      eventStatsId: widget.eventData.eventStatsId,
      homeName: widget.eventData.homeName,
      awayName: widget.eventData.awayName,
      config: StatsDialogConfig.desktop,
      width: 640,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedTab = _DesktopMatchTab.scoreboard;

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
      '[LS-INIT] eventId=${widget.eventData.eventId} '
      'isLive=${widget.eventData.isLive} '
      'isLivestream=${widget.eventData.isLivestream}',
    );

    if (widget.eventData.isLive && widget.eventData.isLivestream) {
      debugPrint('[LS-INIT] → gọi _checkLivestreamUrl()');
      _checkLivestreamUrl();
    } else {
      debugPrint(
        '[LS-INIT] → BỎ QUA _checkLivestreamUrl (không live hoặc không livestream)',
      );
    }
  }

  Future<void> _checkLivestreamUrl() async {
    if (_isCheckingLivestream) return;

    setState(() {
      _isCheckingLivestream = true;
    });

    final eventId = widget.eventData.eventId.toString();
    debugPrint('[LS-FLOW] 1. getLiveLink START eventId=$eventId');

    try {
      final httpManager = SbHttpManager.instance;
      final brand = SbConfig.brandId;

      final response = await httpManager.getLiveLink(eventId, brand);

      debugPrint(
        '[LS-FLOW] 2. getLiveLink OK eventId=$eventId '
        'url=${response.url} status=${response.status} type=${response.type}',
      );

      if (mounted) {
        setState(() {
          _livestreamUrl = response.url;
          _isCheckingLivestream = false;

          if (hasLivestreamUrl && _selectedTab == _DesktopMatchTab.scoreboard) {
            _selectedTab = _DesktopMatchTab.live;
          } else if (!hasLivestreamUrl &&
              _selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
          }
        });
        debugPrint(
          '[LS-FLOW] 3. state set eventId=$eventId '
          'hasLivestreamUrl=$hasLivestreamUrl selectedTab=$_selectedTab',
        );
      }
    } catch (e) {
      debugPrint('[LS-FLOW] X. getLiveLink ERROR eventId=$eventId error=$e');
      if (mounted) {
        setState(() {
          _livestreamUrl = null;
          _isCheckingLivestream = false;
          if (_selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(MatchHeaderDesktopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _detectNotices(oldWidget.eventData, widget.eventData);

    debugPrint(
      '[LS-DIDUPDATE] old.eventId=${oldWidget.eventData.eventId} '
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
        _checkLivestreamUrl();
      } else if (_selectedTab == _DesktopMatchTab.live) {
        setState(() => _selectedTab = _DesktopMatchTab.scoreboard);
      }
      return;
    }

    final hadPrerequisites =
        oldWidget.eventData.isLive && oldWidget.eventData.isLivestream;
    final hasPrerequisites =
        widget.eventData.isLive && widget.eventData.isLivestream;

    if (hasPrerequisites != hadPrerequisites) {
      if (hasPrerequisites) {
        _checkLivestreamUrl();
      } else {
        setState(() {
          _livestreamUrl = null;
          if (_selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
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
    ref.watch(isAuthenticatedProvider);
    return Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
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
      case _DesktopMatchTab.statistics:
      case _DesktopMatchTab.scoreboard:
        return _buildStatisticsContent();
      case _DesktopMatchTab.live:
        return _buildLivestreamContent();
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
      default:
        return AppImages.soccerstadiumphotoshot1;
    }
  }

  Widget _buildStatisticsContent() => Container(
    constraints: const BoxConstraints(minHeight: 208),
    child: Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: 40,
          ),
          child: _buildStatisticsTable(),
        ),
      ],
    ),
  );

  Widget _buildLivestreamContent() {
    if (!widget.isDesktop) {
      return _buildStatisticsContent();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatisticsTable(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          _buildDesktopLivestreamIframe(roundedTop: false),
        ],
      ),
    );
  }

  Widget _buildDesktopLivestreamIframe({bool roundedTop = true}) {
    if (!hasLivestreamUrl || _livestreamUrl == null) {
      debugPrint(
        '[LS-FLOW] 4. build → KHÔNG có link → placeholder '
        '(eventId=${widget.eventData.eventId})',
      );
      return _buildLivestreamPlaceholder(
        'Không có link livestream',
        roundedTop: roundedTop,
      );
    }

    debugPrint(
      '[LS-FLOW] 4. build → nhúng iframe (eventId=${widget.eventData.eventId}) '
      'url=$_livestreamUrl',
    );

    return DesktopLivestreamIframe(
      key: _stableLivestreamKey(_livestreamUrl!),
      url: _livestreamUrl!,
      roundedTop: roundedTop,
    );
  }

  GlobalKey? _livestreamKey;
  String? _livestreamKeyUrl;

  GlobalKey _stableLivestreamKey(String url) {
    if (_livestreamKeyUrl != url || _livestreamKey == null) {
      _livestreamKeyUrl = url;
      _livestreamKey = GlobalKey();
    }
    return _livestreamKey!;
  }

  Widget _buildLivestreamPlaceholder(
    String message, {
    bool roundedTop = true,
  }) => Container(
    constraints: const BoxConstraints(minHeight: 200),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: roundedTop
          ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            )
          : BorderRadius.zero,
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.paragraphXSmall(
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatisticsTable({BorderRadius? borderRadius}) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    final table = switch (widget.sportId) {
      2 => StatisticsTableBasketball(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
      ),
      4 => StatisticsTableTennis(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
      ),
      5 => StatisticsTableVolleyball(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
      ),
      7 => StatisticsTableBadminton(
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
      ),
      _ => _buildSoccerStatisticsTable(borderRadius: radius),
    };

    final leagueName = widget.leagueData?.leagueName ?? '';
    if (leagueName.isEmpty) return table;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
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

  Widget _buildSoccerStatisticsTable({BorderRadius? borderRadius}) => ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: AppColorStyles.backgroundTertiary,
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      if (widget.eventData.isLive)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5172)
                                          .withOpacity(
                                            0.12 * _pulseAnimation.value,
                                          ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5172)
                                          .withOpacity(
                                            0.12 * _pulseAnimation.value,
                                          ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5172),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.eventData.isLive) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: LiveMatchTimeDisplay(
                            eventId: widget.eventData.eventId,
                            initialMinute:
                                widget.eventData.minuteString.isNotEmpty
                                ? widget.eventData.minuteString
                                : null,
                            initialPeriod:
                                widget.eventData.gamePartEnum.displayName,
                            style: AppTextStyles.paragraphSmall(
                              color: AppColorStyles.contentSecondary,
                            ),
                            separator: const SizedBox(width: 12),
                          ),
                        ),
                      ],
                      if (!widget.eventData.isLive) ...[
                        Text(
                          widget.eventData.formattedTime,
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildTeamRow(
                  teamName: widget.eventData.homeName,
                  logoUrl:
                      widget.eventData.homeLogoFirst ??
                      widget.eventData.homeLogoLast ??
                      '',
                  isUpperTeam: _ftHandicapPoints == 0
                      ? null
                      : _ftHandicapPoints < 0,
                  notice: _homeNotice,
                  noticeSeq: _homeNoticeSeq,
                  onNoticeCompleted: () => _clearNotice(home: true),
                ),
                _buildTeamRow(
                  teamName: widget.eventData.awayName,
                  logoUrl:
                      widget.eventData.awayLogoFirst ??
                      widget.eventData.awayLogoLast ??
                      '',
                  isUpperTeam: _ftHandicapPoints == 0
                      ? null
                      : _ftHandicapPoints > 0,
                  notice: _awayNotice,
                  noticeSeq: _awayNoticeSeq,
                  onNoticeCompleted: () => _clearNotice(home: false),
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: [
                _buildStatColumn(
                  icon: _buildCornerKickIcon(),
                  homeValue: widget.eventData.cornersHome,
                  awayValue: widget.eventData.cornersAway,
                ),
                _buildStatColumn(
                  icon: _buildYellowCardIcon(),
                  homeValue: widget.eventData.yellowCardsHome,
                  awayValue: widget.eventData.yellowCardsAway,
                ),
                _buildStatColumn(
                  icon: _buildRedCardIcon(),
                  homeValue: widget.eventData.redCardsHome,
                  awayValue: widget.eventData.redCardsAway,
                ),
                _buildStatColumn(
                  icon: Text(
                    '2nd',
                    style: AppTextStyles.labelXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  homeValue: 0,
                  awayValue: 0,
                ),
                _buildStatColumn(
                  icon: _buildFootballIcon(),
                  homeValue: widget.eventData.displayHomeScore,
                  awayValue: widget.eventData.displayAwayScore,
                  highlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  double get _ftHandicapPoints {
    for (final market in widget.eventData.markets) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue ?? 0;
      }
    }
    return 0;
  }

  Widget _buildTeamRow({
    required String teamName,
    required String logoUrl,
    bool? isUpperTeam,
    MatchNoticeType? notice,
    int noticeSeq = 0,
    VoidCallback? onNoticeCompleted,
  }) => Stack(
    alignment: Alignment.centerLeft,
    children: [
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
        child: Row(
          children: [
            if (logoUrl.isNotEmpty)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 20,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                teamName,
                style: AppTextStyles.labelSmall(
                  color: isUpperTeam == true
                      ? AppColors.orange400
                      : AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      if (notice != null)
        Positioned.fill(
          child: MatchNoticeRiveAnimation(
            key: ValueKey('$notice-$noticeSeq'),
            type: notice,
            onCompleted: onNoticeCompleted,
          ),
        ),
    ],
  );

  Widget _buildStatColumn({
    required Widget icon,
    required int homeValue,
    required int awayValue,
    bool highlighted = false,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(child: icon),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                ),
                child: Center(
                  child: Text(
                    '$homeValue',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                ),
                child: Center(
                  child: Text(
                    '$awayValue',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (highlighted)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: IgnorePointer(
                    child: Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(color: AppColors.gray500, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildCornerKickIcon() =>
      ImageHelper.load(path: AppIcons.phatGoc, width: 20, height: 20);

  Widget _buildYellowCardIcon() =>
      ImageHelper.load(path: AppIcons.iconYellowCard, width: 20, height: 20);

  Widget _buildRedCardIcon() =>
      ImageHelper.load(path: AppIcons.iconRedCard, width: 20, height: 20);

  Widget _buildFootballIcon() => ImageHelper.load(
    path: AppIcons.iconSoccer,
    width: 20,
    height: 20,
    fit: BoxFit.fill,
  );

  Widget _buildTabs() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: SoundTap.wrap(
          _canShowStats ? () => _showStatsDialog(context) : null,
        ),
        child: Opacity(
          opacity: _canShowStats ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Thống kê',
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _canShowStats
                      ? AppColorStyles.contentPrimary
                      : AppColorStyles.contentSecondary,
                ),
              ),
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
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: SoundTap.wrap(() {
                  if (_selectedTab != _DesktopMatchTab.scoreboard) {
                    setState(() {
                      _selectedTab = _DesktopMatchTab.scoreboard;
                    });
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
                    color: _selectedTab == _DesktopMatchTab.scoreboard
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
                        color: _selectedTab == _DesktopMatchTab.scoreboard
                            ? AppColorStyles.contentPrimary
                            : AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: SoundTap.wrap(
                  hasLivestreamUrl
                      ? () {
                          if (_selectedTab != _DesktopMatchTab.live) {
                            setState(() {
                              _selectedTab = _DesktopMatchTab.live;
                            });
                          }
                        }
                      : null,
                ),
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
                      color: _selectedTab == _DesktopMatchTab.live
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
                            color: _selectedTab == _DesktopMatchTab.live
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
            ),
          ],
        ),
      ),
    ],
  );
}

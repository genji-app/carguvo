import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MatchHeaderWidget extends StatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const MatchHeaderWidget({
    super.key,
    required this.eventData,
    this.leagueData,
  });

  @override
  State<MatchHeaderWidget> createState() => _MatchHeaderWidgetState();
}

enum _MatchTab {
  scoreboard,
  live,
}

class _MatchHeaderWidgetState extends State<MatchHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late _MatchTab _selectedTab;

  String? _livestreamUrl;

  bool _isCheckingLivestream = false;

  bool get hasLivestreamUrl {
    if (!widget.eventData.isLive || !widget.eventData.isLivestream) {
      return false;
    }
    return _livestreamUrl != null && _livestreamUrl!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _selectedTab = _MatchTab.scoreboard;

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

    if (widget.eventData.isLive && widget.eventData.isLivestream) {
      _checkLivestreamUrl();
    }
  }

  Future<void> _checkLivestreamUrl() async {
    if (_isCheckingLivestream) return;

    setState(() {
      _isCheckingLivestream = true;
    });

    try {
      final httpManager = SbHttpManager.instance;
      final brand = SbConfig.brandId;
      final eventId = widget.eventData.eventId.toString();

      final response = await httpManager.getLiveLink(eventId, brand);

      if (mounted) {
        setState(() {
          _livestreamUrl = response.url;
          _isCheckingLivestream = false;

          if (hasLivestreamUrl && _selectedTab == _MatchTab.scoreboard) {
            _selectedTab = _MatchTab.live;
          } else if (!hasLivestreamUrl && _selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _livestreamUrl = null;
          _isCheckingLivestream = false;
          if (_selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(MatchHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventData.isLive != oldWidget.eventData.isLive) {
      if (widget.eventData.isLive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
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
          if (_selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    }

    if (hadPrerequisites &&
        !hasLivestreamUrl &&
        _selectedTab == _MatchTab.live) {
      setState(() {
        _selectedTab = _MatchTab.scoreboard;
      });
    } else if (!hadPrerequisites &&
        hasLivestreamUrl &&
        _selectedTab == _MatchTab.scoreboard) {
      setState(() {
        _selectedTab = _MatchTab.live;
      });
    }
  }

  String _getStatisticsBackgroundImageUrl() {
    final sportId = SbHttpManager.instance.sportTypeId;
    switch (sportId) {
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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: Stack(
            children: [
              Positioned.fill(
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
                      Container(
                        color: const Color(0xFF1B1A19).withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 40,
                ),
                child: _buildStatisticsTable(),
              ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(4), child: _buildTabs()),
      ],
    ),
  );

  Widget _buildStatisticsTable() => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColorStyles.backgroundTertiary,
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                        Text(
                          widget.eventData.minuteString,
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getGamePartDisplayText(
                            widget.eventData.gamePartEnum,
                          ),
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
                ),
                _buildTeamRow(
                  teamName: widget.eventData.awayName,
                  logoUrl:
                      widget.eventData.awayLogoFirst ??
                      widget.eventData.awayLogoLast ??
                      '',
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
                    '1st',
                    style: AppTextStyles.labelXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  homeValue: 0,
                  awayValue: 0,
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
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTeamRow({required String teamName, required String logoUrl}) =>
      Container(
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
                  color: AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildStatColumn({
    required Widget icon,
    required int homeValue,
    required int awayValue,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.all(12),
            child: Center(child: icon),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF111010),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: SoundTap.wrap(() {
                if (_selectedTab != _MatchTab.scoreboard) {
                  setState(() {
                    _selectedTab = _MatchTab.scoreboard;
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
                  color: _selectedTab == _MatchTab.scoreboard
                      ? AppColorStyles.backgroundQuaternary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Bảng điểm',
                    style: AppTextStyles.labelXSmall(
                      color: _selectedTab == _MatchTab.scoreboard
                          ? AppColorStyles.contentPrimary
                          : AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: SoundTap.wrap(hasLivestreamUrl
                  ? () {
                      if (_selectedTab != _MatchTab.live) {
                        setState(() {
                          _selectedTab = _MatchTab.live;
                        });
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
                    color: _selectedTab == _MatchTab.live
                        ? AppColorStyles.backgroundQuaternary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Trực tuyến',
                        style: AppTextStyles.labelXSmall(
                          color: _selectedTab == _MatchTab.live
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

  String _getGamePartDisplayText(GamePart gamePart) {
    switch (gamePart) {
      case GamePart.firstHalf:
        return 'Hiệp 1';
      case GamePart.secondHalf:
        return 'Hiệp 2';
      case GamePart.halfTime:
        return 'Nghỉ giữa giờ';
      case GamePart.firstHalfExtraTime:
        return 'Hiệp phụ 1';
      case GamePart.secondHalfExtraTime:
        return 'Hiệp phụ 2';
      case GamePart.halfTimeOfExtraTime:
        return 'Nghỉ hiệp phụ';
      case GamePart.extraTimeFinished:
        return 'Hết hiệp phụ';
      case GamePart.penalties:
        return 'Penalty';
      case GamePart.finished:
      case GamePart.regulaTimeFinished:
        return 'Kết thúc';
      case GamePart.notStarted:
        return gamePart.displayName;
    }
  }
}

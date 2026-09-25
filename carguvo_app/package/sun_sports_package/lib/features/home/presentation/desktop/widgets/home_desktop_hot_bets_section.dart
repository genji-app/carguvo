import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as shimmer;
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/upcoming_events_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/scroll/scroll.dart';

const int _sportIdFootball = 1;
const double _cardWidth = 200;
const double _separatorWidth = 12;

const double _listPaddingH = 8;

const double _mobilePeek = 60;

const double _mobileCardMin = 132;
const double _mobileCardMax = 176;

double _resolveCardWidth({required double viewportWidth, required bool fit}) {
  if (!fit) return _cardWidth;
  final raw =
      (viewportWidth - _listPaddingH - _separatorWidth * 2 - _mobilePeek) / 2;
  return raw.clamp(_mobileCardMin, _mobileCardMax);
}

class HomeDesktopHotBetsSection extends ConsumerStatefulWidget {
  const HomeDesktopHotBetsSection({this.fitToViewport = false, super.key});

  final bool fitToViewport;

  @override
  ConsumerState<HomeDesktopHotBetsSection> createState() =>
      _HomeDesktopHotBetsSectionState();
}

class _HomeDesktopHotBetsSectionState
    extends ConsumerState<HomeDesktopHotBetsSection> {
  final ScrollController _scrollController = ScrollController();

  final ScrollGestureAxisLock _wheelAxisLock = ScrollGestureAxisLock();

  bool _showLeft = false;
  bool _showRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;
    final pos = _scrollController.position;
    final atStart = pos.pixels <= 1;
    final atEnd = pos.pixels >= pos.maxScrollExtent - 1;
    final newShowLeft = !atStart;
    final newShowRight = !atEnd;
    if (newShowLeft == _showLeft && newShowRight == _showRight) {
      return;
    }
    setState(() {
      _showLeft = newShowLeft;
      _showRight = newShowRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();

    final asyncLeagues = ref.watch(
      upcomingLeagueEventsProvider(_sportIdFootball),
    );

    return SizedBox(
      height: 100,
      child: asyncLeagues.when(
        data: (leagues) {
          final items = _flattenUpcomingEvents(leagues);
          if (items.isEmpty) {
            return const SportEmptyPage();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onScroll();
          });
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final cardWidth = _resolveCardWidth(
                viewportWidth: viewportWidth,
                fit: widget.fitToViewport,
              );
              final scrollStep = cardWidth + _separatorWidth;
              return Stack(
                children: [
                  SizedBox(
                    width: viewportWidth,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: PointerDeviceKind.values.toSet(),
                      ),
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: SnapScrollPhysics(
                          itemWidth: scrollStep,
                          parent: const BouncingScrollPhysics(),
                        ),
                        itemCount: items.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: _listPaddingH,
                        ),
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: _separatorWidth),
                        itemBuilder: (context, index) {
                          final (event, league) = items[index];
                          return VerticalWheelForwarder(
                            axisLock: _wheelAxisLock,
                            child: RepaintBoundary(
                              child: _HotBetCard(
                                event: event,
                                league: league,
                                width: cardWidth,
                                onTap: () {
                                  ref.read(selectedEventV2Provider.notifier).state = event;
                                  ref.read(selectedLeagueV2Provider.notifier).state =league;
                                  ref.read(mainContentProvider.notifier).goToBetDetail();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF141414), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showLeft)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: SoundTap.wrap(() {
                            if (!_scrollController.hasClients) return;
                            final pos = _scrollController.position;
                            final target = (pos.pixels - scrollStep).clamp(
                              0.0,
                              pos.maxScrollExtent,
                            );
                            _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          }),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColorStyles.backgroundQuaternary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.transparent, Color(0xFF141414)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showRight)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: SoundTap.wrap(() {
                            if (!_scrollController.hasClients) return;
                            final pos = _scrollController.position;
                            final target = (pos.pixels + scrollStep).clamp(
                              0.0,
                              pos.maxScrollExtent,
                            );
                            _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          }),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColorStyles.backgroundQuaternary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        loading: () => LayoutBuilder(
          builder: (context, constraints) => _HotBetsSectionShimmer(
            cardWidth: _resolveCardWidth(
              viewportWidth: constraints.maxWidth,
              fit: widget.fitToViewport,
            ),
          ),
        ),
        error: (_, __) => Center(
          child: Text(
            'Không tải được dữ liệu',
            style: AppTextStyles.labelXSmall(color: AppColors.gray400),
          ),
        ),
      ),
    );
  }

  static List<(EventModelV2, LeagueModelV2)> _flattenUpcomingEvents(
    List<LeagueModelV2> leagues,
  ) {
    final result = <(EventModelV2, LeagueModelV2)>[];
    for (final league in leagues) {
      for (final event in league.upcomingEvents) {
        result.add((event, league));
      }
    }
    return result;
  }
}

class _HotBetCard extends StatelessWidget {
  const _HotBetCard({
    required this.event,
    required this.league,
    required this.width,
    required this.onTap,
  });

  final EventModelV2 event;
  final LeagueModelV2 league;

  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = event.isLive;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: SoundTap.wrap(onTap),
        child: InnerShadowCard(
          borderRadius: 16,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isLive: isLive),
                const Gap(4),
                Column(
                  children: [
                    _TeamRow(
                      teamName: event.homeName,
                      teamLogo: event.homeLogo,
                    ),
                    _TeamRow(
                      teamName: event.awayName,
                      teamLogo: event.awayLogo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isLive}) {
    if (isLive) {
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
          const Gap(8),
          Text(
            _formatGameTime(event.gameTime),
            style: AppTextStyles.labelXXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(4),
          Container(width: 1, height: 10, color: AppColors.gray400),
          const Gap(4),
          Text(
            _gamePartLabel(event.gamePart),
            style: AppTextStyles.labelXXSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      );
    }

    final (dateStr, timeStr) = _formatStartDateAndTime();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            dateStr,
            style: AppTextStyles.labelXXSmall(
              color: const Color(0xFFBEBEBE).withValues(alpha: 0.7),
            ),
          ),
          const Gap(4),
          Container(width: 1, height: 10, color: AppColors.gray400),
          const Gap(4),
          Text(
            timeStr,
            style: AppTextStyles.labelXXSmall(
              color: const Color(0xFFBEBEBE).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _formatStartDateAndTime() {
    DateTime? dt;
    if (event.startDate.isNotEmpty) {
      dt = DateTime.tryParse(event.startDate);
    }
    if (dt == null && event.startTime > 0) {
      dt = DateTime.fromMillisecondsSinceEpoch(event.startTime);
    }
    if (dt == null) return ('--/--/----', '--:--');
    final local = dt.toLocal();
    return (
      DateFormat('dd/MM/yyyy').format(local),
      DateFormat('HH:mm').format(local),
    );
  }

  static String _formatGameTime(int gameTime) {
    if (gameTime <= 0) return '0"';
    final minutes = gameTime ~/ 60000;
    return '$minutes"';
  }

  static String _gamePartLabel(int gamePart) =>
      GamePart.resolveLive(gamePart).viPeriodLabel;
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.teamName, required this.teamLogo});

  final String teamName;
  final String teamLogo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: teamLogo.isEmpty
                ? const SizedBox.shrink()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ImageHelper.load(
                      path: teamLogo,
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
              teamName.isEmpty ? '--' : teamName,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotBetsSectionShimmer extends StatelessWidget {
  const _HotBetsSectionShimmer({required this.cardWidth});

  final double cardWidth;

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  static Widget _box({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return shimmer.Shimmer(
      enabled: !kIsWeb,
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      padding: const EdgeInsets.only(left: _listPaddingH, right: 50),
      separatorBuilder: (_, __) => const SizedBox(width: _separatorWidth),
      itemBuilder: (_, __) => InnerShadowCard(
        borderRadius: 16,
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(width: 48, height: 10, borderRadius: 4),
                  const Gap(4),
                  _box(width: 1, height: 10),
                  const Gap(4),
                  _box(width: 32, height: 10, borderRadius: 4),
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  _box(width: 24, height: 24, borderRadius: 4),
                  const Gap(8),
                  Expanded(
                    child: _box(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ),
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  _box(width: 24, height: 24, borderRadius: 4),
                  const Gap(8),
                  Expanded(
                    child: _box(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

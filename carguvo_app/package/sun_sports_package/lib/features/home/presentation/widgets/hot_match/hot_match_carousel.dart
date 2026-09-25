import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/presentation/providers/hot_match_provider.dart';
import 'package:sun_sports/features/home/presentation/widgets/hot_match/hot_match_card.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';

class HotMatchCarousel extends ConsumerStatefulWidget {
  final void Function(HotMatchEventV2 match)? onMatchTap;

  final void Function(
    HotMatchEventV2 match,
    LeagueOddsData odds,
    bool isHome,
    int marketId,
  )?
  onOddsTap;

  final double height;

  final double viewportFraction;

  final int autoScrollInterval;

  const HotMatchCarousel({
    super.key,
    this.onMatchTap,
    this.onOddsTap,
    this.height = 200,
    this.viewportFraction = 0.85,
    this.autoScrollInterval = 7,
  });

  @override
  ConsumerState<HotMatchCarousel> createState() => _HotMatchCarouselState();
}

class _HotMatchCarouselState extends ConsumerState<HotMatchCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  Timer? _restartTimer;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _restartTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      Duration(seconds: widget.autoScrollInterval),
      (_) => _scrollToNextPage(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _scrollToNextPage() {
    if (!_pageController.hasClients || _isUserScrolling) return;

    final hotMatches = ref.read(hotMatchesProvider);
    if (hotMatches.isEmpty) return;

    final currentPage = ref.read(hotMatchPageIndexProvider);
    int nextPage = currentPage + 1;
    if (nextPage >= hotMatches.length) {
      nextPage = 0;
    }

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    ref.read(hotMatchProvider.notifier).setPageIndex(page);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isUserScrolling = true;
      _stopAutoScroll();
      _restartTimer?.cancel();
      _restartTimer = null;
    } else if (notification is ScrollEndNotification) {
      _isUserScrolling = false;
      _restartTimer?.cancel();
      _restartTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_isUserScrolling) {
          _startAutoScroll();
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hotMatches = ref.watch(hotMatchesProvider);
    final isLoading = ref.watch(hotMatchLoadingProvider);

    if (hotMatches.isEmpty && !isLoading) {
      return const SportEmptyPage();
    }

    if (isLoading && hotMatches.isEmpty) {
      return _buildLoadingSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(8),
              Text(
                'Hot Match',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFB800),
                  ),
                ),
            ],
          ),
        ),
        const Gap(12),

        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: PageView.builder(
              controller: _pageController,
              itemCount: hotMatches.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final match = hotMatches[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: HotMatchCard(
                    match: match,
                    onTap: () => widget.onMatchTap?.call(match),
                    onOddsTap: (odds, isHome, marketId) {
                      widget.onOddsTap?.call(match, odds, isHome, marketId);
                    },
                  ),
                );
              },
            ),
          ),
        ),

        const Gap(12),

        if (hotMatches.length > 1) _HotMatchIndicator(count: hotMatches.length),
      ],
    );
  }

  Widget _buildLoadingSkeleton() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(8),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
      const Gap(12),

      SizedBox(
        height: widget.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 2,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (_, __) => _buildCardSkeleton(),
        ),
      ),
    ],
  );

  Widget _buildCardSkeleton() => Container(
    width: 280,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamSkeleton(),
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColorStyles.backgroundQuaternary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(4),
                  Container(
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColorStyles.backgroundQuaternary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              _buildTeamSkeleton(),
            ],
          ),
        ),

        const Spacer(),

        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTeamSkeleton() => Column(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          shape: BoxShape.circle,
        ),
      ),
      const Gap(4),
      Container(
        width: 60,
        height: 12,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );
}

class _HotMatchIndicator extends ConsumerWidget {
  const _HotMatchIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(hotMatchPageIndexProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFB800)
                : AppColorStyles.contentQuaternary,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

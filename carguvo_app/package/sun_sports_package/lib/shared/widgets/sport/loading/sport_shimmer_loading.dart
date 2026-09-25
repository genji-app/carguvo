import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

const Color _kShimmerBoxColor = AppColors.gray600;
const Color _kShimmerHighlightColor = AppColorStyles.backgroundQuaternary;

class SportShimmerLoading extends StatelessWidget {
  final bool isDesktop;
  final int leagueCount;
  final int matchesPerLeague;

  const SportShimmerLoading({
    super.key,
    this.isDesktop = false,
    this.leagueCount = 3,
    this.matchesPerLeague = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _kShimmerHighlightColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            leagueCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 8 : 4),
              child: _ShimmerLeagueCard(
                isDesktop: isDesktop,
                matchCount: matchesPerLeague,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const _ShimmerBox({
    this.width,
    this.height,
    this.radius = 4,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: _kShimmerBoxColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ShimmerLeagueCard extends StatelessWidget {
  final bool isDesktop;
  final int matchCount;

  const _ShimmerLeagueCard({required this.isDesktop, required this.matchCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _ShimmerLeagueHeader(isDesktop: isDesktop),

          ...List.generate(
            matchCount,
            (index) => _ShimmerMatchRow(isDesktop: isDesktop),
          ),
        ],
      ),
    );
  }
}

class _ShimmerLeagueHeader extends StatelessWidget {
  final bool isDesktop;

  const _ShimmerLeagueHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 48 : 40,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          _ShimmerBox(
            width: isDesktop ? 28 : 26,
            height: isDesktop ? 28 : 26,
            radius: 6,
          ),
          const SizedBox(width: 8),

          const Expanded(child: _ShimmerBox(height: 14, width: double.infinity)),

          const SizedBox(width: 8),

          _ShimmerBox(
            width: isDesktop ? 24 : 20,
            height: isDesktop ? 24 : 20,
          ),
        ],
      ),
    );
  }
}

class _ShimmerMatchRow extends StatelessWidget {
  final bool isDesktop;

  const _ShimmerMatchRow({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final rowHeight = isDesktop ? 180.0 : 160.0;

    return Container(
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: _ShimmerBox(
                    height: 12,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => const Expanded(
                        child: _ShimmerBox(
                          height: 10,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerTeamRow(),
                      const SizedBox(height: 4),
                      _ShimmerTeamRow(),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          child: _ShimmerOddsColumn(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                3,
                (i) => const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: _ShimmerBox(width: 20, height: 20),
                ),
              ),
              const Spacer(),
              const _ShimmerBox(width: 40, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerTeamRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        children: [
          _ShimmerBox(width: 24, height: 24),
          SizedBox(width: 8),
          Expanded(child: _ShimmerBox(height: 12)),
        ],
      ),
    );
  }
}

class _ShimmerOddsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: i < 1 ? 4 : 0),
            child: const _ShimmerBox(radius: 6),
          ),
        ),
      ),
    );
  }
}

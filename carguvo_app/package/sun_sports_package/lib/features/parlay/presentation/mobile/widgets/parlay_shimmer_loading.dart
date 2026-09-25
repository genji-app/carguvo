import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class ParlayShimmerLoading extends StatelessWidget {
  final int cardCount;

  final ParlayShimmerType type;

  const ParlayShimmerLoading({
    super.key,
    this.cardCount = 2,
    this.type = ParlayShimmerType.single,
  });

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ParlayShimmerType.single => _buildSingleBetShimmer(),
      ParlayShimmerType.combo => _buildComboBetShimmer(),
    };
  }

  Widget _buildSingleBetShimmer() {
    return Column(
      children: [
        for (int i = 0; i < cardCount; i++) ...[
          _ShimmerSingleBetCard(),
          if (i < cardCount - 1) const Gap(12),
        ],
      ],
    );
  }

  Widget _buildComboBetShimmer() {
    return _ShimmerComboBetCard();
  }

  static Widget buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Shimmer(
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
}

enum ParlayShimmerType { single, combo }

class _ShimmerSingleBetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColorStyles.backgroundTertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ParlayShimmerLoading.buildShimmerBox(
                    width: 150,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const Spacer(),
                  ParlayShimmerLoading.buildShimmerBox(
                    width: 20,
                    height: 20,
                    borderRadius: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: AppColorStyles.backgroundQuaternary,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 100,
                              height: 12,
                              borderRadius: 4,
                            ),
                            const Gap(8),
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 140,
                              height: 16,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ParlayShimmerLoading.buildShimmerBox(
                            width: 18,
                            height: 18,
                            borderRadius: 9,
                          ),
                          const Gap(6),
                          ParlayShimmerLoading.buildShimmerBox(
                            width: 50,
                            height: 16,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParlayShimmerLoading.buildShimmerBox(
                              width: double.infinity,
                              height: 44,
                              borderRadius: 12,
                            ),
                            const Gap(8),
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 120,
                              height: 12,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 70,
                              height: 12,
                              borderRadius: 4,
                            ),
                            const Gap(8),
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 100,
                              height: 16,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: AppColorStyles.backgroundQuaternary,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ParlayShimmerLoading.buildShimmerBox(
                width: double.infinity,
                height: 40,
                borderRadius: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerComboBetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ParlayShimmerLoading.buildShimmerBox(
              width: 80,
              height: 14,
              borderRadius: 4,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(12).copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 70,
                      height: 14,
                      borderRadius: 4,
                    ),
                    const Spacer(),
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 50,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
                const Gap(16),
                ParlayShimmerLoading.buildShimmerBox(
                  width: double.infinity,
                  height: 52,
                  borderRadius: 12,
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                    ),
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    for (int i = 0; i < 5; i++) ...[
                      Expanded(
                        child: ParlayShimmerLoading.buildShimmerBox(
                          width: double.infinity,
                          height: 36,
                          borderRadius: 8,
                        ),
                      ),
                      if (i < 4) const Gap(8),
                    ],
                  ],
                ),
              ],
            ),
          ),
          for (int i = 0; i < 2; i++) _buildShimmerComboLeg(),
          Container(
            width: double.infinity,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerComboLeg() {
    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(12),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 180,
                      height: 12,
                      borderRadius: 4,
                    ),
                    const Spacer(),
                    ParlayShimmerLoading.buildShimmerBox(
                      width: 18,
                      height: 18,
                      borderRadius: 9,
                    ),
                  ],
                ),
                const Gap(8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 100,
                              height: 12,
                              borderRadius: 4,
                            ),
                            const Gap(8),
                            ParlayShimmerLoading.buildShimmerBox(
                              width: 120,
                              height: 14,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ParlayShimmerLoading.buildShimmerBox(
                            width: 18,
                            height: 18,
                            borderRadius: 9,
                          ),
                          const Gap(6),
                          ParlayShimmerLoading.buildShimmerBox(
                            width: 50,
                            height: 14,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

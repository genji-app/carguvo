import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShellTabletShimmerLoading extends StatelessWidget {
  const ShellTabletShimmerLoading({super.key});

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: _buildHeaderShimmer(),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF11100F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(child: _buildContentShimmer()),
                const SizedBox(width: 12),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationShimmer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black,
      child: Row(
        children: [
          _buildShimmerBox(width: 102, height: 16, borderRadius: 4),
          const SizedBox(width: 24),
          _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
          const Spacer(),
          _buildShimmerBox(width: 200, height: 44, borderRadius: 22),
          const Spacer(),
          _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 8),
          _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
        ],
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(
              width: double.infinity,
              height: 140,
              borderRadius: 12,
            ),
            const SizedBox(height: 16),
            _buildSectionTitleShimmer(),
            const SizedBox(height: 12),
            _buildHotBetsShimmer(),
            const SizedBox(height: 16),
            _buildSectionTitleShimmer(),
            const SizedBox(height: 12),
            _buildSportsShimmer(),
            const SizedBox(height: 16),
            _buildSectionTitleShimmer(),
            const SizedBox(height: 12),
            _buildCasinoShimmer(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Row(
      children: [
        _buildShimmerBox(width: 120, height: 20, borderRadius: 4),
        const Spacer(),
        _buildShimmerBox(width: 60, height: 16, borderRadius: 4),
      ],
    );
  }

  Widget _buildHotBetsShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildHotBetCardShimmer(),
      ),
    );
  }

  Widget _buildHotBetCardShimmer() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
              const SizedBox(width: 8),
              _buildShimmerBox(width: 80, height: 14, borderRadius: 4),
              const Spacer(),
              _buildShimmerBox(width: 40, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 12),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 12),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 32,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 32,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 32,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSportsShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0x0AFFF6E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShimmerBox(width: 36, height: 36, borderRadius: 8),
              const SizedBox(height: 8),
              _buildShimmerBox(width: 50, height: 12, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasinoShimmer() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _buildShimmerBox(width: 120, height: 140, borderRadius: 12),
      ),
    );
  }

  Widget _buildBottomNavigationShimmer() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          5,
          (index) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
              const SizedBox(height: 4),
              _buildShimmerBox(width: 40, height: 10, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
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

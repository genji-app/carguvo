import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShellMobileShimmerLoading extends StatelessWidget {
  const ShellMobileShimmerLoading({super.key});

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderShimmer(),
              const SizedBox(height: 16),
              _buildBannerShimmer(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Row(
      children: [
        _buildShimmerBox(width: 40, height: 40, borderRadius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShimmerBox(
            width: double.infinity,
            height: 24,
            borderRadius: 6,
          ),
        ),
        const SizedBox(width: 12),
        _buildShimmerBox(width: 40, height: 40, borderRadius: 20),
      ],
    );
  }

  Widget _buildBannerShimmer() {
    return _buildShimmerBox(
      width: double.infinity,
      height: 120,
      borderRadius: 12,
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Row(
      children: [
        _buildShimmerBox(width: 100, height: 18, borderRadius: 4),
        const Spacer(),
        _buildShimmerBox(width: 50, height: 14, borderRadius: 4),
      ],
    );
  }

  Widget _buildHotBetsShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
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
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 80,
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
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _buildShimmerBox(width: 120, height: 140, borderRadius: 12),
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

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShellDesktopShimmerLoading extends StatelessWidget {
  const ShellDesktopShimmerLoading({super.key});

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
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF11100F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            _buildLeftSidebarShimmer(),
            const SizedBox(width: 12),
            Expanded(child: _buildContentShimmer()),
            const SizedBox(width: 12),
            _buildRightSidebarShimmer(),
          ],
        ),
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
          _buildShimmerBox(width: 236, height: 44, borderRadius: 22),
          const Spacer(),
          _buildShimmerBox(width: 100, height: 44, borderRadius: 22),
          const SizedBox(width: 8),
          _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 8),
          _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
        ],
      ),
    );
  }

  Widget _buildLeftSidebarShimmer() {
    return SizedBox(
      width: 240,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 69,
                      borderRadius: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 69,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(6, (index) => _buildMenuItemShimmer()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildShimmerBox(
                width: double.infinity,
                height: 2,
                borderRadius: 1,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (index) => _buildMenuItemShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemShimmer() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 2),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildShimmerBox(width: 20, height: 20, borderRadius: 4),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShimmerBox(
                width: double.infinity,
                height: 12,
                borderRadius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(
                width: double.infinity,
                height: 160,
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
            ],
          ),
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
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildHotBetCardShimmer(),
      ),
    );
  }

  Widget _buildHotBetCardShimmer() {
    return Container(
      width: 320,
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
              _buildShimmerBox(width: 100, height: 14, borderRadius: 4),
              const Spacer(),
              _buildShimmerBox(width: 50, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBox(width: 28, height: 28, borderRadius: 14),
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShimmerBox(width: 28, height: 28, borderRadius: 14),
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
                  height: 36,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 36,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 36,
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
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0x0AFFF6E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShimmerBox(width: 40, height: 40, borderRadius: 8),
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
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _buildShimmerBox(width: 140, height: 160, borderRadius: 12),
      ),
    );
  }

  Widget _buildRightSidebarShimmer() {
    return SizedBox(
      width: 402,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: 12,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 12),
            _buildShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: 24,
            ),
          ],
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

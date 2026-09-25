import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

class NotificationShimmerLoading extends StatelessWidget {
  const NotificationShimmerLoading({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.gray800),
      itemBuilder: (_, __) => const _ShimmerNotificationRow(),
    );
  }
}

class _ShimmerNotificationRow extends StatelessWidget {
  const _ShimmerNotificationRow();

  static const _base = Color(0xFF2A2A2A);
  static const _highlight = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Shimmer(
            duration: const Duration(milliseconds: 1500),
            color: _highlight,
            colorOpacity: 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(w, 14),
                const SizedBox(height: 6),
                _bar(w * 0.88, 14),
                const SizedBox(height: 6),
                _bar(w * 0.88, 14),
                const SizedBox(height: 6),
                _bar(w * 0.88, 14),
                const SizedBox(height: 6),
                _bar(w * 0.88, 14),
                const SizedBox(height: 6),
                _bar(w * 0.88, 14),
                const SizedBox(height: 8),
                _bar(w * 0.32, 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _base,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

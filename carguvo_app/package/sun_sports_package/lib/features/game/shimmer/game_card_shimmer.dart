import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/shimmer/shimmer_box.dart';

class GameCardShimmer extends StatelessWidget {
  const GameCardShimmer({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          SizedBox(height: 8),
          ShimmerBox(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

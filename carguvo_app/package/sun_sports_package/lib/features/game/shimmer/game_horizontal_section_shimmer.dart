import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/game.dart';

class GameHorizontalSectionShimmer extends StatelessWidget {
  const GameHorizontalSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ShimmerBox(width: 140, height: 24, borderRadius: 6),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) =>
                const GameCardShimmer(width: GameCardLayout.minWidth),
          ),
        ),
      ],
    );
  }
}

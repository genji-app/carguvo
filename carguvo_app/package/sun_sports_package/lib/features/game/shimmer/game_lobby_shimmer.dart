import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/shimmer/game_horizontal_section_shimmer.dart';

class GameLobbyShimmer extends StatelessWidget {
  const GameLobbyShimmer({super.key, this.sectionCount = 3});

  final int sectionCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sectionCount,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (_, __) => const GameHorizontalSectionShimmer(),
    );
  }
}

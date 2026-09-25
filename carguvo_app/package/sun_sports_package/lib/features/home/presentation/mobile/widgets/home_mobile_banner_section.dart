import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/game/game.dart';

class HomeMobileBannerSection extends ConsumerWidget {
  const HomeMobileBannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BannerProviders(
    onTap: () {
      ref.goToCasino(selection: const GameCategorySelection());
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';

class HomeMobileHotBetsSection extends ConsumerWidget {
  const HomeMobileHotBetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [HomeDesktopHotBetsSection(fitToViewport: true), Gap(8)],
    );
  }
}

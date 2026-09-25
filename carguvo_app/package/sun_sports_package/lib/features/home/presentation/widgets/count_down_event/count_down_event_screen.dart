import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_deadline.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_desktop.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_mobile.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';

class CountDownEventScreen extends ConsumerWidget {
  const CountDownEventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();

    if (isEventCupExpired()) return const SizedBox.shrink();

    return const ResponsiveLayout(
      mobile: CountDownEventMobile(),
      tablet: CountDownEventMobile(),
      desktop: CountDownEventDesktop(),
    );
  }
}

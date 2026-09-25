import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/state/volta_state.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_metrics.dart';
import 'volta_head_to_head_board.dart';
import 'volta_history_board.dart';
import 'volta_results_board.dart';

class VoltaTabContent extends ConsumerWidget {
  const VoltaTabContent({this.tablet = false, super.key});

  final bool tablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(voltaStateProvider.select((s) => s.tab));

    return SizedBox(
      height: VoltaLayoutScope.of(context).tabContentHeight,
      child: switch (tab) {
        VoltaTab.history => const VoltaHistoryBoard(),
        VoltaTab.results => VoltaResultsBoard(tablet: tablet),
        VoltaTab.headToHead => const VoltaHeadToHeadBoard(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/play_history/play_history.dart';

class BettingHistoryFlowView extends StatefulWidget {
  const BettingHistoryFlowView({super.key});

  @override
  State<BettingHistoryFlowView> createState() => _BettingHistoryFlowViewState();
}

class _BettingHistoryFlowViewState extends State<BettingHistoryFlowView> {
  late final ValueNotifier<BettingHistoryFilter> _filterNotifier;

  @override
  void initState() {
    super.initState();
    _filterNotifier = ValueNotifier(BettingHistoryFilter.sports);
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BettingHistoryFilterMenu(
        initialValue: _filterNotifier.value,
        onChanged: (selection) => _filterNotifier.value = selection,
      ),
      body: ValueListenableBuilder(
        valueListenable: _filterNotifier,
        builder: (context, value, child) => switch (value) {
          BettingHistoryFilter.sports => const BettingHistoryView(),
          BettingHistoryFilter.casino => const PlayHistoryView(),
        },
      ),
    );
  }
}

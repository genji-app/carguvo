import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';

final matchSummaryStatsProvider =
    FutureProvider.family<MatchSummaryStats, int>((ref, summaryEventId) {
      return ref.read(myBetRepositoryProvider).getMatchSummary(summaryEventId);
    });

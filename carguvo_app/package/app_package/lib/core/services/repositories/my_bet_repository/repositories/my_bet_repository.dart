import 'dart:async';

import '../models/models.dart';
import 'my_bet_failure.dart';

enum MyBetFilter {
  active,

  settled,
}

abstract class MyBetRepository {
  Future<List<BetSlip>> getTickets({MyBetFilter filter = MyBetFilter.active});

  Future<BetSlip?> getTicketDetail(String ticketId);

  Future<MatchSummaryStats> getMatchSummary(int summaryEventId);

  Future<GetCashoutResponse?> getCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  });

  Future<CashoutResponse> performCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  });

  Stream<int> get activeBetCountStream;

  Stream<CashoutResponse> get onTicketCashoutSuccess;

  Stream<void> get onBetPlaced;

  void notifyBetPlaced();

  int get currentActiveCount;

  Future<void> refreshActiveCount();

  void dispose();
}

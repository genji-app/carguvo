import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class MyBetRepositoryRemote implements MyBetRepository {
  MyBetRepositoryRemote({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  final SbHttpManager _http;
  final AppLogger _logger = AppLogger(tag: 'MyBetRepo');

  final _activeCountController = StreamController<int>.broadcast();
  final _cashoutSuccessController =
      StreamController<CashoutResponse>.broadcast();
  final _betPlacedController = StreamController<void>.broadcast();
  int _currentActiveCount = 0;

  String get token => _http.userTokenSb;

  @override
  Stream<int> get activeBetCountStream => _activeCountController.stream;

  @override
  Stream<CashoutResponse> get onTicketCashoutSuccess =>
      _cashoutSuccessController.stream;

  @override
  Stream<void> get onBetPlaced => _betPlacedController.stream;

  @override
  int get currentActiveCount => _currentActiveCount;

  @override
  void notifyBetPlaced() {
    if (_betPlacedController.isClosed) return;
    if (_betPlacedController.hasListener) {
      _betPlacedController.add(null);
    } else {
      refreshActiveCount();
    }
  }

  @override
  void dispose() {
    _activeCountController.close();
    _cashoutSuccessController.close();
    _betPlacedController.close();
  }

  @override
  Future<GetCashoutResponse?> getCashout({
    required num amount,
    required String displayOdds,
    required num stake,
    required String ticketId,
  }) async {
    try {
      final requestBody = {
        'amount': amount.toInt(),
        'displayOdds': displayOdds,
        'stake': stake.toInt(),
        'ticketId': ticketId,
        'token': token,
        'userId': '',
      };

      debugPrint('MyBetRepositoryRemote: getCashout request: $requestBody');

      final response = await _http.getCashOut(requestBody);

      if (response.isEmpty) {
        return null;
      }

      return GetCashoutResponse.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get cash out', error: e, stackTrace: stackTrace);
      Error.throwWithStackTrace(GetCashoutFailure(e), stackTrace);
    }
  }

  @override
  Future<CashoutResponse> performCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  }) async {
    try {
      final requestBody = {
        'amount': amount,
        'displayOdds': displayOdds,
        'stake': stake,
        'ticketId': ticketId,
        'userId': '',
      };

      final response = await _http.cashOut(requestBody);

      if (response.isEmpty) {
        throw Exception('Empty cash out response from server');
      }

      final cashoutResponse = CashoutResponse.fromJson(response);

      if (!cashoutResponse.isSuccess) {
        debugPrint(
          'MyBetRepositoryRemote: Cash out API returned success:false - '
          'ticketId: ${cashoutResponse.ticketId}, '
          'status: ${cashoutResponse.settlementStatus}',
        );
        throw Exception('Cash out failed: ${cashoutResponse.settlementStatus}');
      }

      debugPrint(
        'MyBetRepositoryRemote: Cash out successful - '
        'ticketId: ${cashoutResponse.ticketId}, '
        'amount: ${cashoutResponse.cashoutAmount}, '
        'status: ${cashoutResponse.settlementStatus}',
      );

      _cashoutSuccessController.add(cashoutResponse);

      return cashoutResponse;
    } catch (e, stackTrace) {
      _logger.e('Failed to perform cash out', error: e, stackTrace: stackTrace);
      Error.throwWithStackTrace(PerformCashoutFailure(e), stackTrace);
    }
  }

  @override
  Future<void> refreshActiveCount() async {
    try {
      await getTickets(filter: MyBetFilter.active);
    } catch (e) {
      debugPrint('MyBetRepositoryRemote: Warm-up active count failed: $e');
    }
  }

  void _updateActiveCount(int count) {
    if (_currentActiveCount != count && !_activeCountController.isClosed) {
      _currentActiveCount = count;
      _activeCountController.add(count);
      debugPrint('MyBetRepositoryRemote: Active count updated to $count');
    }
  }

  @override
  Future<List<BetSlip>> getTickets({
    MyBetFilter filter = MyBetFilter.active,
  }) async {
    switch (filter) {
      case MyBetFilter.active:
        return getActiveTickets();
      case MyBetFilter.settled:
        return getSettledTickets();
    }
  }

  Future<List<BetSlip>> getActiveTickets() async {
    try {
      final results = await Future.wait([
        _http.getBetSlipByStatus(
          BettingHistoryConstants.apiStatusActive,
          sportId: _http.sportTypeId,
          token: token,
        ),
        _http.getBetSlipByStatus(
          BettingHistoryConstants.apiStatusPending,
          sportId: _http.sportTypeId,
          token: token,
        ),
      ]);

      final activeBets = _parseBetSlipsStandard(_asListOrEmpty(results[0]));
      final pendingBets = _parseBetSlipsStandard(_asListOrEmpty(results[1]));

      final allActiveBets = [...activeBets, ...pendingBets];

      _sortBets(allActiveBets);

      _updateActiveCount(allActiveBets.length);

      return allActiveBets;
    } catch (e, stackTrace) {
      _logger.e('Failed to get active tickets', error: e, stackTrace: stackTrace);
      Error.throwWithStackTrace(GetActiveTicketsFailure(e), stackTrace);
    }
  }

  Future<List<BetSlip>> getSettledTickets() async {
    try {
      final results = await Future.wait([
        _http.betsReporting(
          BettingHistoryConstants.apiStatusSettled,
          sportId: _http.sportTypeId,
          token: token,
        ),
        _http.betsReporting(
          BettingHistoryConstants.apiStatusDeclined,
          sportId: _http.sportTypeId,
          token: token,
        ),
      ]);

      final settledBets = _parseBetSlipsNumeric(_asListOrEmpty(results[0]));
      final declinedBets = _parseBetSlipsNumeric(_asListOrEmpty(results[1]));

      final allSettledBets = [...settledBets, ...declinedBets];

      _sortBets(allSettledBets);

      return allSettledBets;
    } catch (e, stackTrace) {
      _logger.e('Failed to get settled tickets', error: e, stackTrace: stackTrace);
      Error.throwWithStackTrace(GetSettledTicketsFailure(e), stackTrace);
    }
  }

  static List<dynamic> _asListOrEmpty(dynamic data) =>
      data is List ? data : const <dynamic>[];

  List<BetSlip> _parseBetSlipsStandard(List<dynamic> data) {
    return data
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return BetSlip.fromJson(item).resolveComboWinning();
            }
            return null;
          } catch (e, st) {
            _logger.e('Error parsing standard BetSlip', error: e, stackTrace: st);
            return null;
          }
        })
        .whereType<BetSlip>()
        .toList();
  }

  List<BetSlip> _parseBetSlipsNumeric(List<dynamic> data) {
    return data
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return BetSlipParser.parse(item);
            }
            return null;
          } catch (e, st) {
            _logger.e('Error parsing numeric BetSlip', error: e, stackTrace: st);
            return null;
          }
        })
        .whereType<BetSlip>()
        .toList();
  }

  void _sortBets(List<BetSlip> bets) {
    bets.sort((a, b) => b.betTime.compareTo(a.betTime));
  }

  @override
  Future<MatchSummaryStats> getMatchSummary(int summaryEventId) async {
    try {
      final response = await _http.getMatchSummary(summaryEventId);
      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw const FormatException('match summary: missing data');
      }

      if (data['matchStatus'] == 'not_started') {
        throw const MatchNotStartedFailure();
      }

      final competitors = data['competitor'] as List<dynamic>? ?? const [];
      final timeline = data['timeline'] as List<dynamic>? ?? const [];
      if (competitors.isEmpty || timeline.isEmpty) {
        throw const FormatException('match summary: empty competitor/timeline');
      }

      return MatchSummaryParser.parse(data);
    } on MatchNotStartedFailure {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get match summary $summaryEventId',
        error: e,
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(GetMatchSummaryFailure(e), stackTrace);
    }
  }

  @override
  Future<BetSlip?> getTicketDetail(String ticketId) async {
    try {
      final response = await _http.getStatusByTicketId(ticketId);

      if (response['ticket'] == null) return null;

      final ticketData = response['ticket'] as Map<String, dynamic>;
      return BetSlipParser.parse(ticketData);
    } catch (e, stackTrace) {
      _logger.e('Failed to get ticket detail', error: e, stackTrace: stackTrace);
      Error.throwWithStackTrace(GetTicketDetailFailure(e), stackTrace);
    }
  }
}

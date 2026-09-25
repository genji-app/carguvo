// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/misc/misc.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

final bettingHistoryProvider =
    StateNotifierProvider.autoDispose<
      BettingHistoryNotifier,
      PaginatedState<List<BetSlip>>
    >((ref) {
      return BettingHistoryNotifier(
        repository: ref.watch(myBetRepositoryProvider),
      );
    });

class BettingHistoryNotifier
    extends StateNotifier<PaginatedState<List<BetSlip>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<List<BetSlip>, List<BetSlip>> {
  BettingHistoryNotifier({required MyBetRepository repository})
    : _repository = repository,
      _filter = MyBetFilter.active,
      super(const PaginatedState.initial());

  final MyBetRepository _repository;

  StreamSubscription<CashoutResponse>? _cashoutSubscription;
  StreamSubscription<void>? _betPlacedSubscription;

  MyBetFilter _filter = MyBetFilter.active;
  MyBetFilter get filter => _filter;
  void setFilter(MyBetFilter filter) {
    if (_filter == filter) return;
    logInfo('Filter changed: $_filter → $filter');
    _filter = filter;
  }

  void _subscribeToCashoutEvents() {
    _cashoutSubscription = _repository.onTicketCashoutSuccess.listen(
      (response) => _handleCashoutSuccess(response),
    );
  }

  void _subscribeToBetPlacedEvents() {
    _betPlacedSubscription = _repository.onBetPlaced.listen((_) {
      if (_filter != MyBetFilter.active) return;
      logInfo('Bet placed - refreshing active list');
      refresh();
    });
  }

  void _handleCashoutSuccess(CashoutResponse response) {
    if (_filter == MyBetFilter.active) {
      final currentData = state.data ?? [];
      final newData = currentData
          .where((b) => b.ticketId != response.ticketId)
          .toList();

      if (newData.isEmpty) {
        state = PaginatedState.empty();
      } else {
        state = state.copyWith(data: newData);
      }

      logInfo(
        'Cashout success - removed ticket ${response.ticketId} from active list',
      );
    } else {
      final currentData = state.data;
      if (currentData == null) return;

      final newData = currentData.map((bet) {
        if (bet.ticketId == response.ticketId) {
          return bet.applyCashout(response);
        }
        return bet;
      }).toList();

      state = state.copyWith(data: newData);
      logInfo(
        'Cashout success - updated ticket ${response.ticketId} in settled list',
      );
    }
  }

  void updateTicketLocally(BetSlip updatedBet) {
    final currentData = state.data;
    if (currentData == null) return;

    final newData = currentData.map((bet) {
      if (bet.ticketId == updatedBet.ticketId) {
        return updatedBet;
      }
      return bet;
    }).toList();

    state = state.copyWith(data: newData);
  }

  Future<void> initialize() {
    logInfo('✅ BettingHistoryNotifier initialize');
    _subscribeToCashoutEvents();
    _subscribeToBetPlacedEvents();
    return loadInitial();
  }

  @override
  void dispose() {
    logInfo('🔴 BettingHistoryNotifier disposed');
    _cashoutSubscription?.cancel();
    _betPlacedSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> loadInitial() {
    state = const PaginatedState.initial();
    return super.loadInitial();
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError('Request failed', error, stackTrace);
  }

  @override
  Future<void> onInitialResponse(List<BetSlip> response) async {
    logInfo('Loaded ${response.length} bets (initial) | filter: $_filter');

    if (response.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(data: response);
    }
  }

  @override
  Future<void> onMoreResponse(
    List<BetSlip> response,
    List<BetSlip> data,
  ) async {
    state = PaginatedState.withData(data: [...data, ...response]);
  }

  @override
  Future<void> onRefreshResponse(List<BetSlip> response) async {
    logInfo('Refreshed ${response.length} bets | filter: $_filter');

    if (response.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(data: response);
    }
  }

  @override
  Future<List<BetSlip>> request([int? cursor]) {
    logDebug('Requesting bets... | filter: $_filter');
    return _repository.getTickets(filter: _filter);
  }
}

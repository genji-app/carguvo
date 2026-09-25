// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

part 'bet_slip_resell_notifier.freezed.dart';

@freezed
sealed class BetResellState with _$BetResellState {
  const factory BetResellState.idle() = _Idle;
  const factory BetResellState.fetchingQuote(BetSlip bet) = _FetchingQuote;
  const factory BetResellState.quoteFetched({
    required BetSlip bet,
    required GetCashoutResponse quote,
  }) = _QuoteFetched;
  const factory BetResellState.processing(BetSlip bet) = _Processing;
  const factory BetResellState.success(BetSlip bet, CashoutResponse response) =
      _Success;
  const factory BetResellState.error(BetSlip bet, String message) = _Error;
}

class BetResellNotifier extends StateNotifier<BetResellState> with LoggerMixin {
  BetResellNotifier(this._repository) : super(const BetResellState.idle());

  final MyBetRepository _repository;

  Future<GetCashoutResponse?> getLatestQuote(BetSlip bet) async {
    logInfo('Fetching quote for ticket: ${bet.ticketId}');

    try {
      state = BetResellState.fetchingQuote(bet);

      final cashoutAmount = bet.cashOutAbleAmount?.toDouble() ?? 0.0;
      logDebug(
        'Request quote | ticketId: ${bet.ticketId}, amount: $cashoutAmount',
      );

      final quote = await _repository.getCashout(
        ticketId: bet.ticketId,
        amount: cashoutAmount,
        displayOdds: bet.displayOdds,
        stake: bet.stake,
      );

      if (quote != null) {
        if (!quote.isCashoutAvailable) {
          logWarning('Cashout not available for ticket: ${bet.ticketId}');
          state = BetResellState.error(bet, I18n.txtResellNotAllowed);
        } else {
          logInfo(
            'Quote fetched | ticketId: ${bet.ticketId}, cashoutAmount: ${quote.cashoutAmount}',
          );
          state = BetResellState.quoteFetched(bet: bet, quote: quote);
        }
      } else {
        logWarning('Quote is null for ticket: ${bet.ticketId}');
        state = BetResellState.error(bet, I18n.txtCannotGetPrice);
      }
      return quote;
    } catch (e, st) {
      logError('Fetch quote failed for ticket: ${bet.ticketId}', e, st);
      state = BetResellState.error(bet, I18n.txtPriceConnectionError);
      return null;
    }
  }

  Future<void> resell(BetSlip bet) async {
    logInfo('Starting resell for ticket: ${bet.ticketId}');

    try {
      state = BetResellState.processing(bet);

      final cashoutAmount = bet.cashOutAbleAmount?.toDouble() ?? 0.0;
      logDebug(
        'Getting latest quote | ticketId: ${bet.ticketId}, amount: $cashoutAmount',
      );

      final quote = await _repository.getCashout(
        ticketId: bet.ticketId,
        amount: cashoutAmount,
        displayOdds: bet.displayOdds,
        stake: bet.stake,
      );

      final canCashout =
          quote != null &&
          quote.isCashoutAvailable &&
          quote.cashoutAmount != null &&
          quote.cashoutAmount! > 0;

      if (canCashout) {
        logInfo(
          'Executing cashout | ticketId: ${bet.ticketId}, cashoutAmount: ${quote.cashoutAmount}',
        );

        final response = await _repository.performCashout(
          ticketId: bet.ticketId,
          amount: quote.cashoutAmount!,
          displayOdds: quote.odds?.toString() ?? bet.displayOdds,
          stake: bet.stake,
        );

        logInfo(
          'Cashout successful | ticketId: ${bet.ticketId}, receivedAmount: ${response.cashoutAmount}',
        );

        await _repository.refreshActiveCount();

        state = BetResellState.success(bet, response);
      } else {
        final errorMsg = quote != null && !quote.isCashoutAvailable
            ? I18n.txtResellNotAllowed
            : I18n.txtPriceChangedError;
        logWarning(
          'Cannot cashout | ticketId: ${bet.ticketId}, reason: $errorMsg',
        );
        state = BetResellState.error(bet, errorMsg);
      }
    } catch (e, st) {
      logError('Resell failed for ticket: ${bet.ticketId}', e, st);
      state = BetResellState.error(bet, e.toString());
    }
  }

  void reset() {
    logDebug('Resetting state to idle');
    state = const BetResellState.idle();
  }
}

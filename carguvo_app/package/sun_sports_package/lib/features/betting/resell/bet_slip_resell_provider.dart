// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'bet_slip_resell_notifier.dart';

final betResellProvider =
    StateNotifierProvider<BetResellNotifier, BetResellState>((ref) {
      final repository = ref.watch(myBetRepositoryProvider);
      return BetResellNotifier(repository);
    });

final betResellControllerProvider = Provider((ref) {
  return (WidgetRef ref) => BetResellController(ref);
});

class BetResellController {
  BetResellController(this.ref);
  final WidgetRef ref;

  Future<bool> startResellFlow(BuildContext context, BetSlip bet) async {
    ref.read(betResellProvider.notifier).reset();

    await ref.read(betResellProvider.notifier).resell(bet);

    final state = ref.read(betResellProvider);

    return state.maybeWhen(
      success: (_, __) {
        _showSuccessToast(context);
        ref.read(userProvider.notifier).refreshBalance();
        return true;
      },
      error: (_, message) {
        _showErrorToast(context, message);
        return false;
      },
      orElse: () => false,
    );
  }

  void _showSuccessToast(BuildContext context) {
    if (!context.mounted) return;
    AppToast.showSuccess(
      context,
      message: '${I18n.txtSellTicket} ${I18n.txtSuccess}',
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showError(
      context,
      message: localizedOrGenericError(
        '${I18n.txtSellTicket} ${I18n.txtFailure}',
        message,
      ),
    );
  }
}

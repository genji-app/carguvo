import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_cashout_result.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

const List<int> kUpDownBetValues = [1000, 10000, 50000, 100000, 500000];

mixin UpDownInterfaceActions<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  final GlobalKey cashoutKey = GlobalKey();

  int get bet => ref.read(upDownStateProvider).selectedBet;

  bool get spinning => ref.read(upDownStateProvider).spinning;

  int betIndexOf(int selectedBet) =>
      kUpDownBetValues.indexOf(selectedBet).clamp(0, kUpDownBetValues.length - 1);

  bool blockedBySpin() {
    if (!spinning) return false;
    AppToast.showError(context, message: I18n.upDownRoundNotFinished);
    return true;
  }

  void selectBet(int i) {
    final s = ref.read(upDownStateProvider);
    if (s.spinning || s.sessionId != 0) {
      AppToast.showError(context, message: I18n.upDownCannotChangeBet);
      return;
    }
    ref.read(upDownStateProvider.notifier).setBet(kUpDownBetValues[i]);
  }

  bool canStart() {
    if (blockedBySpin()) return false;
    if (ref.read(balanceInVNDProvider) < bet) {
      AppToast.showError(context, message: I18n.upDownNotEnoughMoney);
      return false;
    }
    return true;
  }

  void start() {
    if (!canStart()) return;
    ref.read(upDownStateProvider.notifier).startGame(bet: bet);
  }

  void cashout() {
    if (blockedBySpin()) return;
    final box = cashoutKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.attached && box.hasSize) {
      upDownCashoutAnchorY.value = box.localToGlobal(Offset.zero).dy - 50;
    } else {
      upDownCashoutAnchorY.value = null;
    }
    ref.read(upDownStateProvider.notifier).cashout();
  }

  void pickUp() {
    if (blockedBySpin()) return;
    ref.read(upDownStateProvider.notifier).pickUp(bet: bet);
  }

  void pickDown() {
    if (blockedBySpin()) return;
    ref.read(upDownStateProvider.notifier).pickDown(bet: bet);
  }
}

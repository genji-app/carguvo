import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'package:sun_sports/mini/tx/sub_views/tai_xiu_sub_view_scaffold.dart';
import 'package:sun_sports/mini/tx/sub_views/session_history_view.dart';
import 'package:sun_sports/mini/tx/sub_views/session_stats_view.dart';
import 'package:sun_sports/mini/tx/sub_views/bet_history_view.dart';
import 'package:sun_sports/mini/tx/sub_views/guide_view.dart';
import 'package:sun_sports/mini/tx/sub_views/ranking_view.dart';

enum TaiXiuSide { tai, xiu }

const Duration _kResultRevealDelay = TaiXiuSocketNotifier.kDiceSpinDuration;

String taiXiuCompactAmount(int amount) {
  if (amount >= 1000000) {
    final m = amount / 1000000;
    return '${m == m.roundToDouble() ? m.toInt() : m}M';
  }
  if (amount >= 1000) {
    final k = amount / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k}K';
  }
  return '$amount';
}

mixin TaiXiuGameLogicMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  VoidCallback get onGameClose;

  TaiXiuSide? selectedSide;

  TaiXiuSubView? activeSubView;

  bool resultRevealed = false;
  Timer? _revealTimer;

  bool nanOpened = false;

  bool nanArmed = false;

  int winToken = 0;
  int winBannerAmount = 0;

  bool _winBannerShown = false;

  int stake = 0;

  StreamSubscription<TaiXiuToast>? _toastSub;

  @override
  void initState() {
    super.initState();
    _toastSub = ref
        .read(taiXiuSocketStateProvider.notifier)
        .toastMessages
        .listen((toast) {
          if (!mounted) return;
          final sound = toast.sound;
          if (sound != null) SoundEffects.instance.playMiniGame(sound);
          switch (toast.kind) {
            case TaiXiuToastKind.success:
              AppToast.showSuccess(
                context,
                message: toast.message,
                playSound: sound == null,
              );
            case TaiXiuToastKind.error:
              AppToast.showError(context, message: toast.message);
            case TaiXiuToastKind.info:
              AppToast.showGeneric(context, message: toast.message);
          }
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final total = ref.read(taiXiuSocketStateProvider).diceTotal;
      if (total != null && !resultRevealed && _revealTimer == null) {
        _onDiceTotalChanged(null, total);
      }
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _toastSub?.cancel();
    super.dispose();
  }

  void registerGameStateListeners() {
    ref.listen<int?>(
      taiXiuSocketStateProvider.select((s) => s.diceTotal),
      _onDiceTotalChanged,
    );
    ref.listen<int>(taiXiuSocketStateProvider.select((s) => s.winAmount), (
      _,
      next,
    ) {
      if (next > 0 && resultRevealed && (!nanArmed || nanOpened)) {
        _triggerWinBanner();
      }
    });
  }

  void _onDiceTotalChanged(int? prev, int? next) {
    if (next != null && prev == null) {
      _revealTimer?.cancel();
      if (ref.read(taiXiuSocketStateProvider).resultStatic) {
        _revealTimer = null;
        nanArmed = false;
        ref.read(taiXiuNanBowlOpenedProvider.notifier).state = true;
        setState(() => resultRevealed = true);
        _triggerWinBanner();
        return;
      }
      SoundEffects.instance.playMiniGame(MiniGameSound.roiXiNgau);
      nanArmed = ref.read(taiXiuNanActiveProvider);
      resultRevealed = false;
      _revealTimer = Timer(_kResultRevealDelay, () {
        if (!mounted) return;
        setState(() => resultRevealed = true);
        if (!nanArmed) _triggerWinBanner();
      });
    } else if (next == null && (prev != null || resultRevealed || nanOpened)) {
      _revealTimer?.cancel();
      _revealTimer = null;
      nanArmed = false;
      _winBannerShown = false;
      if (resultRevealed || nanOpened) {
        setState(() {
          resultRevealed = false;
          nanOpened = false;
        });
      }
      if (selectedSide != null || stake != 0) {
        setState(() {
          selectedSide = null;
          stake = 0;
        });
      }
    }
  }

  void openSubView(TaiXiuSubView view) => setState(() => activeSubView = view);
  void closeSubView() => setState(() => activeSubView = null);

  Widget buildSubView(TaiXiuSubView view) {
    switch (view) {
      case TaiXiuSubView.sessionHistory:
        return SessionHistoryView(onBack: closeSubView, onClose: onGameClose);
      case TaiXiuSubView.sessionStats:
        return SessionStatsView(onBack: closeSubView, onClose: onGameClose);
      case TaiXiuSubView.betHistory:
        return BetHistoryView(onBack: closeSubView, onClose: onGameClose);
      case TaiXiuSubView.guide:
        return GuideView(onBack: closeSubView, onClose: onGameClose);
      case TaiXiuSubView.ranking:
        return RankingView(onBack: closeSubView, onClose: onGameClose);
    }
  }

  void addStake(int amount) => setState(() => stake += amount);

  void allIn() {
    final balance = ref.read(taiXiuSocketStateProvider).availableGold;
    if (balance <= 0) return;
    setState(() => stake = balance);
  }

  void cancelStake() => setState(() {
    stake = 0;
    selectedSide = null;
  });

  void selectSide(TaiXiuSide side) {
    final st = ref.read(taiXiuSocketStateProvider);
    final oppositeBet = side == TaiXiuSide.tai ? st.xiuThisBet : st.taiThisBet;
    if (oppositeBet > 0) {
      AppToast.showError(context, message: 'Không được đặt cả 2 cửa');
      return;
    }
    setState(() => selectedSide = side);
  }

  void _triggerWinBanner() {
    ref.read(taiXiuSocketStateProvider.notifier).flushWinBalanceRefresh();
    if (_winBannerShown) return;
    final amount = ref.read(taiXiuSocketStateProvider).winAmount;
    if (amount <= 0) return;
    _winBannerShown = true;
    SoundEffects.instance.playMiniGame(MiniGameSound.winSfx);
    setState(() {
      winBannerAmount = amount;
      winToken++;
    });
  }

  void onBowlOpened() {
    setState(() => nanOpened = true);
    _triggerWinBanner();
    ref.read(taiXiuNanBowlOpenedProvider.notifier).state = true;
  }

  TaiXiuSide? effectiveSide(TaiXiuSocketState state) {
    if (selectedSide != null) return selectedSide;
    if (state.taiThisBet > 0) return TaiXiuSide.tai;
    if (state.xiuThisBet > 0) return TaiXiuSide.xiu;
    return null;
  }

  void confirmBet() {
    final state = ref.read(taiXiuSocketStateProvider);
    final side = effectiveSide(state);
    if (side == null || stake <= 0) return;
    final notifier = ref.read(taiXiuSocketStateProvider.notifier);
    if (side == TaiXiuSide.tai) {
      notifier.betTai(amount: stake);
    } else {
      notifier.betXiu(amount: stake);
    }
    setState(() {
      stake = 0;
      selectedSide = side;
    });
  }
}

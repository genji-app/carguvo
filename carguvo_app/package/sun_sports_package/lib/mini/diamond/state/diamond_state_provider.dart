import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/mini_game/messages/common/jackpot_data.dart';
import 'package:sun_sports/features/mini_game/messages/mini_game_message_streams.dart';
import 'package:sun_sports/features/mini_game/messages/mini_game_senders.dart';
import 'package:sun_sports/features/mini_game/messages/slot_message.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_paylines.dart';
import 'package:sun_sports/mini/diamond/state/diamond_prefs.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';

final diamondStateProvider =
    StateNotifierProvider.autoDispose<DiamondNotifier, DiamondState>(
  (ref) {
    final scopes = ref.watch(miniGameActiveScopesProvider);
    scopes.retainSlots();
    ref.onDispose(scopes.releaseSlots);
    return DiamondNotifier(ref);
  },
);

class DiamondNotifier extends StateNotifier<DiamondState> {
  final Ref _ref;
  final Logger _log = Logger();
  ProviderSubscription<AsyncValue<SlotMessage>>? _sub;

  ProviderSubscription<AsyncValue<MiniGameSocketState>>? _socketStateSub;
  MiniGameSocketState? _lastSocketState;

  Timer? _revealTimer;
  Duration get _revealDelay => state.fastSpin
      ? const Duration(milliseconds: 50)
      : const Duration(milliseconds: 100);

  Timer? _spinWatchdog;
  static const Duration _maxSpin = Duration(seconds: 8);

  Timer? _animTimer;
  Duration get _animSettleDelay => state.fastSpin
      ? const Duration(milliseconds: 450)
      : const Duration(milliseconds: 2200);

  Timer? _autoTimer;
  Duration get _autoGap => state.fastSpin
      ? const Duration(milliseconds: 1400)
      : const Duration(milliseconds: 3600);

  DateTime _lastSpinAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minSpinInterval = Duration(milliseconds: 500);

  final DiamondPrefs _prefs = DiamondPrefs();

  DiamondNotifier(this._ref) : super(const DiamondState(selectedLines: [])) {
    state = state.copyWith(selectedLines: kDiamondAllLines);
    _listen();
    _listenSocketState();
    subscribe();
    _restorePrefs();
  }

  Future<void> _restorePrefs() async {
    final saved = await _prefs.load();
    if (!mounted || state.spinning) return;
    final betChanged =
        saved.bet != null && kDiamondChips.contains(saved.bet) && saved.bet != state.selectedBet;
    final currentUid = _ref.read(userProvider).user?.uid;
    final resumeAuto = saved.auto == true &&
        saved.autoUid != null &&
        saved.autoUid!.isNotEmpty &&
        saved.autoUid == currentUid;
    state = state.copyWith(
      selectedBet: (saved.bet != null && kDiamondChips.contains(saved.bet))
          ? saved.bet
          : null,
      selectedLines:
          (saved.lines != null && saved.lines!.isNotEmpty) ? saved.lines : null,
      fastSpin: saved.turbo,
      autoSpin: resumeAuto,
    );
    if (betChanged) {
      state = state.copyWith(jackpot: _pickJackpot(state.jackpots));
      subscribe();
    }
    if (state.autoSpin && state.canSpin) spin();
  }

  Future<void> subscribe() async {
    final client = await _ref.read(miniGameSocketClientProvider.future);
    KimCuongSender(client).subscribe();
  }

  void _listenSocketState() {
    _socketStateSub = _ref.listen<AsyncValue<MiniGameSocketState>>(
      miniGameSocketStateProvider,
      (_, next) {
        final socketState = next.valueOrNull;
        if (socketState == null) return;
        final prev = _lastSocketState;
        _lastSocketState = socketState;
        if (prev == null) return;
        final wasAuthed = prev is SocketAuthenticated;
        final isAuthed = socketState is SocketAuthenticated;
        if (wasAuthed && !isAuthed) {
          _onSocketDropped();
        } else if (!wasAuthed && isAuthed) {
          _onSocketReauthenticated();
        }
      },
      fireImmediately: true,
    );
  }

  void _onSocketDropped() {
    _log.w('[Diamond] socket rớt → gỡ kẹt lượt quay (giữ Auto)');
    _autoTimer?.cancel();
    _spinWatchdog?.cancel();
    if (state.spinning || state.animating) {
      state = state.copyWith(
        spinning: false,
        animating: false,
      );
    }
  }

  void _onSocketReauthenticated() {
    _log.i('[Diamond] socket sống lại → re-subscribe');
    subscribe();
  }

  void _listen() {
    _sub = _ref.listen<AsyncValue<SlotMessage>>(
      slotMessageStreamProvider(SlotGameId.kimCuong),
      (_, next) {
        next.whenData(_handle);
        if (next.hasError) {
          _log.e('[Diamond] stream error', error: next.error);
        }
      },
    );
  }

  void _handle(SlotMessage msg) {
    switch (msg) {
      case SlotSubscribeJackpot(:final jackpots):
        state = state.copyWith(
          jackpots: jackpots,
          jackpot: _pickJackpot(jackpots),
        );
        if (state.autoSpin &&
            !state.spinning &&
            _lastSocketState is SocketAuthenticated) {
          _autoTimer?.cancel();
          _autoTimer = Timer(const Duration(milliseconds: 500), () {
            if (!mounted ||
                !state.autoSpin ||
                _lastSocketState is! SocketAuthenticated) {
              return;
            }
            if (state.jackpotWin > 0) return;
            if (state.canSpin) {
              spin();
            } else if (!state.spinning) {
              _maybeAutoNext();
            }
          });
        }
      case SlotUpdateJackpot(:final jackpots):
        state = state.copyWith(
          jackpots: jackpots,
          jackpot: _pickJackpot(jackpots),
        );
      case SlotSpinResult(
          :final errorMessage,
          :final accountId,
          :final moneyExchange,
          :final symbols,
          :final rewards,
          :final wonJackpot,
        ):
        if (errorMessage != null) {
          _revealTimer?.cancel();
          _spinWatchdog?.cancel();
          _animTimer?.cancel();
          state = state.copyWith(spinning: false, animating: false);
          return;
        }
        _scheduleReveal(() {
          final matrix = symbols
              .map((e) => e is int ? e : (e as num).toInt())
              .toList(growable: false);
          final wins = _extractWinLines(rewards);
          state = state.copyWith(
            symbols: matrix,
            winLineIds: wins,
            moneyExchange: moneyExchange,
            accountId: accountId ?? state.accountId,
            spinning: false,
            jackpotWin: wonJackpot && moneyExchange > 0
                ? moneyExchange
                : state.jackpotWin,
          );
          _scheduleAnimDone();
          _refreshAppBalance();
          _maybeAutoNext();
        });
    }
  }

  List<int> _extractWinLines(List<dynamic> rewards) {
    final ids = <int>[];
    for (final r in rewards) {
      if (r is Map) {
        final lid = (r['lid'] as num?)?.toInt();
        if (lid != null) ids.add(lid);
      }
    }
    return ids;
  }

  int _pickJackpot(List<JackpotData> jars) {
    if (jars.isEmpty) return state.jackpot;
    final match = jars.where(
      (j) => j.accountId == state.accountId && j.bet == state.selectedBet,
    );
    if (match.isNotEmpty) return match.first.jackpot;
    final aid1 = jars.where((j) => j.accountId == state.accountId);
    return (aid1.isNotEmpty ? aid1.first : jars.first).jackpot;
  }

  void setBet(int bet) {
    if (state.busy || bet == state.selectedBet) return;
    state = state.copyWith(selectedBet: bet);
    state = state.copyWith(jackpot: _pickJackpot(state.jackpots));
    _prefs.saveBet(bet);
    subscribe();
  }

  void setLines(List<int> lines) {
    if (state.busy) return;
    final sorted = [...lines]..sort();
    state = state.copyWith(selectedLines: sorted);
    _prefs.saveLines(sorted);
  }

  void toggleFast() {
    state = state.copyWith(fastSpin: !state.fastSpin);
    _prefs.saveTurbo(state.fastSpin);
  }

  void toggleAuto() {
    final next = !state.autoSpin;
    state = state.copyWith(autoSpin: next);
    _prefs.saveAuto(next, uid: _ref.read(userProvider).user?.uid);
    if (!next) {
      _autoTimer?.cancel();
      return;
    }
    if (state.canSpin) {
      spin();
    } else if (!state.spinning) {
      _maybeAutoNext();
    }
  }

  Future<void> spin() async {
    if (!state.canSpin) return;
    final now = DateTime.now();
    final since = now.difference(_lastSpinAt);
    if (since < _minSpinInterval) {
      if (state.autoSpin) {
        _autoTimer?.cancel();
        _autoTimer = Timer(_minSpinInterval - since, () {
          if (mounted && state.autoSpin) spin();
        });
      }
      return;
    }
    _lastSpinAt = now;
    _autoTimer?.cancel();
    _animTimer?.cancel();
    state = state.copyWith(
      spinning: true,
      animating: true,
      winLineIds: const [],
      moneyExchange: 0,
    );
    _startSpinWatchdog();
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    if (client.state is! SocketAuthenticated) {
      _log.w('[Diamond] spin khi socket chưa sống → ensureConnected + bỏ lượt');
      _spinWatchdog?.cancel();
      _autoTimer?.cancel();
      state = state.copyWith(
        spinning: false,
        animating: false,
      );
      unawaited(client.ensureConnected());
      return;
    }
    KimCuongSender(client).spin(
      bet: state.selectedBet,
      accountId: state.accountId,
      lines: state.selectedLines,
    );
  }

  void debugShowJackpot() {
    if (state.jackpotWin > 0) return;
    final amount = state.jackpot > 0 ? state.jackpot : 200000000;
    state = state.copyWith(jackpotWin: amount);
  }

  void dismissJackpot() {
    if (state.jackpotWin == 0) return;
    state = state.copyWith(jackpotWin: 0);
    if (state.autoSpin && !state.spinning) {
      _autoTimer = Timer(_autoGap, () {
        if (mounted && state.autoSpin) spin();
      });
    }
  }

  void _maybeAutoNext() {
    if (!state.autoSpin) return;
    if (state.jackpotWin > 0) return;
    _autoTimer?.cancel();
    _autoTimer = Timer(_autoGap, () {
      if (mounted && state.autoSpin && !state.spinning) spin();
    });
  }

  void _startSpinWatchdog() {
    _spinWatchdog?.cancel();
    _spinWatchdog = Timer(_maxSpin, () {
      if (!mounted || !state.spinning) return;
      _log.w('[Diamond] spin watchdog → chưa nhận kết quả, tắt quay');
      _animTimer?.cancel();
      state = state.copyWith(spinning: false, animating: false);
      _refreshAppBalance();
    });
  }

  void _scheduleAnimDone() {
    _animTimer?.cancel();
    _animTimer = Timer(_animSettleDelay, () {
      if (!mounted) return;
      state = state.copyWith(animating: false);
    });
  }

  void _scheduleReveal(void Function() apply) {
    _spinWatchdog?.cancel();
    _revealTimer?.cancel();
    _revealTimer = Timer(_revealDelay, () {
      if (!mounted) return;
      apply();
    });
  }

  void _refreshAppBalance() {
    _ref.read(userProvider.notifier).refreshBalance();
  }

  Future<void> _unsubscribeJackpot() async {
    try {
      final client = await _ref.read(miniGameSocketClientProvider.future);
      KimCuongSender(client).unsubscribe();
    } catch (_) {
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _spinWatchdog?.cancel();
    _autoTimer?.cancel();
    _animTimer?.cancel();
    _sub?.close();
    _socketStateSub?.close();
    _unsubscribeJackpot();
    super.dispose();
  }
}

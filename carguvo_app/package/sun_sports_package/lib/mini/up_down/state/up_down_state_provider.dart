import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/features/mini_game/messages/common/jackpot_data.dart';
import 'package:sun_sports/features/mini_game/messages/mini_game_message_streams.dart';
import 'package:sun_sports/features/mini_game/messages/mini_game_senders.dart';
import 'package:sun_sports/features/mini_game/messages/tren_duoi_message.dart';
import 'package:sun_sports/features/mini_game/messages/up_down_message_keys.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_client.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_state.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state.dart';

final upDownStateProvider =
    StateNotifierProvider.autoDispose<UpDownNotifier, UpDownState>(
  (ref) {
    final scopes = ref.watch(miniGameActiveScopesProvider);
    scopes.retainTrenDuoi();
    ref.onDispose(scopes.releaseTrenDuoi);
    return UpDownNotifier(ref);
  },
);

class UpDownNotifier extends StateNotifier<UpDownState> {
  final Ref _ref;
  final Logger _log = Logger();
  ProviderSubscription<AsyncValue<TrenDuoiMessage>>? _sub;

  ProviderSubscription<AsyncValue<MiniGameSocketState>>? _socketStateSub;
  MiniGameSocketState? _lastSocketState;

  Timer? _resetTimer;

  static const Duration _gameOverDelay = Duration(seconds: 3);

  Timer? _spinWatchdog;
  static const Duration _maxSpin = Duration(seconds: 8);

  Timer? _revealTimer;
  static const Duration _revealDelay = Duration(seconds: 1);

  UpDownNotifier(this._ref) : super(const UpDownState()) {
    _listen();
    _listenSocketState();
    subscribe();
  }

  Future<void> subscribe() async {
    _log.i('[UpDown] subscribe → gửi INFO_GAME (${UpDownMsg.infoGame})');
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TrenDuoiSender(client).subscribe();
  }

  void _listen() {
    _sub = _ref.listen<AsyncValue<TrenDuoiMessage>>(
      trenDuoiMessageStreamProvider,
      (_, next) {
        next.whenData(_handle);
        if (next.hasError) {
          _log.e('[UpDown] stream error', error: next.error);
        }
      },
    );
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
    _log.w('[UpDown] socket rớt → gỡ kẹt lượt quay');
    _spinWatchdog?.cancel();
    _revealTimer?.cancel();
    if (state.spinning) {
      state = state.copyWith(spinning: false);
    }
  }

  void _onSocketReauthenticated() {
    _log.i('[UpDown] socket sống lại → subscribe lại (INFO_GAME)');
    subscribe();
  }

  void _handle(TrenDuoiMessage msg) {
    _logMessage(msg);
    switch (msg) {
      case TrenDuoiInfoGame(
          :final up,
          :final down,
          :final jackpots,
          :final remainingTimeMs,
          :final hasSession,
          :final sessionId,
          :final credit,
          :final history,
          :final bet,
        ):
        if (hasSession) {
          if (bet > 0) state = state.copyWith(selectedBet: bet);
          state = state.copyWith(
            upPayout: up,
            downPayout: down,
            credit: credit,
            sessionId: sessionId ?? state.sessionId,
            history: history,
            locked: false,
            jackpot: _pickJackpot(jackpots),
            jackpots: jackpots,
            remainingMs: remainingTimeMs,
            timerDeadlineMs: remainingTimeMs > 0
                ? DateTime.now().millisecondsSinceEpoch + remainingTimeMs
                : _deadlineIn(kUpDownRoundSeconds),
          );
        } else {
          state = state.copyWith(
            upPayout: up,
            downPayout: down,
            sessionId: 0,
            history: const [],
            locked: false,
            jackpot: _pickJackpot(jackpots),
            jackpots: jackpots,
            remainingMs: remainingTimeMs,
            timerDeadlineMs: 0,
          );
        }
      case TrenDuoiStartGame(
          :final errorMessage,
          :final up,
          :final down,
          :final credit,
          :final sessionId,
          :final cardCode,
        ):
        if (errorMessage != null) {
          _revealTimer?.cancel();
          state = state.copyWith(spinning: false, timerDeadlineMs: 0);
          return;
        }
        _scheduleReveal(() {
          state = state.copyWith(
            upPayout: up ?? 0,
            downPayout: down ?? 0,
            credit: credit ?? 0,
            sessionId: sessionId ?? state.sessionId,
            isJackpot: false,
            locked: false,
            spinning: false,
            history: cardCode != null ? [cardCode] : const [],
            timerDeadlineMs: _deadlineIn(kUpDownRoundSeconds),
          );
          _refreshAppBalance();
        });
      case TrenDuoiStartRound(
          :final up,
          :final down,
          :final credit,
          :final sessionId,
          :final isJackpot,
          :final jackpot,
          :final cardCode,
          :final isFree,
          :final nextGame,
        ):
        _scheduleReveal(() {
          final prevCredit = state.credit;
          state = state.copyWith(
            upPayout: up,
            downPayout: down,
            credit: credit,
            sessionId: sessionId,
            isJackpot: isJackpot,
            jackpot: isJackpot && jackpot > 0 ? jackpot : state.jackpot,
            history: [...state.history, cardCode],
            locked: isFree || nextGame,
            spinning: false,
            timerDeadlineMs:
                (isFree || nextGame) ? 0 : _deadlineIn(kUpDownRoundSeconds),
            jackpotWin: isJackpot && jackpot > 0 ? jackpot : state.jackpotWin,
          );
          _refreshAppBalance();
          if (isFree && !isJackpot) {
            state = state.copyWith(loseTick: state.loseTick + 1);
          } else if (!isJackpot && credit > prevCredit) {
            SoundEffects.instance.playMiniGame(MiniGameSound.winSfx);
          }
          if (isFree || nextGame) _scheduleReset();
        });
      case TrenDuoiStopGame(:final credit):
        state = state.copyWith(
          credit: credit,
          sessionId: 0,
          history: const [],
          locked: false,
          spinning: false,
          timerDeadlineMs: 0,
          cashoutWin: credit > 0 ? credit : 0,
        );
        _refreshAppBalance();
      case TrenDuoiUpdateJar(:final jackpots):
        state = state.copyWith(
          jackpot: _pickJackpot(jackpots),
          jackpots: jackpots,
        );
    }
  }

  int _pickJackpot(List<JackpotData> jars) {
    if (jars.isEmpty) return state.jackpot;
    final match = jars.where(
      (j) => j.accountId == 1 && j.bet == state.selectedBet,
    );
    if (match.isNotEmpty) return match.first.jackpot;
    final aid1 = jars.where((j) => j.accountId == 1);
    return (aid1.isNotEmpty ? aid1.first : jars.first).jackpot;
  }

  void _logMessage(TrenDuoiMessage msg) {
    if (!kDebugMode) return;
    final desc = switch (msg) {
      TrenDuoiInfoGame(:final up, :final down, :final remainingTimeMs, :final hasSession) =>
        'INFO_GAME up=$up down=$down rmT=$remainingTimeMs '
            'jars=${msg.jackpots.length} '
            '${hasSession ? "restore(cards=${msg.history.length} credit=${msg.credit})" : "noSession"}',
      TrenDuoiStartGame(:final errorMessage, :final up, :final down, :final credit) =>
        errorMessage != null
            ? 'START_GAME error="$errorMessage"'
            : 'START_GAME up=$up down=$down credit=$credit',
      TrenDuoiStartRound(
        :final up,
        :final down,
        :final credit,
        :final isFree,
        :final isJackpot,
        :final jackpot,
      ) =>
        'START_ROUND up=$up down=$down credit=$credit over=$isFree '
            'jackpot=${isJackpot ? jackpot : 0}',
      TrenDuoiStopGame(:final credit) => 'STOP_GAME credit=$credit',
      TrenDuoiUpdateJar(:final jackpots) => 'UPDATE_JAR jars=${jackpots.length}',
    };
    _log.i('[UpDown] recv $desc');
  }

  int _deadlineIn(int seconds) =>
      DateTime.now().millisecondsSinceEpoch + seconds * 1000;

  void setBet(int bet) {
    if (state.spinning ||
        state.sessionId != 0 ||
        bet == state.selectedBet) {
      return;
    }
    state = state.copyWith(selectedBet: bet);
    state = state.copyWith(jackpot: _pickJackpot(state.jackpots));
  }

  Future<void> startGame({required int bet}) async {
    if (state.spinning) return;
    state = state.copyWith(spinning: true, timerDeadlineMs: 0);
    _startSpinWatchdog();
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    if (!_ensureSocketOrAbort(client)) return;
    TrenDuoiSender(client).startGame(bet: bet);
  }

  Future<void> pickUp({required int bet}) => _pick(bet, UpDownDir.up);
  Future<void> pickDown({required int bet}) => _pick(bet, UpDownDir.down);

  Future<void> _pick(int bet, int dir) async {
    if (state.sessionId == 0 || state.spinning) return;
    state = state.copyWith(spinning: true, timerDeadlineMs: 0);
    _startSpinWatchdog();
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    if (!_ensureSocketOrAbort(client)) return;
    TrenDuoiSender(client)
        .startRound(bet: bet, sessionId: state.sessionId, upDown: dir);
  }

  bool _ensureSocketOrAbort(MiniGameSocketClient client) {
    if (client.state is SocketAuthenticated) return true;
    _log.w('[UpDown] thao tác khi socket chưa sống → ensureConnected + bỏ lệnh');
    _spinWatchdog?.cancel();
    if (state.spinning) state = state.copyWith(spinning: false);
    unawaited(client.ensureConnected());
    return false;
  }

  void _startSpinWatchdog() {
    _spinWatchdog?.cancel();
    _spinWatchdog = Timer(_maxSpin, () {
      if (!mounted || !state.spinning) return;
      _log.w('[UpDown] spin watchdog → chưa nhận kết quả, tắt quay');
      state = state.copyWith(spinning: false);
      _refreshAppBalance();
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

  void debugShowJackpot() {
    if (state.jackpotWin > 0) return;
    final amount = state.jackpot > 0 ? state.jackpot : 200000000;
    state = state.copyWith(jackpotWin: amount);
  }

  void dismissJackpot() {
    if (state.jackpotWin == 0) return;
    state = state.copyWith(jackpotWin: 0);
  }

  void clearCashoutWin() {
    if (state.cashoutWin == 0) return;
    state = state.copyWith(cashoutWin: 0);
  }

  void _refreshAppBalance() {
    _ref.read(userProvider.notifier).refreshBalance();
  }

  Future<void> cashout() async {
    if (state.sessionId == 0) return;
    _resetTimer?.cancel();
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    if (!_ensureSocketOrAbort(client)) return;
    TrenDuoiSender(client).stopGame(sessionId: state.sessionId);
  }

  void _scheduleReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(_gameOverDelay, () {
      if (!mounted) return;
      subscribe();
    });
  }

  @override
  void dispose() {
    _log.i('[UpDown] dispose → huỷ lắng nghe message (đóng game)');
    _resetTimer?.cancel();
    _spinWatchdog?.cancel();
    _revealTimer?.cancel();
    _sub?.close();
    _socketStateSub?.close();
    super.dispose();
  }
}

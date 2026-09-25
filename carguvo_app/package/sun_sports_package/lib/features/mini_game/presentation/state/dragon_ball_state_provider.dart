import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_symbols.dart';

import '../../messages/mini_game_message_streams.dart';
import '../../messages/mini_game_senders.dart';
import '../../messages/slot_message.dart';
import '../../socket/mini_game_socket_providers.dart';
import '../../socket/mini_game_socket_state.dart';
import 'mini_game_bet_options.dart';

enum DragonBallToastKind { success, error, info }

class DragonBallToast {
  final DragonBallToastKind kind;
  final String message;

  const DragonBallToast.success(this.message)
      : kind = DragonBallToastKind.success;
  const DragonBallToast.error(this.message) : kind = DragonBallToastKind.error;
  const DragonBallToast.info(this.message) : kind = DragonBallToastKind.info;
}

const List<int> kDragonBallEntrySymbols = [
  8, 3, 0, 5, 6,
  1, 7, 3, 8, 8,
  8, 2, 0, 5, 6,
];

class DragonBallState {
  final int bet;

  final int jackpot;

  final bool isSpinning;

  final bool autoSpin;

  final bool turbo;

  final List<int> boardSymbols;

  final List<int> winLineIds;

  final List<List<int>> winLineRows;

  final Set<int> winCells;

  final bool winDimAll;

  final int winAnimToken;

  final int jackpotToken;

  final int jackpotAmount;

  final bool jackpotActive;

  final int jackpotWin;

  final bool wonJackpot;

  final bool bigWin;

  final int lastWin;

  final int winBannerToken;

  final int? freeSpins;

  final int spinStartToken;

  final int resultToken;

  final String? error;

  const DragonBallState({
    this.bet = 100,
    this.jackpot = 0,
    this.isSpinning = false,
    this.autoSpin = false,
    this.turbo = false,
    this.boardSymbols = kDragonBallEntrySymbols,
    this.winLineIds = const [],
    this.winLineRows = const [],
    this.winCells = const {},
    this.winDimAll = false,
    this.winAnimToken = 0,
    this.jackpotToken = 0,
    this.jackpotAmount = 0,
    this.jackpotActive = false,
    this.jackpotWin = 0,
    this.wonJackpot = false,
    this.bigWin = false,
    this.lastWin = 0,
    this.winBannerToken = 0,
    this.freeSpins,
    this.spinStartToken = 0,
    this.resultToken = 0,
    this.error,
  });

  DragonBallState copyWith({
    int? bet,
    int? jackpot,
    bool? isSpinning,
    bool? autoSpin,
    bool? turbo,
    List<int>? boardSymbols,
    List<int>? winLineIds,
    List<List<int>>? winLineRows,
    Set<int>? winCells,
    bool? winDimAll,
    int? winAnimToken,
    int? jackpotToken,
    int? jackpotAmount,
    bool? jackpotActive,
    int? jackpotWin,
    bool? wonJackpot,
    bool? bigWin,
    int? lastWin,
    int? winBannerToken,
    Object? freeSpins = _sentinel,
    int? spinStartToken,
    int? resultToken,
    Object? error = _sentinel,
  }) {
    return DragonBallState(
      bet: bet ?? this.bet,
      jackpot: jackpot ?? this.jackpot,
      isSpinning: isSpinning ?? this.isSpinning,
      autoSpin: autoSpin ?? this.autoSpin,
      turbo: turbo ?? this.turbo,
      boardSymbols: boardSymbols ?? this.boardSymbols,
      winLineIds: winLineIds ?? this.winLineIds,
      winLineRows: winLineRows ?? this.winLineRows,
      winCells: winCells ?? this.winCells,
      winDimAll: winDimAll ?? this.winDimAll,
      winAnimToken: winAnimToken ?? this.winAnimToken,
      jackpotToken: jackpotToken ?? this.jackpotToken,
      jackpotAmount: jackpotAmount ?? this.jackpotAmount,
      jackpotActive: jackpotActive ?? this.jackpotActive,
      jackpotWin: jackpotWin ?? this.jackpotWin,
      wonJackpot: wonJackpot ?? this.wonJackpot,
      bigWin: bigWin ?? this.bigWin,
      lastWin: lastWin ?? this.lastWin,
      winBannerToken: winBannerToken ?? this.winBannerToken,
      freeSpins:
          identical(freeSpins, _sentinel) ? this.freeSpins : freeSpins as int?,
      spinStartToken: spinStartToken ?? this.spinStartToken,
      resultToken: resultToken ?? this.resultToken,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final dragonBallTurboProvider = StateProvider<bool>((ref) => false);

final dragonBallAutoProvider = StateProvider<bool>((ref) => false);

final dragonBallBetProvider =
    StateProvider<int>((ref) => const DragonBallState().bet);

class DragonBallLineTable {
  final List<int> ids;
  final List<List<int>> poss;

  const DragonBallLineTable({this.ids = const [], this.poss = const []});

  bool get isEmpty => ids.isEmpty;

  List<int>? rowsFor(int lid) {
    final i = ids.indexOf(lid);
    if (i >= 0 && i < poss.length && poss[i].length >= 3) return poss[i];
    return null;
  }
}

final dragonBallLineTableProvider =
    StateProvider<DragonBallLineTable>((ref) => const DragonBallLineTable());

final dragonBallStateProvider =
    StateNotifierProvider.autoDispose<DragonBallNotifier, DragonBallState>(
        (ref) {
  final scopes = ref.watch(miniGameActiveScopesProvider);
  scopes.retainSlots();
  ref.onDispose(scopes.releaseSlots);
  return DragonBallNotifier(ref);
});

class DragonBallNotifier extends StateNotifier<DragonBallState>
    with WidgetsBindingObserver {
  final Ref _ref;

  ProviderSubscription<AsyncValue<SlotMessage>>? _subscription;
  ProviderSubscription<AsyncValue<MiniGameSocketState>>? _socketStateSub;

  Timer? _roundTimer;

  Timer? _winTimer;

  Timer? _revealTimer;

  int _perLineIndex = 0;

  Timer? _spinTimeoutTimer;

  Timer? _autoResumeTimer;

  int _pendingMoney = 0;
  bool _pendingJackpot = false;

  bool _awaitingRound = false;

  MiniGameSocketState? _lastSocketState;

  int _aid = 1;

  List<int> _lineIds = const [];

  final Map<String, int> _jackpots = {};

  static const Duration _kSpinTimeout = Duration(seconds: 10);

  static const Duration _kRoundSafety = Duration(seconds: 8);
  static const Duration _kRoundSafetyTurbo = Duration(seconds: 4);

  static const Duration _kPerLineInterval = Duration(milliseconds: 1400);

  static const Duration _kFullLineHold = Duration(milliseconds: 2200);
  static const Duration _kFullLineHoldTurbo = Duration(milliseconds: 400);

  static const Duration _kDimAllGap = Duration(milliseconds: 500);

  static const Duration _kJackpotDuration = Duration(seconds: 5);

  static const Duration _kRevealStep = Duration(milliseconds: 350);

  final StreamController<DragonBallToast> _toastController =
      StreamController<DragonBallToast>.broadcast();
  Stream<DragonBallToast> get toastMessages => _toastController.stream;

  DragonBallNotifier(this._ref) : super(const DragonBallState()) {
    final persistedAuto = _ref.read(dragonBallAutoProvider);
    final persistedBet = _ref.read(dragonBallBetProvider);
    final betValid = kMiniGameBetValues.contains(persistedBet);
    state = state.copyWith(
      turbo: _ref.read(dragonBallTurboProvider),
      autoSpin: persistedAuto,
      bet: betValid ? persistedBet : null,
    );
    if (!betValid) {
      Future.microtask(() {
        if (!mounted) return;
        _ref.read(dragonBallBetProvider.notifier).state = state.bet;
      });
    }
    _listen();
    _listenSocketState();
    WidgetsBinding.instance.addObserver(this);
    subscribeJackpot();
  }

  void _listen() {
    _subscription = _ref.listen<AsyncValue<SlotMessage>>(
      slotMessageStreamProvider(SlotGameId.dragonBall),
      (_, next) {
        next.whenData(_handleMessage);
        if (next.hasError) {
          AppLoggers.websocket.e(
            '[DragonBall] stream error',
            error: next.error,
          );
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
        final droppedNow =
            prev is SocketAuthenticated && socketState is! SocketAuthenticated;
        final reauthedNow =
            prev is! SocketAuthenticated && socketState is SocketAuthenticated;
        if (droppedNow) {
          _onDisconnected();
        } else if (reauthedNow) {
          _onReauthenticated();
        }
      },
      fireImmediately: true,
    );
  }

  void _onDisconnected() {
    if (state.isSpinning && !_awaitingRound) {
      _log('MẤT KẾT NỐI → dừng máy (auto giữ nguyên, resume khi reconnect)');
      _unstickSpin(reason: 'socket dropped');
    }
  }

  void _onReauthenticated() {
    AppLoggers.websocket
        .i('[DragonBall] socket sống lại → re-subscribe (cmd 1300)');
    subscribeJackpot();
  }

  void _unstickSpin({required String reason}) {
    AppLoggers.websocket.w(
      '[DragonBall] unstick spin ($reason) → dừng reel + mở lại nút (giữ auto)',
    );
    _spinTimeoutTimer?.cancel();
    state = state.copyWith(
      isSpinning: false,
      resultToken: state.resultToken + 1,
    );
  }

  Future<void> subscribeJackpot() async {
    AppLoggers.websocket
        .i('[DragonBall] subscribe jackpot cmd=1300 bet=${state.bet}');
    final client = await _ref.read(miniGameSocketClientProvider.future);
    DragonBallSender(client).subscribe();
  }

  Future<void> _unsubscribeJackpot() async {
    try {
      final client = await _ref.read(miniGameSocketClientProvider.future);
      DragonBallSender(client).unsubscribe();
    } catch (_) {
    }
  }

  void _setLines(List<dynamic> lines) {
    final ids = <int>[];
    final poss = <List<int>>[];
    for (final l in lines) {
      if (l is! Map) continue;
      final lid = l['lid'];
      if (lid is! num) continue;
      ids.add(lid.toInt());
      final p = l['poss'];
      poss.add(
        p is List
            ? p.whereType<num>().map((e) => e.toInt()).toList(growable: false)
            : const <int>[],
      );
    }
    _lineIds = ids;
    _ref.read(dragonBallLineTableProvider.notifier).state =
        DragonBallLineTable(ids: ids, poss: poss);
    AppLoggers.websocket.i(
      '[DragonBall] LINE TABLE (${ids.length} line): '
      '${[for (var i = 0; i < ids.length; i++) '${ids[i]}:${poss[i]}'].join(' · ')}',
    );
  }

  List<int>? lineRowsFor(int lid) {
    final table = _ref.read(dragonBallLineTableProvider);
    if (!table.isEmpty) return table.rowsFor(lid);
    if (lid >= 0 && lid < kDragonBallLineTable.length) {
      return kDragonBallLineTable[lid];
    }
    return null;
  }

  void selectBet(int value) {
    if (state.isSpinning || state.autoSpin) {
      _toastController.add(const DragonBallToast.info('Đang Quay'));
      return;
    }
    _cancelWinAnim();
    state = state.copyWith(
      bet: value,
      jackpot: _jackpotFor(value),
      boardSymbols: kDragonBallEntrySymbols,
      winLineIds: const [],
      winLineRows: const [],
      winCells: const {},
      winDimAll: false,
      winAnimToken: state.winAnimToken + 1,
      jackpotActive: false,
      wonJackpot: false,
      bigWin: false,
      resultToken: state.resultToken + 1,
    );
    _ref.read(dragonBallBetProvider.notifier).state = value;
    _log('Đổi mức cược → $value');
    subscribeJackpot();
  }

  void setTurbo(bool value) {
    _ref.read(dragonBallTurboProvider.notifier).state = value;
    state = state.copyWith(turbo: value);
    _log('Siêu tốc: ${value ? 'BẬT' : 'TẮT'}');
  }

  void setAuto(bool value) {
    _ref.read(dragonBallAutoProvider.notifier).state = value;
    state = state.copyWith(autoSpin: value);
    _log('Tự quay: ${value ? 'BẬT' : 'TẮT'}');
    if (value && !state.isSpinning) {
      spin();
    }
  }

  Future<void> spin() async {
    if (state.isSpinning) {
      _toastController.add(const DragonBallToast.info('Đang Quay'));
      return;
    }
    if (_lineIds.isEmpty) {
      _toastController.add(const DragonBallToast.info('Vui lòng chọn dòng'));
      _log('SPIN bị chặn: chưa nhận danh sách line từ server (cmd 1300)');
      return;
    }
    final balance = _ref.read(userProvider).user?.balanceInVND;
    if (balance != null && balance < state.bet * _lineIds.length) {
      if (_ref.read(dragonBallAutoProvider)) {
        _ref.read(dragonBallAutoProvider.notifier).state = false;
      }
      state = state.copyWith(autoSpin: false);
      _toastController.add(
        const DragonBallToast.error('Số dư không đủ để đặt cược'),
      );
      _log('SPIN bị chặn: số dư $balance < tổng cược '
          '${state.bet * _lineIds.length} (${state.bet} × ${_lineIds.length} '
          'line)');
      return;
    }
    _cancelWinAnim();
    state = state.copyWith(
      isSpinning: true,
      error: null,
      winLineIds: const [],
      winLineRows: const [],
      winCells: const {},
      winDimAll: false,
      winAnimToken: state.winAnimToken + 1,
      jackpotActive: false,
      wonJackpot: false,
      bigWin: false,
      spinStartToken: state.spinStartToken + 1,
    );
    _log('SPIN → b=${state.bet} aid=$_aid ls=${_lineIds.length} line');
    AppLoggers.websocket.i(
      '[DragonBall] spin cmd=1302 bet=${state.bet} aid=$_aid '
      'lines=${_lineIds.length}',
    );
    _spinTimeoutTimer?.cancel();
    _spinTimeoutTimer = Timer(_kSpinTimeout, _onSpinTimeout);
    final client = await _ref.read(miniGameSocketClientProvider.future);
    DragonBallSender(client)
        .spin(bet: state.bet, accountId: _aid, lines: _lineIds);
  }

  void _onSpinTimeout() {
    if (!state.isSpinning || _awaitingRound) return;
    _log('TIMEOUT: server không phản hồi spin sau '
        '${_kSpinTimeout.inSeconds}s → dừng máy (giữ auto)');
    _toastController
        .add(const DragonBallToast.error('Mất phản hồi từ máy chủ'));
    _unstickSpin(reason: 'spin timeout ${_kSpinTimeout.inSeconds}s');
    _ref.read(userProvider.notifier).refreshBalance();
  }

  void _handleMessage(SlotMessage message) {
    switch (message) {
      case SlotSubscribeJackpot(:final jackpots, :final lines):
        AppLoggers.websocket.i(
          '[DragonBall] subscribe_jackpot jackpots=${jackpots.length} '
          'lines=${lines?.length}',
        );
        if (state.isSpinning && !_awaitingRound) {
          _log('RECONNECT giữa ván → kết quả xem tại Lịch sử cược');
          _unstickSpin(reason: 'reconnect while spinning');
        }
        if (lines != null && lines.isNotEmpty) {
          _setLines(lines);
        }
        _jackpots.clear();
        for (final j in jackpots) {
          _jackpots['${j.accountId}:${j.bet}'] = j.jackpot;
        }
        state = state.copyWith(jackpot: _jackpotFor(state.bet));
        _log('SUBSCRIBE OK: ${_lineIds.length} line, '
            'hũ=${MoneyFormatter.formatWithCommas(state.jackpot)}');
        if (state.autoSpin &&
            !state.isSpinning &&
            !_awaitingRound &&
            _lastSocketState is SocketAuthenticated) {
          _autoResumeTimer?.cancel();
          _autoResumeTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted &&
                state.autoSpin &&
                !state.isSpinning &&
                !_awaitingRound &&
                _lastSocketState is SocketAuthenticated) {
              spin();
            }
          });
        }
      case SlotUpdateJackpot(:final jackpots):
        for (final j in jackpots) {
          _jackpots['${j.accountId}:${j.bet}'] = j.jackpot;
        }
        state = state.copyWith(jackpot: _jackpotFor(state.bet));
      case SlotSpinResult(
          :final errorMessage,
          :final accountId,
          :final moneyExchange,
          :final symbols,
          :final rewards,
          :final sessionId,
          :final freeSpins,
        ):
        _handleSpinResult(
          errorMessage: errorMessage,
          accountId: accountId,
          moneyExchange: moneyExchange,
          symbols: symbols,
          rewards: rewards,
          sessionId: sessionId,
          freeSpins: freeSpins,
        );
    }
  }

  void _handleSpinResult({
    required String? errorMessage,
    required int? accountId,
    required int moneyExchange,
    required List<dynamic> symbols,
    required List<dynamic> rewards,
    required int? sessionId,
    required int? freeSpins,
  }) {
    _spinTimeoutTimer?.cancel();

    AppLoggers.websocket.i(
      '[DragonBall] SPIN_RESULT raw: aid=$accountId mX=$moneyExchange '
      'sid=$sessionId fss=$freeSpins sbs=$symbols wls=$rewards '
      'mgs=$errorMessage',
    );

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _cancelRound();
      _ref.read(dragonBallAutoProvider.notifier).state = false;
      state = state.copyWith(
        isSpinning: false,
        autoSpin: false,
        error: errorMessage,
        resultToken: state.resultToken + 1,
      );
      _log('LỖI SERVER: $errorMessage');
      _toastController.add(DragonBallToast.error(errorMessage));
      AppLoggers.websocket.w('[DragonBall] spin rejected: $errorMessage');
      return;
    }

    if (!state.isSpinning) {
      _log('KQ về sau khi máy đã dừng (sid=$sessionId) → bỏ qua, '
          'xem Lịch sử cược');
      _ref.read(userProvider.notifier).refreshBalance();
      return;
    }

    if (accountId != null) _aid = accountId;

    final board = symbols
        .whereType<num>()
        .map((c) => c.toInt())
        .toList(growable: false);

    final winIds = <int>[];
    var wonJackpot = false;
    for (final r in rewards) {
      if (r is! Map) continue;
      final lid = r['lid'];
      if (lid is num) winIds.add(lid.toInt());
      if (r['iJ'] == true) wonJackpot = true;
    }
    final bigWin = moneyExchange > 100 * state.bet;

    _pendingMoney = moneyExchange;
    _pendingJackpot = wonJackpot;
    _awaitingRound = true;

    state = state.copyWith(
      boardSymbols: board.length == 15 ? board : state.boardSymbols,
      winLineIds: winIds,
      wonJackpot: wonJackpot,
      bigWin: bigWin,
      lastWin: moneyExchange,
      freeSpins: freeSpins,
      resultToken: state.resultToken + 1,
      error: null,
    );

    _logResult(
      sessionId: sessionId,
      moneyExchange: moneyExchange,
      board: board,
      winIds: winIds,
      wonJackpot: wonJackpot,
      bigWin: bigWin,
      freeSpins: freeSpins,
    );

    _roundTimer?.cancel();
    _roundTimer = Timer(
      state.turbo ? _kRoundSafetyTurbo : _kRoundSafety,
      _completeRound,
    );
  }

  void onRoundDone() => _completeRound();

  void _completeRound() {
    if (!_awaitingRound) return;
    _awaitingRound = false;
    _roundTimer?.cancel();
    final money = _pendingMoney;
    final jackpot = _pendingJackpot;

    state = state.copyWith(isSpinning: false);
    _announceResult(money, jackpot);
    _ref.read(userProvider.notifier).refreshBalance();
    if (jackpot) {
      _startJackpot(money);
    } else {
      _startWinAnim(hasWin: money > 0);
    }
  }

  void _startJackpot(int amount) {
    _cancelWinAnim();
    state = state.copyWith(
      winLineRows: const [],
      winCells: const {},
      winDimAll: false,
      winAnimToken: state.winAnimToken + 1,
      jackpotAmount: amount,
      jackpotActive: true,
      jackpotToken: state.jackpotToken + 1,
      jackpotWin: amount,
    );
    _log('JACKPOT: fire anim + đếm số → '
        '${MoneyFormatter.formatWithCommas(amount)}');
    _winTimer?.cancel();
    _winTimer = Timer(_kJackpotDuration, _finishJackpot);
  }

  void _finishJackpot() {
    state = state.copyWith(jackpotActive: false);
    _log('JACKPOT xong');
    if (state.jackpotWin > 0) return;
    if (state.autoSpin) _autoNext();
  }

  void debugShowJackpot() {
    if (state.jackpotWin > 0) return;
    final amount = state.jackpot > 0 ? state.jackpot : 200000000;
    state = state.copyWith(jackpotWin: amount);
  }

  void dismissJackpot() {
    if (state.jackpotWin == 0) return;
    state = state.copyWith(jackpotWin: 0);
    if (state.autoSpin) _autoNext();
  }

  void _startWinAnim({required bool hasWin}) {
    _cancelWinAnim();
    final lineIds = state.winLineIds;
    if (!hasWin || lineIds.isEmpty) {
      _setWinDisplay(const [], const {});
      if (state.autoSpin) {
        _winTimer = Timer(
          state.turbo ? const Duration(milliseconds: 150) : _kFullLineHoldTurbo,
          _autoNext,
        );
      }
      return;
    }

    _setWinDisplay(_rowsForLines(lineIds), _cellsForLines(lineIds));

    final hold = state.turbo ? _kFullLineHoldTurbo : _kFullLineHold;
    _winTimer = Timer(hold, () {
      if (state.autoSpin) {
        _autoNext();
        return;
      }
      if (state.turbo) return;
      _setWinDisplay(const [], const {}, dimAll: true);
      _winTimer = Timer(_kDimAllGap, () => _startPerLineLoop(lineIds));
    });
  }

  void _startPerLineLoop(List<int> lineIds) {
    _perLineIndex = 0;
    _showPerLine(lineIds);
    _winTimer = Timer.periodic(_kPerLineInterval, (t) {
      if (_perLineIndex >= lineIds.length - 1) {
        t.cancel();
        _winTimer = null;
        return;
      }
      _perLineIndex++;
      _showPerLine(lineIds);
    });
  }

  void _showPerLine(List<int> lineIds) {
    final lid = lineIds[_perLineIndex];
    final rows = lineRowsFor(lid);
    if (rows == null || rows.length < 3) {
      _setWinDisplay(const [], _cellsForLines([lid]));
      return;
    }
    int cellAt(int col) => rows[col] * 5 + col;
    _revealTimer?.cancel();
    _setWinDisplay(const [], {cellAt(0)});
    var step = 0;
    _revealTimer = Timer.periodic(_kRevealStep, (t) {
      step++;
      _setWinDisplay(
        [rows.sublist(0, step + 1)],
        {for (var c = 0; c <= step; c++) cellAt(c)},
      );
      if (step >= 2) {
        t.cancel();
        _revealTimer = null;
      }
    });
  }

  List<List<int>> _rowsForLines(List<int> lineIds) => lineIds
      .map(lineRowsFor)
      .whereType<List<int>>()
      .toList(growable: false);

  void _setWinDisplay(List<List<int>> rows, Set<int> cells,
      {bool dimAll = false}) {
    _log('WIN-ANIM: rows=${rows.isEmpty ? '—' : rows.join('|')} '
        'cells=${cells.length}${dimAll ? ' DIM-ALL' : ''}');
    state = state.copyWith(
      winLineRows: rows,
      winCells: cells,
      winDimAll: dimAll,
      winAnimToken: state.winAnimToken + 1,
    );
  }

  Set<int> _cellsForLines(List<int> lineIds) {
    final cells = <int>{};
    for (final lid in lineIds) {
      final rows = lineRowsFor(lid);
      if (rows == null) continue;
      for (var col = 0; col < 3 && col < rows.length; col++) {
        cells.add(rows[col] * 5 + col);
      }
    }
    return cells;
  }

  void _cancelWinAnim() {
    _winTimer?.cancel();
    _winTimer = null;
    _revealTimer?.cancel();
    _revealTimer = null;
  }

  void _autoNext() {
    if (state.autoSpin && !state.isSpinning) spin();
  }

  void _cancelRound() {
    _roundTimer?.cancel();
    _spinTimeoutTimer?.cancel();
    _cancelWinAnim();
    _awaitingRound = false;
  }

  void _announceResult(int moneyExchange, bool wonJackpot) {
    if (moneyExchange <= 0 && !wonJackpot) return;
    state = state.copyWith(winBannerToken: state.winBannerToken + 1);
  }

  int _jackpotFor(int bet) => _jackpots['$_aid:$bet'] ?? 0;

  void _log(String message) => AppLoggers.ui.d('[DragonBall] $message');

  void _logResult({
    required int? sessionId,
    required int moneyExchange,
    required List<int> board,
    required List<int> winIds,
    required bool wonJackpot,
    required bool bigWin,
    required int? freeSpins,
  }) {
    final buf = StringBuffer()
      ..write('KQ')
      ..write(sessionId != null ? ' #$sessionId' : '')
      ..write(': mX=${MoneyFormatter.formatWithCommas(moneyExchange)}')
      ..write(' · line trúng=${winIds.isEmpty ? '—' : winIds.join(',')}');
    if (wonJackpot) buf.write(' · NỔ HŨ');
    if (bigWin) buf.write(' · BIG WIN');
    if (freeSpins != null && freeSpins > 0) buf.write(' · fss=$freeSpins');
    _log(buf.toString());
    if (board.length == 15) {
      for (var row = 0; row < 3; row++) {
        final names = List.generate(5, (col) {
          final display = dragonBallDecodeSymbol(board[row * 5 + col]);
          return dragonBallSymbolName(display);
        });
        _log('  ${names.sublist(0, 3).join(' ')} | '
            '${names.sublist(3).join(' ')}');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (kIsWeb) return;
    if (lifecycle != AppLifecycleState.paused) return;
    AppLoggers.websocket
        .i('[DragonBall] app paused (native) → tắt auto (parity JS EVENT_HIDE)');
    _log('APP XUỐNG NỀN → tắt tự quay (parity JS EVENT_HIDE)');
    if (_ref.read(dragonBallAutoProvider)) {
      _ref.read(dragonBallAutoProvider.notifier).state = false;
    }
    if (state.autoSpin) {
      state = state.copyWith(autoSpin: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.close();
    _socketStateSub?.close();
    _roundTimer?.cancel();
    _winTimer?.cancel();
    _revealTimer?.cancel();
    _spinTimeoutTimer?.cancel();
    _autoResumeTimer?.cancel();
    _unsubscribeJackpot();
    _toastController.close();
    super.dispose();
  }
}

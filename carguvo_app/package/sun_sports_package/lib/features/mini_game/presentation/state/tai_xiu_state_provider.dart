import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';

import '../../messages/mini_game_message_streams.dart';
import '../../messages/mini_game_senders.dart';
import '../../messages/tai_xiu_message.dart';
import '../../socket/mini_game_socket_providers.dart';

enum TaiXiuToastKind { success, error, info }

class TaiXiuToast {
  final TaiXiuToastKind kind;
  final String message;

  final MiniGameSound? sound;

  const TaiXiuToast.success(this.message, {this.sound})
    : kind = TaiXiuToastKind.success;
  const TaiXiuToast.error(this.message, {this.sound})
    : kind = TaiXiuToastKind.error;
  const TaiXiuToast.info(this.message, {this.sound})
    : kind = TaiXiuToastKind.info;
}

class TaiXiuChatLine {
  final String name;
  final String message;

  const TaiXiuChatLine({required this.name, required this.message});
}

class TaiXiuSessionBetLine {
  final String username;
  final int createdAt;
  final int amount;
  final int entryId;
  final int refund;

  const TaiXiuSessionBetLine({
    required this.username,
    required this.createdAt,
    required this.amount,
    required this.entryId,
    required this.refund,
  });

  bool get isTai => entryId == 1;
}

class TaiXiuSessionStatsData {
  final int sessionId;
  final int? d1;
  final int? d2;
  final int? d3;
  final int? startTime;
  final List<TaiXiuSessionBetLine> bets;

  const TaiXiuSessionStatsData({
    required this.sessionId,
    required this.d1,
    required this.d2,
    required this.d3,
    required this.startTime,
    required this.bets,
  });

  int? get diceTotal =>
      d1 == null || d2 == null || d3 == null ? null : d1! + d2! + d3!;
}

class TaiXiuBetHistoryLine {
  final int sessionId;
  final int createdAt;
  final int entryId;
  final int d1;
  final int d2;
  final int d3;
  final int amount;
  final int refund;
  final int payout;

  const TaiXiuBetHistoryLine({
    required this.sessionId,
    required this.createdAt,
    required this.entryId,
    required this.d1,
    required this.d2,
    required this.d3,
    required this.amount,
    required this.refund,
    required this.payout,
  });

  int get diceTotal => d1 + d2 + d3;
  bool get isTai => entryId == 1;
  bool get resultTai => diceTotal > 10;
}

class TaiXiuSessionHistoryLine {
  final int? sessionId;
  final int d1;
  final int d2;
  final int d3;

  const TaiXiuSessionHistoryLine({
    required this.sessionId,
    required this.d1,
    required this.d2,
    required this.d3,
  });

  int get diceTotal => d1 + d2 + d3;
  bool get isTai => diceTotal > 10;
}

class TaiXiuSocketState {
  final bool isLoggedIn;
  final int sessionId;
  final int gameState;

  final int remainingTimeSec;

  final int payingTimeSec;

  final bool resultStatic;

  final int taiTotalBet;
  final int xiuTotalBet;
  final int taiThisBet;
  final int xiuThisBet;
  final int taiUsers;
  final int xiuUsers;
  final int availableGold;

  final int winAmount;
  final int? d1;
  final int? d2;
  final int? d3;
  final List<TaiXiuSessionHistoryLine> history;
  final List<TaiXiuSessionHistoryLine> sessionHistory;
  final List<TaiXiuChatLine> chatLines;
  final bool sessionStatsLoading;
  final TaiXiuSessionStatsData? sessionStats;
  final bool betHistoryLoading;
  final List<TaiXiuBetHistoryLine> betHistory;
  final String? error;

  const TaiXiuSocketState({
    this.isLoggedIn = false,
    this.sessionId = 0,
    this.gameState = 0,
    this.remainingTimeSec = 0,
    this.payingTimeSec = 0,
    this.resultStatic = false,
    this.taiTotalBet = 0,
    this.xiuTotalBet = 0,
    this.taiThisBet = 0,
    this.xiuThisBet = 0,
    this.taiUsers = 0,
    this.xiuUsers = 0,
    this.availableGold = 0,
    this.winAmount = 0,
    this.d1,
    this.d2,
    this.d3,
    this.history = const [],
    this.sessionHistory = const [],
    this.chatLines = const [],
    this.sessionStatsLoading = false,
    this.sessionStats,
    this.betHistoryLoading = false,
    this.betHistory = const [],
    this.error,
  });

  int? get diceTotal =>
      d1 == null || d2 == null || d3 == null ? null : d1! + d2! + d3!;

  TaiXiuSocketState copyWith({
    bool? isLoggedIn,
    int? sessionId,
    int? gameState,
    int? remainingTimeSec,
    int? payingTimeSec,
    bool? resultStatic,
    int? taiTotalBet,
    int? xiuTotalBet,
    int? taiThisBet,
    int? xiuThisBet,
    int? taiUsers,
    int? xiuUsers,
    int? availableGold,
    int? winAmount,
    Object? d1 = _sentinel,
    Object? d2 = _sentinel,
    Object? d3 = _sentinel,
    List<TaiXiuSessionHistoryLine>? history,
    List<TaiXiuSessionHistoryLine>? sessionHistory,
    List<TaiXiuChatLine>? chatLines,
    bool? sessionStatsLoading,
    Object? sessionStats = _sentinel,
    bool? betHistoryLoading,
    List<TaiXiuBetHistoryLine>? betHistory,
    Object? error = _sentinel,
  }) {
    return TaiXiuSocketState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      sessionId: sessionId ?? this.sessionId,
      gameState: gameState ?? this.gameState,
      remainingTimeSec: remainingTimeSec ?? this.remainingTimeSec,
      payingTimeSec: payingTimeSec ?? this.payingTimeSec,
      resultStatic: resultStatic ?? this.resultStatic,
      taiTotalBet: taiTotalBet ?? this.taiTotalBet,
      xiuTotalBet: xiuTotalBet ?? this.xiuTotalBet,
      taiThisBet: taiThisBet ?? this.taiThisBet,
      xiuThisBet: xiuThisBet ?? this.xiuThisBet,
      taiUsers: taiUsers ?? this.taiUsers,
      xiuUsers: xiuUsers ?? this.xiuUsers,
      availableGold: availableGold ?? this.availableGold,
      winAmount: winAmount ?? this.winAmount,
      d1: identical(d1, _sentinel) ? this.d1 : d1 as int?,
      d2: identical(d2, _sentinel) ? this.d2 : d2 as int?,
      d3: identical(d3, _sentinel) ? this.d3 : d3 as int?,
      history: history ?? this.history,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      chatLines: chatLines ?? this.chatLines,
      sessionStatsLoading: sessionStatsLoading ?? this.sessionStatsLoading,
      sessionStats: identical(sessionStats, _sentinel)
          ? this.sessionStats
          : sessionStats as TaiXiuSessionStatsData?,
      betHistoryLoading: betHistoryLoading ?? this.betHistoryLoading,
      betHistory: betHistory ?? this.betHistory,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final taiXiuNanActiveProvider = StateProvider<bool>((ref) => false);

final taiXiuNanBowlOpenedProvider = StateProvider<bool>((ref) => false);

final taiXiuSocketStateProvider =
    StateNotifierProvider.autoDispose<TaiXiuSocketNotifier, TaiXiuSocketState>((
      ref,
    ) {
      final scopes = ref.watch(miniGameActiveScopesProvider);
      scopes.retainTaiXiu();
      ref.onDispose(scopes.releaseTaiXiu);
      return TaiXiuSocketNotifier(ref);
    });

class TaiXiuSocketNotifier extends StateNotifier<TaiXiuSocketState> {
  final Ref _ref;
  final Logger _logger = Logger();
  ProviderSubscription<AsyncValue<TaiXiuMessage>>? _subscription;
  Timer? _countdownTimer;

  DateTime? _bettingDeadline;
  DateTime? _payingDeadline;

  static const int kBetLockSec = 6;

  Timer? _diceRevealTimer;
  static const Duration kTraTienCanKeoDelay = Duration(seconds: 3);

  static const Duration kDiceSpinDuration = Duration(milliseconds: 3000);

  final StreamController<TaiXiuToast> _toastController =
      StreamController<TaiXiuToast>.broadcast();
  Stream<TaiXiuToast> get toastMessages => _toastController.stream;

  int _bettingWindowSec = 0;

  int _payingWindowSec = 0;

  TaiXiuSessionHistoryLine? _pendingHistory;

  int? _liveSessionId;

  TaiXiuSocketNotifier(this._ref) : super(const TaiXiuSocketState()) {
    _listen();
    subscribe();
  }

  Future<void> subscribe() async {
    _logger.i('[TaiXiuLogic] subscribe cmd=1005');
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TaiXiuSender(client).subscribe();
  }

  void _refreshAppBalance() {
    _ref.read(userProvider.notifier).refreshBalance();
  }

  bool _pendingWinBalanceRefresh = false;

  void flushWinBalanceRefresh() {
    if (!_pendingWinBalanceRefresh) return;
    _pendingWinBalanceRefresh = false;
    _refreshAppBalance();
  }

  Future<void> betTai({required int amount}) => _bet(entry: 1, amount: amount);

  Future<void> betXiu({required int amount}) => _bet(entry: 2, amount: amount);

  Future<void> sendChat(String message) async {
    final text = message.trim();
    if (text.isEmpty) return;
    _logger.i('[TaiXiuLogic] send_chat length=${text.length}');
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TaiXiuSender(client).sendChat(message: text);
  }

  Future<void> requestSessionAnalytic({int? sessionId}) async {
    final sid = sessionId ?? (state.sessionId > 0 ? state.sessionId - 1 : 0);
    if (sid <= 0) {
      const message = 'Chưa có phiên để xem thống kê';
      state = state.copyWith(error: message);
      _toastController.add(const TaiXiuToast.error(message));
      return;
    }
    _logger.i('[TaiXiuLogic] request_session_analytic session=$sid');
    state = state.copyWith(sessionStatsLoading: true, error: null);
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TaiXiuSender(client).requestSessionAnalytic(sessionId: sid);
  }

  Future<void> requestBetHistory({int limit = 500, int skip = 0}) async {
    _logger.i('[TaiXiuLogic] request_bet_history limit=$limit skip=$skip');
    state = state.copyWith(betHistoryLoading: true, error: null);
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TaiXiuSender(client).requestBetHistory(limit: limit, skip: skip);
  }

  Future<void> _bet({required int entry, required int amount}) async {
    if (state.sessionId == 0) {
      state = state.copyWith(error: 'Chưa có phiên Tài Xỉu để đặt cược');
      _logger.w('[TaiXiuLogic] bet_blocked reason=no_session entry=$entry');
      return;
    }
    final remainingNow = _bettingDeadline != null
        ? _secondsLeft(_bettingDeadline!)
        : state.remainingTimeSec;
    if (remainingNow <= kBetLockSec) {
      const message = 'Đã hết thời gian đặt cược, vui lòng chờ phiên mới';
      state = state.copyWith(error: message);
      _logger.w(
        '[TaiXiuLogic] bet_blocked reason=betting_closed remaining=${remainingNow}s entry=$entry',
      );
      _toastController.add(const TaiXiuToast.error(message));
      return;
    }
    if ((entry == 1 && state.xiuThisBet > 0) ||
        (entry == 2 && state.taiThisBet > 0)) {
      const message = 'Không được đặt cả 2 cửa';
      state = state.copyWith(error: message);
      _logger.w(
        '[TaiXiuLogic] bet_blocked reason=opposite_entry entry=$entry taiThisBet=${state.taiThisBet} xiuThisBet=${state.xiuThisBet}',
      );
      _toastController.add(const TaiXiuToast.error(message));
      return;
    }
    if (amount > state.availableGold) {
      const message = 'Số dư không đủ để đặt cược';
      state = state.copyWith(error: message);
      _logger.w(
        '[TaiXiuLogic] bet_blocked reason=insufficient_balance entry=$entry amount=$amount availableGold=${state.availableGold}',
      );
      _toastController.add(const TaiXiuToast.error(message));
      return;
    }
    _logger.i(
      '[TaiXiuLogic] bet entry=$entry amount=$amount session=${state.sessionId}',
    );
    final client = await _ref.read(miniGameSocketClientProvider.future);
    TaiXiuSender(
      client,
    ).bet(entry: entry, amount: amount, sessionId: state.sessionId);
  }

  void _listen() {
    _subscription = _ref.listen<AsyncValue<TaiXiuMessage>>(
      taiXiuMessageStreamProvider,
      (_, next) {
        next.whenData(_handleMessage);
        if (next.hasError) {
          _logger.e('[TaiXiuSocket] stream error', error: next.error);
          state = state.copyWith(error: next.error.toString());
        }
      },
    );
  }

  void _handleMessage(TaiXiuMessage message) {
    switch (message) {
      case TaiXiuSubscribeInfo():
        _handleSubscribeInfo(message);
      case TaiXiuStartGame(:final sessionId):
        _logger.i(
          '[TaiXiuLogic] start_game session=$sessionId rearm=${_bettingWindowSec}s',
        );
        final flushedHistory = _pendingHistory != null
            ? [
                _pendingHistory!,
                ...state.history,
              ].take(20).toList(growable: false)
            : state.history;
        _pendingHistory = null;
        _diceRevealTimer?.cancel();
        _liveSessionId = sessionId;
        state = state.copyWith(
          isLoggedIn: true,
          sessionId: sessionId,
          remainingTimeSec: _bettingWindowSec,
          payingTimeSec: 0,
          resultStatic: false,
          d1: null,
          d2: null,
          d3: null,
          taiThisBet: 0,
          xiuThisBet: 0,
          winAmount: 0,
          history: flushedHistory,
          error: null,
        );
        _startBettingCountdown(_bettingWindowSec);
        flushWinBalanceRefresh();
        _toastController.add(const TaiXiuToast.success('Bắt đầu phiên mới'));
      case TaiXiuUpdateBetInfo(:final betArr):
        _logger.i('[TaiXiuLogic] update_bet_info entries=${betArr.length}');
        _applyBetInfo(betArr);
      case TaiXiuBet(
        :final entryId,
        :final thisBet,
        :final totalEntryBet,
        :final totalUsers,
        :final availableBalance,
      ):
        _logger.i(
          '[TaiXiuLogic] bet_update entry=$entryId thisBet=$thisBet total=$totalEntryBet users=$totalUsers balance=$availableBalance',
        );
        state = state.copyWith(
          taiTotalBet: entryId == 1 ? totalEntryBet : state.taiTotalBet,
          xiuTotalBet: entryId == 2 ? totalEntryBet : state.xiuTotalBet,
          taiThisBet: entryId == 1 ? thisBet : state.taiThisBet,
          xiuThisBet: entryId == 2 ? thisBet : state.xiuThisBet,
          taiUsers: entryId == 1 ? totalUsers : state.taiUsers,
          xiuUsers: entryId == 2 ? totalUsers : state.xiuUsers,
          availableGold: availableBalance,
          error: null,
        );
        _toastController.add(
          const TaiXiuToast.success(
            'Đặt cược thành công',
            sound: MiniGameSound.txBetSuccess,
          ),
        );
        _refreshAppBalance();
      case TaiXiuShowResult(:final d1, :final d2, :final d3):
        final isTai = d1 + d2 + d3 > 10;
        _logger.i(
          '[TaiXiuLogic] show_result dice=$d1,$d2,$d3 total=${d1 + d2 + d3} result=${isTai ? 'tai' : 'xiu'}',
        );
        _pendingHistory = TaiXiuSessionHistoryLine(
          sessionId: state.sessionId == 0 ? null : state.sessionId,
          d1: d1,
          d2: d2,
          d3: d3,
        );
        final isLive = _liveSessionId == state.sessionId;
        _diceRevealTimer?.cancel();
        state = state.copyWith(
          d1: isLive ? null : d1,
          d2: isLive ? null : d2,
          d3: isLive ? null : d3,
          remainingTimeSec: 0,
          payingTimeSec: _payingWindowSec,
          resultStatic: !isLive,
          sessionHistory: _appendSessionHistory(
            TaiXiuSessionHistoryLine(
              sessionId: state.sessionId == 0 ? null : state.sessionId,
              d1: d1,
              d2: d2,
              d3: d3,
            ),
            state.sessionHistory,
          ),
          error: null,
        );
        _startPayingCountdown(_payingWindowSec);
        if (isLive) {
          _diceRevealTimer = Timer(kTraTienCanKeoDelay, () {
            state = state.copyWith(d1: d1, d2: d2, d3: d3);
          });
        }
      case TaiXiuChat(:final entry):
        _logger.i('[TaiXiuLogic] chat_received');
        _appendChat(_chatLineFromMap(entry));
      case TaiXiuCalculateResultMoney(
        :final availableGold,
        :final goldBalanceBet,
        :final goldExchange,
        :final goldRefund,
      ):
        final winAmount = goldExchange - goldRefund;
        _logger.i(
          '[TaiXiuLogic] payout availableGold=$availableGold balanceBet=$goldBalanceBet win=$winAmount',
        );
        _toastController.add(const TaiXiuToast.success('Trả Tiền Cân Cửa'));
        state = state.copyWith(
          taiTotalBet: goldBalanceBet,
          xiuTotalBet: goldBalanceBet,
          availableGold: availableGold > 0 ? availableGold : state.availableGold,
          winAmount: winAmount > 0 ? winAmount : null,
          error: null,
        );
        if (winAmount > 0) {
          _pendingWinBalanceRefresh = true;
        } else {
          _refreshAppBalance();
        }
      case TaiXiuSessionAnalytic(
        :final betStats,
        :final sessionId,
        :final d1,
        :final d2,
        :final d3,
        :final startTime,
        :final ended,
      ):
        _logger.i(
          '[TaiXiuLogic] session_analytic session=$sessionId ended=$ended entries=${betStats.length}',
        );
        if (!ended) {
          const message = 'Phiên chưa kết thúc';
          state = state.copyWith(sessionStatsLoading: false, error: message);
          _toastController.add(const TaiXiuToast.error(message));
        } else {
          state = state.copyWith(
            sessionStatsLoading: false,
            sessionStats: TaiXiuSessionStatsData(
              sessionId: sessionId,
              d1: d1,
              d2: d2,
              d3: d3,
              startTime: startTime,
              bets: _sessionBetsFromRaw(betStats),
            ),
            error: null,
          );
        }
      case TaiXiuGetBetHistory(:final items, :final accountId):
        _logger.i(
          '[TaiXiuLogic] bet_history account=$accountId entries=${items.length}',
        );
        state = state.copyWith(
          betHistoryLoading: false,
          betHistory: _betHistoryFromRaw(items),
          error: null,
        );
      case TaiXiuBetFree():
        _logger.i('[TaiXiuLogic] bet_free');
        break;
    }
  }

  void _handleSubscribeInfo(TaiXiuSubscribeInfo message) {
    _diceRevealTimer?.cancel();
    final totals = _extractBetTotals(message.gameInfo);
    _bettingWindowSec = message.timeForBettingSec.round();
    _payingWindowSec = message.timeForPayingSec.round();
    final remaining = message.remainingTimeSec.round();
    _logger.i(
      '[TaiXiuLogic] subscribe_info session=${message.sessionId} state=${message.gameState} remaining=${remaining}s betting=${_bettingWindowSec}s paying=${_payingWindowSec}s balance=${message.availableGold}',
    );

    if (message.gameState == 3) {
      final current = _currentResultFromHistory(message.history);
      final liveResultEcho =
          _liveSessionId != null &&
          current != null &&
          current.sid == _liveSessionId &&
          !state.resultStatic &&
          (state.d1 != null || (_diceRevealTimer?.isActive ?? false));
      if (liveResultEcho) {
        _logger.i(
          '[TaiXiuLogic] subscribe_info reconnect-echo liveSession=$_liveSessionId → giữ kết quả live (không static)',
        );
        state = state.copyWith(
          isLoggedIn: true,
          gameState: message.gameState,
          payingTimeSec: remaining,
          taiTotalBet: totals.taiTotal,
          xiuTotalBet: totals.xiuTotal,
          taiUsers: totals.taiUsers,
          xiuUsers: totals.xiuUsers,
          availableGold: message.availableGold,
          chatLines: _chatLinesFromRaw(message.chatHistory),
          sessionHistory: _sessionHistoryFromRaw(message.history),
          error: null,
        );
        _startPayingCountdown(remaining);
        return;
      }
      _liveSessionId = null;
      final selfBet = _extractSelfBet(message.gameInfo);
      _pendingHistory = current == null
          ? null
          : TaiXiuSessionHistoryLine(
              sessionId: current.sid == 0 ? null : current.sid,
              d1: current.d1,
              d2: current.d2,
              d3: current.d3,
            );
      state = state.copyWith(
        isLoggedIn: true,
        sessionId: message.sessionId,
        gameState: message.gameState,
        remainingTimeSec: 0,
        payingTimeSec: remaining,
        resultStatic: true,
        d1: current?.d1,
        d2: current?.d2,
        d3: current?.d3,
        taiTotalBet: totals.taiTotal,
        xiuTotalBet: totals.xiuTotal,
        taiThisBet: selfBet.taiThisBet,
        xiuThisBet: selfBet.xiuThisBet,
        taiUsers: totals.taiUsers,
        xiuUsers: totals.xiuUsers,
        availableGold: message.availableGold,
        winAmount: 0,
        history: _historyFromRaw(
          message.history,
          excludeSessionId: current?.sid,
        ),
        sessionHistory: _sessionHistoryFromRaw(message.history),
        chatLines: _chatLinesFromRaw(message.chatHistory),
        error: null,
      );
      _startPayingCountdown(remaining);
      return;
    }

    _pendingHistory = null;
    _liveSessionId = message.sessionId;
    final selfBet = _extractSelfBet(message.gameInfo);
    state = state.copyWith(
      isLoggedIn: true,
      sessionId: message.sessionId,
      gameState: message.gameState,
      remainingTimeSec: remaining,
      payingTimeSec: 0,
      resultStatic: false,
      d1: null,
      d2: null,
      d3: null,
      taiTotalBet: totals.taiTotal,
      xiuTotalBet: totals.xiuTotal,
      taiThisBet: selfBet.taiThisBet,
      xiuThisBet: selfBet.xiuThisBet,
      taiUsers: totals.taiUsers,
      xiuUsers: totals.xiuUsers,
      availableGold: message.availableGold,
      winAmount: 0,
      history: _historyFromRaw(message.history),
      sessionHistory: _sessionHistoryFromRaw(message.history),
      chatLines: _chatLinesFromRaw(message.chatHistory),
      error: null,
    );
    _startBettingCountdown(remaining);
  }

  ({int d1, int d2, int d3, int? sid, bool isTai})? _currentResultFromHistory(
    List<dynamic> raw,
  ) {
    for (final item in raw.reversed) {
      if (item is! Map) continue;
      final d1 = (item['d1'] as num?)?.toInt();
      final d2 = (item['d2'] as num?)?.toInt();
      final d3 = (item['d3'] as num?)?.toInt();
      if (d1 == null || d2 == null || d3 == null) continue;
      final sid = (item['sid'] as num?)?.toInt();
      return (d1: d1, d2: d2, d3: d3, sid: sid, isTai: d1 + d2 + d3 > 10);
    }
    return null;
  }

  void _applyBetInfo(List<dynamic> betArr) {
    final totals = _extractBetTotals(betArr);
    state = state.copyWith(
      taiTotalBet: totals.taiTotal,
      xiuTotalBet: totals.xiuTotal,
      taiUsers: totals.taiUsers,
      xiuUsers: totals.xiuUsers,
      error: null,
    );
  }

  int _secondsLeft(DateTime deadline) {
    final ms = deadline.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms + 999) ~/ 1000;
  }

  void _startBettingCountdown(int seconds) {
    _payingDeadline = null;
    _bettingDeadline = DateTime.now().add(Duration(seconds: seconds));
    _startCountdownTicker();
  }

  void _startPayingCountdown(int seconds) {
    _bettingDeadline = null;
    _payingDeadline = DateTime.now().add(Duration(seconds: seconds));
    _startCountdownTicker();
  }

  void _startCountdownTicker() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncCountdownFromDeadline(),
    );
  }

  void _syncCountdownFromDeadline() {
    final betting = _bettingDeadline;
    final paying = _payingDeadline;
    if (betting != null) {
      final left = _secondsLeft(betting);
      if (left != state.remainingTimeSec) {
        state = state.copyWith(remainingTimeSec: left);
      }
      if (left <= 0) _stopCountdown();
    } else if (paying != null) {
      final left = _secondsLeft(paying);
      if (left != state.payingTimeSec) {
        state = state.copyWith(payingTimeSec: left);
      }
      if (left <= 0) _stopCountdown();
    } else {
      _stopCountdown();
    }
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _bettingDeadline = null;
    _payingDeadline = null;
  }

  List<TaiXiuSessionHistoryLine> _historyFromRaw(
    List<dynamic> raw, {
    int? excludeSessionId,
  }) {
    final lines = _sessionHistoryFromRaw(raw).reversed;
    final filtered = excludeSessionId == null
        ? lines
        : lines.where((line) => line.sessionId != excludeSessionId);
    return filtered.take(20).toList(growable: false);
  }

  List<TaiXiuSessionHistoryLine> _sessionHistoryFromRaw(List<dynamic> raw) {
    final lines = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final d1 = _readInt(map['d1']);
          final d2 = _readInt(map['d2']);
          final d3 = _readInt(map['d3']);
          if (d1 <= 0 || d2 <= 0 || d3 <= 0) return null;
          final sid = _readInt(map['sid']);
          return TaiXiuSessionHistoryLine(
            sessionId: sid == 0 ? null : sid,
            d1: d1,
            d2: d2,
            d3: d3,
          );
        })
        .whereType<TaiXiuSessionHistoryLine>()
        .toList(growable: false);
    return lines.length <= 100
        ? lines
        : lines.sublist(lines.length - 100);
  }

  List<TaiXiuSessionHistoryLine> _appendSessionHistory(
    TaiXiuSessionHistoryLine next,
    List<TaiXiuSessionHistoryLine> current,
  ) {
    final filtered = current.where((item) {
      if (next.sessionId != null && item.sessionId != null) {
        return item.sessionId != next.sessionId;
      }
      return item.d1 != next.d1 || item.d2 != next.d2 || item.d3 != next.d3;
    }).toList(growable: false);
    final combined = [...filtered, next];
    return combined.length <= 100
        ? combined
        : combined.sublist(combined.length - 100);
  }

  List<TaiXiuChatLine> _chatLinesFromRaw(List<dynamic> raw) {
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => _chatLineFromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  List<TaiXiuSessionBetLine> _sessionBetsFromRaw(List<dynamic> raw) {
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return TaiXiuSessionBetLine(
            username:
                '${map['dn'] ?? map['displayName'] ?? map['userName'] ?? ''}',
            createdAt: _readInt(map['crt']),
            amount: _readInt(map['b']),
            entryId: _readInt(map['eid']),
            refund: _readInt(map['rf']),
          );
        })
        .toList(growable: false);
  }

  List<TaiXiuBetHistoryLine> _betHistoryFromRaw(List<dynamic> raw) {
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return TaiXiuBetHistoryLine(
            sessionId: _readInt(map['sid']),
            createdAt: _readInt(map['crt']),
            entryId: _readInt(map['eid']),
            d1: _readInt(map['d1']),
            d2: _readInt(map['d2']),
            d3: _readInt(map['d3']),
            amount: _readInt(map['b']),
            refund: _readInt(map['rf']),
            payout: _readInt(map['po']),
          );
        })
        .toList(growable: false);
  }

  TaiXiuChatLine _chatLineFromMap(Map<String, dynamic> entry) {
    final name =
        entry['dn'] ?? entry['fu'] ?? entry['u'] ?? entry['name'] ?? entry['user'];
    final message =
        entry['mgs'] ??
        entry['m'] ??
        entry['message'] ??
        entry['chatContent'] ??
        '';
    return TaiXiuChatLine(name: name == null ? '' : '$name', message: '$message');
  }

  static const int _maxChatLines = 100;

  void _appendChat(TaiXiuChatLine line) {
    if (line.message.isEmpty) return;
    final appended = [...state.chatLines, line];
    final trimmed = appended.length > _maxChatLines
        ? appended.sublist(appended.length - _maxChatLines)
        : appended;
    state = state.copyWith(
      chatLines: List<TaiXiuChatLine>.unmodifiable(trimmed),
      error: null,
    );
  }

  ({int taiThisBet, int xiuThisBet}) _extractSelfBet(dynamic raw) {
    if (raw is List && raw.isNotEmpty) return _extractSelfBet(raw.first);
    if (raw is! Map) return (taiThisBet: 0, xiuThisBet: 0);
    final selfBet = Map<String, dynamic>.from(raw)['b'];
    if (selfBet is! Map) return (taiThisBet: 0, xiuThisBet: 0);
    final betMap = Map<String, dynamic>.from(selfBet);
    final value = _readInt(betMap['v']);
    if (value <= 0) return (taiThisBet: 0, xiuThisBet: 0);
    return _readInt(betMap['eid']) == 1
        ? (taiThisBet: value, xiuThisBet: 0)
        : (taiThisBet: 0, xiuThisBet: value);
  }

  _BetTotals _extractBetTotals(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      return _extractBetTotals(raw.first);
    }
    if (raw is! Map<dynamic, dynamic>) return const _BetTotals();
    final map = Map<String, dynamic>.from(raw);
    final tai = _entryMap(map['B']);
    final xiu = _entryMap(map['S']);
    return _BetTotals(
      taiTotal: _readMoney(tai, ['tEB', 'tB', 'tb', 'totalBet', 'b']),
      xiuTotal: _readMoney(xiu, ['tEB', 'tB', 'tb', 'totalBet', 'b']),
      taiUsers: _readMoney(tai, ['tU', 'u', 'totalUser']),
      xiuUsers: _readMoney(xiu, ['tU', 'u', 'totalUser']),
    );
  }

  Map<String, dynamic> _entryMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  int _readMoney(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final parsed = _readInt(map[key]);
      if (parsed != 0) return parsed;
    }
    return 0;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void dispose() {
    flushWinBalanceRefresh();
    _subscription?.close();
    _countdownTimer?.cancel();
    _diceRevealTimer?.cancel();
    _toastController.close();
    super.dispose();
  }
}

class _BetTotals {
  final int taiTotal;
  final int xiuTotal;
  final int taiUsers;
  final int xiuUsers;

  const _BetTotals({
    this.taiTotal = 0,
    this.xiuTotal = 0,
    this.taiUsers = 0,
    this.xiuUsers = 0,
  });
}

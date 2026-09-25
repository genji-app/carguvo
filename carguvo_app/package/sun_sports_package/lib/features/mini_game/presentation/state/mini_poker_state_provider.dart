import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_reels_rive.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_play_area.dart'
    show kMinipokerDefaultEntry;

import '../../logic/mau_binh_card_lib.dart';
import '../../messages/mini_game_message_streams.dart';
import '../../messages/mini_game_senders.dart';
import '../../messages/slot_message.dart';
import '../../socket/mini_game_socket_providers.dart';
import '../../socket/mini_game_socket_state.dart';
import 'mini_game_bet_options.dart';

enum MiniPokerToastKind { success, error, info }

class MiniPokerToast {
  final MiniPokerToastKind kind;
  final String message;

  const MiniPokerToast.success(this.message) : kind = MiniPokerToastKind.success;
  const MiniPokerToast.error(this.message) : kind = MiniPokerToastKind.error;
  const MiniPokerToast.info(this.message) : kind = MiniPokerToastKind.info;
}

class MiniPokerState {
  final int bet;

  final int jackpot;

  final bool isSpinning;

  final bool autoSpin;

  final bool turbo;

  final List<MinipokerReelCard> entryCards;

  final List<MinipokerReelCard>? resultCards;

  final int spinStartToken;

  final int resultToken;

  final int winToken;

  final String? winHand;

  final int winAmount;

  final int jackpotToken;

  final int jackpotAmount;

  final bool jackpotActive;

  final int jackpotWin;

  final String? error;

  const MiniPokerState({
    this.bet = 100,
    this.jackpot = 0,
    this.isSpinning = false,
    this.autoSpin = false,
    this.turbo = false,
    this.entryCards = kMinipokerDefaultEntry,
    this.resultCards,
    this.spinStartToken = 0,
    this.resultToken = 0,
    this.winToken = 0,
    this.winHand,
    this.winAmount = 0,
    this.jackpotToken = 0,
    this.jackpotAmount = 0,
    this.jackpotActive = false,
    this.jackpotWin = 0,
    this.error,
  });

  MiniPokerState copyWith({
    int? bet,
    int? jackpot,
    bool? isSpinning,
    bool? autoSpin,
    bool? turbo,
    List<MinipokerReelCard>? entryCards,
    Object? resultCards = _sentinel,
    int? spinStartToken,
    int? resultToken,
    int? winToken,
    String? winHand,
    int? winAmount,
    int? jackpotToken,
    int? jackpotAmount,
    bool? jackpotActive,
    int? jackpotWin,
    Object? error = _sentinel,
  }) {
    return MiniPokerState(
      bet: bet ?? this.bet,
      jackpot: jackpot ?? this.jackpot,
      isSpinning: isSpinning ?? this.isSpinning,
      autoSpin: autoSpin ?? this.autoSpin,
      turbo: turbo ?? this.turbo,
      entryCards: entryCards ?? this.entryCards,
      resultCards: identical(resultCards, _sentinel)
          ? this.resultCards
          : resultCards as List<MinipokerReelCard>?,
      spinStartToken: spinStartToken ?? this.spinStartToken,
      resultToken: resultToken ?? this.resultToken,
      winToken: winToken ?? this.winToken,
      winHand: winHand ?? this.winHand,
      winAmount: winAmount ?? this.winAmount,
      jackpotToken: jackpotToken ?? this.jackpotToken,
      jackpotAmount: jackpotAmount ?? this.jackpotAmount,
      jackpotActive: jackpotActive ?? this.jackpotActive,
      jackpotWin: jackpotWin ?? this.jackpotWin,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final miniPokerTurboProvider = StateProvider<bool>((ref) => false);

final miniPokerAutoProvider = StateProvider<bool>((ref) => false);

final miniPokerBetProvider = StateProvider<int>((ref) => const MiniPokerState().bet);

final miniPokerStateProvider =
    StateNotifierProvider.autoDispose<MiniPokerNotifier, MiniPokerState>((ref) {
  final scopes = ref.watch(miniGameActiveScopesProvider);
  scopes.retainSlots();
  ref.onDispose(scopes.releaseSlots);
  return MiniPokerNotifier(ref);
});

class MiniPokerNotifier extends StateNotifier<MiniPokerState>
    with WidgetsBindingObserver {
  static const int _reelCount = 5;

  final Ref _ref;

  ProviderSubscription<AsyncValue<SlotMessage>>? _subscription;
  ProviderSubscription<AsyncValue<MiniGameSocketState>>? _socketStateSub;

  Timer? _roundSafetyTimer;

  Timer? _autoRespinTimer;

  Timer? _jackpotTimer;

  static const Duration _kJackpotDuration = Duration(seconds: 5);

  Timer? _spinResponseTimer;

  static const Duration _kSpinResponseTimeout = Duration(seconds: 10);

  List<MauBinhCard>? _pendingCards;
  int _pendingMoney = 0;
  bool _pendingJackpot = false;

  bool _awaitingRound = false;

  MiniGameSocketState? _lastSocketState;

  int _aid = 1;

  final Map<String, int> _jackpots = {};

  int _pendingSubscribeReplies = 0;

  static const Duration _kRoundSafety = Duration(seconds: 6);

  final StreamController<MiniPokerToast> _toastController =
      StreamController<MiniPokerToast>.broadcast();
  Stream<MiniPokerToast> get toastMessages => _toastController.stream;

  MiniPokerNotifier(this._ref) : super(const MiniPokerState()) {
    final persistedAuto = _ref.read(miniPokerAutoProvider);
    final persistedBet = _ref.read(miniPokerBetProvider);
    final betValid = kMiniGameBetValues.contains(persistedBet);
    AppLoggers.websocket.i(
      '[MiniPoker] notifier CREATED auto=$persistedAuto '
      'turbo=${_ref.read(miniPokerTurboProvider)} '
      'bet=$persistedBet betValid=$betValid',
    );
    state = state.copyWith(
      turbo: _ref.read(miniPokerTurboProvider),
      autoSpin: persistedAuto,
      bet: betValid ? persistedBet : null,
    );
    if (!betValid) {
      Future.microtask(() {
        if (!mounted) return;
        _ref.read(miniPokerBetProvider.notifier).state = state.bet;
      });
    }
    _listen();
    _listenSocketState();
    WidgetsBinding.instance.addObserver(this);
    subscribeJackpot();
    if (persistedAuto) {
      spin();
    }
  }

  void _listen() {
    _subscription = _ref.listen<AsyncValue<SlotMessage>>(
      slotMessageStreamProvider(SlotGameId.miniPoker),
      (_, next) {
        next.whenData(_handleMessage);
        if (next.hasError) {
          AppLoggers.websocket.e(
            '[MiniPoker] stream error',
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
      AppLoggers.websocket.i('[MiniPoker] socket dropped giữa spin → gỡ kẹt reel (giữ auto)');
      _unstickSpin(reason: 'socket dropped');
    }
  }

  void _onReauthenticated() {
    AppLoggers.websocket
        .i('[MiniPoker] socket sống lại → re-subscribe (cmd 1300)');
    _pendingSubscribeReplies = 0;
    subscribeJackpot(countPending: false);
  }

  void _unstickSpin({required String reason}) {
    AppLoggers.websocket.w(
      '[MiniPoker] unstick spin ($reason) → dừng reel + mở lại nút (giữ auto)',
    );
    _cancelRound();
    state = state.copyWith(
      isSpinning: false,
      resultCards: state.entryCards,
      resultToken: state.resultToken + 1,
    );
  }

  Future<void> subscribeJackpot({bool countPending = true}) async {
    AppLoggers.websocket.i('[MiniPoker] subscribe jackpot cmd=1300 bet=${state.bet}');
    if (countPending) _pendingSubscribeReplies++;
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    MiniPokerSender(client).subscribe();
  }

  Future<void> _unsubscribeJackpot() async {
    try {
      final client = await _ref.read(miniGameSocketClientProvider.future);
      MiniPokerSender(client).unsubscribe();
    } catch (_) {
    }
  }

  void selectBet(int value) {
    if (state.isSpinning) {
      _toastController.add(const MiniPokerToast.info('Đang quay'));
      return;
    }
    if (state.autoSpin) {
      _toastController.add(
        const MiniPokerToast.error('Tắt tự động quay để đổi mức cược'),
      );
      return;
    }
    state = state.copyWith(bet: value, jackpot: _jackpotFor(value));
    _ref.read(miniPokerBetProvider.notifier).state = value;
    subscribeJackpot();
  }

  void setTurbo(bool value) {
    _ref.read(miniPokerTurboProvider.notifier).state = value;
    state = state.copyWith(turbo: value);
  }

  void setAuto(bool value) {
    _ref.read(miniPokerAutoProvider.notifier).state = value;
    state = state.copyWith(autoSpin: value);
    if (value && !state.isSpinning) {
      spin(manual: true);
    }
  }

  Future<void> spin({bool manual = false}) async {
    if (state.isSpinning) {
      _toastController.add(const MiniPokerToast.info('Đang quay'));
      return;
    }
    if (_lastSocketState is! SocketAuthenticated) {
      AppLoggers.websocket.w(
        '[MiniPoker] spin blocked: socket=${_lastSocketState.runtimeType} manual=$manual',
      );
      if (manual) {
        _toastController.add(
          const MiniPokerToast.error('Mất kết nối, vui lòng thử lại'),
        );
      }
      return;
    }
    final balance = _ref.read(userProvider).user?.balanceInVND;
    if (balance != null && balance < state.bet) {
      if (_ref.read(miniPokerAutoProvider)) {
        _ref.read(miniPokerAutoProvider.notifier).state = false;
      }
      state = state.copyWith(autoSpin: false);
      _toastController.add(
        const MiniPokerToast.error('Số dư không đủ để đặt cược'),
      );
      return;
    }
    _jackpotTimer?.cancel();
    state = state.copyWith(
      isSpinning: true,
      error: null,
      jackpotActive: false,
      spinStartToken: state.spinStartToken + 1,
    );
    AppLoggers.websocket.i('[MiniPoker] spin cmd=1302 bet=${state.bet} aid=$_aid');
    final client = await _ref.read(miniGameSocketClientProvider.future);
    if (!mounted) return;
    MiniPokerSender(client).spin(bet: state.bet, accountId: _aid, lines: const [0]);
    _spinResponseTimer?.cancel();
    _spinResponseTimer = Timer(_kSpinResponseTimeout, () {
      if (!mounted || !state.isSpinning || _awaitingRound) return;
      _unstickSpin(reason: 'no spin result after ${_kSpinResponseTimeout.inSeconds}s');
      _toastController.add(
        const MiniPokerToast.error('Mất kết nối, vui lòng thử lại'),
      );
      _ref.read(userProvider.notifier).refreshBalance();
    });
  }

  void _handleMessage(SlotMessage message) {
    switch (message) {
      case SlotSubscribeJackpot(:final jackpots, :final autoSpin):
        AppLoggers.websocket.i(
          '[MiniPoker] subscribe_jackpot jackpots=${jackpots.length} autoSpin=$autoSpin',
        );
        final isOwnReply = _pendingSubscribeReplies > 0;
        if (isOwnReply) _pendingSubscribeReplies--;
        if (!isOwnReply && state.isSpinning && !_awaitingRound) {
          _unstickSpin(reason: 'reconnect while spinning');
        }
        _jackpots.clear();
        for (final j in jackpots) {
          _jackpots['${j.accountId}:${j.bet}'] = j.jackpot;
        }
        state = state.copyWith(jackpot: _jackpotFor(state.bet));
        if (_ref.read(miniPokerAutoProvider) &&
            !state.isSpinning &&
            !_awaitingRound &&
            _lastSocketState is SocketAuthenticated &&
            mounted) {
          _autoRespinTimer?.cancel();
          _autoRespinTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted &&
                _ref.read(miniPokerAutoProvider) &&
                !state.isSpinning &&
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
          :final wonJackpot,
        ):
        _handleSpinResult(
          errorMessage: errorMessage,
          accountId: accountId,
          moneyExchange: moneyExchange,
          symbols: symbols,
          wonJackpot: wonJackpot,
        );
    }
  }

  void _handleSpinResult({
    required String? errorMessage,
    required int? accountId,
    required int moneyExchange,
    required List<dynamic> symbols,
    required bool wonJackpot,
  }) {
    AppLoggers.websocket.i(
      '[MiniPoker] SPIN_RESULT raw: aid=$accountId mX=$moneyExchange '
      'iJ=$wonJackpot sbs=$symbols mgs=$errorMessage',
    );

    _spinResponseTimer?.cancel();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _cancelRound();
      _ref.read(miniPokerAutoProvider.notifier).state = false;
      state = state.copyWith(
        isSpinning: false,
        autoSpin: false,
        error: errorMessage,
        resultCards: state.entryCards,
        resultToken: state.resultToken + 1,
      );
      _toastController.add(MiniPokerToast.error(errorMessage));
      AppLoggers.websocket.w('[MiniPoker] spin rejected: $errorMessage');
      return;
    }

    if (!state.isSpinning) {
      AppLoggers.websocket.i(
        '[MiniPoker] spin result về sau khi máy đã dừng → bỏ qua hiển thị, refresh balance',
      );
      _ref.read(userProvider.notifier).refreshBalance();
      return;
    }

    if (accountId != null) _aid = accountId;

    final decoded = symbols
        .whereType<num>()
        .map((c) => MauBinhCard.decode(c.toInt()))
        .toList(growable: false);
    final reelCards =
        decoded.map((c) => c.toReelCard()).toList(growable: false);

    AppLoggers.websocket.i(
      '[MiniPoker] decoded cards=${decoded.map((c) => '${c.n}/${c.s}').join(',')} '
      'hand=${decoded.length == 5 ? MauBinhCardLib.getPokerMiniResultString(decoded) : 'n/a'}',
    );

    _pendingCards = decoded;
    _pendingMoney = moneyExchange;
    _pendingJackpot = wonJackpot;
    _awaitingRound = true;
    state = state.copyWith(
      resultCards: reelCards.isEmpty ? null : reelCards,
      entryCards: reelCards.length == _reelCount ? reelCards : null,
      resultToken: state.resultToken + 1,
      error: null,
    );

    _roundSafetyTimer?.cancel();
    _roundSafetyTimer = Timer(_kRoundSafety, _completeRound);
  }

  void onRoundDone() => _completeRound();

  void _completeRound() {
    if (!_awaitingRound) return;
    _awaitingRound = false;
    _roundSafetyTimer?.cancel();
    final cards = _pendingCards ?? const <MauBinhCard>[];
    final money = _pendingMoney;
    final jackpot = _pendingJackpot;
    _pendingCards = null;

    state = state.copyWith(isSpinning: false);
    _announceResult(cards, money, jackpot);
    _ref.read(userProvider.notifier).refreshBalance();
    if (jackpot) {
      _startJackpot(money);
      return;
    }
    if (state.autoSpin && !state.isSpinning) {
      _autoRespinTimer?.cancel();
      _autoRespinTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (state.autoSpin && !state.isSpinning) spin();
      });
    }
  }

  void _startJackpot(int amount) {
    state = state.copyWith(
      jackpotAmount: amount,
      jackpotActive: true,
      jackpotToken: state.jackpotToken + 1,
      jackpotWin: amount,
    );
    AppLoggers.ui.d('[MiniPoker] JACKPOT: fire anim + đếm số → $amount');
    _jackpotTimer?.cancel();
    _jackpotTimer = Timer(_kJackpotDuration, _finishJackpot);
  }

  void _finishJackpot() {
    state = state.copyWith(jackpotActive: false);
    if (state.jackpotWin > 0) return;
    if (state.autoSpin && !state.isSpinning) {
      _autoRespinTimer?.cancel();
      _autoRespinTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (state.autoSpin && !state.isSpinning) spin();
      });
    }
  }

  void debugShowJackpot() {
    if (state.jackpotWin > 0) return;
    final amount = state.jackpot > 0 ? state.jackpot : 200000000;
    state = state.copyWith(jackpotWin: amount);
  }

  void dismissJackpot() {
    if (state.jackpotWin == 0) return;
    state = state.copyWith(jackpotWin: 0);
    if (state.autoSpin && !state.isSpinning) {
      _autoRespinTimer?.cancel();
      _autoRespinTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (state.autoSpin && !state.isSpinning) spin();
      });
    }
  }

  void _cancelRound() {
    _roundSafetyTimer?.cancel();
    _autoRespinTimer?.cancel();
    _spinResponseTimer?.cancel();
    _jackpotTimer?.cancel();
    _awaitingRound = false;
    _pendingCards = null;
  }

  void _announceResult(
    List<MauBinhCard> cards,
    int moneyExchange,
    bool wonJackpot,
  ) {
    if (wonJackpot) {
      _toastController.add(
        MiniPokerToast.success('Nổ hũ! +${formatMoney(moneyExchange)}'),
      );
      return;
    }
    if (moneyExchange > 0 && cards.length == 5) {
      final hand = MauBinhCardLib.getPokerMiniResultString(cards);
      state = state.copyWith(
        winToken: state.winToken + 1,
        winHand: hand,
        winAmount: moneyExchange,
      );
    }
  }

  int _jackpotFor(int bet) => _jackpots['$_aid:$bet'] ?? 0;

  static String formatMoney(int value) {
    final digits = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return (value < 0 ? '-' : '') + buf.toString();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (kIsWeb) return;
    if (lifecycle != AppLifecycleState.paused) return;
    AppLoggers.websocket.i('[MiniPoker] app paused (native) → tắt auto (parity JS EVENT_HIDE)');
    if (_ref.read(miniPokerAutoProvider)) {
      _ref.read(miniPokerAutoProvider.notifier).state = false;
    }
    if (state.autoSpin) {
      state = state.copyWith(autoSpin: false);
    }
  }

  @override
  void dispose() {
    AppLoggers.websocket.i('[MiniPoker] notifier DISPOSED');
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.close();
    _socketStateSub?.close();
    _roundSafetyTimer?.cancel();
    _autoRespinTimer?.cancel();
    _spinResponseTimer?.cancel();
    _jackpotTimer?.cancel();
    _unsubscribeJackpot();
    _toastController.close();
    super.dispose();
  }
}

library;

import 'dart:async';
import 'dart:math';

import 'package:state_notifier/state_notifier.dart';

import 'volta_bet_api.dart';
import 'volta_bet_rules.dart';
import 'volta_event.dart';
import 'volta_event_merger.dart';
import 'volta_event_source.dart';
import 'volta_fairness.dart';
import 'volta_history_grid.dart';
import 'volta_live_api.dart';
import 'volta_models.dart';
import 'volta_payout.dart';
import 'volta_platform.dart';
import 'volta_results_api.dart';
import 'volta_round_clock.dart';
import 'volta_rules.dart';
import 'volta_state.dart';
import 'volta_stats_api.dart';
import 'volta_stats_models.dart';
import 'volta_wire.dart';

abstract class VoltaAccount {
  const VoltaAccount();

  Future<void> refreshBalance();
}

class VoltaNotifier extends StateNotifier<VoltaState> {
  VoltaNotifier(
    this._account,
    this._source,
    this._betApi,
    this._statsApi,
    this._liveApi,
    this._resultsApi,
  ) : super(const VoltaState()) {
    _start();
  }

  static const Duration _tickEvery = Duration(milliseconds: 200);

  static const Duration _drainDelay = Duration(milliseconds: 120);

  static const int _maxPendingBatches = 99;

  final VoltaAccount _account;

  final VoltaEventSource _source;
  final VoltaBetApi _betApi;
  final VoltaStatsApi _statsApi;
  final VoltaLiveApi _liveApi;
  final VoltaResultsApi _resultsApi;

  StreamSubscription<List<VoltaWireEvent>>? _sub;
  Timer? _ticker;
  Timer? _drainTimer;

  final List<List<VoltaWireEvent>> _pending = <List<VoltaWireEvent>>[];
  List<VoltaEvent> _events = const <VoltaEvent>[];

  DateTime? _lastDataAt;

  bool _wasDown = false;

  bool _focused = true;
  DateTime? _hiddenAt;

  String? _shownEventId;

  int? _settledEventId;

  final Map<int, VoltaEventFairness> _fairness = <int, VoltaEventFairness>{};

  final Map<int, String> _liveUrls = <int, String>{};

  static const int _maxFairnessEntries = 20;

  final Map<String, DateTime> _fairnessAskedAt = <String, DateTime>{};
  final Map<String, int> _fairnessTries = <String, int>{};

  static const Duration _fairnessRetry = Duration(seconds: 3);

  static const int _maxFairnessTries = 3;

  double? _serverBalance;

  int _pendingDebit = 0;

  final Map<String, Timer> _ticketTimers = <String, Timer>{};

  final StreamController<VoltaBetOutcome> _notices =
      StreamController<VoltaBetOutcome>.broadcast();

  Stream<VoltaBetOutcome> get notices => _notices.stream;

  int get _nowSecond => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  void _start() {
    _sub = _source.batches.listen(_onBatch);
    _setBackgroundWorkRunning(true);

    unawaited(refreshHistory());
    unawaited(refreshResults());
  }

  void _onBatch(List<VoltaWireEvent> batch) {
    if (batch.isEmpty) return;
    _lastDataAt = DateTime.now();
    _pending.add(batch);
    if (_pending.length > _maxPendingBatches) _pending.removeAt(0);
    _drainTimer ??= Timer(_drainDelay, _drain);
  }

  void _drain() {
    _drainTimer = null;
    if (_pending.isEmpty) return;

    final List<VoltaWireEvent> incoming = <VoltaWireEvent>[
      for (final List<VoltaWireEvent> batch in _pending) ...batch,
    ];
    _pending.clear();

    for (final VoltaWireEvent event in incoming) {
      final String? live = event.liveUrl;
      if (live != null && live.isNotEmpty) {
        final bool isNew = _liveUrls[event.eventId] != live;
        _liveUrls[event.eventId] = live;
        if (voltaDebug && isNew) {
          voltaLog(() => '[VoltaLive] ván ${event.eventId} — link từ ẢNH CHỤP '
              '(index 22): $live');
        }
      }

      final String? md5 = event.md5;
      if (md5 == null || md5.isEmpty) continue;
      final VoltaEventFairness? old = _fairness[event.eventId];
      if (old != null && old.hash == md5) continue;
      _fairness[event.eventId] = VoltaEventFairness(
        hash: md5,
        result: old?.result ?? '',
      );
    }
    _trimFairness();

    final int before = incoming.length;
    _events = VoltaEventMerger.merge(
      current: _events,
      incoming: incoming,
      nowSecond: _nowSecond,
    );
    _logDrain(before);
    _publish();
  }

  void _publish() {
    if (!_focused) {
      _logStall('app đang ở nền');
      return;
    }

    final VoltaLink link = _linkNow();

    final VoltaEvent? current = VoltaEventMerger.currentOf(_events);
    if (!VoltaEventMerger.isUsable(current)) {
      _logStall(
        current == null
            ? 'không còn ván nào sống sót qua merger (_events rỗng)'
            : 'ván ${current.eventId} thiếu startSecond',
      );
      if (state.link != link) state = state.copyWith(link: link);
      return;
    }

    final VoltaEvent event = current!;
    final int now = _nowSecond;
    final VoltaRoundPhase phase = VoltaRoundClock.phaseOf(event, now);
    _currentEventId = event.eventId;
    _ensureFairness(event.eventId, phase);
    _ensureHeadToHead(event.eventId, phase);
    _ensureLiveLink(event.eventId, phase);
    _ensureMyStake(event.eventId);
    final int remaining = VoltaRoundClock.secondsRemaining(event, now);
    final String eventId = '${event.eventId}';

    VoltaMyStake myStake = state.myStake;
    VoltaMyStake previousStake = state.previousStake;
    final bool switchedEvent = _shownEventId != null && _shownEventId != eventId;
    if (switchedEvent) {
      _scheduleResults();
      unawaited(refreshHistory());

      _refreshBalance();

      previousStake = VoltaBetRules.carryOver(myStake);
      myStake = VoltaMyStake.empty;
      _pendingDebit = 0;
    }
    _shownEventId = eventId;

    List<VoltaHistoryCell> history = state.history;
    VoltaMatchResult? lastResult = state.lastResult;
    if (phase == VoltaRoundPhase.result && _settledEventId != event.eventId) {
      _settledEventId = event.eventId;
      _refreshBalance();
      final VoltaWinner winner = VoltaRoundClock.winnerOf(event);
      final int beforeLen = state.history.length;
      history = _appendHistory(winner);
      if (voltaDebug) {
        voltaLog(() => 
          '[VoltaHistory] ⓐ ván ${event.eventId} XONG · thắng=${winner.name} '
          '· lưới $beforeLen → ${history.length} · '
          'đuôi ${_tail(state.history)} → ${_tail(history)}',
        );
        _dumpGrid('ⓐ SAU khi nối ván mới', history);
      }
      _scheduleResults();
      unawaited(refreshHistory());

      final VoltaEventFairness? codes = _fairness[event.eventId];
      lastResult = VoltaMatchResult(
        homeName: event.home,
        awayName: event.away,
        homeLogo: event.homeLogo,
        awayLogo: event.awayLogo,
        winner: winner,
        finishedAt: DateTime.now(),
        md5Code: codes?.hash ?? '',
        resultCode: codes?.result ?? '',
      );
    }

    final ({int home, int away}) historyPct = _percentsOf(history);
    final VoltaState next = state.copyWith(
      link: link,
      round: _roundOf(event, phase, eventId),
      secondsRemaining: remaining,
      myStake: myStake,
      previousStake: previousStake,
      history: history,
      historyHomePercent: historyPct.home,
      historyAwayPercent: historyPct.away,
      clearHeadToHead: switchedEvent,
      lastResult: lastResult,
    );
    if (next != state) state = next;
  }

  static const Duration _stallLogEvery = Duration(seconds: 5);

  String? _lastStall;
  DateTime? _lastStallAt;

  void _logStall(String reason) {
    if (!voltaDebug) return;
    final DateTime now = DateTime.now();
    final bool changed = reason != _lastStall;
    final bool due =
        _lastStallAt == null ||
        now.difference(_lastStallAt!) >= _stallLogEvery;
    if (!changed && !due) return;
    _lastStall = reason;
    _lastStallAt = now;
    voltaLog(() => 'Volta: CHƯA phát state — $reason');
  }

  void _logDrain(int incomingCount) {
    if (!voltaDebug) return;
    _lastStall = null;
    final int now = _nowSecond;
    final VoltaEvent? current = VoltaEventMerger.currentOf(_events);
    if (current == null) {
      voltaLog(() => 
        'Volta: drain $incomingCount khung → merger giữ lại 0 ván. '
        'now=$now. Nếu số này LỚN hơn finishSecond của ván vừa nhận thì ván '
        'đã kết thúc trước khi tới nơi (đồng hồ máy lệch, hoặc index 28 không '
        'phải giờ kết thúc).',
      );
      return;
    }
    voltaLog(() => 
      'Volta: drain $incomingCount khung → ${_events.length} ván. '
      'hiện tại id=${current.eventId} "${current.home}" vs "${current.away}" '
      'start=${current.startSecond} finish=${current.finishSecond} now=$now '
      '(còn ${current.startSecond - now}s tới giờ đá) '
      'won=${current.won} stake=${current.homeStake}/${current.awayStake}',
    );
  }

  VoltaRound _roundOf(VoltaEvent event, VoltaRoundPhase phase, String id) {
    final VoltaEventFairness? codes = _fairness[event.eventId];
    return VoltaRound(
      eventId: id,
      home: VoltaTeam(
        name: event.home,
        odds: event.homeOdds,
        oddsText: event.homeOddsText,
        logoUrl: event.homeLogo,
        selectionId: event.homeSelectionId,
      ),
      away: VoltaTeam(
        name: event.away,
        odds: event.awayOdds,
        oddsText: event.awayOddsText,
        logoUrl: event.awayLogo,
        selectionId: event.awaySelectionId,
      ),
      homeStake: event.homeStake,
      awayStake: event.awayStake,
      homePlayers: event.homePlayers,
      awayPlayers: event.awayPlayers,
      phase: phase,
      winner: VoltaRoundClock.winnerOf(event),
      md5Code: codes?.hash.isNotEmpty == true ? codes!.hash : null,
      resultCode: codes?.result.isNotEmpty == true ? codes!.result : null,
      fairness: VoltaFairness.verify(
        hash: codes?.hash,
        result: codes?.result,
      ),
      liveUrl: _liveUrls[event.eventId],
      startSecond: event.startSecond,
    );
  }

  void _ensureFairness(int eventId, VoltaRoundPhase phase) {
    final VoltaEventFairness? known = _fairness[eventId];
    final bool needResult = phase == VoltaRoundPhase.result;
    if (known != null && known.hasHash && (!needResult || known.hasResult)) {
      return;
    }

    final String key = '$eventId:${needResult ? 'result' : 'hash'}';
    if ((_fairnessTries[key] ?? 0) >= _maxFairnessTries) return;

    final DateTime? askedAt = _fairnessAskedAt[key];
    final DateTime now = DateTime.now();
    if (askedAt != null && now.difference(askedAt) < _fairnessRetry) return;

    _fairnessAskedAt[key] = now;
    _fairnessTries[key] = (_fairnessTries[key] ?? 0) + 1;
    unawaited(_loadFairness(eventId));
  }

  final Set<String> _formAsked = <String>{};

  void _ensureHeadToHead(int eventId, VoltaRoundPhase phase) {
    final String key =
        '$eventId:${phase == VoltaRoundPhase.result ? 'result' : 'live'}';
    if (!_formAsked.add(key)) return;
    if (_formAsked.length > _maxFairnessEntries) {
      _formAsked.remove(_formAsked.first);
    }
    unawaited(_loadFairness(eventId));
  }

  final Set<int> _recipeProbed = <int>{};

  void _probeHashRecipe(int eventId, VoltaEventFairness codes) {
    if (!voltaDebug) return;
    if (!codes.hasHash || !codes.hasResult) return;
    if (!_recipeProbed.add(eventId)) return;
    if (_recipeProbed.length > _maxFairnessEntries) {
      _recipeProbed.remove(_recipeProbed.first);
    }
    VoltaFairness.reportHashRecipe(hash: codes.hash, result: codes.result);
  }

  Future<void>? _resultsInFlight;

  Future<void> refreshResults() =>
      _resultsInFlight ??= _refreshResults().whenComplete(() {
        _resultsInFlight = null;
      });

  Future<void> _refreshResults() async {
    final List<VoltaMatchResult> list = await _resultsApi.fetch();
    if (!mounted || list.isEmpty) return;
    state = state.copyWith(results: list);
  }

  static const Duration _resultsDelay = Duration(seconds: 6);
  Timer? _resultsTimer;

  void _scheduleResults() {
    _resultsTimer?.cancel();
    _resultsTimer = Timer(_resultsDelay, () {
      if (mounted) unawaited(refreshResults());
    });
  }

  final Set<int> _liveAsked = <int>{};

  final Set<int> _myStakeAsked = <int>{};

  void _ensureMyStake(int eventId) {
    if (eventId <= 0) return;
    if (!_myStakeAsked.add(eventId)) return;
    if (_myStakeAsked.length > _maxFairnessEntries) {
      _myStakeAsked.remove(_myStakeAsked.first);
    }
    unawaited(_restoreMyStake(eventId));
  }

  Future<void> _restoreMyStake(int eventId) async {
    final VoltaMyStake before = state.myStake;
    final VoltaMyStakeSnapshot? snap = await _statsApi.fetchMyStake(eventId);
    if (!mounted || snap == null) return;
    if (snap.eventId != 0 && snap.eventId != eventId) return;
    if (_currentEventId != eventId) return;
    if (state.myStake != before) return;
    if (snap.isEmpty && before.isEmpty) return;

    state = state.copyWith(
      myStake: VoltaMyStake(home: snap.home, away: snap.away),
      betEventId: snap.isEmpty ? null : '$eventId',
      clearBetEventId: snap.isEmpty,
    );
    if (voltaDebug) {
      voltaLog(() => 
        'Volta: khôi phục cược ván $eventId — nhà ${snap.home} / '
        'khách ${snap.away}',
      );
    }
  }

  void _ensureLiveLink(int eventId, VoltaRoundPhase phase) {
    if (phase != VoltaRoundPhase.playing &&
        phase != VoltaRoundPhase.settling) {
      return;
    }
    if (_liveUrls.containsKey(eventId)) return;
    if (!_liveAsked.add(eventId)) return;
    unawaited(_loadLiveLink(eventId));
  }

  Future<void> _loadLiveLink(int eventId) async {
    final String? link = await _liveApi.fetchLink(eventId);
    if (voltaDebug) {
      voltaLog(() => 
        link == null || link.isEmpty
            ? '[VoltaLive] ván $eventId — get-live-link KHÔNG có link'
            : '[VoltaLive] ván $eventId — link từ API: $link',
      );
    }
    if (!mounted || link == null || link.isEmpty) return;
    _liveUrls[eventId] = link;
    _publish();
  }

  final Set<int> _statsInFlight = <int>{};

  Future<void> _loadFairness(int eventId) async {
    if (!_statsInFlight.add(eventId)) return;
    try {
      await _loadFairnessOnce(eventId);
    } finally {
      _statsInFlight.remove(eventId);
    }
  }

  Future<void> _loadFairnessOnce(int eventId) async {
    final VoltaEventStats? stats = await _statsApi.fetchEvent(eventId);
    if (!mounted || stats == null) return;

    final VoltaEventFairness? old = _fairness[eventId];
    final VoltaEventFairness merged = VoltaEventFairness(
      hash: stats.hasHash ? stats.hash : (old?.hash ?? ''),
      result: stats.hasResult ? stats.result : (old?.result ?? ''),
    );
    _fairness[eventId] = merged;
    _trimFairness();
    _probeHashRecipe(eventId, merged);

    if (stats.hasForm && eventId == _currentEventId) {
      state = state.copyWith(headToHead: _headToHeadOf(stats));
    }
    _publish();
  }

  int? _currentEventId;

  VoltaHeadToHead _headToHeadOf(VoltaEventStats stats) {
    final VoltaRound? round = state.round;
    return VoltaHeadToHead(
      home: VoltaTeamForm(
        name: round?.home.name.isNotEmpty == true
            ? round!.home.name
            : stats.homeName,
        logoUrl: round?.home.logoUrl ?? stats.homeLogo,
        results: stats.homeForm,
      ),
      away: VoltaTeamForm(
        name: round?.away.name.isNotEmpty == true
            ? round!.away.name
            : stats.awayName,
        logoUrl: round?.away.logoUrl ?? stats.awayLogo,
        results: stats.awayForm,
      ),
    );
  }

  void _trimFairness() {
    while (_fairness.length > _maxFairnessEntries) {
      final int oldest = _fairness.keys.first;
      _fairness.remove(oldest);
      _fairnessAskedAt.remove('$oldest:hash');
      _fairnessAskedAt.remove('$oldest:result');
      _fairnessTries.remove('$oldest:hash');
      _fairnessTries.remove('$oldest:result');
      _liveUrls.remove(oldest);
      _liveAsked.remove(oldest);
      _recipeProbed.remove(oldest);
    }
  }

  void setServerBalance(double balance) {
    final double? previous = _serverBalance;
    if (previous != null && previous.round() == balance.round()) return;
    _checkUnitProbe(balance.round());
    _serverBalance = balance;
    _pendingDebit = 0;
    _pushBalance();
  }

  ({int stake, int balanceBefore})? _unitProbe;

  void _armUnitProbe(int stake) {
    if (!voltaDebug) return;
    _unitProbe ??= (stake: stake, balanceBefore: (_serverBalance ?? 0).round());
  }

  void _checkUnitProbe(int balanceAfter) {
    final ({int stake, int balanceBefore})? probe = _unitProbe;
    _unitProbe = null;
    if (probe == null || probe.stake <= 0) return;

    final int debited = probe.balanceBefore - balanceAfter;
    if (debited <= 0) return;

    final double ratio = debited / probe.stake;
    if (ratio > 500 && ratio < 2000) {
      voltaLog(() => 
        '🔴 VOLTA — ĐƠN VỊ TIỀN SAI: gửi stake=${probe.stake} nhưng server '
        'trừ $debited (gấp ${ratio.round()} lần). `stake` phải chia 1000 '
        'trước khi gửi — xem VoltaBetRequest.stake.',
      );
      return;
    }
    if (ratio > 1 / 2000 && ratio < 1 / 500) {
      voltaLog(() => 
        '🔴 VOLTA — ĐƠN VỊ TIỀN SAI theo chiều ngược: gửi stake=${probe.stake} '
        'nhưng server chỉ trừ $debited. `stake` phải NHÂN 1000 trước khi gửi.',
      );
      return;
    }
    voltaLog(() => 
      '✅ Volta: đơn vị tiền khớp — gửi ${probe.stake}, server trừ $debited.',
    );
  }

  void _pushBalance() {
    final int shown = max(0, (_serverBalance ?? 0).round() - _pendingDebit);
    if (state.balance == shown) return;
    state = state.copyWith(balance: shown);
  }

  void _refreshBalance() {
    if (!mounted) return;
    unawaited(_account.refreshBalance());
  }

  VoltaLink _linkNow() {
    final DateTime? last = _lastDataAt;
    if (last == null) return VoltaLink.connecting;

    final bool down =
        DateTime.now().difference(last) >= VoltaRules.linkDownAfter;

    if (down) {
      if (!_wasDown) {
        _wasDown = true;
        if (voltaDebug) {
          voltaLog(() => 
            'Volta: MẤT KẾT NỐI — server im ${DateTime.now().difference(last).inSeconds}s. '
            'Khoá cược, giữ nguyên màn hình, chờ dây sống lại.',
          );
        }
      }
      return VoltaLink.down;
    }

    if (_wasDown) {
      _wasDown = false;
      if (voltaDebug) voltaLog(() => 'Volta: có kết nối lại — nạp lại dữ liệu');
      _reloadAfterGap();
    }
    return VoltaLink.ready;
  }

  void setFocused(bool focused) {
    if (_focused == focused) return;
    _focused = focused;

    if (!focused) {
      _hiddenAt = DateTime.now();
      _setBackgroundWorkRunning(false);
      return;
    }
    _setBackgroundWorkRunning(true);

    final DateTime? hiddenAt = _hiddenAt;
    _hiddenAt = null;
    final bool longGap =
        hiddenAt != null &&
        DateTime.now().difference(hiddenAt) >=
            VoltaRules.resumeReconnectThreshold;
    if (longGap) _reloadAfterGap();
    _publish();
  }

  void _setBackgroundWorkRunning(bool running) {
    _source.setActive(running);

    if (!running) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(_tickEvery, (_) => _publish());
  }

  void _reloadAfterGap() {
    unawaited(_source.refresh());
    unawaited(refreshHistory());
    _refreshBalance();
  }

  void selectTab(VoltaTab tab) {
    if (state.tab == tab) return;
    state = state.copyWith(tab: tab);
  }

  void selectChip(int index) {
    if (index < 0 || index >= VoltaChip.defaults.length) return;
    if (state.chipIndex == index) return;
    state = state.copyWith(chipIndex: index);
  }

  Future<VoltaBetOutcome> placeBet(VoltaSide side) =>
      _submit(<VoltaBetLeg>[VoltaBetLeg(side, state.chip.value)]);

  Future<VoltaBetOutcome> rebet() => _replay(1);

  Future<VoltaBetOutcome> doubleStake() => _replay(2);

  Future<VoltaBetOutcome> _replay(int multiplier) {
    if (state.hasBetThisRound) {
      return _fail('Ván này bạn đã đặt cược rồi');
    }
    final VoltaMyStake previous = state.previousStake;
    if (previous.isEmpty) return _fail('Ván trước bạn chưa đặt cược');
    if (previous.total * multiplier >= VoltaRules.rebetCeiling) {
      return _fail('Vượt hạn mức đặt lại');
    }
    return _submit(VoltaBetRules.legsFor(previous, multiplier));
  }

  Future<VoltaBetOutcome> _submit(List<VoltaBetLeg> legs) async {
    if (state.submitting) return const VoltaBetOutcome.busy();

    final VoltaRound? round = state.round;
    if (state.link != VoltaLink.ready || round == null) {
      return const VoltaBetOutcome.notice('Đang kết nối, chờ một chút nhé');
    }
    if (!state.canBet) return _failSync('Đã hết thời gian đặt cược');
    if (legs.isEmpty) return _failSync('Chưa chọn mức cược');

    final int total = legs.fold<int>(0, (int sum, VoltaBetLeg l) => sum + l.stake);
    if (total > state.balance) {
      return _failSync('Bạn không đủ số dư đặt cược, vui lòng nạp thêm');
    }

    state = state.copyWith(submitting: true);
    int placed = 0;
    try {
      for (final VoltaBetLeg leg in legs) {
        final VoltaBetResult result = await _send(round, leg);
        switch (result) {
          case VoltaBetAccepted(:final String ticketId, :final bool isActive):
            placed++;
            _onAccepted(round.eventId, leg, ticketId, active: isActive);
          case VoltaBetRejected(:final String message):
            return VoltaBetOutcome.rejected(message, placed: placed);
          case VoltaBetUncertain(:final String reason):
            if (voltaDebug) voltaLog(() => 'Volta: vé không rõ kết cục — $reason');
            _refreshBalance();
            return VoltaBetOutcome.uncertain(placed: placed);
        }
      }
    } finally {
      if (mounted) state = state.copyWith(submitting: false);
    }
    return VoltaBetOutcome.ok(placed: placed);
  }

  Future<VoltaBetResult> _send(VoltaRound round, VoltaBetLeg leg) async {
    final VoltaTeam team = round.teamOf(leg.side);
    final int? winnings = VoltaPayout.wireWinnings(
      odds: team.odds,
      stake: leg.stake,
    );
    if (winnings == null) {
      return const VoltaBetRejected(603, 'Tỉ lệ cược không hợp lệ, thử lại');
    }
    return _betApi.placeBet(
      VoltaBetRequest(
        selectionId: team.selectionId ?? '',
        displayOdds: team.wireOdds,
        stake: leg.stake,
        winnings: winnings,
      ),
    );
  }

  void _onAccepted(
    String eventId,
    VoltaBetLeg leg,
    String ticketId, {
    bool active = false,
  }) {
    _armUnitProbe(leg.stake);
    _pendingDebit += leg.stake;
    state = state.copyWith(
      myStake: state.myStake.add(leg.side, leg.stake),
      betEventId: eventId,
      balance: max(0, (_serverBalance ?? 0).round() - _pendingDebit),
    );
    _refreshBalance();
    if (!active) {
      _trackTicket(ticketId: ticketId, eventId: eventId, leg: leg);
    }
  }

  void _trackTicket({
    required String ticketId,
    required String eventId,
    required VoltaBetLeg leg,
  }) {
    final DateTime deadline = DateTime.now().add(
      VoltaRules.ticketTrackWindow,
    );

    void schedule() {
      _ticketTimers[ticketId] = Timer(VoltaRules.ticketPoll, () async {
        _ticketTimers.remove(ticketId);
        if (!mounted) return;
        final VoltaTicketStatus status = await _betApi.ticketStatus(ticketId);
        if (!mounted) return;

        switch (status) {
          case VoltaTicketStatus.active:
            _refreshBalance();
          case VoltaTicketStatus.declined:
            _refund(eventId, leg);
            _refreshBalance();
            _notices.add(
              const VoltaBetOutcome.rejected(
                'Vé cược vừa bị huỷ, tiền đã được hoàn lại',
              ),
            );
          case VoltaTicketStatus.unavailable:
            _refreshBalance();
          case VoltaTicketStatus.waiting:
          case VoltaTicketStatus.unknown:
            if (DateTime.now().isBefore(deadline)) {
              schedule();
            } else {
              _refreshBalance();
              _notices.add(
                const VoltaBetOutcome.notice(
                  'Vé vẫn đang chờ xác nhận, bạn xem lại ở Lịch sử cược',
                ),
              );
            }
        }
      });
    }

    schedule();
  }

  void _refund(String eventId, VoltaBetLeg leg) {
    _pendingDebit = max(0, _pendingDebit - leg.stake);
    if (state.round?.eventId == eventId) {
      final int current = state.myStake.of(leg.side);
      state = state.copyWith(
        myStake: state.myStake.add(leg.side, -min(current, leg.stake)),
      );
    }
    _pushBalance();
  }

  Future<VoltaBetOutcome> _fail(String message) async => _failSync(message);

  VoltaBetOutcome _failSync(String message) =>
      VoltaBetOutcome.rejected(message, placed: 0);

  Future<void> refreshHistory() {
    return _historyInFlight ??= _refreshHistory().whenComplete(
      () => _historyInFlight = null,
    );
  }

  Future<void>? _historyInFlight;

  Future<void> _refreshHistory() async {
    final VoltaStatsGrid? grid = await _statsApi.fetchGrid();
    if (!mounted || grid == null || grid.isEmpty) return;
    final List<VoltaHistoryCell> cells = _cellsOf(grid);
    if (voltaDebug) {
      final List<VoltaHistoryCell> now = state.history;
      final bool same =
          now.length == cells.length &&
          List<int>.generate(now.length, (int i) => i)
              .every((int i) => now[i] == cells[i]);
      voltaLog(() => 
        '[VoltaHistory] ⓑ server trả ${grid.results.length} ván · '
        'cắt còn ${cells.length} · '
        '${same ? 'KHÔNG ĐỔI so với lưới đang vẽ ⚠' : 'có đổi ✓'} · '
        'đuôi ${_tail(now)} → ${_tail(cells)}',
      );
      _dumpGrid('ⓑ ĐANG VẼ (trước khi thay)', now);
      _dumpGrid('ⓑ SERVER trả (sẽ thay vào)', cells);
    }

    final int behind = _behindBy(state.history, cells);
    if (behind > 0) {
      if (voltaDebug) {
        voltaLog(() => 
          '[VoltaHistory] ⚠ gói server CHẬM HƠN lưới đang vẽ $behind ván — '
          'giữ nguyên lưới, hỏi lại sau ${_historyRetry.inSeconds}s',
        );
      }
      _retryHistoryLater();
      return;
    }
    if (behind == 0) {
      _historyRetries = 0;
      return;
    }
    _historyRetries = 0;

    final ({int home, int away}) pct = _percentsOf(cells);
    state = state.copyWith(
      history: cells,
      historyHomePercent: pct.home,
      historyAwayPercent: pct.away,
    );
  }

  static const int _maxBehind = 3;

  static int _behindBy(
    List<VoltaHistoryCell> ours,
    List<VoltaHistoryCell> theirs,
  ) {
    if (ours.isEmpty || ours.length != theirs.length) return -1;
    for (int k = 0; k <= _maxBehind; k++) {
      bool ok = true;
      for (int i = 0; i + k < ours.length; i++) {
        if (theirs[i + k] != ours[i]) {
          ok = false;
          break;
        }
      }
      if (ok) return k;
    }
    return -1;
  }

  static const Duration _historyRetry = Duration(seconds: 3);
  static const int _maxHistoryRetries = 3;
  Timer? _historyRetryTimer;
  int _historyRetries = 0;

  void _retryHistoryLater() {
    if (_historyRetries >= _maxHistoryRetries) return;
    _historyRetries++;
    _historyRetryTimer?.cancel();
    _historyRetryTimer = Timer(_historyRetry, () {
      if (mounted) unawaited(refreshHistory());
    });
  }

  static void _dumpGrid(String tag, List<VoltaHistoryCell> cells) {
    if (!voltaDebug) return;
    const int columns = VoltaHistoryGrid.columns;
    const int rows = VoltaHistoryGrid.rows;

    voltaLog(() => '[VoltaHistory] $tag — ${cells.length} ô (N=nhà, K=khách):');
    for (int row = 0; row < rows; row++) {
      final StringBuffer line = StringBuffer();
      for (int col = 0; col < columns; col++) {
        final int age =
            row * columns + (row.isEven ? (columns - 1 - col) : col);
        final int index = cells.length - 1 - age;
        final String mark = (index < 0 || index >= cells.length)
            ? '·'
            : (cells[index].winner == VoltaWinner.home ? 'N' : 'K');
        line.write(age == 0 ? '[$mark]' : ' $mark ');
      }
      voltaLog(() => '[VoltaHistory]   hàng ${row + 1}: $line');
    }
  }

  static String _tail(List<VoltaHistoryCell> cells) {
    if (cells.isEmpty) return '(rỗng)';
    final int from = cells.length < 3 ? 0 : cells.length - 3;
    return cells
        .sublist(from)
        .map((VoltaHistoryCell c) => c.winner == VoltaWinner.home ? 'N' : 'K')
        .join(' ');
  }

  static ({int home, int away}) _percentsOf(List<VoltaHistoryCell> cells) {
    if (cells.isEmpty) return (home: 50, away: 50);
    int home = 0;
    for (final VoltaHistoryCell cell in cells) {
      if (cell.winner == VoltaWinner.home) home++;
    }
    final int away = cells.length - home;
    return (
      home: (home / cells.length * 100).round(),
      away: (away / cells.length * 100).round(),
    );
  }

  static List<VoltaHistoryCell> _cellsOf(VoltaStatsGrid grid) {
    final List<VoltaWinner> all = grid.results;
    final List<VoltaWinner> last = all.length <= VoltaHistoryGrid.maxCells
        ? all
        : all.sublist(all.length - VoltaHistoryGrid.maxCells);
    return List<VoltaHistoryCell>.unmodifiable(
      <VoltaHistoryCell>[for (final VoltaWinner w in last) VoltaHistoryCell(w)],
    );
  }

  List<VoltaHistoryCell> _appendHistory(VoltaWinner winner) {
    final List<VoltaHistoryCell> next = <VoltaHistoryCell>[
      ...state.history,
      VoltaHistoryCell(winner),
    ];
    if (next.length > VoltaHistoryGrid.maxCells) {
      next.removeRange(0, next.length - VoltaHistoryGrid.maxCells);
    }
    return List<VoltaHistoryCell>.unmodifiable(next);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    _drainTimer?.cancel();
    _drainTimer = null;
    _resultsTimer?.cancel();
    _resultsTimer = null;
    _historyRetryTimer?.cancel();
    _historyRetryTimer = null;
    for (final Timer timer in _ticketTimers.values) {
      timer.cancel();
    }
    _ticketTimers.clear();
    unawaited(_sub?.cancel());
    _sub = null;
    unawaited(_notices.close());
    _pending.clear();
    super.dispose();
  }
}

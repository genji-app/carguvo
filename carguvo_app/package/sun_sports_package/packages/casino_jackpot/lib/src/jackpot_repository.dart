import 'dart:async';

import 'package:game_api_client/game_api_client.dart';

import 'jackpot_log.dart';
import 'jackpot_display_state.dart';
import 'jackpot_ticker.dart';

class JackpotRepository {
  JackpotRepository({
    required GameApiClient client,
    JackpotLogHandler? onLog,
    JackpotTickerConfig config = const JackpotTickerConfig(),
    Duration? pollInterval,
    Duration? tickInterval,
  }) : _client = client,
       _logger = JackpotLogger(onLog),
       _config = config,
       _pollInterval = pollInterval ?? config.pollInterval,
       _tickInterval = tickInterval ?? config.tickInterval;

  static const Duration kDefaultPollInterval = Duration(seconds: 30);

  static const Duration kDefaultTickInterval = Duration(milliseconds: 60);

  static const int kMaxConsecutiveErrors = 3;

  final GameApiClient _client;
  final JackpotLogger _logger;
  final JackpotTickerConfig _config;
  final Duration _pollInterval;
  final Duration _tickInterval;

  late final StreamController<Map<int, JackpotDisplayState>> _controller =
      StreamController<Map<int, JackpotDisplayState>>.broadcast(
        onListen: _onFirstListener,
        onCancel: _syncTickTimer,
      );

  final Map<(int, num), JackpotTicker> _tickers = {};

  Map<int, JackpotDisplayState> _currentSnapshot = const {};
  Timer? _pollTimer;
  Timer? _tickTimer;
  int _consecutiveErrors = 0;
  bool _isStarted = false;
  bool _isPaused = false;
  bool _isDisposed = false;

  Stream<Map<int, JackpotDisplayState>> get jackpotStream => _controller.stream;

  Map<int, JackpotDisplayState> get currentJackpots => _currentSnapshot;

  Future<void> start() async {
    if (_isStarted || _isDisposed) return;
    _isStarted = true;
    _logger.log('Starting jackpot polling and display stream');

    _syncTickTimer();
    await _pollNow();
    _startPollTimer();
  }

  Future<void> pollNow() => _pollNow();

  void pausePolling() {
    _isPaused = true;
    _logger.log('Pausing jackpot polling (App in background/paused)');
    _pollTimer?.cancel();
    _pollTimer = null;
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  Future<void> resumePolling() async {
    if (!_isStarted || _isDisposed) return;
    _isPaused = false;
    _logger.log('Resuming jackpot polling (App in foreground/resumed)');
    _syncTickTimer();
    await _pollNow();
    _startPollTimer();
  }

  Future<void> _pollNow() async {
    if (_isDisposed || _isPaused) return;

    try {
      final grouped = await _client.getJackpots();
      _consecutiveErrors = 0;

      for (final entryList in grouped.values) {
        for (final entry in entryList) {
          final key = (entry.gameId, entry.betting);
          final ticker = _tickers.putIfAbsent(key, () => JackpotTicker(config: _config));

          if (ticker.hasDriftExceeded(entry.balance)) {
            ticker.forceCorrect(entry.balance, betting: entry.betting);
          } else {
            ticker.updateFromApi(entry.balance, betting: entry.betting);
          }
        }
      }

      _publishSnapshot(isLoading: false, hasError: false);
      _logger.log('Jackpot balances polled successfully (${grouped.length} games updated)');
    } catch (e, stackTrace) {
      _consecutiveErrors++;
      _logger.warning(
        'Poll jackpot lỗi (lần $_consecutiveErrors): $e',
        e,
        stackTrace,
      );

      if (_consecutiveErrors >= kMaxConsecutiveErrors) {
        _logger.error(
          'Consecutive errors ($kMaxConsecutiveErrors) reached. Freezing jackpot rate extrapolation.',
        );
        for (final ticker in _tickers.values) {
          ticker.freezeRate();
        }
      }
      _publishSnapshot(isLoading: false, hasError: true);
      _scheduleBackoff();
    }
  }

  void _startPollTimer() {
    _pollTimer?.cancel();
    if (_isDisposed || _isPaused) return;

    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_pollNow());
    });
  }

  void _scheduleBackoff() {
    _pollTimer?.cancel();
    if (_isDisposed || _isPaused) return;

    final multiplier = 1 << (_consecutiveErrors.clamp(1, 3) - 1);
    final backoffDuration = _pollInterval * multiplier;

    _pollTimer = Timer(backoffDuration, () {
      unawaited(_pollNow());
      if (!_isPaused && !_isDisposed) {
        _startPollTimer();
      }
    });
  }

  void _onFirstListener() {
    if (_isDisposed) return;
    _publishSnapshot(
      isLoading: _currentSnapshot.isEmpty && _isStarted,
      hasError: _consecutiveErrors > 0,
    );
    _syncTickTimer();
  }

  void _syncTickTimer() {
    final shouldRun =
        _isStarted && !_isPaused && !_isDisposed && _controller.hasListener;
    if (shouldRun) {
      if (_tickTimer != null) return;
      _logger.log('Jackpot tick clock: start');
      _tickTimer = Timer.periodic(_tickInterval, (_) {
        _publishSnapshot(
          isLoading: _currentSnapshot.isEmpty && _isStarted,
          hasError: _consecutiveErrors > 0,
        );
      });
    } else {
      if (_tickTimer != null) {
        _logger.log(
          'Jackpot tick clock: stop '
          '(started=$_isStarted paused=$_isPaused listeners=${_controller.hasListener})',
        );
      }
      _tickTimer?.cancel();
      _tickTimer = null;
    }
  }

  void _publishSnapshot({required bool isLoading, required bool hasError}) {
    if (_isDisposed) return;

    final byGameId = <int, List<MapEntry<(int, num), JackpotTicker>>>{};
    for (final entry in _tickers.entries) {
      byGameId.putIfAbsent(entry.key.$1, () => []).add(entry);
    }

    final now = DateTime.now();
    final snapshot = <int, JackpotDisplayState>{};

    for (final gameEntry in byGameId.entries) {
      final tiers = gameEntry.value.map((e) {
        return JackpotTierState(
          betting: e.key.$2,
          realBalance: e.value.realBalance,
          displayBalance: e.value.displayValue,
          ratePerMs: e.value.ratePerMs,
        );
      }).toList()..sort((a, b) => a.betting.compareTo(b.betting));

      snapshot[gameEntry.key] = JackpotDisplayState(
        gameId: gameEntry.key,
        tiers: tiers,
        isLoading: isLoading,
        hasError: hasError,
        lastUpdated: now,
      );
    }

    _currentSnapshot = snapshot;
    if (!_controller.isClosed) {
      _controller.add(snapshot);
    }
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _logger.log('Disposing JackpotRepository and cancelling all timers');

    _pollTimer?.cancel();
    _pollTimer = null;
    _tickTimer?.cancel();
    _tickTimer = null;

    _controller.close();
  }
}

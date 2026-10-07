library;

import 'dart:async';
import 'dart:convert';

import 'chat_wire.dart';
import 'package:clock/clock.dart';

import 'chat_session_config.dart';
import 'chat_session_hooks.dart';

class ChatSessionMachine {
  ChatSessionMachine({
    required this.hooks,
    this.name = 'ChatSession',
    this.config = const ChatSessionConfig(),
  });

  final String name;
  final ChatSessionConfig config;
  final ChatSessionHooks hooks;

  Timer? _healthTimer;
  Timer? _proactiveTimer;
  Timer? _retryTimer;

  int _pingId = 0;
  int _retryAttempts = 0;
  bool _loggedIn = false;
  bool _started = false;
  bool _killed = false;
  bool _recovering = false;

  int _epoch = 0;
  DateTime? _connectedAt;
  DateTime? _lastRecoverAt;
  DateTime? _lastPongAt;
  final List<String> _queuedFrames = [];

  bool get isLoggedIn => _loggedIn;

  bool get isKilled => _killed;

  bool get hasStarted => _started;

  bool get retryPending => _retryTimer?.isActive ?? false;

  DateTime? get connectedAt => _connectedAt;

  DateTime? get lastPongAt => _lastPongAt;

  int get pingId => _pingId;
  int get retryAttempts => _retryAttempts;

  bool get isDialing {
    if (!hooks.isTransportAlive()) return false;
    if (_loggedIn) return false;
    final at = _connectedAt;
    if (at == null) return false;
    return clock.now().difference(at) < config.loginTimeout;
  }

  void _log(String message) => hooks.log?.call('$name: $message');

  Future<void> start() async {
    if (_started) return;
    _killed = false;
    _started = true;
    if (config.healthRunsContinuously) _startHealthCheck();
    await recover('start', bypassDebounce: true, forceRefresh: false);
  }

  void rearm() {
    _killed = false;
  }

  void notifyTransportOpened() {
    _connectedAt = clock.now();
    _lastPongAt = clock.now();
    if (_healthTimer == null) _startHealthCheck();
  }

  void notifyLoginSuccess() {
    _loggedIn = true;
    hooks.onLoginStateChange(true);
    _lastPongAt = clock.now();

    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempts = 0;

    _scheduleProactiveRefresh();

    _flushQueue();

    hooks.onLoginSuccess();
  }

  void notifyTransportClosed() {
    if (!_loggedIn) return;
    _loggedIn = false;
    _connectedAt = null;
    hooks.onLoginStateChange(false);
    if (!config.healthRunsContinuously) _cancelHealthCheck();
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void onTransportDropped() {
    if (_killed) return;
    if (config.recoverImmediatelyOnDrop) {
      unawaited(recover('socket dropped / connection lost'));
      return;
    }
    hooks.teardownTransport();
    if (_started) _scheduleRecoverRetry();
  }

  void notifyPong([int pongId = 0]) {
    _lastPongAt = clock.now();
  }

  void probe() => _sendPing();

  void queueFrame(String frame) {
    _queuedFrames.add(frame);
  }

  void kill() {
    _killed = true;
    _started = false;
    _epoch++;
    _recovering = false;
    _loggedIn = false;
    _connectedAt = null;
    _cancelHealthCheck();
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempts = 0;
    _lastRecoverAt = null;
    _queuedFrames.clear();
  }

  Future<void> recover(
    String reason, {
    bool bypassDebounce = false,
    bool forceRefresh = true,
  }) async {
    if (_killed) {
      _log('recover IGNORED — chat killed | reason=$reason');
      return;
    }
    if (_recovering) {
      _log('recover SKIPPED — a recover is already in flight | reason=$reason');
      return;
    }
    final now = clock.now();
    if (!bypassDebounce &&
        _lastRecoverAt != null &&
        now.difference(_lastRecoverAt!) < config.recoverDebounce) {
      _log('recover SKIPPED (debounced) | reason=$reason');
      return;
    }
    if (!hooks.canDial()) {
      _log('recover ABORT — endpoint empty (config wiped) | reason=$reason');
      return;
    }
    _lastRecoverAt = now;
    _log('recover START | reason=$reason');

    _recovering = true;
    final epoch = _epoch;
    try {
      _loggedIn = false;
      hooks.onLoginStateChange(false);
      if (!config.healthRunsContinuously) _cancelHealthCheck();
      _proactiveTimer?.cancel();
      _proactiveTimer = null;
      _retryTimer?.cancel();
      _retryTimer = null;
      hooks.teardownTransport();

      final refreshed = await hooks.refreshSession(force: forceRefresh);
      if (_killed || epoch != _epoch) {
        _log('recover ABORT after refresh — chat killed (kick/logout)');
        return;
      }
      if (!refreshed) {
        if (hooks.isSignedOut()) {
          _log('recover STOP — signed out, token cannot come back');
          hooks.onFatalStop();
          return;
        }
        _log('recover FAILED — session refresh not ok');
        _scheduleRecoverRetry();
        return;
      }
      await hooks.dial();
    } catch (e) {
      if (epoch != _epoch) return;
      _log('recover FAILED: $e');
      hooks.teardownTransport();
      _scheduleRecoverRetry();
    } finally {
      if (epoch == _epoch) _recovering = false;
    }
  }

  void _startHealthCheck() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(config.healthInterval, (_) => _healthTick());
  }

  void _cancelHealthCheck() {
    _healthTimer?.cancel();
    _healthTimer = null;
  }

  void _healthTick() {
    if (_killed) return;

    if (!hooks.isTransportAlive()) {
      if (_recovering || retryPending) return;
      _log('health-check — NOT CONNECTED → recover');
      unawaited(recover('health-check: transport not connected'));
      return;
    }

    if (!_loggedIn) {
      final at = _connectedAt;
      final waited =
          at == null ? Duration.zero : clock.now().difference(at);
      if (waited >= config.loginTimeout) {
        _log('health-check — connected ${waited.inSeconds}s but NOT LOGGED IN '
            '→ recover');
        unawaited(recover('health-check: login timeout (${waited.inSeconds}s)'));
      }
      return;
    }

    _sendPing();
  }

  void _sendPing() {
    if (!hooks.isTransportAlive() || !_loggedIn) return;
    _pingId++;
    try {
      hooks.sendFrame(
        jsonEncode(buildChatPingPayload(hooks.chatZone(), _pingId)),
      );
    } catch (_) {
      onTransportDropped();
    }
  }

  void _scheduleProactiveRefresh() {
    _proactiveTimer?.cancel();

    final delay = chatProactiveRefreshDelay(
      tokenExpiry: hooks.wsTokenExpiry(),
      leadTime: config.refreshLeadTime,
      minDelay: config.refreshMinDelay,
      fallback: config.refreshFallback,
    );

    _proactiveTimer = Timer(delay, () {
      _log('proactive pre-expiry token refresh');
      unawaited(recover('proactive pre-expiry refresh', bypassDebounce: true));
    });
  }

  void _scheduleRecoverRetry() {
    _retryAttempts++;
    final seconds = chatRecoverBackoffSeconds(
      _retryAttempts,
      baseSeconds: config.retryBaseDelay.inSeconds,
      maxSeconds: config.retryMaxDelay.inSeconds,
    );
    _log('recover retry in ${seconds}s (attempt $_retryAttempts)');

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), () {
      _lastRecoverAt = null;
      unawaited(recover(
        'auto-retry after failed recover (attempt $_retryAttempts)',
        bypassDebounce: true,
      ));
    });
  }

  void _flushQueue() {
    if (_queuedFrames.isEmpty) return;
    for (final frame in _queuedFrames) {
      hooks.sendFrame(frame);
    }
    _queuedFrames.clear();
  }
}

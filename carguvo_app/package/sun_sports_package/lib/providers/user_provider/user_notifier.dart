import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

part 'user_notifier.freezed.dart';

enum UserStatus {
  initial,

  loading,

  success,

  refreshing,

  failure,
}

@freezed
sealed class UserState with _$UserState {
  const UserState._();

  const factory UserState({
    @Default(UserStatus.initial) UserStatus status,

    User? user,

    String? error,

    DateTime? lastUpdated,
  }) = _UserState;

  bool get isLoading => status == UserStatus.loading;

  bool get isRefreshing => status == UserStatus.refreshing;

  bool get isLoggedIn => user?.isLoggedIn ?? false;
}

class UserNotifier extends StateNotifier<UserState> with LoggerMixin {
  UserNotifier({required UserRepository repository})
    : _repository = repository,
      super(const UserState()) {
    _listenToDataSources();
  }

  final UserRepository _repository;
  StreamSubscription<User?>? _userSubscription;
  Timer? _periodicSyncTimer;
  static const _periodicSyncInterval = Duration(seconds: 60);

  void _listenToDataSources() {
    logDebug('Initializing real-time data source listeners from repository');

    _userSubscription = _repository.userStream.listen((user) {
      if (user != null) {
        logInfo('User state updated from repository: ${user.displayName}');
        state = state.copyWith(
          user: user,
          status: UserStatus.success,
          lastUpdated: DateTime.now(),
        );
        _startPeriodicSync();
      } else {
        _stopPeriodicSync();
      }
    });
  }

  void _startPeriodicSync() {
    if (_periodicSyncTimer?.isActive ?? false) return;
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (_) {
      if (!mounted || !state.isLoggedIn) {
        _stopPeriodicSync();
        return;
      }
      final ls = WidgetsBinding.instance.lifecycleState;
      if (ls != null && ls != AppLifecycleState.resumed) return;
      refreshBalance();
    });
  }

  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  Future<void> fetchUserInfo() async {
    logInfo('Fetching user info');
    state = state.copyWith(status: UserStatus.loading, error: null);

    try {
      final user = await _repository.getUserInfo();
      if (!mounted) return;

      state = state.copyWith(
        user: user,
        status: UserStatus.success,
        lastUpdated: DateTime.now(),
      );
      if (user != null && user.isLoggedIn) {
        _startPeriodicSync();
        unawaited(refreshBalance());
      }
    } on GetUserInfoFailure catch (e, stackTrace) {
      logError('Failed to fetch user info', e, stackTrace);
      if (!mounted) return;
      state = state.copyWith(
        status: UserStatus.failure,
        error: e.errorMessage ?? 'Không thể tải thông tin người dùng',
      );
    }
  }

  DateTime? _lastBalanceRefreshAt;

  static const Duration _ambientRefreshMinInterval = Duration(seconds: 10);

  Future<void> refreshBalance() async {
    if (state.isRefreshing) return;

    _lastBalanceRefreshAt = DateTime.now();
    logInfo('Refreshing user balance');
    state = state.copyWith(status: UserStatus.refreshing);

    try {
      await _repository.getBalance();

      logInfo('Balance refresh complete');
      if (!mounted) return;
      if (state.status == UserStatus.refreshing) {
        state = state.copyWith(
          status: UserStatus.success,
          lastUpdated: DateTime.now(),
        );
      }
    } on GetBalanceFailure catch (e, stackTrace) {
      logError('Failed to refresh balance', e, stackTrace);
      if (!mounted) return;
      state = state.copyWith(status: UserStatus.success);
    }
  }

  Future<void> refreshBalanceThrottled({Duration? minInterval}) async {
    if (!state.isLoggedIn) return;

    final last = _lastBalanceRefreshAt;
    final window = minInterval ?? _ambientRefreshMinInterval;
    if (last != null && DateTime.now().difference(last) < window) {
      logDebug('Skip ambient balance refresh (trong cửa sổ coalesce)');
      return;
    }
    return refreshBalance();
  }

  static const Duration _moneyFlowRetryInterval = Duration(seconds: 30);

  static const int _moneyFlowMaxAttempts = 5;

  Timer? _moneyFlowTimer;

  int _moneyFlowAttempt = 0;

  double? _moneyFlowBaseline;

  void watchBalanceAfterMoneyFlow({
    Duration? firstTickInterval,
    Duration? retryInterval,
    int? maxAttempts,
  }) {
    _moneyFlowTimer?.cancel();
    _moneyFlowAttempt = 0;
    _moneyFlowBaseline = state.user?.balance;

    final regular = retryInterval ?? _moneyFlowRetryInterval;
    logInfo('Theo dõi số dư sau giao dịch (mốc: $_moneyFlowBaseline)');
    _scheduleMoneyFlowTick(
      firstTickInterval ?? regular,
      regular,
      maxAttempts ?? _moneyFlowMaxAttempts,
    );
  }

  void cancelBalanceWatch() {
    _moneyFlowTimer?.cancel();
    _moneyFlowTimer = null;
    _moneyFlowAttempt = 0;
    _moneyFlowBaseline = null;
  }

  void _scheduleMoneyFlowTick(
    Duration interval,
    Duration regularInterval,
    int maxAttempts,
  ) {
    _moneyFlowTimer = Timer(interval, () async {
      _moneyFlowTimer = null;
      if (!mounted) return;
      if (!state.isLoggedIn) return;

      if (_moneyFlowBalanceChanged()) {
        logInfo('Số dư đã đổi trước nhịp trễ → dừng theo dõi');
        return;
      }

      _moneyFlowAttempt++;
      await refreshBalance();
      await Future<void>.microtask(() {});
      if (!mounted) return;

      if (_moneyFlowBalanceChanged()) {
        logInfo('Số dư đã cập nhật sau nhịp trễ $_moneyFlowAttempt → dừng');
        return;
      }
      if (_moneyFlowAttempt >= maxAttempts) {
        logInfo('Hết $maxAttempts nhịp trễ mà số dư chưa đổi → bỏ theo dõi');
        return;
      }
      _scheduleMoneyFlowTick(regularInterval, regularInterval, maxAttempts);
    });
  }

  bool _moneyFlowBalanceChanged() {
    final baseline = _moneyFlowBaseline;
    final current = state.user?.balance;
    if (baseline == null || current == null) return false;
    return (current - baseline).abs() > 0.0001;
  }

  void updateAvatarLocally(String avatarUrl) {
    if (!mounted) return;
    _repository.updateLocalAvatarUrl(avatarUrl);
    logInfo('Locally updated avatarUrl for UI instant update');
  }

  void clear() {
    logDebug('Clearing user state');
    _stopPeriodicSync();
    _repository.clearOverrides();
    cancelBalanceWatch();
    state = const UserState();
  }

  @override
  void dispose() {
    logDebug('Disposing UserNotifier: Cancelling subscriptions');
    _stopPeriodicSync();
    _userSubscription?.cancel();
    cancelBalanceWatch();
    super.dispose();
  }
}

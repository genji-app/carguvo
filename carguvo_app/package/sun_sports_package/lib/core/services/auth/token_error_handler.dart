import 'dart:async';
import 'package:auth_domain/auth_domain.dart'
    show isTokenErrorMessage;
import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding;
import 'package:sun_sports/core/network/sb_api_client.dart' show HttpException;
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/auth/session_superseded_exception.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class TokenErrorHandler {
  static final TokenErrorHandler _instance = TokenErrorHandler._();
  static TokenErrorHandler get instance => _instance;
  TokenErrorHandler._();

  static final _logger = AppLogger(tag: 'TokenErrorHandler');

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  static const _refreshTimeout = Duration(seconds: 10);

  static const _maxTransientRetries = 2;

  static const _retryBackoff = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 3),
  ];

  static bool _isDefinitiveAuthReject(Object e) =>
      e is HttpException && (e.statusCode == 401 || e.statusCode == 403);

  static bool get _isAppInBackground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused;
  }

  Future<bool> handleTokenError({bool closeGameOnFail = true}) async {
    if (!await SbLogin.hasValidTokens()) {
      _logger.d('Guest (no refresh token) → bỏ qua 401, không force-logout');
      return false;
    }

    if (_isRefreshing && _refreshCompleter != null) {
      _logger.d('Token refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    final generation = SbLogin.sessionGeneration;

    try {
      _logger.i('Starting token refresh...');
      Object? lastError;
      StackTrace? lastStack;

      for (var attempt = 0; attempt <= _maxTransientRetries; attempt++) {
        if (attempt > 0) {
          final wait = _retryBackoff[attempt - 1];
          _logger.w(
            'Token refresh: thử lại lần $attempt/$_maxTransientRetries '
            'sau ${wait.inSeconds}s',
          );
          await Future<void>.delayed(wait);
        }
        try {
          await SbLogin.refreshToken().timeout(
            _refreshTimeout,
            onTimeout: () => throw TimeoutException(
              'Token refresh timeout after ${_refreshTimeout.inSeconds}s',
            ),
          );
          _logger.i(
            'Token refresh successful (accessToken + wsToken + userTokenSb)'
            '${attempt > 0 ? ' — sau $attempt lần thử lại' : ''}',
          );
          _refreshCompleter!.complete(true);
          return true;
        } catch (e, stackTrace) {
          lastError = e;
          lastStack = stackTrace;
          if (e is SessionSupersededException) {
            _logger.w('Token refresh abandoned — $e');
            break;
          }
          if (_isDefinitiveAuthReject(e)) {
            _logger.e(
              'Refresh token bị server TỪ CHỐI → không thử lại',
              error: e,
              stackTrace: stackTrace,
            );
            break;
          }
          _logger.w(
            'Token refresh hỏng vì lỗi TẠM THỜI (lần ${attempt + 1}/'
            '${_maxTransientRetries + 1})',
            e,
          );
        }
      }

      final e = lastError!;

      if (e is SessionSupersededException ||
          SbLogin.sessionGeneration != generation) {
        _logger.w(
          'Token refresh result dropped — session changed during refresh '
          '(started $generation, now ${SbLogin.sessionGeneration}): $e',
        );
        _refreshCompleter!.complete(false);
        return false;
      }

      _logger.e('Token refresh failed', error: e, stackTrace: lastStack);
      _refreshCompleter!.complete(false);
      final isDefinitiveAuthReject = _isDefinitiveAuthReject(e);

      if (!isDefinitiveAuthReject && _isAppInBackground) {
        _logger.w(
          'Refresh hỏng vì lỗi tạm thời NHƯNG app đang ở nền → HOÃN logout, '
          'giữ phiên; sẽ thử lại khi có request kế tiếp lúc foreground',
        );
        return false;
      }

      if (closeGameOnFail || isDefinitiveAuthReject) {
        await SbLogin.closeCreatorGame(
          401,
          withPopup: true,
          info: 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
        );
      }
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  bool isTokenError(String message) => isTokenErrorMessage(message);

  bool isAuthStatusCode(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  void reset() {
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}

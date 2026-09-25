import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/repositories/auth_repository.dart';
import 'package:sun_sports/core/services/models/user_model.dart';
import 'package:sun_sports/shared/domain/enums/auth_enums.dart';

export 'package:sun_sports/shared/domain/enums/auth_enums.dart';

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  final bool profilePending;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.profilePending = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
    bool? profilePending,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    token: token ?? this.token,
    errorMessage: errorMessage ?? this.errorMessage,
    profilePending: profilePending ?? this.profilePending,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> connect() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final success = await _repository.connect();

      if (success) {
        final user = _repository.getCurrentUser();
        final token = _repository.currentToken;

        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            token: token,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Không thể lấy thông tin user',
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Kết nối thất bại',
        );
      }
    } catch (e, st) {
      AppLoggers.auth.e('connect exception', error: e, stackTrace: st);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: genericErrorMessage,
      );
    }
  }

  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
    }
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
    try {
      await _repository.logout();
    } catch (e, st) {
      AppLoggers.auth.e('logout cleanup failed', error: e, stackTrace: st);
    }
  }

  bool get isInitialized => _repository.isInitialized;

  double get currentBalance => state.user?.balance ?? 0.0;

  void syncFromSbLogin() {
    final http = SbHttpManager.instance;
    final userData = http.user;

    final custLogin = userData['cust_login'] as String? ?? '';

    if (custLogin.isNotEmpty) {
      final user = UserModel(
        uid: userData['uid'] as String? ?? '',
        displayName: userData['displayName'] as String? ?? '',
        custLogin: custLogin,
        custId: http.custId,
        balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
        currency: userData['currency'] as String? ?? 'VND',
        status: userData['status'] as String? ?? 'Active',
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: http.userTokenSb,
        profilePending: false,
      );
    } else if (http.userToken.isNotEmpty) {
      AppLoggers.auth.i(
        'syncFromSbLogin: có token, profile đang nạp nền → pending',
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: state.user ?? UserModel.empty(),
        profilePending: true,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        profilePending: false,
      );
    }
  }

  void markProfileReady() {
    if (!state.profilePending) return;
    syncFromSbLogin();
    if (state.profilePending) {
      state = state.copyWith(profilePending: false);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final profilePendingProvider = Provider<bool>(
  (ref) => ref.watch(authProvider.select((s) => s.profilePending)),
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);

final userBalanceProvider = Provider<double>(
  (ref) => ref.watch(authProvider).user?.balance ?? 0.0,
);

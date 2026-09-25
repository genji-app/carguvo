import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/services/auth/auth_config_service.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/services/monitoring/login_timing.dart';
import 'package:sun_sports/core/utils/auth_validator.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_flow_result.dart';
import 'package:sun_sports/features/auth/domain/entities/username_check_result.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
import 'package:sun_sports/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/login_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/register_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/submit_otp_usecase.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SubmitOtpUseCase _submitOtpUseCase;
  final LogoutUseCase _logoutUseCase;

  final void Function()? onRegisterSuccess;

  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._submitOtpUseCase,
    this._logoutUseCase, {
    this.onRegisterSuccess,
  }) : super(const AuthState.initial());

  Future<bool> _ensureConfigReady() async {
    if (AuthConfigService.instance.isReady) return true;
    return SbLogin.initConfigOnly();
  }

  Future<void> _onAuthSuccess(
    AuthEntity auth,
    String username,
    String password,
  ) async {
    LoginTiming.current?.step('persist');
    await TokenManager.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      wsToken: auth.wsToken,
    );

    await UserManager.saveCredentials(username, password);

    await SbLogin.connect(isReconnect: false, freshLogin: true);

    state = AuthState.authenticated(auth);
  }

  Future<void> login(
    String username,
    String password, {
    String source = 'form',
  }) async {
    state = const AuthState.loading();

    final timing = LoginTiming.start(source);
    try {
      timing.step('config');
      if (!await _ensureConfigReady()) {
        timing.finish('no-config');
        state = const AuthState.error(genericErrorMessage);
        return;
      }

      timing.step('login');
      final result = await _loginUseCase(
        LoginRequest(username: username, password: password),
      );

      switch (result) {
        case AuthFlowSuccess(:final auth):
          await _onAuthSuccess(auth, username, password);
          timing.finish('ok');
        case AuthFlowOtpRequired(:final sessionId, :final message):
          timing.finish('otp');
          state = AuthState.otpRequired(
            sessionId: sessionId,
            message: message ?? 'Vui lòng nhập mã OTP',
            username: username,
            password: password,
          );
        case AuthFlowFailure(:final message, :final showPopup):
          timing.finish('rejected');
          state = AuthState.error(message, showPopup: showPopup);
      }
    } catch (e, st) {
      final report = timing.finish('failed');
      AppLoggers.auth.e('login exception ($report)', error: e, stackTrace: st);
      state = const AuthState.error(genericErrorMessage);
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String displayName,
    String? affId,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmContent,
    String? utmTerm,
  }) async {
    state = const AuthState.loading();

    final timing = LoginTiming.start('register');
    try {
      timing.step('config');
      if (!await _ensureConfigReady()) {
        timing.finish('no-config');
        state = const AuthState.error(genericErrorMessage);
        return;
      }

      timing.step('login');
      final result = await _registerUseCase(
        RegisterRequest(
          username: username,
          password: password,
          displayName: displayName,
          affId: affId,
          utmSource: utmSource,
          utmMedium: utmMedium,
          utmCampaign: utmCampaign,
          utmContent: utmContent,
          utmTerm: utmTerm,
        ),
      );

      switch (result) {
        case AuthFlowSuccess(:final auth):
          await _onAuthSuccess(auth, username, password);
          timing.finish('ok');
          onRegisterSuccess?.call();
        case AuthFlowOtpRequired(:final message, :final showPopup):
          timing.finish('otp');
          state = AuthState.error(
            message ?? 'Đã xảy ra lỗi',
            showPopup: showPopup,
          );
        case AuthFlowFailure(:final message, :final showPopup):
          timing.finish('rejected');
          state = AuthState.error(message, showPopup: showPopup);
      }
    } catch (e, st) {
      final report = timing.finish('failed');
      AppLoggers.auth.e('register exception ($report)', error: e, stackTrace: st);
      state = const AuthState.error(genericErrorMessage);
    }
  }

  Future<void> submitOtp({
    required String sessionId,
    required String otp,
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();

    final timing = LoginTiming.start('otp');
    try {
      timing.step('config');
      if (!await _ensureConfigReady()) {
        timing.finish('no-config');
        state = const AuthState.error(genericErrorMessage);
        return;
      }

      timing.step('login');
      final result = await _submitOtpUseCase(
        OtpRequest(
          sessionId: sessionId,
          otp: otp,
          username: username,
          password: password,
        ),
      );

      switch (result) {
        case AuthFlowSuccess(:final auth):
          await _onAuthSuccess(auth, username, password);
          timing.finish('ok');
        case AuthFlowOtpRequired(:final message):
          timing.finish('otp');
          state = AuthState.error(message ?? 'Đã xảy ra lỗi');
        case AuthFlowFailure(:final message):
          timing.finish('rejected');
          state = AuthState.error(message);
      }
    } catch (e, st) {
      final report = timing.finish('failed');
      AppLoggers.auth.e('submitOtp exception ($report)', error: e, stackTrace: st);
      state = const AuthState.error(genericErrorMessage);
    }
  }

  Future<void> logout() async {
    state = const AuthState.unauthenticated();

    try {
      await _logoutUseCase();
    } catch (e) {
    }

    try {
      await SbLogin.logout();
    } catch (e, st) {
      AppLoggers.auth.e('SbLogin.logout failed', error: e, stackTrace: st);
    }
    try {
      await TokenManager.clearTokens();
      await UserManager.clearCredentials();
    } catch (e, st) {
      AppLoggers.auth.e('clear tokens failed', error: e, stackTrace: st);
    }
  }

  void markSignedOut() {
    state = const AuthState.unauthenticated();
  }

  Future<void> checkAuthStatus() async {
    final hasTokens = await TokenManager.hasTokens();
    if (hasTokens) {
      state = const AuthState.unauthenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void updateUsername(String username) {
    state = state.copyWith(
      username: username,
      usernameError: null,
      generalError: null,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null,
      generalError: null,
    );
  }

  bool validate() {
    final usernameError = AuthValidator.validateLoginUsername(state.username);
    final passwordError = AuthValidator.validateLoginPassword(state.password);

    state = state.copyWith(
      usernameError: usernameError,
      passwordError: passwordError,
    );

    return usernameError == null && passwordError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const LoginFormState();
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final CheckUsernameUseCase? _checkUsernameUseCase;

  RegisterFormNotifier([this._checkUsernameUseCase])
    : super(const RegisterFormState());

  Future<UsernameAvailability>? _usernameCheckInFlight;
  String? _usernameCheckInFlightFor;

  void updateUsername(String username) {
    if (username == state.username) return;
    state = state.copyWith(
      username: username,
      usernameError: null,
      generalError: null,
      usernameAvailability: UsernameAvailability.unknown,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null,
      generalError: null,
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: null,
      generalError: null,
    );
  }

  void updateDisplayName(String displayName) {
    state = state.copyWith(
      displayName: displayName,
      displayNameError: null,
      generalError: null,
    );
  }

  Future<UsernameAvailability> checkUsernameAvailability() {
    final username = state.username;
    if (_checkUsernameUseCase == null ||
        AuthValidator.validateRegisterUsername(username) != null) {
      return Future.value(UsernameAvailability.unknown);
    }
    final settled = state.usernameAvailability;
    if (settled != UsernameAvailability.unknown &&
        settled != UsernameAvailability.checking) {
      return Future.value(settled);
    }
    final inFlight = _usernameCheckInFlight;
    if (inFlight != null && _usernameCheckInFlightFor == username) {
      return inFlight;
    }
    final future = _runUsernameCheck(_checkUsernameUseCase, username);
    _usernameCheckInFlight = future;
    _usernameCheckInFlightFor = username;
    return future;
  }

  Future<UsernameAvailability> _runUsernameCheck(
    CheckUsernameUseCase useCase,
    String username,
  ) async {
    state = state.copyWith(usernameAvailability: UsernameAvailability.checking);

    var availability = UsernameAvailability.unknown;
    try {
      availability = switch (await useCase.call(username)) {
        UsernameCheckResult.available => UsernameAvailability.available,
        UsernameCheckResult.existsOnOtherBrand =>
          UsernameAvailability.existsOnOtherBrand,
        UsernameCheckResult.taken => UsernameAvailability.taken,
      };
    } catch (e) {
      AppLoggers.auth.w('[register] username check failed: $e');
    } finally {
      if (_usernameCheckInFlightFor == username) {
        _usernameCheckInFlight = null;
        _usernameCheckInFlightFor = null;
      }
    }

    if (mounted && state.username == username) {
      state = state.copyWith(usernameAvailability: availability);
    }
    return availability;
  }

  bool validate() {
    final usernameError = AuthValidator.validateRegisterUsername(
      state.username,
    );
    final passwordError = AuthValidator.validatePassword(state.password);
    final confirmPasswordError = AuthValidator.validateConfirmPassword(
      state.confirmPassword,
      state.password,
    );
    final displayNameError = AuthValidator.validateDisplayName(
      state.displayName,
      state.username,
    );

    state = state.copyWith(
      usernameError: usernameError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      displayNameError: displayNameError,
    );

    return usernameError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        displayNameError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const RegisterFormState();
  }
}

class OtpFormNotifier extends StateNotifier<OtpFormState> {
  OtpFormNotifier() : super(const OtpFormState());

  void updateOtp(String otp) {
    state = state.copyWith(otp: otp, otpError: null, generalError: null);
  }

  bool validate() {
    final otpError = AuthValidator.validateOtp(state.otp);

    state = state.copyWith(otpError: otpError);

    return otpError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const OtpFormState();
  }
}

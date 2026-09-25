import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthEntity auth) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(
    String message, {
    @Default(false) bool showPopup,
  }) = _Error;

  const factory AuthState.otpRequired({
    required String sessionId,
    required String message,
    required String username,
    required String password,
  }) = _OtpRequired;
}

@freezed
sealed class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String username,
    @Default('') String password,
    String? usernameError,
    String? passwordError,
    @Default(false) bool isSubmitting,
    String? generalError,
  }) = _LoginFormState;
}

@freezed
sealed class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String username,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String displayName,
    String? usernameError,
    String? passwordError,
    String? confirmPasswordError,
    String? displayNameError,
    @Default(false) bool isSubmitting,
    String? generalError,

    @Default(UsernameAvailability.unknown)
    UsernameAvailability usernameAvailability,
  }) = _RegisterFormState;
}

@freezed
sealed class OtpFormState with _$OtpFormState {
  const factory OtpFormState({
    @Default('') String otp,
    String? otpError,
    @Default(false) bool isSubmitting,
    String? generalError,
  }) = _OtpFormState;
}

const String kUsernameTakenMessage = 'Tên đăng nhập đã tồn tại';

enum UsernameAvailability {
  unknown,

  checking,

  available,

  taken,

  existsOnOtherBrand,
}

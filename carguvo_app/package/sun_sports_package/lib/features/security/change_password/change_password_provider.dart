import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';
import 'package:sun_sports/core/utils/auth_validator.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

part 'change_password_provider.freezed.dart';

class _ErrorMessages {
  static const String emptyCurrentPassword = 'Vui lòng nhập mật khẩu hiện tại.';
  static const String emptyNewPassword = 'Vui lòng nhập mật khẩu mới.';
  static const String emptyConfirmPassword = 'Vui lòng xác nhận mật khẩu mới.';

  static const String passwordMismatch = 'Mật khẩu xác nhận không khớp.';
  static const String passwordSameAsOld =
      'Mật khẩu mới không được trùng với mật khẩu hiện tại.';
}

enum ChangePasswordStatus { initial, loading, success, failure, invalid }

@freezed
sealed class ChangePasswordState with _$ChangePasswordState {
  const ChangePasswordState._();

  const factory ChangePasswordState({
    @Default(ChangePasswordStatus.initial) ChangePasswordStatus status,
    String? errorMessage,
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
  }) = _ChangePasswordState;

  bool get isLoading => status == ChangePasswordStatus.loading;

  bool get isFormValid =>
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmPasswordError == null;

  bool get canSubmit => !isLoading && isFormValid;
}

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState>
    with LoggerMixin {
  ChangePasswordNotifier({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const ChangePasswordState());

  final UserRepository _userRepository;

  void setCurrentPassword(String value) {
    _updateFieldAndClearErrors(
      (state) => state.copyWith(currentPassword: value),
    );
    _validateCurrentPassword();

    if (state.newPassword.isNotEmpty) {
      _validateNewPassword();
    }
  }

  void setNewPassword(String value) {
    _updateFieldAndClearErrors((state) => state.copyWith(newPassword: value));
    _validateNewPassword();

    if (state.confirmPassword.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void setConfirmPassword(String value) {
    _updateFieldAndClearErrors(
      (state) => state.copyWith(confirmPassword: value),
    );
    _validateConfirmPassword();
  }

  void resetState() => state = const ChangePasswordState();

  Future<void> submit() async {
    if (state.status == ChangePasswordStatus.loading) return;

    if (!_validateAll()) {
      state = state.copyWith(status: ChangePasswordStatus.invalid);
      return;
    }

    await _performPasswordChange();
  }

  void _updateFieldAndClearErrors(
    ChangePasswordState Function(ChangePasswordState) update,
  ) {
    state = update(
      state,
    ).copyWith(errorMessage: null, status: ChangePasswordStatus.initial);
  }

  void _validateCurrentPassword() {
    final error = _getCurrentPasswordError(state.currentPassword);
    state = state.copyWith(currentPasswordError: error);
  }

  void _validateNewPassword() {
    final error = _getNewPasswordError(state.newPassword);
    state = state.copyWith(newPasswordError: error);
  }

  void _validateConfirmPassword() {
    final error = _getConfirmPasswordError(
      state.confirmPassword,
      state.newPassword,
    );
    state = state.copyWith(confirmPasswordError: error);
  }

  bool _validateAll() {
    final currentError = _getCurrentPasswordError(state.currentPassword);
    final newError = _getNewPasswordError(state.newPassword);
    final confirmError = _getConfirmPasswordError(
      state.confirmPassword,
      state.newPassword,
    );

    state = state.copyWith(
      currentPasswordError: currentError,
      newPasswordError: newError,
      confirmPasswordError: confirmError,
    );

    return currentError == null && newError == null && confirmError == null;
  }

  String? _getCurrentPasswordError(String value) {
    if (value.isEmpty) return _ErrorMessages.emptyCurrentPassword;
    return null;
  }

  String? _getNewPasswordError(String value) {
    if (value.isEmpty) return _ErrorMessages.emptyNewPassword;
    if (state.currentPassword.isNotEmpty && value == state.currentPassword) {
      return _ErrorMessages.passwordSameAsOld;
    }

    return AuthValidator.validatePasswordRealtime(value);
  }

  String? _getConfirmPasswordError(String confirmValue, String newValue) {
    if (confirmValue.isEmpty) return _ErrorMessages.emptyConfirmPassword;
    if (confirmValue != newValue) return _ErrorMessages.passwordMismatch;
    return null;
  }

  Future<void> _performPasswordChange() async {
    state = state.copyWith(status: ChangePasswordStatus.loading);
    _logSubmit();

    try {
      await _userRepository.changePassword(
        state.currentPassword,
        state.newPassword,
      );

      logInfo('Password changed successfully');
      _handleSuccess();
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      _handleError(e);
    }
  }

  void _handleSuccess() {
    state = state.copyWith(
      status: ChangePasswordStatus.success,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    );
  }

  void _handleError(Object error) {
    String errorMsg;
    if (error is UserFailure) {
      errorMsg = error.errorMessage ?? error.toString();
    } else {
      errorMsg = error.toString().replaceAll('Exception: ', '');
    }

    state = state.copyWith(
      status: ChangePasswordStatus.failure,
      errorMessage: errorMsg,
    );
  }

  void _logSubmit() {
    logInfo('Submitting...');
    logDebug('Current password length: ${state.currentPassword.length}');
    logDebug('New password length: ${state.newPassword.length}');
  }

  void _logError(Object error, StackTrace? stackTrace) {
    logError('Password change failed', error, stackTrace);
  }
}

final changePasswordProvider =
    StateNotifierProvider.autoDispose<
      ChangePasswordNotifier,
      ChangePasswordState
    >((ref) {
      return ChangePasswordNotifier(
        userRepository: ref.read(userRepositoryProvider),
      );
    });

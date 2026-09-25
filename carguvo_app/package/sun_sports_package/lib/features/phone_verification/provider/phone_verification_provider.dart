import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/auth_provider.dart'
    show authRepositoryProvider;
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

import 'phone_verification_validators.dart';

sealed class PhoneVerificationStatus {
  const PhoneVerificationStatus();
}

final class Initial extends PhoneVerificationStatus {
  const Initial();
}

final class RequestingOtp extends PhoneVerificationStatus {
  const RequestingOtp();
}

final class VerifyingOtp extends PhoneVerificationStatus {
  const VerifyingOtp();
}

final class OtpSent extends PhoneVerificationStatus {
  final String? message;
  const OtpSent(this.message);
}

final class Verified extends PhoneVerificationStatus {
  const Verified();
}

final class ResendSuccess extends PhoneVerificationStatus {
  final String? message;
  const ResendSuccess(this.message);
}

final class RequestOtpFailed extends PhoneVerificationStatus {
  final String message;
  const RequestOtpFailed(this.message);
}

final class ResendOtpFailed extends PhoneVerificationStatus {
  final String message;
  const ResendOtpFailed(this.message);
}

final class VerifyOtpFailed extends PhoneVerificationStatus {
  final String message;
  const VerifyOtpFailed(this.message);
}

class PhoneVerificationState {
  final String phoneNumber;
  final PhoneVerificationStatus status;

  const PhoneVerificationState({
    this.phoneNumber = '',
    this.status = const Initial(),
  });

  bool get isProcessing => status is RequestingOtp || status is VerifyingOtp;
  bool get isOtpSent => status is OtpSent;
  bool get isVerified => status is Verified;
  bool get hasError =>
      status is RequestOtpFailed ||
      status is ResendOtpFailed ||
      status is VerifyOtpFailed;

  PhoneVerificationState copyWith({
    String? phoneNumber,
    PhoneVerificationStatus? status,
  }) {
    return PhoneVerificationState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
    );
  }
}

class PhoneVerificationNotifier extends StateNotifier<PhoneVerificationState>
    with LoggerMixin {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  PhoneVerificationNotifier({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       super(const PhoneVerificationState());

  String? validatePhone(String? value) => validatePhoneNumber(value);

  String? validateOtp(String? value) => validateOtpCode(value);

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  Future<bool> requestOtp(String phone) async {
    logInfo('Requesting OTP for $phone');
    state = state.copyWith(status: const RequestingOtp());

    try {
      final msg = await _authRepository.requestOtp(phone);
      state = state.copyWith(
        phoneNumber: phone,
        status: OtpSent(msg),
      );
      logInfo('OTP sent successfully: $msg');
      return true;
    } catch (e, stackTrace) {
      logError('Error requesting OTP', e, stackTrace);
      final errorMsg =
          (e is AuthFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: RequestOtpFailed(errorMsg));
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    logInfo('Verifying OTP');
    state = state.copyWith(status: const VerifyingOtp());

    try {
      await _userRepository.verifyPhone(
        phoneNumber: state.phoneNumber,
        otp: otp,
      );
      state = state.copyWith(status: const Verified());
      logInfo('Account activated successfully for ${state.phoneNumber}');
      return true;
    } catch (e, stackTrace) {
      logError('Error verifying OTP', e, stackTrace);
      final errorMsg =
          (e is UserFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: VerifyOtpFailed(errorMsg));
      return false;
    }
  }

  Future<bool> resendOtp() async {
    logInfo('Resending OTP to ${state.phoneNumber}');

    try {
      final msg = await _authRepository.requestOtp(state.phoneNumber);
      state = state.copyWith(
        status: ResendSuccess(msg),
      );
      logInfo('OTP resent successfully: $msg');
      return true;
    } catch (e, stackTrace) {
      logError('Error resending OTP', e, stackTrace);
      final errorMsg =
          (e is AuthFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: ResendOtpFailed(errorMsg));
      return false;
    }
  }

  void clearStatus() {
    state = state.copyWith(status: const Initial());
  }

  void reset() {
    state = const PhoneVerificationState();
  }
}

final phoneVerificationProvider =
    StateNotifierProvider.autoDispose<
      PhoneVerificationNotifier,
      PhoneVerificationState
    >((ref) {
      return PhoneVerificationNotifier(
        authRepository: ref.watch(authRepositoryProvider),
        userRepository: ref.watch(userRepositoryProvider),
      );
    });

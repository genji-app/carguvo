import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/phone_verification/phone_verification.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class PhoneVerificationView extends ConsumerWidget {
  const PhoneVerificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(phoneVerificationProvider);
    final notifier = ref.read(phoneVerificationProvider.notifier);
    final currentStep = _deriveStepFromStatus(state.status);

    _setupToastListener(ref, context);

    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildContent(context, currentStep, state, notifier)],
      ),
    );
  }

  void _setupToastListener(WidgetRef ref, BuildContext context) {
    ref.listen(phoneVerificationProvider, (previous, next) {
      VerificationToastHandler.handleStatusChange(context, next.status);

      if (next.status is Verified) {
        ref.read(userProvider.notifier).fetchUserInfo();
      }
    });
  }

  Widget _buildContent(
    BuildContext context,
    VerificationStep currentStep,
    PhoneVerificationState state,
    PhoneVerificationNotifier notifier,
  ) {
    return switch (currentStep) {
      VerificationStep.success => _buildSuccessView(state),
      VerificationStep.phone => _buildPhoneInputView(notifier),
      VerificationStep.otp => _buildOtpInputView(state, notifier),
    };
  }

  Widget _buildSuccessView(PhoneVerificationState state) {
    return VerifySuccessBanner(phoneNumber: state.phoneNumber);
  }

  Widget _buildPhoneInputView(PhoneVerificationNotifier notifier) {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationDescription(),
        VerificationCard(
          title: I18n.txtVerifyByPhone,
          subtitle: I18n.msgEnterPhoneToReceiveOTP,
          form: PhoneInputForm(
            onSubmit: notifier.requestOtp,
            validator: notifier.validatePhone,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputView(
    PhoneVerificationState state,
    PhoneVerificationNotifier notifier,
  ) {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationDescription(),
        VerificationCard(
          title: I18n.txtVerifyByPhone,
          subtitle:
              '${I18n.msgEnterOTPSentTo} ${formatPhoneForPrivacy(state.phoneNumber)}',
          form: OtpInputForm(
            validator: notifier.validateOtp,
            onResend: notifier.resendOtp,
            onSubmit: notifier.verifyOtp,
          ),
        ),
      ],
    );
  }
}

enum VerificationStep {
  phone,

  otp,

  success,
}

VerificationStep _deriveStepFromStatus(PhoneVerificationStatus status) {
  return switch (status) {
    Initial() ||
    RequestingOtp() ||
    RequestOtpFailed() => VerificationStep.phone,

    OtpSent() ||
    ResendSuccess() ||
    ResendOtpFailed() ||
    VerifyingOtp() ||
    VerifyOtpFailed() => VerificationStep.otp,

    Verified() => VerificationStep.success,
  };
}

class VerificationToastHandler {
  static void handleStatusChange(
    BuildContext context,
    PhoneVerificationStatus status,
  ) {
    switch (status) {
      case RequestOtpFailed(:final message):
      case ResendOtpFailed(:final message):
      case VerifyOtpFailed(:final message):
        AppToast.showError(
          context,
          message: localizedOrGenericError('Xác thực OTP', message),
        );

      case OtpSent(:final message):
        _showSuccessToast(context, message, I18n.msgOTPSent);

      case ResendSuccess(:final message):
        _showSuccessToast(context, message, I18n.msgOTPResent);

      case Initial():
      case RequestingOtp():
      case VerifyingOtp():
      case Verified():
        break;
    }
  }

  static void _showSuccessToast(
    BuildContext context,
    String? message,
    String fallback,
  ) {
    AppToast.showSuccess(context, message: message ?? fallback);
  }
}

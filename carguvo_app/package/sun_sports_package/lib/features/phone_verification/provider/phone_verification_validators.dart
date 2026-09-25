import 'package:auth_domain/auth_domain.dart' show maskPhoneNumber;
import 'package:sun_sports/core/constants/i18n.dart';

final RegExp _phoneRegex = RegExp(r'^0[3|5|7|8|9]\d{8}$');

final RegExp _otpRegex = RegExp(r'^\d{6}$');

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return I18n.errPhoneRequired;
  }

  if (value.length < 10) {
    return I18n.errPhoneMinLength;
  }

  if (value.length > 10) {
    return I18n.errPhoneMaxLength;
  }

  if (!_phoneRegex.hasMatch(value)) {
    return I18n.errPhoneInvalid;
  }

  return null;
}

String? validateOtpCode(String? value) {
  if (value == null || value.isEmpty) {
    return I18n.errOTPRequired;
  }

  if (!_otpRegex.hasMatch(value)) {
    return I18n.errOTPInvalid;
  }

  return null;
}

String formatPhoneForPrivacy(String phoneNumber) {
  return maskPhoneNumber(phoneNumber);
}

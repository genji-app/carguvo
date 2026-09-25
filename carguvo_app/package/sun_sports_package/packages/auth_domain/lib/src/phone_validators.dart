library;

bool isValidVnPhonePattern(String value) =>
    RegExp(r'^0[3|5|7|8|9]\d{8}$').hasMatch(value);

bool isValidOtpPattern(String value) =>
    RegExp(r'^\d{6}$').hasMatch(value);

enum VnPhoneError { required, tooShort, tooLong, invalid }

enum OtpError { required, invalid }

VnPhoneError? validateVnPhoneKind(String? value) {
  if (value == null || value.isEmpty) return VnPhoneError.required;
  if (value.length < 10) return VnPhoneError.tooShort;
  if (value.length > 10) return VnPhoneError.tooLong;
  if (!isValidVnPhonePattern(value)) return VnPhoneError.invalid;
  return null;
}

OtpError? validateOtpKind(String? value) {
  if (value == null || value.isEmpty) return OtpError.required;
  if (!isValidOtpPattern(value)) return OtpError.invalid;
  return null;
}

String maskPhoneNumber(String? phoneNumber) {
  final value = phoneNumber?.trim();
  if (value == null || value.isEmpty) return '-';
  if (value.length < 4) return value;
  return '${value.substring(0, 2)}******${value.substring(value.length - 2)}';
}

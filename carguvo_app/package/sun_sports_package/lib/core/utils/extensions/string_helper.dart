class StringHelper {
  StringHelper._();

  static String maskPhone(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return '-';

    final trimmedPhone = phoneNumber.trim();
    if (trimmedPhone.length < 4) return trimmedPhone;

    return '${trimmedPhone.substring(0, 2)}******${trimmedPhone.substring(trimmedPhone.length - 2)}';
  }
}

extension StringExtension on String {
  String maskPhone() => StringHelper.maskPhone(this);
}

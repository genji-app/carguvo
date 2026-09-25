
class BankType {
  static const int eWallet = 2;
}

class DepositAnimationDurations {
  static const Duration navigationDelay = Duration(milliseconds: 300);

  static const Duration dialogPopDelay = Duration(milliseconds: 400);
}

class DepositUIConstants {
  static const double defaultSpacing = 24.0;

  static const double bottomSpacing = 32.0;

  static const double formFieldHeight = 48.0;

  static const double borderRadius = 12.0;
}

class DepositErrorMessages {
  static const String invalidDenomination = 'Mệnh giá không hợp lệ';
  static const String pleaseCheckInfo = 'Vui lòng kiểm tra lại thông tin';
  static const String processing =
      'Chúng tôi đang xác nhận. Vui lòng đợi vài phút !';
}

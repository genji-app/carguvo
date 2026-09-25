library;

import 'package:app_format/app_format.dart';

const String bettingApiPlaceBetFailureFallback =
    'Đặt cược thất bại. Vui lòng thử lại!';

const String bettingApiOddsChangedRetryMessage =
    'Kèo đã thay đổi! Vui lòng thử lại.';

bool bettingApiPlaceBetOfferStale(int? errorCode) =>
    errorCode == 607 ||
    errorCode == 611 ||
    errorCode == 613 ||
    errorCode == 619 ||
    errorCode == 620 ||
    errorCode == 622;

bool bettingApiPlaceBetBasisChanged(int? errorCode) =>
    bettingApiPlaceBetOfferStale(errorCode) ||
    errorCode == 602 ||
    errorCode == 603 ||
    errorCode == 604 ||
    errorCode == 612;

const String bettingApiParlayComboFailureFallback =
    'Đặt cược xiên thất bại. Vui lòng thử lại!';

const String bettingApiCalculateBetFailureFallback =
    'Không thể tính toán cược. Vui lòng thử lại!';

const String bettingApiCalculateParlayFailureFallback =
    'Không thể tính toán cược xiên. Vui lòng thử lại!';

const String betInsufficientBalanceMessage =
    'Bạn không đủ số dư để cược, vui lòng nạp thêm!';

String? bettingApiErrorMessage(int? errorCode) {
  switch (errorCode) {
    case 400:
      return 'Yêu cầu không hợp lệ!';
    case 600:
      return betInsufficientBalanceMessage;
    case 601:
      return 'Trận đấu không tồn tại. Vui lòng thử lại!';
    case 602:
      return 'Kèo không tồn tại. Vui lòng thử lại!';
    case 603:
      return 'Tỷ lệ cược đã thay đổi';
    case 604:
      return 'Tỷ số đã thay đổi';
    case 605:
      return 'Số tiền cược phải lớn hơn mức cược tối thiểu!';
    case 606:
      return 'Số tiền cược phải nhỏ hơn mức cược tối đa!';
    case 607:
      return 'Không tìm thấy tỷ lệ cược';
    case 608:
    case 609:
    case 610:
      return 'Bạn không thể cược tỷ lệ này!';
    case 611:
    case 613:
      return 'Không tìm thấy tỷ lệ cược';
    case 614:
      return 'Người chơi đã bị khóa. Vui lòng liên hệ CSKH.';
    case 615:
      return 'Tiền cược không được nhỏ hơn mức cược tối thiểu!';
    case 616:
      return 'Tỷ lệ kèo không hỗ trợ, vui lòng thử lại hoặc chọn kèo khác.';
    case 617:
      return 'Số tiền cược phải nhỏ hơn mức cược tối đa!';
    case 618:
      return 'Vượt mức số tiền đặt của kèo này. Vui lòng thử lại với số '
          'tiền nhỏ hơn hoặc chọn kèo khác.';
    default:
      return null;
  }
}

String bettingApiErrorDisplayMessage(
  int? errorCode, {
  String? serverMessage,
  required String fallback,
  TechnicalErrorReporter? onTechnical,
}) {
  final mapped = bettingApiErrorMessage(errorCode);
  if (mapped != null) {
    return mapped;
  }
  return localizedOrGenericError(
    'Betting error (code=$errorCode)',
    serverMessage,
    fallback: fallback,
    onTechnical: onTechnical,
  );
}

bool bettingApiErrorIsMoneyRelated(int? errorCode) {
  return errorCode == 600 ||
      errorCode == 605 ||
      errorCode == 606 ||
      errorCode == 615 ||
      errorCode == 617 ||
      errorCode == 618;
}

bool bettingApiErrorIndicatesOddsChanged({
  required int? errorCode,
  String? message,
}) {
  if (errorCode == 603) {
    return true;
  }
  final t = message ?? '';
  return t.toLowerCase().contains('lệ cược đã thay đổi') || t.toLowerCase().contains('kèo đã thay đổi');
}

import 'package:app_format/app_format.dart' as af;
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

const String genericErrorMessage = 'Đã có lỗi xảy ra, vui lòng thử lại';

bool isVietnameseMessage(String? message) => af.isVietnameseMessage(message);

String localizedOrGenericError(String where, String? message, {String? fallback}) =>
    af.localizedOrGenericError(
      where,
      message,
      fallback: fallback ?? genericErrorMessage,
      onTechnical: (w, d) {
        LogHelper.error('$w: $d');
        SentryService.captureBackendError(w, d);
      },
    );

String logAndGenericError(String where, Object? detail) {
  LogHelper.error('$where: $detail');
  SentryService.captureBackendError(where, '$detail');
  return genericErrorMessage;
}

String formatMoneySeparators(String message) => af.formatMoneySeparators(message);

String localizedMoneyError(String where, String? message, {String? fallback}) =>
    formatMoneySeparators(
      localizedOrGenericError(where, message, fallback: fallback),
    );

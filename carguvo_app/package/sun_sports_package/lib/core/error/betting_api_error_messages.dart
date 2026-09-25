export 'package:betting_domain/betting_domain.dart'
    show
        bettingApiPlaceBetFailureFallback,
        bettingApiOddsChangedRetryMessage,
        bettingApiPlaceBetOfferStale,
        bettingApiPlaceBetBasisChanged,
        bettingApiParlayComboFailureFallback,
        bettingApiCalculateBetFailureFallback,
        bettingApiCalculateParlayFailureFallback,
        betInsufficientBalanceMessage,
        bettingApiErrorMessage,
        bettingApiErrorIsMoneyRelated,
        bettingApiErrorIndicatesOddsChanged;

import 'package:betting_domain/betting_domain.dart' as bd;
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

String bettingApiErrorDisplayMessage(
  int? errorCode, {
  String? serverMessage,
  required String fallback,
}) =>
    bd.bettingApiErrorDisplayMessage(
      errorCode,
      serverMessage: serverMessage,
      fallback: fallback,
      onTechnical: (where, detail) {
        LogHelper.error('$where: $detail');
        SentryService.captureBackendError(where, detail);
      },
    );

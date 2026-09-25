import 'package:sun_sports/core/services/sportbook_api.dart';

extension SunApiResponseX<T> on SunApiResponse<T> {
  T get dataOrThrow => map(
    success: (s) => s.data as T,
    failure: (f) => throw SunApiException(
      message: f.error ?? f.messageKey,
      messageKey: f.messageKey,
      status: f.code,
      data: f.data,
    ),
  );
}

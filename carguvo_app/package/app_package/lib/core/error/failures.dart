import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({required String message, int? statusCode}) =
      ServerFailure;

  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    @Default('Cache error occurred') String message,
  }) = CacheFailure;

  const factory Failure.parse({
    @Default('Failed to parse data') String message,
  }) = ParseFailure;

  const factory Failure.authentication({
    @Default('Authentication failed') String message,
  }) = AuthenticationFailure;

  const factory Failure.authorization({
    @Default('Access denied') String message,
  }) = AuthorizationFailure;

  const factory Failure.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundFailure;

  const factory Failure.timeout({@Default('Request timeout') String message}) =
      TimeoutFailure;

  const factory Failure.validation({
    @Default('Validation failed') String message,
    Map<String, dynamic>? errors,
  }) = ValidationFailure;

  const factory Failure.unexpected({
    @Default('An unexpected error occurred') String message,
  }) = UnexpectedFailure;
}

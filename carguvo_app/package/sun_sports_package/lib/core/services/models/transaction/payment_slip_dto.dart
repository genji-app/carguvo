import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_slip_dto.freezed.dart';
part 'payment_slip_dto.g.dart';

@freezed
sealed class PaymentSlipBankDto with _$PaymentSlipBankDto {
  const factory PaymentSlipBankDto({
    @JsonKey(name: 'bankId') required String bankId,
    @JsonKey(name: 'publicRss') required int publicRss,
    @JsonKey(name: 'type') required int type,
    @JsonKey(name: 'accountName') String? accountName,
    @JsonKey(name: 'accountNumber') String? accountNumber,
  }) = _PaymentSlipBankDto;

  factory PaymentSlipBankDto.fromJson(Map<String, Object?> json) =>
      _$PaymentSlipBankDtoFromJson(json);
}

@freezed
sealed class PaymentSlipDto with _$PaymentSlipDto {
  const factory PaymentSlipDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'transactionCode') required String transactionCode,
    @JsonKey(name: 'amount') required num amount,

    @JsonKey(name: 'type') required int type,

    @JsonKey(name: 'status') required int status,

    @JsonKey(name: 'slipType') required int slipType,

    @JsonKey(name: 'statusDescription') required String statusDescription,
    @JsonKey(name: 'bankSent') required PaymentSlipBankDto bankSent,
    @JsonKey(name: 'bankReceive') required PaymentSlipBankDto bankReceive,
    @JsonKey(name: 'requestTime') required int requestTime,
    @JsonKey(name: 'responseTime') required int responseTime,
    @JsonKey(name: 'notes') String? notes,
  }) = _PaymentSlipDto;

  factory PaymentSlipDto.fromJson(Map<String, Object?> json) =>
      _$PaymentSlipDtoFromJson(json);
}

@freezed
abstract class PaymentSlipResponseDto with _$PaymentSlipResponseDto {
  const factory PaymentSlipResponseDto({
    @JsonKey(name: 'count') required int count,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'items') required List<PaymentSlipDto> items,
  }) = _PaymentSlipResponseDto;

  factory PaymentSlipResponseDto.fromJson(Map<String, Object?> json) =>
      _$PaymentSlipResponseDtoFromJson(json);
}

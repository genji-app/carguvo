import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit_complains_dto.freezed.dart';
part 'deposit_complains_dto.g.dart';

@freezed
abstract class DepositComplainResponseDto with _$DepositComplainResponseDto {
  const factory DepositComplainResponseDto({
    @JsonKey(name: 'id') dynamic id,
    @JsonKey(name: '_id') dynamic objectId,
    @JsonKey(name: 'amount') num? amount,
    @JsonKey(name: 'value') num? value,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'type') int? type,
    @JsonKey(name: 'method') int? method,
    @JsonKey(name: 'statusDescription') String? statusDescription,
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'transactionCode') String? transactionCode,
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'ref') String? ref,
    @JsonKey(name: 'responseTime') int? responseTime,
    @JsonKey(name: 'requestTime') int? requestTime,
    @JsonKey(name: 'createdTime') int? createdTime,
    @JsonKey(name: 'createdAt') int? createdAt,
    @JsonKey(name: 'time') int? time,
  }) = _DepositComplainResponseDto;

  factory DepositComplainResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DepositComplainResponseDtoFromJson(json);
}

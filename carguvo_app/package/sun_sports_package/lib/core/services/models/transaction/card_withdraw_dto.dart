import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_withdraw_dto.freezed.dart';
part 'card_withdraw_dto.g.dart';

@freezed
abstract class CardWithdrawResponseDto with _$CardWithdrawResponseDto {
  const factory CardWithdrawResponseDto({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'requestTime') int? requestTime,
    @JsonKey(name: 'responseTime') int? responseTime,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'displayName') String? displayName,
    @JsonKey(name: 'userId') int? userId,
    @JsonKey(name: 'result') CardWithdrawResultDto? result,
    @JsonKey(name: 'item') CardWithdrawItemDto? item,
  }) = _CardWithdrawResponseDto;

  factory CardWithdrawResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CardWithdrawResponseDtoFromJson(json);
}

@freezed
abstract class CardWithdrawResultDto with _$CardWithdrawResultDto {
  const factory CardWithdrawResultDto({
    @JsonKey(name: 'code') dynamic code,
    @JsonKey(name: 'serial') dynamic serial,
  }) = _CardWithdrawResultDto;

  factory CardWithdrawResultDto.fromJson(Map<String, dynamic> json) =>
      _$CardWithdrawResultDtoFromJson(json);
}

@freezed
abstract class CardWithdrawItemDto with _$CardWithdrawItemDto {
  const factory CardWithdrawItemDto({
    @JsonKey(name: 'amount') num? amount,
    @JsonKey(name: 'price') num? price,
    @JsonKey(name: 'displayName') String? displayName,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'brand') String? brand,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'type') int? type,
    @JsonKey(name: 'telcoId') int? telcoId,
  }) = _CardWithdrawItemDto;

  factory CardWithdrawItemDto.fromJson(Map<String, dynamic> json) =>
      _$CardWithdrawItemDtoFromJson(json);
}

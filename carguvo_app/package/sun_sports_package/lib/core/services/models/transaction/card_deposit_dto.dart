import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_deposit_dto.freezed.dart';
part 'card_deposit_dto.g.dart';

@freezed
abstract class CardDepositResponseDto with _$CardDepositResponseDto {
  const factory CardDepositResponseDto({
    @JsonKey(name: 'amount') num? amount,
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'serial') String? serial,
    @JsonKey(name: 'network') String? network,
    @JsonKey(name: 'createdTime') int? createdTime,
    @JsonKey(name: 'statusMessage') String? statusMessage,
    @JsonKey(name: 'receivedAmount') num? receivedAmount,
    @JsonKey(name: 'slipId') dynamic slipId,
  }) = _CardDepositResponseDto;

  factory CardDepositResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CardDepositResponseDtoFromJson(json);
}

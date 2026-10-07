import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history_dto.freezed.dart';
part 'play_history_dto.g.dart';

@freezed
sealed class PlayHistoryResponseDto with _$PlayHistoryResponseDto {
  const factory PlayHistoryResponseDto({
    @Default(0) int count,
    @Default([]) List<PlayHistoryItemDto> items,
  }) = _PlayHistoryResponseDto;

  factory PlayHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryResponseDtoFromJson(json);
}

@freezed
sealed class PlayHistoryItemDto with _$PlayHistoryItemDto {
  const factory PlayHistoryItemDto({
    @Default(0) int activityType,
    @Default(0) int createdTime,
    @Default('') String serviceName,
    @Default('') String description,
    @Default(0.0) num closingValue,
    @Default(0.0) num exchangeValue,
  }) = _PlayHistoryItemDto;

  factory PlayHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryItemDtoFromJson(json);
}

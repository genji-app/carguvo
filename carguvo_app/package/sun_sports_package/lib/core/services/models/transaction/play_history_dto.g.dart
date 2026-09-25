
part of 'play_history_dto.dart';

_PlayHistoryResponseDto _$PlayHistoryResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PlayHistoryResponseDto(
  count: (json['count'] as num?)?.toInt() ?? 0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PlayHistoryItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlayHistoryResponseDtoToJson(
  _PlayHistoryResponseDto instance,
) => <String, dynamic>{
  'count': instance.count,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_PlayHistoryItemDto _$PlayHistoryItemDtoFromJson(Map<String, dynamic> json) =>
    _PlayHistoryItemDto(
      activityType: (json['activityType'] as num?)?.toInt() ?? 0,
      createdTime: (json['createdTime'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      closingValue: json['closingValue'] as num? ?? 0.0,
      exchangeValue: json['exchangeValue'] as num? ?? 0.0,
    );

Map<String, dynamic> _$PlayHistoryItemDtoToJson(_PlayHistoryItemDto instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'createdTime': instance.createdTime,
      'serviceName': instance.serviceName,
      'description': instance.description,
      'closingValue': instance.closingValue,
      'exchangeValue': instance.exchangeValue,
    };

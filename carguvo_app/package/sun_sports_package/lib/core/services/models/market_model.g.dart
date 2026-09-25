
part of 'market_model.dart';

_MarketModel _$MarketModelFromJson(Map<String, dynamic> json) => _MarketModel(
  id: json['id'] as String,
  name: json['name'] as String,
  cls: json['cls'] as String,
  odds:
      (json['odds'] as List<dynamic>?)
          ?.map((e) => SelectionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  description: json['description'] as String?,
);

Map<String, dynamic> _$MarketModelToJson(_MarketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cls': instance.cls,
      'odds': instance.odds.map((e) => e.toJson()).toList(),
      'isActive': instance.isActive,
      'description': instance.description,
    };

_SelectionModel _$SelectionModelFromJson(Map<String, dynamic> json) =>
    _SelectionModel(
      selectionId: json['selectionId'] as String,
      name: json['name'] as String,
      displayOdds: json['displayOdds'] as String,
      offerId: json['offerId'] as String,
      trueOdds: (json['trueOdds'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      handicap: (json['handicap'] as num?)?.toDouble(),
      line: (json['line'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SelectionModelToJson(_SelectionModel instance) =>
    <String, dynamic>{
      'selectionId': instance.selectionId,
      'name': instance.name,
      'displayOdds': instance.displayOdds,
      'offerId': instance.offerId,
      'trueOdds': instance.trueOdds,
      'isActive': instance.isActive,
      'handicap': instance.handicap,
      'line': instance.line,
    };

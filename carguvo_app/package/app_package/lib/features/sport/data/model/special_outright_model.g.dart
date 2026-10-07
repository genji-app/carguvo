
part of 'special_outright_model.dart';

_SpecialOutrightSelection _$SpecialOutrightSelectionFromJson(
  Map<String, dynamic> json,
) => _SpecialOutrightSelection(
  selectionId: json['0'] as String? ?? '',
  selectionName: json['1'] as String? ?? '',
  logoUrl: json['2'] as String? ?? '',
  offerId: json['3'] as String? ?? '',
  odds: json['4'] == null ? 0.0 : _safeParseDouble(json['4']),
  selectionCode: json['5'] as String? ?? '',
);

Map<String, dynamic> _$SpecialOutrightSelectionToJson(
  _SpecialOutrightSelection instance,
) => <String, dynamic>{
  '0': instance.selectionId,
  '1': instance.selectionName,
  '2': instance.logoUrl,
  '3': instance.offerId,
  '4': instance.odds,
  '5': instance.selectionCode,
};

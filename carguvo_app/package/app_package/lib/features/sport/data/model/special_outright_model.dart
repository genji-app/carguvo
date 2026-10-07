import 'package:freezed_annotation/freezed_annotation.dart';

part 'special_outright_model.freezed.dart';
part 'special_outright_model.g.dart';

double _safeParseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@freezed
sealed class SpecialOutrightModel with _$SpecialOutrightModel {
  const factory SpecialOutrightModel({
    @Default([]) List<SpecialOutrightSelection> selections,

    @Default(0) int outrightId,

    @Default(0) int eventId,

    @Default('') String outrightName,

    @Default('') String eventName,

    @Default(0) int lineOrder,

    @Default('') String endDate,

    @Default(0) int startTime,

    @Default(0) int leagueId,

    @Default('') String leagueLogo,

    @Default('') String leagueName,
  }) = _SpecialOutrightModel;
}

@freezed
sealed class SpecialOutrightSelection with _$SpecialOutrightSelection {
  const factory SpecialOutrightSelection({
    @JsonKey(name: '0') @Default('') String selectionId,

    @JsonKey(name: '1') @Default('') String selectionName,

    @JsonKey(name: '2') @Default('') String logoUrl,

    @JsonKey(name: '3') @Default('') String offerId,

    @JsonKey(name: '4', fromJson: _safeParseDouble) @Default(0.0) double odds,

    @JsonKey(name: '5') @Default('') String selectionCode,
  }) = _SpecialOutrightSelection;

  factory SpecialOutrightSelection.fromJson(Map<String, dynamic> json) =>
      _$SpecialOutrightSelectionFromJson(json);
}

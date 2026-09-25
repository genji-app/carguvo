import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

part 'odds_style_model_v2.freezed.dart';

@freezed
sealed class OddsStyleModelV2 with _$OddsStyleModelV2 {
  const factory OddsStyleModelV2({
    @Default('') String decimal,

    @Default('') String malay,

    @Default('') String indo,

    @Default('') String hk,
  }) = _OddsStyleModelV2;

  const OddsStyleModelV2._();

  factory OddsStyleModelV2.fromJson(Map<String, dynamic> json) {
    return OddsStyleModelV2(
      decimal: json['0']?.toString() ?? '',
      malay: json['1']?.toString() ?? '',
      indo: json['2']?.toString() ?? '',
      hk: json['3']?.toString() ?? '',
    );
  }

  double get decimalValue => double.tryParse(decimal) ?? 0.0;

  double get malayValue => double.tryParse(malay) ?? 0.0;

  double get indoValue => double.tryParse(indo) ?? 0.0;

  double get hkValue => double.tryParse(hk) ?? 0.0;

  bool get isValid => decimal.isNotEmpty && decimalValue > 0;

  String getOddsByFormat(OddsFormatV2 format) {
    switch (format) {
      case OddsFormatV2.decimal:
        return decimal;
      case OddsFormatV2.malay:
        return malay;
      case OddsFormatV2.indo:
        return indo;
      case OddsFormatV2.hk:
        return hk;
    }
  }

  double getValueByFormat(OddsFormatV2 format) {
    switch (format) {
      case OddsFormatV2.decimal:
        return decimalValue;
      case OddsFormatV2.malay:
        return malayValue;
      case OddsFormatV2.indo:
        return indoValue;
      case OddsFormatV2.hk:
        return hkValue;
    }
  }
}

enum OddsFormatV2 {
  decimal,
  malay,
  indo,
  hk;

  String get displayName {
    switch (this) {
      case OddsFormatV2.decimal:
        return 'Decimal';
      case OddsFormatV2.malay:
        return 'Malay';
      case OddsFormatV2.indo:
        return 'Indo';
      case OddsFormatV2.hk:
        return 'HK';
    }
  }
}

extension OddsStyleToFormatV2 on OddsStyle {
  OddsFormatV2 toOddsFormatV2() {
    switch (this) {
      case OddsStyle.malay:
        return OddsFormatV2.malay;
      case OddsStyle.indo:
        return OddsFormatV2.indo;
      case OddsStyle.hongKong:
        return OddsFormatV2.hk;
      case OddsStyle.decimal:
        return OddsFormatV2.decimal;
    }
  }
}

library;

import 'league_enums.dart';

class ResolvedStyleOdds {
  final double value;
  final OddsStyle style;
  const ResolvedStyleOdds({required this.value, required this.style});
}

class StyleOddsValues {
  final double? decimal;
  final double? malay;
  final double? indo;
  final double? hongKong;
  const StyleOddsValues({this.decimal, this.malay, this.indo, this.hongKong});
}

double? _validStyleValue(OddsStyle style, double? raw) {
  if (raw == null) return null;
  switch (style) {
    case OddsStyle.malay:
    case OddsStyle.indo:
    case OddsStyle.hongKong:
      return (raw == -100 || raw == 0) ? null : raw;
    case OddsStyle.decimal:
      return raw <= 0 ? null : raw;
  }
}

ResolvedStyleOdds? resolveStyleOdds(StyleOddsValues values, OddsStyle style) {
  double? byStyle(OddsStyle s) => switch (s) {
        OddsStyle.decimal => _validStyleValue(s, values.decimal),
        OddsStyle.malay => _validStyleValue(s, values.malay),
        OddsStyle.indo => _validStyleValue(s, values.indo),
        OddsStyle.hongKong => _validStyleValue(s, values.hongKong),
      };
  final native = byStyle(style);
  if (native != null) return ResolvedStyleOdds(value: native, style: style);
  for (final fallback in const [
    OddsStyle.decimal,
    OddsStyle.indo,
    OddsStyle.malay,
    OddsStyle.hongKong,
  ]) {
    if (fallback == style) continue;
    final v = byStyle(fallback);
    if (v != null) return ResolvedStyleOdds(value: v, style: fallback);
  }
  return null;
}

String? formatStyleOdds(StyleOddsValues values, OddsStyle style) =>
    resolveStyleOdds(values, style)?.value.toStringAsFixed(2);

String? formatLiveStyleOdds({
  required double? currentDecimal,
  required double malayValue,
  required double indoValue,
  required double hkValue,
  required OddsStyle style,
}) {
  if (currentDecimal == null) return null;
  final styled = switch (style) {
    OddsStyle.malay => malayValue,
    OddsStyle.decimal => currentDecimal,
    OddsStyle.indo => indoValue,
    OddsStyle.hongKong => hkValue,
  };
  final value = styled != 0 ? styled : currentDecimal;
  return value.toStringAsFixed(2);
}

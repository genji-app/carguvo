library;

String formatWithCommas(int value) {
  if (value == 0) return '0';
  final digits = value.abs().toString();
  final out = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

String formatCompact(int value) {
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();

  String unit(int divisor, String suffix) {
    final scaled = abs ~/ (divisor ~/ 100);
    final whole = scaled ~/ 100;
    final frac = scaled % 100;
    if (frac == 0) return '$sign$whole$suffix';
    final fracStr = frac.toString().padLeft(2, '0').replaceAll(
      RegExp(r'0+$'),
      '',
    );
    return '$sign$whole.$fracStr$suffix';
  }

  if (abs >= 1000000000) return unit(1000000000, 'B');
  if (abs >= 1000000) return unit(1000000, 'M');
  if (abs >= 1000) return unit(1000, 'K');
  return formatWithCommas(value);
}

String formatMoneySeparators(String message) =>
    message.replaceAll(RegExp(r'(?<=\d)\.(?=\d)'), ',');

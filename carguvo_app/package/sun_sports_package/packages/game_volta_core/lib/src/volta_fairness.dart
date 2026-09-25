import 'dart:convert';

import 'volta_platform.dart';

import 'package:crypto/crypto.dart';

enum VoltaFairnessVerdict {
  unknown,

  match,

  mismatch,
}

class VoltaFairness {
  const VoltaFairness._();

  static const bool trustMismatch = false;

  static String decodeUnicodeEscape(String input) {
    if (!input.contains(r'\u')) return input;
    return input.replaceAllMapped(
      _escapePattern,
      (Match m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
    );
  }

  static final RegExp _escapePattern = RegExp(r'\\u([0-9a-fA-F]{4})');

  static String forDisplay(String input) {
    if (!_hasSurrogate(input)) return input;

    final StringBuffer out = StringBuffer();
    bool repaired = false;
    for (int i = 0; i < input.length; i++) {
      final int unit = input.codeUnitAt(i);
      if (_isHigh(unit)) {
        final bool paired =
            i + 1 < input.length && _isLow(input.codeUnitAt(i + 1));
        if (paired) {
          out
            ..writeCharCode(unit)
            ..writeCharCode(input.codeUnitAt(i + 1));
          i++;
          continue;
        }
      } else if (!_isLow(unit)) {
        out.writeCharCode(unit);
        continue;
      }
      repaired = true;
      out.writeCharCode(0xFFFD);
    }
    return repaired ? out.toString() : input;
  }

  static bool _hasSurrogate(String input) {
    for (int i = 0; i < input.length; i++) {
      final int unit = input.codeUnitAt(i);
      if (_isHigh(unit) || _isLow(unit)) return true;
    }
    return false;
  }

  static bool _isHigh(int unit) => unit >= 0xD800 && unit <= 0xDBFF;

  static bool _isLow(int unit) => unit >= 0xDC00 && unit <= 0xDFFF;

  static String hashOf(String raw) =>
      md5.convert(utf8.encode(raw)).toString();

  static VoltaFairnessVerdict verify({
    required String? hash,
    required String? result,
  }) {
    if (hash == null || hash.isEmpty) return VoltaFairnessVerdict.unknown;
    if (result == null || result.isEmpty) return VoltaFairnessVerdict.unknown;
    final String computed = hashOf(decodeUnicodeEscape(result));
    return computed == hash.toLowerCase()
        ? VoltaFairnessVerdict.match
        : VoltaFairnessVerdict.mismatch;
  }

  static String? probeHashRecipe({
    required String hash,
    required String result,
  }) {
    if (hash.isEmpty || result.isEmpty) return null;
    final String want = hash.toLowerCase();
    final String decoded = decodeUnicodeEscape(result);

    final Map<String, String> candidates = <String, String>{
      'giải escape, nguyên văn (đang dùng)': decoded,
      'giải escape + trim': decoded.trim(),
      'giải escape + chữ thường': decoded.toLowerCase(),
      'giải escape + CHỮ HOA': decoded.toUpperCase(),
      'KHÔNG giải escape, nguyên xi': result,
      'KHÔNG giải escape + trim': result.trim(),
      'KHÔNG giải escape + chữ thường': result.toLowerCase(),
    };

    for (final MapEntry<String, String> entry in candidates.entries) {
      if (hashOf(entry.value) == want) return entry.key;
    }
    return null;
  }

  static void reportHashRecipe({required String hash, required String result}) {
    if (!voltaDebug) return;
    final String? recipe = probeHashRecipe(hash: hash, result: result);
    if (recipe == null) {
      voltaLog(() =>
        '🟠 Volta MD5: không công thức nào khớp — nhiều khả năng server có '
        'thêm salt. CHƯA được kết luận server sai. hash=$hash '
        'result=${result.length} ký tự',
      );
      return;
    }
    voltaLog(() =>
      '✅ Volta MD5: công thức khớp = "$recipe". Nếu đây là '
      '"giải escape, nguyên văn (đang dùng)" thì bật '
      'VoltaFairness.trustMismatch = true được rồi.',
    );
  }

  static String? badgeFor(VoltaFairnessVerdict verdict) => switch (verdict) {
    VoltaFairnessVerdict.match => 'Đã đối chiếu khớp',
    VoltaFairnessVerdict.mismatch => trustMismatch ? 'Mã không khớp' : null,
    VoltaFairnessVerdict.unknown => null,
  };
}

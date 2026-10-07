library;

typedef TechnicalErrorReporter = void Function(String where, String detail);

final RegExp _vietnameseChars = RegExp(
  '[ăâđêôơưàáảãạằắẳẵặầấẩẫậèéẻẽẹềếểễệìíỉĩịòóỏõọồốổỗộờớởỡợùúủũụừứửữựỳýỷỹỵ]',
);

bool isVietnameseMessage(String? message) {
  final s = message?.trim();
  if (s == null || s.isEmpty) return false;
  return _vietnameseChars.hasMatch(s.toLowerCase());
}

String localizedOrGenericError(
  String where,
  String? message, {
  String? fallback,
  TechnicalErrorReporter? onTechnical,
}) {
  final s = message?.trim() ?? '';
  if (isVietnameseMessage(s)) return s;
  if (s.isNotEmpty) onTechnical?.call(where, s);
  return fallback ?? 'Đã có lỗi xảy ra, vui lòng thử lại';
}

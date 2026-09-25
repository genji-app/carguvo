library;

const int kRecentListMaxItems = 5;

List<String> pushRecent(
  List<String> current,
  String item, {
  int maxItems = kRecentListMaxItems,
  bool caseInsensitive = false,
}) {
  final value = item.trim();
  final result = List<String>.of(current);
  if (value.isEmpty) return result;
  if (caseInsensitive) {
    final lower = value.toLowerCase();
    result.removeWhere((e) => e.toLowerCase() == lower);
  } else {
    result.remove(value);
  }
  result.insert(0, value);
  if (result.length > maxItems) result.removeRange(maxItems, result.length);
  return result;
}

String casinoRecentGameKey(
  String providerId,
  String productId,
  String gameCode,
) =>
    '$providerId|$productId|$gameCode';

const String kSoundEnabledRawKey = 'sbSoundEnabled';
const String kSoundEnabledWebStorageKey = 'flutter.sbSoundEnabled';

const bool kSoundEnabledDefault = true;

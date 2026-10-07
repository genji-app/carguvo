library;

const Map<String, String> _kViFold = {
  'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
  'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
  'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
  'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
  'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
  'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
  'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
  'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
  'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
  'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
  'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
  'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
  'đ': 'd',
};

const Map<String, String> _kAlias = {
  'h1': 'hiep 1',
  'h2': 'hiep 2',
  'hp': 'hiep phu',
  'tx': 'tai xiu',
  'ou': 'tai xiu',
  'hdp': 'keo chap',
  'ah': 'keo chap',
  'ts': 'ti so',
  'cs': 'ti so chinh xac',
  'pg': 'phat goc',
  'tt': 'toan tran',
  'ft': 'toan tran',
  'pen': 'penalty',
  '11m': 'penalty',
  'lc': 'le chan',
};

final Map<String, String> _normalizeCache = <String, String>{};

String normalizeMarketSearch(String raw) {
  final cached = _normalizeCache[raw];
  if (cached != null) return cached;

  final lower = raw.toLowerCase();
  final folded = StringBuffer();
  for (final ch in lower.split('')) {
    final mapped = _kViFold[ch] ?? ch;
    folded.write(mapped == 'y' ? 'i' : mapped);
  }

  final cleaned = StringBuffer();
  for (final ch in folded.toString().split('')) {
    final isDigit = ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;
    final isLetter = ch.codeUnitAt(0) >= 0x61 && ch.codeUnitAt(0) <= 0x7a;
    cleaned.write(isDigit || isLetter ? ch : ' ');
  }

  final split = StringBuffer();
  final chars = cleaned.toString();
  for (int i = 0; i < chars.length; i++) {
    final ch = chars[i];
    if (i > 0) {
      final prev = chars[i - 1];
      if (_isDigit(prev) != _isDigit(ch) && prev != ' ' && ch != ' ') {
        split.write(' ');
      }
    }
    split.write(ch);
  }

  final result = split
      .toString()
      .replaceAll('1 x 2', '1x2')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .join(' ');

  if (_normalizeCache.length > 512) _normalizeCache.clear();
  _normalizeCache[raw] = result;
  return result;
}

bool _isDigit(String ch) =>
    ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;

class MarketSearchQuery {
  MarketSearchQuery._(this.tokens, this.compact);

  final List<String> tokens;

  final String compact;

  factory MarketSearchQuery.parse(String raw) {
    final normalized = normalizeMarketSearch(raw);
    if (normalized.isEmpty) return MarketSearchQuery._(const [], '');
    final expanded = <String>[];
    for (final token in normalized.split(' ')) {
      final alias = _kAlias[token];
      if (alias != null) {
        expanded.addAll(alias.split(' '));
      } else {
        expanded.add(token);
      }
    }
    return MarketSearchQuery._(expanded, expanded.join());
  }

  bool get isEmpty => tokens.isEmpty;

  bool matches(String title) {
    if (isEmpty) return true;
    final hay = normalizeMarketSearch(title);
    final hayTokens = hay.split(' ');
    var allPresent = true;
    for (final token in tokens) {
      if (!_tokenPresent(hay, hayTokens, token)) {
        allPresent = false;
        break;
      }
    }
    if (allPresent) return true;
    if (compact.length < 4) return false;
    return hay.replaceAll(' ', '').contains(compact);
  }

  bool matchesFuzzy(String title) {
    if (isEmpty) return true;
    if (matches(title)) return true;
    final hay = normalizeMarketSearch(title);
    final hayTokens = hay.split(' ');
    for (final token in tokens) {
      if (_tokenPresent(hay, hayTokens, token)) continue;
      if (token.length < 4) return false;
      var near = false;
      for (final word in hayTokens) {
        if (_withinOneEdit(token, word)) {
          near = true;
          break;
        }
      }
      if (!near) return false;
    }
    return true;
  }
}

bool _tokenPresent(String hay, List<String> hayTokens, String token) {
  if (token.length >= 4) return hay.contains(token);
  for (final word in hayTokens) {
    if (word.startsWith(token)) return true;
  }
  return false;
}

bool _withinOneEdit(String a, String b) {
  final la = a.length;
  final lb = b.length;
  if ((la - lb).abs() > 1) return false;
  int i = 0, j = 0;
  var edited = false;
  while (i < la && j < lb) {
    if (a[i] == b[j]) {
      i++;
      j++;
      continue;
    }
    if (edited) return false;
    edited = true;
    if (la == lb) {
      i++;
      j++;
    } else if (la > lb) {
      i++;
    } else {
      j++;
    }
  }
  return (la - i) + (lb - j) + (edited ? 1 : 0) <= 1;
}

List<T> filterByMarketQuery<T>(
  List<T> items,
  String raw,
  String Function(T item) titleOf,
) {
  final query = MarketSearchQuery.parse(raw);
  if (query.isEmpty) return items;
  final strict = [
    for (final item in items)
      if (query.matches(titleOf(item))) item,
  ];
  if (strict.isNotEmpty) return strict;
  return [
    for (final item in items)
      if (query.matchesFuzzy(titleOf(item))) item,
  ];
}

bool marketTitleMatchesQuery(String title, String query) =>
    MarketSearchQuery.parse(query).matches(title);

String stripPeriodPrefix(String title, String? tabLabel) {
  if (tabLabel == null || tabLabel.isEmpty) return title;
  for (final sep in const [' - ', ' – ']) {
    final head = '$tabLabel$sep';
    if (!title.startsWith(head)) continue;
    final rest = title.substring(head.length).trim();
    return rest.isEmpty ? title : rest;
  }
  return title;
}

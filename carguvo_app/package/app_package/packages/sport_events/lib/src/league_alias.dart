library;

const int kLeagueAliasMaxLength = 24;

final RegExp _vlPrefix = RegExp(r'^vl(\s|$)', caseSensitive: false);
final RegExp _whitespace = RegExp(r'\s+');

class LeagueAliasTable {
  const LeagueAliasTable._(this.version, this._bySport);

  static const LeagueAliasTable empty = LeagueAliasTable._(0, {});

  final int version;

  final Map<int, Map<int, String>> _bySport;

  bool get isEmpty => _bySport.values.every((m) => m.isEmpty);

  int get length => _bySport.values.fold(0, (sum, m) => sum + m.length);

  static LeagueAliasTable? tryParse(Object? json) {
    if (json is! Map) return null;
    final version = _asInt(json['version']);
    if (version == null || version <= 0) return null;
    final sports = json['sports'];
    if (sports is! Map) return null;
    final bySport = <int, Map<int, String>>{};
    for (final MapEntry(key: sportKey, value: leagues) in sports.entries) {
      final sportId = _asInt(sportKey);
      if (sportId == null || leagues is! Map) continue;
      final labels = <int, String>{};
      for (final MapEntry(key: leagueKey, value: label) in leagues.entries) {
        final leagueId = _asInt(leagueKey);
        if (leagueId == null || leagueId <= 0 || label is! String) continue;
        final clean = normalizeLeagueName(label);
        if (isValidLeagueAlias(clean)) labels[leagueId] = clean;
      }
      if (labels.isNotEmpty) bySport[sportId] = labels;
    }
    return LeagueAliasTable._(version, bySport);
  }

  String? labelFor({required int sportId, required int leagueId}) => _bySport[sportId]?[leagueId];

  Map<String, Object> toJson() => {
    'version': version,
    'sports': {
      for (final MapEntry(key: sportId, value: labels) in _bySport.entries)
        '$sportId': {for (final MapEntry(key: id, value: label) in labels.entries) '$id': label},
    },
  };

  static int? _asInt(Object? value) => switch (value) {
    final int v => v,
    final String v => int.tryParse(v.trim()),
    _ => null,
  };
}

bool isValidLeagueAlias(String label) {
  if (label.isEmpty || label.runes.length > kLeagueAliasMaxLength) return false;
  if (_vlPrefix.hasMatch(label)) return false;
  return !label.runes.any((r) => r < 0x20 || r == 0x7f);
}

String normalizeLeagueName(String raw) {
  var s = raw;
  if (s.contains('&')) {
    s = s
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&');
  }
  return s.trim().replaceAll(_whitespace, ' ');
}

Map<int, String> leagueChipLabels(
  Iterable<({int id, String name})> leagues, {
  required int sportId,
  LeagueAliasTable table = LeagueAliasTable.empty,
}) {
  final full = <int, String>{};
  final alias = <int, String>{};
  final aliasUse = <String, int>{};
  for (final league in leagues) {
    full[league.id] = normalizeLeagueName(league.name);
    final label = table.labelFor(sportId: sportId, leagueId: league.id);
    if (label != null) {
      alias[league.id] = label;
      aliasUse[label] = (aliasUse[label] ?? 0) + 1;
    }
  }
  return {
    for (final MapEntry(key: id, value: name) in full.entries)
      id: switch (alias[id]) {
        final label? when aliasUse[label] == 1 => label,
        _ => name,
      },
  };
}

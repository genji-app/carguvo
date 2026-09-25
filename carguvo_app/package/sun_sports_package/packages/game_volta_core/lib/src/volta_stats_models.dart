import 'package:meta/meta.dart';
import 'volta_platform.dart';

import 'volta_models.dart';

@immutable
class VoltaStatsGrid {
  const VoltaStatsGrid({
    required this.results,
    required this.homeCount,
    required this.awayCount,
    required this.homePercent,
    required this.awayPercent,
  });

  final List<VoltaWinner> results;

  final int homeCount;
  final int awayCount;

  final int homePercent;
  final int awayPercent;

  bool get isEmpty => results.isEmpty;

  static const VoltaStatsGrid empty = VoltaStatsGrid(
    results: <VoltaWinner>[],
    homeCount: 0,
    awayCount: 0,
    homePercent: 50,
    awayPercent: 50,
  );

  static VoltaWinner _winnerOf(Object? code) {
    final String value = '$code'.trim().toUpperCase();
    return value == 'H' ? VoltaWinner.home : VoltaWinner.away;
  }

  static int? _percentOf(int home, int away) {
    final int total = home + away;
    if (total <= 0) return null;
    final int percent = (home * 100 / total).round();
    return percent < 0 ? 0 : (percent > 100 ? 100 : percent);
  }

  static int? _percentOfList(List<VoltaWinner> results) {
    if (results.isEmpty) return null;
    int home = 0;
    for (final VoltaWinner w in results) {
      if (w == VoltaWinner.home) home++;
    }
    return _percentOf(home, results.length - home);
  }

  static VoltaStatsGrid? parse(Object? body) {
    if (body is! List) return null;
    final Object? rawList = body.isNotEmpty ? body[0] : null;
    if (rawList is! List) return null;

    final List<VoltaWinner> results = List<VoltaWinner>.unmodifiable(
      <VoltaWinner>[for (final Object? code in rawList) _winnerOf(code)],
    );

    int at(int i) {
      final Object? v = i < body.length ? body[i] : null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final int homePercent =
        _percentOf(at(3), at(4)) ??
        _percentOf(at(1), at(2)) ??
        _percentOfList(results) ??
        50;

    return VoltaStatsGrid(
      results: results,
      homeCount: at(1),
      awayCount: at(2),
      homePercent: homePercent,
      awayPercent: 100 - homePercent,
    );
  }
}

@immutable
class VoltaEventStats {
  const VoltaEventStats({
    required this.hash,
    required this.result,
    this.homeName = '',
    this.awayName = '',
    this.homeLogo,
    this.awayLogo,
    this.homeForm = const <bool>[],
    this.awayForm = const <bool>[],
  });

  final String hash;
  final String result;
  final String homeName;
  final String awayName;
  final String? homeLogo;
  final String? awayLogo;

  final List<bool> homeForm;
  final List<bool> awayForm;

  bool get hasHash => hash.isNotEmpty;

  bool get hasResult => result.isNotEmpty;

  bool get hasForm => homeForm.isNotEmpty || awayForm.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaEventStats &&
          other.hash == hash &&
          other.result == result &&
          other.homeName == homeName &&
          other.awayName == awayName &&
          other.homeLogo == homeLogo &&
          other.awayLogo == awayLogo &&
          voltaListEquals(other.homeForm, homeForm) &&
          voltaListEquals(other.awayForm, awayForm);

  @override
  int get hashCode => Object.hash(
    hash,
    result,
    homeName,
    awayName,
    homeLogo,
    awayLogo,
    Object.hashAll(homeForm),
    Object.hashAll(awayForm),
  );
}

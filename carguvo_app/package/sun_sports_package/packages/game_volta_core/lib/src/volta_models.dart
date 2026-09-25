import 'package:meta/meta.dart';
import 'volta_platform.dart';

import 'volta_fairness.dart';

enum VoltaSide { home, away }

enum VoltaRoundPhase {
  idle,

  betting,

  playing,

  settling,

  result,
}

extension VoltaRoundPhaseX on VoltaRoundPhase {
  bool get acceptsBets => this == VoltaRoundPhase.betting;
}

enum VoltaWinner {
  unknown,
  home,
  away;

  static VoltaWinner fromCode(Object? code) => switch (code) {
    1 || '1' => VoltaWinner.home,
    2 || '2' => VoltaWinner.away,
    _ => VoltaWinner.unknown,
  };

  VoltaSide? get side => switch (this) {
    VoltaWinner.home => VoltaSide.home,
    VoltaWinner.away => VoltaSide.away,
    VoltaWinner.unknown => null,
  };
}

@immutable
class VoltaTeam {
  final String name;

  final String? logoUrl;

  final double odds;

  final String oddsText;

  final String? selectionId;

  const VoltaTeam({
    required this.name,
    required this.odds,
    this.oddsText = '',
    this.logoUrl,
    this.selectionId,
  });

  String get wireOdds {
    if (oddsText.isNotEmpty) return oddsText;
    final String text = odds.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaTeam &&
          other.name == name &&
          other.logoUrl == logoUrl &&
          other.odds == odds &&
          other.oddsText == oddsText &&
          other.selectionId == selectionId;

  @override
  int get hashCode =>
      Object.hash(name, logoUrl, odds, oddsText, selectionId);
}

@immutable
class VoltaRound {
  final String eventId;
  final VoltaTeam home;
  final VoltaTeam away;

  final int homeStake;
  final int awayStake;

  final int homePlayers;
  final int awayPlayers;

  final VoltaRoundPhase phase;
  final VoltaWinner winner;

  final String? md5Code;

  final String? resultCode;

  final VoltaFairnessVerdict fairness;

  final String? liveUrl;

  final int startSecond;

  const VoltaRound({
    required this.eventId,
    required this.home,
    required this.away,
    this.homeStake = 0,
    this.awayStake = 0,
    this.homePlayers = 0,
    this.awayPlayers = 0,
    this.phase = VoltaRoundPhase.idle,
    this.winner = VoltaWinner.unknown,
    this.md5Code,
    this.resultCode,
    this.fairness = VoltaFairnessVerdict.unknown,
    this.liveUrl,
    this.startSecond = 0,
  });

  VoltaTeam teamOf(VoltaSide side) =>
      side == VoltaSide.home ? home : away;

  int stakeOf(VoltaSide side) =>
      side == VoltaSide.home ? homeStake : awayStake;

  int playersOf(VoltaSide side) =>
      side == VoltaSide.home ? homePlayers : awayPlayers;

  VoltaRound copyWith({
    VoltaTeam? home,
    VoltaTeam? away,
    int? homeStake,
    int? awayStake,
    int? homePlayers,
    int? awayPlayers,
    VoltaRoundPhase? phase,
    VoltaWinner? winner,
    String? md5Code,
    String? resultCode,
    VoltaFairnessVerdict? fairness,
    String? liveUrl,
    int? startSecond,
  }) => VoltaRound(
    eventId: eventId,
    home: home ?? this.home,
    away: away ?? this.away,
    homeStake: homeStake ?? this.homeStake,
    awayStake: awayStake ?? this.awayStake,
    homePlayers: homePlayers ?? this.homePlayers,
    awayPlayers: awayPlayers ?? this.awayPlayers,
    phase: phase ?? this.phase,
    winner: winner ?? this.winner,
    md5Code: md5Code ?? this.md5Code,
    resultCode: resultCode ?? this.resultCode,
    fairness: fairness ?? this.fairness,
    liveUrl: liveUrl ?? this.liveUrl,
    startSecond: startSecond ?? this.startSecond,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaRound &&
          other.eventId == eventId &&
          other.home == home &&
          other.away == away &&
          other.homeStake == homeStake &&
          other.awayStake == awayStake &&
          other.homePlayers == homePlayers &&
          other.awayPlayers == awayPlayers &&
          other.phase == phase &&
          other.winner == winner &&
          other.md5Code == md5Code &&
          other.resultCode == resultCode &&
          other.fairness == fairness &&
          other.liveUrl == liveUrl &&
          other.startSecond == startSecond;

  @override
  int get hashCode => Object.hash(
    eventId,
    home,
    away,
    homeStake,
    awayStake,
    homePlayers,
    awayPlayers,
    phase,
    winner,
    md5Code,
    resultCode,
    fairness,
    liveUrl,
    startSecond,
  );
}

@immutable
class VoltaMyStake {
  final int home;
  final int away;

  const VoltaMyStake({this.home = 0, this.away = 0});

  static const VoltaMyStake empty = VoltaMyStake();

  int of(VoltaSide side) => side == VoltaSide.home ? home : away;

  int get total => home + away;

  bool get isEmpty => home == 0 && away == 0;

  VoltaMyStake add(VoltaSide side, int amount) => side == VoltaSide.home
      ? VoltaMyStake(home: home + amount, away: away)
      : VoltaMyStake(home: home, away: away + amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaMyStake && other.home == home && other.away == away;

  @override
  int get hashCode => Object.hash(home, away);
}

@immutable
class VoltaChip {
  final int value;

  final String label;

  const VoltaChip(this.value, this.label);

  static const List<VoltaChip> defaults = <VoltaChip>[
    VoltaChip(1000, '1K'),
    VoltaChip(10000, '10K'),
    VoltaChip(50000, '50K'),
    VoltaChip(100000, '100K'),
    VoltaChip(500000, '500K'),
    VoltaChip(5000000, '5M'),
    VoltaChip(20000000, '20M'),
  ];

  static const int defaultIndex = 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaChip && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);
}

@immutable
class VoltaHistoryCell {
  final VoltaWinner winner;

  const VoltaHistoryCell(this.winner);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaHistoryCell && other.winner == winner;

  @override
  int get hashCode => winner.hashCode;
}

@immutable
class VoltaMatchResult {
  final String homeName;
  final String awayName;
  final String? homeLogo;
  final String? awayLogo;
  final VoltaWinner winner;

  final DateTime finishedAt;

  final String md5Code;

  final String resultCode;

  const VoltaMatchResult({
    required this.homeName,
    required this.awayName,
    required this.winner,
    required this.finishedAt,
    required this.md5Code,
    required this.resultCode,
    this.homeLogo,
    this.awayLogo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaMatchResult &&
          other.homeName == homeName &&
          other.awayName == awayName &&
          other.homeLogo == homeLogo &&
          other.awayLogo == awayLogo &&
          other.winner == winner &&
          other.finishedAt == finishedAt &&
          other.md5Code == md5Code &&
          other.resultCode == resultCode;

  @override
  int get hashCode => Object.hash(
    homeName,
    awayName,
    homeLogo,
    awayLogo,
    winner,
    finishedAt,
    md5Code,
    resultCode,
  );
}

@immutable
class VoltaTeamForm {
  final String name;
  final String? logoUrl;

  final List<bool> results;

  const VoltaTeamForm({
    required this.name,
    required this.results,
    this.logoUrl,
  });

  int get wins => results.where((w) => w).length;

  int get losses => results.length - wins;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaTeamForm &&
          other.name == name &&
          other.logoUrl == logoUrl &&
          voltaListEquals(other.results, results);

  @override
  int get hashCode => Object.hash(name, logoUrl, Object.hashAll(results));
}

@immutable
class VoltaHeadToHead {
  final VoltaTeamForm home;
  final VoltaTeamForm away;

  const VoltaHeadToHead({required this.home, required this.away});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaHeadToHead && other.home == home && other.away == away;

  @override
  int get hashCode => Object.hash(home, away);
}

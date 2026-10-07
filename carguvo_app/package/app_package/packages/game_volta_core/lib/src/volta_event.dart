import 'package:meta/meta.dart';

import 'volta_wire.dart';

@immutable
class VoltaEvent {
  final int eventId;
  final String home;
  final String away;
  final String? homeLogo;
  final String? awayLogo;

  final int startSecond;
  final int finishSecond;

  final int won;

  final int matchType;
  final int homeStake;
  final int awayStake;
  final int homePlayers;
  final int awayPlayers;
  final double homeOdds;
  final double awayOdds;

  final String homeOddsText;
  final String awayOddsText;

  final String homeSelectionId;
  final String awaySelectionId;
  final String offerId;

  const VoltaEvent({
    required this.eventId,
    required this.home,
    required this.away,
    required this.startSecond,
    required this.finishSecond,
    required this.won,
    required this.matchType,
    required this.homeStake,
    required this.awayStake,
    required this.homePlayers,
    required this.awayPlayers,
    required this.homeOdds,
    required this.awayOdds,
    required this.homeSelectionId,
    required this.awaySelectionId,
    required this.offerId,
    this.homeOddsText = VoltaWireOdds.fallbackOddsText,
    this.awayOddsText = VoltaWireOdds.fallbackOddsText,
    this.homeLogo,
    this.awayLogo,
  });

  factory VoltaEvent.fromWire(VoltaWireEvent wire) {
    final VoltaWireOdds odds =
        wire.odds ??
        const VoltaWireOdds(
          homeOdds: VoltaWireOdds.fallbackOdds,
          awayOdds: VoltaWireOdds.fallbackOdds,
          homeSelectionId: '',
          awaySelectionId: '',
          offerId: '',
        );
    return VoltaEvent(
      eventId: wire.eventId,
      home: wire.home,
      away: wire.away,
      homeLogo: wire.homeLogo,
      awayLogo: wire.awayLogo,
      startSecond: wire.startSecond,
      finishSecond: wire.finishSecond,
      won: wire.won,
      matchType: wire.matchType,
      homeStake: wire.homeStake,
      awayStake: wire.awayStake,
      homePlayers: wire.homePlayers,
      awayPlayers: wire.awayPlayers,
      homeOdds: odds.homeOdds,
      awayOdds: odds.awayOdds,
      homeOddsText: odds.homeOddsText,
      awayOddsText: odds.awayOddsText,
      homeSelectionId: odds.homeSelectionId,
      awaySelectionId: odds.awaySelectionId,
      offerId: odds.offerId,
    );
  }

  VoltaEvent merge(VoltaWireEvent wire) {
    final VoltaWireOdds? odds = wire.odds;
    return VoltaEvent(
      eventId: eventId,
      home: wire.home.isEmpty ? home : wire.home,
      away: wire.away.isEmpty ? away : wire.away,
      homeLogo: wire.homeLogo ?? homeLogo,
      awayLogo: wire.awayLogo ?? awayLogo,
      startSecond: wire.startSecond == 0 ? startSecond : wire.startSecond,
      finishSecond: wire.finishSecond == 0 ? finishSecond : wire.finishSecond,
      won: wire.won == 0 ? won : wire.won,
      matchType: wire.matchType == 0 ? matchType : wire.matchType,
      homeStake: wire.homeStake,
      awayStake: wire.awayStake,
      homePlayers: wire.homePlayers,
      awayPlayers: wire.awayPlayers,
      homeOdds: odds?.homeOdds ?? homeOdds,
      awayOdds: odds?.awayOdds ?? awayOdds,
      homeOddsText: odds?.homeOddsText ?? homeOddsText,
      awayOddsText: odds?.awayOddsText ?? awayOddsText,
      homeSelectionId: odds?.homeSelectionId ?? homeSelectionId,
      awaySelectionId: odds?.awaySelectionId ?? awaySelectionId,
      offerId: odds?.offerId ?? offerId,
    );
  }

  VoltaEvent copyWith({int? startSecond, int? finishSecond, int? won}) =>
      VoltaEvent(
        eventId: eventId,
        home: home,
        away: away,
        homeLogo: homeLogo,
        awayLogo: awayLogo,
        startSecond: startSecond ?? this.startSecond,
        finishSecond: finishSecond ?? this.finishSecond,
        won: won ?? this.won,
        matchType: matchType,
        homeStake: homeStake,
        awayStake: awayStake,
        homePlayers: homePlayers,
        awayPlayers: awayPlayers,
        homeOdds: homeOdds,
        awayOdds: awayOdds,
        homeOddsText: homeOddsText,
        awayOddsText: awayOddsText,
        homeSelectionId: homeSelectionId,
        awaySelectionId: awaySelectionId,
        offerId: offerId,
      );

  bool get hasStart => startSecond != 0;
  bool get hasFinish => finishSecond != 0;
  bool get hasWinner => won == 1 || won == 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoltaEvent &&
          other.eventId == eventId &&
          other.home == home &&
          other.away == away &&
          other.homeLogo == homeLogo &&
          other.awayLogo == awayLogo &&
          other.startSecond == startSecond &&
          other.finishSecond == finishSecond &&
          other.won == won &&
          other.matchType == matchType &&
          other.homeStake == homeStake &&
          other.awayStake == awayStake &&
          other.homePlayers == homePlayers &&
          other.awayPlayers == awayPlayers &&
          other.homeOdds == homeOdds &&
          other.awayOdds == awayOdds &&
          other.homeOddsText == homeOddsText &&
          other.awayOddsText == awayOddsText &&
          other.homeSelectionId == homeSelectionId &&
          other.awaySelectionId == awaySelectionId &&
          other.offerId == offerId;

  @override
  int get hashCode => Object.hash(
    eventId,
    home,
    away,
    homeLogo,
    awayLogo,
    startSecond,
    finishSecond,
    won,
    matchType,
    homeStake,
    awayStake,
    homePlayers,
    Object.hash(awayPlayers, homeOdds, awayOdds, homeOddsText, awayOddsText,
        homeSelectionId, awaySelectionId, offerId),
  );
}

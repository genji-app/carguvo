import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

const Set<int> ftHandicapMarketIds = {5, 27, 201, 402, 509, 609, 709};

extension EventModelV2UIExtension on EventModelV2 {
  String get formattedTime {
    final dt = startDateTime;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year | $hour:$minute';
  }

  String get formattedDate {
    final dt = startDateTime;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  int get homeScoreInt {
    if (score == null) return 0;
    return int.tryParse(score!.homeScore) ?? 0;
  }

  int get awayScoreInt {
    if (score == null) return 0;
    return int.tryParse(score!.awayScore) ?? 0;
  }

  String get scoreString => '${homeScoreInt} - ${awayScoreInt}';

  String get minuteString {
    if (!isLive) return '';

    final minutes = gameTime > 0 ? (gameTime / 1000 / 60).ceil() : 0;

    if (minutes > 0) {
      return "$minutes'";
    }

    return 'LIVE';
  }

  GamePart get gamePartEnum => GamePart.fromInt(gamePart);

  int get yellowCardsHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).yellowCardsHome;
    }
    return 0;
  }

  int get yellowCardsAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).yellowCardsAway;
    }
    return 0;
  }

  int get redCardsHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).redCardsHome;
    }
    return 0;
  }

  int get redCardsAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).redCardsAway;
    }
    return 0;
  }

  int get cornersHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).homeCorner;
    }
    return 0;
  }

  int get cornersAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).awayCorner;
    }
    return 0;
  }

  int get homeScoreOT {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).homeScoreOT;
    }
    return 0;
  }

  int get awayScoreOT {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).awayScoreOT;
    }
    return 0;
  }

  bool get isOvertimePhase => gamePart > GamePart.regulaTimeFinished.value;

  int get displayHomeScore => homeScoreInt + homeScoreOT;

  int get displayAwayScore => awayScoreInt + awayScoreOT;

  bool get canBet => !isSuspended;

  bool get hasMarkets => markets.isNotEmpty;

  int get totalCardsHome => redCardsHome + yellowCardsHome;
  int get totalCardsAway => redCardsAway + yellowCardsAway;

  double? get ftHandicapPoints {
    for (final market in markets) {
      if (ftHandicapMarketIds.contains(market.marketId)) {
        return market.mainLineOdds?.pointsValue;
      }
    }
    return null;
  }

  bool get hasUpperTeam => (ftHandicapPoints ?? 0) != 0;

  bool get isHomeUpper => (ftHandicapPoints ?? 0) < 0;

  bool get isAwayUpper => (ftHandicapPoints ?? 0) > 0;
}

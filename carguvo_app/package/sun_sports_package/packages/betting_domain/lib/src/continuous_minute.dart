library;

import 'league_enums.dart';

const Set<int> kSoccerKnownGameParts = {
  2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
};

int continuousMatchMinute({required int gameTimeMs, required int? gamePart}) {
  final minutes = gameTimeMs > 0 ? gameTimeMs ~/ 60000 : 0;
  if (minutes <= 0) return 0;
  switch (GamePart.resolveLive(gamePart, gameTimeMinutes: minutes)) {
    case GamePart.secondHalf:
      return 45 + minutes;
    case GamePart.firstHalfExtraTime:
      return 90 + minutes;
    case GamePart.secondHalfExtraTime:
      return 105 + minutes;
    default:
      return minutes;
  }
}

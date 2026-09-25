import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

enum UpDownSuit {
  spade(1, red: false, porkerName: 'spade'),
  club(2, red: false, porkerName: 'club'),
  diamond(3, red: true, porkerName: 'diamond'),
  heart(4, red: true, porkerName: 'heart');

  final int code;
  final bool red;

  final String porkerName;

  const UpDownSuit(this.code, {required this.red, required this.porkerName});

  static UpDownSuit fromCode(int suitCode) {
    switch (suitCode) {
      case 1:
        return UpDownSuit.spade;
      case 2:
        return UpDownSuit.club;
      case 3:
        return UpDownSuit.diamond;
      default:
        return UpDownSuit.heart;
    }
  }

  String get assetPath {
    switch (this) {
      case UpDownSuit.spade:
        return MiniGameIcons.upDownSpades;
      case UpDownSuit.club:
        return MiniGameIcons.upDownClubs;
      case UpDownSuit.diamond:
        return MiniGameIcons.upDownDiamond;
      case UpDownSuit.heart:
        return MiniGameIcons.upDownHeart;
    }
  }
}

class UpDownCard {
  final int code;

  final UpDownSuit suit;

  final int rank;

  final int compareValue;

  final String label;

  const UpDownCard({
    required this.code,
    required this.suit,
    required this.rank,
    required this.compareValue,
    required this.label,
  });

  bool get isAce => compareValue == 14;

  String get _porkerRank => switch (rank) {
        1 => 'a',
        11 => 'j',
        12 => 'q',
        13 => 'k',
        _ => '$rank',
      };

  String get faceAsset => MiniGameIcons.porkerFace(suit.porkerName, _porkerRank);
}

UpDownCard decodeCard(int code) {
  final suitCode = code % 4 + 1;
  var rank = code ~/ 4 + 1;
  if (rank == 15) rank = 2;
  final compareValue = (rank == 1) ? 14 : rank;
  final label = switch (rank) {
    1 => 'A',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    _ => '$rank',
  };
  return UpDownCard(
    code: code,
    suit: UpDownSuit.fromCode(suitCode),
    rank: rank,
    compareValue: compareValue,
    label: label,
  );
}

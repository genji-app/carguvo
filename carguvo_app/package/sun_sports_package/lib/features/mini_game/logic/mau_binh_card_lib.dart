library;

import 'package:mini_game_protocol/mini_game_protocol.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_card.dart'
    show PorkerCard, PorkerSuit;
import 'package:sun_sports/mini/minipoker/widgets/minipoker_reels_rive.dart'
    show MinipokerReelCard, MinipokerSuit;

export 'package:mini_game_protocol/mini_game_protocol.dart'
    show MauBinhCard, MauBinhCardLib, MauBinhResult;

extension MauBinhCardUi on MauBinhCard {
  PorkerSuit get porkerSuit => switch (s) {
        1 => PorkerSuit.spade,
        2 => PorkerSuit.club,
        3 => PorkerSuit.diamond,
        _ => PorkerSuit.heart,
      };

  MinipokerReelCard toReelCard() =>
      MinipokerReelCard(rank: n == 14 ? 1 : n, suit: MinipokerSuit.fromCode(s));

  PorkerCard toPorkerCard() => PorkerCard(porkerSuit, porkerRank);
}

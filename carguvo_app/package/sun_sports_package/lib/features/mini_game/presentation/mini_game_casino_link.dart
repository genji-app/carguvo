import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/mini_game_selection.dart';

final requestOpenMiniGameProvider = StateProvider<MiniGameSelection?>(
  (ref) => null,
);

final casinoBackButtonVisibleProvider = StateProvider<bool>((ref) => false);

final casinoGameOpenProvider = StateProvider<bool>((ref) => false);

final casinoGameBodyLevelProvider = StateProvider<bool>((ref) => false);

final casinoBackRequestProvider = StateProvider<int>((ref) => 0);

MiniGameSelection? miniGameSelectionForGameCode(String? gameCode) {
  switch (gameCode) {
    case 'TAI_XIU_MINI-SUN':
      return MiniGameSelection.taiXiu;
    case 'HI_LO-SUN':
      return MiniGameSelection.trenDuoi;
    case 'DIAMOND-SUN':
      return MiniGameSelection.kimCuong;
    case 'MINI_POKER-SUN':
      return MiniGameSelection.miniPoker;
    case 'DRAGON_BALL-SUN':
      return MiniGameSelection.dragonBall;
    default:
      return null;
  }
}

bool isVoltaGameCode(String? gameCode) =>
    gameCode == 'VT' || gameCode == 'VTS';

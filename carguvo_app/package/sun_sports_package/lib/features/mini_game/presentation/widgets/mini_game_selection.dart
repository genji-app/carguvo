import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/features/mini_game/messages/slot_message.dart';

enum MiniGameSelection {
  taiXiu(BundleDefines.taiXiu),
  trenDuoi(BundleDefines.trenDuoi),
  kimCuong(BundleDefines.kimCuong),
  miniPoker(BundleDefines.miniPoker),
  dragonBall(BundleDefines.dragonBall);

  const MiniGameSelection(this.bundleKey);

  final String bundleKey;

  static MiniGameSelection? tryParseBundleKey(String key) {
    for (final value in MiniGameSelection.values) {
      if (value.bundleKey == key) return value;
    }
    return null;
  }
}

SlotGameId? slotGameFor(MiniGameSelection selection) {
  switch (selection) {
    case MiniGameSelection.kimCuong:
      return SlotGameId.kimCuong;
    case MiniGameSelection.miniPoker:
      return SlotGameId.miniPoker;
    case MiniGameSelection.dragonBall:
      return SlotGameId.dragonBall;
    case MiniGameSelection.taiXiu:
    case MiniGameSelection.trenDuoi:
      return null;
  }
}

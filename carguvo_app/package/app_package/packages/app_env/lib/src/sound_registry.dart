library;

class SoundFile {
  const SoundFile._();

  static const String uiTap = 'ui_tap.mp3';

  static const String addToBetslip = 'add_to_betslip.mp3';

  static const String removeFromBetslip = 'remove_from_betslip.mp3';

  static const String pushNotificationSucceed = 'push_notification_succeed.mp3';

  static const String pushNotificationFailed = 'push_notification_failed.mp3';

  static const String roiXiNgau = 'roi_xi_ngau.mp3';

  static const String taiXiuStart = 'tai_xiu_start.mp3';

  static const String txBetSuccess = 'tx_bet_success.mp3';

  static const String winSfx = 'win_sfx.mp3';

  static const String jackpot = 'jackpot.mp3';

  static const List<String> allForWarm = <String>[
    uiTap,
    addToBetslip,
    removeFromBetslip,
    pushNotificationSucceed,
    pushNotificationFailed,
    roiXiNgau,
    taiXiuStart,
    txBetSuccess,
    winSfx,
    jackpot,
  ];
}

enum SoundEffect {
  uiTap,

  addToBetslip,

  removeFromBetslip,

  pushNotificationSucceed,

  pushNotificationFailed,
}

extension SoundEffectFile on SoundEffect {
  String get file => switch (this) {
    SoundEffect.uiTap => SoundFile.uiTap,
    SoundEffect.addToBetslip => SoundFile.addToBetslip,
    SoundEffect.removeFromBetslip => SoundFile.removeFromBetslip,
    SoundEffect.pushNotificationSucceed => SoundFile.pushNotificationSucceed,
    SoundEffect.pushNotificationFailed => SoundFile.pushNotificationFailed,
  };
}

enum MiniGameSound {
  roiXiNgau,

  taiXiuStart,

  txBetSuccess,

  winSfx,

  jackpot,
}

extension MiniGameSoundFile on MiniGameSound {
  String get file => switch (this) {
    MiniGameSound.roiXiNgau => SoundFile.roiXiNgau,
    MiniGameSound.taiXiuStart => SoundFile.taiXiuStart,
    MiniGameSound.txBetSuccess => SoundFile.txBetSuccess,
    MiniGameSound.winSfx => SoundFile.winSfx,
    MiniGameSound.jackpot => SoundFile.jackpot,
  };
}

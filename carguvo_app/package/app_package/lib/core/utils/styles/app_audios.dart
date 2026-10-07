
class AppAudios {
  
  static String get addToBetslip => 'add_to_betslip.mp3';

  static String get removeFromBetslip => 'remove_from_betslip.mp3';

  static String get pushNotificationSucceed =>
      'push_notification_succeed.mp3';

  static String get pushNotificationFailed =>
      'push_notification_failed.mp3';

  static String get uiTap => 'ui_tap.mp3';

  static String get roiXiNgau => 'roi_xi_ngau.mp3';

  static String get taiXiuStart => 'tai_xiu_start.mp3';

  static String get txBetSuccess => 'tx_bet_success.mp3';

  static String get winSfx => 'win_sfx.mp3';

  static String get jackpot => 'jackpot.mp3';

  static String get voltaBetOk => 'volta_sfx_bet_ok.mp3';

  static String get voltaBetError => 'volta_sfx_bet_error.mp3';

  static String get voltaOdds => 'volta_sfx_odds.mp3';

  static String get voltaClick => 'volta_sfx_click.wav';

  static List<String> get remoteUrlsForPreload => [
    addToBetslip,
    removeFromBetslip,
    pushNotificationSucceed,
    pushNotificationFailed,
    uiTap,
    roiXiNgau,
    taiXiuStart,
    txBetSuccess,
    winSfx,
    jackpot,
  ];
}

enum AppSound {
  uiTap,
  addToBetslip,
  removeFromBetslip,
  pushNotificationSucceed,
  pushNotificationFailed,
}

extension AppSoundUrl on AppSound {
  String get url {
    switch (this) {
      case AppSound.uiTap:
        return AppAudios.uiTap;
      case AppSound.addToBetslip:
        return AppAudios.addToBetslip;
      case AppSound.removeFromBetslip:
        return AppAudios.removeFromBetslip;
      case AppSound.pushNotificationSucceed:
        return AppAudios.pushNotificationSucceed;
      case AppSound.pushNotificationFailed:
        return AppAudios.pushNotificationFailed;
    }
  }
}

enum MiniGameSound {
  roiXiNgau,

  taiXiuStart,

  txBetSuccess,

  winSfx,

  jackpot,

  voltaBetOk,

  voltaBetError,

  voltaOdds,

  voltaClick,
}

extension MiniGameSoundUrl on MiniGameSound {
  String get url {
    switch (this) {
      case MiniGameSound.roiXiNgau:
        return AppAudios.roiXiNgau;
      case MiniGameSound.taiXiuStart:
        return AppAudios.taiXiuStart;
      case MiniGameSound.txBetSuccess:
        return AppAudios.txBetSuccess;
      case MiniGameSound.winSfx:
        return AppAudios.winSfx;
      case MiniGameSound.jackpot:
        return AppAudios.jackpot;
      case MiniGameSound.voltaBetOk:
        return AppAudios.voltaBetOk;
      case MiniGameSound.voltaBetError:
        return AppAudios.voltaBetError;
      case MiniGameSound.voltaOdds:
        return AppAudios.voltaOdds;
      case MiniGameSound.voltaClick:
        return AppAudios.voltaClick;
    }
  }
}

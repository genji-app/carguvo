import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rive/rive.dart' show Factory;

class AppRive {
  
  static Factory get riveFactory => kIsWeb ? Factory.flutter : Factory.rive;

  static const List<String> _kFlutterRendererStems = [
    'anim_xingau_result',
    'lobbytx',
    'badge_tx',
  ];

  static Factory factoryForUrl(String url) =>
      usesFlutterRenderer(url) ? Factory.flutter : riveFactory;

  static bool usesFlutterRenderer(String url) =>
      _kFlutterRendererStems.any((stem) => url.contains(stem));

  static String get animCardBig => 'anim_card_big.riv';

  static String get animCardBigGlow => 'anim_card_big_glow.riv';

  static String get animCardNho => 'anim_nho.riv';

  static String get animLoading => 'anim_loading.riv';

  static String get ghiban => 'ghiban.riv';

  static String get mnlobbytx => 'lobbytx.riv';
  static String get mnBadgeTx => 'badge_tx_1.riv';
  static String get txAnimBaseTai => 'anim_base_tai.riv';
  static String get txAnimBaseXiu => 'anim_base_xiu.riv';
  static String get txAnimBaseTaiMobileWeb => 'anim_base_tai_mobile_web.riv';
  static String get txAnimBaseXiuMobileWeb => 'anim_base_xiu_mobile_web.riv';
  static String get txAnimBaseTaiWeb => 'anim_base_tai_web.riv';
  static String get txAnimBaseXiuWeb => 'anim_base_xiu_web.riv';
  static String get txAnimRecentResult =>
      'anim_recent_result.riv';
  static String get txAnimXingau => 'anim_xingau.riv';
  static String get txAnimBowl => 'bowl.riv';
  static String get txAnimBtnNan => 'btn_nan.riv';
  static String get txAnimXingauInput =>
      'anim_xingau_input.riv';
  static String get txAnimXingauResult =>
      'anim_xingau_result.riv';

  static String get mpAnimAuto => 'btn_auto.riv';
  static String get mpAnimSpin =>
      'btn_spin_minipoker.riv';
  static String get mpAnimTurbo => 'btn_turbo.riv';
  static String get mpAnimReels3 =>
      'reels_minipoker_3.riv';

  static String get dgReels => 'reels_dragonball_2.riv';
  static String get dgAnimSpin => 'btn_spin_dragonball.riv';
  static String get spinKimCuong => 'btn_spin_kimcuong.riv';

  static String get upDownASymbol => 'updown_asymbol.riv';
  static String get upDowButtonDown => 'updown_btndown.riv';
  static String get upDownButtonUp => 'updown_btnup.riv';
  static String get upDownBtnStart => 'updown_btnstart.riv';

  static List<String> get remoteUrlsForPreloadUpDown => <String>[
    upDownASymbol,
    upDowButtonDown,
    upDownButtonUp,
    upDownBtnStart,
  ];

  static String get jackpotMiniGame => 'jackpot_mini_game.riv';

  static List<String> get remoteUrlsForPreloadMiniPoker => <String>[
    mpAnimAuto,
    dgAnimSpin,
    mpAnimTurbo,
    mpAnimReels3,
  ];

  static List<String> get remoteUrlsForPreloadDragonBall => <String>[
    mpAnimAuto,
    dgAnimSpin,
    mpAnimTurbo,
    dgReels,
  ];

  static String get matchNotice => 'match_notice.riv';

  static List<String> get remoteUrlsForPreloadTaiXiu => <String>[
    txAnimBaseTai,
    txAnimBaseXiu,
    txAnimBaseTaiWeb,
    txAnimBaseXiuWeb,
    txAnimRecentResult,
    txAnimXingau,
    txAnimXingauInput,
    txAnimXingauResult,
    txAnimBowl,
    txAnimBtnNan,
    ghiban,
  ];

  static List<String> get remoteUrlsForPreload => <String>[
    animCardBig,
    animCardBigGlow,
    animCardNho,
    animLoading,
    matchNotice,
    spinKimCuong,
    ...remoteUrlsForPreloadTaiXiu,
    ...remoteUrlsForPreloadMiniPoker,
  ];
}

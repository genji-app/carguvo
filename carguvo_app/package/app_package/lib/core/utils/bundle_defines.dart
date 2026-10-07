class BundleDefines {
  BundleDefines._();

  static const String main = 'main';
  static const String dynamic = 'dynamic';
  static const String mini = 'mini';
  static const String lode = 'lode';
  static const String taiXiu = 'tx';
  static const String trenDuoi = 'up_down';
  static const String kimCuong = 'diamond';
  static const String miniPoker = 'mini_poker';
  static const String dragonBall = 'dragon_ball';

  static const String volta = 'volta';

  static const List<String> miniGameBundles = <String>[
    taiXiu,
    trenDuoi,
    kimCuong,
    miniPoker,
    dragonBall,
  ];

  static const Map<String, List<String>> bundleDependencies = {
    taiXiu: [mini],
    trenDuoi: [mini],
    kimCuong: [mini],
    miniPoker: [mini],
    dragonBall: [mini],
  };
}

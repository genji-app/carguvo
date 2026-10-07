class BrandConfig {
  const BrandConfig(this.raw);

  factory BrandConfig.fromJson(Map<String, dynamic> json) => BrandConfig(json);

  static const BrandConfig empty = BrandConfig(<String, dynamic>{});

  final Map<String, dynamic> raw;

  bool get isEmpty => raw.isEmpty;

  String? str(String key) {
    final v = raw[key];
    if (v == null) return null;
    return v.toString();
  }

  String? url(String key) {
    final v = str(key)?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  int? intOf(String key) {
    final v = raw[key];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? doubleOf(String key) {
    final v = raw[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  bool? boolOf(String key) {
    final v = raw[key];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return null;
  }

  int? get agentId => intOf('agentId');
  String? get agentCode => str('agentCode');
  String? get clientId => str('clientId');
  String? get brandId => str('brandId');
  String? get brand => str('brand');
  String? get authBrand => str('authBrand');
  String? get bundleId => str('bundleId');
  String? get appName => str('appName');
  String? get chatZone => str('chatZone');
  String? get chatRoom => str('chatRoom');

  String? get hostDomain => url('host_domain');
  String? get apiDomain => url('api_domain');
  String? get sportDomain => url('sport_domain');
  String? get wsSportDomain => url('ws_sport_domain');
  String? get gameApiUrl => url('game_api_url');
  String? get gamesUrl => url('games_url');
  String? get miniGameWsUrl => url('ws_mini_game');
  String? get livechatLicense => str('livechat_license');

  String? get rsDomain => url('rs_domain');

  String? get casinoConfigUrl => url('casino_config_url');

  String? get secretKey {
    final p0 = str('cache_prefix') ?? '';
    final p1 = str('display_key') ?? '';
    final p2 = str('locale_suffix') ?? '';
    final p3 = str('render_token') ?? '';
    if (p0.isEmpty || p1.isEmpty || p2.isEmpty || p3.isEmpty) return null;
    return '$p0$p1$p2$p3';
  }

  String? get sentryDsnWeb => url('sentry_dsn_web');
  String? get sentryDsnMobile => url('sentry_dsn_mobile');
  bool? get sentryEnabled => boolOf('sentry_enabled');
  double? get sentryTracesSampleRate => doubleOf('sentry_traces_sample_rate');
  String? get sentryEnvironment => str('sentry_environment');
  bool? get sentryAllowDebug => boolOf('sentry_allow_debug');
}

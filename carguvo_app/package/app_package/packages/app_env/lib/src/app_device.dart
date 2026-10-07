enum HostPlatform {
  web,
  android,
  ios,
  macos,
  windows,
  linux,

  unknown;

  bool get isNativeMobile => this == android || this == ios;
  bool get isNativeDesktop => this == macos || this == windows || this == linux;
}

class AppDevice {
  AppDevice._();

  static HostPlatform _platform = HostPlatform.unknown;
  static String _userAgent = '';
  static int _maxTouchPoints = 0;
  static String? _pageUrl;
  static String _pageBaseUrl = '';
  static bool _configured = false;

  static bool get isConfigured => _configured;

  static void configure({
    required HostPlatform platform,
    String? userAgent,
    int maxTouchPoints = 0,
    String? pageUrl,
    String pageBaseUrl = '',
  }) {
    _platform = platform;
    _userAgent = userAgent ?? '';
    _maxTouchPoints = maxTouchPoints;
    _pageUrl = pageUrl;
    _pageBaseUrl = pageBaseUrl;
    _configured = true;
  }

  static void resetForTesting() {
    _platform = HostPlatform.unknown;
    _userAgent = '';
    _maxTouchPoints = 0;
    _pageUrl = null;
    _pageBaseUrl = '';
    _configured = false;
  }

  static HostPlatform get platform => _platform;

  static String get userAgent => _userAgent;

  static String? get pageUrl => _pageUrl;

  static String get pageBaseUrl => _pageBaseUrl;

  static bool get isBrowser => platform == HostPlatform.web;

  static bool get isNativeApp => !isBrowser && platform != HostPlatform.unknown;

  static bool get isAndroid =>
      platform == HostPlatform.android || (isBrowser && _uaHas('Android'));

  static bool get isIOS =>
      platform == HostPlatform.ios || (isBrowser && _isIOSBrowserUA);

  static bool get isNativeDesktop => platform.isNativeDesktop;

  static bool get isMobile =>
      platform.isNativeMobile || (isBrowser && isMobileBrowser);

  static bool get isPhone =>
      isBrowser ? isPhoneBrowser : platform.isNativeMobile;

  static bool get isTablet => isBrowser && isTabletBrowser;

  static bool get isMobileBrowser {
    if (!isBrowser) return false;
    final ua = _userAgent.toLowerCase();
    if (RegExp(
      r'mobi|android|iphone|ipod|ipad|iemobile|blackberry|opera mini|windows phone|webos',
    ).hasMatch(ua)) {
      return true;
    }
    return _isIPadOSDesktopUA;
  }

  static bool get isPhoneBrowser {
    if (!isBrowser) return false;
    final isIPad = _uaHas('iPad');
    final isIOSPhone = _uaHas('iPhone') || _uaHas('iPod');
    return _uaHas('Android') || (isIOSPhone && !isIPad);
  }

  static bool get isTabletBrowser =>
      isBrowser && (_uaHas('iPad') || _isIPadOSDesktopUA);

  static bool get isAndroidBrowser => isBrowser && _uaHas('Android');

  static bool get isIOSBrowser => isBrowser && _isIOSBrowserUA;

  static bool get isIOSSafariBrowser {
    if (!isBrowser) return false;
    if (!(_uaHas('iPhone') || _uaHas('iPod'))) return false;
    return _uaHas('Version/') &&
        !_uaHas('CriOS') &&
        !_uaHas('FxiOS') &&
        !_uaHas('EdgiOS') &&
        !_uaHas('OPiOS');
  }

  static bool get isFirefoxBrowser =>
      isBrowser && (_uaHas('Firefox/') || _uaHas('FxiOS'));

  static int get platformId {
    if (isBrowser) return 4;
    return switch (platform) {
      HostPlatform.ios => 1,
      HostPlatform.android => 2,
      _ => 4,
    };
  }

  static int get versionId => isBrowser ? 20 : 27;

  static String get osName => switch (platform) {
    HostPlatform.web => 'Web',
    HostPlatform.android => 'Android',
    HostPlatform.ios => 'iOS',
    HostPlatform.macos => 'macOS',
    HostPlatform.windows => 'Windows',
    HostPlatform.linux => 'Linux',
    HostPlatform.unknown => 'Web',
  };

  static bool _uaHas(String token) => _userAgent.contains(token);

  static bool get _isIOSBrowserUA =>
      _uaHas('iPhone') ||
      _uaHas('iPod') ||
      _uaHas('iPad') ||
      _isIPadOSDesktopUA;

  static bool get _isIPadOSDesktopUA =>
      _userAgent.toLowerCase().contains('macintosh') && _maxTouchPoints > 1;
}

library;

import 'package:app_env/app_env.dart';

bool get isIOSSafariWeb => AppDevice.isIOSSafariBrowser;

bool get isWebAndroidBrowser => AppDevice.isAndroidBrowser;

bool get isWebIOSBrowser => AppDevice.isIOSBrowser;

bool get isWebIPadBrowser => AppDevice.isTabletBrowser;

bool get isWebPhoneBrowser => AppDevice.isPhoneBrowser;

bool get isFirefoxWeb => AppDevice.isFirefoxBrowser;

bool get isLivestreamUnsupportedBrowser => AppDevice.isIOSBrowser;

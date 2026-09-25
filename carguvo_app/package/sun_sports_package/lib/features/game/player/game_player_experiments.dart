library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';

bool get embedGameOnMobileWeb => kIsWeb && isWebPhoneBrowser;

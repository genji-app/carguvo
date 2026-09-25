import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

void cocosLog(String step, String message) {
  if (kDebugMode) debugPrint('🎮 [cocos][$step] $message');
}

import 'package:flutter/foundation.dart';

const bool kOrientationVerboseLog = false;

void orientationLog(String message) {
  if (kOrientationVerboseLog) {
    debugPrint(message);
  }
}

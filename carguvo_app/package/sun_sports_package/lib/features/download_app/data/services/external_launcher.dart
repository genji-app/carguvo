library;

export 'external_launcher_io.dart'
    if (dart.library.js_interop) 'external_launcher_web.dart';

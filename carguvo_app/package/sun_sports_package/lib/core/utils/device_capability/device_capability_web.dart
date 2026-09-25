import 'package:web/web.dart' as web;

bool get hasMouse => web.window.matchMedia('(pointer: fine)').matches;

import 'package:flutter/material.dart';

import 'package:sun_sports/features/sun_247/presentation/desktop/sun_247_desktop_mobile.dart'
    if (dart.library.html)
        'package:sun_sports/features/sun_247/presentation/desktop/sun_247_desktop_web.dart';

class Sun247Desktop extends StatelessWidget {
  const Sun247Desktop({super.key});

  @override
  Widget build(BuildContext context) => const Sun247DesktopImpl();
}
